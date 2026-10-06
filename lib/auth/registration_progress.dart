import 'package:shared_preferences/shared_preferences.dart';

/// Paso del registro en el que quedó la persona, para retomarlo si cierra la
/// app a mitad de camino. Se guarda en el teléfono y se lee al arrancar
/// ([load]) para que la ruta inicial pueda decidir sin esperar.
///
/// Pasos con sesión ya iniciada (después de `complete-registration`):
/// - [idAndTerms]: falta la identificación y aceptar los términos.
/// - [associateForm]: asociado que falta completar el formulario (dirección,
///   documentos y entrevista).
/// - [pendingReview]: asociado que ya envió todo y espera que DOVIA lo
///   apruebe. Al abrir la app ve la pantalla de "solicitud en revisión" (con
///   la sesión abierta) hasta que el backend lo marque activo.
class RegistrationProgress {
  static const idAndTerms = 'id_terms';
  static const associateForm = 'associate_form';
  static const pendingReview = 'pending_review';

  static const _stepKey = 'registration_step';
  static const _submittedKey = 'associate_form_submitted_';

  static String? _step;

  /// El paso pendiente se abrió al volver a la app (reinicio con la sesión
  /// guardada o inicio de sesión), no en el flujo seguido del registro. La
  /// pantalla lo consume una vez para mostrar con qué correo se estaba
  /// registrando.
  static bool resumedAfterRestart = false;

  /// Paso pendiente, o null si no hay registro a medias.
  static String? get step => _step;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _step = prefs.getString(_stepKey);
  }

  static Future<void> set(String step) async {
    _step = step;
    await (await SharedPreferences.getInstance()).setString(_stepKey, step);
  }

  static Future<void> clear() async {
    _step = null;
    await (await SharedPreferences.getInstance()).remove(_stepKey);
  }

  /// El asociado ya envió su formulario. El backend puede seguir diciendo
  /// `isAssociateProfileComplete = false` hasta que DOVIA confirme la cita, y
  /// no hay que volver a mandarlo al formulario por eso.
  static Future<void> markAssociateSubmitted(String userId) async =>
      (await SharedPreferences.getInstance())
          .setBool('$_submittedKey$userId', true);

  static Future<bool> associateSubmitted(String userId) async =>
      (await SharedPreferences.getInstance())
          .getBool('$_submittedKey$userId') ??
      false;

  /// El formulario de asociado ya se envió, según el perfil del backend
  /// (`GET /users/me`): están los documentos y la dirección que sube el
  /// formulario.
  ///
  /// `isAssociateProfileComplete` del sign-in no sirve para esto: además
  /// exige la zona de trabajo y una cita **confirmada**, así que recién
  /// enviado sigue en false. Y la marca local de [associateSubmitted] no está
  /// en otro teléfono (ni si el uid cambió): sin esto, al volver a iniciar
  /// sesión se lo mandaba otra vez al formulario.
  static bool associateFormSentInProfile(dynamic profileBody) {
    if (profileBody is! Map) return false;
    final data = profileBody['data'];
    if (data is! Map) return false;
    bool has(String key) => (data[key]?.toString().trim() ?? '').isNotEmpty;
    return has('criminalRecordUrl') &&
        has('policeRecordUrl') &&
        has('utilityBillUrl') &&
        has('address');
  }

  /// Registro a medias con el correo ya verificado
  /// (`PASSWORD_RECOVERY_REQUIRED`). El backend no deja reverificar un correo
  /// confirmado, así que se usa el código de recuperación: la pantalla del
  /// código lo guarda acá sin pedir contraseña, y el formulario de datos lo
  /// confirma junto con la contraseña que elige ahí (una sola vez).
  static String? resumeEmail;
  static String? resumeCode;

  static bool isResuming(String email) =>
      email.isNotEmpty && resumeEmail == email;

  static void clearResume() {
    resumeEmail = null;
    resumeCode = null;
  }
}
