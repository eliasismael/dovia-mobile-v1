import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/custom_code/widgets/dovia_client_house_card.dart';
import 'package:dovia/dovia_client/app/principal/new_projects.dart';
import 'package:dovia/domain/property_location.dart';

Map<String, dynamic> _project({
  bool isMock = true,
  String? externalId = 'torre-zona-14',
  num? salePrice = 350000,
  Map<String, dynamic>? general,
}) =>
    {
      'id': 'p-1',
      'name': 'Torre Zona 14',
      'image': 'https://img.test/torre.jpg',
      'isMock': isMock,
      'externalId': externalId,
      'propertyType': 'APARTMENT',
      'listingType': 'SALE',
      'saleInfo': {'salePrice': salePrice},
      'features': {
        'general': general ??
            {
              'landArea': 0,
              'constructionArea': 85,
              'bedrooms': 2,
              'bathrooms': 0,
            },
      },
    };

void main() {
  group('Proyectos Nuevos (GET /properties?isMock=true)', () {
    test('toma sólo los del sitio externo: isMock y externalId', () {
      final projects = NewProject.listFrom({
        'data': [
          _project(),
          _project(isMock: false),
          _project(externalId: null),
          _project(externalId: '   '),
        ],
      });
      expect(projects, hasLength(1));
      expect(projects.single.externalId, 'torre-zona-14');
    });

    test('abre la página del proyecto en el sitio de desarrollos', () {
      final project = NewProject.fromJson(_project(externalId: 'torre 14/a'))!;
      expect(
          project.url, 'https://doviaapp.com/proyectos-nuevos/torre%2014%2Fa');
    });

    test('saca el prefijo dovia-new-project- que el sitio no usa en la URL',
        () {
      final project = NewProject.fromJson(
          _project(externalId: 'dovia-new-project-bosques-de-cayala'))!;
      expect(project.url,
          'https://doviaapp.com/proyectos-nuevos/bosques-de-cayala');
    });

    test('el precio va en USD como en la web; sin precio, por confirmar', () {
      expect(NewProject.fromJson(_project())!.priceLabel, 'USD 350,000');
      expect(NewProject.fromJson(_project())!.hasPrice, isTrue);
      expect(NewProject.fromJson(_project(salePrice: 0))!.priceLabel,
          'Precio por confirmar');
    });

    test('sin salePrice usa el price general', () {
      final json = _project(salePrice: null)..['price'] = 120000;
      expect(NewProject.fromJson(json)!.priceLabel, 'USD 120,000');
    });

    test('ubicación: zona y país, o la zona con Guatemala', () {
      expect(
          propertyLocationLabel({
            'location': {
              'address': {'fullAddress': 'Cayalá', 'zone': 'Cayalá'}
            }
          }),
          'Cayalá, Guatemala');
      expect(
          propertyLocationLabel({
            'location': {
              'address': {
                'fullAddress': 'Polanco, Miguel Hidalgo, CDMX',
                'zone': 'Polanco'
              }
            }
          }),
          'Polanco, CDMX');
      expect(
          propertyLocationLabel({
            'location': {
              'address': {'fullAddress': 'Zona 15, Guatemala'}
            }
          }),
          'Zona 15, Guatemala');
      expect(propertyLocationLabel({'location': null}), isNull);
    });
  });

  testWidgets(
      'tarjeta de proyecto: "Precio desde", flecha y "—" en lo que falta',
      (tester) async {
    final project = NewProject.fromJson(_project())!;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DoviaClientHouseCard(
            width: 210,
            imageUrl: '',
            name: project.name,
            type: project.listingType,
            propertyType: project.propertyType,
            priceLabel: project.priceLabel,
            priceCaption: 'Precio desde',
            landArea: project.landArea,
            constructionArea: project.constructionArea,
            bedrooms: project.bedrooms,
            bathrooms: project.bathrooms,
            parkingSpots: project.parkingSpots,
            dashEmptySpecs: true,
            isNewProject: true,
          ),
        ),
      ),
    ));
    expect(find.text('PRECIO DESDE'), findsOneWidget);
    expect(find.text('USD 350,000'), findsOneWidget);
    expect(find.text('APARTAMENTOS'), findsOneWidget);
    expect(find.text('VENTA'), findsOneWidget);
    expect(find.text('85 m²'), findsOneWidget);
    expect(find.text('Desde 2'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    expect(find.byIcon(Icons.north_east), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  testWidgets('tarjeta común: corazón, sin "Precio desde", tipo en singular',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DoviaClientHouseCard(
            width: 160,
            compact: true,
            imageUrl: '',
            name: 'Casa Zona 10',
            type: 'SALE',
            propertyType: 'HOUSE',
            price: '1500000',
            location: 'Zona 10, Guatemala',
            bedrooms: 3,
            parkingSpots: 2,
          ),
        ),
      ),
    ));
    expect(find.text('PRECIO DESDE'), findsNothing);
    expect(find.text('Q 1.500.000'), findsOneWidget);
    expect(find.text('CASA'), findsOneWidget);
    expect(find.text('Zona 10, Guatemala'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.north_east), findsNothing);
  });
}
