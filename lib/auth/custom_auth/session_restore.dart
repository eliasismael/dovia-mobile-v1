import 'package:flutter/foundation.dart';

import '/backend/api_requests/api_auth.dart';
import 'auth_util.dart';

/// Renueva la sesión guardada al abrir la app.
///
/// El login no guarda el vencimiento del token, así que la app daba la sesión
/// por válida aunque el idToken de Cognito ya hubiera vencido: abría el home
/// con sesión iniciada pero todas las llamadas (incluido el perfil) fallaban.
///
/// Con el refreshToken se pide un idToken nuevo. Si el backend lo rechaza la
/// sesión se cierra y el router lleva al login. Un error de red no cierra la
/// sesión, para no desloguear a quien abre la app sin conexión.
Future<void> restoreSession() async {
  if (!loggedIn) return;

  final refreshToken = authManager.refreshToken;
  if (refreshToken == null || refreshToken.isEmpty) {
    await authManager.signOut();
    return;
  }

  try {
    final call = DOVIAAPIAuthContextGroup.refreshTokenNEWCall;
    final response = await call.call(refreshToken: refreshToken);
    final idToken = call.idToken(response.jsonBody);

    if (response.succeeded && idToken != null && idToken.isNotEmpty) {
      authManager.updateAuthUserData(
        authenticationToken: idToken,
        refreshToken:
            call.refreshTokenResponse(response.jsonBody) ?? refreshToken,
        tokenExpiration: authManager.tokenExpiration,
        authUid: authManager.uid,
      );
      return;
    }

    if (response.statusCode >= 400 && response.statusCode < 500) {
      await authManager.signOut();
    }
  } catch (e) {
    if (kDebugMode) print('No se pudo renovar la sesión: $e');
  }
}
