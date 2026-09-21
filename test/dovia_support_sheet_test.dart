import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/shared_components/dovia_support/dovia_support_widget.dart';

/// Reproduce la hoja tal como la abre Ajustes: limitada al 70 % del alto de
/// la pantalla. Las otras pantallas la abren sin ese tope.
Future<void> _pumpSheet(
  WidgetTester tester, {
  required double logicalHeight,
  double? maxHeightFactor,
}) async {
  tester.view.physicalSize = Size(390 * 3, logicalHeight * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: maxHeightFactor == null
                ? const BoxConstraints()
                : BoxConstraints(maxHeight: logicalHeight * maxHeightFactor),
            child: const DoviaSupportWidget(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  for (final height in const [667.0, 800.0, 930.0]) {
    testWidgets('la hoja de soporte no desborda al 70% en $height dp',
        (tester) async {
      await _pumpSheet(tester, logicalHeight: height, maxHeightFactor: 0.7);

      expect(find.text('¡Hola!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // La barra flotante quedaba fuera de la hoja, en la franja desbordada.
      expect(tester.getRect(find.text('Mensajes')).bottom,
          lessThanOrEqualTo(height));
    });

    testWidgets(
        'la hoja de soporte no desborda a pantalla completa en $height dp',
        (tester) async {
      await _pumpSheet(tester, logicalHeight: height);

      expect(find.text('¡Hola!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.text('Mensajes')).bottom,
          lessThanOrEqualTo(height));
    });
  }
}
