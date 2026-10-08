import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/auth/registration_progress.dart';
import '/backend/api_requests/api_users.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Roles de asociado: tienen formulario, aprobación de DOVIA y su propio home.
const associateRoles = [
  'SHOWING_AGENT',
  'OPERATIVE_LISTER',
  'LISTER_HQ',
  'HOME_ASSOCIATE',
  // Asociado tipo Empresa: mismo contexto Dovia Home, pero su panel es el
  // pipeline de cotizaciones y no la bolsa de trabajos.
  'HOME_ASSOCIATE_COMPANY',
  'LEGAL_ASSOCIATE',
  'LEGAL_OFFICER',
  'HQ_ADMIN',
];

/// Lleva a donde corresponde después de iniciar sesión (con contraseña o con
/// Google), según el perfil de `GET /users/me`:
/// - sin rol: retoma el registro (identificación, términos y rol);
/// - asociado sin el formulario enviado: el formulario;
/// - asociado pendiente de aprobación: "solicitud en revisión";
/// - si no, el home de su rol.
///
/// [roleSelected], [associateProfileComplete] y [verified] vienen del
/// sign-in con contraseña; con Google se leen del perfil.
Future<void> navigateAfterSignIn(
  BuildContext context, {
  required dynamic profileBody,
  bool? roleSelected,
  bool? associateProfileComplete,
  bool? verified,
}) async {
  final profileCall = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall;
  final userRole = profileCall.userRole(profileBody);

  // La aprobación del asociado es `verified`: select-role lo deja en false y
  // HQ Admin lo pasa a true. `active` es otra cosa (cuenta deshabilitada): con
  // active=false el backend ni siquiera deja iniciar sesión.
  final isApproved =
      verified == true || profileCall.isVerified(profileBody) == true;

  // Registro a medias: se retoma el paso que falta en vez de entrar al home.
  if (roleSelected == false) {
    await RegistrationProgress.set(RegistrationProgress.idAndTerms);
    RegistrationProgress.resumedAfterRestart = true;
    if (!context.mounted) return;
    context.goNamed(Datos2Widget.routeName);
    return;
  }
  if (associateRoles.contains(userRole)) {
    // Ya envió el formulario si lo dice el perfil del backend (vale en
    // cualquier teléfono) o la marca local.
    final submitted =
        RegistrationProgress.associateFormSentInProfile(profileBody) ||
            await RegistrationProgress.associateSubmitted(currentUserUid);
    if (!context.mounted) return;
    if (RegistrationProgress.step == RegistrationProgress.associateForm ||
        (associateProfileComplete == false && verified != true && !submitted)) {
      FFAppState().UserRole = userRole ?? '';
      await RegistrationProgress.set(RegistrationProgress.associateForm);
      if (!context.mounted) return;
      context.goNamed(FormAssociateWidget.routeName);
      return;
    }
  }
  await RegistrationProgress.clear();
  if (!context.mounted) return;

  if (!associateRoles.contains(userRole)) {
    FFAppState().UserRole = 'CLIENT';
    context.pushNamedAuth(DOVIACLIENTHomePageWidget.routeName, context.mounted);
    return;
  }
  if (!isApproved) {
    // Pendiente de aprobación: la sesión queda abierta y se muestra
    // "solicitud en revisión". Antes se cerraba la sesión y la app volvía al
    // login cada vez.
    FFAppState().UserRole = userRole ?? FFAppState().UserRole;
    await RegistrationProgress.set(RegistrationProgress.pendingReview);
    if (!context.mounted) return;
    context.goNamed(SolicitudEnRevisionWidget.routeName);
    return;
  }
  // Aprobado: al home de su rol.
  FFAppState().UserRole = userRole ?? 'HOME_ASSOCIATE';
  final route = switch (userRole) {
    'SHOWING_AGENT' => SHOWINGHomeWidget.routeName,
    'OPERATIVE_LISTER' => OPERATIVELISTINGHomeWidget.routeName,
    'LISTER_HQ' => LISTINGHQHomeWidget.routeName,
    // Legal HQ audita y supervisa: su panel es el tablero de expedientes, no
    // la bolsa de trabajo del asociado.
    'LEGAL_OFFICER' => LEGALHQHomeWidget.routeName,
    'LEGAL_ASSOCIATE' => LegalAssociateHomeWidget.routeName,
    // La empresa no tiene bolsa de trabajos: su panel es el pipeline de
    // cotizaciones.
    'HOME_ASSOCIATE_COMPANY' => DHASSOCIATEEmpresaHomePageWidget.routeName,
    // HOME_ASSOCIATE / HQ_ADMIN
    _ => DHASSOCIATEHomePageWidget.routeName,
  };
  context.pushNamedAuth(route, context.mounted);
}
