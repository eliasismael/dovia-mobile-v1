import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/shared_components/segmented_filter_bar/segmented_filter_bar_widget.dart';

void main() {
  testWidgets('selecciona entre Enviado y Rechazada', (tester) async {
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SegmentedFilterBarWidget(
          labels: const ['Enviado', 'Rechazada'],
            selectedIndex: selected,
            onSelected: (index) => selected = index,
          ),
        ),
      ),
    );

    expect(find.text('Enviado'), findsOneWidget);
    expect(find.text('Rechazada'), findsOneWidget);

    await tester.tap(find.text('Rechazada'));
    await tester.pump();

    expect(selected, 1);
  });
}
