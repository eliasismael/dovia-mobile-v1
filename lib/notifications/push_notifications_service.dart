import 'dart:async';

import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/core/result.dart';
import '/repositories/notifications_repository.dart';
import 'push_messaging.dart';

/// El servicio de la app, para quien no tiene un `BuildContext` a mano (Ej:
/// el cierre de sesión). Lo crea `main.dart`.
PushNotificationsService? pushNotificationsService;

/// Resultado de intentar registrar el dispositivo, para logs y tests.
enum PushSyncOutcome {
  registered,
  notLoggedIn,
  permissionDenied,
  noToken,
  failed,

  /// La sesión cambió mientras se registraba: el resultado no aplica.
  stale,
}

/// Ciclo de vida de las notificaciones push, según la guía del backend
/// (`docs/contexts/notification/notification-installations.md`):
///
/// - al iniciar sesión y en cada arranque con sesión: pedir permiso, obtener
///   el token y `PUT /notifications/devices/{installationId}`;
/// - si el backend responde `409` (FCM invalidó ese token): token nuevo y
///   repetir una vez;
/// - en cada rotación del token: repetir el PUT;
/// - sin permiso: no hacer PUT, y si antes estaba registrado, DELETE;
/// - al cerrar sesión: DELETE antes de descartar el JWT (best effort).
///
/// Además, un push con la app abierta actualiza el contador y la bandeja, y
/// uno tocado se le pasa a [onOpen] para navegar.
class PushNotificationsService {
  PushNotificationsService({
    required this.messaging,
    required this.repository,
    this.onOpen,
    this.onForeground,
  });

  final PushMessaging messaging;
  final NotificationsRepository repository;

  /// El usuario tocó un push (con la app en segundo plano o cerrada).
  void Function(PushMessage message)? onOpen;

  /// Llegó un push con la app abierta: el sistema no lo muestra solo.
  void Function(PushMessage message)? onForeground;

  bool _registered = false;
  bool get isRegistered => _registered;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Se suscribe a los eventos del proveedor y atiende el push que haya
  /// abierto la app. Llamar una vez, con la app ya montada.
  Future<void> start() async {
    _subscriptions
      ..add(messaging.onTokenRefresh.listen(_onTokenRefresh))
      ..add(messaging.onForegroundMessage.listen(_onForegroundMessage))
      ..add(messaging.onMessageOpenedApp.listen(_onMessageOpened));

    final initial = await messaging.getInitialMessage();
    if (initial != null) _onMessageOpened(initial);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  Future<PushSyncOutcome>? _retrying;

  /// Reintenta el registro si todavía no quedó hecho en esta sesión (Ej: el
  /// primer intento falló por falta de conexión, o el permiso se dio después
  /// desde Ajustes). Pensado para cuando la app vuelve del fondo; si ya está
  /// registrado no hace nada, y varias llamadas seguidas comparten el intento.
  Future<PushSyncOutcome> retryIfNotRegistered() {
    if (!loggedIn) return Future.value(PushSyncOutcome.notLoggedIn);
    if (_registered) return Future.value(PushSyncOutcome.registered);
    return _retrying ??=
        syncForCurrentSession().whenComplete(() => _retrying = null);
  }

  /// Registra este dispositivo para la sesión actual.
  Future<PushSyncOutcome> syncForCurrentSession() async {
    if (!loggedIn) return PushSyncOutcome.notLoggedIn;
    final generation = authManager.sessionGeneration;

    final permission = await messaging.requestPermission();
    if (authManager.sessionGeneration != generation) {
      return PushSyncOutcome.stale;
    }
    if (permission != PushPermission.granted) {
      // Se revocó el permiso desde la última vez: que el backend deje de
      // mandarle a este dispositivo.
      if (_registered) {
        _registered = false;
        await repository.revokeDevice();
      }
      return PushSyncOutcome.permissionDenied;
    }

    final token = await messaging.getToken();
    if (token == null || token.isEmpty) return PushSyncOutcome.noToken;
    return _register(token, generation);
  }

  /// Da de baja el dispositivo. Llamar al cerrar sesión **antes** de
  /// descartar el JWT; si falla, el próximo PUT de otra cuenta lo transfiere.
  Future<void> beforeSignOut() async {
    _registered = false;
    if (!loggedIn) return;
    try {
      await repository.revokeDevice().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[Push] No se pudo dar de baja el dispositivo: $e');
    }
  }

  /// Ya sin sesión, por cualquier camino (cerrar sesión o sesión vencida):
  /// descarta el token de FCM de este dispositivo. Si la baja no se pudo
  /// hacer (sin JWT vigente o sin conexión), el backend igual deja de
  /// mandarle: FCM rechaza el token viejo y el worker desactiva el
  /// dispositivo. Al volver a entrar se registra un token nuevo.
  Future<void> afterSignOut() async {
    _registered = false;
    try {
      await messaging.deleteToken();
    } catch (e) {
      debugPrint('[Push] No se pudo descartar el token: $e');
    }
  }

  Future<PushSyncOutcome> _register(String token, int generation) async {
    var result = await repository.syncDevice(pushToken: token);

    if (result case Failure(:final statusCode) when statusCode == 409) {
      // FCM invalidó ese token exacto: se pide uno nuevo y se repite.
      await messaging.deleteToken();
      final fresh = await messaging.getToken();
      if (fresh == null || fresh.isEmpty) return PushSyncOutcome.noToken;
      result = await repository.syncDevice(pushToken: fresh);
    }

    if (authManager.sessionGeneration != generation) {
      return PushSyncOutcome.stale;
    }
    _registered = result is Success;
    if (!_registered) {
      debugPrint('[Push] No se pudo registrar el dispositivo: $result');
      return PushSyncOutcome.failed;
    }
    return PushSyncOutcome.registered;
  }

  Future<void> _onTokenRefresh(String token) async {
    if (!loggedIn || token.isEmpty) return;
    await _register(token, authManager.sessionGeneration);
  }

  Future<void> _onForegroundMessage(PushMessage message) async {
    if (!loggedIn) return;
    onForeground?.call(message);
    // La entrada ya está en el inbox antes de que llegue el push.
    await repository.refreshUnreadCount();
    if (!repository.isEmpty) await repository.loadInbox();
  }

  void _onMessageOpened(PushMessage message) {
    if (!loggedIn) return;
    unawaited(_markOpened(message));
    onOpen?.call(message);
  }

  /// Tocar el push equivale a abrirla en la bandeja: se marca como leída si
  /// el push trae su `notificationId`, y después se actualiza el contador.
  Future<void> _markOpened(PushMessage message) async {
    final id = message.data['notificationId'];
    if (id != null && id.isNotEmpty) await repository.markAsRead(id);
    await repository.refreshUnreadCount();
  }
}
