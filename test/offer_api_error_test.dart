import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/offer_json.dart';

void main() {
  group('offerApiErrorMessage', () {
    test('toma el mensaje del primer error y le quita el nombre del DTO', () {
      // Cuerpo real de un rechazo de "Ofertar" con promesa de 40 meses.
      final body = {
        'success': false,
        'status_code': 400,
        'message':
            'Invalid SaleOfferData: El tiempo de la promesa debe estar entre 1 y 36 meses',
        'action_required': 'NONE',
        'data': null,
        'meta': {
          'timestamp': '2026-09-21T21:06:20.315Z',
          'request_id': '526cc8e7-ce77-4f29-8f55-1789eafb54cb',
          'path': '/offers/properties/01a082b9-c6ff-713c-8157-d71becabdfb0',
        },
        'errors': [
          {
            'source': 'VALIDATION',
            'code': 'INVALID_OFFER_DATA',
            'message':
                'Invalid SaleOfferData: El tiempo de la promesa debe estar entre 1 y 36 meses',
            'field': null,
          },
        ],
      };

      expect(
        offerApiErrorMessage(body),
        'El tiempo de la promesa debe estar entre 1 y 36 meses',
      );
    });

    test('nunca deja pasar ids, paths ni el JSON crudo', () {
      final message = offerApiErrorMessage({
        'message': 'Invalid SaleOfferData: Algo falló',
        'meta': {'request_id': 'abc', 'path': '/offers/x'},
      });

      expect(message, 'Algo falló');
      expect(message, isNot(contains('request_id')));
      expect(message, isNot(contains('{')));
    });

    test('sin lista de errores usa el mensaje de la raíz', () {
      expect(
        offerApiErrorMessage({'message': 'Propiedad no disponible'}),
        'Propiedad no disponible',
      );
    });

    test('salta errores sin mensaje hasta dar con uno', () {
      expect(
        offerApiErrorMessage({
          'errors': [
            {'code': 'X'},
            {'message': 'Segundo error'},
          ],
        }),
        'Segundo error',
      );
    });

    test('un mensaje que era sólo el prefijo cae al texto por defecto', () {
      expect(
        offerApiErrorMessage({'message': 'Invalid SaleOfferData: '}),
        'No pudimos enviar tu oferta. Inténtalo de nuevo.',
      );
    });

    test('cuerpos que no son un mapa caen al texto por defecto', () {
      const fallback = 'No pudimos enviar tu oferta. Inténtalo de nuevo.';

      expect(offerApiErrorMessage(null), fallback);
      expect(offerApiErrorMessage('Bad Gateway'), fallback);
      expect(offerApiErrorMessage(<String, dynamic>{}), fallback);
    });

    test('acepta un texto por defecto propio', () {
      expect(offerApiErrorMessage(null, fallback: 'Otro'), 'Otro');
    });
  });
}
