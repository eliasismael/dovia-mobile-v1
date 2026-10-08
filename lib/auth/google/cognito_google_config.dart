import '/backend/api_requests/api_config.dart';

/// Configuración pública de Cognito para entrar con Google (Authorization
/// Code + PKCE en el navegador del sistema). Son identificadores públicos: no
/// hay secretos de cliente.
///
/// Cada entorno usa su dominio de Cognito y su cliente **móvil**, del mismo
/// entorno que la API (ver `kApiBaseUrl`). Se pueden pisar con
/// `--dart-define=COGNITO_DOMAIN=... --dart-define=COGNITO_MOBILE_CLIENT_ID=...`
/// (p. ej. para producción, que todavía no tiene valores).
///
/// `COGNITO_USER_POOL_ID` es opcional: con él se usa el discovery de Cognito
/// y AppAuth valida además el emisor del ID token. No se deduce del dominio.
class CognitoGoogleConfig {
  const CognitoGoogleConfig({
    required this.domain,
    required this.clientId,
    this.userPoolId = '',
    this.scopes = fullScopes,
  });

  /// Origen del dominio de Cognito (sin barra final).
  final String domain;

  /// Cliente público móvil (no el web).
  final String clientId;
  final String userPoolId;

  /// Scopes que se piden a Cognito. Login y registro piden los mismos.
  final List<String> scopes;

  static const redirectUrl = 'com.mycompany.dovia://oauth/callback';
  static const logoutRedirectUrl = 'com.mycompany.dovia://auth/login';

  /// Los de la guía del backend.
  static const fullScopes = ['openid', 'email', 'profile'];

  /// El cliente móvil de staging todavía no tiene habilitado `profile`
  /// (Cognito responde `invalid_scope`). Cuando lo habiliten, usar
  /// [fullScopes] también ahí.
  static const scopesWithoutProfile = ['openid', 'email'];

  String get authorizationEndpoint => '$domain/oauth2/authorize';
  String get tokenEndpoint => '$domain/oauth2/token';
  String get logoutEndpoint => '$domain/logout';

  /// Discovery de OpenID del User Pool, o null si no se configuró el id. La
  /// región va en el propio id (`us-east-2_XXXX`).
  String? get discoveryUrl {
    if (userPoolId.isEmpty || !userPoolId.contains('_')) return null;
    final region = userPoolId.split('_').first;
    return 'https://cognito-idp.$region.amazonaws.com/$userPoolId'
        '/.well-known/openid-configuration';
  }

  static const dev = CognitoGoogleConfig(
    domain: 'https://us-east-20pc8xmyvl.auth.us-east-2.amazoncognito.com',
    clientId: '4s7ttd11648lb2mr9cdsvcco3g',
    userPoolId: String.fromEnvironment('COGNITO_USER_POOL_ID'),
  );

  static const staging = CognitoGoogleConfig(
    domain: 'https://us-east-2amy5dp2mj.auth.us-east-2.amazoncognito.com',
    clientId: '4t90gdei6t163sv0vuq70qfeqb',
    userPoolId: String.fromEnvironment('COGNITO_USER_POOL_ID'),
    scopes: scopesWithoutProfile,
  );

  static const _envDomain = String.fromEnvironment('COGNITO_DOMAIN');
  static const _envClientId =
      String.fromEnvironment('COGNITO_MOBILE_CLIENT_ID');

  /// La del entorno de este build, o null si no hay (entonces no se ofrece
  /// entrar con Google).
  static CognitoGoogleConfig? get current =>
      forEnvironment(kApiEnvLabel, domain: _envDomain, clientId: _envClientId);

  static CognitoGoogleConfig? forEnvironment(
    String envLabel, {
    String domain = '',
    String clientId = '',
  }) {
    if (domain.isNotEmpty && clientId.isNotEmpty) {
      return CognitoGoogleConfig(
        domain: domain,
        clientId: clientId,
        userPoolId: const String.fromEnvironment('COGNITO_USER_POOL_ID'),
      );
    }
    switch (envLabel) {
      case 'DEV':
        return dev;
      case 'STAGING':
        return staging;
      default:
        return null;
    }
  }
}
