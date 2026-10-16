/// A qué pantalla lleva una notificación al tocarla.
///
/// El backend no manda pantallas sino la entidad (`actionPath`, Ej:
/// `/visits/{id}`), y la misma entidad se abre en pantallas distintas según el
/// rol y según a quién iba dirigida (el código del catálogo termina en
/// `_CLIENT`, `_OWNER`, ...). Se navega al detalle sólo cuando están todos los
/// datos que esa pantalla necesita; si no, a la bandeja del rol, que siempre
/// funciona.
///
/// Para probar (`POST /notifications/test`, que manda `NOTIFICATION_TEST` sin
/// datos): `actionPath` puede llevar el código y los datos como parámetros,
/// Ej: `/visits/<id>?type=VISIT_CONFIRMED_CLIENT&propertyId=<id>`, y así se
/// resuelve igual que la notificación real. También puede ser directamente
/// la ruta de una pantalla de la app.
library;

import '/domain/notification_models.dart';
import '/index.dart';
import 'push_messaging.dart';

/// Código del catálogo de `POST /notifications/test`.
const kTestNotificationType = 'NOTIFICATION_TEST';

class NotificationDestination {
  const NotificationDestination(this.routeName,
      [this.queryParameters = const {}])
      : location = null;

  /// Una pantalla de la app por su ruta (`/dHCLIENTHomepage`), para las
  /// notificaciones de prueba que apuntan directo a una pantalla.
  const NotificationDestination.location(String this.location)
      : routeName = '',
        queryParameters = const {};

  final String routeName;
  final Map<String, String> queryParameters;
  final String? location;

  @override
  bool operator ==(Object other) =>
      other is NotificationDestination &&
      other.routeName == routeName &&
      other.location == location &&
      _mapEquals(other.queryParameters, queryParameters);

  @override
  int get hashCode => Object.hash(routeName, location, queryParameters.length);

  @override
  String toString() => location != null
      ? 'NotificationDestination(location: $location)'
      : 'NotificationDestination($routeName, $queryParameters)';
}

bool _mapEquals(Map<String, String> a, Map<String, String> b) =>
    a.length == b.length && a.keys.every((k) => a[k] == b[k]);

/// Bandeja de notificaciones de cada rol (`FFAppState().UserRole`).
String notificationsInboxRouteFor(String role) => switch (role) {
      'SHOWING_AGENT' => SHOWINGNotificationsWidget.routeName,
      'OPERATIVE_LISTER' => OPERATIVELISTINGNotificationsWidget.routeName,
      'LISTER_HQ' => LISTINGHQNotificationsWidget.routeName,
      'LEGAL_OFFICER' => LEGALHQNotificacionesWidget.routeName,
      'LEGAL_ASSOCIATE' => LEGALASSOCIATENotificationsWidget.routeName,
      'HOME_ASSOCIATE' ||
      'HOME_ASSOCIATE_COMPANY' ||
      'HQ_ADMIN' =>
        DHASSOCIATENotificacionesWidget.routeName,
      _ => DOVIACLIENTNotificacionesWidget.routeName,
    };

/// Pantalla de detalle para la notificación, o null si no hay un mapeo seguro
/// (falta el mapeo para ese rol o falta algún dato que la pantalla necesita).
NotificationDestination? notificationDetailFor({
  required String role,
  String? type,
  String? actionPath,
  Map<String, String> data = const {},
}) {
  final target = NotificationTarget.parse(actionPath);
  if (target == null) return null;

  // Los parámetros de la ruta completan lo que la notificación no trae (los
  // datos reales mandan). En una de prueba, también el código.
  final query = _queryOf(actionPath);
  data = {...query, ...data};
  if (type == null || type == kTestNotificationType) {
    type = query['type'] ?? type;
  }
  final audience = _audienceOf(type);

  // Cliente y dueño comparten el rol CLIENT: los distingue el código.
  if (role == 'CLIENT' || role.isEmpty) {
    switch (target.resource) {
      case 'visits':
        final visitId = target.id;
        final propertyId = data['propertyId'];
        if (visitId == null || propertyId == null || propertyId.isEmpty) {
          return null;
        }
        final params = {'visitId': visitId, 'propertyId': propertyId};
        if (audience == 'CLIENT') {
          return NotificationDestination(
              DOVIACLIENTSobreMiVisitaWidget.routeName, params);
        }
        if (type == 'VISIT_REQUESTED_OWNER') {
          return NotificationDestination(
              DOVIACLIENTPropuestaDeVisitaWidget.routeName, params);
        }
        return null;
      case 'offers':
        // Los tableros cargan solos y muestran la oferta en su estado
        // actual; el detalle depende de ese estado (oferta, contraoferta,
        // cierre), que la notificación no trae.
        if (audience == 'CLIENT') {
          return NotificationDestination(DOVIACLIENTMisOfertasWidget.routeName);
        }
        if (audience == 'OWNER') {
          return NotificationDestination(
              DOVIACLIENTPropuestasRecientesWidget.routeName);
        }
        return null;
      case 'dovia-home':
        return NotificationDestination(DHCLIENTHomepageWidget.routeName);
    }
  }
  return null;
}

/// A dónde lleva tocar una notificación: su detalle si hay un mapeo seguro;
/// si no, y [actionPath] es la ruta de una pantalla de la app
/// ([isAppRoute]), esa pantalla; si no, null.
NotificationDestination? resolveNotificationTap({
  required String role,
  String? type,
  String? actionPath,
  Map<String, String> data = const {},
  bool Function(String path)? isAppRoute,
}) {
  final detail = notificationDetailFor(
    role: role,
    type: type,
    actionPath: actionPath,
    data: data,
  );
  if (detail != null) return detail;
  final path = actionPath?.trim() ?? '';
  if (path.startsWith('/') && (isAppRoute?.call(path) ?? false)) {
    return NotificationDestination.location(path);
  }
  return null;
}

/// A dónde llevar un push tocado: el detalle si se puede, si no la bandeja.
///
/// Hoy el backend no incluye el código del catálogo en los datos del push
/// (sólo `actionPath`, la entidad y los datos del catálogo), así que lo que
/// depende de a quién iba dirigida cae en la bandeja. Si algún día manda
/// `type`, se usa sin cambiar nada acá.
NotificationDestination destinationForPush({
  required String role,
  required PushMessage message,
  bool Function(String path)? isAppRoute,
}) =>
    resolveNotificationTap(
      role: role,
      type: message.data['type'],
      actionPath: message.actionPath,
      data: message.data,
      isAppRoute: isAppRoute,
    ) ??
    NotificationDestination(notificationsInboxRouteFor(role));

Map<String, String> _queryOf(String? actionPath) {
  if (actionPath == null || !actionPath.contains('?')) return const {};
  try {
    return Uri.parse(actionPath).queryParameters;
  } on FormatException {
    return const {};
  }
}

/// A quién iba dirigida según el código del catálogo: el último `CLIENT` u
/// `OWNER` (`VISIT_CONFIRMED_CLIENT` -> `CLIENT`). Los recordatorios llevan
/// el plazo al final (`CLIENT_VISIT_REMINDER_OWNER_24H` -> `OWNER`). Si no
/// hay ninguno, el último segmento.
String? _audienceOf(String? type) {
  if (type == null || !type.contains('_')) return null;
  final parts = type.split('_');
  return parts.lastWhere((p) => p == 'CLIENT' || p == 'OWNER',
      orElse: () => parts.last);
}
