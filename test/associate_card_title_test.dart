import 'package:dovia/dovia_home_associate/associate_service_categories.dart';
import 'package:flutter_test/flutter_test.dart';

const _albanileria = AssociateServiceCategory(
  id: 'spec-alb',
  code: 'ALBANILERIA',
  label: 'Albañilería',
  iconPath: 'assets/images/albanileria.svg',
);

Map<String, dynamic> _request(String name, List<String> specialtyIds) => {
      'serviceDetail': {
        'name': name,
        'requiredSpecialtyIds': specialtyIds,
      },
    };

void main() {
  test('la tarjeta suma el oficio al servicio', () {
    expect(
      associateRequestCardTitle(
          _request('Instalación', ['spec-alb']), const [_albanileria]),
      'Instalación · Albañilería',
    );
  });

  test('no repite el oficio si el servicio ya lo nombra', () {
    expect(
      associateRequestCardTitle(
          _request('Albañilería', ['spec-alb']), const [_albanileria]),
      'Albañilería',
    );
  });

  test('sin oficio conocido queda sólo el servicio', () {
    expect(associateRequestCardTitle(_request('Instalación', []), const []),
        'Instalación');
  });
}
