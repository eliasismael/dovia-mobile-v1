import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/counter_offer_view.dart';

Map<String, dynamic> _offer({
  required Map<String, dynamic> original,
  Map<String, dynamic>? counter,
}) =>
    {
      'offerId': 'offer-1',
      'propertyId': 'prop-1',
      'offerType': 'SALE',
      'offerStatus': 'COUNTER_OFFER',
      'originalOfferData': original,
      if (counter != null) 'counterOfferData': counter,
    };

List<String> _labels(CounterOfferView view) =>
    view.mine.map((f) => f.label).toList();

List<String> _theirLabels(CounterOfferView view) =>
    view.theirs.map((r) => r.field.label).toList();

void main() {
  group('Hipoteca', () {
    final view = CounterOfferView.fromJson(_offer(
      original: {
        'paymentMethod': 'mortgage',
        'currency': 'USD',
        'proposedAmount': 250000,
        'bankName': 'Banco Industrial',
        'downPaymentPercentage': 20,
        'creditStatus': 'in_process',
        'considerations': 'Arreglar tubería',
      },
      counter: {
        'paymentMethod': 'mortgage',
        'currency': 'USD',
        'proposedAmount': 270000,
        'bankName': 'Banrural',
        'downPaymentPercentage': 30,
      },
    ));

    test('la referencia lleva los campos del diseño', () {
      expect(_labels(view), [
        'Método de pago',
        'Banco',
        'Propuesta económica',
        'Enganche',
        'Estado del crédito',
        'Moneda de pago',
        'Solicitud adicional',
      ]);
    });

    test('formatea montos, porcentaje y estado del crédito', () {
      final mine = {for (final f in view.mine) f.label: f.value};

      expect(mine['Propuesta económica'], 'USD 250,000');
      expect(mine['Enganche'], '20%');
      expect(mine['Estado del crédito'], 'En proceso');
      expect(mine['Banco'], 'Banco Industrial');
    });

    test('la contraoferta muestra los nuevos términos', () {
      final theirs = {for (final r in view.theirs) r.field.label: r.field.value};

      expect(theirs['Propuesta económica'], 'USD 270,000');
      expect(theirs['Enganche'], '30%');
      expect(theirs['Banco'], 'Banrural');
    });

    test('sólo se reescribe lo que el endpoint acepta', () {
      final editable = view.theirs
          .where((r) => r.isEditable)
          .map((r) => r.input!.apiKey)
          .toList();

      expect(editable, [
        'bankName',
        'proposedAmount',
        'downPaymentPercentage',
        'considerations',
      ]);
      expect(
        view.theirs.firstWhere((r) => r.field.label == 'Método de pago').isEditable,
        isFalse,
        reason: 'el método de pago no se renegocia acá',
      );
    });

    test('el formulario arranca con los valores crudos, no los formateados',
        () {
      expect(view.initialInputs[CounterOfferInput.proposedAmount], '270000');
      expect(view.initialInputs[CounterOfferInput.downPaymentPercentage], '30');
    });
  });

  group('Contado', () {
    final view = CounterOfferView.fromJson(_offer(
      original: {
        'paymentMethod': 'cash',
        'currency': 'USD',
        'proposedAmount': 180000,
      },
      counter: {'paymentMethod': 'cash', 'currency': 'USD', 'proposedAmount': 200000},
    ));

    test('no arrastra campos de hipoteca', () {
      expect(_labels(view), [
        'Método de pago',
        'Propuesta económica',
        'Moneda de pago',
        'Solicitud adicional',
      ]);
      expect(_theirLabels(view), [
        'Método de pago',
        'Propuesta económica',
        'Solicitud adicional',
      ]);
    });

    test('el discriminador viaja como lo espera el backend', () {
      expect(view.paymentMethodApiValue, 'cash');
    });
  });

  group('Promesa de compra', () {
    final view = CounterOfferView.fromJson(_offer(
      original: {
        'paymentMethod': 'purchase_promise',
        'currency': 'GTQ',
        'proposedAmount': 900000,
        'initialReserve': 50000,
        'finalPayment': 850000,
      },
      counter: {
        'paymentMethod': 'purchase_promise',
        'currency': 'GTQ',
        'proposedAmount': 950000,
        'initialReserve': 60000,
        'finalPayment': 890000,
      },
    ));

    test('muestra reserva y pago final', () {
      expect(_theirLabels(view), [
        'Método de pago',
        'Propuesta económica',
        'Reserva inicial',
        'Pago final',
        'Solicitud adicional',
      ]);
    });

    test('el pago final se lee pero no se edita: el DTO no lo recibe', () {
      final pagoFinal =
          view.theirs.firstWhere((r) => r.field.label == 'Pago final');

      expect(pagoFinal.field.value, 'Quetzales 890,000');
      expect(pagoFinal.isEditable, isFalse);
    });

    test('quetzales se muestra con su nombre', () {
      expect(view.currency, 'Quetzales');
      expect(view.paymentMethodApiValue, 'purchase_promise');
    });
  });

  test('sin respuesta del propietario no hay nada que comparar', () {
    final view = CounterOfferView.fromJson(_offer(
      original: {'paymentMethod': 'cash', 'currency': 'USD', 'proposedAmount': 1},
    ));

    expect(view.hasCounterOffer, isFalse);
  });

  test('los campos que faltan se muestran con guion, no vacíos', () {
    final view = CounterOfferView.fromJson(_offer(
      original: {'paymentMethod': 'mortgage', 'currency': 'USD'},
    ));
    final mine = {for (final f in view.mine) f.label: f.value};

    expect(mine['Propuesta económica'], '—');
    expect(mine['Banco'], '—');
    expect(mine['Enganche'], '—');
  });
}
