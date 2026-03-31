import 'dart:convert';

import 'package:flutter/foundation.dart';

export 'api_manager.dart' show ApiCallResponse;

// ---------------------------------------------------------------------------
// Shared serialization helpers (were private in the original api_calls.dart)
// ---------------------------------------------------------------------------

dynamic _toEncodable(dynamic item) => item;

String serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print('List serialization failed. Returning empty list.');
    }
    return '[]';
  }
}

String serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print('Json serialization failed. Returning empty json.');
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) return null;
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}

// ---------------------------------------------------------------------------
// Pagination helper
// ---------------------------------------------------------------------------

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}
