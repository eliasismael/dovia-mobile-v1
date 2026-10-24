import 'package:dovia/auth/post_login_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _profile(List<String> roles) => {
      'data': {'roles': roles},
    };

void main() {
  group('hasAdminRole', () {
    test('detecta al administrador', () {
      expect(hasAdminRole(_profile(['HQ_ADMIN'])), isTrue);
    });

    test('detecta al administrador con otro rol', () {
      expect(hasAdminRole(_profile(['CLIENT', 'HQ_ADMIN'])), isTrue);
    });

    test('el resto de los roles entra a la app', () {
      expect(hasAdminRole(_profile(['CLIENT'])), isFalse);
      expect(hasAdminRole(_profile(['HOME_ASSOCIATE'])), isFalse);
      expect(hasAdminRole(_profile([])), isFalse);
      expect(hasAdminRole(null), isFalse);
    });
  });

  testWidgets('el aviso indica entrar desde la web', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showAdminWebOnlyDialog(context),
          child: const Text('abrir'),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa desde la web'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa desde la web'), findsNothing);
  });
}
