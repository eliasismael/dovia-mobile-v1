import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_client/app/ajustes/d_o_v_i_a_c_l_i_e_n_t_ajustes/d_o_v_i_a_c_l_i_e_n_t_ajustes_widget.dart';
import 'package:dovia/repositories/index.dart';

/// El ancho es lo que se está probando: las dos pestañas no entraban a lo
/// ancho del teléfono y la fila desbordaba por la derecha.
Future<void> _pumpAjustes(
  WidgetTester tester, {
  required double logicalWidth,
}) async {
  tester.view.physicalSize = Size(logicalWidth * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FFAppState()),
        ChangeNotifierProvider(create: (_) => UserRepository()),
        ChangeNotifierProvider(create: (_) => PaymentsRepository()),
        ChangeNotifierProvider(create: (_) => NotificationsRepository()),
      ],
      child: const MaterialApp(
        home: DOVIACLIENTAjustesWidget(),
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

  // `FFAppState` es un singleton: sin esto el estado de un caso se filtra al
  // siguiente y los anchos dejan de ser independientes entre sí.
  tearDown(FFAppState.reset);

  // 320 es el teléfono más angosto que se soporta; 430 es el ancho donde se
  // vio el desborde original, de sólo 10 px.
  for (final width in const [320.0, 360.0, 430.0]) {
    testWidgets('las pestañas de Ajustes entran a ${width.toInt()} dp',
        (tester) async {
      await _pumpAjustes(tester, logicalWidth: width);

      final perfil = find.text('Perfil y seguridad');
      final notificaciones = find.text('Notificaciones');
      expect(perfil, findsOneWidget);
      expect(notificaciones, findsOneWidget);

      // Se mide la geometría en vez de mirar las excepciones del frame: la
      // pantalla es larga y en el viewport fijo del test desborda a lo alto
      // por su propio motivo, que no es lo que cubre este archivo.
      expect(tester.getRect(perfil).left, greaterThanOrEqualTo(0.0));
      expect(tester.getRect(notificaciones).right, lessThanOrEqualTo(width));
    });
  }
}
