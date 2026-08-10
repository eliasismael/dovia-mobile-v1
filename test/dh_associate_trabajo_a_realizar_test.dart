import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar/d_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar_widget.dart';

Future<void> _pump(WidgetTester tester, Map<String, dynamic> data) async {
  // La pantalla pinta fotos de ejemplo desde picsum.photos (preexistente, no
  // depende del estado del trabajo); sin red esas cargas fallan de forma
  // asíncrona, en un momento que no coincide con ningún pump puntual. Se
  // silencia sólo ese error acá — no es parte de lo que este archivo cubre —
  // y se restaura el handler al terminar el test.
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is NetworkImageLoadException) return;
    originalOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = originalOnError);

  DHASSOCIATETrabajoARealizarWidget.requestData = data;
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATETrabajoARealizarWidget(),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('oportunidad libre muestra el botón de postulación',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // _canApply exige un id no vacío (es lo que postularía), así que a
    // diferencia de los otros casos acá sí hace falta uno. El fake
    // HttpClient de TestWidgetsFlutterBinding devuelve 400 sin red real, y
    // _loadDetail lo traga en silencio.
    await _pump(tester, {
      'id': 'req-1',
      'status': 'PENDING',
      'serviceDetail': {'label': 'Plomería'},
    });

    expect(find.text('Tu trabajo', findRichText: true), findsOneWidget);
    expect(find.text('Postularme a este trabajo'), findsOneWidget);
    // La ficha se ve, pero con la dirección enmascarada y sin mapa ni check-in.
    expect(find.text('Dirección exacta'), findsOneWidget);
    expect(find.text('Se revela cuando aceptes el trabajo.'), findsOneWidget);
    expect(find.text('Debes llevar'), findsOneWidget);
    expect(find.text('Mapa'), findsNothing);
    expect(find.text('Ya llegué al punto'), findsNothing);
  });

  testWidgets(
      'trabajo tomado desoculta dirección, mapa y check-in en la misma pantalla',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'status': 'TAKEN',
      'serviceDetail': {'label': 'Plomería'},
      'whatToBring': 'Llave inglesa y teflón.',
      'address': {
        'address': 'Calle Falsa 123',
        'accessInstructions': 'Tocar timbre 2B',
        'coordinates': {'latitude': 14.6, 'longitude': -90.5},
      },
    });

    expect(find.text('Tu trabajo', findRichText: true), findsOneWidget);
    expect(find.text('Postularme a este trabajo'), findsNothing);
    expect(find.text('Dirección exacta'), findsOneWidget);
    expect(find.text('Calle Falsa 123'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Instrucciones de ingreso'), findsOneWidget);
    expect(find.text('Tocar timbre 2B'), findsOneWidget);
    expect(find.text('Debes llevar'), findsOneWidget);
    expect(find.text('Llave inglesa y teflón.'), findsOneWidget);
    expect(find.text('Ya llegué al punto'), findsOneWidget);
    expect(find.text('Enviar mi ubicación y notificar'), findsOneWidget);
    // El mapa es de sólo lectura: no ofrece elegir un punto.
    expect(find.text('Toca el mapa para elegir el punto'), findsNothing);
  });

  testWidgets('trabajo tomado sin instrucciones no pinta esa sección',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'status': 'TAKEN',
      'serviceDetail': {'label': 'Plomería'},
      'address': {'address': 'Calle Falsa 123'},
    });

    expect(find.text('Dirección exacta'), findsOneWidget);
    expect(find.text('Instrucciones de ingreso'), findsNothing);
  });

  testWidgets('trabajo en sitio muestra las acciones de ejecución',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'status': 'IN_PROGRESS',
      'serviceDetail': {'label': 'Plomería'},
      'address': {'address': 'Calle Falsa 123'},
    });

    expect(find.text('Trabajo a realizar', findRichText: true), findsOneWidget);
    expect(find.text('Ya llegué al punto'), findsNothing);
    expect(find.text('Finalizar trabajos/visitas'), findsOneWidget);
    expect(find.text('Necesito materiales adicionales'), findsOneWidget);
  });

  testWidgets('las acciones de ejecución están cableadas, no son stubs',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'id': 'req-1',
      'status': 'IN_PROGRESS',
      'serviceDetail': {'label': 'Plomería'},
    });

    // FFButtonWidget deshabilita el botón cuando onPressed es null; que estén
    // habilitados es lo que distingue un botón cableado de uno muerto.
    for (final label in const [
      'Necesito materiales adicionales',
      'Se necesitan trabajos adicionales',
      'Finalizar trabajos/visitas',
    ]) {
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNotNull, reason: '"$label" quedó sin acción');
    }
  });
}
