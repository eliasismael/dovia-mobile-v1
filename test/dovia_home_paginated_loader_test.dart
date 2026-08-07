import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/backend/api_requests/api_manager.dart';
import 'package:dovia/backend/api_requests/dovia_home_paginated_loader.dart';

/// Respuesta paginada como la sirve el API: el arreglo en `data` y la metadata
/// en `meta.pagination`.
ApiCallResponse _page(
  int count, {
  required bool hasNextPage,
  int status = 200,
  String prefix = 'r',
}) =>
    ApiCallResponse(
      {
        'data': [
          for (var i = 0; i < count; i++) {'id': '$prefix$i'},
        ],
        'meta': {
          'pagination': {'hasNextPage': hasNextPage},
        },
      },
      const {},
      status,
    );

/// Respuesta sin `meta.pagination`, para el camino de respaldo.
ApiCallResponse _pageWithoutMeta(int count, {String prefix = 'r'}) =>
    ApiCallResponse(
      {
        'data': [
          for (var i = 0; i < count; i++) {'id': '$prefix$i'},
        ],
      },
      const {},
      200,
    );

ApiCallResponse _error(int status) => ApiCallResponse(null, const {}, status);

List? _extract(dynamic body) => body is Map ? body['data'] as List? : null;

void main() {
  group('loadAllDoviaHomePages', () {
    test('corta cuando el backend dice que no hay más páginas', () async {
      final pagesRequested = <int>[];

      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async {
          pagesRequested.add(page);
          return _page(
            page <= 2 ? kDoviaHomePageSize : 7,
            hasNextPage: page < 3,
          );
        },
        extractList: _extract,
      );

      expect(pagesRequested, [1, 2, 3], reason: 'page es 1-based y consecutivo');
      expect(result.items, hasLength(kDoviaHomePageSize * 2 + 7));
      expect(result.truncated, isFalse);
      expect(result.failed, isFalse);
    });

    test(
        'una página llena que el backend marca como última no pide una más '
        '(el tamaño no alcanza para saberlo)', () async {
      var calls = 0;

      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async {
          calls++;
          return _page(kDoviaHomePageSize, hasNextPage: false);
        },
        extractList: _extract,
      );

      expect(calls, 1);
      expect(result.items, hasLength(kDoviaHomePageSize));
      expect(result.truncated, isFalse);
    });

    test('una sola página incompleta no pide una segunda', () async {
      var calls = 0;

      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async {
          calls++;
          return _page(3, hasNextPage: false);
        },
        extractList: _extract,
      );

      expect(calls, 1);
      expect(result.items, hasLength(3));
      expect(result.truncated, isFalse);
    });

    test(
        'sigue paginando aunque [keep] descarte la página entera '
        '(el corte no mira la lista filtrada)', () async {
      final pagesRequested = <int>[];

      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async {
          pagesRequested.add(page);
          // La primera página viene llena pero se descarta entera; la segunda
          // trae lo que sí sirve. Si el corte mirara la lista ya filtrada, el
          // bucle terminaría en la página 1 y esos 4 nunca se verían.
          return _page(
            page == 1 ? kDoviaHomePageSize : 4,
            hasNextPage: page == 1,
            prefix: page == 1 ? 'descartar' : 'servir',
          );
        },
        extractList: _extract,
        keep: (data) => !(data['id'] as String).startsWith('descartar'),
      );

      expect(pagesRequested, [1, 2]);
      expect(result.items, hasLength(4));
      expect(result.truncated, isFalse);
    });

    group('sin `meta.pagination` cae al tamaño de página', () {
      test('una página incompleta cierra el listado', () async {
        var calls = 0;

        final result = await loadAllDoviaHomePages(
          fetchPage: (page, limit) async {
            calls++;
            return _pageWithoutMeta(page == 1 ? kDoviaHomePageSize : 2);
          },
          extractList: _extract,
        );

        expect(calls, 2);
        expect(result.items, hasLength(kDoviaHomePageSize + 2));
        expect(result.truncated, isFalse);
      });
    });

    test('marca truncated al llegar al tope de páginas', () async {
      var calls = 0;

      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async {
          calls++;
          // Backend que ignora `page`: siempre una página llena y con más.
          return _page(kDoviaHomePageSize, hasNextPage: true);
        },
        extractList: _extract,
      );

      expect(calls, kDoviaHomeMaxPages, reason: 'el tope corta');
      expect(result.items, hasLength(kDoviaHomeMaxItems));
      expect(result.truncated, isTrue);
      expect(result.failed, isFalse);
    });

    test('fallo en la primera página se reporta como error', () async {
      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async => _error(403),
        extractList: _extract,
      );

      expect(result.failed, isTrue);
      expect(result.errorStatus, 403);
      expect(result.items, isEmpty);
    });

    test('fallo en una página posterior conserva lo ya traído', () async {
      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async => page == 1
            ? _page(kDoviaHomePageSize, hasNextPage: true)
            : _error(500),
        extractList: _extract,
      );

      expect(result.failed, isFalse, reason: 'hay contenido útil que mostrar');
      expect(result.items, hasLength(kDoviaHomePageSize));
      expect(result.truncated, isTrue);
    });

    test('un cuerpo sin `data` se trata como listado vacío', () async {
      final result = await loadAllDoviaHomePages(
        fetchPage: (page, limit) async => const ApiCallResponse(null, {}, 200),
        extractList: _extract,
      );

      expect(result.items, isEmpty);
      expect(result.failed, isFalse);
      expect(result.truncated, isFalse);
    });
  });
}
