import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_ajustes/d_h_a_s_s_o_c_i_a_t_e_ajustes_widget.dart';
import 'package:dovia/repositories/user_repository.dart';

Future<void> _signInAsCompany() async {
  SharedPreferences.setMockInitialValues(
      {'ff_UserRole': 'HOME_ASSOCIATE_COMPANY'});
  await FFAppState().initializePersistedState();
}

/// El perfil sale contra el fake HttpClient del binding (400 sin red), así que
/// los campos quedan vacíos: lo que se verifica acá es el armado de la
/// pantalla —las dos pestañas y sus secciones—, no los datos.
Future<void> _pumpAjustes(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => UserRepository(),
      child: const MaterialApp(
        home: DHASSOCIATEAjustesWidget(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(FFAppState.reset);

  testWidgets('la cabecera dice Ajustes y ofrece las dos pestañas',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpAjustes(tester);

    expect(find.text('Ajustes', findRichText: true), findsOneWidget);
    expect(find.text('Perfil y seguridad'), findsOneWidget);
    expect(find.text('Configuración de notificaciones'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la píldora de rol dice Empresa Asociada, no Operative Listing',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpAjustes(tester);

    expect(find.text('Empresa Asociada Dovia Home'), findsOneWidget);
    expect(find.text('Dovia Operative Listing'), findsNothing);
  });

  testWidgets('la pestaña de perfil arma las secciones del diseño',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpAjustes(tester);

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Datos personales'), findsOneWidget);
    expect(find.text('Ganancias'), findsOneWidget);
    expect(find.text('Documentación'), findsOneWidget);
    expect(find.text('Cambio de contraseña'), findsOneWidget);
    expect(find.text('Soporte y legal'), findsOneWidget);
    expect(find.text('Acciones críticas'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(find.text('Eliminar cuenta'), findsOneWidget);
  });

  testWidgets('la pestaña de notificaciones lista los cinco avisos',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpAjustes(tester);

    await tester.tap(find.text('Configuración de notificaciones'));
    await tester.pumpAndSettle();

    expect(find.text('Notificaciones'), findsOneWidget);
    for (final aviso in const [
      'Daily listing',
      'Recomendaciones',
      'Tips',
      'Novedades',
      'Informe semanal',
    ]) {
      expect(find.text(aviso), findsOneWidget, reason: 'falta el aviso $aviso');
    }
    expect(find.byType(Switch), findsNWidgets(5));

    // El perfil deja de estar a la vista: son pestañas, no secciones apiladas.
    expect(find.text('Cambio de contraseña'), findsNothing);
  });
}
