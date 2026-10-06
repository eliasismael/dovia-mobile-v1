import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/backend/api_requests/api_users.dart';
import 'package:dovia/custom_code/widgets/dovia_associate_form_widget.dart';
import 'package:dovia/custom_code/widgets/operative_listing_profile.dart';
import 'package:dovia/repositories/index.dart';
import 'package:dovia/flutter_flow/flutter_flow_drop_down.dart';

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

const _zones = [
  {'id': 'z-1', 'name': 'Zona 10'},
  {'id': 'z-2', 'name': 'Mixco'},
];

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// El asociado elige su zona de trabajo de `GET /users/work-zones` (antes
/// había un mapa que no guardaba nada) y se manda como `workZoneId`.
void main() {
  group('API', () {
    test('lista las zonas válidas de la respuesta', () {
      final zones = UserWorkZone.listFrom({
        'data': [
          ..._zones,
          {'id': '', 'name': 'sin id'},
          {'id': 'z-3'},
        ],
      });
      expect(zones.map((z) => z.id), ['z-1', 'z-2']);
      expect(zones.first.name, 'Zona 10');
      expect(UserWorkZone.listFrom(null), isEmpty);
    });

    test('el PATCH manda workZoneId solo si se eligió', () async {
      final bodies = <Map<String, dynamic>>[];
      await http.runWithClient(() async {
        final call = DOVIAAPIUserContextGroup.updateUserProfileCall;
        await call.call(userId: 'u', authToken: 't', workZoneId: 'z-1');
        await call.call(userId: 'u', authToken: 't', address: 'Calle 1');
      },
          () => MockClient((req) async {
                bodies.add(jsonDecode(req.body) as Map<String, dynamic>);
                return _json(200, {'data': {}});
              }));
      expect(bodies[0], {'workZoneId': 'z-1'});
      expect(bodies[1], {'address': 'Calle 1'});
    });

    test('lee la zona guardada del perfil', () {
      final call = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall;
      expect(
          call.workZoneId({
            'data': {
              'workZone': {'id': 'z-2', 'name': 'Mixco'}
            }
          }),
          'z-2');
      expect(
          call.workZoneId({
            'data': {'workZone': null}
          }),
          isNull);
    });
  });

  group('formulario', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await FFAppState().initializePersistedState();
    });
    tearDown(FFAppState.reset);

    Future<void> pump(
      WidgetTester tester, {
      http.Response? zones,
      Map<String, dynamic> profile = const {},
    }) async {
      tester.view.physicalSize = const Size(412 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final original = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);

      await http.runWithClient(() async {
        await tester.pumpWidget(ChangeNotifierProvider.value(
          value: FFAppState(),
          child: const MaterialApp(
            home: Scaffold(body: DoviaAssociateFormWidget()),
          ),
        ));
        await _settle(tester);
      },
          () => MockClient((req) async => req.url.path.endsWith('/work-zones')
              ? (zones ?? _json(200, {'data': _zones}))
              : _json(200, {'data': profile})));
    }

    Finder missing(String field) => find.textContaining(field);

    testWidgets('pide elegir la zona y la quita de lo que falta al elegirla',
        (tester) async {
      await pump(tester);

      expect(find.text('Selecciona la zona donde trabajarás'), findsOneWidget);
      expect(missing('zona de trabajo'), findsOneWidget);

      final dropDown = find.byType(FlutterFlowDropDown<String>);
      await tester.ensureVisible(dropDown);
      await _settle(tester);
      await tester.tap(dropDown);
      await _settle(tester);
      await tester.tap(find.text('Mixco').last);
      await _settle(tester);

      expect(find.text('Mixco'), findsOneWidget);
      expect(missing('zona de trabajo'), findsNothing);
      // Lo demás obligatorio sigue faltando.
      expect(missing('fecha de la entrevista'), findsOneWidget);
    });

    testWidgets('si ya tenía zona guardada, viene elegida', (tester) async {
      await pump(tester, profile: {
        'workZone': {'id': 'z-1', 'name': 'Zona 10'}
      });

      expect(find.text('Zona 10'), findsOneWidget);
      expect(missing('zona de trabajo'), findsNothing);
    });

    testWidgets('una zona guardada que ya no está activa no se preselecciona',
        (tester) async {
      await pump(tester, profile: {
        'workZone': {'id': 'vieja', 'name': 'Zona vieja'}
      });

      expect(find.text('Zona vieja'), findsNothing);
      expect(missing('zona de trabajo'), findsOneWidget);
    });

    testWidgets('si no cargan las zonas ofrece reintentar y no bloquea',
        (tester) async {
      await pump(tester, zones: _json(500, {'message': 'error'}));

      expect(find.text('No pudimos cargar las zonas.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(missing('zona de trabajo'), findsNothing);
    });

    testWidgets('sin zonas configuradas no muestra la sección', (tester) async {
      await pump(tester, zones: _json(200, {'data': []}));

      expect(find.text('Zona de trabajo'), findsNothing);
      expect(missing('zona de trabajo'), findsNothing);
    });
  });

  group('ajustes del asociado', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'ff_UserRole': 'SHOWING_AGENT'});
      await FFAppState().initializePersistedState();
      await authManager.initialize();
      await authManager.signIn(authenticationToken: 't', authUid: 'u');
    });
    tearDown(FFAppState.reset);

    testWidgets('muestra la zona y la cambia desde "Editar datos"',
        (tester) async {
      tester.view.physicalSize = const Size(430 * 3, 6000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final original = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);

      var zone = {'id': 'z-1', 'name': 'Zona 10'};
      final patches = <Map<String, dynamic>>[];
      Map<String, dynamic> profile() => {
            'data': {
              'id': 'u',
              'active': true,
              'roles': ['SHOWING_AGENT'],
              'fullName': {'name': 'Ana', 'lastname': 'Pérez'},
              'workZone': zone,
            }
          };

      await http.runWithClient(() async {
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FFAppState()),
            ChangeNotifierProvider(create: (_) => UserRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: OperativeListingProfile()),
          ),
        ));
        await _settle(tester);

        expect(find.text('Zona de trabajo'), findsOneWidget);
        expect(find.text('Zona 10'), findsOneWidget);

        await tester.tap(find.text('Editar datos'));
        await _settle(tester);
        await tester.tap(find.byType(DropdownButton<String>).last);
        await _settle(tester);
        await tester.tap(find.text('Mixco').last);
        await _settle(tester);
        await tester.tap(find.text('Guardar'));
        await _settle(tester);
      },
          () => MockClient((req) async {
                if (req.url.path.endsWith('/work-zones')) {
                  return _json(200, {'data': _zones});
                }
                if (req.method == 'PATCH') {
                  final body = jsonDecode(req.body) as Map<String, dynamic>;
                  patches.add(body);
                  if (body['workZoneId'] == 'z-2') {
                    zone = {'id': 'z-2', 'name': 'Mixco'};
                  }
                  return _json(200, {'data': {}});
                }
                if (req.url.path.endsWith('/users/me')) {
                  return _json(200, profile());
                }
                return _json(200, {'data': {}});
              }));

      expect(patches.single['workZoneId'], 'z-2');
      expect(find.text('Mixco'), findsOneWidget);
      expect(find.text('Zona 10'), findsNothing);
    });
  });
}
