// Lectura de una oferta enviada tal como la muestra el detalle "Oferta de
// compra/renta realizada": la propuesta congelada, en sólo lectura.
//
// El detalle no edita nada, así que en vez de rearmar el formulario de
// "Ofertar" con sus controladores, se traduce el JSON a la lista de campos que
// la pantalla dibuja. Así el reparto entre secciones —lo que puso el
// propietario y lo que propuso el cliente— se puede probar sin montar la UI.

import 'client_offer_models.dart';
import 'offer_json.dart';

enum OfferDetailFieldKind { text, textArea, currency }

/// Un campo del detalle, ya formateado para mostrarse.
class OfferDetailField {
  final String label;
  final String value;
  final OfferDetailFieldKind kind;

  /// El campo ocupa media fila: se aparea con el siguiente campo `half`.
  final bool half;

  const OfferDetailField(
    this.label,
    this.value, {
    this.kind = OfferDetailFieldKind.text,
    this.half = false,
  });
}

/// Bloque de campos bajo un subtítulo del diseño ("Estructura hipotecaria",
/// "¿Quién será el comprador?", "Si es empresa").
class OfferDetailSection {
  final String? title;
  final List<OfferDetailField> fields;

  const OfferDetailSection({this.title, required this.fields});
}

/// Valor ausente. Es el guion que ya usan el detalle del comprador y el del
/// propietario para un campo que el backend no mandó.
const String _empty = '—';

class ClientOfferDetail {
  /// Título del header: "Oferta de compra realizada", "Oferta de renta
  /// rechazada"...
  final String title;

  /// La negociación se cerró: el pie muestra el motivo en vez de las acciones.
  final bool isRejected;

  /// Texto que redactó el propietario al rechazar. Vacío si no llegó ninguno.
  final String rejectionReason;

  /// Todavía se puede retirar la oferta.
  final bool canWithdraw;

  /// Lo que publicó el propietario, arriba del formulario.
  final List<OfferDetailSection> ownerSections;

  /// La propuesta del cliente.
  final List<OfferDetailSection> proposalSections;

  const ClientOfferDetail({
    required this.title,
    required this.isRejected,
    required this.rejectionReason,
    required this.canWithdraw,
    required this.ownerSections,
    required this.proposalSections,
  });

  /// [offerJson] es la respuesta de `GET /offers/{offerId}` y [propertyJson] la
  /// de `GET /properties/{id}`: el inmueble es ajeno y la oferta sólo trae su
  /// id, así que sin ese cruce la sección del propietario queda en guiones.
  factory ClientOfferDetail.fromJson(
    Map<String, dynamic> offerJson, {
    Map<String, dynamic>? propertyJson,
  }) {
    final offer = ClientOffer.fromJson(offerJson);
    final data = _proposalData(offerJson);
    final property = unwrapPropertyJson(propertyJson);
    final isRent = offer.offerType == 'RENT';

    final isRejected = offer.wasRejectedByOwner;

    return ClientOfferDetail(
      title: 'Oferta de ${isRent ? 'renta' : 'compra'} '
          '${isRejected ? 'rechazada' : 'realizada'}',
      isRejected: isRejected,
      rejectionReason: offer.rejectionReason,
      canWithdraw: offer.isCancellable,
      ownerSections: [
        OfferDetailSection(
          title: 'Características que proporcionó el propietario',
          fields:
              isRent ? _rentOwnerFields(property) : _saleOwnerFields(property),
        ),
      ],
      proposalSections:
          isRent ? _rentProposal(data) : _saleProposal(data, offer),
    );
  }

  /// Todos los campos, en orden. Atajo para las pruebas y para buscar un valor
  /// sin recorrer las secciones a mano.
  List<OfferDetailField> get allFields =>
      [...ownerSections, ...proposalSections].expand((s) => s.fields).toList();
}

/// La propuesta vigente: la contraoferta manda sobre la oferta original, igual
/// que en las tarjetas y en el detalle del propietario.
Map<String, dynamic> _proposalData(Map<String, dynamic> json) {
  return offerAsMap(json['activeOfferData']) ??
      offerAsMap(json['counterOfferData']) ??
      offerAsMap(json['originalOfferData']) ??
      offerAsMap(json['offerData']) ??
      json;
}

/// `GET /properties/{id}` responde `{data: {data: {...}}}`, pero otros lugares
/// ya entregan la propiedad desenvuelta: se aceptan las dos formas.
Map<String, dynamic>? unwrapPropertyJson(Map<String, dynamic>? json) {
  var current = json;
  for (var i = 0; i < 2; i++) {
    if (current == null) return null;
    if (current.containsKey('name') || current.containsKey('saleInfo')) break;
    final nested = offerAsMap(current['data']);
    if (nested == null) break;
    current = nested;
  }
  return current;
}

