import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dovia/backend/api_requests/presigned_upload.dart';
import 'package:dovia/dovia_home_client/upcoming_service_requests.dart';

http.Response _page(List<String> statuses, {required bool hasNext}) =>
    http.Response(
      jsonEncode({
        'data': [
          for (final (i, s) in statuses.indexed) {'id': '$s-$i', 'status': s},
        ],
        'meta': {
          'pagination': {'hasNextPage': hasNext}
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  group('Próximas visitas de Dovia Home', () {
    test('si la primera página está toda finalizada, sigue a la siguiente',
        () async {
      final pages = <String?>[];
      final response = await http.runWithClient(
        () => loadUpcomingServiceRequests(authToken: 't', wanted: 2),
        () => MockClient((req) async {
          pages.add(req.url.queryParameters['page']);
          return req.url.queryParameters['page'] == '1'
              ? _page(List.filled(20, 'FINISHED'), hasNext: true)
              : _page(['PENDING', 'TAKEN', 'FINISHED'], hasNext: false);
        }),
      );

      final data = (response.jsonBody as Map)['data'] as List;
      expect(pages, ['1', '2']);
      expect(data.map((e) => e['status']), ['PENDING', 'TAKEN']);
    });

    test('con suficientes pendientes en la primera página no pide más',
        () async {
      var calls = 0;
      await http.runWithClient(
        () => loadUpcomingServiceRequests(authToken: 't', wanted: 2),
        () => MockClient((_) async {
          calls++;
          return _page(['PENDING', 'IN_PROGRESS'], hasNext: true);
        }),
      );
      expect(calls, 1);
    });

    test('si falla una página posterior sin pendientes, devuelve el error',
        () async {
      final response = await http.runWithClient(
        () => loadUpcomingServiceRequests(authToken: 't'),
        () => MockClient((req) async => req.url.queryParameters['page'] == '1'
            ? _page(List.filled(5, 'FINISHED'), hasNext: true)
            : http.Response('{}', 500)),
      );
      expect(response.succeeded, isFalse);
    });

    test('si falla la primera página, devuelve ese error', () async {
      final response = await http.runWithClient(
        () => loadUpcomingServiceRequests(authToken: 't'),
        () => MockClient((_) async => http.Response('{}', 500)),
      );
      expect(response.succeeded, isFalse);
    });
  });

  test('una subida a S3 que nunca responde termina con timeout', () async {
    await expectLater(
      http.runWithClient(
        () => putPresigned(
          Uri.parse('https://s3.test/x'),
          body: [1],
          timeout: const Duration(milliseconds: 50),
        ),
        () => MockClient((_) => Completer<http.Response>().future),
      ),
      throwsA(isA<TimeoutException>()),
    );
  });
}
