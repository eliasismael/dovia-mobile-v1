import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/backend/api_requests/api_manager.dart';
import 'package:dovia/dovia_home_associate/associate_requests_loader.dart';

/// Respuesta con [count] solicitudes bajo `data`, como la sirve el API.
ApiCallResponse _page(int count, {int status = 200, String prefix = 'r'}) =>
    ApiCallResponse(
      {
        'data': [
          for (var i = 0; i < count; i++) {'id': '$prefix$i'},
        ],
      },
      const {},
      status,
    );

ApiCallResponse _error(int status) => ApiCallResponse(null, const {}, status);

List? _extract(dynamic body) =>
    body is Map ? body['data'] as List? : null;

void main() {
  group('loadAllAssociateRequests', () {
    test('corta en la primera página incompleta', () async {
      final pagesRequested = <int>[];

      final result = await loadAllAssociateRequests(
        fetchPage: (page, limit) async {
          pagesRequested.add(page);
          // Dos páginas llenas y una parcial.
          return _page(page <= 2 ? kAssociateRequestsPageSize : 7);
        },
        extractList: _extract,
      );

      expect(pagesRequested, [1, 2, 3], reason: 'page es 1-based y consecutivo');
      expect(result.requests, hasLength(kAssociateRequestsPageSize * 2 + 7));
      expect(result.truncated, isFalse);
      expect(result.failed, isFalse);
    });

    test('una sola página incompleta no pide una segunda', () async {
      var calls = 0;

      final result = await loadAllAssociateRequests(
        fetchPage: (page, limit) async {
          calls++;
          return _page(3);
        },
        extractList: _extract,
      );

      expect(calls, 1);
      expect(result.requests, hasLength(3));
      expect(result.truncated, isFalse);
    });

    test(
        'sigue paginando aunque [keep] descarte la página entera '
        '(el corte mide la página cruda, no la filtrada)', () async {
      final pagesRequested = <int>[];

      final result = await loadAllAssociateRequests(
        fetchPage: (page, limit) async {
          pagesRequested.add(page);
          // La primera página viene llena pero se descarta entera; la segunda
          // trae lo que sí sirve. Midiendo la lista ya filtrada, el bucle
          // cortaría en la página 1 y esos 4 nunca se verían.
          return _page(
            page == 1 ? kAssociateRequestsPageSize : 4,
            prefix: page == 1 ? 'descartar' : 'servir',
          );
        },
        extractList: _extract,
        keep: (data) => !(data['id'] as String).startsWith('descartar'),
      );

      expect(pagesRequested, [1, 2]);
      expect(result.requests, hasLength(4));
      expect(result.truncated, isFalse);
    });

    test('marca truncated al llegar al tope de páginas', () async {
      var calls = 0;

      final result = await loadAllAssociateRequests(
        fetchPage: (page, limit) async {
          calls++;
          // Backend que ignora `page`: siempre una página llena.
          return _page(kAssociateRequestsPageSize);
        },
        extractList: _extract,
      );

      expect(calls, kAssociateRequestsMaxPages, reason: 'el tope corta');
      expect(result.requests, hasLength(kAssociateRequestsMaxItems));
      expect(result.truncated, isTrue);
      expect(result.failed, isFalse);
    });

    test('fallo en la primera página se reporta como error', () async {
      final result = await loadAllAssociateRequests(
        fetchPage: (page, limit) async => _error(403),
        extractList: _extract,
      );

      expect(result.failed, isTrue);
      expect(result.errorStatus, 403);
      expect(result.requests, isEmpty);
    });

    test('fallo en una página posterior conserva lo ya traído', () async {
      final result = await loadAllAssociateRequests(
        fetchPage: (page, limit) async =>
            page == 1 ? _page(kAssociateRequestsPageSize) : _error(500),
        extractList: _extract,
      );

      expect(result.failed, isFalse, reason: 'hay contenido útil que mostrar');
      expect(result.requests, hasLength(kAssociateRequestsPageSize));
      expect(result.truncated, isTrue);
    });

    test('un cuerpo sin `data` se trata como listado vacío', () async {
      final result = await loadAllAssociateRequests(
        fetchPage: (page, limit) async => const ApiCallResponse(null, {}, 200),
        extractList: _extract,
      );

      expect(result.requests, isEmpty);
      expect(result.failed, isFalse);
      expect(result.truncated, isFalse);
    });
  });
}
