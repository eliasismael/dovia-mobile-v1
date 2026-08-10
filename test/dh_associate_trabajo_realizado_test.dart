import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_realizado/d_h_a_s_s_o_c_i_a_t_e_trabajo_realizado_widget.dart';

Future<void> _pump(WidgetTester tester, Map<String, dynamic> data) async {
  DHASSOCIATETrabajoRealizadoWidget.requestData = data;
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATETrabajoRealizadoWidget(),
  ));
  await tester.pump();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('sin calificación muestra el estado vacío', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Sin id: no dispara la lectura del detalle, así que no hay red en el test.
    await _pump(tester, {
      'status': 'FINISHED',
      'completionDescription': 'Se cambió la llave de paso.',
      'clientRecommendations': 'Revisar el sifón en 6 meses.',
    });

    expect(
        find.text('Tu trabajo realizado', findRichText: true), findsOneWidget);
    expect(find.text('Información que se envio al cliente'), findsOneWidget);
    expect(find.text('Feedback del cliente'), findsOneWidget);
    expect(find.text('Se cambió la llave de paso.'), findsOneWidget);
    expect(find.text('Recomendaciones: Revisar el sifón en 6 meses.'),
        findsOneWidget);
    expect(find.text('El cliente aún no ha dejado una calificación.'),
        findsOneWidget);
    expect(find.text('El cliente no dejó ningún comentario.'), findsOneWidget);
    expect(find.text('Aceptar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con calificación pinta las estrellas y el comentario',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'status': 'FINISHED',
      'completionDescription': 'Trabajo terminado.',
      'associateRating': {'stars': 4, 'comment': 'Muy prolijo, gracias.'},
    });

    expect(find.text('Muy prolijo, gracias.'), findsOneWidget);
    expect(find.text('El cliente aún no ha dejado una calificación.'),
        findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la evidencia se pinta como carrusel', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'status': 'FINISHED',
      'completionImages': {
        'WORK': [
          {'url': 'https://example.test/a.jpg'},
          {'url': 'https://example.test/b.jpg'},
        ],
      },
    });

    expect(
      find.byWidgetPredicate((w) => w is Image && w.image is NetworkImage),
      findsNWidgets(2),
    );
    expect(find.text('No enviaste imágenes de este trabajo.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
