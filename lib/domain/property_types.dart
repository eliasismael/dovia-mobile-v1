// Tipos de inmueble (`propertyType`). Las claves son el enum del backend
// (`property-type.enum.ts`); los valores, la etiqueta que se muestra.

import 'property_location.dart';

const kPropertyTypeLabels = {
  'APARTMENT': 'Apartamento',
  'HOUSE': 'Casa',
  'STUDIO': 'Apartamento tipo estudio',
  'PENTHOUSE': 'Penthouse',
  'FARM': 'Finca',
  'LOT': 'Lote / terreno',
};

/// Etiqueta de un `propertyType` del backend, o null si no es uno conocido.
String? propertyTypeLabel(dynamic raw) =>
    raw == null ? null : kPropertyTypeLabels[raw.toString().toUpperCase()];

/// Título corto de una propiedad, como en la miniatura: "Casa en Zona 15".
///
/// El nombre que escribe el propietario puede ser una descripción larga, así
/// que Listing HQ identifica la propiedad por tipo y zona. Si falta alguno de
/// los dos se usa lo que haya y, sin nada, [fallback].
String propertyShortTitle(Map? property, {String fallback = 'Propiedad'}) {
  final type = propertyTypeLabel(property?['propertyType']);
  final zone = propertyZone(property);
  if (type != null && zone != null) return '$type en $zone';
  return type ?? zone ?? fallback;
}

/// `propertyType` del backend para una etiqueta del desplegable.
String? propertyTypeFromLabel(String? label) {
  for (final e in kPropertyTypeLabels.entries) {
    if (e.value == label) return e.key;
  }
  return null;
}
