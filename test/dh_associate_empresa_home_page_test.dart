import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_empresa_home_page/d_h_a_s_s_o_c_i_a_t_e_empresa_home_page_widget.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_home_page/d_h_a_s_s_o_c_i_a_t_e_home_page_widget.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';

/// Deja el rol en sesión como lo dejaría el login. `initializePersistedState`
/// además engancha las prefs mock, sin las cuales el setter de rol explota.
Future<void> _signInAs(String role) async {
  SharedPreferences.setMockInitialValues({'ff_UserRole': role});
  await FFAppState().initializePersistedState();
}

/// Los listados salen contra el fake HttpClient del binding (400 sin red), así
/// que el tablero resuelve con los tres carriles en error: lo que se verifica
/// acá es el armado de la pantalla, no los datos.
Future<void> _pumpPanel(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATEEmpresaHomePageWidget(),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Finder _navItems() => find.descendant(
      of: find.byType(DHASSOCIATENavbarWidget),
      matching: find.byType(InkWell),
    );

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(FFAppState.reset);

  testWidgets('el panel arma las tres secciones del pipeline', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpPanel(tester);

    expect(find.text('Servicios'), findsOneWidget);
    expect(find.text('Añadir'), findsOneWidget);
    expect(find.text('Cotizaciones'), findsOneWidget);
    expect(find.text('Ver más'), findsOneWidget);
    expect(find.text('Cotizaciones activas:'), findsOneWidget);
    expect(find.text('Cotizaciones enviadas:'), findsOneWidget);
    expect(find.text('Cotizaciones aprobadas:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el panel de empresa no ofrece la bolsa del independiente',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpPanel(tester);

    expect(find.text('Trabajos disponibles:'), findsNothing);
    expect(find.text('Próximos trabajos'), findsNothing);
  });

  testWidgets('con rol Empresa el navbar inyecta el ítem de Cotizaciones',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE_COMPANY');
    await _pumpPanel(tester);

    // Inicio + Cotizaciones + Servicios: avisos y ajustes están en el header.
    expect(_navItems(), findsNWidgets(3));
    expect(find.text('Cotizaciones'), findsWidgets);
  });

  testWidgets('el profesional independiente no ve el ítem de Cotizaciones',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAs('HOME_ASSOCIATE');
    await tester.pumpWidget(const MaterialApp(
      home: DHASSOCIATEHomePageWidget(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Inicio + Trabajos + Servicios: los endpoints de cotizaciones son de
    // empresa y le responderían 403.
    expect(_navItems(), findsNWidgets(3));
    expect(find.text('Trabajos'), findsOneWidget);
  });
}
