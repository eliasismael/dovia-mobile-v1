import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/core/result.dart';
import 'package:dovia/repositories/offers_repository.dart';

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

/// Página [page] de un listado de [total] ofertas, con la `meta.pagination`
/// que manda el backend.
http.Response _offersPage(http.Request req, int total) {
  final page = int.parse(req.url.queryParameters['page'] ?? '1');
  final limit = int.parse(req.url.queryParameters['limit'] ?? '10');
  final start = (page - 1) * limit;
  final end = (start + limit).clamp(0, total);
  return _json(200, {
    'data': [
      for (var i = start; i < end; i++)
        {
          'id': 'offer-$i',
          'propertyId': 'prop-$i',
          'offerStatus': 'PENDING',
        },
    ],
    'meta': {
      'pagination': {
        'page': page,
        'limit': limit,
        'totalItems': total,
        'hasNextPage': end < total,
      },
    },
  });
}

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await authManager.initialize();
    await authManager.signIn(authenticationToken: 't', authUid: 'u');
  });

  test('Mis Ofertas trae todas las páginas, no solo la primera', () async {
    final pages = <String>[];
    final result = await http.runWithClient(
      () => OffersRepository().loadMyOffers(),
      () => MockClient((req) async {
        if (req.url.path.endsWith('/offers/my-offers')) {
          pages.add(req.url.queryParameters['page']!);
          return _offersPage(req, 120);
        }
        return _json(404, {});
      }),
    );

    expect(result, isA<Success>());
    expect((result as Success).data.all, hasLength(120));
    expect(pages, ['1', '2', '3']);
  });

  test('las propuestas recibidas también se recorren completas', () async {
    final result = await http.runWithClient(
      () => OffersRepository().loadProposalsOnMyProperties(),
      () => MockClient((req) async {
        if (req.url.path.endsWith('/offers/my-properties')) {
          return _offersPage(req, 75);
        }
        return _json(404, {});
      }),
    );

    expect((result as Success).data.all, hasLength(75));
  });

  test('si falla la primera página, es un error', () async {
    final result = await http.runWithClient(
      () => OffersRepository().loadMyOffers(),
      () => MockClient((req) async => _json(500, {})),
    );
    expect(result, isA<Failure>());
  });
}
