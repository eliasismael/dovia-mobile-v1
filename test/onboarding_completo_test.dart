import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/auth/post_login_navigation.dart';

void main() {
  group('profileMissingIdentification', () {
    test('perfil sin identificación (p. ej. registrado con Google)', () {
      expect(
        profileMissingIdentification({
          'data': {
            'id': 'u1',
            'roles': ['CLIENT'],
          },
        }),
        isTrue,
      );
      expect(
        profileMissingIdentification({
          'data': {'id': 'u1', 'identificationDocumentUrl': '  '},
        }),
        isTrue,
      );
    });

    test('perfil con identificación', () {
      expect(
        profileMissingIdentification({
          'data': {
            'id': 'u1',
            'identificationDocumentUrl': 'https://s3/dpi.jpg',
          },
        }),
        isFalse,
      );
      expect(
        profileMissingIdentification({
          'data': {'id': 'u1', 'identificationUrl': 'https://s3/dpi.jpg'},
        }),
        isFalse,
      );
    });

    test('sin perfil no manda al onboarding', () {
      expect(profileMissingIdentification(null), isFalse);
      expect(profileMissingIdentification({'message': 'error'}), isFalse);
    });
  });
}
