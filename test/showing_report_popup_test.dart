import 'package:dovia/showing/s_h_o_w_i_n_g_report_popup/s_h_o_w_i_n_g_report_popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el modal de reporte entra a 360 dp y "Enviar reporte" es blanco',
      (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SHOWINGReportPopupWidget()),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('¿Qué problema tuviste en la visita?'), findsOneWidget);
    final send = tester.widget<Text>(find.text('Enviar reporte'));
    expect(send.style?.color, Colors.white);

    // Sin nota no se envía: avisa en rojo.
    await tester.tap(find.text('Enviar reporte'));
    await tester.pump();
    expect(find.text('Escribe qué pasó para enviar el reporte.'), findsOneWidget);
  });
}
