import 'package:shared_preferences/shared_preferences.dart';

import '/flutter_flow/uploaded_file.dart';

/// Rol de asociado elegido antes de crear la cuenta ("Regístrate como
/// asociado" en el sign in). Queda guardado en el teléfono mientras la persona
/// completa el registro normal y se envía al final, junto con la
/// identificación y los términos.
class PendingAssociateRole {
  static const _key = 'pending_associate_role';

  static Future<void> set(String role) async =>
      (await SharedPreferences.getInstance()).setString(_key, role);

  static Future<String?> get() async {
    final role = (await SharedPreferences.getInstance()).getString(_key);
    return (role == null || role.isEmpty) ? null : role;
  }

  static Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove(_key);
}

/// Foto de identificación que se subió al aceptar los términos. El formulario
/// de asociado la muestra ya cargada y no la vuelve a subir.
class RegistrationIdDocument {
  static FFUploadedFile? uploaded;
}
