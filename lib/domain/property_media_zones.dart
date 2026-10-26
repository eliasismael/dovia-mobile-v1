// Zonas de fotos de una propiedad (`property.images` es `{ zona: [urls] }`).
//
// Las claves son las de la web (`property-media-zones.ts`): la app sube con
// esas y lee también las viejas que ya hay guardadas (`habitacion`, `otras`,
// `recorrido360`...), así que las dos caen en la misma sección.

/// Sección de la pantalla → zona que se manda a `/images/presign`.
const _zoneBySection = {
  'Foto principal': 'principal',
  'Habitaciones': 'habitaciones',
  'Sala': 'sala',
  'Comedor': 'comedor',
  'Cocina': 'cocina',
  'Otras zonas': 'otras-zonas',
  'Plano': 'plano',
  'Recorrido 360': 'recorrido-360',
};

/// Zona guardada (en minúsculas, nuevas y viejas) → sección.
const _sectionByZone = {
  'principal': 'Foto principal',
  'habitaciones': 'Habitaciones',
  'habitacion': 'Habitaciones',
  'sala': 'Sala',
  'comedor': 'Comedor',
  'cocina': 'Cocina',
  'otras-zonas': 'Otras zonas',
  'otras': 'Otras zonas',
  'otraszonas': 'Otras zonas',
  'otras_zonas': 'Otras zonas',
  'plano': 'Plano',
  'planos': 'Plano',
  'recorrido-360': 'Recorrido 360',
  'recorrido360': 'Recorrido 360',
  'video360': 'Recorrido 360',
  'frenteedificio': 'Fachada',
  'living-room': 'Sala de estar',
};

/// Zona para subir las fotos de [section]. Las secciones que agrega el
/// usuario van como slug (`^[a-z0-9][a-z0-9-_]{0,39}$`, lo que pide el backend).
String propertyZoneForSection(String section) =>
    _zoneBySection[section] ?? _slugify(section);

/// Sección a mostrar para una [zone] guardada. Las desconocidas (agregadas por
/// el usuario) se muestran con el slug legible: `bano-visitas` → "Bano visitas".
String propertySectionForZone(String zone) {
  final known = _sectionByZone[zone.trim().toLowerCase()];
  if (known != null) return known;
  final words = zone.trim().replaceAll(RegExp(r'[-_]+'), ' ').trim();
  if (words.isEmpty) return words;
  return words[0].toUpperCase() + words.substring(1);
}

String _slugify(String input) {
  var s = input.toLowerCase().trim();
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  for (int i = 0; i < from.length; i++) {
    s = s.replaceAll(from[i], to[i]);
  }
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  s = s.replaceAll(RegExp(r'^-+|-+$'), '');
  if (s.isEmpty) s = 'zona';
  if (s.length > 40) s = s.substring(0, 40);
  return s;
}
