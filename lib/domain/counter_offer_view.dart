// Las dos propuestas enfrentadas en la pantalla "Contraoferta": la que el
// cliente envió y la que el propietario devolvió.
//
// El diseño arma cada sección con distintos campos según el método de pago
// negociado, así que el reparto se resuelve acá y la pantalla sólo dibuja la
// lista que le toca. La sección de arriba es referencia congelada; la de abajo
// es la que el cliente puede reescribir al contraofertar.

import 'client_offer_detail.dart';
import 'client_offer_models.dart';
import 'offer_json.dart';
import 'offer_credit_status.dart';

const String _empty = '—';

/// Campos que el cliente puede reescribir al contraofertar, según el método de
/// pago. Son exactamente los que acepta `POST /offers/{id}/counter-offer`.
///
/// "Pago final" queda fuera a propósito: el diseño lo muestra en la promesa de
/// compra pero el DTO no lo recibe, así que se lee y no se edita.
enum CounterOfferInput {
  proposedAmount,
  bankName,
  downPaymentPercentage,
  initialReserve,
  promiseTimeMonths,
  considerations,
}

extension CounterOfferInputX on CounterOfferInput {
  /// Clave del `counterOfferData`.
  String get apiKey {
    switch (this) {
      case CounterOfferInput.proposedAmount:
        return 'proposedAmount';
      case CounterOfferInput.bankName:
        return 'bankName';
      case CounterOfferInput.downPaymentPercentage:
        return 'downPaymentPercentage';
      case CounterOfferInput.initialReserve:
        return 'initialReserve';
      case CounterOfferInput.promiseTimeMonths:
        return 'promiseTimeMonths';
      case CounterOfferInput.considerations:
        return 'considerations';
    }
  }

  /// El backend espera número en todo lo económico.
  bool get isNumeric =>
      this != CounterOfferInput.bankName &&
      this != CounterOfferInput.considerations;
}

/// Una fila de la sección del propietario: lo que muestra y, si el cliente
/// contraoferta, qué campo del DTO reescribe.
class CounterOfferRow {
  final OfferDetailField field;
  final CounterOfferInput? input;

  /// Valor sin formatear, para arrancar el campo editable: en el formulario se
  /// escribe `250000`, no `USD 250,000`.
  final String rawValue;

  const CounterOfferRow(this.field, {this.input, this.rawValue = ''});

  bool get isEditable => input != null;
}

/// Las dos propuestas, listas para dibujar.
class CounterOfferView {
  /// `mortgage` | `cash` | `purchase_promise`, el discriminador del DTO.
  final String paymentMethodApiValue;

  final String currency;

  /// Lo que envió el cliente: referencia congelada, en gris.
  final List<OfferDetailField> mine;

  /// Lo que devolvió el propietario, y qué se puede reescribir encima.
  final List<CounterOfferRow> theirs;

  /// El propietario todavía no respondió: no hay nada que comparar.
  final bool hasCounterOffer;

  const CounterOfferView({
    required this.paymentMethodApiValue,
    required this.currency,
    required this.mine,
    required this.theirs,
    required this.hasCounterOffer,
  });

  factory CounterOfferView.fromJson(Map<String, dynamic> offerJson) {
    final offer = ClientOffer.fromJson(offerJson);
    final original = offerAsMap(offerJson['originalOfferData']) ??
        offerAsMap(offerJson['offerData']) ??
        offerJson;
    final counter = offerAsMap(offerJson['counterOfferData']) ??
        offerAsMap(offerJson['counterOffer']);

    final method = offer.normalizedPaymentMethod;
    final currency = _currencyLabel(original);

    return CounterOfferView(
      paymentMethodApiValue: _apiPaymentMethod(method),
      currency: currency,
      mine: _mineFields(original, method, currency),
      theirs: _theirsRows(counter ?? const {}, method, _currencyLabel(counter)),
      hasCounterOffer: counter != null && counter.isNotEmpty,
    );
  }

  /// Valores de arranque del formulario de contraoferta: lo último propuesto.
  Map<CounterOfferInput, String> get initialInputs => {
        for (final row in theirs)
          if (row.input != null) row.input!: row.rawValue,
      };
}

