import 'package:flutter/foundation.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

import '/app_state.dart';
import '/auth/custom_auth/auth_util.dart';

/// Chat de soporte con Intercom.
///
/// El App ID es el del espacio de DOVIA. En web alcanza con él; en Android y
/// iOS el SDK además pide la API key de cada plataforma (Intercom → Settings →
/// Messenger → Install). Las keys no están en el código: entran al compilar
/// con `--dart-define-from-file=config/dart_defines.json` (ver
/// `config/dart_defines.example.json`). Sin la key de la plataforma Intercom
/// queda apagado y [openIntercomMessenger] devuelve `false`, para que quien
/// llama muestre el panel de soporte de siempre.
const _appId = 'moz2kipy';
const _androidApiKey = String.fromEnvironment('INTERCOM_ANDROID_API_KEY');
const _iosApiKey = String.fromEnvironment('INTERCOM_IOS_API_KEY');

bool _initialized = false;

/// Uid con el que se registró el usuario en Intercom; `''` si no se registró
/// nadie y `null` si se registró como anónimo.
String? _loggedInUid = '';

bool get _hasPlatformKey {
  if (kIsWeb) return true;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => _androidApiKey.isNotEmpty,
    TargetPlatform.iOS => _iosApiKey.isNotEmpty,
    _ => false,
  };
}

/// Arranca el SDK. Si falla, la app sigue sin chat de Intercom.
Future<void> initIntercom() async {
  if (!_hasPlatformKey) return;
  try {
    await Intercom.instance.initialize(
      _appId,
      androidApiKey: _androidApiKey,
      iosApiKey: _iosApiKey,
    );
    _initialized = true;
  } catch (e) {
    debugPrint('Intercom no se pudo inicializar: $e');
  }
}

/// Registra en Intercom a quien tiene la sesión abierta (o a un anónimo) para
/// que la conversación quede a su nombre. Solo vuelve a registrar si cambió
/// el usuario: Intercom rechaza un segundo login sobre uno activo.
Future<void> _loginCurrentUser() async {
  final uid = currentUserUid.isEmpty ? null : currentUserUid;
  if (uid == _loggedInUid) return;
  if (_loggedInUid != '') await Intercom.instance.logout();
  if (uid == null) {
    await Intercom.instance.loginUnidentifiedUser();
  } else {
    await Intercom.instance.loginIdentifiedUser(userId: uid);
    final email = FFAppState().UserEmail;
    if (email.contains('@')) {
      await Intercom.instance.updateUser(email: email);
    }
  }
  _loggedInUid = uid;
}

/// Abre el Messenger de Intercom y dice si pudo.
Future<bool> openIntercomMessenger() async {
  if (!_initialized) return false;
  try {
    await _loginCurrentUser();
    await Intercom.instance.displayMessenger();
    return true;
  } catch (e) {
    debugPrint('Intercom no pudo abrir el chat: $e');
    return false;
  }
}

/// Al cerrar sesión: la próxima conversación no debe quedar a nombre de la
/// cuenta anterior.
Future<void> logoutIntercom() async {
  if (!_initialized || _loggedInUid == '') return;
  try {
    await Intercom.instance.logout();
  } catch (_) {}
  _loggedInUid = '';
}
