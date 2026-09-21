import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dovia/backend/api_requests/api_offers.dart';

/// `GET /offers/my-offers` viene respondiendo 500 en el entorno `dev`. La
/// llamada mandaba siempre `offerType=&offerStatus=&processStatus=` vacíos —
/// los otros cuatro filtros del mismo endpoint ya se omitían cuando no traen
/// valor—, así que ningún request salía nunca sin ellos.
///
/// Un filtro de enum vacío es un candidato razonable a romper el parseo del
/// lado del servidor, pero no está confirmado: sin token no se puede
/// distinguir desde afuera. Lo que estos tests fijan es sólo lo que depende
/// del cliente: no mandar parámetros vacíos.
///
/// Devuelve la URL que llegó a la red.
Future<Uri> _requestedUrl({
  String? page,
  String? limit,
  String? offerStatus,
}) async {
  late Uri seen;
  final client = MockClient((request) async {
    seen = request.url;
    return http.Response('{"data":{"items":[]}}', 200);
  });

  await http.runWithClient(
    () => DOVIAAPIOfferContextGroup.listMyOffersCall.call(
      authToken: 'token',
      page: page ?? '1',
      limit: limit ?? '50',
      offerStatus: offerStatus ?? '',
    ),
    () => client,
  );
  return seen;
}

/// Llamada tal como la hacen las pantallas: sólo con el token.
Future<Uri> _defaultUrl() async {
  late Uri seen;
  final client = MockClient((request) async {
    seen = request.url;
    return http.Response('{"data":{"items":[]}}', 200);
  });

  await http.runWithClient(
    () => DOVIAAPIOfferContextGroup.listMyOffersCall.call(authToken: 'token'),
    () => client,
  );
  return seen;
}

void main() {
  group('ListMyOffersCall', () {
    test('no manda ningún parámetro con valor vacío', () async {
      final url = await _defaultUrl();

      expect(url.path, endsWith('/offers/my-offers'));
      for (final entry in url.queryParameters.entries) {
        expect(entry.value, isNotEmpty,
            reason: '"${entry.key}" viaja vacío en ${url.query}');
      }
      // Los tres que iban siempre vacíos y que ninguna pantalla usa.
      expect(url.queryParameters, isNot(contains('offerType')));
      expect(url.queryParameters, isNot(contains('offerStatus')));
      expect(url.queryParameters, isNot(contains('processStatus')));
    });

    test('pagina por defecto, porque ninguna pantalla lo pide explícitamente',
        () async {
      final url = await _defaultUrl();

      expect(
          int.tryParse(url.queryParameters['page']!), greaterThanOrEqualTo(1));
      expect(int.tryParse(url.queryParameters['limit']!), greaterThan(0));
    });

    test('una paginación explícita se respeta', () async {
      final url = await _requestedUrl(page: '2', limit: '10');

      expect(url.queryParameters['page'], '2');
      expect(url.queryParameters['limit'], '10');
    });

    test('un filtro con valor sí viaja', () async {
      final url = await _requestedUrl(offerStatus: 'PENDING');

      expect(url.queryParameters['offerStatus'], 'PENDING');
    });
  });
}
