import 'package:flutter/foundation.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_helpers.dart' show ApiCallResponse;
import '/backend/api_requests/api_notifications.dart';
import '/core/notification_installation.dart';
import '/core/result.dart';
import '/domain/favorite_models.dart' show PaginationMeta;
import '/domain/notification_models.dart';

/// Single Source of Truth del inbox de notificaciones y de la instalacion PUSH.
///
/// Envuelve `DOVIAAPINotificationContextGroup` y expone metodos basados en
/// [Result]. Mantiene en memoria la pagina cargada del inbox y el contador de
/// no leidas, para que el badge del header y la pantalla no se pisen.
///
/// Uso:
/// ```dart
/// // Al abrir la pantalla de notificaciones
/// context.read<NotificationsRepository>().loadInbox();
///
/// // Badge
/// final unread = context.watch<NotificationsRepository>().unreadCount;
///
/// // Al tocar una notificacion
/// await repo.markAsRead(n.id);
/// ```
///
/// El inbox solo contiene notificaciones con politica `INBOX_AND_PUSH` o
/// `INBOX_ONLY`. Las `PUSH_ONLY` del catalogo nunca aparecen aca: llegan solo
/// como push al dispositivo.
class NotificationsRepository extends ChangeNotifier {
  /// Tamano de pagina por defecto. El backend acepta hasta 100.
  static const int defaultPageSize = 20;

  /// Codigo que devuelve el backend cuando FCM ya invalido ese `pushToken`.
  /// El cliente debe pedir un token nuevo y repetir el registro.
  static const String invalidPushTokenReuseCode = 'INVALID_PUSH_TOKEN_REUSE';

  // ── Estado cacheado ───────────────────────────────────────────────────────

  List<AppNotification> _items = [];
  PaginationMeta? _meta;
  int _unreadCount = 0;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _sessionGeneration = 0;
  int _inboxRequest = 0;
  int _countRequest = 0;
  int _stateRevision = 0;
  bool _needsReload = false;

  // ── Estado publico ────────────────────────────────────────────────────────

  List<AppNotification> get items => List.unmodifiable(_items);
  PaginationMeta? get meta => _meta;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;

  /// Si quedan paginas o una recarga pendiente que [loadMore] deba reintentar.
  bool get hasMore => _needsReload || (_meta?.hasNextPage ?? false);

  String get _token => currentAuthenticationToken ?? '';

  ({int generation, String? userId, String token}) _session() => (
        generation: _sessionGeneration,
        userId: authManager.uid,
        token: _token,
      );

  bool _isCurrentSession(
    ({int generation, String? userId, String token}) session,
  ) =>
      session.generation == _sessionGeneration &&
      session.userId == authManager.uid &&
      _token.isNotEmpty;

  // Una respuesta anterior no puede sobrescribir un refresh o una mutacion.
  void _invalidateReads() {
    _inboxRequest++;
    _countRequest++;
    _isLoading = false;
    _isLoadingMore = false;
  }

  // ── Inbox ─────────────────────────────────────────────────────────────────

