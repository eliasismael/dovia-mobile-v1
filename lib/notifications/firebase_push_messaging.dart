import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;

import 'push_messaging.dart';

/// Proyecto de Firebase `dovia-notifications` (el mismo que usa el worker de
/// notificaciones del backend). Los valores salen de `google-services.json` y
/// `GoogleService-Info.plist`; se pasan desde Dart para no depender del plugin
/// de Gradle, que exige que cada flavor tenga su paquete registrado.
///
/// En Android cada flavor es un paquete distinto y tiene su propia app en
/// Firebase. Registrados: `com.mycompany.dovia` (flavor `dev`, que va sin
/// sufijo, o build sin flavor) y `com.mycompany.dovia.stg` (`staging`).
const _androidAppIds = <String?, String>{
  null: '1:240336837682:android:780f6a517ffbc7112df02b',
  'dev': '1:240336837682:android:780f6a517ffbc7112df02b',
  'staging': '1:240336837682:android:83b592ef903911b52df02b',
};

FirebaseOptions? _firebaseOptions() {
  if (kIsWeb) return null;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final appId = _androidAppIds[appFlavor];
      if (appId == null) return null;
      return FirebaseOptions(
        apiKey: 'AIzaSyAMAV1vt44gcRVyUPJNhCPMKIkUp61ZTaw',
        appId: appId,
        messagingSenderId: '240336837682',
        projectId: 'dovia-notifications',
        storageBucket: 'dovia-notifications.firebasestorage.app',
      );
    case TargetPlatform.iOS:
      return const FirebaseOptions(
        apiKey: 'AIzaSyBGsuuNXcPyScRKKGon2J0vQBdswbzyv2U',
        appId: '1:240336837682:ios:d9f8f9d2aaffb9642df02b',
        messagingSenderId: '240336837682',
        projectId: 'dovia-notifications',
        storageBucket: 'dovia-notifications.firebasestorage.app',
        iosBundleId: 'com.mycompany.dovia',
      );
    default:
      return null;
  }
}

/// Inicializa Firebase y devuelve el proveedor push real. Si la plataforma no
/// tiene configuración (web, escritorio) o la inicialización falla, devuelve
/// [NoopPushMessaging]: la app sigue funcionando sin push.
Future<PushMessaging> initPushMessaging() async {
  final options = _firebaseOptions();
  if (options == null) return const NoopPushMessaging();
  try {
    await Firebase.initializeApp(options: options);
    return FirebasePushMessaging();
  } catch (e) {
    debugPrint('[Push] No se pudo inicializar Firebase: $e');
    return const NoopPushMessaging();
  }
}

/// [PushMessaging] sobre Firebase Cloud Messaging.
///
/// Usa el token de registro de FCM (`getToken`/`onTokenRefresh`), aunque
/// firebase_messaging 17 los marca deprecados a favor de `register()`: ese
/// devuelve el ID de instalación (FID) para "direct-send", y el backend manda
/// con `sendEachForMulticast({ tokens })`, que espera tokens de registro.
class FirebasePushMessaging implements PushMessaging {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  Future<PushPermission> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission();
      final status = settings.authorizationStatus;
      return status == AuthorizationStatus.authorized ||
              status == AuthorizationStatus.provisional
          ? PushPermission.granted
          : PushPermission.denied;
    } catch (e) {
      debugPrint('[Push] No se pudo pedir el permiso: $e');
      return PushPermission.denied;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      // ignore: deprecated_member_use
      return await _messaging.getToken();
    } catch (e) {
      // Ej: un flavor cuyo paquete no está registrado en Firebase.
      debugPrint('[Push] No se pudo obtener el token: $e');
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      // ignore: deprecated_member_use
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('[Push] No se pudo descartar el token: $e');
    }
  }

  @override
  // ignore: deprecated_member_use
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage.map(_toPushMessage);

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_toPushMessage);

  @override
  Future<PushMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toPushMessage(message);
  }

  PushMessage _toPushMessage(RemoteMessage message) => PushMessage(
        title: message.notification?.title,
        body: message.notification?.body,
        data: message.data.map((key, value) => MapEntry(key, '$value')),
      );
}
