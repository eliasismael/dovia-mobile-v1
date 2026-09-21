import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/offer_credit_status.dart';

void main() {
  group('Estado del crédito', () {
    test('ofrece los tres valores del contrato, en orden', () {
      expect(kCreditStatusValues, ['approved', 'in_process', 'not_started']);
    });

    test('el desplegable muestra las etiquetas en español', () {
      expect(creditStatusLabels, ['Aprobado', 'En proceso', 'No iniciado']);
    });

    test('traduce cada valor del contrato a su etiqueta', () {
      expect(creditStatusLabel('approved'), 'Aprobado');
      expect(creditStatusLabel('in_process'), 'En proceso');
      expect(creditStatusLabel('not_started'), 'No iniciado');
    });

    test('acepta el valor en mayúsculas, como puede llegar del backend', () {
      expect(creditStatusLabel('APPROVED'), 'Aprobado');
    });

    test('un valor fuera del enum no tiene etiqueta', () {
      expect(creditStatusLabel('preaprobado'), isNull);
      expect(creditStatusLabel(null), isNull);
    });

    test('la etiqueta elegida vuelve al valor que espera la API', () {
      for (final value in kCreditStatusValues) {
        expect(creditStatusValueFromLabel(creditStatusLabel(value)), value);
      }
    });

    test('sin elección no hay valor que mandar', () {
      expect(creditStatusValueFromLabel(null), isNull);
      expect(creditStatusValueFromLabel(''), isNull);
    });
  });
}
