import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_counter_offer_detail.dart';

Map<String, dynamic> _detail({
  String status = 'COUNTER_OFFER',
  String offerType = 'SALE',
  String? rejectedBy,
  String? rejectionReason,
  Map<String, dynamic>? original,
  Map<String, dynamic>? owner,
}) =>
    {
      'offerId': 'offer-1',
      'propertyId': 'property-1',
      'offerType': offerType,
      'offerStatus': status,
      'counterOfferCount': 1,
      'lastOfferBy': 'OWNER',
      'pendingResponseBy': 'CLIENT',
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      'originalOfferData': original ??
          {
            'paymentMethod': 'mortgage',
            'currency': 'USD',
            'proposedAmount': 120000,
            'bankName': 'Banco Uno',
            'downPaymentPercentage': 15,
          },
      'counterOfferData': owner ??
          {
            'paymentMethod': 'mortgage',
            'currency': 'USD',
            'proposedAmount': 130000,
            'bankName': 'Banco Uno',
            'downPaymentPercentage': 20,
            'considerations': 'Cierre en treinta días',
          },
    };

void main() {
  test('separa la propuesta original de los términos del propietario', () {
    final detail = ClientCounterOfferDetail.fromJson(_detail());

    expect(detail.canResolve, isTrue);
    expect(detail.isRejected, isFalse);
    expect(detail.originalTerms.paymentMethodLabel, 'Hipoteca');
    expect(
      detail.originalTerms.fields
          .firstWhere((field) =>
              field.key == CounterOfferFieldKey.proposedAmount)
          .value,
      '120000',
    );
    expect(
      detail.ownerTerms.fields
          .firstWhere((field) =>
              field.key == CounterOfferFieldKey.proposedAmount)
          .value,
      '130000',
    );
  });

  test('inyecta campos distintos para contado, promesa y renta', () {
    final cash = CounterOfferTerms.fromJson(
      {
        'paymentMethod': 'cash',
        'proposedAmount': 100,
        'estimatedPaymentTime': 2,
      },
      offerType: 'SALE',
    );
    final promise = CounterOfferTerms.fromJson(
      {
        'paymentMethod': 'purchase_promise',
        'proposedAmount': 100,
        'initialReserve': 10,
        'finalPayment': 90,
        'promiseTimeMonths': 6,
      },
      offerType: 'SALE',
    );
    final rent = CounterOfferTerms.fromJson(
      {
        'currency': 'GTQ',
        'contractStartDate': '2026-09-01',
        'contractEndDate': '2027-08-31',
        'propertyUse': 'Vivienda',
      },
      offerType: 'RENT',
    );

    expect(
      cash.fields.map((field) => field.key),
      contains(CounterOfferFieldKey.estimatedApprovalTime),
    );
    expect(
      promise.fields.map((field) => field.key),
      containsAll([
        CounterOfferFieldKey.initialReserve,
        CounterOfferFieldKey.finalPayment,
        CounterOfferFieldKey.promiseTimeMonths,
      ]),
    );
    expect(rent.paymentMethodLabel, 'Renta');
    expect(
      rent.fields.map((field) => field.key),
      containsAll([
        CounterOfferFieldKey.contractStartDate,
        CounterOfferFieldKey.contractEndDate,
        CounterOfferFieldKey.propertyUse,
      ]),
    );
  });

  test('el método de pago abre cada propuesta y no se edita', () {
    final detail = ClientCounterOfferDetail.fromJson(_detail());

    for (final terms in [detail.originalTerms, detail.ownerTerms]) {
      final first = terms.fields.first;
      expect(first.key, CounterOfferFieldKey.paymentMethod);
      expect(first.value, 'Hipoteca');
      expect(first.editable, isFalse);
      // Comparte fila con el banco, como en el diseño.
      expect(first.half, isTrue);
      expect(terms.fields[1].key, CounterOfferFieldKey.bankName);
    }
  });

  test('genera el payload de una nueva contraoferta con valores editados', () {
    final terms = ClientCounterOfferDetail.fromJson(_detail()).ownerTerms;
    final payload = terms.toCounterOfferPayload(
      {
        CounterOfferFieldKey.proposedAmount: '140,000',
        CounterOfferFieldKey.bankName: 'Banco Dos',
        CounterOfferFieldKey.downPaymentPercentage: '25',
        CounterOfferFieldKey.considerations: 'Entrega inmediata',
      },
      selectedCurrency: 'GTQ',
    );

    expect(payload['paymentMethod'], 'mortgage');
    expect(payload['currency'], 'GTQ');
    expect(payload['proposedAmount'], 140000);
    expect(payload['bankName'], 'Banco Dos');
    expect(payload['downPaymentPercentage'], 25);
    expect(payload['considerations'], 'Entrega inmediata');
  });

  test('un rechazo previo queda en historial sin acciones resolutivas', () {
    final detail = ClientCounterOfferDetail.fromJson(_detail(
      status: 'REJECTED_BY_CLIENT',
      rejectedBy: 'CLIENT',
      rejectionReason: 'No puedo aceptar el nuevo monto',
    ));

    expect(detail.canResolve, isFalse);
    expect(detail.isRejected, isTrue);
    expect(detail.rejectionReason, 'No puedo aceptar el nuevo monto');
  });
}
