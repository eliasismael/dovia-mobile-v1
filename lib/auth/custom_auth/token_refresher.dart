import 'package:flutter/foundation.dart';

import '/auth/google/cognito_google_config.dart';
import '/auth/google/google_oauth_client.dart';
import '/backend/api_requests/api_auth.dart';
import 'auth_util.dart';

/// Se llama cuando el backend rechaza el refreshToken y la sesión se cierra,
/// con el motivo para mostrarle al usuario. Lo registra `main.dart` para
/// llevar al login.
void Function(String message)? onSessionExpired;

const sessionExpiredMessage = 'Tu sesión expiró. Volvé a iniciar sesión.';
const accountDisabledMessage =
    'Tu cuenta está deshabilitada o suspendida. Si crees que es un error, '
    'contacta a soporte.';

/// Respuestas de `/auth/refresh-token` que significan que el refreshToken ya
/// no sirve (vencido, revocado o cuenta deshabilitada).
const _kRejectedRefreshStatuses = {400, 401, 403};

Future<String?>? _inFlight;
int? _inFlightGeneration;
DateTime? _lastRefresh;

/// Vencimiento del idToken a partir del `expiresIn` (segundos) que devuelven
/// el sign-in y el refresh. Sin dato, null.
DateTime? tokenExpirationFrom(int? expiresIn) =>
    expiresIn == null ? null : DateTime.now().add(Duration(seconds: expiresIn));

/// Renueva el idToken con el refreshToken guardado y devuelve el nuevo.
///
/// Si ya hay una renovación en curso se espera esa misma: varias llamadas que
/// dan 401 a la vez no disparan varios refresh. Si el backend rechaza el
/// refreshToken (4xx) la sesión se cierra; un error de red no la cierra, para
/// no desloguear a quien se quedó sin conexión.
///
/// La renovación queda atada a la sesión que la pidió: si mientras tanto se
/// cerró sesión o entró otra cuenta, la respuesta se descarta.
Future<String?> refreshSession() {
  final generation = authManager.sessionGeneration;
  final pending = _inFlight;
  if (pending != null && _inFlightGeneration == generation) return pending;

  late final Future<String?> refresh;
  refresh = _refresh(generation).whenComplete(() {
    if (identical(_inFlight, refresh)) _inFlight = null;
  });
  _inFlight = refresh;
  _inFlightGeneration = generation;
  return refresh;
}

/// La sesión que pidió la renovación ya no es la actual.
bool _stale(int generation) => authManager.sessionGeneration != generation;

/// Si el token ya venció (o vence en menos de 30 s), lo renueva y devuelve el
/// nuevo; si no, null. Lo usa el ApiManager antes de cada pedido autenticado.
Future<String?> freshTokenIfExpired() async {
  if (!loggedIn) return null;
  final expiration = authManager.tokenExpiration;
  if (expiration == null) return null;
  if (expiration.isAfter(DateTime.now().add(const Duration(seconds: 30)))) {
    return null;
  }
  return refreshSession();
}

/// Si el token vence pronto (o no se sabe cuándo vence y hace rato que no se
/// renueva), lo renueva. Pensado para cuando la app vuelve del fondo.
Future<void> refreshSessionIfStale() async {
  if (!loggedIn) return;
  final now = DateTime.now();
  final expiration = authManager.tokenExpiration;
  final stale = expiration != null
      ? expiration.isBefore(now.add(const Duration(minutes: 5)))
      : _lastRefresh == null ||
          now.difference(_lastRefresh!) > const Duration(minutes: 50);
  if (stale) await refreshSession();
}

Future<String?> _refresh(int generation) async {
  if (!loggedIn) return null;

  final refreshToken = authManager.refreshToken;
  if (refreshToken == null || refreshToken.isEmpty) {
    await _expire();
    return null;
  }

  if (authManager.isGoogleSession) {
    return _refreshGoogle(refreshToken, generation);
  }

  try {
    final call = DOVIAAPIAuthContextGroup.refreshTokenNEWCall;
    final response = await call.call(refreshToken: refreshToken);
    if (_stale(generation)) return null;
    final idToken = call.idToken(response.jsonBody);

    if (response.succeeded && idToken != null && idToken.isNotEmpty) {
      _lastRefresh = DateTime.now();
      authManager.updateAuthUserData(
        authenticationToken: idToken,
        refreshToken:
            call.refreshTokenResponse(response.jsonBody) ?? refreshToken,
        tokenExpiration: tokenExpirationFrom(call.expiresIn(response.jsonBody)),
        authUid: authManager.uid,
      );
      return idToken;
    }

    // Sólo un rechazo del refreshToken cierra la sesión. Un 429 (demasiados
    // pedidos), 408 u otro 4xx pasajero se reintenta más adelante.
    if (_kRejectedRefreshStatuses.contains(response.statusCode)) {
      // 403 USER_DISABLED: el backend ahora también rechaza el refresh de una
      // cuenta deshabilitada o suspendida. No es una sesión vencida.
      await _expire(response.statusCode == 403
          ? accountDisabledMessage
          : sessionExpiredMessage);
    }
  } catch (e) {
    if (kDebugMode) print('No se pudo renovar la sesión: $e');
  }
  return null;
}

/// Las sesiones de Google se renuevan directo en Cognito con el cliente
/// móvil (no con `/auth/refresh-token`, que es para correo y contraseña).
Future<String?> _refreshGoogle(String refreshToken, int generation) async {
  final config = CognitoGoogleConfig.current;
  if (config == null) {
    await _expire();
    return null;
  }
  try {
    final tokens = await googleOAuthClient.refresh(config, refreshToken);
    if (_stale(generation)) return null;
    _lastRefresh = DateTime.now();
    final claimId = tokens.claims['custom:id']?.toString();
    if (kDebugMode) {
      final c = tokens.claims;
      print('[Google] refresh OK: custom:id=${claimId != null} '
          'custom:profile_complete=${c['custom:profile_complete']} '
          'custom:verified=${c['custom:verified']} '
          'cognito:groups=${c['cognito:groups']}');
    }
    authManager.updateAuthUserData(
      authenticationToken: tokens.idToken,
      refreshToken: tokens.refreshToken ?? refreshToken,
      tokenExpiration: tokens.expiresAt,
      // Tras el alta federada el claim `custom:id` recién aparece acá.
      authUid: (claimId != null && claimId.isNotEmpty) ? claimId : null,
    );
    return tokens.idToken;
  } on GoogleRefreshRejected {
    if (!_stale(generation)) await _expire();
  } catch (e) {
    if (kDebugMode) print('No se pudo renovar la sesión de Google: $e');
  }
  return null;
}

Future<void> _expire([String message = sessionExpiredMessage]) async {
  await authManager.signOut();
  onSessionExpired?.call(message);
}
