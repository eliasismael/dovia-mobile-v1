/// Ubicación corta de una propiedad para las tarjetas: "Zona 15, Guatemala".
///
/// Toma la zona (`location.address.zone`, o el primer tramo de
/// `fullAddress`) y le agrega el último tramo de la dirección (país o
/// estado). Si la dirección no trae más que la zona, se completa con
/// "Guatemala", como hace la web. `null` si la propiedad no tiene ubicación.
String? propertyLocationLabel(dynamic property) {
  if (property is! Map) return null;
  final location = property['location'];
  if (location is! Map) return null;
  final address = location['address'];

  String? clean(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return (text.isEmpty || text == 'null') ? null : text;
  }

  final full = address is Map ? clean(address['fullAddress']) : clean(address);
  final parts = (full ?? '')
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  final zone = (address is Map ? clean(address['zone']) : null) ??
      (parts.isEmpty ? null : parts.first);
  if (zone == null) return null;

  final tail = parts.length > 1 ? parts.last : 'Guatemala';
  if (zone.toLowerCase().contains(tail.toLowerCase())) return zone;
  return '$zone, $tail';
}
