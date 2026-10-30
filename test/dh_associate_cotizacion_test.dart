import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizacion/d_h_a_s_s_o_c_i_a_t_e_cotizacion_widget.dart';

Map<String, dynamic> _request({
  String id = 'req-1',
  String label = 'Instalación de TV',
  String zone = 'Zona 10',
  String? description,
  List<String>? imageUrls,
}) =>
    {
      'id': id,
      'requestType': 'QUOTE',
      'status': 'PENDING',
      'subStatus': 'QUOTE_QUOTING',
      'serviceDetail': {'label': label},
      'address': {'zone': zone},
      if (description != null) 'description': description,
      if (imageUrls != null) 'requestImageUrls': imageUrls,
    };

Map<String, dynamic> _proposal({
  String status = 'SUBMITTED',
  num? totalAmount = 1200,
  String? documentUrl = 'https://dovia.test/presupuesto.pdf',
}) =>
    {
      'id': 'prop-1',
      'serviceRequestId': 'req-1',
      'proposalType': 'QUOTE',
      'status': status,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (documentUrl != null) 'documentUrl': documentUrl,
      if (documentUrl != null) 'originalFileName': 'presupuesto-tv.pdf',
    };

Future<void> _pump(
  WidgetTester tester, {
  Map<String, dynamic>? data,
  Map<String, dynamic>? proposal,
}) async {
  DHASSOCIATECotizacionWidget.requestData = data;
  DHASSOCIATECotizacionWidget.proposalData = proposal;
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATECotizacionWidget(),
  ));
  await tester.pump();
  // `_loadDetail` sale contra el fake HttpClient del binding (400 sin red) y
  // se traga el fallo: la pantalla sigue con lo que trajo el listado.
  await tester.pump(const Duration(milliseconds: 500));
}

ElevatedButton _button(WidgetTester tester, String text) =>
    tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text(text),
        matching: find.byType(ElevatedButton),
      ),
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    DHASSOCIATECotizacionWidget.requestData = null;
    DHASSOCIATECotizacionWidget.proposalData = null;
  });

  group('Estado 1 (Activa)', () {
    testWidgets('muestra el requerimiento del cliente y el formulario',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        data: _request(
          description: 'Necesito montar dos televisores en pared de concreto.',
        ),
      );

      expect(find.text('Cotizaciones', findRichText: true), findsOneWidget);
      expect(find.text('Lo que necesita el cliente'), findsOneWidget);
      expect(
        find.text('Necesito montar dos televisores en pared de concreto.'),
        findsOneWidget,
      );
      expect(
          find.text('Indica el precio total de la cotización'), findsOneWidget);
      expect(find.text('Carga las Cotización'), findsOneWidget);
      expect(find.text('Sube el PDF o la imagen con tu presupuesto'),
          findsOneWidget);
      expect(find.text('Enviar cotización'), findsOneWidget);
    });

    testWidgets('la dirección sigue enmascarada hasta ganar el proyecto',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final data = _request()
        ..['address'] = {
          'zone': 'Zona 10',
          'address': 'Calle Falsa 123',
        };
      await _pump(tester, data: data);

      expect(find.textContaining('Dirección: Zona 10'), findsOneWidget);
      expect(find.textContaining('Calle Falsa 123'), findsNothing);
    });

    testWidgets('sin monto ni archivo el envío queda deshabilitado',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(tester, data: _request());

      expect(_button(tester, 'Enviar cotización').onPressed, isNull);
    });

    testWidgets('con monto pero sin archivo tampoco se puede enviar',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(tester, data: _request());

      await tester.enterText(find.byType(TextFormField).first, '4500');
      await tester.pump();

      expect(_button(tester, 'Enviar cotización').onPressed, isNull);
    });

    testWidgets(
        'sin requerimiento fijado lo dice en vez de un formulario vacío',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(tester, data: null);

      expect(
        find.textContaining('No encontramos el requerimiento'),
        findsOneWidget,
      );
      expect(_button(tester, 'Enviar cotización').onPressed, isNull);
    });

    testWidgets('sin fotos del cliente lo dice explícitamente', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(tester, data: _request());

      expect(
        find.text('El cliente no adjuntó fotos de lo que necesita.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'información del cliente muestra nombre y zona para armar el PDF, '
        'sin teléfono ni correo', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        data: _request()
          ..['clientProfile'] = {'id': 'c1', 'fullName': 'Ana López'},
      );

      expect(_button(tester, 'Información del cliente').onPressed, isNotNull);
      await tester.ensureVisible(find.text('Información del cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Información del cliente'));
      await tester.pumpAndSettle();

      expect(find.text('Datos del cliente'), findsOneWidget);
      expect(find.text('Ana López'), findsOneWidget);
      expect(find.text('Zona: Zona 10'), findsOneWidget);
      expect(find.textContaining('Número:'), findsNothing);
      expect(find.textContaining('se habilitan cuando el cliente acepte'),
          findsOneWidget);
    });

    testWidgets('no muestra ningún banner de estado', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(tester, data: _request());

      expect(find.textContaining('fue enviada correctamente'), findsNothing);
      expect(find.textContaining('fue aceptada'), findsNothing);
    });
  });

  group('Estado 2 (Enviada)', () {
    testWidgets(
        'bloquea precio y archivo, esconde Enviar y muestra el banner amarillo',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(tester, data: _request(), proposal: _proposal());

      expect(find.text('Q1,200'), findsOneWidget);
      expect(find.text('presupuesto-tv.pdf'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Enviar cotización'), findsNothing);
      expect(
        find.textContaining('Tu cotización fue enviada correctamente'),
        findsOneWidget,
      );
      expect(_button(tester, 'Información del cliente').onPressed, isNotNull);
    });
  });

  group('Estado 3 (Aprobada)', () {
    testWidgets('muestra el banner verde y habilita Información del cliente',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        data: _request(),
        proposal: _proposal(status: 'ACCEPTED'),
      );

      expect(find.textContaining('Tu cotización fue aceptada'), findsOneWidget);
      expect(find.text('Enviar cotización'), findsNothing);
      expect(_button(tester, 'Información del cliente').onPressed, isNotNull);
    });

    testWidgets('el modal de datos del cliente se abre y se cierra',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        data: _request(),
        proposal: _proposal(status: 'ACCEPTED'),
      );

      await tester.ensureVisible(find.text('Información del cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Información del cliente'));
      await tester.pumpAndSettle();

      expect(find.text('Datos del cliente'), findsOneWidget);
      expect(find.textContaining('Número:'), findsOneWidget);
      expect(find.textContaining('Correo:'), findsOneWidget);

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      expect(find.text('Datos del cliente'), findsNothing);
    });
  });
}
