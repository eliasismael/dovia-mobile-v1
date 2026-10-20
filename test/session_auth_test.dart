import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/auth/custom_auth/session_restore.dart';
import 'package:dovia/auth/custom_auth/token_refresher.dart';
import 'package:dovia/backend/api_requests/api_manager.dart';
import 'package:dovia/backend/api_requests/api_users.dart';

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

http.Response _refreshOk(String idToken, {int expiresIn = 3600}) =>
    _json(200, {
      'data': {
        'idToken': idToken,
        'refreshToken': 'refresh-2',
        'expiresIn': expiresIn,
      },
    });

/// Deja una sesión guardada como la dejaba una versión anterior de la app
/// (tokens en las preferencias); `initialize()` la migra.
Future<void> _storedSession({
  String token = 'token-viejo',
  String? refresh = 'refresh-1',
  String? uid = 'user-1',
  DateTime? expiration,
}) async {
  FlutterSecureStorage.setMockInitialValues({});
  SharedPreferences.setMockInitialValues({
    '_auth_authentication_token_': token,
    if (refresh != null) '_auth_refresh_token_': refresh,
    if (uid != null) '_auth_uid_': uid,
    if (expiration != null)
      '_auth_token_expiration_': expiration.millisecondsSinceEpoch,
  });
  await authManager.initialize();
}

Future<ApiCallResponse> _getMyProfile() => DOVIAAPIUserContextGroup
    .getAuthenticatedUserProfileCall
    .call(authToken: authManager.authenticationToken);

