/// Lo que la app necesita del proveedor de notificaciones push (Firebase
/// Cloud Messaging).
///
/// Todo el ciclo (registro del dispositivo, rotación del token, mensajes en
/// primer plano y al tocar) se arma contra esta interfaz y no contra el SDK de
/// Firebase. Así se prueba con un proveedor falso y, mientras el proyecto no
/// tenga los archivos de Firebase, la app usa [NoopPushMessaging] y no
/// registra nada.
library;

import 'dart:async';

enum PushPermission { granted, denied }

/// Un push recibido. [data] es lo que manda el backend junto al título y el
/// cuerpo: `actionPath`, `relatedEntityType`, `relatedEntityId` y los datos
/// del catálogo (Ej: `visitId`, `propertyId`).
class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  final String? title;
  final String? body;
  final Map<String, String> data;

  String? get actionPath => data['actionPath'];
}

abstract class PushMessaging {
  /// Pide el permiso (en Android 13+ e iOS muestra el diálogo la primera vez)
  /// y devuelve el estado actual.
  Future<PushPermission> requestPermission();

  /// Token actual del dispositivo, o null si todavía no hay.
  Future<String?> getToken();

  /// Descarta el token actual para que [getToken] emita uno nuevo. Hace falta
  /// cuando el backend responde que FCM invalidó el que se le mandó.
  Future<void> deleteToken();

  /// Emite cada vez que el proveedor rota el token.
  Stream<String> get onTokenRefresh;

  /// Pushes que llegan con la app abierta (el sistema no los muestra solo).
  Stream<PushMessage> get onForegroundMessage;

  /// Pushes que el usuario tocó con la app en segundo plano.
  Stream<PushMessage> get onMessageOpenedApp;

  /// El push que abrió la app desde cerrada, si fue así.
  Future<PushMessage?> getInitialMessage();
}

/// Proveedor vacío: sin permiso y sin token, así que nunca se registra el
/// dispositivo. Es el que usa la app hasta que se configure Firebase.
class NoopPushMessaging implements PushMessaging {
  const NoopPushMessaging();

  @override
  Future<PushPermission> requestPermission() async => PushPermission.denied;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> deleteToken() async {}

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<PushMessage> get onForegroundMessage => const Stream.empty();

  @override
  Stream<PushMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<PushMessage?> getInitialMessage() async => null;
}

/// Proveedor que usa la app. Cuando se configure Firebase se reemplaza en
/// `main()` por la implementación con `firebase_messaging`.
PushMessaging pushMessaging = const NoopPushMessaging();
