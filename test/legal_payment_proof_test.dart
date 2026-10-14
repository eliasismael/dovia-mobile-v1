import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dovia/backend/api_requests/api_legal_process.dart';
import 'package:dovia/flutter_flow/uploaded_file.dart';

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

final _file = FFUploadedFile(
  name: 'boleta.pdf',
  bytes: Uint8List.fromList([1, 2, 3]),
);

/// Sube el comprobante contra un backend falso que responde la categoría
/// [category] (o falla si [processStatus] no es 200) y devuelve a qué rutas
/// se mandó el archivo.
Future<List<String>> _uploadWith(String? category,
    {int processStatus = 200}) async {
  final uploads = <String>[];
  await http.runWithClient(
    () => uploadLegalPaymentProof(
      processId: 'lp-1',
      authToken: 'jwt',
      file: _file,
    ),
    () => MockClient((req) async {
      if (req.method == 'GET') {
        return processStatus == 200
            ? _json(200, {
                'data': {'id': 'lp-1', 'category': category}
              })
            : _json(processStatus, {});
      }
      uploads.add(
          '${req.method} ${req.url.path.substring(req.url.path.indexOf('/legal-processes'))}');
      return _json(200, {'data': {}});
    }),
  );
  return uploads;
}

void main() {
  test('un proceso hipotecario usa el endpoint hipotecario', () async {
    expect(await _uploadWith('SALE_MORTGAGE'),
        ['POST /legal-processes/lp-1/mortgage/payment-document']);
  });

  test('venta y renta usan el endpoint estándar', () async {
    expect(await _uploadWith('SALE'),
        ['POST /legal-processes/lp-1/payment-proof']);
    expect(await _uploadWith('RENT'),
        ['POST /legal-processes/lp-1/payment-proof']);
  });

  test('si no se puede leer el proceso, usa el estándar como antes', () async {
    expect(await _uploadWith(null, processStatus: 500),
        ['POST /legal-processes/lp-1/payment-proof']);
  });
}
