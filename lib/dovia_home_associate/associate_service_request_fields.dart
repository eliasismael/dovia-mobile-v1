/// Lectura del payload del marketplace de Dovia Home Associate
/// (`GET /dovia-home/associate/service-requests` y `.../available`) para las
/// pantallas del asociado.
///
/// Comparte criterio con [service_request_fields.dart] del cliente: el servicio
/// vive en `serviceDetail` (`label` / `code`), `scheduledAt` viaja en la raíz y
/// `requestType` distingue `SERVICE` / `EMERGENCY` / `QUOTE`.
///
/// Dos reglas propias del perfil asociado:
///   - **La dirección exacta no se pinta en la bolsa de oportunidades.** Sólo se
///     muestra la zona/barrio hasta que el trabajo se acepta; ver [asrZone].
///   - **El pago que se muestra es el neto del asociado**, ya descontada la
///     comisión de DOVIA. Es un dato que calcula el backend: la UI nunca lo
///     deriva del precio que pagó el cliente; ver [asrPayoutLabel].
library;

/// Píldora de prioridad de la tarjeta de oportunidad.
const String kStandardPriorityLabel = 'ESTANDAR';
const String kUrgentPriorityLabel = 'URGENTE';

/// Texto de la zona cuando la solicitud no trae ningún dato de ubicación
/// aproximada. Es el placeholder del diseño y, a la vez, el fallback seguro:
/// ante la duda no se filtra ubicación.
const String kHiddenAddressPlaceholder = 'XXX';

const List<String> _monthsEs = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

String? asrString(dynamic value) =>
    (value is String && value.trim().isNotEmpty) ? value.trim() : null;

num? _asrNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

/// Primer valor no vacío de una lista de candidatos del payload.
String? _firstString(List<dynamic> candidates) {
  for (final c in candidates) {
    final s = asrString(c);
    if (s != null) return s;
  }
  return null;
}

num? _firstNum(List<dynamic> candidates) {
  for (final c in candidates) {
    final n = _asrNum(c);
    if (n != null) return n;
  }
  return null;
}

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String asrId(Map<String, dynamic> data) =>
    (data['id'] ?? data['serviceRequestId'])?.toString() ?? '';

String asrRequestType(Map<String, dynamic> data) =>
    (asrString(data['requestType']) ?? 'SERVICE').toUpperCase();

/// Solicitud de emergencia: el cliente pagó el servicio de urgencia.
bool asrIsEmergency(Map<String, dynamic> data) =>
    asrRequestType(data) == 'EMERGENCY';

/// Solicitud de cotización. El perfil Independiente **no** las trabaja, así que
/// se filtran de sus listados (ver [asrIsWorkableByIndependent]).
bool asrIsQuote(Map<String, dynamic> data) => asrRequestType(data) == 'QUOTE';

/// Píldora de prioridad: URGENTE (emergencia) o ESTANDAR (servicio normal).
String asrPriorityLabel(Map<String, dynamic> data) =>
    asrIsEmergency(data) ? kUrgentPriorityLabel : kStandardPriorityLabel;

/// Trabajos que puede tomar un asociado con `Role = Independent`: sólo servicios
/// estándar y emergencias. Las cotizaciones (QUOTE) y los trabajos fuera de
/// alcance (OUT_OF_SCOPE) son de la red de empresas y no se listan para él.
bool asrIsWorkableByIndependent(Map<String, dynamic> data) {
  const workable = {'SERVICE', 'EMERGENCY'};
  return workable.contains(asrRequestType(data));
}

/// Nombre del trabajo tal como lo etiqueta el catálogo (`serviceDetail.label`).
String asrServiceName(Map<String, dynamic> data) {
  final detail = _asMap(data['serviceDetail']) ?? _asMap(data['service']);
  return _firstString([
        detail?['label'],
        detail?['name'],
        data['serviceName'],
      ]) ??
      'Servicio';
}

/// Código de catálogo del servicio (Ej: `PLUMBING`). Es con lo que se cruza la
/// tarjeta contra el filtro de categoría.
String? asrServiceCode(Map<String, dynamic> data) {
  final detail = _asMap(data['serviceDetail']) ?? _asMap(data['service']);
  return _firstString([
    detail?['code'],
    data['serviceCode'],
    data['serviceId'],
  ])?.toUpperCase();
}

Map<String, dynamic>? _addressOf(Map<String, dynamic> data) =>
    _asMap(data['address']) ?? _asMap(data['serviceAddress']);

