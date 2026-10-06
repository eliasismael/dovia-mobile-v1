import 'dart:async';

import '/backend/api_requests/api_users.dart';
import 'auth_util.dart';
import 'token_refresher.dart';

/// Renueva la sesión guardada al abrir la app.
///
/// El idToken de Cognito vence a la hora: sin esto la app abría el home con
/// sesión iniciada pero todas las llamadas (incluido el perfil) fallaban.
///
/// Con el refreshToken se pide un idToken nuevo. Si el backend lo rechaza la
/// sesión se cierra y el router lleva al login. Un error de red no cierra la
/// sesión, para no desloguear a quien abre la app sin conexión.
Future<void> restoreSession() async {
  if (!loggedIn) return;
  // Con mala señal no se frena el splash más de unos segundos: la renovación
  // sigue en segundo plano y, si una llamada da 401 antes, la cubre igual.
  await refreshSession()
      .timeout(const Duration(seconds: 8), onTimeout: () => null);
  // No frena el arranque: el uid solo hace falta más adelante.
  unawaited(_backfillUid());
}

/// Las sesiones iniciadas antes de guardar el uid en el login lo tienen vacío.
/// Se completa con el perfil para no obligar a cerrar sesión.
Future<void> _backfillUid() async {
  if (!loggedIn || (authManager.uid ?? '').isNotEmpty) return;
  final call = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall;
  final response =
      await call.call(authToken: authManager.authenticationToken);
  final id = call.userId(response.jsonBody);
  if (!response.succeeded || id == null || id.isEmpty) return;
  authManager.updateAuthUserData(
    authenticationToken: authManager.authenticationToken,
    refreshToken: authManager.refreshToken,
    tokenExpiration: authManager.tokenExpiration,
    authUid: id,
  );
}
