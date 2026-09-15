import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_offer_detail.dart' show unwrapPropertyJson;
import 'package:dovia/domain/offer_json.dart';

/// Forma real de `GET /properties/{id}`: la propiedad cuelga de `data`, sin el
/// segundo nivel que suponen los getters generados por FlutterFlow.
Map<String, dynamic> _response() => {
      'success': true,
      'status_code': 200,
      'data': {
        'id': '019eb7ed-2286-70ce-bbcc-6b927171331b',
        'name': 'Departamento Polanco Masaryk',
        'listingType': ['SALE', 'RENT'],
        'price': 38000,
        'saleInfo': {'salePrice': 9800000, 'maintenanceFee': 3800},
        'rentInfo': {
          'monthlyRent': 38000,
          'rentalConditions': {
            'minimumTime': 12,
            'others': 'Se requieren 2 meses de depósito',
            'allowedUses': 'Vivienda personal',
            'notAllowedUses': 'Airbnb y subarrendamiento',
          },
        },
        'infoHQ': {'showingConsiderations': 'Avisar con 24 horas'},
      },
    };

void main() {
  group('Características que proporcionó el propietario', () {
    test('desenvuelve la respuesta real, con un solo nivel de data', () {
      final property = unwrapPropertyJson(_response());

      expect(property?['name'], 'Departamento Polanco Masaryk');
    });

    test('sigue aceptando la forma anidada {data: {data: ...}}', () {
      final nested = {
        'data': {'data': _response()['data']}
      };

      expect(unwrapPropertyJson(nested)?['name'],
          'Departamento Polanco Masaryk');
    });

    test('lee el precio de venta y el de renta', () {
      final property = unwrapPropertyJson(_response());

      expect(
        propertyPathValue(property, const ['saleInfo.salePrice', 'price']),
        9800000,
      );
      expect(
        propertyPathValue(property, const ['rentInfo.monthlyRent', 'price']),
        38000,
      );
    });

    test('lee usos permitidos, no permitidos y consideraciones', () {
      final property = unwrapPropertyJson(_response());

      expect(
        propertyPathValue(property, const [
          'rentInfo.rentalConditions.allowedUses',
          'conditions.allowedUses',
        ]),
        'Vivienda personal',
      );
      expect(
        propertyPathValue(property, const [
          'rentInfo.rentalConditions.notAllowedUses',
          'conditions.notAllowedUses',
        ]),
        'Airbnb y subarrendamiento',
      );
      expect(
        propertyPathValue(property, const [
          'infoHQ.showingConsiderations',
          'rentInfo.rentalConditions.others',
        ]),
        'Avisar con 24 horas',
      );
    });

    test('cae al alias siguiente cuando la ruta preferida no está', () {
      final property = unwrapPropertyJson(_response());
      (property?['infoHQ'] as Map).remove('showingConsiderations');

      expect(
        propertyPathValue(property, const [
          'infoHQ.showingConsiderations',
          'rentInfo.rentalConditions.others',
        ]),
        'Se requieren 2 meses de depósito',
      );
    });

    test('devuelve null cuando ninguna ruta trae dato', () {
      final property = unwrapPropertyJson(_response());

      expect(
        propertyPathValue(property, const ['infoHQ.inexistente', 'tampoco']),
        isNull,
      );
    });
  });
}
