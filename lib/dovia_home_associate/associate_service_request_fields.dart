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
///
/// **Revisar al implementar el reporte de fuera de alcance del asociado**
/// (`POST /dovia-home/associate/service-requests/{id}/out-of-scope-requests`,
/// que hoy ninguna pantalla llama). Ese endpoint acepta
/// `executionMode: REPORTER_CAN_EXECUTE | OTHER_PROVIDER_REQUIRED`: con el
/// primero, el fuera de alcance vuelve como trabajo del propio asociado que lo
/// reportó, y descartarlo acá lo dejaría fuera de su agenda —un compromiso suyo
/// que no ve en "Próximos trabajos"—. El descarte de OUT_OF_SCOPE sólo es
/// correcto mientras todos vayan a otro proveedor.
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

/// Categoría que el cliente eligió dentro del servicio (Ej: "Reparación de
/// fugas"). Es lo que acota el trabajo: el servicio dice el oficio, la
/// categoría dice qué se va a hacer y hasta dónde.
///
/// **Null en las solicitudes anteriores al cambio de contrato**, que viajan
/// con `selectedCategory` en null.
String? asrCategoryName(Map<String, dynamic> data) {
  final selected = _asMap(data['selectedCategory']);
  return _firstString([selected?['name'], selected?['label']]);
}

