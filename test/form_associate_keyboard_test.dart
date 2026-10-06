import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_client/inicio_sesion_nueva_version/form_associate/form_associate_widget.dart';

/// Con el teclado abierto (al completar la dirección) el formulario de
/// asociado desbordaba 305 px: tenía un alto fijo del 80 % de la pantalla.
void main() {
  tearDown(FFAppState.reset);

  testWidgets('con el teclado abierto el formulario no desborda',
      (tester) async {
    // Teléfono como el SM-S721B y un teclado de ~340 dp.
    tester.view.physicalSize = const Size(384 * 3, 832 * 3);
    tester.view.devicePixelRatio = 3.0;
    tester.view.viewInsets =
        const FakeViewPadding(bottom: 340 * 3);
    addTearDown(tester.view.reset);

    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) {
        overflows.add(text);
        return;
      }
      // El mapa y las llamadas de red no aplican acá.
    };
    addTearDown(() => FlutterError.onError = original);

    SharedPreferences.setMockInitialValues({'ff_UserRole': 'HOME_ASSOCIATE'});
    await FFAppState().initializePersistedState();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: MaterialApp.router(
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (_, __) => const FormAssociateWidget()),
        ]),
      ),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Solo cuenta un desborde a lo alto (el de la captura); los de texto a lo
    // ancho son de la fuente de test.
    expect(overflows.where((o) => o.contains('bottom')), isEmpty);
  });
}
