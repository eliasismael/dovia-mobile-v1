import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/auth/registration_progress.dart';
import 'package:dovia/dovia_client/inicio_sesion_nueva_version/form_associate/form_associate_widget.dart';
import 'package:dovia/index.dart' show SignInWidget, SolicitudEnRevisionWidget;

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

GoRouter _router() => GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const FormAssociateWidget()),
      for (final name in [
        SolicitudEnRevisionWidget.routeName,
        SignInWidget.routeName,
      ])
        GoRoute(
          name: name,
          path: '/$name',
          builder: (_, __) => Scaffold(body: Text('RUTA $name')),
        ),
    ]);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// El formulario de asociado no dejaba salir (atrás bloqueado) y aparecía
/// aunque el formulario ya se hubiera enviado.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'ff_UserRole': 'HOME_ASSOCIATE'});
    await FFAppState().initializePersistedState();
    await RegistrationProgress.set(RegistrationProgress.associateForm);
    await authManager.initialize();
    await authManager.signIn(authenticationToken: 't', authUid: 'u');
  });
  tearDown(FFAppState.reset);

  Future<void> pump(WidgetTester tester, Map<String, dynamic> profile) async {
    tester.view.physicalSize = const Size(412 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      // Desbordes de texto de la fuente de test y el mapa no aplican acá.
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: MaterialApp.router(routerConfig: _router()),
      ));
      await _settle(tester);
    }, () => MockClient((req) async => _json(200, {'data': profile})));
  }

  testWidgets('si el formulario ya se había enviado, pasa a la revisión',
      (tester) async {
    await pump(tester, {
      'criminalRecordUrl': 'a.pdf',
      'policeRecordUrl': 'b.pdf',
      'utilityBillUrl': 'c.pdf',
      'address': 'Calle 123',
    });

    expect(find.text('RUTA ${SolicitudEnRevisionWidget.routeName}'),
        findsOneWidget);
    expect(RegistrationProgress.step, RegistrationProgress.pendingReview);
  });

  testWidgets('si falta enviarlo, muestra el formulario con salida',
      (tester) async {
    await pump(tester, {'address': null});

    expect(find.byTooltip('Salir del registro'), findsOneWidget);
    expect(find.textContaining('RUTA'), findsNothing);
  });

  testWidgets('salir pide confirmar y cierra la sesión', (tester) async {
    await pump(tester, {'address': null});

    await http.runWithClient(() async {
      await tester.tap(find.byTooltip('Salir del registro'));
      await _settle(tester);
      expect(find.text('¿Salir del registro?'), findsOneWidget);

      // "Seguir completando" no hace nada.
      await tester.tap(find.text('Seguir completando'));
      await _settle(tester);
      expect(find.textContaining('RUTA'), findsNothing);
      expect(loggedIn, isTrue);

      await tester.tap(find.byTooltip('Salir del registro'));
      await _settle(tester);
      await tester.tap(find.text('Cerrar sesión'));
      await _settle(tester);
    }, () => MockClient((req) async => _json(200, {})));

    expect(find.text('RUTA ${SignInWidget.routeName}'), findsOneWidget);
    expect(loggedIn, isFalse);
  });

  testWidgets('el botón atrás del sistema también ofrece salir',
      (tester) async {
    await pump(tester, {'address': null});

    final popped = await tester.binding.handlePopRoute();
    await _settle(tester);

    expect(popped, isTrue);
    expect(find.text('¿Salir del registro?'), findsOneWidget);
  });
}
