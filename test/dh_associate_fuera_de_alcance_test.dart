import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_fuera_de_alcance/d_h_a_s_s_o_c_i_a_t_e_fuera_de_alcance_widget.dart';

Future<void> _pump(WidgetTester tester, {String? serviceRequestId}) async {
  DHASSOCIATEFueraDeAlcanceWidget.serviceRequestId = serviceRequestId;
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATEFueraDeAlcanceWidget(),
  ));
  await tester.pump();
}

/// El botón de envío queda al pie del scroll, debajo del navbar fijo, así que
/// un `tester.tap` no lo alcanza. Se dispara su handler directamente: lo que
/// interesa acá son las validaciones, no la geometría.
Future<void> _tapSubmit(WidgetTester tester) async {
  final button = tester.widget<ElevatedButton>(
    find.ancestor(
      of: find.text('Enviar'),
      matching: find.byType(ElevatedButton),
    ),
  );
  button.onPressed!();
  // El SnackBar necesita un frame extra para entrar en escena.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 750));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('muestra los dos campos del diseño', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, serviceRequestId: 'req-1');

    expect(find.text('Trabajo adicional', findRichText: true), findsOneWidget);
    expect(find.text('Trabajos a cotizar'), findsOneWidget);
    expect(find.text('Sube las imágenes'), findsOneWidget);
    expect(find.text('Enviar'), findsOneWidget);
    // El selector de executionMode ya no existe: el reporte siempre se deriva.
    expect(find.text('¿Quién puede hacerlo?'), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin descripción no envía y lo dice', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, serviceRequestId: 'req-1');

    await _tapSubmit(tester);

    expect(find.text('Describe el trabajo adicional que hace falta.'),
        findsOneWidget);
  });

  test('el reporte siempre sale como trabajo para otro proveedor', () {
    expect(kOutOfScopeExecutionMode, 'OTHER_PROVIDER_REQUIRED');
  });
}
