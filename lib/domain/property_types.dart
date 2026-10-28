// Tipos de inmueble (`propertyType`). Las claves son el enum del backend
// (`property-type.enum.ts`); los valores, la etiqueta que se muestra.

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

/// `propertyType` del backend para una etiqueta del desplegable.
String? propertyTypeFromLabel(String? label) {
  for (final e in kPropertyTypeLabels.entries) {
    if (e.value == label) return e.key;
  }
  return null;
}