List<OfferDetailField> _mineFields(
  Map<String, dynamic> data,
  String method,
  String currency,
) {
  final amount = _amount(data, currency);

  switch (method) {
    case 'hipoteca':
      return [
        OfferDetailField('Método de pago', 'Hipoteca', half: true),
        OfferDetailField('Banco', _str(data['bankName']), half: true),
        OfferDetailField('Propuesta económica', amount, half: true),
        OfferDetailField('Enganche', _percent(data['downPaymentPercentage']),
            half: true),
        OfferDetailField('Estado del crédito', _creditStatus(data), half: true),
        OfferDetailField('Moneda de pago', currency,
            kind: OfferDetailFieldKind.currency, half: true),
        OfferDetailField('Solicitud adicional', _str(data['considerations']),
            kind: OfferDetailFieldKind.textArea),
      ];
    case 'promesa':
      return [
        OfferDetailField('Método de pago', 'Promesa de compra'),
        OfferDetailField('Propuesta económica', amount),
        OfferDetailField(
            'Reserva inicial', _money(data['initialReserve'], currency),
            half: true),
        OfferDetailField('Pago final', _money(data['finalPayment'], currency),
            half: true),
        OfferDetailField('Moneda de pago', currency,
            kind: OfferDetailFieldKind.currency, half: true),
        OfferDetailField('Solicitud adicional', _str(data['considerations']),
            kind: OfferDetailFieldKind.textArea),
      ];
    default:
      return [
        OfferDetailField('Método de pago', 'Contado', half: true),
        OfferDetailField('Propuesta económica', amount, half: true),
        OfferDetailField('Moneda de pago', currency,
            kind: OfferDetailFieldKind.currency, half: true),
        OfferDetailField('Solicitud adicional', _str(data['considerations']),
            kind: OfferDetailFieldKind.textArea),
      ];
  }
}

List<CounterOfferRow> _theirsRows(
  Map<String, dynamic> data,
  String method,
  String currency,
) {
  final amount = _amount(data, currency);
  final considerations = CounterOfferRow(
    OfferDetailField('Solicitud adicional', _str(data['considerations']),
        kind: OfferDetailFieldKind.textArea),
    input: CounterOfferInput.considerations,
    rawValue: offerStr(data['considerations']) ?? '',
  );

  switch (method) {
    case 'hipoteca':
      return [
        CounterOfferRow(
            OfferDetailField('Método de pago', 'Hipoteca', half: true)),
        CounterOfferRow(
          OfferDetailField('Banco', _str(data['bankName']), half: true),
          input: CounterOfferInput.bankName,
          rawValue: offerStr(data['bankName']) ?? '',
        ),
        CounterOfferRow(
          OfferDetailField('Propuesta económica', amount, half: true),
          input: CounterOfferInput.proposedAmount,
          rawValue: _raw(data['proposedAmount']),
        ),
        CounterOfferRow(
          OfferDetailField('Enganche', _percent(data['downPaymentPercentage']),
              half: true),
          input: CounterOfferInput.downPaymentPercentage,
          rawValue: _raw(data['downPaymentPercentage']),
        ),
        considerations,
      ];
    case 'promesa':
      return [
        CounterOfferRow(OfferDetailField('Método de pago', 'Promesa de compra',
            half: true)),
        CounterOfferRow(
          OfferDetailField('Propuesta económica', amount, half: true),
          input: CounterOfferInput.proposedAmount,
          rawValue: _raw(data['proposedAmount']),
        ),
        CounterOfferRow(
          OfferDetailField(
              'Reserva inicial', _money(data['initialReserve'], currency),
              half: true),
          input: CounterOfferInput.initialReserve,
          rawValue: _raw(data['initialReserve']),
        ),
        CounterOfferRow(
          OfferDetailField('Pago final', _money(data['finalPayment'], currency),
              half: true),
        ),
        considerations,
      ];
    default:
      return [
        CounterOfferRow(
            OfferDetailField('Método de pago', 'Contado', half: true)),
        CounterOfferRow(
          OfferDetailField('Propuesta económica', amount, half: true),
          input: CounterOfferInput.proposedAmount,
          rawValue: _raw(data['proposedAmount']),
        ),
        considerations,
      ];
  }
}

/// Valor crudo para prellenar el formulario.
String _raw(dynamic value) => offerStr(value) ?? '';

String _apiPaymentMethod(String normalized) {
  switch (normalized) {
    case 'hipoteca':
      return 'mortgage';
    case 'promesa':
      return 'purchase_promise';
    default:
      return 'cash';
  }
}

String _str(dynamic value) => offerStr(value) ?? _empty;

String _currencyLabel(Map<String, dynamic>? data) {
  final raw = (offerStr(data?['currency']) ?? 'USD').toUpperCase();
  return raw == 'GTQ' || raw == 'QUETZALES' ? 'Quetzales' : raw;
}

String _amount(Map<String, dynamic> data, String currency) =>
    _money(data['proposedAmount'], currency);

String _money(dynamic value, String currency) {
  final amount = offerNum(value);
  if (amount == null) return _empty;
  final formatted = amount.truncateToDouble() == amount
      ? amount
          .toInt()
          .toString()
          .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')
      : amount.toStringAsFixed(2);
  return '$currency $formatted';
}

String _percent(dynamic value) {
  final raw = offerStr(value);
  return raw == null ? _empty : '$raw%';
}

String _creditStatus(Map<String, dynamic> data) {
  final raw = offerStr(data['creditStatus']);
  return creditStatusLabel(raw) ?? raw ?? _empty;
}
