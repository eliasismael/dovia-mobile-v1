import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_client/service_request_fields.dart';

void main() {
  group('srIsPaid', () {
    test('true cuando payment.status es PAID', () {
      final data = {
        'payment': {'status': 'PAID'},
      };
      expect(srIsPaid(data), isTrue);
    });

    test('true cuando la orden de pago quedó SUCCEEDED', () {
      final data = {
        'paymentOrder': {'status': 'SUCCEEDED'},
      };
      expect(srIsPaid(data), isTrue);
    });

    test('false sin payment o con un estado no pagado', () {
      expect(srIsPaid(const {}), isFalse);
      expect(
        srIsPaid({
          'payment': {'status': 'PENDING'},
        }),
        isFalse,
      );
    });
  });

  group('srPriceAmount / srPriceCurrency', () {
    test('lee price.price.gtq, el monto que exige el checkout custom', () {
      final data = {
        'price': {
          'price': {'gtq': 449.99, 'currency': 'GTQ'},
        },
      };
      expect(srPriceAmount(data), 449.99);
      expect(srPriceCurrency(data), 'GTQ');
    });

    test('cae en price.gtq cuando no hay un objeto anidado', () {
      final data = {
        'price': {'gtq': 600},
      };
      expect(srPriceAmount(data), 600);
    });

    test('null cuando la solicitud no trae precio', () {
      expect(srPriceAmount(const {}), isNull);
    });

    test('GTQ por default cuando no hay moneda explícita', () {
      expect(srPriceCurrency(const {}), 'GTQ');
    });
  });

  group('srSubscriberPriceAmount', () {
    test('lee el monto con descuento cuando el backend lo expone', () {
      final data = {
        'price': {'subscriberGtq': 314.99},
      };
      expect(srSubscriberPriceAmount(data), 314.99);
    });

    test('null cuando el backend no expone precio de suscriptor', () {
      final data = {
        'price': {
          'price': {'gtq': 449.99},
        },
      };
      expect(srSubscriberPriceAmount(data), isNull);
    });
  });

  group('srBasePriceAmount / srPlanDiscount', () {
    test('deriva ahorro y porcentaje del precio de lista y el aplicable', () {
      final data = {
        'price': {
          'baseGtq': 600,
          'price': {'gtq': 390},
        },
      };

      expect(srBasePriceAmount(data), 600);
      final discount = srPlanDiscount(data);
      expect(discount, isNotNull);
      expect(discount!.savings, 210);
      expect(discount.percentOff, 35);
    });

    test('null cuando el backend no expone precio de lista', () {
      final data = {
        'price': {
          'price': {'gtq': 600},
        },
      };

      expect(srBasePriceAmount(data), isNull);
      expect(srPlanDiscount(data), isNull);
    });

    test('null cuando el precio de lista no supera al que se cobra: sin plan '
        'no hay descuento que anunciar', () {
      final data = {
        'price': {
          'baseGtq': 600,
          'price': {'gtq': 600},
        },
      };

      expect(srPlanDiscount(data), isNull);
    });
  });

  group('srFormatAmount', () {
    test('GTQ se formatea con prefijo Q y separador de miles', () {
      expect(srFormatAmount(449.99, 'GTQ'), 'Q449.99');
      expect(srFormatAmount(1200, 'GTQ'), 'Q1,200');
    });

    test('otra moneda antepone el código en vez de Q', () {
      expect(srFormatAmount(10, 'USD'), 'USD 10');
    });
  });
}
