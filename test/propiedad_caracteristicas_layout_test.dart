import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/components/propiedad_caracteristicas_widget.dart';

void main() {
  testWidgets(
      'PropiedadCaracteristicasWidget expandido se arma sin errores de layout',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Captura cada error de layout (no sólo el primero que guarda el tester).
    // Los desbordes de texto se ignoran: en tests la fuente es Ahem, mucho más
    // ancha que la real, y "Pet friendly" / "Permitido para Airbnb" no caben
    // en una línea. Lo que se vigila es el flex sin ancho acotado y su cascada.
    final errors = <String>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('overflowed by')) return;
      errors.add(details.toString());
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PropiedadCaracteristicasWidget(
              bedrooms: 3,
              bathrooms: 2,
              halfBathrooms: 1,
              parkingSpots: 2,
              floors: 2,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Características'));
    await tester.pumpAndSettle();
    // Se restaura antes de los expect: el binding exige el handler original.
    FlutterError.onError = originalOnError;

    expect(find.text('Pisos'), findsOneWidget);
    expect(errors, isEmpty, reason: errors.join('\n---\n'));
  });
}
