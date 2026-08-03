/// Lectura del payload de `GET /dovia-home/service-requests` para las pantallas
/// del cliente (Dovia Home).
///
/// Los nombres de los campos vienen del contrato real del backend, que no es el
/// que asumían las pantallas:
///   - El servicio se anida en `serviceDetail` (`label` / `code`). **No existe**
///     `serviceName`, así que leerlo dejaba todas las tarjetas como "Servicio".
///   - `scheduledAt` viaja en la raíz de la solicitud. **No existe** un objeto
///     `appointment`.
///   - El flujo de cotización deja `status` en `PENDING` y expresa el avance en
///     `subStatus` (Ej: `QUOTE_QUOTING`), por lo que la píldora tiene que mirar
///     los dos campos.
///   - `requestType` distingue `SERVICE` / `EMERGENCY` / `QUOTE`.
library;

/// Píldora de las solicitudes de cotización que están en manos de la red de
/// proveedores esperando propuestas.
const String kPendingQuoteStatusLabel = 'Pendiente de Cotización';

/// Título de las solicitudes de cotización. El catálogo las etiqueta como
/// "Servicio por cotizar" (`code: SERVICE_QUOTE`), que no le dice nada al
/// cliente que la creó.
const String kQuoteRequestTitle = 'Solicitud de cotización';

/// El app solo inicializa el locale 'en', por eso las fechas en español se arman
/// manualmente (mismo criterio que el resto de pantallas del cliente).
const List<String> _weekdaysEs = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
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

String? srString(dynamic value) =>
    (value is String && value.trim().isNotEmpty) ? value.trim() : null;

String srId(Map<String, dynamic> data) =>
    (data['id'] ?? data['serviceRequestId'])?.toString() ?? '';

String srRequestType(Map<String, dynamic> data) =>
    (srString(data['requestType']) ?? 'SERVICE').toUpperCase();

bool srIsEmergency(Map<String, dynamic> data) =>
    srRequestType(data) == 'EMERGENCY';

bool srIsQuote(Map<String, dynamic> data) => srRequestType(data) == 'QUOTE';

/// Nombre del servicio tal como lo etiqueta el catálogo (`serviceDetail.label`).
String srServiceName(Map<String, dynamic> data) {
  if (srIsQuote(data)) return kQuoteRequestTitle;
  final detail = data['serviceDetail'];
  return srString(detail is Map ? detail['label'] : null) ??
      srString(data['serviceName']) ??
      'Servicio';
}

/// Retorna el asset del icono correspondiente al servicio.
String srServiceIconAsset(String serviceName) {
  switch (serviceName) {
    case 'Plomería':
      return 'assets/images/IconoServicioPlomeria.svg';
    case 'Eléctrico':
      return 'assets/images/IconoServicioElectrico.svg';
    case 'Albañilería':
      return 'assets/images/IconoServicioAlbaileria.svg';
    case 'Pintura':
      return 'assets/images/IconServicioPintura.svg';
    case 'Instalación':
      return 'assets/images/IconServicioInstalacion.svg';
    case 'Servicio de emergencia':
    case 'Servicio de\nemergencia':
      return 'assets/images/warning-triangle.svg';
    default:
      return 'assets/images/IconoCaja.svg';
  }
}

/// Fecha de la visita agendada. Null mientras la solicitud no tenga fecha (Ej:
/// una cotización esperando propuestas). Deliberadamente **no** cae a
/// `createdAt`: pintar la fecha de creación en el lugar de la fecha de visita
/// hace parecer que el trabajo ya está calendarizado.
DateTime? srScheduledAt(Map<String, dynamic> data) {
  final apt = data['appointment'];
  final raw = srString(data['scheduledAt']) ??
      srString(apt is Map ? apt['scheduledAt'] : null);
  return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}

DateTime? srCreatedAt(Map<String, dynamic> data) {
  final raw = srString(data['createdAt']);
  return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}

/// Fecha contra la que filtra el selector "Fecha del trabajo". Usa la fecha
/// agendada y, para las solicitudes que aún no la tienen, la de creación: así
/// toda tarjeta visible sigue siendo alcanzable desde el filtro.
DateTime? srFilterDate(Map<String, dynamic> data) =>
    srScheduledAt(data) ?? srCreatedAt(data);

/// Texto de la fecha en la tarjeta. Distingue la visita agendada de la
/// solicitud que todavía no tiene fecha, en vez de mostrar ambas igual.
String srFormattedDate(Map<String, dynamic> data) {
  final scheduled = srScheduledAt(data);
  if (scheduled != null) {
    return '${_weekdaysEs[scheduled.weekday - 1]}, ${scheduled.day} de '
        '${_monthsEs[scheduled.month - 1]}';
  }
  final created = srCreatedAt(data);
  if (created == null) return 'Fecha pendiente';
  return 'Solicitada el ${created.day} de ${_monthsEs[created.month - 1]}';
}

/// Píldora de estatus que ve el cliente.
///
/// Reglas, en orden: una solicitud tomada por un asociado y no confirmada aún
/// pide acción ("Confirmar"); una cotización en curso reporta su `subStatus`
/// (con `status` en `PENDING`, decir "Pendiente" escondería que la solicitud ya
/// está circulando entre proveedores); el resto sale del enum `status`
/// (PENDING / TAKEN / IN_PROGRESS / FINISHED).
String srStatusLabel(Map<String, dynamic> data, Set<String> confirmedIds) {
  final status = (srString(data['status']) ?? 'PENDING').toUpperCase();
  final subStatus = (srString(data['subStatus']) ?? '').toUpperCase();

  if (status == 'TAKEN' && !confirmedIds.contains(srId(data))) {
    return 'Confirmar';
  }
  if (subStatus.startsWith('QUOTE')) return kPendingQuoteStatusLabel;

  switch (status) {
    case 'TAKEN':
      return 'Programada';
    case 'IN_PROGRESS':
      return 'En progreso';
    case 'FINISHED':
      return 'Finalizada';
    case 'PENDING':
    default:
      return 'Pendiente';
  }
}
