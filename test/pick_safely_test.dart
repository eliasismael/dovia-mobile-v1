import 'package:dovia/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> _pumpScaffold(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(builder: (c) {
        context = c;
        return const SizedBox();
      }),
    ),
  ));
  return context;
}

void main() {
  testWidgets('devuelve lo que eligió la persona', (tester) async {
    final context = await _pumpScaffold(tester);

    final result = await pickSafely(() async => 'foto.jpg', context: context);

    expect(result, 'foto.jpg');
  });

  testWidgets('sin permiso devuelve null y avisa cómo resolverlo',
      (tester) async {
    final context = await _pumpScaffold(tester);

    final result = await pickSafely<String>(
      () async => throw PlatformException(code: 'camera_access_denied'),
      context: context,
    );
    await tester.pump();

    expect(result, isNull);
    expect(find.textContaining('Revisá los permisos'), findsOneWidget);
  });

  testWidgets('sin context no avisa ni lanza', (tester) async {
    final result = await pickSafely<String>(
      () async => throw PlatformException(code: 'photo_access_denied'),
    );

    expect(result, isNull);
  });

  testWidgets('otros errores no se esconden', (tester) async {
    expect(
      () => pickSafely<String>(() async => throw StateError('bug')),
      throwsStateError,
    );
  });
}
