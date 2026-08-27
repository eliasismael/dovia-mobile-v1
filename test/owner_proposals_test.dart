import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/owner_proposal_models.dart';

Map<String, dynamic> _offer({
  String offerId = 'offer-1',
  String offerStatus = 'PENDING',
  String? processStatus,
  Map<String, dynamic>? counterOfferData,
  String? lastOfferBy,
  String? pendingResponseBy,
  bool contractSigned = false,
  bool isRated = false,
  String? createdAt,
  String? updatedAt,
}) {
  return {
    'offerId': offerId,
    'offerType': 'SALE',
    'offerStatus': offerStatus,
    if (processStatus != null) 'processStatus': processStatus,
    if (counterOfferData != null) 'counterOfferData': counterOfferData,
    if (lastOfferBy != null) 'lastOfferBy': lastOfferBy,
    if (pendingResponseBy != null) 'pendingResponseBy': pendingResponseBy,
    'contractSigned': contractSigned,
    'isRated': isRated,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
    'property': {
      'id': 'prop-1',
      'name': 'Orchad House',
      'photos': [
        {'url': 'https://example.test/casa.png'}
      ],
    },
    'activeOfferData': {
      'proposedAmount': 250000,
      'currency': 'usd',
      'paymentMethod': 'MORTGAGE',
      'buyerInfo': {'name': 'Ana Perez'},
    },
  };
}

