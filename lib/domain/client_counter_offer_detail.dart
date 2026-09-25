import 'client_offer_models.dart';
import 'offer_json.dart';

enum CounterOfferFieldKey {
  paymentMethod,
  proposedAmount,
  bankName,
  downPaymentPercentage,
  creditStatus,
  estimatedApprovalTime,
  initialReserve,
  finalPayment,
  promiseTimeMonths,
  contractStartDate,
  contractEndDate,
  propertyUse,
  considerations,
}

enum CounterOfferFieldKind { text, number, date, textArea }

class CounterOfferField {
  final CounterOfferFieldKey key;
  final String label;
  final String value;
  final CounterOfferFieldKind kind;
  final bool half;
  final bool editable;
  final String suffix;

  const CounterOfferField({
    required this.key,
    required this.label,
    required this.value,
    this.kind = CounterOfferFieldKind.text,
    this.half = false,
    this.editable = true,
    this.suffix = '',
  });
}

/// Los términos de una ronda de negociación, normalizados para comparar y
/// editar sin que la vista conozca la forma cruda del backend.
class CounterOfferTerms {
  final String paymentMethod;
  final String currency;
  final List<CounterOfferField> fields;

  const CounterOfferTerms({
    required this.paymentMethod,
    required this.currency,
    required this.fields,
  });

  factory CounterOfferTerms.fromJson(
    Map<String, dynamic>? json, {
    required String offerType,
  }) {
    final data = json ?? const <String, dynamic>{};
    final rawMethod = offerStr(data['paymentMethod']) ?? '';
    final normalizedMethod = _normalizePaymentMethod(rawMethod);
    final currency = (offerStr(data['currency']) ?? 'USD').toUpperCase();

    if (offerType == 'RENT') {
      return CounterOfferTerms(
        paymentMethod: 'renta',
        currency: currency,
        fields: [
          const CounterOfferField(
            key: CounterOfferFieldKey.paymentMethod,
            label: 'Método de pago',
            value: 'Renta',
            editable: false,
          ),
          CounterOfferField(
            key: CounterOfferFieldKey.contractStartDate,
            label: 'Fecha de inicio de contrato',
            value: offerStr(data['contractStartDate']) ?? '',
            kind: CounterOfferFieldKind.date,
            half: true,
          ),
          CounterOfferField(
            key: CounterOfferFieldKey.contractEndDate,
            label: 'Fecha de finalización de contrato',
            value: offerStr(data['contractEndDate']) ?? '',
            kind: CounterOfferFieldKind.date,
            half: true,
          ),
          CounterOfferField(
            key: CounterOfferFieldKey.propertyUse,
            label: 'Uso de la propiedad',
            value: offerStr(data['propertyUse']) ?? '',
          ),
          CounterOfferField(
            key: CounterOfferFieldKey.considerations,
            label: 'Solicitud adicional',
            value: offerStr(data['considerations']) ?? '',
            kind: CounterOfferFieldKind.textArea,
          ),
        ],
      );
    }

    final fields = <CounterOfferField>[];
    void add(
      CounterOfferFieldKey key,
      String label,
      dynamic value, {
      CounterOfferFieldKind kind = CounterOfferFieldKind.text,
      bool half = false,
      String suffix = '',
      bool whenMissing = true,
    }) {
      final text = offerStr(value) ?? '';
      if (!whenMissing && text.isEmpty) return;
      fields.add(CounterOfferField(
        key: key,
        label: label,
        value: text,
        kind: kind,
        half: half,
        suffix: suffix,
      ));
    }

    // El método de pago abre las dos propuestas y nunca se edita: la
    // negociación mueve montos, no cambia de instrumento.
    fields.add(CounterOfferField(
      key: CounterOfferFieldKey.paymentMethod,
      label: 'Método de pago',
      value: _paymentMethodLabel(normalizedMethod),
      half: true,
      editable: false,
    ));

    switch (normalizedMethod) {
      case 'hipoteca':
        add(CounterOfferFieldKey.bankName, 'Banco', data['bankName'],
            half: true);
        add(
          CounterOfferFieldKey.proposedAmount,
          'Propuesta económica',
          data['proposedAmount'],
          kind: CounterOfferFieldKind.number,
          half: true,
        );
        add(
          CounterOfferFieldKey.downPaymentPercentage,
          'Enganche',
          data['downPaymentPercentage'] ?? data['downPayment'],
          kind: CounterOfferFieldKind.number,
          half: true,
          suffix: '%',
        );
        add(
          CounterOfferFieldKey.creditStatus,
          'Estado del crédito',
          data['creditStatus'],
          half: true,
          whenMissing: false,
        );
        add(
          CounterOfferFieldKey.estimatedApprovalTime,
          'Tiempo estimado de aprobación',
          data['estimatedApprovalTime'],
          kind: CounterOfferFieldKind.number,
          suffix: ' meses',
          whenMissing: false,
        );
        break;
      case 'promesa':
        add(
          CounterOfferFieldKey.proposedAmount,
          'Propuesta económica',
          data['proposedAmount'],
          kind: CounterOfferFieldKind.number,
          half: true,
        );
        add(
          CounterOfferFieldKey.initialReserve,
          'Reserva inicial',
          data['initialReserve'] ?? data['reservationAmount'],
          kind: CounterOfferFieldKind.number,
          half: true,
        );
        add(
          CounterOfferFieldKey.finalPayment,
          'Pago final',
          data['finalPayment'],
          kind: CounterOfferFieldKind.number,
          half: true,
        );
        add(
          CounterOfferFieldKey.promiseTimeMonths,
          'Tiempo de promesa',
          data['promiseTimeMonths'] ?? data['promiseTime'],
          kind: CounterOfferFieldKind.number,
          suffix: ' meses',
          whenMissing: false,
        );
        break;
      default:
        add(
          CounterOfferFieldKey.proposedAmount,
          'Propuesta económica',
          data['proposedAmount'],
          kind: CounterOfferFieldKind.number,
          half: true,
        );
        add(
          CounterOfferFieldKey.estimatedApprovalTime,
          'Tiempo estimado de pago',
          data['estimatedPaymentTime'],
          kind: CounterOfferFieldKind.number,
          suffix: ' meses',
          whenMissing: false,
        );
    }

    add(
      CounterOfferFieldKey.considerations,
      'Solicitud adicional',
      data['considerations'],
      kind: CounterOfferFieldKind.textArea,
    );

    return CounterOfferTerms(
      paymentMethod: normalizedMethod,
      currency: currency,
      fields: fields,
    );
  }

