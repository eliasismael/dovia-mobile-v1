import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dovia/backend/api_requests/api_associate_feedback.dart';

/// Contrato de `associate-feedback`: qué URL y qué body salen de cada
/// calificación.
void main() {
  Future<http.Request> capture(Future<void> Function() send) async {
    late http.Request sent;
    await http.runWithClient(send, () {
      return MockClient((request) async {
        sent = request;
        return http.Response('{"id":"r1"}', 201,
            headers: {'content-type': 'application/json'});
      });
    });
    return sent;
  }

  test('Dovia Home envía el comentario recortado junto a las estrellas',
      () async {
    final request = await capture(() => DOVIAAPIAssociateFeedbackContextGroup
        .createDoviaHomeAssociateRatingCall
        .call(
            serviceRequestId: 'sr-1',
            stars: 4,
            comment: '  Muy prolijo  ',
            authToken: 't'));
    expect(request.url.path,
        endsWith('/associate-feedback/dovia-home/services/sr-1/ratings'));
    expect(jsonDecode(request.body), {'stars': 4.0, 'comment': 'Muy prolijo'});
    expect(request.headers['Authorization'], 'Bearer t');
  });

  test('Dovia Home sin comentario no manda el campo', () async {
    final request = await capture(() => DOVIAAPIAssociateFeedbackContextGroup
        .createDoviaHomeAssociateRatingCall
        .call(serviceRequestId: 'sr-1', stars: 5, comment: '   '));
    expect(jsonDecode(request.body), {'stars': 5.0});
  });

  test('la visita de producción califica al OPERATIVE_LISTER', () async {
    final request = await capture(() => DOVIAAPIAssociateFeedbackContextGroup
        .createVisitAssociateRatingCall
        .call(visitId: 'v-1', targetRole: 'OPERATIVE_LISTER', stars: 3));
    expect(request.url.path, endsWith('/associate-feedback/visits/v-1/ratings'));
    expect(jsonDecode(request.body),
        {'targetRole': 'OPERATIVE_LISTER', 'stars': 3.0});
  });
}
