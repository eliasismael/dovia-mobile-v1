import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/auth/custom_auth/token_refresher.dart';
import '/auth/post_login_navigation.dart';
import '/auth/registration_progress.dart';
import '/backend/api_requests/api_auth.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_users.dart';
import '/core/api_error.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show GoogleDatosWidget;
import 'cognito_google_config.dart';
import 'google_oauth_client.dart';

/// Desde dónde se tocó "Continuar con Google": el login o crear cuenta.
enum GoogleAuthIntent { signIn, signUp }

const googleUnavailableMessage =
    'El ingreso con Google no está disponible en esta versión de la app.';
const googleFailedMessage =
    'No pudimos iniciar sesión con Google. Intenta de nuevo.';
const accountMethodConflictMessage =
    'Este correo ya tiene una cuenta de DOVIA con contraseña. Inicia sesión '
    'con tu correo y contraseña.';
const federatedIdentityConflictMessage =
    'Hay un problema con esta cuenta de Google. Contacta a soporte.';

/// Se ofrece en Android e iOS cuando el entorno tiene Cognito configurado.
/// En web haría falta el cliente y el callback web, que es otro flujo.
bool get googleLoginAvailable => !kIsWeb && CognitoGoogleConfig.current != null;

/// Inicia sesión con Google (Cognito, navegador del sistema) y sigue según el
/// perfil de Dovia:
/// - ya tiene cuenta: entra como con contraseña ([navigateAfterSignIn]);
/// - no tiene: con intención explícita de crearla (crear cuenta, o confirmar
///   desde el login) va al formulario de datos para el alta federada.
///
/// Un 401/403 o la falta de `custom:id` nunca crean la cuenta solos: el
/// backend no distingue con certeza "no registrado" de otros fallos.
Future<void> continueWithGoogle(
  BuildContext context, {
  required GoogleAuthIntent intent,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  void snack(String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));

  final config = CognitoGoogleConfig.current;
  if (kIsWeb || config == null) {
    snack(googleUnavailableMessage);
    return;
  }

  GoogleTokens? tokens;
  try {
    tokens = await googleOAuthClient.signIn(config);
  } catch (e) {
    if (kDebugMode) print('Google: no se pudo iniciar sesión: $e');
    snack(googleFailedMessage);
    return;
  }
  // Cerró el navegador: no es un error.
  if (tokens == null || !context.mounted) return;

  final claims = tokens.claims;
  final claimId = claims['custom:id']?.toString() ?? '';
  if (kDebugMode) {
    print('[Google] login (${intent.name}): custom:id=${claimId.isNotEmpty} '
        'custom:profile_complete=${claims['custom:profile_complete']} '
        'custom:verified=${claims['custom:verified']} '
        'cognito:groups=${claims['cognito:groups']}');
  }
  router.prepareAuthEvent();
  await authManager.signIn(
    authenticationToken: tokens.idToken,
    refreshToken: tokens.refreshToken,
    tokenExpiration: tokens.expiresAt,
    authUid: claimId.isEmpty ? null : claimId,
    provider: kGoogleAuthProvider,
  );
  final email = claims['email']?.toString() ?? '';
  if (email.isNotEmpty) FFAppState().UserEmail = email;

  final profileCall = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall;
  final profile = await profileCall.call(authToken: tokens.idToken);
  if (!context.mounted) return;

  if (profile.succeeded) {
    final profileUid = profileCall.userId(profile.jsonBody) ?? '';
    if ((authManager.uid ?? '').isEmpty && profileUid.isNotEmpty) {
      authManager.updateAuthUserData(
        authenticationToken: authManager.authenticationToken,
        refreshToken: authManager.refreshToken,
        tokenExpiration: authManager.tokenExpiration,
        authUid: profileUid,
      );
    }
    if (intent == GoogleAuthIntent.signUp) {
      snack('Ya tenías una cuenta con este Google: te ingresamos.');
    }
    final roles = getJsonField(profile.jsonBody, r'$.data.roles');
    await navigateAfterSignIn(
      context,
      profileBody: profile.jsonBody,
      roleSelected: roles is List ? roles.isNotEmpty : null,
      associateProfileComplete: castToType<bool>(
          getJsonField(profile.jsonBody, r'$.data.isAssociateProfileComplete')),
      verified: profileCall.isVerified(profile.jsonBody),
    );
    return;
  }

  final status = profile.statusCode;
  if (status == 403) {
    await _abort(router, config);
    snack(accountDisabledMessage);
    return;
  }
  if (status == -1 || claimId.isNotEmpty) {
    // Sin conexión, o ya tiene usuario en Dovia (`custom:id`) y el perfil
    // falló por otra cosa: no es un alta.
    await _abort(router, config);
    snack(apiErrorMessage(profile,
        'No pudimos cargar tu cuenta. Intenta de nuevo en unos minutos.'));
    return;
  }

  // Sin `custom:id` y sin perfil: lo más probable es que no tenga cuenta en
  // Dovia. Desde el login se pregunta antes de crearla.
  if (intent == GoogleAuthIntent.signIn) {
    final create = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('No encontramos tu cuenta'),
        content: Text(
          email.isEmpty
              ? 'No hay una cuenta de DOVIA con este Google. ¿Quieres crear una?'
              : 'No hay una cuenta de DOVIA con $email. ¿Quieres crear una?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Crear cuenta'),
          ),
        ],
      ),
    );
    if (create != true) {
      await _abort(router, config);
      return;
    }
  }
  await RegistrationProgress.set(RegistrationProgress.googleData);
  router.goNamed(GoogleDatosWidget.routeName);
}

