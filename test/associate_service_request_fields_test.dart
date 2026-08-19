import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/associate_service_request_fields.dart';

void main() {
  group('asrLatitude / asrLongitude', () {
    test('lee coordenadas anidadas en address.coordinates', () {
      final data = {
        'address': {
          'coordinates': {'latitude': 14.634915, 'longitude': -90.506882},
        },
      };

      expect(asrLatitude(data), 14.634915);
      expect(asrLongitude(data), -90.506882);
    });

    test('cae en serviceAddress cuando no hay address', () {
      final data = {
        'serviceAddress': {
          'coordinates': {'lat': 20.0, 'lng': -100.0},
        },
      };

      expect(asrLatitude(data), 20.0);
      expect(asrLongitude(data), -100.0);
    });

    test('null cuando la solicitud no trae coordenadas', () {
      final data = {'address': {'address': 'Calle Falsa 123'}};

      expect(asrLatitude(data), isNull);
      expect(asrLongitude(data), isNull);
    });
  });

  group('asrCategoryName / asrCategoryScope', () {
    test('lee la categoria elegida por el cliente', () {
      final data = {
        'selectedCategory': {
          'id': '018f6f11-0001-7000-8000-000000000001',
          'name': 'Reparacion de fugas',
          'description': 'en tuberias o conexiones visibles, de 2 a 3 fugas.',
        },
      };

      expect(asrCategoryName(data), 'Reparacion de fugas');
      expect(
        asrCategoryScope(data),
        'Reparacion de fugas: en tuberias o conexiones visibles, de 2 a 3 fugas.',
      );
    });

    test('null en las solicitudes anteriores al cambio de contrato', () {
      final data = {'categoryId': null, 'selectedCategory': null};

      expect(asrCategoryName(data), isNull);
      expect(asrCategoryScope(data), isNull);
    });
  });

  group('asrWhatToBring', () {
    test('arma la lista con lo que el catalogo dice que lleva el tecnico', () {
      final data = {
        'serviceDetail': {
          'technicianBrings': [
            'Herramientas manuales para trabajos de plomeria.',
            'Equipo para diagnostico de fugas.',
          ],
        },
      };

      expect(
        asrWhatToBring(data),
        '- Herramientas manuales para trabajos de plomeria.\n'
        '- Equipo para diagnostico de fugas.',
      );
    });

    test('null cuando el servicio no declara que llevar', () {
      final data = {
        'serviceDetail': {'technicianBrings': <dynamic>[]},
      };

      expect(asrWhatToBring(data), isNull);
    });
  });
}
