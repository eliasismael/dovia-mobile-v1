import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado/d_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado_widget.dart';

Future<void> _pump(WidgetTester tester, Map<String, dynamic>? data) async {
  DHASSOCIATETrabajoFinalizadoWidget.requestData = data;
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATETrabajoFinalizadoWidget(),
  ));
  await tester.pump();
}

/// El botón "Terminado" queda al pie del scroll, debajo del navbar fijo, así
/// que un `tester.tap` no lo alcanza. Se dispara su handler directamente: lo
/// que interesa acá son las validaciones, no la geometría.
Future<void> _tapTerminado(WidgetTester tester) async {
  final button = tester.widget<ElevatedButton>(
    find.ancestor(
      of: find.text('Terminado'),
      matching: find.byType(ElevatedButton),
    ),
  );
  button.onPressed!();
  await tester.pump();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('muestra los cuatro campos del reporte de cierre',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {'id': 'req-1', 'status': 'IN_PROGRESS'});

    expect(find.text('Trabajo finalizado', findRichText: true),
        findsOneWidget);
    expect(find.text('Cargar imágenes de trabajos realizados'),
        findsOneWidget);
    expect(find.text('Describe los trabajos realizados'), findsOneWidget);
    expect(
        find.text('En caso de dejar materiales, ¿dónde los dejaste?'),
        findsOneWidget);
    expect(find.text('Recomendaciones para el cliente'), findsOneWidget);
    expect(find.text('Terminado'), findsOneWidget);
  });

  testWidgets('sin fotos no cierra: la evidencia es obligatoria',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {'id': 'req-1', 'status': 'IN_PROGRESS'});

    // Sin fotos cargadas, tocar "Terminado" no debe llegar a la red: se
    // bloquea antes, con la descripción todavía vacía también.
    await _tapTerminado(tester);

    expect(
        find.text(
            'Agrega al menos una foto de los trabajos realizados para poder '
            'cerrar.'),
        findsOneWidget);
  });
}
