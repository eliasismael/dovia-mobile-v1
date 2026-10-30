import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/listing_hq/listing_hq_visit_property.dart';

void main() {
  group('listerHqVisitsFrom', () {
    test('lee la lista en data', () {
      final visits = listerHqVisitsFrom({
        'data': [
          {'id': 'v1'},
          'basura',
        ],
      });
      expect(visits.map((v) => v['id']), ['v1']);
    });

    test('lee la lista paginada en data.data', () {
      final visits = listerHqVisitsFrom({
        'data': {
          'data': [
            {'id': 'v1'},
            {'id': 'v2'},
          ],
          'meta': {'total': 2},
        },
      });
      expect(visits.map((v) => v['id']), ['v1', 'v2']);
    });

    test('sin data devuelve vacío', () {
      expect(listerHqVisitsFrom({'message': 'error'}), isEmpty);
    });
  });

  test('el id de la propiedad sale de propertyId o de propertyInfo', () {
    expect(listerHqVisitPropertyId({'propertyId': 'p1'}), 'p1');
    expect(
        listerHqVisitPropertyId({
          'propertyInfo': {'id': 'p2'},
        }),
        'p2');
    expect(listerHqVisitPropertyId({'id': 'v1'}), '');
  });

  test('con propertyInfo no pide nada al backend', () async {
    final info = {
      'id': 'p1',
      'location': {
        'address': {'fullAddress': '5a Avenida, Zona 10'},
      },
    };
    final property = await listerHqVisitProperty(
        {'propertyId': 'p1', 'propertyInfo': info}, 'token');
    expect(property, same(info));
  });

  test('sin propiedad ni id devuelve null', () async {
    expect(await listerHqVisitProperty({'id': 'v1'}, 'token'), isNull);
  });
}
