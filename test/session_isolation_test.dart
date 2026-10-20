import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/auth/custom_auth/token_refresher.dart';
import 'package:dovia/backend/api_requests/api_manager.dart';
import 'package:dovia/backend/api_requests/api_users.dart';
import 'package:dovia/dovia_home_client/service_request_draft.dart';
import 'package:dovia/flutter_flow/uploaded_file.dart';

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.dir);
  final Directory dir;

  @override
  Future<String?> getApplicationSupportPath() async => dir.path;
}

Future<void> _signIn(String user) => authManager.signIn(
      authenticationToken: 'token-$user',
      refreshToken: 'refresh-$user',
      tokenExpiration: DateTime.now().add(const Duration(hours: 1)),
      authUid: user,
    );

/// Lo que cada cuenta hace queda en su cuenta, aunque se cambie de usuario
/// con algo todavía en curso.
void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await authManager.initialize();
    ApiManager.onUnauthorized = refreshSession;
    ApiManager.freshTokenIfExpired = freshTokenIfExpired;
    ApiManager.sessionGeneration = () => authManager.sessionGeneration;
    onSessionExpired = null;
  });

  test('un 401 de la cuenta A no se reintenta con el token de B', () async {
    await _signIn('a');
    final server = Completer<http.Response>();
    final sent = <String?>[];

    await http.runWithClient(() async {
      final pending = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall
          .call(authToken: authManager.authenticationToken);
      await Future<void>.delayed(Duration.zero);

      await authManager.signOut();
      await _signIn('b');
      server.complete(_json(401, {}));

      final res = await pending;
      expect(res.statusCode, 401);
    }, () {
      return MockClient((req) async {
        sent.add(req.headers['Authorization']);
        if (req.url.path.endsWith('/auth/refresh-token')) {
          return _json(200, {
            'data': {'idToken': 'token-b2', 'expiresIn': 3600},
          });
        }
        if (sent.length == 1) return server.future;
        return _json(200, {});
      });
    });

    // Solo salió el pedido original de A: ni refresh ni reintento como B.
    expect(sent, ['Bearer token-a']);
    expect(authManager.uid, 'b');
  });

  test('un 429 al renovar no cierra la sesión', () async {
    await _signIn('a');
    var expired = 0;
    onSessionExpired = (_) => expired++;

    final token = await http.runWithClient(
      refreshSession,
      () => MockClient(
          (_) async => _json(429, {'message': 'Too Many Requests'})),
    );

    expect(token, isNull);
    expect(loggedIn, isTrue);
    expect(expired, 0);
  });

  group('borrador de Dovia Home', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('draft_isolation');
      PathProviderPlatform.instance = _FakePathProvider(tmp);
    });

    tearDown(() async {
      await tmp.delete(recursive: true);
    });

    test('el borrador de A no termina guardado en la cuenta B', () async {
      await _signIn('a');
      final saving = ServiceRequestDraftStore.save(
        serviceTitle: 'Plomería',
        categoryId: 'cat-1',
        description: 'Fuga en la cocina de A',
        photos: [
          FFUploadedFile(
              name: 'a.jpg', bytes: Uint8List.fromList([1, 2, 3])),
        ],
      );
      await authManager.signOut();
      await _signIn('b');
      await saving;

      expect(await ServiceRequestDraftStore.load('Plomería'), isNull);

      await authManager.signOut();
      await _signIn('a');
      final draft = await ServiceRequestDraftStore.load('Plomería');
      expect(draft?.description, 'Fuga en la cocina de A');
      expect(draft?.photos, hasLength(1));
    });
  });
}