  /// Carga la primera pagina del inbox (`GET /notifications`).
  ///
  /// Reemplaza lo que haya en memoria. Tambien refresca el contador de no
  /// leidas, porque una entrada puede existir en el inbox antes de que el push
  /// llegue al dispositivo.
  Future<Result<List<AppNotification>>> loadInbox({
    int limit = defaultPageSize,
  }) async {
    if (_token.isEmpty) return const Failure('No autenticado');

    final session = _session();
    final request = ++_inboxRequest;
    _isLoadingMore = false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final response =
        await DOVIAAPINotificationContextGroup.listNotificationsCall.call(
      page: 1,
      limit: limit,
      authToken: session.token,
    );

    if (!_isCurrentSession(session) || request != _inboxRequest) {
      return const Failure('Carga descartada por un cambio de estado');
    }
    _isLoading = false;

    if (!response.succeeded) {
      _error =
          _messageFrom(response, 'No se pudieron cargar las notificaciones');
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    _items =
        _listFrom(response.jsonBody).map(AppNotification.fromJson).toList();
    _meta = _paginationFrom(response.jsonBody);
    _needsReload = false;
    _stateRevision++;
    notifyListeners();

    // Best effort: el inbox ya es utilizable aunque falle el contador.
    await refreshUnreadCount();

    if (!_isCurrentSession(session)) {
      return const Failure('La sesion cambio');
    }
    return Success(items);
  }

  /// Trae la pagina siguiente y la agrega al final de la lista.
  ///
  /// No hace nada si ya se esta cargando o si no hay mas paginas.
  Future<Result<List<AppNotification>>> loadMore() async {
    if (_isLoading || _isLoadingMore) return Success(items);
    if (!hasMore) return Success(items);
    if (_token.isEmpty) return const Failure('No autenticado');

    // DELETE desplaza los offsets del backend. Si fallo la recarga posterior,
    // no se puede seguir usando el numero de pagina anterior.
    if (_needsReload) return loadInbox(limit: _meta?.limit ?? defaultPageSize);

    final meta = _meta!;
    final session = _session();
    final request = ++_inboxRequest;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    final response =
        await DOVIAAPINotificationContextGroup.listNotificationsCall.call(
      page: meta.page + 1,
      limit: meta.limit,
      authToken: session.token,
    );

    if (!_isCurrentSession(session) || request != _inboxRequest) {
      return const Failure('Carga descartada por un cambio de estado');
    }
    _isLoadingMore = false;

    if (!response.succeeded) {
      _error =
          _messageFrom(response, 'No se pudieron cargar mas notificaciones');
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    final page =
        _listFrom(response.jsonBody).map(AppNotification.fromJson).toList();

    // El orden es estable (createdAt DESC, _id DESC), pero una notificacion
    // nueva entre dos pedidos puede correr la ventana y repetir un id.
    final known = _items.map((n) => n.id).toSet();
    _items = [..._items, ...page.where((n) => !known.contains(n.id))];
    _meta = _paginationFrom(response.jsonBody) ?? _meta;
    _stateRevision++;
    notifyListeners();

    return Success(items);
  }

  /// Refresca el contador de no leidas (`GET /notifications/unread-count`).
  Future<Result<int>> refreshUnreadCount() async {
    if (_token.isEmpty) return const Failure('No autenticado');

    final session = _session();
    final request = ++_countRequest;

    final response = await DOVIAAPINotificationContextGroup
        .getUnreadNotificationCountCall
        .call(authToken: session.token);

    if (!_isCurrentSession(session) || request != _countRequest) {
      return const Failure('Contador descartado por un cambio de estado');
    }

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo obtener el contador'),
        statusCode: response.statusCode,
      );
    }

    final body = response.jsonBody;
    final count =
        body is Map ? (body['data']?['count'] as num?)?.toInt() : null;
    if (count == null) {
      return const Failure('Respuesta inesperada del servidor');
    }

    // Una lectura autoritativa tambien invalida snapshots de rollback cuando
    // coincide por casualidad con el valor optimista que ya se muestra.
    _stateRevision++;
    if (count != _unreadCount) {
      _unreadCount = count;
      notifyListeners();
    }
    return Success(count);
  }

  /// Marca una notificacion como leida
  /// (`PATCH /notifications/{id}/read`). Optimista, con rollback si falla.
  ///
  /// La operacion es idempotente en el backend: repetirla devuelve el mismo
  /// `readAt`.
  Future<Result<void>> markAsRead(String notificationId) async {
    if (_token.isEmpty) return const Failure('No autenticado');
    final index = _items.indexWhere((n) => n.id == notificationId);
    final previous = index >= 0 ? _items[index] : null;

    if (previous != null && previous.isRead) return const Success(null);
    return _mutateInbox(
      request: (token) => DOVIAAPINotificationContextGroup
          .markNotificationAsReadCall
          .call(notificationId: notificationId, authToken: token),
      optimisticUpdate: () {
        if (previous != null) {
          _items[index] = previous.copyWith(readAt: DateTime.now());
          _decrementUnread();
        }
      },
      applyResponse: (response) {
        final readAt = _readAtFrom(response.jsonBody);
        final current = _items.indexWhere((n) => n.id == notificationId);
        if (readAt != null && current >= 0) {
          _items[current] = _items[current].copyWith(readAt: readAt);
        }
      },
      errorMessage: 'No se pudo marcar como leida',
    );
  }

  /// Archiva una notificacion (`DELETE /notifications/{id}`): la saca del inbox.
  ///
  /// Un `404` se trata como exito: la notificacion ya no esta en el inbox del
  /// usuario, que es justo el estado buscado.
  Future<Result<void>> archive(String notificationId) async {
    final index = _items.indexWhere((n) => n.id == notificationId);
    final previous = index >= 0 ? _items[index] : null;
    return _mutateInbox(
      request: (token) => DOVIAAPINotificationContextGroup
          .archiveNotificationCall
          .call(notificationId: notificationId, authToken: token),
      optimisticUpdate: () {
        if (previous != null) {
          _items.removeAt(index);
          if (previous.isUnread) _decrementUnread();
        }
      },
      applyResponse: (_) => _items.removeWhere((n) => n.id == notificationId),
      changesPagination: true,
      missingIsSuccess: true,
      errorMessage: 'No se pudo archivar la notificacion',
    );
  }

