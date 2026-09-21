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

/// `processStatus` de la oferta, en el vocabulario que entienden los carriles.
///
/// El dato llega por dos caminos con dos vocabularios distintos. La oferta lo
/// trae en el suyo —`awaiting_legal_review`, `agreement_structuring`,
/// `contract_signing`, `completed`—, pero cuando el payload sólo embebe
/// `legalProcess`, ese `status` es el enum del proceso legal (`FINISHED`,
/// `REJECTED`, `BANK_EVALUATION`…). Sin traducirlo, un trato ya cerrado
/// llegaba como `finished`, que no es ninguno de los estados que los carriles
/// conocen: se quedaba para siempre en "Proceso Legal" y el cliente nunca
/// podía calificarlo.
///
/// Sólo se traducen los dos desenlaces, que son los que el backend documenta:
/// `FINISHED` completa la oferta (`processStatus=COMPLETED`) y `REJECTED` la
/// cierra. El resto son etapas abiertas y ya se leen como tales.
String offerProcessStatus(Map<String, dynamic> json) {
  final own = offerStr(json['processStatus']);
  if (own != null) return own.toLowerCase();

  final legal = (offerStr(offerAsMap(json['legalProcess'])?['status']) ?? '')
      .toLowerCase();
  switch (legal) {
    case 'finished':
      return 'completed';
    case 'rejected':
      return 'rejected';
    default:
      return legal;
  }
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

/// Motivo con el que se cerró la negociación.
///
/// `POST /offers/{id}/reject` acepta un `reason` opcional, pero el contrato
/// publicado no documenta con qué nombre vuelve al leer la oferta: se prueban
/// los alias conocidos, en la raíz y dentro del objeto de rechazo.
String? offerRejectionReason(Map<String, dynamic>? json) {
  if (json == null) return null;

  const keys = [
    'rejectionReason',
    'ownerRejectionReason',
    'rejectReason',
    'rejectedReason',
    'reason',
  ];

  for (final source in [json, offerAsMap(json['rejection'])]) {
    if (source == null) continue;
    for (final key in keys) {
      final value = offerStr(source[key]);
      if (value != null) return value;
    }
  }
  return null;
}

/// Mensaje legible de una respuesta de error de la API de ofertas.
///
/// El backend responde `{success: false, message, errors: [{source, code,
/// message, field}]}`. Mostrar ese cuerpo tal cual —como hacían los diálogos
/// de "Ofertar"— le tira al usuario un volcado de JSON con request ids y
/// paths. Acá se toma el primer mensaje de `errors` (o el de la raíz) y se le
/// quita el nombre del DTO que el backend pone por delante
/// ("Invalid SaleOfferData: ..."), que al usuario no le dice nada.
String offerApiErrorMessage(
  dynamic body, {
  String fallback = 'No pudimos enviar tu oferta. Inténtalo de nuevo.',
}) {
  final json = offerAsMap(body);
  if (json == null) return fallback;

  String? message;
  final errors = json['errors'];
  if (errors is List) {
    for (final error in errors) {
      message = offerStr(offerAsMap(error)?['message']);
      if (message != null) break;
    }
  }
  message ??= offerStr(json['message']);
  if (message == null) return fallback;

  final cleaned = message.replaceFirst(RegExp(r'^Invalid \w+:\s*'), '').trim();
  return cleaned.isEmpty ? fallback : cleaned;
}

/// Lee un valor anidado de la propiedad probando varias rutas con puntos.
///
/// El backend no publica un nombre único para varios campos del listado
/// (`allowedUses` vive en `rentInfo.rentalConditions` o suelto en
/// `conditions`), así que cada lector declara los alias que conoce y se queda
/// con el primero que traiga dato.
dynamic propertyPathValue(Map<String, dynamic>? property, List<String> paths) {
  if (property == null) return null;
  for (final path in paths) {
    dynamic current = property;
    for (final segment in path.split('.')) {
      final map = offerAsMap(current);
      current = map?[segment];
      if (current == null) break;
    }
    if (current != null) return current;
  }
  return null;
}
