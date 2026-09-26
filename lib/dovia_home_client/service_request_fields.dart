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

/// Categoría que el cliente eligió dentro del servicio, con el alcance que el
/// catálogo le adjunta ("Reparación de fugas: en tuberías o conexiones
/// visibles, de 2 a 3 fugas por visita").
///
/// **Null en las solicitudes anteriores al cambio de contrato**: el backend
/// las devuelve con `categoryId` y `selectedCategory` en null, así que la
/// pantalla omite el dato en vez de inventarle una categoría.
String? srCategoryLabel(Map<String, dynamic> data) {
  final selected = data['selectedCategory'];
  if (selected is! Map) return null;
  final name = srString(selected['name']);
  if (name == null) return null;
  final description = srString(selected['description']);
  return description == null ? name : '$name: $description';
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

/// Ícono de la solicitud: el de su servicio; en una cotización, el del
/// servicio que la originó si el backend lo trae.
String srIconAsset(Map<String, dynamic> data) {
  if (srIsQuote(data)) {
    final detail = data['serviceDetail'];
    final label = srString(detail is Map ? detail['label'] : null) ??
        srString(data['serviceName']);
    return label == null ? kQuoteIconAsset : srServiceIconAsset(label);
  }
  return srServiceIconAsset(srServiceName(data));
}

/// Marca para las cotizaciones sin servicio: la tarjeta pinta un ícono de
/// cotización en vez de un SVG.
const String kQuoteIconAsset = 'quote';

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

/// Nombre de la propiedad para la cabecera del detalle.
///
/// **El contrato no tiene un nombre de casa que el cliente pueda poner.**
/// `DoviaHomeClientAddressResponseDto` expone `label`, y el backend lo genera
/// solo como `"casa - "` + los primeros 30 caracteres de `address`;
/// `CreateServiceAddressRequestDto` ni siquiera acepta `label`. Por eso se corta
/// en el primer `" - "`: lo que queda es ese prefijo fijo, no un alias.
///
/// Se conserva la función —y no se pinta `label` crudo— porque pintarlo entero
/// llenaría la cabecera con la dirección truncada a mitad de palabra. Si el
/// producto quiere un nombre real por vivienda, hay que pedirlo como campo
/// nuevo del backend: desde la app no hay dónde tomarlo.
String srHouseName(Map<String, dynamic> data) {
  final address = data['address'];
  final raw = address is Map ? srString(address['label']) : null;
  if (raw == null) return 'Casa';
  final name = raw.split(' - ').first.trim();
  if (name.isEmpty) return 'Casa';
  return name[0].toUpperCase() + name.substring(1);
}

/// Tipos de solicitud que piden la confirmación de la visita al cliente.
///
/// Solo aplica cuando **el sistema** asigna un Home Associate persona. En
/// `QUOTE` y `OUT_OF_SCOPE` el cliente ya eligió y aprobó al proveedor
/// aceptando una propuesta (y en out-of-scope además la pagó), así que el
/// backend las deja en `TAKEN` sin que quede nada por autorizar: volver a
/// pedirle "Confirmar" sería pedir dos veces la misma decisión.
const Set<String> kConfirmableRequestTypes = {'SERVICE', 'EMERGENCY'};

/// Si la solicitud puede pedirle al cliente que confirme la visita.
bool srIsConfirmable(Map<String, dynamic> data) =>
    kConfirmableRequestTypes.contains(srRequestType(data));

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

num? _firstNum(List<dynamic> candidates) {
  for (final value in candidates) {
    if (value is num) return value;
  }
  return null;
}

/// Estado del pago de la solicitud (`payment.status`). No confundir con
/// `status`/`subStatus` de la solicitud: una solicitud puede estar `TAKEN` y
/// seguir sin pagarse (Ej: se creó en Agenda y el cliente todavía no cobró en
/// ValorVisita).
/// Solicitud creada pero sin cobrar: el backend la crea al abrir la pantalla
/// de pago (necesita su precio) con `subStatus: PAYMENT_PENDING`, y la deja así
/// hasta que el pago se confirma. Todavía nadie la busca ni la atiende.
bool srAwaitsPayment(Map<String, dynamic> data) =>
    (srString(data['status']) ?? '').toUpperCase() == 'PENDING' &&
    (srString(data['subStatus']) ?? '').toUpperCase() == 'PAYMENT_PENDING';

const String kPaymentPendingStatusLabel = 'Pago pendiente';

bool srIsPaid(Map<String, dynamic> data) {
  final payment = _asMap(data['payment']) ?? _asMap(data['paymentOrder']);
  final status = srString(payment?['status']) ?? '';
  return status.toUpperCase() == 'PAID' || status.toUpperCase() == 'SUCCEEDED';
}

/// Monto a cobrar por el servicio (`price.price.gtq`), que es el mismo monto
/// que `POST /payments/custom-checkout` exige recibir en `amount`. Se sondea
/// de forma defensiva porque el contrato anida el monto distinto según de
/// dónde viene la solicitud (Ej: `price.price.gtq` vs `price.gtq`).
num? srPriceAmount(Map<String, dynamic> data) {
  final price = _asMap(data['price']);
  final nestedPrice = _asMap(price?['price']);
  return _firstNum([
    nestedPrice?['gtq'],
    price?['gtq'],
    price?['amount'],
    data['amount'],
  ]);
}

String srPriceCurrency(Map<String, dynamic> data) {
  final price = _asMap(data['price']);
  final nestedPrice = _asMap(price?['price']);
  return srString(nestedPrice?['currency']) ??
      srString(price?['currency']) ??
      srString(data['currency']) ??
      'GTQ';
}

/// Monto con descuento que se le cobraría a un suscriptor. `null` cuando el
/// payload no lo trae: no se pinta un monto inventado (mismo criterio que el
/// catálogo de planes, que sólo muestra precios que el backend confirma).
num? srSubscriberPriceAmount(Map<String, dynamic> data) {
  final price = _asMap(data['price']);
  return _firstNum([
    price?['subscriberGtq'],
    price?['discountedGtq'],
    _asMap(price?['subscriberPrice'])?['gtq'],
  ]);
}

/// Precio de lista, **antes** del descuento del plan. Es el monto tachado de la
/// tarjeta Premium; [srPriceAmount] es lo que se cobra de verdad.
///
/// `null` cuando el payload no lo distingue del precio aplicable: sin él no hay
/// descuento que anunciar y la tarjeta muestra sólo el monto a cobrar, en vez
/// de inventar un "antes" que haga parecer más grande el ahorro.
num? srBasePriceAmount(Map<String, dynamic> data) {
  final price = _asMap(data['price']);
  return _firstNum([
    price?['baseGtq'],
    price?['listGtq'],
    _asMap(price?['basePrice'])?['gtq'],
    _asMap(price?['listPrice'])?['gtq'],
  ]);
}

/// Descuento del plan sobre esta solicitud: cuánto se ahorra y qué porcentaje
/// representa. `null` si el backend no expone un precio de lista mayor al que
/// se cobra — no hay nada verificable que anunciar.
({num savings, int percentOff})? srPlanDiscount(Map<String, dynamic> data) {
  final base = srBasePriceAmount(data);
  final amount = srPriceAmount(data);
  if (base == null || amount == null || base <= amount || base <= 0) {
    return null;
  }
  final savings = base - amount;
  return (savings: savings, percentOff: ((savings / base) * 100).round());
}

/// Mismo formato de moneda que el resto de Dovia Home (`GTQ` → `Q449.99`).
String srFormatAmount(num amount, String currency) {
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

/// Píldora de estatus que ve el cliente.
///
/// Reglas, en orden: un servicio tomado por un asociado y no confirmado aún
/// pide acción ("Confirmar"); una cotización en curso reporta su `subStatus`
/// (con `status` en `PENDING`, decir "Pendiente" escondería que la solicitud ya
/// está circulando entre proveedores); el resto sale del enum `status`
/// (PENDING / TAKEN / IN_PROGRESS / FINISHED).
String srStatusLabel(Map<String, dynamic> data, Set<String> confirmedIds) {
  final status = (srString(data['status']) ?? 'PENDING').toUpperCase();
  final subStatus = (srString(data['subStatus']) ?? '').toUpperCase();

  if (srAwaitsPayment(data)) return kPaymentPendingStatusLabel;

  if (status == 'TAKEN' &&
      srIsConfirmable(data) &&
      !confirmedIds.contains(srId(data))) {
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
