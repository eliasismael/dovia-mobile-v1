import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/offer_form_validation.dart';

/// Una compra al contado completa: cada prueba vacía sólo el campo que mira.
OfferFormInput _contado({
  String purchaseAmount = '250000',
  String cashPaymentTime = '3',
  String buyerName = 'Ana Compradora',
  String legalName = '',
  String legalRepresentative = '',
}) =>
    OfferFormInput(
      offerType: 'compra',
      purchaseAmount: purchaseAmount,
      cashPaymentTime: cashPaymentTime,
      buyerName: buyerName,
      legalName: legalName,
      legalRepresentative: legalRepresentative,
    );

OfferFormInput _hipoteca({
  String downPayment = '25',
  String bankName = 'Banco Dovia',
  String bankApprovalTime = '2',
}) =>
    OfferFormInput(
      offerType: 'compra',
      paymentMethod: 'Hipoteca',
      purchaseAmount: '250000',
      buyerName: 'Ana Compradora',
      downPayment: downPayment,
      bankName: bankName,
      bankApprovalTime: bankApprovalTime,
    );

OfferFormInput _promesa({
  String initialReserve = '60000',
  String promiseMonths = '10',
}) =>
    OfferFormInput(
      offerType: 'compra',
      paymentMethod: 'Promesa de compra',
      purchaseAmount: '250000',
      buyerName: 'Ana Compradora',
      initialReserve: initialReserve,
      promiseMonths: promiseMonths,
    );

OfferFormInput _renta({
  String rentAmount = '1500',
  String contractStart = '2026-01-01',
  String contractEnd = '2027-01-01',
  String buyerName = 'Ana Inquilina',
}) =>
    OfferFormInput(
      offerType: 'renta',
      rentAmount: rentAmount,
      contractStart: contractStart,
      contractEnd: contractEnd,
      buyerName: buyerName,
    );

