import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_offer_models.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/mi_oferta_card_widget.dart';

ClientOffer _offer({
  String offerStatus = 'SENT',
  String? processStatus,
  int counterOfferCount = 0,
  String? lastOfferBy,
  bool isRated = false,
}) {
  return ClientOffer.fromJson({
    'offerId': 'offer-1',
    'propertyId': 'prop-1',
    'offerType': 'SALE',
    'offerStatus': offerStatus,
    if (processStatus != null) 'processStatus': processStatus,
    'counterOfferCount': counterOfferCount,
    // Lo inyecta el cruce con /offers/accepted; /offers/my-offers no lo trae.
    if (isRated)
      'ratingStatus': const {
        'hasRatedLegalAssociate': true,
        'hasRatedLegalHq': true,
        'isFullyRated': true,
      },
    if (lastOfferBy != null) 'lastOfferBy': lastOfferBy,
    'updatedAt': '2026-08-20T10:00:00.000Z',
    'property': {'id': 'prop-1', 'name': 'Orchad House'},
    'activeOfferData': {'proposedAmount': 250000, 'currency': 'USD'},
  });
}

/// Monta la tarjeta y devuelve cuántas veces se tocó cada acción.
Future<({List<int> taps})> _pumpCard(
  WidgetTester tester,
  ClientOffer offer, {
  required ClientOfferLane lane,
  bool hasUnreadUpdate = false,
}) async {
  final taps = [0]; // [abrir]
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: MiOfertaCardWidget(
        offer: offer,
        lane: lane,
        hasUnreadUpdate: hasUnreadUpdate,
        onOpen: () => taps[0]++,
      ),
    ),
  ));
  await tester.pump();
  return (taps: taps);
}

void main() {
  group('Acciones segun el carril', () {
    testWidgets('en el pipeline general solo ofrece ver la oferta',
        (tester) async {
      await _pumpCard(tester, _offer(), lane: ClientOfferLane.realizadas);

      expect(find.text('Ver tu oferta'), findsOneWidget);
      // Se retira desde el detalle, no desde la tarjeta.
      expect(find.text('Cancelar oferta'), findsNothing);
    });

    testWidgets('en contraoferta solo abre la negociacion', (tester) async {
      await _pumpCard(
        tester,
        _offer(counterOfferCount: 1, lastOfferBy: 'OWNER'),
        lane: ClientOfferLane.contraoferta,
      );

      expect(find.text('Ver contraoferta'), findsOneWidget);
      expect(find.text('Cancelar oferta'), findsNothing);
      expect(find.text('Ver tu oferta'), findsNothing);
    });

    testWidgets('en curso el trato lleva al proceso legal', (tester) async {
      await _pumpCard(
        tester,
        _offer(offerStatus: 'ACCEPTED', processStatus: 'contract_signing'),
        lane: ClientOfferLane.aceptada,
      );

      expect(find.text('Ver proceso legal'), findsOneWidget);
      expect(find.text('Calificar'), findsNothing);
      expect(find.text('Cancelar oferta'), findsNothing);
    });

    testWidgets('terminado el tramite invita a calificar', (tester) async {
      await _pumpCard(
        tester,
        _offer(offerStatus: 'ACCEPTED', processStatus: 'completed'),
        lane: ClientOfferLane.aceptada,
      );

      expect(find.text('Calificar'), findsOneWidget);
      expect(find.text('Ver proceso legal'), findsNothing);
    });

    testWidgets('ya calificado el tramite solo se consulta', (tester) async {
      await _pumpCard(
        tester,
        _offer(
          offerStatus: 'ACCEPTED',
          processStatus: 'completed',
          isRated: true,
        ),
        lane: ClientOfferLane.aceptada,
      );

      expect(find.text('Ver proceso legal'), findsOneWidget);
      expect(find.text('Calificar'), findsNothing);
    });
  });

  group('Cuando se puede retirar la oferta', () {
    testWidgets('una oferta aceptada ya no se cancela desde la tarjeta',
        (tester) async {
      await _pumpCard(
        tester,
        _offer(offerStatus: 'ACCEPTED', processStatus: 'awaiting_legal_review'),
        lane: ClientOfferLane.realizadas,
      );

      expect(find.text('Ver tu oferta'), findsOneWidget);
      expect(find.text('Cancelar oferta'), findsNothing);
    });

    testWidgets('una oferta ya rechazada tampoco', (tester) async {
      await _pumpCard(tester, _offer(offerStatus: 'REJECTED'),
          lane: ClientOfferLane.realizadas);

      expect(find.text('Cancelar oferta'), findsNothing);
    });
  });

  group('Lo que cuenta la tarjeta', () {
    testWidgets('muestra la propiedad y el monto ofertado', (tester) async {
      await _pumpCard(tester, _offer(), lane: ClientOfferLane.realizadas);

      expect(find.text('Orchad House'), findsOneWidget);
      expect(find.text('Compra · USD 250,000'), findsOneWidget);
    });

    testWidgets('marca el desenlace de una oferta cerrada', (tester) async {
      await _pumpCard(tester, _offer(offerStatus: 'REJECTED'),
          lane: ClientOfferLane.realizadas);
      expect(find.text('Rechazada'), findsOneWidget);

      await _pumpCard(tester, _offer(offerStatus: 'REJECTED_BY_CLIENT'),
          lane: ClientOfferLane.realizadas);
      expect(find.text('Retirada'), findsOneWidget);

      await _pumpCard(tester, _offer(offerStatus: 'EXPIRED'),
          lane: ClientOfferLane.realizadas);
      expect(find.text('Expirada'), findsOneWidget);
    });

    testWidgets('el punto rojo solo aparece cuando hay novedad',
        (tester) async {
      await _pumpCard(
        tester,
        _offer(counterOfferCount: 1, lastOfferBy: 'OWNER'),
        lane: ClientOfferLane.contraoferta,
      );
      expect(_badgeFinder, findsNothing);

      await _pumpCard(
        tester,
        _offer(counterOfferCount: 1, lastOfferBy: 'OWNER'),
        lane: ClientOfferLane.contraoferta,
        hasUnreadUpdate: true,
      );
      expect(_badgeFinder, findsOneWidget);
    });
  });

  group('Interaccion', () {
    testWidgets('el boton abre la oferta', (tester) async {
      final result =
          await _pumpCard(tester, _offer(), lane: ClientOfferLane.realizadas);

      await tester.tap(find.text('Ver tu oferta'));
      await tester.pump();
      expect(result.taps, [1]);
    });
  });
}

/// El badge es el único círculo rojo de la tarjeta.
final Finder _badgeFinder = find.byWidgetPredicate((widget) {
  if (widget is! Container) return false;
  final decoration = widget.decoration;
  return decoration is BoxDecoration &&
      decoration.shape == BoxShape.circle &&
      decoration.color == const Color(0xFFDA0010);
});
