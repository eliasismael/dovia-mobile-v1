import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/repositories/favorites_repository.dart';
import 'package:dovia/repositories/payments_repository.dart';
import 'package:dovia/repositories/properties_repository.dart';
import 'package:dovia/repositories/visits_repository.dart';

http.Response _json(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

/// Al probar: se cerraba sesión, se entraba con otra cuenta y por un momento
/// se veían los datos de la anterior. La causa: una carga de la cuenta A
/// seguía en curso al cerrar sesión, su respuesta llegaba después de limpiar
/// los repositorios y los volvía a llenar. Ahora se descarta.
void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({'ff_UserRole': 'CLIENT'});
    await FFAppState().initializePersistedState();
    await authManager.initialize();
    await authManager.signIn(
      authenticationToken: 'token-a',
      refreshToken: 'refresh-a',
      tokenExpiration: DateTime.now().add(const Duration(hours: 1)),
      authUid: 'user-a',
    );
  });
  tearDown(FFAppState.reset);

  /// Corre [load] con la respuesta de la cuenta A colgada, cierra sesión y
  /// entra B (limpiando como hace main.dart) y recién ahí deja llegar la
  /// respuesta de A.
  Future<void> switchAccountDuringLoad({
    required Future<void> Function() load,
    required void Function() clear,
    required Object responseOfA,
  }) async {
    final server = Completer<http.Response>();
    await http.runWithClient(() async {
      final pending = load();
      await Future<void>.delayed(Duration.zero);

      await authManager.signOut();
      clear();
      await authManager.signIn(
        authenticationToken: 'token-b',
        refreshToken: 'refresh-b',
        tokenExpiration: DateTime.now().add(const Duration(hours: 1)),
        authUid: 'user-b',
      );

      server.complete(_json(responseOfA));
      await pending;
    }, () => MockClient((_) => server.future));
  }

  test('los favoritos de A no aparecen en la cuenta B', () async {
    final repo = FavoritesRepository();
    await switchAccountDuringLoad(
      load: () => repo.loadDefaultFavorites(),
      clear: repo.clear,
      responseOfA: {
        'data': [
          {'id': 'prop-de-a', 'name': 'Casa de A'},
        ],
      },
    );
    expect(repo.defaultFavorites, isEmpty);
    expect(repo.isFavorited('prop-de-a'), isFalse);
    expect(repo.isLoading, isFalse);
  });

  test('B no hereda la suscripción Premium de A', () async {
    final repo = PaymentsRepository();
    await switchAccountDuringLoad(
      load: () => repo.loadCurrentSubscription(),
      clear: repo.clear,
      responseOfA: {
        'id': 'sub-a',
        'status': 'ACTIVE',
        'planId': 'premium',
      },
    );
    expect(repo.currentSubscription, isNull);
    expect(repo.subscriptionLoaded, isFalse);
    expect(repo.isLoading, isFalse);
  });

  test('las visitas de A no aparecen en la cuenta B', () async {
    final repo = VisitsRepository();
    await switchAccountDuringLoad(
      load: () => repo.loadMyVisits(),
      clear: repo.clear,
      responseOfA: {
        'data': [
          {'id': 'visita-de-a'},
        ],
      },
    );
    expect(repo.myVisits, isEmpty);
    expect(repo.isLoading, isFalse);
  });

  test('el Inicio de A no queda en caché para B', () async {
    final repo = PropertiesRepository();
    await switchAccountDuringLoad(
      load: () => repo.loadHomeProperties(),
      clear: repo.clear,
      responseOfA: {
        'data': [
          {'id': 'prop-de-a', 'name': 'Casa de A', 'isFavorite': true},
        ],
      },
    );
    expect(repo.homeProperties, isEmpty);
    expect(repo.isLoadingHome, isFalse);
  });
}
