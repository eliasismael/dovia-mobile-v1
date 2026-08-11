import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizaciones/d_h_a_s_s_o_c_i_a_t_e_cotizaciones_widget.dart';

/// Deja el rol en sesión como lo dejaría el login.
Future<void> _signInAs(String role) async {
  SharedPreferences.setMockInitialValues({'ff_UserRole': role});
  await FFAppState().initializePersistedState();
}

/// Los listados salen contra el fake HttpClient del binding (400 sin red), así
/// que el tablero resuelve con los carriles en error: lo que se verifica acá es
/// el armado de la pantalla —cabecera, filtros y bloques—, no los datos.
Future<void> _pumpHistory(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATECotizacionesWidget(),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(FFAppState.reset);

  testWidgets('la cabecera dice Cotizaciones y no hay barra de búsqueda',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpHistory(tester);

    // El título de la cabecera es un RichText, no un Text suelto.
    expect(find.text('Cotizaciones', findRichText: true), findsOneWidget);
    // El historial navega sólo con los desplegables: no hay campo de texto.
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Búsqueda con IA'), findsNothing);
  });

  testWidgets('ofrece los tres filtros del diseño', (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpHistory(tester);

    expect(find.text('Tipo de Trabajo'), findsOneWidget);
    expect(find.text('Estado del trabajo'), findsOneWidget);
    expect(find.text('Fecha del trabajo'), findsOneWidget);
  });

  testWidgets('lista los cuatro estados del ciclo de venta', (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpHistory(tester);

    expect(find.text('Cotizaciones activas:'), findsOneWidget);
    expect(find.text('Cotizaciones enviadas:'), findsOneWidget);
    expect(find.text('Cotizaciones aprobadas:'), findsOneWidget);
    expect(find.text('Cotizaciones rechazadas:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el filtro de estado ofrece los cuatro carriles y "Todas"',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpHistory(tester);

    // El desplegable arranca en "Todas" (no filtra), así que ése es su rótulo.
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();

    for (final option in const [
      'Todas',
      'Activas',
      'Enviadas',
      'Aprobadas',
      'Rechazadas',
    ]) {
      expect(find.text(option), findsWidgets, reason: 'falta la opción $option');
    }
  });

  testWidgets('elegir un estado deja sólo ese bloque en la grilla',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpHistory(tester);

    // El desplegable arranca en "Todas" (no filtra), así que ése es su rótulo.
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rechazadas').last);
    await tester.pumpAndSettle();

    expect(find.text('Cotizaciones rechazadas:'), findsOneWidget);
    expect(find.text('Cotizaciones activas:'), findsNothing);
    expect(find.text('Cotizaciones enviadas:'), findsNothing);
    expect(find.text('Cotizaciones aprobadas:'), findsNothing);
  });
}
