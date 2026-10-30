import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dovia/backend/api_requests/api_offers.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/mortgage_bank_data_card.dart';

void main() {
  group('offerNeedsBankData', () {
    test('oferta aceptada sin expediente ni banco: pide los datos', () {
      expect(
        offerNeedsBankData({
          'offerStatus': 'ACCEPTED',
          'processStatus': 'AWAITING_LEGAL_REVIEW',
          'legalProcessId': null,
          'legalProcess': null,
        }),
        isTrue,
      );
    });

    test('con expediente o datos del banco ya no pide nada', () {
      final base = {
        'offerStatus': 'ACCEPTED',
        'processStatus': 'AWAITING_LEGAL_REVIEW',
      };
      expect(offerNeedsBankData({...base, 'legalProcessId': 'lp1'}), isFalse);
      expect(
        offerNeedsBankData({
          ...base,
          'bankAgentData': {'bankName': 'BI', 'bankAddress': 'Zona 4'},
        }),
        isFalse,
      );
    });

    test('oferta todavía en negociación: no pide nada', () {
      expect(
        offerNeedsBankData({
          'offerStatus': 'COUNTER_OFFERED',
          'processStatus': 'AWAITING_LEGAL_REVIEW',
        }),
        isFalse,
      );
    });
  });

  test('el envío usa los campos del backend y omite los opcionales vacíos',
      () async {
    late http.Request sent;
    await http.runWithClient(
      () => DOVIAAPIOfferContextGroup.submitBankAgentDataCall.call(
        offerId: 'o1',
        authToken: 't',
        bankName: ' Banco Industrial ',
        bankAddress: 'Zona 4',
        phone: '',
        email: 'ana@banco.gt',
      ),
      () => MockClient((request) async {
        sent = request;
        return http.Response('{"data":{}}', 200,
            headers: {'content-type': 'application/json'});
      }),
    );

    expect(sent.url.path, endsWith('/offers/o1/bank-agent-data'));
    expect(jsonDecode(sent.body), {
      'bankName': 'Banco Industrial',
      'bankAddress': 'Zona 4',
      'email': 'ana@banco.gt',
    });
  });
}
