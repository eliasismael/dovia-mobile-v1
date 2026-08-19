import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_client/service_catalog.dart';
import 'package:dovia/dovia_home_client/service_request_fields.dart';

void main() {
  group('DoviaHomeServiceCategory', () {
    test('parsea la categoria del catalogo', () {
      final category = DoviaHomeServiceCategory.fromJson({
        'id': '018f6f11-0001-7000-8000-000000000001',
        'name': 'Destape de drenajes',
        'description': 'lavamanos, lavaplatos, inodoro o ducha.',
      });

      expect(category, isNotNull);
      expect(category!.id, '018f6f11-0001-7000-8000-000000000001');
      expect(
        category.scopeLine,
        'Destape de drenajes: lavamanos, lavaplatos, inodoro o ducha.',
      );
    });

    test('descarta lo que no sirve como categoria', () {
      expect(DoviaHomeServiceCategory.fromJson({'name': 'Sin id'}), isNull);
      expect(DoviaHomeServiceCategory.fromJson({'id': 'sin-nombre'}), isNull);
      expect(DoviaHomeServiceCategory.fromJson('texto suelto'), isNull);
    });
  });

  group('DoviaHomeServiceScope.categoryById', () {
    final scope = DoviaHomeServiceScope(
      serviceId: 'servicio-1',
      categories: const [
        DoviaHomeServiceCategory(
          id: 'cat-1',
          name: 'Reparacion de fugas',
          description: '',
        ),
      ],
      technicianBrings: const [],
      notIncluded: const [],
    );

    test('encuentra la categoria elegida', () {
      expect(scope.categoryById('cat-1')?.name, 'Reparacion de fugas');
    });

    test('null cuando no hay seleccion o la categoria ya no esta', () {
      expect(scope.categoryById(null), isNull);
      expect(scope.categoryById('cat-borrada'), isNull);
    });
  });

  group('srCategoryLabel', () {
    test('junta la categoria con su alcance', () {
      final data = {
        'selectedCategory': {
          'id': 'cat-1',
          'name': 'Control de fuga de agua',
          'description': 'contencion de la fuga, de 1 a 2 puntos.',
        },
      };

      expect(
        srCategoryLabel(data),
        'Control de fuga de agua: contencion de la fuga, de 1 a 2 puntos.',
      );
    });

    test('null en las solicitudes historicas, que no traen categoria', () {
      expect(srCategoryLabel({'selectedCategory': null}), isNull);
      expect(srCategoryLabel(<String, dynamic>{}), isNull);
    });
  });
}
