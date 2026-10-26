/// Documentos que aprueba "Aceptar y enviar a Dovia Legal" en el visor de
/// Listing HQ.
///
/// El backend aprueba de a uno (`PUT .../documents/{id}/review`) y pasa la
/// visita a "por asignar" recién cuando están todos aprobados. Como la web, el
/// botón aprueba de una vez todos los que tienen archivo y faltan aprobar.
/// Los rechazados quedan afuera: los rechazó el mismo Lister HQ y esperan que
/// el propietario los vuelva a subir. El documento abierto entra siempre.
List<String> listerHqDocIdsToApprove(List<dynamic> docs, String currentId) {
  final ids = <String>[];
  if (currentId.isNotEmpty) ids.add(currentId);
  for (final doc in docs) {
    if (doc is! Map) continue;
    final id = (doc['id'] ?? doc['documentId'])?.toString() ?? '';
    if (id.isEmpty || ids.contains(id)) continue;
    final url = (doc['fileUrl'] ?? doc['url'])?.toString() ?? '';
    final status = doc['status']?.toString().toLowerCase() ?? '';
    if (url.isEmpty || status == 'approved' || status == 'rejected') continue;
    ids.add(id);
  }
  return ids;
}

/// Checklist de la visita desde `GET /visits/{id}/details`: `documentChecklist`
/// más `documents`, sin repetir ids. Mismo armado que Archivos pendientes.
List<dynamic> listerHqVisitDocs(dynamic data) {
  if (data is! Map) return [];
  final visit = data['visit'];
  final checklist =
      (visit is Map ? visit['documentChecklist'] : null) ?? data['documentChecklist'];
  final docs = (visit is Map ? visit['documents'] : null) ?? data['documents'];

  final combined = <dynamic>[];
  if (checklist is List) combined.addAll(checklist);
  if (docs is List) {
    for (final doc in docs) {
      if (doc is! Map) continue;
      final id = (doc['id'] ?? doc['documentId'])?.toString();
      final exists = id != null &&
          id.isNotEmpty &&
          combined.any((c) =>
              c is Map && (c['id'] ?? c['documentId'])?.toString() == id);
      if (!exists) combined.add(doc);
    }
  }
  return combined;
}
