import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_offer_models.dart';

Map<String, dynamic> _offer({
  required String id,
  String status = 'SENT',
  String? rejectedBy,
  String? reason,
  int counterOfferCount = 0,
  String? processStatus,
  String? pendingResponseBy,
  String? lastOfferBy,
}) =>
    {
      'offerId': id,
      'propertyId': 'property-1',
      'offerType': 'SALE',
      'offerStatus': status,
      'counterOfferCount': counterOfferCount,
      if (processStatus != null) 'processStatus': processStatus,
      if (pendingResponseBy != null) 'pendingResponseBy': pendingResponseBy,
      if (lastOfferBy != null) 'lastOfferBy': lastOfferBy,
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

  test('REJECTED antiguo sin rejectedBy se interpreta como rechazo del dueño',
      () {
    final offer = ClientOffer.fromJson(
      _offer(id: 'legacy', status: 'REJECTED'),
    );

    expect(offer.wasRejectedByOwner, isTrue);
  });

  test('Contraofertas separa pendientes del cliente e historial rechazado', () {
    final board = ClientOffersBoard.fromOffers([
      _offer(
        id: 'espera-cliente',
        status: 'COUNTER_OFFER',
        counterOfferCount: 1,
        pendingResponseBy: 'CLIENT',
        lastOfferBy: 'OWNER',
      ),
      _offer(
        id: 'espera-dueno',
        status: 'COUNTER_OFFER',
        counterOfferCount: 2,
        pendingResponseBy: 'OWNER',
        lastOfferBy: 'CLIENT',
      ),
      _offer(
        id: 'negociacion-rechazada',
        status: 'REJECTED_BY_CLIENT',
        counterOfferCount: 2,
        rejectedBy: 'CLIENT',
        reason: 'Los nuevos términos no me convienen',
      ),
      _offer(id: 'rechazo-inicial', status: 'REJECTED'),
    ]);

    expect(
      board
          .byFilterInLane(
            ClientOfferLane.contraoferta,
            ClientOfferFilter.enviada,
          )
          .map((offer) => offer.offerId),
      ['espera-cliente'],
    );
    expect(
      board
          .byFilterInLane(
            ClientOfferLane.contraoferta,
            ClientOfferFilter.rechazada,
          )
          .map((offer) => offer.offerId),
      ['negociacion-rechazada'],
    );
  });
}
