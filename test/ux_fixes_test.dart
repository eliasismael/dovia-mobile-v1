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
import 'package:dovia/backend/api_requests/api_manager.dart';
import 'package:dovia/core/api_error.dart';
import 'package:dovia/custom_code/widgets/ajustes_screen.dart';
import 'package:dovia/custom_code/widgets/custom_recover_password1.dart';
import 'package:dovia/custom_code/widgets/custom_recover_password2.dart';
import 'package:dovia/custom_code/widgets/operative_listing_profile.dart';
import 'package:dovia/index.dart' show RecoverPasswordStep2Widget, SignInWidget;
import 'package:dovia/repositories/index.dart';
import 'package:dovia/shared_components/error_state/error_state_widget.dart';

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

ApiCallResponse _res(int status, [Object? body]) =>
    ApiCallResponse(body, const {}, status);

/// Pantalla alta: los ajustes son largos y en el viewport por defecto del
/// test desbordan a lo alto por un motivo que no es el que se prueba acá.
void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(430 * 3, 6000 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Widget _withRepos(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FFAppState()),
        ChangeNotifierProvider(create: (_) => UserRepository()),
        ChangeNotifierProvider(create: (_) => PaymentsRepository()),
        ChangeNotifierProvider(create: (_) => NotificationsRepository()),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

/// La fuente de los tests (Ahem) dibuja cada letra como un cuadrado ancho y
/// algunas filas de texto desbordan solo acá. Se ignoran esos avisos; cualquier
/// otro error sigue haciendo fallar el test.
void _ignoreTextOverflow() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

/// Avanza el reloj sin esperar a que todo quede quieto: el cursor del PIN
/// titila para siempre y `pumpAndSettle` no terminaría nunca.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapText(WidgetTester tester, String text,
    {bool settle = true}) async {
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  settle ? await tester.pumpAndSettle() : await _settle(tester);
  await tester.tap(finder);
  settle ? await tester.pumpAndSettle() : await _settle(tester);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'ff_UserRole': 'CLIENT'});
    await FFAppState().initializePersistedState();
    await authManager.initialize();
  });
  tearDown(FFAppState.reset);

  group('mensajes de error', () {
    test('sin conexión lo dice, en vez del error genérico', () {
      expect(apiErrorMessage(_res(-1), 'genérico'), contains('Sin conexión'));
    });

    test('usa el message del backend o el primero de errors', () {
      expect(apiErrorMessage(_res(400, {'message': 'Correo inválido'}), 'x'),
          'Correo inválido');
      expect(
          apiErrorMessage(
              _res(400, {
                'errors': [
                  {'message': 'Falta el monto'}
                ]
              }),
              'x'),
          'Falta el monto');
      expect(apiErrorMessage(_res(400, 'texto'), 'genérico'), 'genérico');
    });

    test('un 5xx no muestra el texto del servidor', () {
      expect(
          apiErrorMessage(
              _res(502, {'message': 'Internal server error'}), 'genérico'),
          'genérico');
    });

    test('solo red y 5xx muestran el aviso de reintentar', () async {
      await authManager.signIn(authenticationToken: 't', authUid: 'u');
      expect(isRetryableLoadError(_res(-1)), isTrue);
      expect(isRetryableLoadError(_res(503)), isTrue);
      // 401 (visitante) y 404 (lista vacía en algunos endpoints) siguen
      // mostrando el estado vacío.
      expect(isRetryableLoadError(_res(401)), isFalse);
      expect(isRetryableLoadError(_res(404)), isFalse);
      expect(isRetryableLoadError(_res(200)), isFalse);
    });

    test('un visitante sin sesión nunca ve el aviso de error', () async {
      // En web los 401 llegan como error de red (sin CORS): sin esto el
      // visitante veía "Sin conexión" en Favoritos.
      await authManager.signOut();
      expect(isRetryableLoadError(_res(-1)), isFalse);
      expect(isRetryableLoadError(_res(503)), isFalse);
    });

    testWidgets('el aviso de error tiene Reintentar', (tester) async {
      var retries = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body:
              ErrorStateWidget.fromResponse(_res(-1), onRetry: () => retries++),
        ),
      ));
      expect(find.textContaining('Sin conexión'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      expect(retries, 1);
    });
  });

  group('cerrar sesión', () {
    test('borra los datos personales pero no la lista de visitas', () async {
      final app = FFAppState();
      app.UserEmail = 'a@dovia.com';
      app.addToConfirmedServiceRequests('req-1');
      app.clearUserScopedState();

      expect(app.UserEmail, '');
      expect(app.confirmedServiceRequests, ['req-1']);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ff_UserEmail'), isNull);
      expect(prefs.getString('ff_UserData'), isNull);
    });
  });

  group('eliminar cuenta (cliente)', () {
    Future<void> runDelete(WidgetTester tester, {required bool ok}) async {
      _tallView(tester);
      var signOuts = 0;
      String? sentReason;
      await tester.pumpWidget(_withRepos(AjustesScreen(
        onDeleteAccount: (reason) async {
          sentReason = reason;
          return ok;
        },
        onSignOut: () async => signOuts++,
      )));
      await _settle(tester);

      await _tapText(tester, 'Eliminar cuenta', settle: false);
      // El botón del diálogo de confirmación, el mismo que en los asociados.
      await _tapText(tester, 'Eliminar cuenta', settle: false);
      await tester.enterText(find.byType(TextField).last, 'Ya no la uso');
      await _tapText(tester, 'Enviar', settle: false);

      expect(sentReason, 'Ya no la uso');
      if (ok) {
        expect(signOuts, 1);
      } else {
        // Antes se cerraba la sesión igual y el usuario creía haber borrado
        // una cuenta que seguía activa.
        expect(signOuts, 0);
        expect(find.textContaining('No pudimos eliminar tu cuenta'),
            findsOneWidget);
      }
    }

    testWidgets('si el backend falla, avisa y no cierra sesión',
        (tester) => runDelete(tester, ok: false));
    testWidgets(
        'si sale bien, cierra sesión', (tester) => runDelete(tester, ok: true));
  });

  group('eliminar cuenta (asociados)', () {
    testWidgets('si el backend falla, no muestra éxito ni cierra sesión',
        (tester) async {
      _tallView(tester);
      var logouts = 0;
      await tester.pumpWidget(_withRepos(OperativeListingProfile(
        onDeleteAccount: (_) async => false,
        onLogout: () async => logouts++,
      )));
      await tester.pumpAndSettle();

      await _tapText(tester, 'Eliminar cuenta');
      // Confirmación y motivo: se avanza con el botón de cada diálogo.
      for (var i = 0; i < 2; i++) {
        final buttons = find.descendant(
            of: find.byType(Dialog), matching: find.byType(ElevatedButton));
        final target = buttons.evaluate().isNotEmpty
            ? buttons.last
            : find
                .descendant(
                    of: find.byType(Dialog),
                    matching: find.byType(GestureDetector))
                .last;
        await tester.tap(target);
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(seconds: 4));

      expect(
          find.textContaining('No pudimos eliminar tu cuenta'), findsOneWidget);
      expect(logouts, 0);
    });
  });

  group('recuperar contraseña', () {
    GoRouter router(Widget home) => GoRouter(routes: [
          GoRoute(path: '/', builder: (_, __) => Scaffold(body: home)),
          GoRoute(
            name: RecoverPasswordStep2Widget.routeName,
            path: '/paso2',
            builder: (_, __) => const Text('PASO 2'),
          ),
          GoRoute(
            name: SignInWidget.routeName,
            path: '/login',
            builder: (_, __) => const Text('LOGIN'),
          ),
        ]);

    testWidgets('paso 1: si el correo no sale, no pasa al paso 2',
        (tester) async {
      _tallView(tester);
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp.router(
            routerConfig: router(const CustomRecoverPassword1())));
        await tester.enterText(find.byType(TextFormField), ' a@dovia.com ');
        await tester.pumpAndSettle();
        await _tapText(tester, 'Restablecer contraseña');
      }, () => MockClient((req) async => _json(500, {})));

      expect(find.text('PASO 2'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('paso 1: con el correo enviado pasa al paso 2 (recortado)',
        (tester) async {
      _tallView(tester);
      String? sentEmail;
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp.router(
            routerConfig: router(const CustomRecoverPassword1())));
        await tester.enterText(find.byType(TextFormField), ' a@dovia.com ');
        await tester.pumpAndSettle();
        await _tapText(tester, 'Restablecer contraseña');
      },
          () => MockClient((req) async {
                sentEmail = jsonDecode(req.body)['email'];
                return _json(200, {});
              }));

      expect(sentEmail, 'a@dovia.com');
      expect(find.text('PASO 2'), findsOneWidget);
    });

    Future<void> fillStep2(WidgetTester tester) async {
      // PIN, contraseña y confirmación, en ese orden (el PIN también usa un
      // campo de texto por dentro).
      final fields = find.byType(EditableText);
      expect(fields, findsNWidgets(3));
      await tester.enterText(fields.at(0), '123456');
      await tester.enterText(fields.at(1), 'Clave123!');
      await tester.enterText(fields.at(2), 'Clave123!');
      await _settle(tester);
    }

    for (final c in [
      (status: -1, name: 'sin conexión'),
      (status: 500, name: 'error del servidor'),
    ]) {
      testWidgets('paso 2: ${c.name} no se muestra como código inválido',
          (tester) async {
        _tallView(tester);
        _ignoreTextOverflow();
        _ignoreTextOverflow();
        await http.runWithClient(() async {
          await tester.pumpWidget(MaterialApp.router(
              routerConfig:
                  router(const CustomRecoverPassword2(email: 'a@dovia.com'))));
          await fillStep2(tester);
          await _tapText(tester, 'Verificar contraseña', settle: false);
        },
            () => MockClient((req) async => c.status == -1
                ? throw http.ClientException('offline')
                : _json(c.status, {'message': 'Internal error'})));

        expect(find.text('Código inválido'), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
      });
    }

    testWidgets('paso 2: un código incorrecto sí se muestra como tal',
        (tester) async {
      _tallView(tester);
      _ignoreTextOverflow();
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp.router(
            routerConfig:
                router(const CustomRecoverPassword2(email: 'a@dovia.com'))));
        await fillStep2(tester);
        await _tapText(tester, 'Verificar contraseña', settle: false);
      },
          () => MockClient((req) async =>
              _json(400, {'message': 'Invalid verification code provided'})));

      expect(find.text('Código inválido'), findsOneWidget);
    });

    testWidgets('paso 2: al terminar va al login sin dejar volver atrás',
        (tester) async {
      _tallView(tester);
      _ignoreTextOverflow();
      late GoRouter r;
      await http.runWithClient(() async {
        r = router(const CustomRecoverPassword2(email: 'a@dovia.com'));
        await tester.pumpWidget(MaterialApp.router(routerConfig: r));
        await fillStep2(tester);
        await _tapText(tester, 'Verificar contraseña', settle: false);
        await tester.pump(const Duration(seconds: 4));
        await _settle(tester);
      }, () => MockClient((req) async => _json(200, {})));

      expect(find.text('LOGIN'), findsOneWidget);
      expect(r.canPop(), isFalse);
    });

    testWidgets('paso 2: reenviar avisa si falló', (tester) async {
      _tallView(tester);
      _ignoreTextOverflow();
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp.router(
            routerConfig:
                router(const CustomRecoverPassword2(email: 'a@dovia.com'))));
        await _settle(tester);
        await _settle(tester);
        // El contenedor limita el ancho a 350 px y, con la fuente de test, el
        // link cae fuera de la fila: se dispara su onTap directamente.
        tester
            .widget<GestureDetector>(find
                .ancestor(
                    of: find.text('volver a enviar'),
                    matching: find.byType(GestureDetector))
                .first)
            .onTap!();
        await _settle(tester);
      }, () => MockClient((req) async => _json(500, {})));

      expect(find.textContaining('Se reenvió'), findsNothing);
      expect(find.textContaining('No pudimos reenviar'), findsOneWidget);
    });
  });
}