/// La categoría con el alcance que el catálogo le adjunta ("de 2 a 3 fugas por
/// visita"), que es el límite de lo que la visita cubre.
String? asrCategoryScope(Map<String, dynamic> data) {
  final name = asrCategoryName(data);
  if (name == null) return null;
  final description =
      _firstString([_asMap(data['selectedCategory'])?['description']]);
  return description == null ? name : '$name: $description';
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

/// Especialidades que el servicio de la solicitud exige
/// (`serviceDetail.requiredSpecialtyIds`). Son ids del mismo catálogo que
/// devuelve `GET /users/me/specialties`, así que es el cruce exacto entre una
/// tarjeta y los oficios del asociado — y el único que funciona para servicios
/// cuyo nombre no es un oficio (`INSTALACION`, `EMERGENCIA`).
Set<String> asrRequiredSpecialtyIds(Map<String, dynamic> data) {
  final detail = _asMap(data['serviceDetail']) ?? _asMap(data['service']);
  final raw = detail?['requiredSpecialtyIds'];
  if (raw is! List) return const {};
  return {
    for (final id in raw)
      if (asrString(id) != null) asrString(id)!,
  };
}

/// Trabajos que puede trabajar un asociado con `Role = HOME_ASSOCIATE_COMPANY`:
/// **sólo cotizaciones**. La bolsa de servicios estándar y emergencias es del
/// perfil Independiente, y el panel de la empresa está armado alrededor del
/// pipeline de presupuestos.
bool asrIsWorkableByCompany(Map<String, dynamic> data) => asrIsQuote(data);

/// Descripción libre que el cliente escribió al pedir la cotización. Es, junto
/// con las fotos ([asrRequestImages]), lo único con lo que la empresa arma su
/// presupuesto antes de visitar.
String? asrDescription(Map<String, dynamic> data) => _firstString([
      data['description'],
      data['clientDescription'],
      data['notes'],
    ]);

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

/// Coordenadas del domicilio de la visita, para centrar el mapa del asociado
/// una vez que tomó el trabajo. Viajan anidadas en `address.coordinates`, el
/// mismo contrato que arma `CreateServiceAddressCall` al cargar la dirección.
double? asrLatitude(Map<String, dynamic> data) {
  final address = _addressOf(data);
  final coordinates = _asMap(address?['coordinates']);
  return _firstNum([
    coordinates?['latitude'],
    coordinates?['lat'],
    address?['latitude'],
    data['latitude'],
  ])?.toDouble();
}

double? asrLongitude(Map<String, dynamic> data) {
  final address = _addressOf(data);
  final coordinates = _asMap(address?['coordinates']);
  return _firstNum([
    coordinates?['longitude'],
    coordinates?['lng'],
    address?['longitude'],
    data['longitude'],
  ])?.toDouble();
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

/// Qué tiene que llevar el asociado a la visita (sección "Debes llevar" del
/// diseño): herramientas, repuestos o materiales que el trabajo exige.
///
/// Sale del catálogo, en `serviceDetail.technicianBrings`: es la misma lista
/// que ve el cliente al pedir el servicio, así que los dos lados esperan lo
/// mismo del técnico. Se conservan las claves planas por si el resumen del
/// listado entrega el dato ya armado, y ante la duda devuelve null para que la
/// pantalla diga que no hay indicaciones en vez de inventarlas.
///
/// No cubre `requestedMaterials`, que es el flujo inverso —el asociado pidiendo
/// materiales *extra* una vez en sitio (`POST .../extra-materials`)—.
String? asrWhatToBring(Map<String, dynamic> data) {
  final detail = _asMap(data['serviceDetail']) ?? _asMap(data['service']);
  final brings = detail?['technicianBrings'];
  if (brings is List) {
    final items = <String>[
      for (final item in brings)
        if (asrString(item) != null) '- ${asrString(item)!}',
    ];
    if (items.isNotEmpty) return items.join('\n');
  }
  return _firstString([
    data['whatToBring'],
    data['requiredMaterials'],
    data['requiredTools'],
    data['materials'],
    detail?['whatToBring'],
    detail?['requiredMaterials'],
  ]);
}

/// Estado del ciclo de vida de la solicitud.
///
/// El enum es **cerrado y son estos cuatro**: PENDING / TAKEN / IN_PROGRESS /
/// FINISHED. El controller valida contra ellos el filtro `status` de los
/// listados, y no existe ningún estado de cancelación —Dovia Home tampoco
/// expone un endpoint para cancelar una solicitud—.
String asrStatus(Map<String, dynamic> data) =>
    (asrString(data['status']) ?? 'PENDING').toUpperCase();

/// El trabajo ya se ejecutó y se cerró. Es lo que parte la agenda del asociado
/// en sus dos secciones: lo que todavía tiene que hacer ("Trabajos aceptados")
/// y su historial ("Trabajos terminados").
///
/// Que FINISHED sea el **único** estado terminal es lo que hace correcto
/// definir los aceptados por descarte (`!asrIsFinished`): no hay un quinto
/// estado que pudiera colarse ahí como si fuera un compromiso vigente.
bool asrIsFinished(Map<String, dynamic> data) => asrStatus(data) == 'FINISHED';

/// Descripción del trabajo realizado que cargó el asociado al finalizar.
///
/// Se leen las mismas claves que consume el registro del cliente: el shape del
/// detalle todavía no está cerrado del lado del backend.
String? asrCompletionDescription(Map<String, dynamic> data) => _firstString([
      data['completionDescription'],
      data['workDoneDescription'],
      data['completionNotes'],
    ]);

/// Recomendaciones que el asociado le dejó al cliente al cerrar el trabajo.
String? asrCompletionRecommendations(Map<String, dynamic> data) =>
    _firstString([
      data['clientRecommendations'],
      data['recommendations'],
      data['completionRecommendations'],
    ]);

/// URLs de imágenes de una lista cuyo item puede ser un String suelto o un Map
/// con la URL en alguna de las claves conocidas.
List<String> _urlsFrom(dynamic list) {
  if (list is! List) return const [];
  final urls = <String>[];
  for (final item in list) {
    final direct = asrString(item);
    if (direct != null) {
      urls.add(direct);
      continue;
    }
    final map = _asMap(item);
    if (map == null) continue;
    final url = _firstString([
      map['url'],
      map['signedUrl'],
      map['downloadUrl'],
      map['storageKey'],
    ]);
    if (url != null) urls.add(url);
  }
  return urls;
}

/// Imágenes de completado agrupadas por categoría.
///
/// El asociado las sube contra `completion-images/confirm` con
/// `category: WORK | LEFTOVER_MATERIALS`, así que el detalle puede devolverlas
/// como un Map indexado por esa categoría. Mismo criterio que usa el registro
/// del cliente sobre el mismo dato.
List<String> _categorizedCompletionImages(
  Map<String, dynamic> data,
  String category,
) {
  for (final key in const [
    'completionImages',
    'completionImagesByCategory',
    'images',
  ]) {
    final node = _asMap(data[key]);
    if (node == null) continue;
    final urls = _urlsFrom(node[category] ?? node[category.toLowerCase()]);
    if (urls.isNotEmpty) return urls;
  }
  return const [];
}

/// Fotos de evidencia que el asociado le mandó al cliente al cerrar el trabajo.
///
/// El shape del detalle todavía no está cerrado del lado del backend: se
/// prueban la forma categorizada y las variantes planas conocidas, y ante la
/// duda se devuelve vacío (la pantalla dice que no hay evidencia en vez de
/// inventar una).
List<String> asrCompletionImages(Map<String, dynamic> data) {
  final categorized = _categorizedCompletionImages(data, 'WORK');
  if (categorized.isNotEmpty) return categorized;
  return _urlsFrom(
    data['completionImages'] ??
        data['workImages'] ??
        data['completedImages'] ??
        data['evidenceImages'] ??
        data['finishImages'],
  );
}

/// Fotos que **el cliente** adjuntó al pedir el trabajo.
///
/// El contrato las entrega en `requestImageUrls` (mismo campo que lee el
/// detalle del cliente); `images` e `imageUrls` se contemplan porque el
/// marketplace de empresa y el listado unificado de propuestas usan esa forma.
/// Son la evidencia con la que la empresa cotiza sin haber visitado, así que
/// ante la duda se devuelve vacío y la pantalla lo dice.
List<String> asrRequestImages(Map<String, dynamic> data) => _urlsFrom(
      data['requestImageUrls'] ?? data['imageUrls'] ?? data['images'],
    );

/// Nodo con la calificación que el cliente le dejó al asociado por este
/// trabajo, si el detalle la trae anidada.
Map<String, dynamic>? _clientRatingNode(Map<String, dynamic> data) {
  for (final key in const [
    'associateRating',
    'clientRating',
    'rating',
    'associateFeedback',
    'feedback',
    'review',
  ]) {
    final node = _asMap(data[key]);
    if (node != null) return node;
  }
  return null;
}

/// Estrellas (1 a 5) que el cliente le puso al asociado, o null si todavía no
/// calificó.
///
/// **Depende de que el detalle del servicio traiga la calificación**: el
/// contexto `associate-feedback` sólo expone endpoints de creación
/// (`POST .../ratings`), no hay un GET para leer lo recibido. Mientras el
/// backend no lo devuelva acá, esto responde null y la pantalla muestra el
/// estado "sin calificación" en vez de estrellas inventadas.
double? asrClientRatingStars(Map<String, dynamic> data) {
  final node = _clientRatingNode(data);
  final stars = _firstNum([
    data['ratingStars'],
    data['stars'],
    data['ratingValue'],
    data['rating'],
    node?['stars'],
    node?['rating'],
    node?['value'],
    node?['score'],
  ]);
  if (stars == null) return null;
  return stars.toDouble().clamp(0.0, 5.0);
}

/// Comentario en texto libre que el cliente dejó con su calificación.
///
/// Hoy suele venir vacío: la pantalla de calificar del cliente captura el
/// comentario pero los endpoints de ratings sólo aceptan `stars`, así que no
/// hay dónde persistirlo. Se lee igual para que la pantalla lo muestre en
/// cuanto el contrato lo soporte.
String? asrClientRatingComment(Map<String, dynamic> data) {
  final node = _clientRatingNode(data);
  return _firstString([
    data['ratingComment'],
    data['clientComment'],
    data['reviewComment'],
    node?['comment'],
    node?['message'],
    node?['review'],
    node?['text'],
    node?['description'],
  ]);
}

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

/// Fecha en formato largo ("14 de agosto de 2026"). Vive suelta de
/// [asrLongDate] para que otras pantallas formateen así una fecha que no es la
/// de la visita (Ej: cuándo se creó la solicitud) sin duplicar la tabla de
/// meses.
String asrLongDateFor(DateTime date) =>
    '${date.day} de ${_monthsEs[date.month - 1]} de ${date.year}';

/// Fecha en formato largo, para el detalle y los listados completos.
String asrLongDate(Map<String, dynamic> data) {
  final scheduled = asrScheduledAt(data);
  if (scheduled == null) return 'Fecha por confirmar';
  return asrLongDateFor(scheduled);
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
