/// Lectura de la solicitud de materiales extra que viaja dentro del detalle del
/// servicio (`GET /dovia-home/service-requests/{id}`).
///
/// Los nombres vienen del contrato real (`DoviaHomeExtraMaterialsRequestResponseDto`),
/// que no es el que asumían las pantallas:
///   - El estado se llama `status` y su enum es
///     `QUOTE_PENDING | QUOTE_SENT | PAYMENT_PENDING | PAID | REJECTED`.
///     **No existen** `PENDING`, `REQUESTED`, `CLIENT_APPROVAL_PENDING`,
///     `QUOTED`, `AWAITING_CLIENT`, `ACCEPTED` ni `APPROVED`.
///   - El monto y el PDF viven **anidados en `quote`**, no en la raíz, y `quote`
///     es null hasta que DOVIA cotiza. No hay `currency`: todo es GTQ.
///   - Las fotos que subió el asociado están en `installationImageUrls`, un
///     arreglo plano de strings. **No existe** `images` ni items con la URL
///     anidada.
///   - El detalle del servicio expone la solicitud vigente en
///     `latestExtraMaterialsRequest` (+ `latestExtraMaterialsRequestId` y
///     `hasPendingExtraMaterialsRequests`), así que no hay que adivinar claves ni
///     tomar el último elemento del historial.
library;

/// Estados de `DoviaHomeExtraMaterialsRequestResponseDto.status`.
///
/// El enum es cerrado y son estos cinco. El único en que el cliente decide es
/// [kExtraMaterialsQuoteSent]: antes no hay cotización que aceptar y después ya
/// decidió.
const String kExtraMaterialsQuotePending = 'QUOTE_PENDING';
const String kExtraMaterialsQuoteSent = 'QUOTE_SENT';
const String kExtraMaterialsPaymentPending = 'PAYMENT_PENDING';
const String kExtraMaterialsPaid = 'PAID';
const String kExtraMaterialsRejected = 'REJECTED';

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String? _str(dynamic value) =>
    (value is String && value.trim().isNotEmpty) ? value.trim() : null;

/// Solicitud de materiales vigente dentro del detalle del servicio.
///
/// Se lee de `latestExtraMaterialsRequest`, que es la que el contrato declara
/// vigente. `extraMaterialsRequests` queda como respaldo para las respuestas que
/// sólo traen el historial: ahí la vigente es la última, que es el mismo criterio
/// con el que el backend calcula `latestExtraMaterialsRequestId`.
Map<String, dynamic>? emLatestRequest(Map<String, dynamic>? service) {
  if (service == null) return null;

  final latest = _asMap(service['latestExtraMaterialsRequest']);
  if (latest != null) return latest;

  final history = service['extraMaterialsRequests'];
  if (history is List && history.isNotEmpty) {
    final last = _asMap(history.last);
    if (last != null) return last;
  }

  // El Map recibido ya es la solicitud en sí (Ej: la inyectó una notificación).
  return service.containsKey('requestedMaterials') ? service : null;
}

/// Si el servicio tiene una solicitud de materiales esperando al cliente. Es la
/// señal del propio contrato, más barata y más confiable que deducirla del
/// estado de la última solicitud.
bool emHasPendingRequest(Map<String, dynamic>? service) =>
    service?['hasPendingExtraMaterialsRequests'] == true;

String? emId(Map<String, dynamic>? materials) =>
    materials == null ? null : _str(materials['id']);

/// Estado de la solicitud. Sin estado legible se asume [kExtraMaterialsQuotePending]:
/// es el estado inicial y el que menos supone: no habilita decidir ni da por
/// cerrada una solicitud viva.
String emStatus(Map<String, dynamic>? materials) =>
    (_str(materials?['status']) ?? kExtraMaterialsQuotePending).toUpperCase();

/// Esperando que DOVIA cotice. El cliente todavía no tiene nada que decidir.
bool emIsAwaitingQuote(Map<String, dynamic>? materials) =>
    emStatus(materials) == kExtraMaterialsQuotePending;

/// **El único estado en que se ofrecen Aceptar/Rechazar.** La cotización está
/// completa (PDF, detalle y monto) y la decisión es del cliente.
bool emIsDecidable(Map<String, dynamic>? materials) =>
    emStatus(materials) == kExtraMaterialsQuoteSent;

/// El cliente ya aceptó y hay una orden de pago sin completar. No se vuelve a
/// llamar `accept`: se reanuda el checkout existente.
bool emIsAwaitingPayment(Map<String, dynamic>? materials) =>
    emStatus(materials) == kExtraMaterialsPaymentPending;

bool emIsPaid(Map<String, dynamic>? materials) =>
    emStatus(materials) == kExtraMaterialsPaid;

bool emIsRejected(Map<String, dynamic>? materials) =>
    emStatus(materials) == kExtraMaterialsRejected;

/// Estados terminales: no queda ninguna acción por delante.
bool emIsSettled(Map<String, dynamic>? materials) =>
    emIsPaid(materials) || emIsRejected(materials);

/// Texto del material que pidió el asociado. Es obligatorio en el contrato.
String? emRequestedMaterials(Map<String, dynamic>? materials) =>
    materials == null ? null : _str(materials['requestedMaterials']);

/// Fotos de la instalación que subió el asociado. Vacío mientras no confirme
/// ninguna: las imágenes son opcionales.
List<String> emInstallationImageUrls(Map<String, dynamic>? materials) {
  final raw = materials?['installationImageUrls'];
  if (raw is! List) return const [];
  return raw.map(_str).whereType<String>().toList();
}

/// Cotización de DOVIA. Null hasta que HQ la carga: es lo que separa
/// [kExtraMaterialsQuotePending] de [kExtraMaterialsQuoteSent].
Map<String, dynamic>? emQuote(Map<String, dynamic>? materials) =>
    _asMap(materials?['quote']);

/// PDF de la cotización. Es el entregable que el cliente tiene que leer antes de
/// aceptar el cobro.
String? emQuoteDocumentUrl(Map<String, dynamic>? materials) =>
    _str(emQuote(materials)?['documentUrl']);

/// Desglose que escribió HQ junto al PDF.
String? emQuoteDetails(Map<String, dynamic>? materials) =>
    _str(emQuote(materials)?['details']);

num? emQuoteTotalAmount(Map<String, dynamic>? materials) {
  final amount = emQuote(materials)?['totalAmount'];
  if (amount is num) return amount;
  if (amount is String) return num.tryParse(amount.trim());
  return null;
}

/// Monto de la cotización con su símbolo. Null mientras no haya cotización, para
/// que la pantalla distinga "todavía no cotizado" de "cotizado en Q0".
String? emQuoteAmountLabel(Map<String, dynamic>? materials) {
  final amount = emQuoteTotalAmount(materials);
  return amount == null ? null : emFormatAmount(amount);
}

/// Orden de pago creada al aceptar. Es la que se reanuda con
/// `POST /payments/{paymentOrderId}/resume` si el checkout se cae.
String? emPaymentOrderId(Map<String, dynamic>? materials) =>
    _str(materials?['paymentOrderId']);

String? emRejectionReason(Map<String, dynamic>? materials) =>
    _str(materials?['rejectionReason']);

/// Formato de moneda del flujo. Los materiales extra se cotizan siempre en GTQ
/// (el DTO no tiene `currency`), así que el símbolo no se negocia.
String emFormatAmount(num amount) {
  final fixed = ((amount * 100).round() / 100).toStringAsFixed(2);
  final parts = fixed.split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return 'Q${parts[1] == '00' ? grouped : '$grouped.${parts[1]}'}';
}
