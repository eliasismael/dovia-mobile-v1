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
}
