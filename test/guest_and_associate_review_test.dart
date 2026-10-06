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
import 'package:dovia/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import 'package:dovia/dovia_client/inicio_sesion_nueva_version/solicitud_en_revision/solicitud_en_revision_widget.dart';
import 'package:dovia/flutter_flow/nav/nav.dart'
    show homeForRole, homeRouteNameForRole;
import 'package:dovia/index.dart'
    show
        DHASSOCIATEHomePageWidget,
        DOVIACLIENTMisFavoritosWidget,
        DOVIACLIENTMisVisitasWidget,
        SHOWINGHomeWidget,
        SignInWidget;
import 'package:dovia/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

/// Router mínimo: la pantalla a probar en '/' y un marcador por cada destino.
GoRouter _router(Widget home) => GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => home),
      for (final name in [
        DOVIACLIENTMisVisitasWidget.routeName,
        DOVIACLIENTMisFavoritosWidget.routeName,
        SignInWidget.routeName,
        homeRouteNameForRole('HOME_ASSOCIATE'),
        homeRouteNameForRole('SHOWING_AGENT'),
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

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    await RegistrationProgress.load();
    await authManager.initialize();
  });
  tearDown(FFAppState.reset);

  group('invitado', () {
    for (final tab in ['Visitas', 'Favoritos']) {
      testWidgets('no puede entrar a $tab: ve el aviso de registro',
          (tester) async {
        FFAppState().UserRole = 'VISITOR';
        await tester.pumpWidget(ChangeNotifierProvider.value(
          value: FFAppState(),
          child: MaterialApp.router(
            routerConfig: _router(const Scaffold(
              bottomNavigationBar: DOVIACLIENTNavbarWidget(),
            )),
          ),
        ));
        await _settle(tester);

        await tester.tap(find.text(tab));
        await _settle(tester);

        expect(find.byType(VisitorRestrictionPopupWidget), findsOneWidget);
        expect(find.textContaining('RUTA'), findsNothing);
      });
    }

    testWidgets('un cliente con sesión sí entra a Visitas', (tester) async {
      FFAppState().UserRole = 'CLIENT';
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: MaterialApp.router(
          routerConfig: _router(const Scaffold(
            bottomNavigationBar: DOVIACLIENTNavbarWidget(),
          )),
        ),
      ));
      await _settle(tester);

      await tester.tap(find.text('Visitas'));
      await _settle(tester);

      expect(find.text('RUTA ${DOVIACLIENTMisVisitasWidget.routeName}'),
          findsOneWidget);
      expect(find.byType(VisitorRestrictionPopupWidget), findsNothing);
    });
  });

  group('asociado con la solicitud enviada', () {
    test('al abrir la app su inicio es "solicitud en revisión"', () async {
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      expect(homeForRole('HOME_ASSOCIATE'), isA<SolicitudEnRevisionWidget>());
    });

    test('sin registro pendiente entra a su home', () async {
      await RegistrationProgress.clear();
      expect(homeForRole('HOME_ASSOCIATE'), isA<DHASSOCIATEHomePageWidget>());
      expect(homeForRole('SHOWING_AGENT'), isA<SHOWINGHomeWidget>());
    });

    test('el perfil del backend dice si el formulario ya se envió', () {
      // Vale en cualquier teléfono, sin la marca local. Con esto el login ya
      // no lo vuelve a mandar al formulario.
      Map<String, dynamic> profile(Map<String, dynamic> data) => {'data': data};
      final complete = {
        'criminalRecordUrl': 'users/u/criminal.pdf',
        'policeRecordUrl': 'users/u/police.pdf',
        'utilityBillUrl': 'users/u/bill.pdf',
        'address': 'Calle 123',
      };
      expect(RegistrationProgress.associateFormSentInProfile(profile(complete)),
          isTrue);
      for (final key in complete.keys) {
        final missing = Map<String, dynamic>.from(complete)..remove(key);
        expect(
            RegistrationProgress.associateFormSentInProfile(profile(missing)),
            isFalse,
            reason: 'falta $key');
      }
      expect(
          RegistrationProgress.associateFormSentInProfile(
              profile({...complete, 'address': '  '})),
          isFalse);
      expect(RegistrationProgress.associateFormSentInProfile(null), isFalse);
    });

    test('el paso pendiente sobrevive a reabrir la app', () async {
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      // Simula el arranque: se vuelve a leer de SharedPreferences.
      await RegistrationProgress.load();
      expect(RegistrationProgress.step, RegistrationProgress.pendingReview);
    });

    Future<GoRouter> pumpReview(WidgetTester tester,
        Future<http.Response> Function(http.Request) backend) async {
      late GoRouter router;
      await http.runWithClient(() async {
        router = _router(const SolicitudEnRevisionWidget());
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await _settle(tester);
      }, () => MockClient(backend));
      return router;
    }

    testWidgets('si sigue pendiente, muestra la pantalla y los botones',
        (tester) async {
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      await pumpReview(
          tester,
          // Así llega un asociado pendiente: la cuenta está activa (si no, ni
          // podría iniciar sesión) pero todavía no fue verificado por HQ.
          (_) async => _json(200, {
                'data': {
                  'active': true,
                  'verified': false,
                  'roles': ['HOME_ASSOCIATE']
                }
              }));

      expect(find.text('Tu solicitud está en revisión'), findsOneWidget);
      expect(find.text('Actualizar estado'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
      expect(find.textContaining('No pudimos consultar'), findsNothing);
      expect(RegistrationProgress.step, RegistrationProgress.pendingReview);
    });

    testWidgets('si ya fue aprobado, entra directo a su home',
        (tester) async {
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      await pumpReview(
          tester,
          (_) async => _json(200, {
                'data': {
                  'verified': true,
                  'roles': ['SHOWING_AGENT']
                }
              }));

      expect(find.text('RUTA ${homeRouteNameForRole('SHOWING_AGENT')}'),
          findsOneWidget);
      expect(FFAppState().UserRole, 'SHOWING_AGENT');
      // La próxima vez que abra la app ya no ve la revisión.
      expect(RegistrationProgress.step, isNull);
    });

    testWidgets('sin conexión no lo saca de la pantalla y lo avisa',
        (tester) async {
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      await pumpReview(
          tester, (_) async => throw http.ClientException('offline'));

      expect(find.text('Tu solicitud está en revisión'), findsOneWidget);
      expect(find.textContaining('No pudimos consultar'), findsOneWidget);
      expect(RegistrationProgress.step, RegistrationProgress.pendingReview);
    });

    testWidgets('"Actualizar estado" vuelve a consultar y entra si ya aprobó',
        (tester) async {
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      var approved = false;
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp.router(
            routerConfig: _router(const SolicitudEnRevisionWidget())));
        await _settle(tester);
        expect(find.text('Tu solicitud está en revisión'), findsOneWidget);

        approved = true;
        await tester.tap(find.text('Actualizar estado'));
        await _settle(tester);
      },
          () => MockClient((_) async => _json(200, {
                'data': {
                  'verified': approved,
                  'roles': ['HOME_ASSOCIATE']
                }
              })));

      expect(find.text('RUTA ${homeRouteNameForRole('HOME_ASSOCIATE')}'),
          findsOneWidget);
    });

    testWidgets('"Cerrar sesión" lleva al login y olvida la revisión',
        (tester) async {
      await authManager.signIn(authenticationToken: 't', authUid: 'u');
      await RegistrationProgress.set(RegistrationProgress.pendingReview);
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp.router(
            routerConfig: _router(const SolicitudEnRevisionWidget())));
        await _settle(tester);
        await tester.tap(find.text('Cerrar sesión'));
        await _settle(tester);
      },
          () => MockClient((_) async => _json(200, {
                'data': {'verified': false}
              })));

      expect(find.text('RUTA ${SignInWidget.routeName}'), findsOneWidget);
      expect(loggedIn, isFalse);
      expect(RegistrationProgress.step, isNull);
    });
  });
}