void main() {
  group('OwnerProposal.fromJson', () {
    test('lee la propiedad, el monto y el comprador', () {
      final proposal = OwnerProposal.fromJson(_offer());

      expect(proposal.offerId, 'offer-1');
      expect(proposal.propertyId, 'prop-1');
      expect(proposal.propertyName, 'Orchad House');
      expect(proposal.propertyImageUrl, 'https://example.test/casa.png');
      expect(proposal.proposedAmount, 250000);
      expect(proposal.currency, 'USD');
      expect(proposal.buyerName, 'Ana Perez');
      expect(proposal.normalizedPaymentMethod, 'hipoteca');
    });

    test('tolera una oferta sin propiedad ni montos', () {
      final proposal = OwnerProposal.fromJson({'offerId': 'offer-2'});

      expect(proposal.propertyName, 'Propiedad');
      expect(proposal.propertyImageUrl, isEmpty);
      expect(proposal.proposedAmount, isNull);
      expect(proposal.currency, 'USD');
      expect(proposal.normalizedPaymentMethod, 'contado');
    });
  });

  group('Carriles', () {
    test('una propuesta nueva cae en Ofertas', () {
      expect(OwnerProposal.fromJson(_offer()).lane, OwnerProposalLane.ofertas);
    });

    test('una negociacion con contraoferta cae en Contraoferta', () {
      final withCounterData = OwnerProposal.fromJson(
          _offer(counterOfferData: {'proposedAmount': 240000}));
      final withCounterStatus =
          OwnerProposal.fromJson(_offer(offerStatus: 'COUNTER_OFFERED'));

      expect(withCounterData.lane, OwnerProposalLane.contraoferta);
      expect(withCounterStatus.lane, OwnerProposalLane.contraoferta);
    });

    test('una oferta aceptada o en proceso legal cae en Oferta aceptada', () {
      final accepted = OwnerProposal.fromJson(_offer(offerStatus: 'ACCEPTED'));
      final inLegal = OwnerProposal.fromJson(_offer(
          offerStatus: 'ACCEPTED', processStatus: 'contract_signing'));

      expect(accepted.lane, OwnerProposalLane.aceptada);
      expect(inLegal.lane, OwnerProposalLane.aceptada);
    });

    test('el proceso legal manda sobre la contraoferta previa', () {
      final proposal = OwnerProposal.fromJson(_offer(
        offerStatus: 'COUNTER_OFFERED',
        processStatus: 'agreement_structuring',
        counterOfferData: {'proposedAmount': 240000},
      ));

      expect(proposal.lane, OwnerProposalLane.aceptada);
    });

    test('una oferta terminal conserva su carril pero deja de estar activa', () {
      for (final status in ['REJECTED', 'CANCELLED', 'EXPIRED', 'WITHDRAWN']) {
        final proposal = OwnerProposal.fromJson(_offer(offerStatus: status));
        expect(proposal.lane, OwnerProposalLane.ofertas, reason: status);
        expect(proposal.isTerminal, isTrue, reason: status);
        expect(proposal.isActive, isFalse, reason: status);
      }
    });

    test('una contraoferta rechazada se queda en el carril de contraoferta',
        () {
      final proposal = OwnerProposal.fromJson(_offer(
          offerStatus: 'REJECTED', counterOfferData: {'proposedAmount': 1}));

      expect(proposal.lane, OwnerProposalLane.contraoferta);
      expect(proposal.filter, OwnerProposalFilter.contraofertaRechazada);
    });
  });

  group('Pestanas de filtrado', () {
    test('cada carril expone las pestanas del diseno', () {
      expect(OwnerProposalLane.ofertas.filters.map((f) => f.label),
          ['Activas', 'Rechazadas']);
      expect(OwnerProposalLane.contraoferta.filters.map((f) => f.label),
          ['Enviada', 'Rechazada']);
      expect(OwnerProposalLane.aceptada.filters.map((f) => f.label),
          ['Proceso Legal', 'Finalizadas', 'Calificadas']);
    });

    test('Ofertas separa activas de rechazadas', () {
      expect(OwnerProposal.fromJson(_offer()).filter,
          OwnerProposalFilter.ofertasActivas);
      expect(OwnerProposal.fromJson(_offer(offerStatus: 'EXPIRED')).filter,
          OwnerProposalFilter.ofertasRechazadas);
    });

    test('Contraoferta separa enviada de rechazada', () {
      expect(
          OwnerProposal.fromJson(_offer(offerStatus: 'COUNTER_OFFERED')).filter,
          OwnerProposalFilter.contraofertaEnviada);
      expect(
          OwnerProposal.fromJson(_offer(
                  offerStatus: 'CANCELLED',
                  counterOfferData: {'proposedAmount': 1}))
              .filter,
          OwnerProposalFilter.contraofertaRechazada);
    });

    test('Oferta aceptada separa proceso legal, finalizadas y calificadas', () {
      expect(
          OwnerProposal.fromJson(_offer(
                  offerStatus: 'ACCEPTED', processStatus: 'contract_signing'))
              .filter,
          OwnerProposalFilter.aceptadaProcesoLegal);
      expect(
          OwnerProposal.fromJson(
                  _offer(offerStatus: 'ACCEPTED', processStatus: 'completed'))
              .filter,
          OwnerProposalFilter.aceptadaFinalizadas);
      expect(
          OwnerProposal.fromJson(_offer(
                  offerStatus: 'ACCEPTED',
                  processStatus: 'completed',
                  isRated: true))
              .filter,
          OwnerProposalFilter.aceptadaCalificadas);
    });

    test('el slug del carril viaja por la ruta en los dos sentidos', () {
      for (final lane in OwnerProposalLane.values) {
        expect(OwnerProposalLaneX.fromSlug(lane.slug), lane);
      }
      expect(OwnerProposalLaneX.fromSlug(null), OwnerProposalLane.ofertas);
      expect(
          OwnerProposalLaneX.fromSlug('otra-cosa'), OwnerProposalLane.ofertas);
    });
  });

  group('OwnerProposalsBoard', () {
    test('reparte las ofertas por carril, terminales incluidas', () {
      final board = OwnerProposalsBoard.fromOffers([
        _offer(offerId: 'a'),
        _offer(offerId: 'b', counterOfferData: {'proposedAmount': 1}),
        _offer(offerId: 'c', offerStatus: 'ACCEPTED'),
        _offer(offerId: 'd', offerStatus: 'REJECTED'),
        _offer(offerId: ''), // sin id: se ignora
        'basura',
      ]);

      expect(board.ofertas.map((p) => p.offerId), ['a', 'd']);
      expect(board.contraofertas.map((p) => p.offerId), ['b']);
      expect(board.aceptadas.map((p) => p.offerId), ['c']);
      expect(board.all, hasLength(4));
    });

    test('activeIn deja fuera las terminales del carril', () {
      final board = OwnerProposalsBoard.fromOffers([
        _offer(offerId: 'viva'),
        _offer(offerId: 'rechazada', offerStatus: 'REJECTED'),
      ]);

      expect(board.inLane(OwnerProposalLane.ofertas), hasLength(2));
      expect(board.activeIn(OwnerProposalLane.ofertas).map((p) => p.offerId),
          ['viva']);
    });

    test('byFilter devuelve exactamente lo de esa pestana', () {
      final board = OwnerProposalsBoard.fromOffers([
        _offer(offerId: 'activa'),
        _offer(offerId: 'rechazada', offerStatus: 'REJECTED'),
        _offer(offerId: 'legal', offerStatus: 'ACCEPTED'),
        _offer(
            offerId: 'calificada',
            offerStatus: 'ACCEPTED',
            processStatus: 'completed',
            isRated: true),
      ]);

      expect(
          board
              .byFilter(OwnerProposalFilter.ofertasActivas)
              .map((p) => p.offerId),
          ['activa']);
      expect(
          board
              .byFilter(OwnerProposalFilter.ofertasRechazadas)
              .map((p) => p.offerId),
          ['rechazada']);
      expect(
          board
              .byFilter(OwnerProposalFilter.aceptadaProcesoLegal)
              .map((p) => p.offerId),
          ['legal']);
      expect(board.byFilter(OwnerProposalFilter.aceptadaFinalizadas), isEmpty);
      expect(
          board
              .byFilter(OwnerProposalFilter.aceptadaCalificadas)
              .map((p) => p.offerId),
          ['calificada']);
    });

    test('recent() ordena de mas nueva a mas vieja y respeta el limite', () {
      final board = OwnerProposalsBoard.fromOffers([
        _offer(offerId: 'vieja', createdAt: '2026-08-01T10:00:00.000Z'),
        _offer(offerId: 'nueva', createdAt: '2026-08-20T10:00:00.000Z'),
        _offer(offerId: 'media', createdAt: '2026-08-10T10:00:00.000Z'),
      ]);

      expect(board.recent().map((p) => p.offerId),
          ['nueva', 'media', 'vieja']);
      expect(board.recent(limit: 2).map((p) => p.offerId), ['nueva', 'media']);
    });

    test('recent() no lleva propuestas terminales al carrusel', () {
      final board = OwnerProposalsBoard.fromOffers([
        _offer(offerId: 'viva', createdAt: '2026-08-01T10:00:00.000Z'),
        _offer(
            offerId: 'rechazada',
            offerStatus: 'REJECTED',
            createdAt: '2026-08-20T10:00:00.000Z'),
      ]);

      expect(board.recent().map((p) => p.offerId), ['viva']);
    });

    test('un tablero vacio no rompe recent()', () {
      expect(const OwnerProposalsBoard.empty().recent(), isEmpty);
      expect(const OwnerProposalsBoard.empty().isEmpty, isTrue);
    });
  });

  group('SLA de 7 dias', () {
    test('cuenta los dias restantes desde el ultimo movimiento', () {
      final startedTwoDaysAgo =
          DateTime.now().subtract(const Duration(days: 2));
      final proposal = OwnerProposal.fromJson(
          _offer(updatedAt: startedTwoDaysAgo.toIso8601String()));

      expect(proposal.daysLeftToRespond, 4); // 7 - 2, truncado por horas
      expect(proposal.isResponseOverdue, isFalse);
      expect(proposal.awaitsOwnerResponse, isTrue);
    });

    test('marca el plazo vencido pasados los 7 dias', () {
      final proposal = OwnerProposal.fromJson(_offer(
          updatedAt: DateTime.now()
              .subtract(const Duration(days: kOwnerProposalSlaDays + 1))
              .toIso8601String()));

      expect(proposal.isResponseOverdue, isTrue);
      expect(proposal.daysLeftToRespond, lessThan(0));
    });

    test('el plazo no corre cuando la pelota esta del lado del comprador', () {
      final ownerCountered = OwnerProposal.fromJson(_offer(
        offerStatus: 'COUNTER_OFFERED',
        lastOfferBy: 'OWNER',
        counterOfferData: {'proposedAmount': 1},
        updatedAt: DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String(),
      ));

      expect(ownerCountered.awaitsOwnerResponse, isFalse);
      expect(ownerCountered.isResponseOverdue, isFalse);
    });

    test('el plazo corre cuando el comprador contraoferto de vuelta', () {
      final buyerCountered = OwnerProposal.fromJson(_offer(
        offerStatus: 'COUNTER_OFFERED',
        lastOfferBy: 'CLIENT',
        counterOfferData: {'proposedAmount': 1},
      ));

      expect(buyerCountered.awaitsOwnerResponse, isTrue);
    });

    test('pendingResponseBy manda sobre lastOfferBy', () {
      final ownerOwes = OwnerProposal.fromJson(_offer(
        offerStatus: 'COUNTER_OFFERED',
        lastOfferBy: 'OWNER',
        pendingResponseBy: 'OWNER',
        counterOfferData: {'proposedAmount': 1},
      ));
      final buyerOwes = OwnerProposal.fromJson(_offer(
        offerStatus: 'COUNTER_OFFERED',
        lastOfferBy: 'CLIENT',
        pendingResponseBy: 'CLIENT',
        counterOfferData: {'proposedAmount': 1},
      ));

      expect(ownerOwes.awaitsOwnerResponse, isTrue);
      expect(buyerOwes.awaitsOwnerResponse, isFalse);
    });

    test('sin saber de quien es la pelota no se afirma un plazo en contraoferta',
        () {
      final unknown = OwnerProposal.fromJson(
          _offer(offerStatus: 'COUNTER_OFFERED', counterOfferData: {'a': 1}));

      expect(unknown.awaitsOwnerResponse, isFalse);
      expect(unknown.isResponseOverdue, isFalse);
    });

    test('la oferta original siempre le debe respuesta al dueno', () {
      expect(OwnerProposal.fromJson(_offer()).awaitsOwnerResponse, isTrue);
    });

    test('una oferta aceptada ya no tiene plazo de respuesta', () {
      final accepted = OwnerProposal.fromJson(_offer(offerStatus: 'ACCEPTED'));

      expect(accepted.awaitsOwnerResponse, isFalse);
    });

    test('sin fechas del backend no se inventa un plazo', () {
      final proposal = OwnerProposal.fromJson({'offerId': 'x'});

      expect(proposal.responseDeadline, isNull);
      expect(proposal.daysLeftToRespond, isNull);
      expect(proposal.isResponseOverdue, isFalse);
    });
  });

  group('Proceso legal', () {
    test('avanza la barra segun los cinco pasos reales del proceso', () {
      int steps(String? processStatus) => OwnerProposal.fromJson(_offer(
            offerStatus: 'ACCEPTED',
            processStatus: processStatus,
          )).legalProgressSteps;

      // 1 es la negociacion, ya cerrada en este carril.
      expect(steps(null), 2, reason: 'recien aceptada');
      expect(steps('awaiting_legal_review'), 2);
      expect(steps('agreement_structuring'), 3);
      expect(steps('contract_signing'), 4);
      expect(steps('completed'), 5);
    });

    test('reconoce la calificacion en las formas que puede mandar el backend',
        () {
      Map<String, dynamic> completed(Map<String, dynamic> extra) => {
            ..._offer(offerStatus: 'ACCEPTED', processStatus: 'completed'),
            ...extra,
          };

      expect(OwnerProposal.fromJson(completed({'isRated': true})).isRated,
          isTrue);
      expect(
          OwnerProposal.fromJson(completed({'rated': true})).isRated, isTrue);
      expect(OwnerProposal.fromJson(completed({'hasRating': true})).isRated,
          isTrue);
      expect(
          OwnerProposal.fromJson(
                  completed({'ratedAt': '2026-08-20T10:00:00.000Z'}))
              .isRated,
          isTrue);
      expect(
          OwnerProposal.fromJson(completed({
            'rating': {'stars': 5}
          })).isRated,
          isTrue);
      expect(
          OwnerProposal.fromJson(completed({
            'ratings': [
              {'stars': 5}
            ]
          })).isRated,
          isTrue);
      expect(OwnerProposal.fromJson(completed({'ratings': []})).isRated,
          isFalse);
    });

    test('solo el proceso terminado habilita Calificar', () {
      expect(
          OwnerProposal.fromJson(_offer(
                  offerStatus: 'ACCEPTED', processStatus: 'contract_signing'))
              .isLegalProcessFinished,
          isFalse);
      expect(
          OwnerProposal.fromJson(
                  _offer(offerStatus: 'ACCEPTED', processStatus: 'completed'))
              .isLegalProcessFinished,
          isTrue);
    });
  });

  group('seenSignature', () {
    test('cambia cuando avanza la negociacion o el proceso legal', () {
      final nueva = OwnerProposal.fromJson(_offer());
      final contraofertada =
          OwnerProposal.fromJson(_offer(offerStatus: 'COUNTER_OFFERED'));
      final enFirma = OwnerProposal.fromJson(_offer(
          offerStatus: 'ACCEPTED', processStatus: 'contract_signing'));
      final firmada = OwnerProposal.fromJson(_offer(
          offerStatus: 'ACCEPTED',
          processStatus: 'contract_signing',
          contractSigned: true));

      final signatures = {
        nueva.seenSignature,
        contraofertada.seenSignature,
        enFirma.seenSignature,
        firmada.seenSignature,
      };

      expect(signatures, hasLength(4));
    });

    test('se mantiene estable mientras nada cambia', () {
      expect(OwnerProposal.fromJson(_offer()).seenSignature,
          OwnerProposal.fromJson(_offer()).seenSignature);
    });
  });
}
