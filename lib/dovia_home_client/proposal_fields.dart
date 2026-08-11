/// Lectura de las propuestas que recibe el cliente.
///
/// La pantalla de cotizaciones recibidas consume **dos contratos distintos**,
/// según haya o no una solicitud fijada, y los dos están documentados:
///
///   - `GET /dovia-home/proposals` → `DoviaHomeUnifiedProposalDto`. Es el
///     listado unificado: mezcla propuestas `QUOTE` y `OUT_OF_SCOPE`, trae
///     `description`, `providerProfile` y el PDF en `documentUrl`.
///   - `GET /dovia-home/service-requests/{id}/quote-proposals` →
///     `QuoteProposalResponseDto`. Es el historial de una cotización concreta:
///     no trae `proposalType` (son todas `QUOTE`), no trae `description` ni
///     perfil del proveedor —sólo `companyId`— y el PDF viaja en `pdfUrl`.
///   - `GET /dovia-home/service-requests/{childId}/out-of-scope-proposals` →
///     `OutOfScopeProposalDto`. Son las del hijo `OUT_OF_SCOPE`: tampoco traen
///     `proposalType` ni `description`, y se reconocen por `outOfScopeRequestId`.
///
/// Por eso los accessors aceptan las dos formas. Lo que **no** hacen es adivinar
/// claves fuera de contrato: campos como `workDescription`, `estimatedTime`,
/// `scopeOfWork`, `warranty`, `finalPrice` o `premiumDiscountApplied` no existen
/// en ninguno de los dos DTOs y leerlos sólo producía celdas con "-".
///
/// Nota sobre el precio: `totalAmount` es el monto que el proveedor cotizó y el
/// que se cobra tal cual. El contrato **no** expone ningún descuento, así que la
/// pantalla no puede calcular uno por su cuenta: en `OUT_OF_SCOPE` el checkout
/// cobra exactamente este monto, y mostrar otro sería mentirle al cliente.
library;

/// Origen de la propuesta. Decide por qué ruta se acepta o se rechaza, así que
/// es el dato que **no** se puede ignorar al operar sobre ella.
const String kProposalTypeQuote = 'QUOTE';
const String kProposalTypeOutOfScope = 'OUT_OF_SCOPE';

/// Estados de una versión de propuesta. El enum es cerrado y son estos tres:
/// no existe `EXPIRED`.
const String kProposalSubmitted = 'SUBMITTED';
const String kProposalRejected = 'REJECTED';
const String kProposalAccepted = 'ACCEPTED';

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String? _str(dynamic value) =>
    (value is String && value.trim().isNotEmpty) ? value.trim() : null;

String? _firstStr(List<dynamic> candidates) {
  for (final candidate in candidates) {
    final value = _str(candidate);
    if (value != null) return value;
  }
  return null;
}

String proposalId(Map<String, dynamic> proposal) =>
    _str(proposal['id']) ?? '';

/// Tipo de propuesta.
///
/// Sólo el listado unificado trae `proposalType`. Los listados por servicio no
/// lo mandan porque cada uno devuelve una sola familia, así que se deduce del
/// contrato: `outOfScopeRequestId` existe únicamente en `OutOfScopeProposalDto`.
/// Sin ninguna de las dos señales queda `QUOTE`, que es el otro listado posible.
String proposalType(Map<String, dynamic> proposal) {
  final declared = _str(proposal['proposalType']);
  if (declared != null) return declared.toUpperCase();
  return _str(proposal['outOfScopeRequestId']) != null
      ? kProposalTypeOutOfScope
      : kProposalTypeQuote;
}

bool proposalIsOutOfScope(Map<String, dynamic> proposal) =>
    proposalType(proposal) == kProposalTypeOutOfScope;

/// Estado de la versión. Sin estado se asume `SUBMITTED`, que es como nace toda
/// propuesta y el único que deja al cliente decidir.
String proposalStatus(Map<String, dynamic> proposal) =>
    (_str(proposal['status']) ?? kProposalSubmitted).toUpperCase();

/// La propuesta sigue viva y esperando la decisión del cliente.
bool proposalIsActionable(Map<String, dynamic> proposal) =>
    proposalStatus(proposal) == kProposalSubmitted;

/// Etiqueta del estado para la UI.
String proposalStatusLabel(Map<String, dynamic> proposal) {
  switch (proposalStatus(proposal)) {
    case kProposalAccepted:
      return 'Aceptada';
    case kProposalRejected:
      return 'Rechazada';
    default:
      return 'Pendiente';
  }
}

