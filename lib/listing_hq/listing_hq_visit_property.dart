import '/backend/api_requests/api_properties.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Visitas de `GET /visits/lister-hq`, con o sin la envoltura de paginación
/// (`data` como lista o como `{data, meta}`).
List<Map> listerHqVisitsFrom(dynamic jsonBody) {
  var raw = getJsonField(jsonBody, r'$.data');
  if (raw is Map && raw['data'] is List) raw = raw['data'];
  return raw is List ? raw.whereType<Map>().toList() : const [];
}

/// Id de la propiedad de una visita de la lista.
String listerHqVisitPropertyId(Map visit) {
  final info = visit['propertyInfo'] ?? visit['property'];
  return (visit['propertyId'] ?? (info is Map ? info['id'] : null))
          ?.toString() ??
      '';
}

final Map<String, Future<Map?>> _propertyCache = {};

/// La propiedad de una visita para su tarjeta. La lista la trae resumida en
/// `propertyInfo` (`property` por compatibilidad); donde el backend todavía
/// no la manda, se pide la del backoffice por su id, una vez por sesión.
Future<Map?> listerHqVisitProperty(Map visit, String token) async {
  final info = visit['propertyInfo'] ?? visit['property'];
  if (info is Map) return info;
  final propertyId = listerHqVisitPropertyId(visit);
  if (propertyId.isEmpty) return null;
  final pending = _propertyCache.putIfAbsent(
      propertyId, () => _fetchBackoffice(propertyId, token));
  final property = await pending;
  // Un fallo no se queda guardado: la próxima carga reintenta.
  if (property == null) _propertyCache.remove(propertyId);
  return property;
}

Future<Map?> _fetchBackoffice(String propertyId, String token) async {
  final res = await DOVIAAPIPropertyContextGroup.getPropertyBackofficeCall
      .call(propertyId: propertyId, authToken: token);
  if (!res.succeeded) return null;
  final raw = getJsonField(res.jsonBody, r'$.data');
  if (raw is Map && raw['data'] is Map) return raw['data'] as Map;
  return raw is Map ? raw : null;
}
