// Helpers de parseo compartidos por los dos modelos de oferta: el del
// propietario ([OwnerProposal], ofertas recibidas) y el del cliente
// ([ClientOffer], ofertas enviadas). Ambos leen el mismo serializador del
// backend, así que la lectura del JSON vive en un solo lugar.

Map<String, dynamic>? offerAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value.isEmpty ? null : value;
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return map.isEmpty ? null : map;
  }
  return null;
}

String? offerStr(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

num? offerNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

/// Foto principal de la propiedad.
///
/// El backend la expone de varias formas según el endpoint: `GET
/// /properties/{id}` devuelve `image` (una URL suelta) e `images` (un mapa
/// ambiente → lista de URLs), mientras que otros listados usan `photos`. Los
/// listados paginados no traen ninguna, y ahí la tarjeta cae en su placeholder.
String? firstPropertyPhotoUrl(Map<String, dynamic>? property) {
  if (property == null) return null;

  final single = offerStr(property['image']) ??
      offerStr(property['imageUrl']) ??
      offerStr(property['coverPhoto']);
  if (single != null) return single;

  for (final key in const ['photos', 'images']) {
    final value = property[key];
    final url = _urlFrom(value);
    if (url != null) return url;
  }
  return null;
}

/// Extrae la primera URL de una lista, de un mapa de listas (`{sala: [...],
/// cocina: [...]}`) o de un elemento suelto.
String? _urlFrom(dynamic value) {
  if (value is List) {
    for (final item in value) {
      final url = _urlFrom(item);
      if (url != null) return url;
    }
    return null;
  }
  if (value is Map) {
    for (final item in value.values) {
      final url = _urlFrom(item);
      if (url != null) return url;
    }
    return null;
  }
  return offerStr(value);
}