/// Servicio sobre el que se opera la propuesta.
///
/// En `QUOTE` es el servicio cotizado; en `OUT_OF_SCOPE` es el **hijo** creado
/// al autorizar el trabajo extra. En los dos casos es el ID que va en la ruta de
/// aceptación de cotizaciones; la de fuera de alcance sólo necesita el
/// `proposalId`.
String? proposalServiceRequestId(Map<String, dynamic> proposal) =>
    _str(proposal['serviceRequestId']);

/// Raíz de la unidad de trabajo. En `QUOTE` coincide con [proposalServiceRequestId].
String? proposalRootServiceRequestId(Map<String, dynamic> proposal) =>
    _str(proposal['rootServiceRequestId']);

/// Descripción del trabajo propuesto. Sólo la trae el listado unificado; el
/// historial por servicio no la incluye.
String? proposalDescription(Map<String, dynamic> proposal) =>
    _str(proposal['description']);

/// Versión de la propuesta. Una empresa puede mandar varias tras un rechazo, y
/// el listado devuelve todas, así que el número es lo que las distingue.
int? proposalVersion(Map<String, dynamic> proposal) {
  final value = proposal['version'];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(_str(value) ?? '');
}

/// PDF de la propuesta. Es el entregable que el cliente tiene que leer antes de
/// aceptar: el listado unificado lo manda en `documentUrl` y el historial por
/// servicio en `pdfUrl`.
String? proposalDocumentUrl(Map<String, dynamic> proposal) =>
    _firstStr([proposal['documentUrl'], proposal['pdfUrl']]);

String? proposalOriginalFileName(Map<String, dynamic> proposal) =>
    _str(proposal['originalFileName']);

/// Monto cotizado, tal cual lo envió el proveedor.
num? proposalTotalAmount(Map<String, dynamic> proposal) {
  final value = proposal['totalAmount'];
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

/// Moneda del monto. El flujo es GTQ; el campo se lee igual porque el contrato
/// lo expone.
String proposalCurrency(Map<String, dynamic> proposal) =>
    (_str(proposal['currency']) ?? 'GTQ').toUpperCase();

/// Precio formateado para la tarjeta, o null si la propuesta no trae monto.
String? proposalAmountLabel(Map<String, dynamic> proposal) {
  final amount = proposalTotalAmount(proposal);
  return amount == null
      ? null
      : proposalFormatAmount(amount, proposalCurrency(proposal));
}

/// Nombre del proveedor que envió la propuesta.
///
/// Sale de `providerProfile` (`DoviaHomeOperationalProfileDto`), que puede ser
/// null cuando el usuario relacionado ya no existe. El historial por servicio no
/// trae perfil, así que ahí no hay nombre que mostrar.
String? proposalProviderName(Map<String, dynamic> proposal) =>
    _str(_asMap(proposal['providerProfile'])?['fullName']);

/// Imágenes asociadas: las del servicio en `QUOTE`, la evidencia confirmada del
/// trabajo extra en `OUT_OF_SCOPE`.
List<String> proposalImageUrls(Map<String, dynamic> proposal) {
  final raw = proposal['imageUrls'];
  if (raw is! List) return const [];
  return raw.map(_str).whereType<String>().toList();
}

/// Fecha en que el cliente decidió la propuesta (aceptó o rechazó), si el
/// contrato la trae. El sobre unificado no documenta un campo fijo para esto,
/// así que se prueban las claves plausibles; sin ninguna, la pantalla que la
/// use omite la fecha en vez de inventarla.
DateTime? proposalDecidedAt(Map<String, dynamic> proposal) {
  final raw = _firstStr([
    proposal['decidedAt'],
    proposal['respondedAt'],
    proposal['acceptedAt'],
    proposal['statusUpdatedAt'],
    proposal['updatedAt'],
  ]);
  return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}

/// [proposalDecidedAt] en el formato `dd/mm/aaaa` del banner de aprobación.
String? proposalDecidedDateLabel(Map<String, dynamic> proposal) {
  final date = proposalDecidedAt(proposal);
  if (date == null) return null;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

String proposalFormatAmount(num amount, String currency) {
  final fixed = ((amount * 100).round() / 100).toStringAsFixed(2);
  final parts = fixed.split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  final body = parts[1] == '00' ? grouped : '$grouped.${parts[1]}';
  return currency == 'GTQ' ? 'Q$body' : '$currency $body';
}
