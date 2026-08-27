import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/owner_proposal_models.dart';
import 'package:dovia/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_propuestas_recientes/propuesta_reciente_card_widget.dart';

OwnerProposal _proposal({
  String offerStatus = 'PENDING',
  String? processStatus,
  Map<String, dynamic>? counterOfferData,
  String? lastOfferBy,
  bool contractSigned = false,
  String? updatedAt,
}) {
  return OwnerProposal.fromJson({
    'offerId': 'offer-1',
    'offerType': 'SALE',
    'offerStatus': offerStatus,
    if (processStatus != null) 'processStatus': processStatus,
    if (counterOfferData != null) 'counterOfferData': counterOfferData,
    if (lastOfferBy != null) 'lastOfferBy': lastOfferBy,
    'contractSigned': contractSigned,
    'updatedAt': updatedAt ??
        DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    'property': {'id': 'prop-1', 'name': 'Orchad House'},
    'activeOfferData': {'proposedAmount': 250000, 'currency': 'USD'},
  });
}

Future<int> _pumpCard(
  WidgetTester tester,
  OwnerProposal proposal, {
  bool hasUnreadUpdate = false,
}) async {
  var taps = 0;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: PropuestaRecienteCardWidget(
        proposal: proposal,
        hasUnreadUpdate: hasUnreadUpdate,
        onOpen: () => taps++,
      ),
    ),
  ));
  await tester.pump();
  return taps;
}

void main() {
  testWidgets('una oferta nueva sólo ofrece [Ver oferta]', (tester) async {
    await _pumpCard(tester, _proposal());

    expect(find.text('Ver oferta'), findsOneWidget);
    expect(find.text('Orchad House'), findsOneWidget);
    expect(find.textContaining('Compra'), findsOneWidget);
  });

  testWidgets('el propietario nunca ve "Cancelar oferta"', (tester) async {
    final proposals = [
      _proposal(),
      _proposal(
          offerStatus: 'COUNTER_OFFERED',
          counterOfferData: {'proposedAmount': 240000}),
      _proposal(offerStatus: 'ACCEPTED', processStatus: 'contract_signing'),
      _proposal(offerStatus: 'ACCEPTED', processStatus: 'completed'),
    ];

    for (final proposal in proposals) {
      await _pumpCard(tester, proposal);
      expect(find.text('Cancelar oferta'), findsNothing,
          reason: '${proposal.lane}');
      expect(find.textContaining('Cancelar'), findsNothing,
          reason: '${proposal.lane}');
    }
  });

  testWidgets('una contraoferta del comprador se abre como [Ver contraoferta]',
      (tester) async {
    await _pumpCard(
        tester,
        _proposal(
          offerStatus: 'COUNTER_OFFERED',
          lastOfferBy: 'CLIENT',
          counterOfferData: {'proposedAmount': 240000},
        ));

    expect(find.text('Ver contraoferta'), findsOneWidget);
  });

  testWidgets('una oferta en proceso legal abre [Ver proceso legal]',
      (tester) async {
    await _pumpCard(
        tester,
        _proposal(
            offerStatus: 'ACCEPTED', processStatus: 'agreement_structuring'));

    expect(find.text('Ver proceso legal'), findsOneWidget);
    expect(find.text('Calificar'), findsNothing);
  });

  testWidgets('al terminar el ciclo la tarjeta ofrece [Calificar]',
      (tester) async {
    await _pumpCard(tester,
        _proposal(offerStatus: 'ACCEPTED', processStatus: 'completed'));

    expect(find.text('Calificar'), findsOneWidget);
    expect(find.text('Ver proceso legal'), findsNothing);
  });

  testWidgets('muestra el plazo de 7 días en las propuestas por responder',
      (tester) async {
    await _pumpCard(
        tester,
        _proposal(
            updatedAt: DateTime.now()
                .subtract(const Duration(days: 2))
                .toIso8601String()));

    expect(find.text('Te quedan 4 días'), findsOneWidget);
  });

  testWidgets('avisa cuando el plazo de respuesta venció', (tester) async {
    await _pumpCard(
        tester,
        _proposal(
            updatedAt: DateTime.now()
                .subtract(const Duration(days: 10))
                .toIso8601String()));

    expect(find.text('Plazo vencido'), findsOneWidget);
  });

  testWidgets('una propuesta terminal muestra su estado, no un plazo',
      (tester) async {
    await _pumpCard(tester, _proposal(offerStatus: 'REJECTED'));
    expect(find.text('Rechazada'), findsOneWidget);
    expect(find.textContaining('Te quedan'), findsNothing);
    expect(find.textContaining('Plazo'), findsNothing);

    await _pumpCard(tester, _proposal(offerStatus: 'EXPIRED'));
    expect(find.text('Expirada'), findsOneWidget);

    await _pumpCard(tester, _proposal(offerStatus: 'CANCELLED'));
    expect(find.text('Cancelada'), findsOneWidget);
  });

  testWidgets('las ofertas aceptadas no muestran plazo de respuesta',
      (tester) async {
    await _pumpCard(tester,
        _proposal(offerStatus: 'ACCEPTED', processStatus: 'contract_signing'));

    expect(find.textContaining('Plazo'), findsNothing);
    expect(find.textContaining('Te quedan'), findsNothing);
  });

  testWidgets('el punto rojo aparece sólo con novedades sin leer',
      (tester) async {
    Finder badge() => find.byWidgetPredicate((w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).color == const Color(0xFFDA0010));

    await _pumpCard(tester, _proposal(), hasUnreadUpdate: true);
    expect(badge(), findsOneWidget);

    await _pumpCard(tester, _proposal());
    expect(badge(), findsNothing);
  });

  testWidgets('tocar la acción abre la propuesta', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PropuestaRecienteCardWidget(
          proposal: _proposal(),
          onOpen: () => taps++,
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Ver oferta'));
    await tester.pump();

    expect(taps, 1);
  });
}
