/// A qué pantalla lleva una notificación al tocarla.
///
/// El backend no manda pantallas sino la entidad (`actionPath`, Ej:
/// `/visits/{id}`), y la misma entidad se abre en pantallas distintas según el
/// rol y según a quién iba dirigida (el código del catálogo termina en
/// `_CLIENT`, `_OWNER`, ...). Se navega al detalle sólo cuando están todos los
/// datos que esa pantalla necesita; si no, a la bandeja del rol, que siempre
/// funciona.
library;

import '/domain/notification_models.dart';
import '/index.dart';
import 'push_messaging.dart';

class NotificationDestination {
  const NotificationDestination(this.routeName,
      [this.queryParameters = const {}]);

  final String routeName;
  final Map<String, String> queryParameters;

  @override
  bool operator ==(Object other) =>
      other is NotificationDestination &&
      other.routeName == routeName &&
      _mapEquals(other.queryParameters, queryParameters);

  @override
  int get hashCode => Object.hash(routeName, queryParameters.length);

  @override
  String toString() => 'NotificationDestination($routeName, $queryParameters)';
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

/// A dónde llevar un push tocado: el detalle si se puede, si no la bandeja.
///
/// Hoy el backend no incluye el código del catálogo en los datos del push
/// (sólo `actionPath`, la entidad y los datos del catálogo), así que lo que
/// depende de a quién iba dirigida cae en la bandeja. Si algún día manda
/// `type`, se usa sin cambiar nada acá.
NotificationDestination destinationForPush({
  required String role,
  required PushMessage message,
}) =>
    notificationDetailFor(
      role: role,
      type: message.data['type'],
      actionPath: message.actionPath,
      data: message.data,
    ) ??
    NotificationDestination(notificationsInboxRouteFor(role));

/// Último segmento del código del catálogo (`VISIT_CONFIRMED_CLIENT` ->
/// `CLIENT`), que dice a quién iba dirigida.
String? _audienceOf(String? type) {
  if (type == null || !type.contains('_')) return null;
  return type.substring(type.lastIndexOf('_') + 1);
}