void main() {
  group('Compra al contado', () {
    test('un formulario completo se puede enviar', () {
      expect(validateOfferForm(_contado()), isEmpty);
    });

    test('exige la propuesta economica y el tiempo de pago', () {
      final errors = validateOfferForm(
        _contado(purchaseAmount: '', cashPaymentTime: ''),
      );

      expect(errors[OfferField.purchaseAmount], 'Campo obligatorio');
      expect(errors[OfferField.cashPaymentTime], 'Campo obligatorio');
    });

    test('el tiempo de pago viaja como entero: rechaza decimales', () {
      final errors = validateOfferForm(_contado(cashPaymentTime: '3.5'));

      expect(errors[OfferField.cashPaymentTime], 'Ingresa un número entero');
    });

    test('la propuesta economica admite decimales', () {
      expect(validateOfferForm(_contado(purchaseAmount: '250000.50')), isEmpty);
    });

    test('rechaza texto en la propuesta economica', () {
      final errors = validateOfferForm(_contado(purchaseAmount: 'mucho'));

      expect(errors[OfferField.purchaseAmount], 'Ingresa un número válido');
    });

    test('no pide campos de hipoteca ni de promesa', () {
      final errors = validateOfferForm(_contado(purchaseAmount: ''));

      expect(errors.keys, isNot(contains(OfferField.bankName)));
      expect(errors.keys, isNot(contains(OfferField.initialReserve)));
    });
  });

  group('Compra con hipoteca', () {
    test('un formulario completo se puede enviar', () {
      expect(validateOfferForm(_hipoteca()), isEmpty);
    });

    test('exige enganche, banco y tiempo de aprobacion', () {
      final errors = validateOfferForm(_hipoteca(
        downPayment: '',
        bankName: '',
        bankApprovalTime: '',
      ));

      expect(
        errors.keys,
        containsAll(<String>[
          OfferField.downPayment,
          OfferField.bankName,
          OfferField.bankApprovalTime,
        ]),
      );
    });

    test('el estado de credito es opcional: no bloquea el envio', () {
      // El contrato lo declara opcional y el formulario lo resuelve con un
      // desplegable, asi que no tiene regla propia.
      expect(validateOfferForm(_hipoteca()), isEmpty);
    });

    test('el enganche es un porcentaje entero entre 1 y 100', () {
      expect(
        validateOfferForm(
            _hipoteca(downPayment: '20.5'))[OfferField.downPayment],
        'Ingresa un número entero',
      );
      expect(
        validateOfferForm(
            _hipoteca(downPayment: '120'))[OfferField.downPayment],
        'Debe ser menor o igual a 100',
      );
      expect(
        validateOfferForm(_hipoteca(downPayment: '0'))[OfferField.downPayment],
        'Debe ser mayor o igual a 1',
      );
    });

    test('no pide el tiempo de pago del contado', () {
      expect(
        validateOfferForm(_hipoteca()).keys,
        isNot(contains(OfferField.cashPaymentTime)),
      );
    });
  });

  group('Compra con promesa', () {
    test('un formulario completo se puede enviar', () {
      expect(validateOfferForm(_promesa()), isEmpty);
    });

    test('exige reserva inicial y tiempo de promesa', () {
      final errors = validateOfferForm(
        _promesa(initialReserve: '', promiseMonths: ''),
      );

      expect(errors[OfferField.initialReserve], 'Campo obligatorio');
      expect(errors[OfferField.promiseMonths], 'Campo obligatorio');
    });

    test('el tiempo de promesa viaja como entero', () {
      final errors = validateOfferForm(_promesa(promiseMonths: '10.5'));

      expect(errors[OfferField.promiseMonths], 'Ingresa un número entero');
    });

    test('la reserva inicial admite decimales', () {
      expect(validateOfferForm(_promesa(initialReserve: '60000.75')), isEmpty);
    });

    // El backend rechaza el rango con "El tiempo de la promesa debe estar
    // entre 1 y 36 meses"; el formulario tiene que decirlo antes de enviar.
    group('el tiempo de promesa va de 1 a 36 meses', () {
      const rangeMessage = 'El tiempo debe estar entre 1 y 36 meses';

      test('acepta los dos extremos', () {
        expect(validateOfferForm(_promesa(promiseMonths: '1')), isEmpty);
        expect(validateOfferForm(_promesa(promiseMonths: '36')), isEmpty);
      });

      test('rechaza 37 en adelante', () {
        for (final value in const ['37', '40', '120']) {
          final errors = validateOfferForm(_promesa(promiseMonths: value));
          expect(errors[OfferField.promiseMonths], rangeMessage,
              reason: '"$value" meses');
        }
      });

      test('rechaza 0', () {
        final errors = validateOfferForm(_promesa(promiseMonths: '0'));

        expect(errors[OfferField.promiseMonths], rangeMessage);
      });

      test('vacío sigue siendo "Campo obligatorio", no un error de rango', () {
        final errors = validateOfferForm(_promesa(promiseMonths: '  '));

        expect(errors[OfferField.promiseMonths], 'Campo obligatorio');
      });
    });
  });

  group('Renta', () {
    test('un formulario completo se puede enviar', () {
      expect(validateOfferForm(_renta()), isEmpty);
    });

    test('exige monto mensual y las dos fechas', () {
      final errors = validateOfferForm(
        _renta(rentAmount: '', contractStart: '', contractEnd: ''),
      );

      expect(errors[OfferField.rentAmount], 'Campo obligatorio');
      expect(errors[OfferField.contractStart], 'Campo obligatorio');
      expect(errors[OfferField.contractEnd], 'Campo obligatorio');
    });

    test('el contrato no puede terminar antes de empezar', () {
      final errors = validateOfferForm(
        _renta(contractStart: '2027-01-01', contractEnd: '2026-01-01'),
      );

      expect(
        errors[OfferField.contractEnd],
        'Debe ser posterior a la fecha de inicio',
      );
    });

    test('tampoco puede terminar el mismo dia', () {
      final errors = validateOfferForm(
        _renta(contractStart: '2026-01-01', contractEnd: '2026-01-01'),
      );

      expect(
        errors[OfferField.contractEnd],
        'Debe ser posterior a la fecha de inicio',
      );
    });

    test('no pide nada de la compra', () {
      final errors = validateOfferForm(_renta(rentAmount: ''));

      expect(errors.keys, isNot(contains(OfferField.purchaseAmount)));
      expect(errors.keys, isNot(contains(OfferField.cashPaymentTime)));
    });
  });

  group('Oferta combinada', () {
    test('pide los campos de la renta y los de la compra', () {
      final errors = validateOfferForm(
        const OfferFormInput(offerType: 'ambos', paymentMethod: 'Contado'),
      );

      expect(
        errors.keys,
        containsAll(<String>[
          OfferField.purchaseAmount,
          OfferField.cashPaymentTime,
          OfferField.rentAmount,
          OfferField.contractStart,
          OfferField.contractEnd,
          OfferField.buyerName,
        ]),
      );
    });

    test('completa, se puede enviar', () {
      final errors = validateOfferForm(
        const OfferFormInput(
          offerType: 'ambos',
          paymentMethod: 'Contado',
          purchaseAmount: '250000',
          cashPaymentTime: '3',
          rentAmount: '1500',
          contractStart: '2026-01-01',
          contractEnd: '2027-01-01',
          buyerName: 'Ana Compradora',
        ),
      );

      expect(errors, isEmpty);
    });
  });

  group('Comprador', () {
    test('el nombre es obligatorio en cualquier oferta', () {
      expect(
        validateOfferForm(_contado(buyerName: ''))[OfferField.buyerName],
        'Campo obligatorio',
      );
      expect(
        validateOfferForm(_renta(buyerName: ''))[OfferField.buyerName],
        'Campo obligatorio',
      );
    });

    test('sin razon social no se pide representante legal', () {
      expect(
        validateOfferForm(_contado()).keys,
        isNot(contains(OfferField.legalRepresentative)),
      );
    });

    test('al declarar una empresa, el representante pasa a ser obligatorio',
        () {
      final errors =
          validateOfferForm(_contado(legalName: 'Compras Ana, S.A.'));

      expect(errors[OfferField.legalRepresentative], 'Campo obligatorio');
    });

    test('con representante, la empresa valida', () {
      expect(
        validateOfferForm(_contado(
          legalName: 'Compras Ana, S.A.',
          legalRepresentative: 'Ana Pérez',
        )),
        isEmpty,
      );
    });
  });
}
