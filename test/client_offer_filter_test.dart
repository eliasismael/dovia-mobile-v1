import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_offer_models.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/client_offer_navigation.dart';

Map<String, dynamic> _offer({
  required String id,
  String status = 'SENT',
  String? rejectedBy,
  String? reason,
  int counterOfferCount = 0,
  String? processStatus,
  bool isRated = false,
}) =>
    {
      'offerId': id,
      'propertyId': 'property-1',
      'offerType': 'SALE',
      'offerStatus': status,
      'counterOfferCount': counterOfferCount,
      // `ratingStatus` no viene en /offers/my-offers: lo inyecta el cruce con
      // /offers/accepted que hace el repositorio.
      if (isRated)
        'ratingStatus': const {
          'canRate': false,
          'hasRatedLegalAssociate': true,
          'hasRatedLegalHq': true,
          'isFullyRated': true,
        },
      if (processStatus != null) 'processStatus': processStatus,
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
      if (reason != null) 'rejectionReason': reason,
      'offerData': {'paymentMethod': 'cash', 'currency': 'USD'},
    };

void main() {
  test('separa vigentes y rechazos del propietario sin mezclar retiros', () {
    final board = ClientOffersBoard.fromOffers([
      _offer(id: 'enviada'),
      _offer(id: 'pendiente', status: 'PENDING'),
      _offer(id: 'contraoferta', status: 'COUNTER_OFFER'),
      _offer(id: 'aceptada', status: 'ACCEPTED'),
      _offer(
        id: 'sent-con-contraoferta',
        counterOfferCount: 1,
      ),
      _offer(
        id: 'rechazada',
        status: 'REJECTED',
        rejectedBy: 'OWNER',
        reason: 'El enganche es muy bajo',
      ),
      _offer(
        id: 'retirada',
        status: 'REJECTED_BY_CLIENT',
        rejectedBy: 'CLIENT',
      ),
      _offer(id: 'expirada', status: 'EXPIRED'),
    ]);

    expect(
      board.byFilter(ClientOfferFilter.enviada).map((offer) => offer.offerId),
      ['enviada', 'pendiente'],
    );
    expect(
      board
          .byFilter(ClientOfferFilter.rechazada)
          .map((offer) => offer.offerId),
      ['rechazada'],
    );
    expect(
      board.byFilter(ClientOfferFilter.rechazada).single.rejectionReason,
      'El enganche es muy bajo',
    );
  });

  test('Enviado exige el estado inicial y no cualquier oferta activa', () {
    expect(
      ClientOffer.fromJson(_offer(id: 'sent')).isSentAwaitingOwnerResponse,
      isTrue,
    );
    expect(
      ClientOffer.fromJson(_offer(id: 'pending', status: 'PENDING'))
          .isSentAwaitingOwnerResponse,
      isTrue,
    );
    expect(
      ClientOffer.fromJson(_offer(id: 'active', status: 'ACTIVE'))
          .isSentAwaitingOwnerResponse,
      isFalse,
    );
    expect(
      ClientOffer.fromJson(_offer(id: 'counter', status: 'COUNTER_OFFER'))
          .isSentAwaitingOwnerResponse,
      isFalse,
    );
    expect(
      ClientOffer.fromJson(_offer(id: 'accepted', status: 'ACCEPTED'))
          .isSentAwaitingOwnerResponse,
      isFalse,
    );
  });

  test('todo lo que cae en una pestaña abre el detalle de solo lectura', () {
    final enviada = ClientOffer.fromJson(_offer(id: 'enviada'));
    // Rechazo posterior a una contraoferta: sigue viviendo en "Rechazada", y
    // la negociación ya no admite respuesta.
    final rechazadaTrasContraoferta = ClientOffer.fromJson(_offer(
      id: 'rechazada-contraoferta',
      status: 'REJECTED',
      rejectedBy: 'OWNER',
      counterOfferCount: 1,
    ));
    final enNegociacion =
        ClientOffer.fromJson(_offer(id: 'contraoferta', status: 'COUNTER_OFFER'));

    expect(opensReadOnlyOfferDetail(enviada), isTrue);
    expect(opensReadOnlyOfferDetail(rechazadaTrasContraoferta), isTrue);
    expect(opensReadOnlyOfferDetail(enNegociacion), isFalse);
  });

  group('Pestañas de Ofertas aceptadas', () {
    ClientOffersBoard board() => ClientOffersBoard.fromOffers([
          _offer(
            id: 'en-revision',
            status: 'ACCEPTED',
            processStatus: 'awaiting_legal_review',
          ),
          _offer(
            id: 'firmando',
            status: 'ACCEPTED',
            processStatus: 'contract_signing',
          ),
          _offer(
            id: 'por-calificar',
            status: 'ACCEPTED',
            processStatus: 'completed',
          ),
          _offer(
            id: 'calificada',
            status: 'ACCEPTED',
            processStatus: 'completed',
            isRated: true,
          ),
          // Ruido de los otros carriles: no debe colarse en ninguna pestaña.
          _offer(id: 'enviada'),
          _offer(id: 'contraoferta', status: 'COUNTER_OFFER'),
        ]);

    test('el trámite abierto vive en Proceso Legal', () {
      expect(
        board()
            .byFilter(ClientOfferFilter.procesoLegal)
            .map((offer) => offer.offerId),
        ['en-revision', 'firmando'],
      );
    });

    test('terminado y sin calificar espera en Finalizadas', () {
      expect(
        board()
            .byFilter(ClientOfferFilter.finalizada)
            .map((offer) => offer.offerId),
        ['por-calificar'],
      );
    });

    test('una vez calificado pasa al archivo de Calificadas', () {
      expect(
        board()
            .byFilter(ClientOfferFilter.calificada)
            .map((offer) => offer.offerId),
        ['calificada'],
      );
    });

    test('las tres pestañas reparten el carril sin perder ni duplicar', () {
      final carril = board().inLane(ClientOfferLane.aceptada).map((o) => o.offerId);
      final enPestanas = ClientOfferLane.aceptada.filters
          .expand((filter) => board().byFilter(filter))
          .map((offer) => offer.offerId);

      expect(enPestanas.toSet(), carril.toSet());
      expect(enPestanas.length, carril.length);
    });

    test('ninguna pestaña del cierre abre el detalle de sólo lectura', () {
      final enProceso = ClientOffer.fromJson(_offer(
        id: 'firmando',
        status: 'ACCEPTED',
        processStatus: 'contract_signing',
      ));
      final porCalificar = ClientOffer.fromJson(_offer(
        id: 'por-calificar',
        status: 'ACCEPTED',
        processStatus: 'completed',
      ));
      final calificada = ClientOffer.fromJson(_offer(
        id: 'calificada',
        status: 'ACCEPTED',
        processStatus: 'completed',
        isRated: true,
      ));

      // Las tres abren la pantalla de cierre: la calificación vive ahí, en un
      // modal, y sólo cambia si entra con acciones o como archivo.
      expect(opensReadOnlyOfferDetail(enProceso), isFalse);
      expect(opensReadOnlyOfferDetail(porCalificar), isFalse);
      expect(opensReadOnlyOfferDetail(calificada), isFalse);
      expect(porCalificar.isRated, isFalse);
      expect(calificada.isRated, isTrue,
          reason: 'es lo que vacía de acciones la pantalla de cierre');
      expect(calificada.ratedRoles, ['LEGAL_ASSOCIATE', 'LEGAL_OFFICER']);
    });

    test('el menú del diseño, en orden', () {
      expect(
        ClientOfferLane.aceptada.filters.map((filter) => filter.label),
        ['Proceso Legal', 'Finalizadas', 'Calificadas'],
      );
    });

    test('el header del diseño va en singular', () {
      expect(ClientOfferLane.aceptada.listTitle, 'Oferta aceptada');
    });

    test('sin el cruce con /offers/accepted nada llega calificado', () {
      // /offers/my-offers no expone el estado de calificación: si el cruce
      // falla, el trato se comporta como pendiente en vez de desaparecer.
      final offer = ClientOffer.fromJson(_offer(
        id: 'sin-cruce',
        status: 'ACCEPTED',
        processStatus: 'completed',
      ));

      expect(offer.ratingStatus, isNull);
      expect(offer.isRated, isFalse);
      expect(offer.ratedRoles, isEmpty);
      expect(offer.acceptedFilter, ClientOfferFilter.finalizada);
    });

    test('el cruce puede traer un solo rol calificado', () {
      final offer = ClientOffer.fromJson(
        _offer(id: 'medio', status: 'ACCEPTED', processStatus: 'completed'),
        ratingStatus: const {
          'hasRatedLegalAssociate': true,
          'hasRatedLegalHq': false,
          'isFullyRated': false,
        },
      );

      expect(offer.ratedRoles, ['LEGAL_ASSOCIATE']);
      expect(offer.isRated, isFalse,
          reason: 'todavía le falta Legal HQ: sigue en Finalizadas');
      expect(offer.acceptedFilter, ClientOfferFilter.finalizada);
    });
  });

  test('REJECTED antiguo sin rejectedBy se interpreta como rechazo del dueño',
      () {
    final offer = ClientOffer.fromJson(
      _offer(id: 'legacy', status: 'REJECTED'),
    );

    expect(offer.wasRejectedByOwner, isTrue);
  });
}
