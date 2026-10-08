import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'cognito_google_config.dart';

/// Tokens de Cognito obtenidos al entrar con Google (o al renovarlos).
class GoogleTokens {
  const GoogleTokens({
    required this.idToken,
    this.refreshToken,
    this.expiresAt,
  });

  /// ID token de Cognito: es el que recibe la API Dovia.
  final String idToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  Map<String, dynamic> get claims => jwtClaims(idToken);
}

/// Cognito rechazó el refresh token (vencido o revocado): hay que volver a
/// iniciar sesión. Un error de red no es esto.
class GoogleRefreshRejected implements Exception {
  const GoogleRefreshRejected();
}

/// Claims del payload de un JWT, sin validar. Solo se leen datos para la UI
/// (nombre, correo, `custom:id`): AppAuth ya validó audiencia, vencimiento,
/// nonce y, con discovery, el emisor; el token llega directo del endpoint de
/// Cognito por HTTPS. La API vuelve a validarlo con su authorizer.
Map<String, dynamic> jwtClaims(String? jwt) {
  final parts = jwt?.split('.') ?? const [];
  if (parts.length != 3) return const {};
  try {
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final decoded = jsonDecode(payload);
    return decoded is Map<String, dynamic> ? decoded : const {};
  } catch (_) {
    return const {};
  }
}

/// Vencimiento del token según su claim `exp`.
DateTime? jwtExpiration(String? jwt) {
  final exp = jwtClaims(jwt)['exp'];
  return exp is num
      ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000)
      : null;
}

/// Inicio de sesión con Google a través de Cognito. Interfaz para poder
/// reemplazarla en los tests: el plugin real abre el navegador del sistema.
abstract class GoogleOAuthClient {
  /// Abre Google en el navegador del sistema y canjea el código (PKCE S256,
  /// state y nonce). Null si la persona cerró el navegador.
  Future<GoogleTokens?> signIn(CognitoGoogleConfig config);

  /// Renueva los tokens directo en Cognito con el cliente móvil. Lanza
  /// [GoogleRefreshRejected] si Cognito rechaza el refresh token.
  Future<GoogleTokens> refresh(CognitoGoogleConfig config, String refreshToken);

  /// Cierra la sesión del navegador en Cognito (best effort).
  Future<void> logout(CognitoGoogleConfig config);
}

/// El que usa la app; los tests lo reemplazan.
GoogleOAuthClient googleOAuthClient = AppAuthGoogleOAuthClient();

class AppAuthGoogleOAuthClient implements GoogleOAuthClient {
  AppAuthGoogleOAuthClient([FlutterAppAuth? appAuth])
      : _appAuth = appAuth ?? const FlutterAppAuth();

  final FlutterAppAuth _appAuth;

  AuthorizationServiceConfiguration _service(CognitoGoogleConfig c) =>
      AuthorizationServiceConfiguration(
        authorizationEndpoint: c.authorizationEndpoint,
        tokenEndpoint: c.tokenEndpoint,
        endSessionEndpoint: c.logoutEndpoint,
      );

  @override
  Future<GoogleTokens?> signIn(CognitoGoogleConfig config) async {
    final discoveryUrl = config.discoveryUrl;
    try {
      // AppAuth genera el verifier/challenge S256, el state y el nonce, abre
      // el navegador del sistema (Custom Tabs / ASWebAuthenticationSession,
      // nunca un WebView), valida el state del callback y el nonce del ID
      // token, y canjea el código una sola vez.
      final res = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          CognitoGoogleConfig.redirectUrl,
          serviceConfiguration: discoveryUrl == null ? _service(config) : null,
          discoveryUrl: discoveryUrl,
          scopes: config.scopes,
          additionalParameters: const {'identity_provider': 'Google'},
          // Cognito se lo pasa a Google: siempre muestra el selector de
          // cuentas. Si no, Google entra solo con la cuenta abierta en el
          // navegador y no se puede usar otra (ni registrarse con otra).
          promptValues: const ['select_account'],
          // iOS: sesión efímera, sin cookies compartidas con Safari. Así se
          // puede elegir otra cuenta de Google después de cerrar sesión.
          externalUserAgent:
              ExternalUserAgent.ephemeralAsWebAuthenticationSession,
        ),
      );
      final idToken = res.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Cognito no devolvió el ID token');
      }
      return GoogleTokens(
        idToken: idToken,
        refreshToken: res.refreshToken,
        expiresAt: jwtExpiration(idToken) ?? res.accessTokenExpirationDateTime,
      );
    } on FlutterAppAuthUserCancelledException {
      return null;
    }
  }

  @override
  Future<GoogleTokens> refresh(
      CognitoGoogleConfig config, String refreshToken) async {
    final discoveryUrl = config.discoveryUrl;
    try {
      final res = await _appAuth.token(TokenRequest(
        config.clientId,
        CognitoGoogleConfig.redirectUrl,
        refreshToken: refreshToken,
        serviceConfiguration: discoveryUrl == null ? _service(config) : null,
        discoveryUrl: discoveryUrl,
        scopes: config.scopes,
      ));
      final idToken = res.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Cognito no devolvió el ID token');
      }
      return GoogleTokens(
        idToken: idToken,
        // Cognito no siempre devuelve uno nuevo: se conserva el anterior.
        refreshToken: res.refreshToken ?? refreshToken,
        expiresAt: jwtExpiration(idToken) ?? res.accessTokenExpirationDateTime,
      );
    } on FlutterAppAuthPlatformException catch (e) {
      final error = e.platformErrorDetails.error;
      if (error == 'invalid_grant' || error == 'unauthorized_client') {
        throw const GoogleRefreshRejected();
      }
      rethrow;
    }
  }

  @override
  Future<void> logout(CognitoGoogleConfig config) async {
    // En iOS la sesión es efímera: no queda cookie que borrar, y abrir el
    // logout mostraría el aviso de "quiere usar ... para iniciar sesión".
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _appAuth.endSession(EndSessionRequest(
        postLogoutRedirectUrl: CognitoGoogleConfig.logoutRedirectUrl,
        serviceConfiguration: _service(config),
        // Cognito no usa los parámetros estándar de OIDC para salir.
        additionalParameters: {
          'client_id': config.clientId,
          'logout_uri': CognitoGoogleConfig.logoutRedirectUrl,
        },
      ));
    } catch (e) {
      // La sesión local ya se cerró; esto solo limpia la cookie de Cognito.
      if (kDebugMode) print('No se pudo cerrar la sesión de Cognito: $e');
    }
  }
}
