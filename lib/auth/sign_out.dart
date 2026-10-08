import 'dart:async';

import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/auth/google/cognito_google_config.dart';
import '/auth/google/google_oauth_client.dart';
import '/auth/registration_progress.dart';
import '/backend/api_requests/api_auth.dart';
import '/flutter_flow/nav/nav.dart';
import '/index.dart' show SignInWidget;

/// Cierra la sesión y lleva al login. Es el cierre de sesión de todos los
/// roles: antes cada pantalla de ajustes tenía el suyo y no hacían lo mismo
/// (algunos no revocaban las sesiones en el backend, otros no limpiaban el
/// perfil). El estado del usuario se limpia en el listener de `main.dart`.
///
/// Con [revokeSessions] se invalidan también los refreshToken en el backend.
/// Si esa llamada falla (sin conexión) la sesión local se cierra igual.
Future<void> signOutAndGoToLogin(
  BuildContext context, {
  bool revokeSessions = true,
}) async {
  final router = GoRouter.of(context);
  final token = authManager.authenticationToken;
  if (revokeSessions && token != null && token.isNotEmpty) {
    await DOVIAAPIAuthContextGroup.logoutAllCall.call(idToken: token);
  }
  // Un paso de registro pendiente (p. ej. la revisión del asociado) es de esta
  // cuenta: no debe aplicarse a quien inicie sesión después.
  await RegistrationProgress.clear();
  final wasGoogle = authManager.isGoogleSession;
  router.prepareAuthEvent();
  await authManager.signOut();
  router.clearRedirectLocation();
  router.goNamed(SignInWidget.routeName);
  // Con Google además se cierra la sesión de Cognito en el navegador, para
  // que la próxima vez se pueda elegir otra cuenta. La sesión local ya está
  // cerrada aunque esto no vuelva.
  final config = CognitoGoogleConfig.current;
  if (wasGoogle && config != null) {
    unawaited(googleOAuthClient.logout(config));
  }
}