List<OfferDetailField> _saleOwnerFields(Map<String, dynamic>? property) {
  return [
    OfferDetailField(
      'Precio',
      _money(_propertyNum(property, const ['saleInfo.salePrice', 'price'])),
      half: true,
    ),
    OfferDetailField('Disponible desde', _availableFrom(property), half: true),
  ];
}

List<OfferDetailField> _rentOwnerFields(Map<String, dynamic>? property) {
  return [
    OfferDetailField(
      'Precio mensual',
      _money(_propertyNum(property, const ['rentInfo.monthlyRent', 'price'])),
      half: true,
    ),
    OfferDetailField('Disponible desde', _availableFrom(property), half: true),
    OfferDetailField(
      'Tiempo mínimo de contrato en meses',
      _months(
        _propertyStr(property, const [
          'rentInfo.rentalConditions.minimumContractMonths',
          'rentInfo.rentalConditions.minimumMonths',
          'rentInfo.rentalConditions.minimumTime',
          'rentInfo.minimumContractMonths',
        ]),
      ),
    ),
    OfferDetailField(
      'Otras consideraciones',
      _propertyStr(property, const [
        'infoHQ.showingConsiderations',
        'rentInfo.rentalConditions.otherConsiderations',
        'rentInfo.rentalConditions.others',
      ]),
    ),
    OfferDetailField(
      'Uso permitido en esta propiedad',
      _propertyStr(property, const [
        'rentInfo.rentalConditions.allowedUses',
        'conditions.allowedUses',
      ]),
    ),
    OfferDetailField(
      'Uso no permitido en esta propiedad',
      _propertyStr(property, const [
        'rentInfo.rentalConditions.notAllowedUses',
        'rentInfo.rentalConditions.prohibitedUses',
        'conditions.notAllowedUses',
      ]),
    ),
  ];
}

List<OfferDetailSection> _saleProposal(
  Map<String, dynamic> data,
  ClientOffer offer,
) {
  final method = offer.normalizedPaymentMethod;
  final currency = _currencyLabel(data);
  final amount = _money(offerNum(data['proposedAmount']), currency: currency);

  final sections = <OfferDetailSection>[
    OfferDetailSection(
      fields: [
        OfferDetailField(
          'Método de pago',
          _paymentMethodLabel(method),
          half: true,
        ),
        OfferDetailField(
          'Moneda de pago',
          currency,
          kind: OfferDetailFieldKind.currency,
          half: true,
        ),
      ],
    ),
  ];

  switch (method) {
    case 'hipoteca':
      sections.add(
        OfferDetailSection(
          title: 'Estructura hipotecaria',
          fields: [
            OfferDetailField(
              'Enganche',
              _percent(data['downPaymentPercentage']),
            ),
            OfferDetailField('Propuesta económica', amount, half: true),
            OfferDetailField(
              'Banco a utilizar',
              _str(data['bankName']),
              half: true,
            ),
            OfferDetailField('Estado del crédito', _creditStatus(data)),
            OfferDetailField(
              'Tiempo estimado para aprobación del banco',
              _months(_str(data['estimatedApprovalTime'])),
            ),
          ],
        ),
      );
      break;
    case 'promesa':
      sections.add(
        OfferDetailSection(
          fields: [
            OfferDetailField(
              'Reserva',
              _money(offerNum(data['initialReserve']), currency: currency),
            ),
            OfferDetailField(
              'Pago final',
              _money(offerNum(data['finalPayment']), currency: currency),
              half: true,
            ),
            OfferDetailField(
              'Tiempo de promesa',
              _months(_str(data['promiseTimeMonths'])),
              half: true,
            ),
          ],
        ),
      );
      break;
    default:
      sections.add(
        OfferDetailSection(
          fields: [
            OfferDetailField('Propuesta económica', amount),
            OfferDetailField(
              'Tiempo estimado de pago',
              _months(_str(data['estimatedPaymentTime'])),
            ),
          ],
        ),
      );
  }

  final buyer = offerAsMap(data['buyerInfo']) ?? const {};
  sections.addAll([
    OfferDetailSection(
      title: '¿Quién será el comprador?',
      fields: [OfferDetailField('Nombre del comprador', _str(buyer['name']))],
    ),
    OfferDetailSection(
      title: 'Si es empresa',
      fields: [
        OfferDetailField('Razón social', _str(buyer['legalName']), half: true),
        OfferDetailField(
          'Representante legal',
          _str(buyer['legalRepresentative']),
          half: true,
        ),
      ],
    ),
    OfferDetailSection(
      fields: [
        OfferDetailField(
          'Consideraciones o solicitudes',
          _str(data['considerations']),
          kind: OfferDetailFieldKind.textArea,
        ),
      ],
    ),
  ]);

  return sections;
}