  /// Archiva todo el inbox (`DELETE /notifications/all`).
  ///
  /// Ojo: NO es "marcar todas como leidas". Ese endpoint no existe; esto vacia
  /// el inbox del usuario hasta el instante de la operacion.
  Future<Result<void>> archiveAll() async {
    return _mutateInbox(
      request: (token) => DOVIAAPINotificationContextGroup
          .archiveAllNotificationsCall
          .call(authToken: token),
      optimisticUpdate: () {
        _items = [];
        _unreadCount = 0;
        _meta = null;
      },
      changesPagination: true,
      errorMessage: 'No se pudo vaciar el inbox',
    );
  }

  Future<Result<void>> _mutateInbox({
    required Future<ApiCallResponse> Function(String token) request,
    required VoidCallback optimisticUpdate,
    required String errorMessage,
    void Function(ApiCallResponse)? applyResponse,
    bool changesPagination = false,
    bool missingIsSuccess = false,
  }) async {
    final session = _session();
    if (session.token.isEmpty) return const Failure('No autenticado');

    final previousItems = List<AppNotification>.of(_items);
    final previousUnread = _unreadCount;
    final previousMeta = _meta;
    final previousNeedsReload = _needsReload;
    _invalidateReads();
    optimisticUpdate();
    final revision = ++_stateRevision;
    notifyListeners();

    final response = await request(session.token);
    if (!_isCurrentSession(session)) {
      return const Failure('La sesion cambio');
    }

    final succeeded =
        response.succeeded || (missingIsSuccess && response.statusCode == 404);
    final canRollback = revision == _stateRevision;
    _invalidateReads();
    if (!succeeded && canRollback) {
      _items = previousItems;
      _unreadCount = previousUnread;
      _meta = previousMeta;
      _needsReload = previousNeedsReload;
      _stateRevision++;
      notifyListeners();
    } else if (succeeded && !changesPagination) {
      applyResponse?.call(response);
      _stateRevision++;
      notifyListeners();
      await refreshUnreadCount();
    } else {
      if (succeeded) applyResponse?.call(response);
      // Un DELETE cambia los offsets. Reiniciar desde pagina 1 tambien evita
      // que un refresh pendiente vuelva a insertar la entrada archivada.
      // Si hubo otro cambio, el servidor resuelve el estado: nunca restaurar
      // una foto vieja por encima del refresh o de otra mutacion.
      _needsReload = true;
      _stateRevision++;
      await loadInbox(limit: previousMeta?.limit ?? defaultPageSize);
    }

    if (!_isCurrentSession(session)) {
      return const Failure('La sesion cambio');
    }
    if (!succeeded) {
      return Failure(_messageFrom(response, errorMessage),
          statusCode: response.statusCode);
    }
    return const Success(null);
  }