/// Zona/barrio de la visita. **Nunca la calle ni el número**: en la bolsa de
/// oportunidades el asociado todavía no tomó el trabajo, y revelar la dirección
/// exacta de un cliente que no lo contrató es una fuga de datos. La dirección
/// completa se ve en el detalle de la visita, después de aceptarla
/// ([asrExactAddress]).
///
/// `zone` viaja como string en el contrato de direcciones
/// (`CreateServiceAddressCall`), pero se contempla también anidado por si el
/// listado del marketplace lo expande a objeto.
String asrZone(Map<String, dynamic> data) {
  final address = _addressOf(data);
  final zoneObject = _asMap(address?['zone']) ?? _asMap(data['workableZone']);
  return _firstString([
        address?['zone'],
        address?['zoneName'],
        address?['neighborhood'],
        address?['sector'],
        zoneObject?['name'],
        zoneObject?['label'],
        address?['city'],
        data['zone'],
        data['zoneName'],
      ]) ??
      kHiddenAddressPlaceholder;
}

/// Etiqueta de ubicación de la tarjeta, con el mismo formato del diseño.
String asrZoneLabel(Map<String, dynamic> data) => 'Dirección: ${asrZone(data)}';

/// Dirección exacta de la visita. **Sólo para el detalle de un trabajo ya
/// tomado**: el backend la incluye recién cuando el asociado quedó asignado.
/// Null mientras la solicitud siga en la bolsa de oportunidades.
String? asrExactAddress(Map<String, dynamic> data) {
  final address = _addressOf(data);
  return _firstString([
    address?['address'],
    address?['fullAddress'],
    address?['line1'],
    data['exactAddress'],
    data['addressLine'],
  ]);
}

/// Instrucciones para llegar / ingresar que dejó el cliente.
String? asrAccessInstructions(Map<String, dynamic> data) {
  final address = _addressOf(data);
  return _firstString([
    address?['accessInstructions'],
    address?['instructions'],
    address?['reference'],
    data['accessInstructions'],
    data['arrivalInstructions'],
  ]);
}

/// Estado del ciclo de vida de la solicitud (PENDING / TAKEN / IN_PROGRESS /
/// FINISHED).
String asrStatus(Map<String, dynamic> data) =>
    (asrString(data['status']) ?? 'PENDING').toUpperCase();

/// Estados en los que la solicitud ya tiene dueño y no se puede tomar.
const Set<String> _kClaimedStatuses = {'TAKEN', 'IN_PROGRESS', 'FINISHED'};

/// ¿La solicitud sigue libre para que el asociado se postule?
///
/// Se descarta por estado (ya tomada / en curso / finalizada) y por tener un
/// asociado asignado. Deliberadamente **no** exige `status == PENDING`: un
/// estado desconocido del backend no debería esconder el botón y dejar al
/// asociado mirando las acciones de un trabajo que no es suyo. Si igual estaba
/// tomada, el backend rechaza la toma y [asrIsTakeable] no es la última
/// palabra — la toma es atómica del lado del servidor.
bool asrIsTakeable(Map<String, dynamic> data) {
  if (_kClaimedStatuses.contains(asrStatus(data))) return false;
  final assigned = data['associate'] ??
      data['assignedAssociate'] ??
      data['homeAssociate'] ??
      data['associateId'];
  return assigned == null || (assigned is String && assigned.trim().isEmpty);
}

DateTime? asrScheduledAt(Map<String, dynamic> data) {
  final apt = _asMap(data['appointment']);
  final raw = _firstString([data['scheduledAt'], apt?['scheduledAt']]);
  return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}

DateTime? asrCreatedAt(Map<String, dynamic> data) {
  final raw = asrString(data['createdAt']);
  return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}

/// Fecha contra la que filtran los listados. Cae en la de creación para las
/// solicitudes que todavía no tienen visita agendada (Ej: una emergencia recién
/// pagada), para que ninguna tarjeta visible quede fuera del filtro.
DateTime? asrFilterDate(Map<String, dynamic> data) =>
    asrScheduledAt(data) ?? asrCreatedAt(data);

String _two(int value) => value.toString().padLeft(2, '0');

/// Fecha de la visita en el formato del diseño (`dd/mm/aaaa`).
String asrFormattedDate(Map<String, dynamic> data) {
  final scheduled = asrScheduledAt(data);
  if (scheduled == null) return 'Fecha por confirmar';
  return '${_two(scheduled.day)}/${_two(scheduled.month)}/${scheduled.year}';
}