/// Cierra la sesión local recién abierta (y la de Cognito en el navegador).
Future<void> _abort(GoRouter router, CognitoGoogleConfig config) async {
  router.prepareAuthEvent();
  await RegistrationProgress.clear();
  await authManager.signOut();
  unawaited(googleOAuthClient.logout(config));
}

/// Da de alta en Dovia a quien entró con Google
/// (`POST /auth/federated/complete-registration`) y renueva los tokens en
/// Cognito para recibir el `custom:id`. Devuelve el mensaje de error, o null
/// si salió bien.
Future<String?> completeGoogleRegistration({
  required String name,
  required String lastname,
  required String day,
  required String month,
  required String year,
  required String gender,
  required String phoneCountryCode,
  required String phoneNumber,
  String? nationality,
}) async {
  final call = DOVIAAPIAuthContextGroup.federatedCompleteRegistrationCall;
  final ApiCallResponse res = await call.call(
    idToken: currentAuthenticationToken ?? '',
    name: name,
    lastname: lastname,
    day: day,
    month: month,
    year: year,
    gender: gender,
    phoneCountryCode: phoneCountryCode,
    phoneNumber: phoneNumber,
    nationality: nationality,
  );
  if (!res.succeeded) {
    if (kDebugMode) {
      // Solo los claims que exige el backend, nunca el token.
      final c = jwtClaims(currentAuthenticationToken);
      print('[Google] alta federada ${res.statusCode}: ${res.bodyText}');
      print('[Google] claims: token_use=${c['token_use']} '
          'sub=${c['sub'] != null} cognito:username=${c['cognito:username'] != null} '
          'email=${c['email'] != null} email_verified=${c['email_verified']} '
          'identities=${_providers(c['identities'])}');
    }
    if (call.hasErrorCode(res, 'ACCOUNT_METHOD_CONFLICT')) {
      return accountMethodConflictMessage;
    }
    if (call.hasErrorCode(res, 'FEDERATED_IDENTITY_CONFLICT')) {
      return federatedIdentityConflictMessage;
    }
    return apiErrorMessage(
        res, 'No pudimos crear tu cuenta. Intenta de nuevo.');
  }

  // El alta no devuelve tokens: se renuevan en Cognito para que el ID token
  // traiga `custom:id` y `custom:profile_complete`.
  await refreshSession();
  // Cognito rechazó la renovación y la sesión se cerró: la cuenta quedó
  // creada, falta volver a entrar.
  if (!loggedIn) {
    return 'Tu cuenta se creó. Inicia sesión con Google para continuar.';
  }
  final id = getJsonField(res.jsonBody, r'$.data.id')?.toString() ?? '';
  if (loggedIn && (authManager.uid ?? '').isEmpty && id.isNotEmpty) {
    authManager.updateAuthUserData(
      authenticationToken: authManager.authenticationToken,
      refreshToken: authManager.refreshToken,
      tokenExpiration: authManager.tokenExpiration,
      authUid: id,
    );
  }
  return null;
}

/// `providerName/providerType` de cada identidad del token (sin ids), para
/// diagnosticar el alta.
String _providers(dynamic identities) {
  dynamic list = identities;
  if (list is String) {
    try {
      list = jsonDecode(list);
    } catch (_) {
      return 'no legible';
    }
  }
  if (list is! List) return '$list';
  return list
      .whereType<Map>()
      .map((i) => '${i['providerName']}/${i['providerType']}')
      .join(', ');
}
