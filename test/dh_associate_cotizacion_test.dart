import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizacion/d_h_a_s_s_o_c_i_a_t_e_cotizacion_widget.dart';

Future<void> _pump(WidgetTester tester, Map<String, dynamic>? data) async {
  DHASSOCIATECotizacionWidget.requestData = data;
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATECotizacionWidget(),
  ));
  await tester.pump();
  // `_loadDetail` sale contra el fake HttpClient del binding (400 sin red) y
  // se traga el fallo: la pantalla sigue con lo que trajo el listado.
  await tester.pump(const Duration(milliseconds: 500));
}

ElevatedButton _submitButton(WidgetTester tester) => tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Enviar propuesta'),
        matching: find.byType(ElevatedButton),
      ),
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    DHASSOCIATECotizacionWidget.requestData = null;
  });

  testWidgets('muestra el requerimiento del cliente y el formulario de propuesta',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'id': 'req-1',
      'requestType': 'QUOTE',
      'status': 'PENDING',
      'subStatus': 'QUOTE_QUOTING',
      'serviceDetail': {'label': 'Instalación de TV'},
      'description': 'Necesito montar dos televisores en pared de concreto.',
      'address': {'zone': 'Zona 10'},
    });

    expect(find.text('Cotización', findRichText: true), findsOneWidget);
    expect(find.text('Lo que pide el cliente'), findsOneWidget);
    expect(
      find.text('Necesito montar dos televisores en pared de concreto.'),
      findsOneWidget,
    );
    expect(find.text('Monto total de tu propuesta'), findsOneWidget);
    expect(find.text('Presupuesto en PDF'), findsOneWidget);
    expect(find.text('Sube el PDF con tu presupuesto'), findsOneWidget);
  });

  testWidgets('la dirección sigue enmascarada hasta ganar el proyecto',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'id': 'req-1',
      'requestType': 'QUOTE',
      'serviceDetail': {'label': 'Instalación de TV'},
      'address': {
        'zone': 'Zona 10',
        'address': 'Calle Falsa 123',
      },
    });

    expect(find.textContaining('Dirección: Zona 10'), findsOneWidget);
    expect(find.textContaining('Calle Falsa 123'), findsNothing);
  });

  testWidgets('sin monto ni PDF el envío queda deshabilitado', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'id': 'req-1',
      'requestType': 'QUOTE',
      'serviceDetail': {'label': 'Instalación de TV'},
    });

    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('con monto pero sin PDF tampoco se puede enviar', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'id': 'req-1',
      'requestType': 'QUOTE',
      'serviceDetail': {'label': 'Instalación de TV'},
    });

    await tester.enterText(find.byType(TextFormField).first, '4500');
    await tester.pump();

    // El PDF es el entregable que el cliente lee antes de aceptar: el endpoint
    // lo exige y la pantalla no deja mandar sólo el número.
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('sin requerimiento fijado lo dice en vez de un formulario vacío',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, null);

    expect(
      find.textContaining('No encontramos el requerimiento'),
      findsOneWidget,
    );
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('sin fotos del cliente lo dice explícitamente', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester, {
      'id': 'req-1',
      'requestType': 'QUOTE',
      'serviceDetail': {'label': 'Instalación de TV'},
    });

    expect(
      find.text('El cliente no adjuntó fotos de lo que necesita.'),
      findsOneWidget,
    );
  });
}