void main() {
  setUp(() {
    ApiManager.onUnauthorized = refreshSession;
    ApiManager.freshTokenIfExpired = freshTokenIfExpired;
    onSessionExpired = null;
  });

  group('al abrir la app', () {
    test('con el idToken vencido pero con refreshToken la sesión sigue',
        () async {
      await _storedSession(
          expiration: DateTime.now().subtract(const Duration(hours: 2)));
      expect(loggedIn, isTrue);
    });

    test('sin refreshToken y con el token vencido, la sesión no sigue',
        () async {
      await _storedSession(
        refresh: null,
        expiration: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(loggedIn, isFalse);
    });

    test('restoreSession renueva el token guardado', () async {
      await _storedSession();
      final refreshCalls = <http.Request>[];
      await http.runWithClient(
        () => restoreSession(),
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            refreshCalls.add(req);
            return _refreshOk('token-nuevo');
          }
          return _json(200, {
            'data': {'id': 'user-1'}
          });
        }),
      );
      // Antes de arreglar `currentUser`, `loggedIn` daba false al arrancar y
      // esto no llamaba nunca al backend.
      expect(refreshCalls, hasLength(1));
      expect(jsonDecode(refreshCalls.single.body)['refreshToken'],
          'refresh-1');
      expect(authManager.authenticationToken, 'token-nuevo');
      expect(authManager.refreshToken, 'refresh-2');
      expect(authManager.tokenExpiration, isNotNull);
      expect(authManager.uid, 'user-1');
    });

    test('restoreSession completa el uid vacío con el perfil', () async {
      await _storedSession(uid: null);
      await http.runWithClient(
        () async {
          await restoreSession();
          // El backfill no frena el arranque: se espera a que termine.
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            return _refreshOk('token-nuevo');
          }
          if (req.url.path.endsWith('/users/me')) {
            return _json(200, {
              'data': {'id': 'user-desde-perfil'}
            });
          }
          return _json(404, {});
        }),
      );
      expect(currentUserUid, 'user-desde-perfil');
    });

    test('con el token vigente abre sin esperar a la red y renueva después',
        () async {
      await _storedSession(
          expiration: DateTime.now().add(const Duration(minutes: 40)));
      final server = Completer<http.Response>();
      await http.runWithClient(
        () async {
          // El refresh queda colgado: restoreSession igual termina.
          await restoreSession()
              .timeout(const Duration(seconds: 1), onTimeout: () {
            fail('restoreSession esperó a la red con el token vigente');
          });
          expect(authManager.authenticationToken, 'token-viejo');

          server.complete(_refreshOk('token-nuevo'));
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        () => MockClient((req) => server.future),
      );
      expect(authManager.authenticationToken, 'token-nuevo');
    });

    test('con el token por vencer lo renueva al abrir', () async {
      await _storedSession(
          expiration: DateTime.now().add(const Duration(minutes: 2)));
      await http.runWithClient(
        () => restoreSession(),
        () => MockClient((req) async => _refreshOk('token-nuevo')),
      );
      expect(authManager.authenticationToken, 'token-nuevo');
    });

    test('sin conexión no cierra la sesión', () async {
      await _storedSession();
      await http.runWithClient(
        () => restoreSession(),
        () => MockClient((req) async => throw http.ClientException('offline')),
      );
      expect(loggedIn, isTrue);
      expect(authManager.authenticationToken, 'token-viejo');
    });
  });

  group('401 a mitad de uso', () {
    test('se renueva el token y se reintenta una vez con el nuevo', () async {
      await _storedSession();
      final authHeaders = <String?>[];
      var refreshes = 0;
      final res = await http.runWithClient(
        _getMyProfile,
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            refreshes++;
            return _refreshOk('token-nuevo');
          }
          authHeaders.add(req.headers['Authorization']);
          return req.headers['Authorization'] == 'Bearer token-nuevo'
              ? _json(200, {
                  'data': {'id': 'user-1'}
                })
              : _json(401, {'message': 'Unauthorized'});
        }),
      );
      expect(res.succeeded, isTrue);
      expect(refreshes, 1);
      expect(authHeaders, ['Bearer token-viejo', 'Bearer token-nuevo']);
      expect(authManager.authenticationToken, 'token-nuevo');
      // Renovar no cambia de usuario.
      expect(authManager.uid, 'user-1');
    });

    test('varias llamadas con 401 a la vez hacen un solo refresh', () async {
      await _storedSession();
      var refreshes = 0;
      final results = await http.runWithClient(
        () => Future.wait(List.generate(5, (_) => _getMyProfile())),
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            refreshes++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return _refreshOk('token-nuevo');
          }
          return req.headers['Authorization'] == 'Bearer token-nuevo'
              ? _json(200, {'data': {}})
              : _json(401, {});
        }),
      );
      expect(refreshes, 1);
      expect(results.every((r) => r.succeeded), isTrue);
    });

    test('si el backend rechaza el refresh, cierra sesión y avisa', () async {
      await _storedSession();
      var expired = 0;
      String? message;
      onSessionExpired = (m) {
        expired++;
        message = m;
      };
      final res = await http.runWithClient(
        _getMyProfile,
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            return _json(401, {'message': 'Refresh Token has expired'});
          }
          return _json(401, {});
        }),
      );
      expect(res.statusCode, 401);
      expect(loggedIn, isFalse);
      expect(authManager.authenticationToken, isNull);
      expect(expired, 1);
      expect(message, sessionExpiredMessage);
    });

    test('cuenta deshabilitada: cierra sesión con ese motivo', () async {
      // Desde dcb0e24e el backend rechaza el refresh de usuarios inactivos o
      // suspendidos con 403 USER_DISABLED.
      await _storedSession();
      String? message;
      onSessionExpired = (m) => message = m;
      await http.runWithClient(
        _getMyProfile,
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            return _json(403, {
              'errors': [
                {'code': 'USER_DISABLED'}
              ]
            });
          }
          return _json(401, {});
        }),
      );
      expect(loggedIn, isFalse);
      expect(message, accountDisabledMessage);
    });

    test('sin conexión durante el refresh no reintenta ni cierra sesión',
        () async {
      await _storedSession();
      var calls = 0;
      final res = await http.runWithClient(
        _getMyProfile,
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            throw http.ClientException('offline');
          }
          calls++;
          return _json(401, {});
        }),
      );
      expect(res.statusCode, 401);
      expect(calls, 1);
      expect(loggedIn, isTrue);
    });

    test('un 401 del sign-in no dispara un refresh', () async {
      await _storedSession();
      var refreshes = 0;
      final res = await http.runWithClient(
        () => ApiManager.instance.makeApiCall(
          callName: 'Sign In NEW',
          apiUrl: 'https://example.test/auth/sign-in',
          callType: ApiCallType.POST,
          headers: {'Authorization': 'Bearer x'},
          body: '{}',
          bodyType: BodyType.JSON,
        ),
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) refreshes++;
          return _json(401, {});
        }),
      );
      expect(res.statusCode, 401);
      expect(refreshes, 0);
    });

    test('un pedido sin Authorization no dispara un refresh', () async {
      await _storedSession();
      var refreshes = 0;
      await http.runWithClient(
        () => ApiManager.instance.makeApiCall(
          callName: 'Algo publico',
          apiUrl: 'https://example.test/public',
          callType: ApiCallType.GET,
          headers: {},
        ),
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) refreshes++;
          return _json(401, {});
        }),
      );
      expect(refreshes, 0);
    });
  });

  group('token vencido sin ver el 401 (web)', () {
    test('se renueva antes de mandar el pedido', () async {
      // En web API Gateway devuelve los 401 sin CORS y llegan como error de
      // red: por eso se renueva antes de mandar, si ya se sabe que venció.
      await _storedSession(
          expiration: DateTime.now().subtract(const Duration(minutes: 1)));
      final sentAuth = <String?>[];
      final res = await http.runWithClient(
        _getMyProfile,
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) {
            return _refreshOk('token-nuevo');
          }
          sentAuth.add(req.headers['Authorization']);
          return req.headers['Authorization'] == 'Bearer token-nuevo'
              ? _json(200, {'data': {}})
              : throw http.ClientException('CORS');
        }),
      );
      expect(res.succeeded, isTrue);
      expect(sentAuth, ['Bearer token-nuevo']);
    });

    test('con el token vigente no se renueva', () async {
      await _storedSession(
          expiration: DateTime.now().add(const Duration(minutes: 30)));
      var refreshes = 0;
      await http.runWithClient(
        _getMyProfile,
        () => MockClient((req) async {
          if (req.url.path.endsWith('/auth/refresh-token')) refreshes++;
          return _json(200, {'data': {}});
        }),
      );
      expect(refreshes, 0);
    });
  });

  group('refreshSessionIfStale (al volver del fondo)', () {
    test('renueva si el token vence en menos de 5 minutos', () async {
      await _storedSession(
          expiration: DateTime.now().add(const Duration(minutes: 2)));
      var refreshes = 0;
      await http.runWithClient(
        refreshSessionIfStale,
        () => MockClient((req) async {
          refreshes++;
          return _refreshOk('token-nuevo');
        }),
      );
      expect(refreshes, 1);
    });

    test('no renueva si al token le queda tiempo', () async {
      await _storedSession(
          expiration: DateTime.now().add(const Duration(minutes: 40)));
      var refreshes = 0;
      await http.runWithClient(
        refreshSessionIfStale,
        () => MockClient((req) async {
          refreshes++;
          return _refreshOk('token-nuevo');
        }),
      );
      expect(refreshes, 0);
    });
  });

  group('datos de la cuenta', () {
    test('updateAuthUserData sin uid conserva el uid', () async {
      await _storedSession();
      authManager.updateAuthUserData(
        authenticationToken: 'otro',
        refreshToken: 'r',
      );
      expect(currentUserUid, 'user-1');
    });

    test('signIn guarda el uid y el vencimiento', () async {
      await _storedSession(uid: null);
      await authManager.signIn(
        authenticationToken: 't',
        refreshToken: 'r',
        authUid: 'nuevo',
        tokenExpiration: tokenExpirationFrom(3600),
      );
      expect(currentUserUid, 'nuevo');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('_auth_uid_'), 'nuevo');
      expect(prefs.getInt('_auth_token_expiration_'), isNotNull);
    });
  });

  group('tokens en almacenamiento seguro', () {
    const secure = FlutterSecureStorage();

    test('migra los tokens de las preferencias y siguen al reabrir',
        () async {
      await _storedSession();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('_auth_authentication_token_'), isNull);
      expect(prefs.getString('_auth_refresh_token_'), isNull);
      expect(await secure.read(key: '_auth_authentication_token_'),
          'token-viejo');
      expect(await secure.read(key: '_auth_refresh_token_'), 'refresh-1');

      await authManager.initialize();
      expect(loggedIn, isTrue);
      expect(authManager.authenticationToken, 'token-viejo');
      expect(authManager.refreshToken, 'refresh-1');
    });

    test('renovar guarda los tokens nuevos cifrados, no en preferencias',
        () async {
      await _storedSession();
      authManager.updateAuthUserData(
          authenticationToken: 'otro', refreshToken: 'r2');
      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('_auth_authentication_token_'), isNull);
      expect(prefs.getString('_auth_refresh_token_'), isNull);
      expect(await secure.read(key: '_auth_authentication_token_'), 'otro');
      expect(await secure.read(key: '_auth_refresh_token_'), 'r2');
    });

    test('cerrar sesión borra los tokens cifrados', () async {
      await _storedSession();
      await authManager.signOut();
      await Future<void>.delayed(Duration.zero);
      expect(await secure.read(key: '_auth_authentication_token_'), isNull);
      expect(await secure.read(key: '_auth_refresh_token_'), isNull);
      await authManager.initialize();
      expect(loggedIn, isFalse);
    });

    test('tokens sueltos de una instalación anterior no abren sesión',
        () async {
      // En iOS el Keychain sobrevive a la desinstalación; las preferencias no.
      FlutterSecureStorage.setMockInitialValues({
        '_auth_authentication_token_': 'de-antes',
        '_auth_refresh_token_': 'de-antes',
      });
      SharedPreferences.setMockInitialValues({});
      await authManager.initialize();
      expect(loggedIn, isFalse);
      expect(authManager.authenticationToken, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(await secure.read(key: '_auth_refresh_token_'), isNull);
    });
  });

  group('respuestas de una sesión anterior', () {
    test('un refresh que llega tarde no pisa la cuenta nueva', () async {
      await _storedSession();
      final response = Completer<http.Response>();
      final refresh = http.runWithClient(
        refreshSession,
        () => MockClient((req) => response.future),
      );
      await Future<void>.delayed(Duration.zero);

      await authManager.signOut();
      await authManager.signIn(
        authenticationToken: 'token-cuenta-b',
        refreshToken: 'refresh-b',
        authUid: 'user-b',
      );
      response.complete(_refreshOk('token-cuenta-a'));

      expect(await refresh, isNull);
      expect(authManager.authenticationToken, 'token-cuenta-b');
      expect(authManager.refreshToken, 'refresh-b');
      expect(currentUserUid, 'user-b');
    });

    test('un refresh rechazado que llega tarde no cierra la cuenta nueva',
        () async {
      await _storedSession();
      var expired = 0;
      onSessionExpired = (_) => expired++;
      final response = Completer<http.Response>();
      final refresh = http.runWithClient(
        refreshSession,
        () => MockClient((req) => response.future),
      );
      await Future<void>.delayed(Duration.zero);

      await authManager.signIn(
        authenticationToken: 'token-cuenta-b',
        refreshToken: 'refresh-b',
        authUid: 'user-b',
      );
      response.complete(_json(401, {'message': 'Refresh Token has expired'}));

      await refresh;
      expect(loggedIn, isTrue);
      expect(authManager.authenticationToken, 'token-cuenta-b');
      expect(expired, 0);
    });

    test('la cuenta nueva no se cuelga del refresh de la anterior', () async {
      await _storedSession();
      final old = Completer<http.Response>();
      final refreshBodies = <String>[];
      await http.runWithClient(
        () async {
          final first = refreshSession();
          await Future<void>.delayed(Duration.zero);
          await authManager.signIn(
            authenticationToken: 'token-cuenta-b',
            refreshToken: 'refresh-b',
            authUid: 'user-b',
          );
          final second = await refreshSession();
          expect(second, 'token-nuevo');
          old.complete(_refreshOk('token-cuenta-a'));
          expect(await first, isNull);
        },
        () => MockClient((req) {
          refreshBodies.add(req.body);
          return refreshBodies.length == 1
              ? old.future
              : Future.value(_refreshOk('token-nuevo'));
        }),
      );
      expect(jsonDecode(refreshBodies.last)['refreshToken'], 'refresh-b');
      expect(authManager.authenticationToken, 'token-nuevo');
      expect(currentUserUid, 'user-b');
    });
  });

  group('timeout', () {
    testWidgets('un pedido colgado termina con statusCode -1',
        (tester) async {
      // El límite real es de 60 s: testWidgets corre con el reloj simulado.
      ApiCallResponse? res;
      http.runWithClient(
        () => ApiManager.instance
            .makeApiCall(
              callName: 'Lento',
              apiUrl: 'https://example.test/slow',
              callType: ApiCallType.GET,
            )
            .then((r) => res = r),
        () => MockClient((req) => Completer<http.Response>().future),
      );
      await tester.pump(const Duration(seconds: 59));
      expect(res, isNull);
      await tester.pump(const Duration(seconds: 2));
      expect(res?.statusCode, -1);
    });
  });
}
