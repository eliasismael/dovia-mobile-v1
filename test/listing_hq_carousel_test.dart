import 'package:dovia/listing_hq/listing_hq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sin alto fijo, el carrusel toma el de la tarjeta más alta',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ListingHqCarousel(
                  height: null,
                  children: [
                    Container(width: 300, height: 120, color: Colors.red),
                    Container(width: 300, height: 200, color: Colors.blue),
                    Container(width: 300, height: 80, color: Colors.green),
                  ],
                ),
                const Text('debajo'),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final carousel = tester.getSize(find.byType(ListingHqCarousel));
    // 200 de la tarjeta más alta + 6 de aire arriba y abajo.
    expect(carousel.height, 212);
    // Las tarjetas se estiran al alto de la fila.
    final first = tester.getSize(find.byType(Container).first);
    expect(first.height, 200);
    expect(find.text('debajo'), findsOneWidget);
  });
}