  String get paymentMethodLabel => _paymentMethodLabel(paymentMethod);

  Map<String, dynamic> toCounterOfferPayload(
    Map<CounterOfferFieldKey, String> values, {
    required String selectedCurrency,
  }) {
    final payload = <String, dynamic>{
      if (paymentMethod != 'renta')
        'paymentMethod': switch (paymentMethod) {
          'hipoteca' => 'mortgage',
          'promesa' => 'purchase_promise',
          _ => 'cash',
        },
      'currency': selectedCurrency,
    };

    for (final field in fields) {
      final value = (values[field.key] ?? field.value).trim();
      switch (field.key) {
        case CounterOfferFieldKey.paymentMethod:
          // Es una etiqueta de lectura; el instrumento ya viaja arriba.
          break;
        case CounterOfferFieldKey.proposedAmount:
          payload['proposedAmount'] = _parseNumber(value);
        case CounterOfferFieldKey.bankName:
          payload['bankName'] = value;
        case CounterOfferFieldKey.downPaymentPercentage:
          payload['downPaymentPercentage'] = _parseNumber(value);
        case CounterOfferFieldKey.creditStatus:
          payload['creditStatus'] = value;
        case CounterOfferFieldKey.estimatedApprovalTime:
          if (paymentMethod == 'contado') {
            payload['estimatedPaymentTime'] = _parseNumber(value);
          } else {
            payload['estimatedApprovalTime'] = _parseNumber(value);
          }
        case CounterOfferFieldKey.initialReserve:
          payload['initialReserve'] = _parseNumber(value);
        case CounterOfferFieldKey.finalPayment:
          payload['finalPayment'] = _parseNumber(value);
        case CounterOfferFieldKey.promiseTimeMonths:
          payload['promiseTimeMonths'] = _parseNumber(value);
        case CounterOfferFieldKey.contractStartDate:
          payload['contractStartDate'] = value;
        case CounterOfferFieldKey.contractEndDate:
          payload['contractEndDate'] = value;
        case CounterOfferFieldKey.propertyUse:
          payload['propertyUse'] = value;
        case CounterOfferFieldKey.considerations:
          payload['considerations'] = value;
      }
    }
    return payload;
  }
}

class ClientCounterOfferDetail {
  final String offerId;
  final String offerType;
  final CounterOfferTerms originalTerms;
  final CounterOfferTerms ownerTerms;
  final bool canResolve;
  final bool isRejected;
  final String rejectionReason;

  const ClientCounterOfferDetail({
    required this.offerId,
    required this.offerType,
    required this.originalTerms,
    required this.ownerTerms,
    required this.canResolve,
    required this.isRejected,
    required this.rejectionReason,
  });

  factory ClientCounterOfferDetail.fromJson(Map<String, dynamic> json) {
    final offer = ClientOffer.fromJson(json);
    final original = offerAsMap(json['originalOfferData']) ??
        offerAsMap(json['offerData']) ??
        const <String, dynamic>{};
    final owner = offerAsMap(json['counterOfferData']) ??
        offerAsMap(json['counterOffer']) ??
        offerAsMap(json['activeOfferData']) ??
        const <String, dynamic>{};

    return ClientCounterOfferDetail(
      offerId: offer.offerId,
      offerType: offer.offerType,
      originalTerms: CounterOfferTerms.fromJson(
        original,
        offerType: offer.offerType,
      ),
      ownerTerms: CounterOfferTerms.fromJson(
        owner,
        offerType: offer.offerType,
      ),
      canResolve: offer.awaitsClientResponse,
      isRejected: offer.isTerminal,
      rejectionReason: offer.rejectionReason,
    );
  }
}

String _paymentMethodLabel(String normalized) {
  switch (normalized) {
    case 'hipoteca':
      return 'Hipoteca';
    case 'promesa':
      return 'Promesa de compra';
    case 'renta':
      return 'Renta';
    default:
      return 'Contado';
  }
}

String _normalizePaymentMethod(String raw) {
  final value = raw.toLowerCase();
  if (value.contains('mortgage') || value.contains('hipoteca')) {
    return 'hipoteca';
  }
  if (value.contains('promise') || value.contains('promesa')) {
    return 'promesa';
  }
  return 'contado';
}

num? _parseNumber(String value) {
  final sanitized =
      value.replaceAll(RegExp(r'[^0-9,.-]'), '').replaceAll(',', '');
  return num.tryParse(sanitized);
}
