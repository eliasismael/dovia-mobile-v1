import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/shared_components/app_tutorial/app_tutorial.dart';

void main() {
  testWidgets('dos llamadas a la vez muestran un solo tutorial',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        ctx = context;
        return const SizedBox.expand();
      }),
    ));

    const steps = [
      TutorialStep(title: 'Uno', text: 'Primer paso'),
      TutorialStep(title: 'Dos', text: 'Segundo paso'),
    ];
    final first = AppTutorial.show(ctx, steps);
    final second = AppTutorial.show(ctx, steps);
    await tester.pumpAndSettle();

    expect(await second, isFalse);
    expect(find.text('Uno'), findsOneWidget);

    await tester.tap(find.text('Omitir tutorial'));
    await tester.pumpAndSettle();
    expect(await first, isTrue);
    expect(find.text('Uno'), findsNothing);

    // Cerrado el primero, se puede volver a mostrar.
    final again = AppTutorial.show(ctx, steps);
    await tester.pumpAndSettle();
    expect(find.text('Uno'), findsOneWidget);
    await tester.tap(find.text('Omitir tutorial'));
    await tester.pumpAndSettle();
    expect(await again, isTrue);
  });
}
