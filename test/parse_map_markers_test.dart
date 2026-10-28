import 'package:dovia/flutter_flow/custom_functions.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _property({
  String id = 'p1',
  Object? coordinates = const [-90.51, 14.6],
  Object? listingType = const ['sale'],
  Object? price = 250000,
  Object? features,
}) =>
    {
      'id': id,
      'name': 'Casa $id',
      'location': {
        'geo': {'coordinates': coordinates}
      },
      'listingType': listingType,
      'price': price,
      'propertyType': 'house',
      'isFavorite': true,
      'features': features,
    };

void main() {
  test('convierte una propiedad completa', () {
    final markers = parseMapMarkers({
      'data': [
        _property(features: {
          'general': {
            'landArea': 120,
            'bedrooms': 3,
            'bathrooms': 2.0,
            'constructionArea': 95.5,
          }
        }),
      ],
    });

    expect(markers, hasLength(1));
    final m = markers.single;
    expect(m.id, 'p1');
    expect(m.name, 'Casa p1');
    expect(m.longitude, -90.51);
    expect(m.latitude, 14.6);
    expect(m.price, 250000);
    expect(m.listingType, 'sale');
    expect(m.propertyType, 'house');
    expect(m.isFavorite, isTrue);
    expect(m.landArea, 120);
    expect(m.bedrooms, 3);
    expect(m.bathrooms, 2);
    expect(m.constructionArea, 95.5);
  });

  test('descarta las propiedades incompletas sin perder las demás', () {
    final markers = parseMapMarkers({
      'data': [
        _property(id: 'ok1'),
        _property(id: 'sinPrecio', price: null),
        _property(id: 'sinUbicacion', coordinates: null),
        _property(id: 'coordsCortas', coordinates: [-90.5]),
        _property(id: 'sinOperacion', listingType: const []),
        _property(id: 'operacionNula', listingType: null),
        _property(id: 'precioTexto', price: '250000'),
        {
          'id': 'sinLocation',
          'price': 1,
          'listingType': ['rent']
        },
        'no es un mapa',
        _property(id: 'ok2', features: {'general': 'raro'}),
      ],
    });

    expect(markers.map((m) => m.id), ['ok1', 'ok2']);
  });

  test('sin features deja los datos generales vacíos', () {
    final m = parseMapMarkers({
      'data': [_property()]
    }).single;
    expect(m.hasBedrooms(), isFalse);
    expect(m.hasLandArea(), isFalse);
  });

  test('una respuesta sin lista devuelve una lista vacía', () {
    expect(parseMapMarkers(null), isEmpty);
    expect(parseMapMarkers(''), isEmpty);
    expect(parseMapMarkers({'data': null}), isEmpty);
    expect(parseMapMarkers({'data': 'x'}), isEmpty);
  });
}
