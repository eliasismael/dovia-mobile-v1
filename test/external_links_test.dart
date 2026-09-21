import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/core/external_links.dart';

void main() {
  group('whatsAppUri', () {
    test('deja el número en dígitos, como espera wa.me', () {
      expect(whatsAppUri('+502 5555 5555').toString(),
          'https://wa.me/50255555555');
      expect(whatsAppUri('(502) 5555-5555').toString(),
          'https://wa.me/50255555555');
    });

    test('sin dígitos no hay chat que abrir', () {
      expect(whatsAppUri(''), isNull);
      expect(whatsAppUri('   '), isNull);
      expect(whatsAppUri('sin numero'), isNull);
    });
  });

  group('telUri', () {
    test('arma la llamada por partes, no parseando texto', () {
      // `Uri.parse('tel:+502 5555 5555')` se rompe con el espacio.
      final uri = telUri('+502 5555 5555')!;
      expect(uri.scheme, 'tel');
      // `Uri.path` devuelve el componente ya codificado, así que el espacio
      // viaja como %20; lo que importa es que el número llegue entero.
      expect(Uri.decodeComponent(uri.path), '+502 5555 5555');
    });

    test('sin número no hay llamada', () {
      expect(telUri(''), isNull);
      expect(telUri('  '), isNull);
    });
  });

  group('openExternalUri', () {
    test('un enlace nulo no intenta abrir nada', () async {
      expect(await openExternalUri(null), isFalse);
    });
  });
}
