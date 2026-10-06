import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_client/inicio_sesion_nueva_version/sign_in/sign_in_widget.dart';

/// El login tenía márgenes fijos y en un teléfono donde entraba todo
/// aparecía un scroll de unos pocos píxeles. Ahora solo scrollea cuando de
/// verdad no entra.
Future<ScrollPosition> _pumpSignIn(WidgetTester tester, Size logical) async {
  tester.view.physicalSize = logical * 3;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  await FFAppState().initializePersistedState();
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: FFAppState(),
    child: MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const SignInWidget()),
      ]),
    ),
  ));
  await tester.pumpAndSettle();
  final scrollable = tester.state<ScrollableState>(find
      .descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable))
      .first);
  return scrollable.position;
}

void main() {
  tearDown(FFAppState.reset);

  testWidgets('en un teléfono alto no hay scroll y el registro queda abajo',
      (tester) async {
    const size = Size(412, 1000);
    final position = await _pumpSignIn(tester, size);

    expect(position.maxScrollExtent, 0.0);
    final footer = tester.getRect(find.text('Regístrate como asociado'));
    // Pegado al fondo (16 px de margen + el alto del link), no a mitad de
    // pantalla.
    expect(footer.bottom, greaterThan(size.height - 80));
  });

  testWidgets('en una pantalla chica sigue pudiendo scrollear',
      (tester) async {
    // A 320 dp la fuente de test (Ahem, letras anchas) desborda una fila de
    // texto a lo ancho; ya pasaba antes de este cambio y no es lo que se
    // prueba acá.
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    final position = await _pumpSignIn(tester, const Size(320, 568));
    expect(position.maxScrollExtent, greaterThan(0.0));
  });
}
