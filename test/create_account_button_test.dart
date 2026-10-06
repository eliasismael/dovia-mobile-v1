import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_client/inicio_sesion_nueva_version/create_account/create_account_widget.dart';
import 'package:dovia/flutter_flow/flutter_flow_widgets.dart';

/// "Continuar" se habilitaba recién al cerrar el teclado. Tiene que
/// habilitarse mientras se escribe, apenas el correo es válido.
void main() {
  tearDown(FFAppState.reset);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412 * 3, 1000 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: MaterialApp.router(
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (_, __) => const CreateAccountWidget()),
        ]),
      ),
    ));
    await tester.pumpAndSettle();
  }

  bool continuarEnabled(WidgetTester tester) => tester
          .widget<FFButtonWidget>(find.widgetWithText(FFButtonWidget, 'Continuar'))
          .onPressed !=
      null;

  testWidgets('se habilita mientras se escribe, sin cerrar el teclado',
      (tester) async {
    await pump(tester);
    final field = find.byType(TextFormField);
    await tester.tap(field);
    await tester.pump();

    expect(continuarEnabled(tester), isFalse);

    await tester.enterText(field, 'ana@dovia');
    await tester.pump();
    expect(continuarEnabled(tester), isFalse);

    await tester.enterText(field, 'ana@dovia.com');
    await tester.pump();
    // El campo sigue con foco (teclado abierto) y el botón ya está activo.
    expect(
        tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
        isTrue);
    expect(continuarEnabled(tester), isTrue);

    // Si se borra hasta dejarlo inválido, se vuelve a deshabilitar.
    await tester.enterText(field, 'ana@');
    await tester.pump();
    expect(continuarEnabled(tester), isFalse);
  });
}
