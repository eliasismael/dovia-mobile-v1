import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/auth/custom_auth/token_refresher.dart' as refresher;
import 'package:dovia/auth/google/cognito_google_config.dart';
import 'package:dovia/auth/google/google_oauth_client.dart';
import 'package:dovia/auth/google/google_sign_in_flow.dart';
import 'package:dovia/auth/registration_progress.dart';
import 'package:dovia/custom_code/widgets/custom_datos_widget.dart';
import 'package:dovia/index.dart'
    show
        Datos2Widget,
        DOVIACLIENTHomePageWidget,
        GoogleDatosWidget,
        SignInWidget,
        SolicitudEnRevisionWidget;

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

/// JWT de prueba (sin firma real): solo importa el payload.
String _jwt(Map<String, dynamic> claims) {
  String part(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part(claims)}.firma';
}

/// Reemplaza al plugin (que abre el navegador del sistema).
class _FakeGoogle implements GoogleOAuthClient {
  GoogleTokens? signInResult;
  Object? refreshError;
  GoogleTokens? refreshResult;
  int refreshCalls = 0;
  int logoutCalls = 0;
  String? lastRefreshToken;

  @override
  Future<GoogleTokens?> signIn(CognitoGoogleConfig config) async =>
      signInResult;

  @override
  Future<GoogleTokens> refresh(
      CognitoGoogleConfig config, String refreshToken) async {
    refreshCalls++;
    lastRefreshToken = refreshToken;
    if (refreshError != null) throw refreshError!;
    return refreshResult!;
  }

  @override
  Future<void> logout(CognitoGoogleConfig config) async => logoutCalls++;
}

