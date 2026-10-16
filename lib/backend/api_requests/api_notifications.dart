import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import 'api_config.dart';
import 'api_helpers.dart';

/// Start DOVIA API - Notification Context Group Code
///
/// Contrato: `docs/contexts/notification/notification.endpoints.md`.
/// Son 8 endpoints: 6 de inbox y 2 de instalaciones. Todos requieren Bearer
/// Cognito y el claim `custom:id`; ninguno pide permiso o rol adicional.

class DOVIAAPINotificationContextGroup {
  static String getBaseUrl() => kApiBaseUrl;
  static Map<String, String> headers = {};
  static ListNotificationsCall listNotificationsCall = ListNotificationsCall();
  static GetUnreadNotificationCountCall getUnreadNotificationCountCall =
      GetUnreadNotificationCountCall();
  static SendTestNotificationCall sendTestNotificationCall =
      SendTestNotificationCall();
  static MarkNotificationAsReadCall markNotificationAsReadCall =
      MarkNotificationAsReadCall();
  static ArchiveNotificationCall archiveNotificationCall =
      ArchiveNotificationCall();
  static ArchiveAllNotificationsCall archiveAllNotificationsCall =
      ArchiveAllNotificationsCall();
  static SyncNotificationDeviceCall syncNotificationDeviceCall =
      SyncNotificationDeviceCall();
  static RevokeNotificationDeviceCall revokeNotificationDeviceCall =
      RevokeNotificationDeviceCall();
}

/// `GET /notifications`
///
/// Inbox del usuario autenticado, sin archivadas, ordenado de mas nueva a mas
/// antigua. Solo acepta `page` y `limit` (max 100): cualquier otro query param
/// devuelve 400, y por eso los nulos no se envian.
class ListNotificationsCall {
  Future<ApiCallResponse> call({
    int? page,
    int? limit,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'List My Notifications',
      apiUrl: '$baseUrl/notifications',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? notifications(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;

  dynamic pagination(dynamic response) => getJsonField(
        response,
        r'''$.meta.pagination''',
      );
}

/// `GET /notifications/unread-count` -> `{ count }`.
class GetUnreadNotificationCountCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get My Unread Notification Count',
      apiUrl: '$baseUrl/notifications/unread-count',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? count(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.count''',
      ));
}

/// `POST /notifications/test` -> `202 { eventId }`.
///
/// Notificacion de prueba para el usuario del JWT (tipo `NOTIFICATION_TEST`,
/// categoria `SYSTEM`) con titulo, texto y ruta a eleccion. Queda en la bandeja
/// y se encola el push. `actionPath` tiene que ser una ruta interna que
/// empiece con una sola `/`. Requiere usuario activo y verificado. El 202
/// confirma persistencia durable del inbox y del outbox, no la entrega FCM.
class SendTestNotificationCall {
  Future<ApiCallResponse> call({
    required String title,
    required String body,
    required String actionPath,
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "title": "${escapeStringForJson(title)}",
  "body": "${escapeStringForJson(body)}",
  "actionPath": "${escapeStringForJson(actionPath)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Send Test Notification',
      apiUrl: '$baseUrl/notifications/test',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? eventId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.eventId''',
      ));
}

/// `PATCH /notifications/{notificationId}/read` -> `200 { id, readAt }`.
///
/// Idempotente: repetir la llamada devuelve el mismo `readAt`.
class MarkNotificationAsReadCall {
  Future<ApiCallResponse> call({
    String? notificationId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Mark My Notification as Read',
      apiUrl: '$baseUrl/notifications/$notificationId/read',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? readAt(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.readAt''',
      ));
}

/// `DELETE /notifications/{notificationId}` -> `204` sin body.
///
/// Archiva la notificacion (la saca del inbox). Repetirlo es idempotente.
class ArchiveNotificationCall {
  Future<ApiCallResponse> call({
    String? notificationId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Archive My Notification',
      apiUrl: '$baseUrl/notifications/$notificationId',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// `DELETE /notifications/all` -> `204` sin body.
///
/// Archiva todo el inbox creado hasta el instante de la operacion. NO es un
/// "marcar todas como leidas": ese endpoint no existe.
class ArchiveAllNotificationsCall {
  Future<ApiCallResponse> call({
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Archive All My Notifications',
      apiUrl: '$baseUrl/notifications/all',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// `PUT /notifications/devices/{installationId}` -> `200` con el device.
///
/// Registra, sincroniza, reactiva o transfiere la instalacion al usuario del
/// token. El body debe traer exactamente `pushToken` y `platform`; cualquier
/// propiedad extra (incluido `appVersion`) devuelve 400.
///
/// `409 INVALID_PUSH_TOKEN_REUSE` significa que FCM invalido ese token: el
/// cliente debe pedir uno nuevo y repetir el PUT.
class SyncNotificationDeviceCall {
  Future<ApiCallResponse> call({
    String? installationId = '',
    String? pushToken = '',
    String? platform = 'WEB',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "pushToken": "${escapeStringForJson(pushToken)}",
  "platform": "${escapeStringForJson(platform)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Synchronize My Notification Installation',
      apiUrl: '$baseUrl/notifications/devices/$installationId',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic device(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
}

/// `DELETE /notifications/devices/{installationId}` -> `204` sin body.
///
/// Revoca logicamente la instalacion. Todo UUID valido devuelve 204, exista o
/// no y sea propia o ajena. Llamarlo en logout antes de descartar el JWT.
class RevokeNotificationDeviceCall {
  Future<ApiCallResponse> call({
    String? installationId = '',
    String? authToken = '',
  }) async {
    final baseUrl = DOVIAAPINotificationContextGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Revoke My Notification Installation',
      apiUrl: '$baseUrl/notifications/devices/$installationId',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End DOVIA API - Notification Context Group Code
