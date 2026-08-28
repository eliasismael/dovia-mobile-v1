import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_offer_models.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/mi_oferta_card_widget.dart';

void main() {
  testWidgets('la tarjeta de grilla abre al tocarla y no muestra acciones',
      (tester) async {
    var openCount = 0;
    final offer = ClientOffer.fromJson({
      'offerId': 'offer-1',
      'propertyId': 'property-1',
      'offerType': 'SALE',
      'offerStatus': 'SENT',
      'property': {'name': 'Orchad House'},
      'offerData': {'proposedAmount': 250000, 'currency': 'USD'},
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MiOfertaCardWidget(
          offer: offer,
          lane: ClientOfferLane.realizadas,
          tapToOpen: true,
          showActions: false,
          onOpen: () => openCount++,
        ),
      ),
    ));

    expect(find.text('Ver tu oferta'), findsNothing);
    expect(find.text('Cancelar oferta'), findsNothing);

    await tester.tap(find.text('Orchad House'));
    await tester.pump();
    expect(openCount, 1);
  });
}