GoogleTokens _tokens({String? customId, String refresh = 'rt-google'}) =>
    GoogleTokens(
      idToken: _jwt({
        'email': 'ana@gmail.com',
        'given_name': 'Ana',
        'family_name': 'Pérez',
        if (customId != null) 'custom:id': customId,
      }),
      refreshToken: refresh,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

GoRouter _router() => GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, __) => Scaffold(
          body: Column(children: [
            TextButton(
              onPressed: () =>
                  continueWithGoogle(context, intent: GoogleAuthIntent.signIn),
              child: const Text('login'),
            ),
            TextButton(
              onPressed: () =>
                  continueWithGoogle(context, intent: GoogleAuthIntent.signUp),
              child: const Text('crear'),
            ),
          ]),
        ),
      ),
      for (final name in [
        DOVIACLIENTHomePageWidget.routeName,
        GoogleDatosWidget.routeName,
        Datos2Widget.routeName,
        SignInWidget.routeName,
        SolicitudEnRevisionWidget.routeName,
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
  late _FakeGoogle google;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    await RegistrationProgress.clear();
    await authManager.initialize();
    google = _FakeGoogle();
    googleOAuthClient = google;
  });
  tearDown(() async {
    await authManager.signOut();
    FFAppState.reset();
  });

  group('configuración', () {
    test('cada entorno usa su dominio y su cliente móvil', () {
      final dev = CognitoGoogleConfig.forEnvironment('DEV')!;
      expect(dev.clientId, '4s7ttd11648lb2mr9cdsvcco3g');
      expect(dev.authorizationEndpoint,
          'https://us-east-20pc8xmyvl.auth.us-east-2.amazoncognito.com/oauth2/authorize');
      final stg = CognitoGoogleConfig.forEnvironment('STAGING')!;
      expect(stg.clientId, '4t90gdei6t163sv0vuq70qfeqb');
      expect(stg.tokenEndpoint,
          'https://us-east-2amy5dp2mj.auth.us-east-2.amazoncognito.com/oauth2/token');
      // Producción todavía no tiene valores: no se ofrece Google.
      expect(CognitoGoogleConfig.forEnvironment(''), isNull);
      expect(dev.scopes, ['openid', 'email', 'profile']);
      expect(stg.scopes, ['openid', 'email']);
      expect(CognitoGoogleConfig.redirectUrl,
          'com.mycompany.dovia://oauth/callback');
    });

    test('el discovery sale del User Pool ID, no del dominio', () {
      const sinPool = CognitoGoogleConfig(domain: 'https://x', clientId: 'c');
      expect(sinPool.discoveryUrl, isNull);
      const conPool = CognitoGoogleConfig(
          domain: 'https://x', clientId: 'c', userPoolId: 'us-east-2_AbC');
      expect(conPool.discoveryUrl,
          'https://cognito-idp.us-east-2.amazonaws.com/us-east-2_AbC/.well-known/openid-configuration');
    });

    test('lee los claims del ID token', () {
      final t = _jwt({'custom:id': 'u1', 'exp': 2000000000});
      expect(jwtClaims(t)['custom:id'], 'u1');
      expect(
          jwtExpiration(t), DateTime.fromMillisecondsSinceEpoch(2e12.toInt()));
      expect(jwtClaims('no-es-un-jwt'), isEmpty);
    });
  });

  group('sesión de Google', () {
    test('el refresh token va cifrado, no a las preferencias', () async {
      await authManager.signIn(
        authenticationToken: 'id',
        refreshToken: 'rt-google',
        provider: kGoogleAuthProvider,
      );
      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('_auth_refresh_token_'), isNull);
      expect(
          await const FlutterSecureStorage().read(key: '_auth_refresh_token_'),
          'rt-google');

      // Al reabrir la app se recupera de ahí.
      await authManager.initialize();
      expect(authManager.isGoogleSession, isTrue);
      expect(authManager.refreshToken, 'rt-google');
      expect(loggedIn, isTrue);

      // Cerrar sesión lo borra.
      await authManager.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(
          await const FlutterSecureStorage().read(key: '_auth_refresh_token_'),
          isNull);
    });

    test('se renueva directo en Cognito, no con la API', () async {
      await authManager.signIn(
        authenticationToken: 'id-viejo',
        refreshToken: 'rt-google',
        provider: kGoogleAuthProvider,
      );
      final nuevo = _jwt({'custom:id': 'u-mongo'});
      google.refreshResult = GoogleTokens(idToken: nuevo);
      final apiCalls = <Uri>[];

      final token = await http.runWithClient(
        refresher.refreshSession,
        () => MockClient((req) async {
          apiCalls.add(req.url);
          return _json(500, {});
        }),
      );

      expect(token, nuevo);
      expect(google.lastRefreshToken, 'rt-google');
      expect(apiCalls, isEmpty);
      expect(authManager.authenticationToken, nuevo);
      // Sin refresh nuevo se conserva el anterior.
      expect(authManager.refreshToken, 'rt-google');
      // Tras el alta el `custom:id` llega en el token renovado.
      expect(currentUserUid, 'u-mongo');
    });

    test('si Cognito rechaza el refresh, la sesión se cierra', () async {
      await authManager.signIn(
        authenticationToken: 'id',
        refreshToken: 'rt-google',
        provider: kGoogleAuthProvider,
      );
      google.refreshError = const GoogleRefreshRejected();
      String? aviso;
      refresher.onSessionExpired = (m) => aviso = m;
      addTearDown(() => refresher.onSessionExpired = null);

      expect(await refresher.refreshSession(), isNull);
      expect(loggedIn, isFalse);
      expect(aviso, refresher.sessionExpiredMessage);
    });

    test('un error de red no cierra la sesión', () async {
      await authManager.signIn(
        authenticationToken: 'id',
        refreshToken: 'rt-google',
        provider: kGoogleAuthProvider,
      );
      google.refreshError = Exception('sin red');
      expect(await refresher.refreshSession(), isNull);
      expect(loggedIn, isTrue);
    });
  });

  group('continuar con Google', () {
    Future<void> run(
      WidgetTester tester,
      String button,
      Future<http.Response> Function(http.Request) backend, {
      Future<void> Function()? then,
    }) async {
      await http.runWithClient(() async {
        await tester.pumpWidget(ChangeNotifierProvider.value(
          value: FFAppState(),
          child: MaterialApp.router(routerConfig: _router()),
        ));
        await tester.tap(find.text(button));
        await _settle(tester);
        await then?.call();
      }, () => MockClient(backend));
    }

    testWidgets('si cierra el navegador no pasa nada', (tester) async {
      google.signInResult = null;
      await run(tester, 'login', (_) async => _json(200, {}));
      expect(loggedIn, isFalse);
      expect(find.textContaining('RUTA'), findsNothing);
    });

    testWidgets('un cliente que ya tiene cuenta entra a su home',
        (tester) async {
      google.signInResult = _tokens(customId: 'u1');
      await run(
          tester,
          'login',
          (_) async => _json(200, {
                'data': {
                  'id': 'u1',
                  'roles': ['CLIENT'],
                  'verified': true,
                  'active': true,
                  'identificationDocumentUrl': 'https://s3/dpi.jpg',
                }
              }));

      expect(find.text('RUTA ${DOVIACLIENTHomePageWidget.routeName}'),
          findsOneWidget);
      expect(authManager.isGoogleSession, isTrue);
      expect(currentUserUid, 'u1');
      expect(FFAppState().UserEmail, 'ana@gmail.com');
    });

    testWidgets(
        'un cliente sin identificación hace el onboarding aunque tenga rol',
        (tester) async {
      google.signInResult = _tokens(customId: 'u1');
      await run(
          tester,
          'login',
          (_) async => _json(200, {
                'data': {
                  'id': 'u1',
                  'roles': ['CLIENT'],
                  'verified': true,
                  'active': true,
                }
              }));

      expect(find.text('RUTA ${Datos2Widget.routeName}'), findsOneWidget);
    });

    testWidgets('con cuenta pero sin rol, retoma el registro', (tester) async {
      google.signInResult = _tokens(customId: 'u1');
      await run(
          tester,
          'login',
          (_) async => _json(200, {
                'data': {'id': 'u1', 'roles': [], 'verified': false}
              }));

      expect(find.text('RUTA ${Datos2Widget.routeName}'), findsOneWidget);
    });

    testWidgets('asociado pendiente ve "solicitud en revisión"',
        (tester) async {
      google.signInResult = _tokens(customId: 'u1');
      await run(
          tester,
          'login',
          (_) async => _json(200, {
                'data': {
                  'id': 'u1',
                  'roles': ['HOME_ASSOCIATE'],
                  'verified': false,
                  'criminalRecordUrl': 'a.pdf',
                  'policeRecordUrl': 'b.pdf',
                  'utilityBillUrl': 'c.pdf',
                  'address': 'Calle 1',
                }
              }));

      expect(find.text('RUTA ${SolicitudEnRevisionWidget.routeName}'),
          findsOneWidget);
    });

    testWidgets(
        'desde el login, sin cuenta pregunta antes de crearla; cancelar '
        'cierra la sesión', (tester) async {
      google.signInResult = _tokens();
      await run(tester, 'login', (_) async => _json(401, {}), then: () async {
        expect(find.text('No encontramos tu cuenta'), findsOneWidget);
        expect(find.textContaining('ana@gmail.com'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await _settle(tester);
      });

      expect(loggedIn, isFalse);
      expect(google.logoutCalls, 1);
      expect(find.textContaining('RUTA'), findsNothing);
    });

    testWidgets('desde el login, "Crear cuenta" lleva a completar los datos',
        (tester) async {
      google.signInResult = _tokens();
      await run(tester, 'login', (_) async => _json(401, {}), then: () async {
        await tester.tap(find.text('Crear cuenta'));
        await _settle(tester);
      });

      expect(find.text('RUTA ${GoogleDatosWidget.routeName}'), findsOneWidget);
      expect(RegistrationProgress.step, RegistrationProgress.googleData);
      expect(loggedIn, isTrue);
    });

    testWidgets('desde crear cuenta va directo a completar los datos',
        (tester) async {
      google.signInResult = _tokens();
      await run(tester, 'crear', (_) async => _json(401, {}));

      expect(find.text('No encontramos tu cuenta'), findsNothing);
      expect(find.text('RUTA ${GoogleDatosWidget.routeName}'), findsOneWidget);
    });

    testWidgets('con custom:id un error del perfil nunca crea cuenta',
        (tester) async {
      google.signInResult = _tokens(customId: 'u1');
      await run(tester, 'crear', (_) async => _json(401, {}));

      expect(find.textContaining('RUTA'), findsNothing);
      expect(
          find.textContaining('No pudimos cargar tu cuenta'), findsOneWidget);
      expect(loggedIn, isFalse);
    });

    testWidgets('cuenta deshabilitada: lo avisa y no entra', (tester) async {
      google.signInResult = _tokens(customId: 'u1');
      await run(tester, 'login', (_) async => _json(403, {}));

      expect(find.textContaining('deshabilitada'), findsOneWidget);
      expect(loggedIn, isFalse);
    });
  });

  group('alta federada', () {
    Future<void> signedInWithGoogle() => authManager.signIn(
          authenticationToken: _jwt({'email': 'ana@gmail.com'}),
          refreshToken: 'rt-google',
          provider: kGoogleAuthProvider,
        );

    Future<String?> complete(
            Future<http.Response> Function(http.Request) backend) =>
        http.runWithClient(
          () => completeGoogleRegistration(
            name: 'Ana',
            lastname: 'Pérez',
            day: '05',
            month: '06',
            year: '1995',
            gender: 'FEMALE',
            phoneCountryCode: '+502',
            phoneNumber: '55551234',
            nationality: 'Guatemala',
          ),
          () => MockClient(backend),
        );

    test('manda solo los datos permitidos y renueva en Cognito', () async {
      await signedInWithGoogle();
      google.refreshResult = GoogleTokens(idToken: _jwt({'custom:id': 'u9'}));
      late http.Request sent;

      final error = await complete((req) async {
        sent = req;
        return _json(201, {
          'data': {'id': 'u9', 'roles': [], 'verified': false}
        });
      });

      expect(error, isNull);
      expect(sent.url.path, endsWith('/auth/federated/complete-registration'));
      expect(sent.headers['Authorization'], startsWith('Bearer '));
      expect(jsonDecode(sent.body), {
        'name': 'Ana',
        'lastname': 'Pérez',
        'birthDate': '05/06/1995',
        'gender': 'FEMALE',
        'phone': {'countryCode': '+502', 'number': '55551234'},
        'nationality': 'Guatemala',
      });
      expect(google.refreshCalls, 1);
      expect(currentUserUid, 'u9');
    });

    test('correo con cuenta de contraseña: lo dice, no crea otra', () async {
      await signedInWithGoogle();
      final error = await complete((_) async => _json(409, {
            'success': false,
            'errors': [
              {'code': 'ACCOUNT_METHOD_CONFLICT'}
            ],
          }));
      expect(error, accountMethodConflictMessage);
      expect(google.refreshCalls, 0);
    });

    test('identidad inconsistente: deriva a soporte', () async {
      await signedInWithGoogle();
      final error = await complete(
          (_) async => _json(409, {'message': 'FEDERATED_IDENTITY_CONFLICT'}));
      expect(error, federatedIdentityConflictMessage);
    });
  });

  group('formulario de datos con Google', () {
    testWidgets('no pide contraseña y trae el nombre de Google',
        (tester) async {
      tester.view.physicalSize = const Size(412 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final original = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);

      await authManager.signIn(
        authenticationToken:
            _jwt({'given_name': 'Ana', 'family_name': 'Pérez'}),
        provider: kGoogleAuthProvider,
      );
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: const MaterialApp(
          home: Scaffold(body: CustomDatosWidget(googleAccount: true)),
        ),
      ));
      await _settle(tester);

      expect(
          find.textContaining('Contraseña', findRichText: true), findsNothing);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Pérez'), findsOneWidget);
    });

    testWidgets('el registro con correo sigue pidiendo contraseña',
        (tester) async {
      tester.view.physicalSize = const Size(412 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final original = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);

      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: const MaterialApp(home: Scaffold(body: CustomDatosWidget())),
      ));
      await _settle(tester);

      expect(
          find.textContaining('Contraseña', findRichText: true), findsWidgets);
    });
  });
}