List<OfferDetailSection> _rentProposal(Map<String, dynamic> data) {
  final tenant = offerAsMap(data['tenantInfo']) ?? const {};
  final start = _date(data['contractStartDate']);
  final end = _date(data['contractEndDate']);

  return [
    OfferDetailSection(
      fields: [
        OfferDetailField('Fecha de inicio de contrato', start, half: true),
        OfferDetailField('Fecha de finalización de contrato', end, half: true),
        OfferDetailField(
          'Duración del contrato',
          _contractLength(data['contractStartDate'], data['contractEndDate']),
          half: true,
        ),
        OfferDetailField(
          'Moneda de pago',
          _currencyLabel(data),
          kind: OfferDetailFieldKind.currency,
          half: true,
        ),
        OfferDetailField(
          '¿Qué uso le darás a la propiedad?',
          _str(data['propertyUse']),
        ),
        OfferDetailField(
          'Consideraciones o solicitudes',
          _str(data['considerations']),
          kind: OfferDetailFieldKind.textArea,
        ),
      ],
    ),
    OfferDetailSection(
      fields: [
        OfferDetailField('Quien será el arrendatario', _str(tenant['name'])),
      ],
    ),
    OfferDetailSection(
      title: 'Si es empresa',
      fields: [
        OfferDetailField('Razón social', _str(tenant['legalName']), half: true),
        OfferDetailField(
          'Representante legal',
          _str(tenant['legalRepresentative']),
          half: true,
        ),
      ],
    ),
  ];
}

// ── Formato ─────────────────────────────────────────────────────────────────

String _str(dynamic value) => offerStr(value) ?? _empty;

String _paymentMethodLabel(String normalized) {
  switch (normalized) {
    case 'hipoteca':
      return 'Hipoteca';
    case 'promesa':
      return 'Promesa de compra';
    default:
      return 'Contado';
  }
}

String _creditStatus(Map<String, dynamic> data) {
  final raw = offerStr(data['creditStatus']);
  switch (raw?.toLowerCase()) {
    case 'approved':
      return 'Aprobado';
    case 'in_process':
      return 'En proceso';
    case 'not_started':
      return 'No iniciado';
    default:
      return raw ?? _empty;
  }
}

String _currencyLabel(Map<String, dynamic> data) {
  final raw = (offerStr(data['currency']) ?? 'USD').toUpperCase();
  return raw == 'GTQ' || raw == 'QUETZALES' ? 'Quetzales' : raw;
}

String _money(num? amount, {String currency = 'USD'}) {
  if (amount == null) return _empty;
  final formatted = amount.truncateToDouble() == amount
      ? amount.toInt().toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'),
            (m) => '${m[1]},',
          )
      : amount.toStringAsFixed(2);
  return currency == 'USD' ? 'USD $formatted' : '$currency $formatted';
}

String _percent(dynamic value) {
  final raw = offerStr(value);
  return raw == null ? _empty : '$raw%';
}

String _months(String value) {
  if (value == _empty) return _empty;
  return value == '1' ? '1 mes' : '$value meses';
}

String _date(dynamic value) {
  final parsed = DateTime.tryParse(offerStr(value) ?? '');
  if (parsed == null) return _empty;
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

/// El formulario calcula la duración a partir de las fechas ("Calculo en base
/// a fechas"), así que el detalle la recalcula igual.
String _contractLength(dynamic start, dynamic end) {
  final from = DateTime.tryParse(offerStr(start) ?? '');
  final to = DateTime.tryParse(offerStr(end) ?? '');
  if (from == null || to == null) return _empty;
  final months = (to.year - from.year) * 12 + (to.month - from.month);
  if (months <= 0) return _empty;
  return _months(months.toString());
}

String _availableFrom(Map<String, dynamic>? property) {
  final raw = _propertyStr(property, const [
    'rentInfo.rentalConditions.availableFrom',
    'conditions.availableFrom',
    'availableFrom',
  ]);
  if (raw == _empty) return _empty;
  final asDate = _date(raw);
  return asDate == _empty ? raw : asDate;
}

/// Lee un valor de la propiedad probando varias rutas con puntos.
dynamic _propertyValue(Map<String, dynamic>? property, List<String> paths) {
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

String _propertyStr(Map<String, dynamic>? property, List<String> paths) =>
    _str(_propertyValue(property, paths));

num? _propertyNum(Map<String, dynamic>? property, List<String> paths) =>
    offerNum(_propertyValue(property, paths));
