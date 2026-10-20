import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/custom_code/widgets/dovia_client_house_card.dart';
import 'package:dovia/dovia_client/app/principal/new_projects.dart';

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

    test('el precio va en USD y "desde"; sin precio, por confirmar', () {
      expect(NewProject.fromJson(_project())!.priceLabel, 'Desde US\$ 350.000');
      expect(NewProject.fromJson(_project(salePrice: 0))!.priceLabel,
          'Precio por confirmar');
    });

    test('sin salePrice usa el price general', () {
      final json = _project(salePrice: null)..['price'] = 120000;
      expect(NewProject.fromJson(json)!.priceLabel, 'Desde US\$ 120.000');
    });
  });

  testWidgets('la tarjeta muestra el precio armado y "—" en lo que falta',
      (tester) async {
    final project = NewProject.fromJson(_project())!;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DoviaClientHouseCard(
          width: 210,
          imageUrl: '',
          name: project.name,
          priceLabel: project.priceLabel,
          landArea: project.landArea,
          constructionArea: project.constructionArea,
          bedrooms: project.bedrooms,
          bathrooms: project.bathrooms,
          dashEmptySpecs: true,
          showFavorite: false,
        ),
      ),
    ));
    expect(find.text('Desde US\$ 350.000'), findsOneWidget);
    expect(find.text('85 M2'), findsOneWidget);
    expect(find.text('2 Hab.'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
  });
}
