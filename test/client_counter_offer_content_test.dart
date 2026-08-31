import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/core/result.dart';
import 'package:dovia/domain/client_counter_offer_detail.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/d_o_v_i_a_c_l_i_e_n_t_mis_ofertas_contraoferta_detalle/d_o_v_i_a_c_l_i_e_n_t_mis_ofertas_contraoferta_detalle_widget.dart';

ClientCounterOfferDetail _detail({String status = 'COUNTER_OFFER'}) =>
    ClientCounterOfferDetail.fromJson({
      'offerId': 'offer-1',
      'propertyId': 'property-1',
      'offerType': 'SALE',
      'offerStatus': status,
      'counterOfferCount': 1,
      'lastOfferBy': 'OWNER',
      'pendingResponseBy': 'CLIENT',
      'originalOfferData': {
        'paymentMethod': 'cash',
        'currency': 'USD',
        'proposedAmount': 120000,
      },
      'counterOfferData': {
        'paymentMethod': 'cash',
        'currency': 'USD',
        'proposedAmount': 130000,
        'considerations': 'Cierre en treinta días',
      },
      if (status.startsWith('REJECTED')) ...{
        'rejectedBy': 'CLIENT',
        'rejectionReason': 'Los nuevos términos no me convienen',
      },
    });

Widget _app({
  required ClientCounterOfferDetail detail,
  required CounterOfferAction onAccept,
  required RejectCounterOfferAction onReject,
  required SendCounterOfferAction onSendCounterOffer,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ClientCounterOfferContent(
        detail: detail,
        onAccept: onAccept,
        onReject: onReject,
        onSendCounterOffer: onSendCounterOffer,
      ),
    ),
  );
}

void main() {
  testWidgets('muestra comparación, stepper y acepta la contraoferta',
      (tester) async {
    var accepted = false;
    await tester.pumpWidget(_app(
      detail: _detail(),
      onAccept: () async {
        accepted = true;
        return const Success(true);
      },
      onReject: (_) async => const Success(true),
      onSendCounterOffer: (_) async => const Success(true),
    ));

    expect(find.text('Estado de tu proceso'), findsOneWidget);
    expect(find.text('Tu propuesta'), findsOneWidget);
    expect(find.text('Propuesta del propietario'), findsOneWidget);

    final accept = find.byKey(const ValueKey('accept-offer'));
    await tester.ensureVisible(accept);
    await tester.tap(accept);
    await tester.pump();

    expect(accepted, isTrue);
  });

  testWidgets('habilita montos y envía una nueva contraoferta', (tester) async {
    Map<String, dynamic>? sentPayload;
    await tester.pumpWidget(_app(
      detail: _detail(),
      onAccept: () async => const Success(true),
      onReject: (_) async => const Success(true),
      onSendCounterOffer: (payload) async {
        sentPayload = payload;
        return const Success(true);
      },
    ));

    final counter = find.byKey(const ValueKey('counter-offer'));
    await tester.ensureVisible(counter);
    await tester.tap(counter);
    await tester.pump();

    final amount = find.byKey(const ValueKey('counter-proposedAmount'));
    expect(amount, findsOneWidget);
    await tester.enterText(amount, '140000');
    await tester.ensureVisible(counter);
    await tester.tap(counter);
    await tester.pump();

    expect(sentPayload, isNotNull);
    expect(sentPayload!['proposedAmount'], 140000);
    expect(sentPayload!['paymentMethod'], 'cash');
  });

  testWidgets('el método de pago se muestra pero nunca se edita',
      (tester) async {
    await tester.pumpWidget(_app(
      detail: _detail(),
      onAccept: () async => const Success(true),
      onReject: (_) async => const Success(true),
      onSendCounterOffer: (_) async => const Success(true),
    ));

    // Una vez en cada propuesta: la del cliente y la del propietario.
    expect(find.text('Método de pago'), findsNWidgets(2));
    expect(find.text('Contado'), findsNWidgets(2));

    final counter = find.byKey(const ValueKey('counter-offer'));
    await tester.ensureVisible(counter);
    await tester.tap(counter);
    await tester.pump();

    expect(find.byKey(const ValueKey('counter-paymentMethod')), findsNothing);
  });

  testWidgets('exige un motivo antes de confirmar el rechazo', (tester) async {
    String? rejectedReason;
    await tester.pumpWidget(_app(
      detail: _detail(),
      onAccept: () async => const Success(true),
      onReject: (reason) async {
        rejectedReason = reason;
        return const Success(true);
      },
      onSendCounterOffer: (_) async => const Success(true),
    ));

    final reject = find.byKey(const ValueKey('reject-offer'));
    await tester.ensureVisible(reject);
    await tester.tap(reject);
    await tester.pump();

    final confirm = find.byKey(const ValueKey('confirm-rejection'));
    expect(find.text('¿Por qué rechazas la oferta?'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('rejection-reason')),
      'El nuevo monto supera mi presupuesto',
    );
    await tester.pump();
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pump();
    expect(rejectedReason, 'El nuevo monto supera mi presupuesto');
  });

  testWidgets('el historial rechazado oculta las tres acciones',
      (tester) async {
    await tester.pumpWidget(_app(
      detail: _detail(status: 'REJECTED_BY_CLIENT'),
      onAccept: () async => const Success(true),
      onReject: (_) async => const Success(true),
      onSendCounterOffer: (_) async => const Success(true),
    ));

    expect(find.byKey(const ValueKey('accept-offer')), findsNothing);
    expect(find.byKey(const ValueKey('counter-offer')), findsNothing);
    expect(find.byKey(const ValueKey('reject-offer')), findsNothing);
    expect(find.text('Negociación rechazada:'), findsOneWidget);
    expect(find.text('Los nuevos términos no me convienen'), findsOneWidget);
  });
}
