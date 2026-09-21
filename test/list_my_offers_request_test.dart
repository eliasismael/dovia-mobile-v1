import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dovia/backend/api_requests/api_offers.dart';

/// `GET /offers/my-offers` responde 500 cuando `page` o `limit` viajan vacíos
/// (`?page=&limit=&offerType=...`). Las pantallas que lo llaman con valores
/// funcionan; la de propiedad lo llamaba sólo con el token.
///
/// Devuelve la URL que llegó a la red.
Future<Uri> _requestedUrl({String? page, String? limit}) async {
  late Uri seen;
  final client = MockClient((request) async {
    seen = request.url;
    return http.Response('{"data":{"items":[]}}', 200);
  });

  await http.runWithClient(
    () => page == null && limit == null
        ? DOVIAAPIOfferContextGroup.listMyOffersCall.call(authToken: 'token')
        : DOVIAAPIOfferContextGroup.listMyOffersCall
            .call(authToken: 'token', page: page, limit: limit),
    () => client,
  );
  return seen;
}

void main() {
  group('ListMyOffersCall', () {
    test('sin paginación explícita no manda page ni limit vacíos', () async {
      final url = await _requestedUrl();

      expect(url.path, endsWith('/offers/my-offers'));
      expect(url.queryParameters['page'], isNotEmpty,
          reason: 'page vacío tumba el endpoint con un 500');
      expect(url.queryParameters['limit'], isNotEmpty,
          reason: 'limit vacío tumba el endpoint con un 500');
      expect(url.toString(), isNot(contains('page=&')));
      expect(url.toString(), isNot(contains('limit=&')));
    });

    test('los valores por defecto son números que el backend puede paginar',
        () async {
      final url = await _requestedUrl();

      expect(
          int.tryParse(url.queryParameters['page']!), greaterThanOrEqualTo(1));
      expect(int.tryParse(url.queryParameters['limit']!), greaterThan(0));
    });

    test('una paginación explícita se respeta', () async {
      final url = await _requestedUrl(page: '2', limit: '10');

      expect(url.queryParameters['page'], '2');
      expect(url.queryParameters['limit'], '10');
    });
  });
}