/// Fecha en formato largo, para el detalle y los listados completos.
String asrLongDate(Map<String, dynamic> data) {
  final scheduled = asrScheduledAt(data);
  if (scheduled == null) return 'Fecha por confirmar';
  return '${scheduled.day} de ${_monthsEs[scheduled.month - 1]} de '
      '${scheduled.year}';
}

/// Mes al que pertenece la solicitud, como clave ordenable (`2026-08`).
///
/// Null cuando la solicitud no tiene ninguna fecha: no se la puede agrupar, así
/// que queda fuera de cualquier filtro de mes en vez de caer en uno arbitrario.
String? asrMonthKey(Map<String, dynamic> data) {
  final date = asrFilterDate(data);
  if (date == null) return null;
  return '${date.year}-${_two(date.month)}';
}

/// Etiqueta del mes para el filtro de fecha (`Agosto 2026`).
String? asrMonthLabel(Map<String, dynamic> data) {
  final date = asrFilterDate(data);
  if (date == null) return null;
  return '${_monthsEs[date.month - 1]} ${date.year}';
}

/// Hora de la visita (`Hora: HH:mm`). Una emergencia sin hora agendada se
/// atiende cuanto antes, así que se dice eso en vez de inventar una hora.
String asrTimeLabel(Map<String, dynamic> data) {
  final scheduled = asrScheduledAt(data);
  if (scheduled == null) {
    return asrIsEmergency(data)
        ? 'Hora: lo antes posible'
        : 'Hora: por definir';
  }
  return 'Hora: ${_two(scheduled.hour)}:${_two(scheduled.minute)}';
}

/// Monto **neto** que cobra el asociado por el trabajo, ya descontada la
/// comisión de DOVIA. Lo calcula el backend; la UI sólo lo lee. Si el payload no
/// lo trae, devuelve null y la tarjeta lo dice explícitamente en vez de mostrar
/// el precio que pagó el cliente (que no es lo que el asociado recibe).
num? asrPayoutAmount(Map<String, dynamic> data) {
  final payment = _asMap(data['payment']) ??
      _asMap(data['paymentOrder']) ??
      _asMap(data['pricing']);
  return _firstNum([
    data['associatePayout'],
    data['associateAmount'],
    data['associateEarnings'],
    data['netAmount'],
    data['payout'],
    data['amountToReceive'],
    payment?['associatePayout'],
    payment?['associateAmount'],
    payment?['netAmount'],
    payment?['amountToReceive'],
  ]);
}

String asrCurrency(Map<String, dynamic> data) {
  final payment = _asMap(data['payment']) ?? _asMap(data['paymentOrder']);
  return _firstString([data['currency'], payment?['currency']]) ?? 'GTQ';
}

/// Mismo formato de moneda que el resto de Dovia Home (GTQ → `Q1,200`).
String asrFormatAmount(num amount, String currency) {
  final rounded = (amount * 100).round() / 100;
  final fixed = rounded.toStringAsFixed(2);
  final parts = fixed.split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  final body = parts[1] == '00' ? grouped : '$grouped.${parts[1]}';
  return currency.toUpperCase() == 'GTQ' ? 'Q$body' : '$currency $body';
}

/// Transparencia de pago de la tarjeta: "Podrás ganar: X".
String asrPayoutLabel(Map<String, dynamic> data) {
  final amount = asrPayoutAmount(data);
  if (amount == null) return 'Podrás ganar: por confirmar';
  return 'Podrás ganar: ${asrFormatAmount(amount, asrCurrency(data))}';
}

/// Búsqueda por palabras clave sobre la tarjeta (Ej: "Fuga de agua",
/// "Instalación TV"). Cruza el título del trabajo, la descripción del cliente,
/// la categoría del catálogo y la zona; ignora tildes y mayúsculas para que
/// "instalacion" también encuentre "Instalación".
bool asrMatchesQuery(Map<String, dynamic> data, String query) {
  final terms = _normalize(query).split(RegExp(r'\s+'))
    ..removeWhere((t) => t.isEmpty);
  if (terms.isEmpty) return true;

  final haystack = _normalize([
    asrServiceName(data),
    asrServiceCode(data) ?? '',
    asrString(data['description']) ?? '',
    asrZone(data),
    asrPriorityLabel(data),
  ].join(' '));

  return terms.every(haystack.contains);
}

const Map<String, String> _accents = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

String _normalize(String value) {
  var out = value.toLowerCase();
  _accents.forEach((from, to) => out = out.replaceAll(from, to));
  return out;
}