  /// Pide una notificacion de prueba (`POST /notifications/test`) con titulo,
  /// texto y ruta a eleccion, y devuelve el `eventId` aceptado.
  ///
  /// El `202` confirma que el inbox y el outbox quedaron persistidos, no que
  /// FCM haya entregado el push. Requiere usuario activo y verificado: una
  /// cuenta inactiva o sin verificar devuelve `403`; una ruta que no sea
  /// interna (`/...`), `400`.
  Future<Result<String>> sendTestNotification({
    required String title,
    required String body,
    required String actionPath,
  }) async {
    if (_token.isEmpty) return const Failure('No autenticado');

    final response = await DOVIAAPINotificationContextGroup
        .sendTestNotificationCall
        .call(
      title: title,
      body: body,
      actionPath: actionPath,
      authToken: _token,
    );

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo enviar la notificacion de prueba'),
        statusCode: response.statusCode,
      );
    }

    final json = response.jsonBody;
    final eventId = json is Map ? (json['data']?['eventId'] as String?) : null;
    return Success(eventId ?? '');
  }

  // ── Instalacion / PUSH ────────────────────────────────────────────────────

  /// Registra o sincroniza la instalacion con su token FCM
  /// (`PUT /notifications/devices/{installationId}`).
  ///
  /// Llamar en cada login, en cada arranque con sesion activa y en cada
  /// rotacion del token FCM. El ultimo PUT exitoso define al propietario de la
  /// instalacion, asi que tambien resuelve el cambio de cuenta en el mismo
  /// dispositivo.
  ///
  /// Un `409` ([invalidPushTokenReuseCode]) significa que FCM invalido ese
  /// token exacto: hay que pedir uno nuevo al SDK de Firebase y reintentar.
  ///
  /// ```dart
  /// final result = await repo.syncDevice(pushToken: token);
  /// if (result case Failure(:final statusCode) when statusCode == 409) {
  ///   // pedir token FCM nuevo y volver a llamar
  /// }
  /// ```
  Future<Result<NotificationDevice>> syncDevice({
    required String pushToken,
    NotificationPlatform? platform,
  }) async {
    if (_token.isEmpty) return const Failure('No autenticado');
    if (pushToken.trim().isEmpty) {
      return const Failure('Sin token de notificaciones');
    }

    final installationId = await NotificationInstallation.id();

    final response =
        await DOVIAAPINotificationContextGroup.syncNotificationDeviceCall.call(
      installationId: installationId,
      pushToken: pushToken.trim(),
      platform: (platform ?? NotificationPlatform.current).wireValue,
      authToken: _token,
    );

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo registrar el dispositivo'),
        statusCode: response.statusCode,
      );
    }

    final body = response.jsonBody;
    final data = body is Map ? (body['data'] as Map<String, dynamic>?) : null;
    if (data == null) return const Failure('Respuesta inesperada del servidor');

    return Success(NotificationDevice.fromJson(data));
  }

  /// Revoca la instalacion (`DELETE /notifications/devices/{installationId}`).
  ///
  /// Ejecutar en logout ANTES de descartar el JWT, y tratarlo como best effort:
  /// si falla, el proximo PUT exitoso de otro usuario reemplaza al propietario.
  /// Todo UUID valido devuelve `204`, exista la instalacion o no.
  Future<Result<void>> revokeDevice() async {
    if (_token.isEmpty) return const Failure('No autenticado');

    final installationId = await NotificationInstallation.id();

    final response = await DOVIAAPINotificationContextGroup
        .revokeNotificationDeviceCall
        .call(installationId: installationId, authToken: _token);

    if (!response.succeeded) {
      return Failure(
        _messageFrom(response, 'No se pudo revocar el dispositivo'),
        statusCode: response.statusCode,
      );
    }
    return const Success(null);
  }

  // ── Limpieza ──────────────────────────────────────────────────────────────

  /// Limpia el estado cacheado (llamar al cerrar sesion).
  ///
  /// Sin nada que limpiar no notifica: se invoca desde el stream de auth, que
  /// puede emitir en medio de un build.
  void clear() {
    _sessionGeneration++;
    final isEmpty = _items.isEmpty &&
        _meta == null &&
        _unreadCount == 0 &&
        _error == null &&
        !_isLoading &&
        !_isLoadingMore &&
        !_needsReload;

    _invalidateReads();

    _items = [];
    _meta = null;
    _unreadCount = 0;
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
    _needsReload = false;
    _stateRevision++;
    if (!isEmpty) notifyListeners();
  }

  @override
  void dispose() {
    _sessionGeneration++;
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _decrementUnread() {
    if (_unreadCount > 0) _unreadCount -= 1;
  }

  Iterable<Map<String, dynamic>> _listFrom(dynamic body) {
    final list = body is List
        ? body
        : (body is Map ? body['data'] as List? : null) ?? const [];
    return list.whereType<Map<String, dynamic>>();
  }

  PaginationMeta? _paginationFrom(dynamic body) {
    if (body is! Map) return null;
    final pagination = body['meta']?['pagination'];
    if (pagination is! Map<String, dynamic>) return null;
    return PaginationMeta.fromJson(pagination);
  }

  DateTime? _readAtFrom(dynamic body) {
    if (body is! Map) return null;
    final raw = body['data']?['readAt'];
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  /// Extrae el mensaje del envelope `{ success, status_code, data, meta, errors }`
  /// o del formato de error de Nest, y cae al texto por defecto si no hay nada.
  String _messageFrom(ApiCallResponse response, String fallback) {
    final body = response.jsonBody;
    if (body is Map) {
      final msg = body['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();

      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is String && first.isNotEmpty) return first;
        if (first is Map) {
          final detail = first['message'] ?? first['detail'] ?? first['code'];
          if (detail is String && detail.isNotEmpty) return detail;
        }
      }
    }
    return fallback;
  }
}
