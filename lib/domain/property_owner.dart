import '/auth/custom_auth/auth_util.dart';
import 'package:flutter/foundation.dart';

import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart' show getJsonField;

/// IDs de las propiedades publicadas por el usuario logueado, según
/// `GET /properties/my-properties`. El listado general no trae el dueño, así
/// que es la forma confiable de reconocerlas.
Set<String> _ownPropertyIds = {};
String _ownIdsToken = '';

/// Carga (o recarga) las propiedades publicadas del usuario.
Future<void> loadOwnPropertyIds() async {
  // Se identifica la sesión por el token: `currentUserUid` puede venir vacío
  // con el login propio.
  final token = currentAuthenticationToken ?? '';
  debugPrint('[Propias] cargando (token: ${token.isNotEmpty})');
  if (token.isEmpty) {
    _ownPropertyIds = {};
    _ownIdsToken = '';
    return;
  }
  // Sin `status` el backend devuelve solo PUBLISHED, pero el listado
  // público también trae casas en otros estados. Se pide cada estado por
  // separado: si el backend rechaza alguno, los demás igual cuentan.
  const statuses = [
    'PUBLISHED',
    'IN_PROCESS',
    'PENDING_REVIEW',
    'APPROVED',
    'DRAFT',
    'ARCHIVED',
    'SOLD',
    'RENTED',
  ];
  final ids = <String>{};
  var anyOk = false;
  await Future.wait(statuses.map((status) async {
    for (var page = 1; page <= 10; page++) {
      final res = await DOVIAAPIPropertyContextGroup.getMyPropertiesCall.call(
        status: status,
        page: '$page',
        limit: '100',
        authToken: currentAuthenticationToken,
      );
      if (!res.succeeded) {
        debugPrint('[Propias] $status -> ${res.statusCode}: ${res.bodyText}');
        return;
      }
      anyOk = true;
      final pageIds = DOVIAAPIPropertyContextGroup.getMyPropertiesCall
              .itemId(res.jsonBody) ??
          const <String>[];
      ids.addAll(pageIds);
      final hasNext =
          getJsonField(res.jsonBody, r'$.meta.pagination.hasNextPage') == true;
      if (!hasNext || pageIds.isEmpty) return;
    }
  }));
  if (!anyOk) return;
  debugPrint('[Propias] ${ids.length} propiedades del usuario: $ids');
  _ownPropertyIds = ids;
  _ownIdsToken = token;
}

/// Si la propiedad la publicó el usuario logueado. Sirve para no mostrarle
/// sus propias casas en el Home, la búsqueda y "Ver más".
bool isOwnProperty(dynamic house) {
  if (house is! Map) return false;
  final token = currentAuthenticationToken ?? '';
  final id = house['id']?.toString();
  if (token.isNotEmpty &&
      _ownIdsToken == token &&
      id != null &&
      _ownPropertyIds.contains(id)) {
    return true;
  }
  final uid = currentUserUid;
  if (uid.isEmpty) return false;
  final owner = house['owner'];
  return [
    house['createdBy'],
    house['ownerId'],
    house['userId'],
    if (owner is Map) owner['id'],
    if (owner is String) owner,
  ].any((v) => v != null && v.toString() == uid);
}
