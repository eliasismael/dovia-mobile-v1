/// Zonas donde opera DOVIA. Es la misma lista en el formulario de venta/renta
/// y en la ubicación de DOVIA Home, así ambos piden lo mismo.
const List<String> kDoviaZones = [
  'Zona 10',
  'Zona 14',
  'Zona 15',
  'Zona 16',
  'Carretera a El Salvador',
];

/// Centro aproximado de cada zona: al elegirla, el mapa se mueve alli para
/// marcar el punto exacto.
const Map<String, (double, double)> kDoviaZoneCenters = {
  'Zona 1': (14.6417, -90.5133),
  'Zona 2': (14.6560, -90.5120),
  'Zona 10': (14.6005, -90.5075),
  'Zona 14': (14.5870, -90.5130),
  'Zona 15': (14.5975, -90.4870),
  'Zona 16': (14.6150, -90.4700),
  'Carretera a El Salvador': (14.5480, -90.4450),
};

/// Parámetros de Mapbox que limitan la búsqueda a la zona elegida (una caja
/// de ~3 km alrededor del centro). Vacío si la zona no tiene centro.
String mapboxZoneFilter(String? zone) {
  final center = kDoviaZoneCenters[zone];
  if (center == null) return '';
  const d = 0.03;
  return '&proximity=${center.$2},${center.$1}'
      '&bbox=${center.$2 - d},${center.$1 - d},'
      '${center.$2 + d},${center.$1 + d}';
}

/// "5a Avenida" y "5 Avenida" son la misma calle.
String normalizeStreetName(String s) => s
    .toLowerCase()
    .replaceAllMapped(
        RegExp(r'(\d+)\s*(a|ª|era|da|ta|ma|va|na)\b'), (m) => m.group(1)!)
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// De los resultados de Mapbox, el cuya calle coincide con lo escrito: Mapbox
/// suele poner primero otra calle con el mismo número.
dynamic bestAddressMatch(List<dynamic> features, String typedAddress) {
  final typed = normalizeStreetName(typedAddress);
  return features.firstWhere(
    (f) {
      final street = normalizeStreetName((f['text'] ?? '').toString());
      return street.isNotEmpty && typed.contains(street);
    },
    orElse: () => features.first,
  );
}
