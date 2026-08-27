import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/client_offer_models.dart';

Map<String, dynamic> _offer({
  String offerId = 'offer-1',
  String propertyId = 'prop-1',
  String offerType = 'SALE',
  String offerStatus = 'SENT',
  String? processStatus,
  String? lastOfferBy,
  String? pendingResponseBy,
  int counterOfferCount = 0,
  Map<String, dynamic>? counterOfferData,
  Map<String, dynamic>? property,
  String? updatedAt,
}) {
  return {
    'offerId': offerId,
    'propertyId': propertyId,
    'offerType': offerType,
    'offerStatus': offerStatus,
    if (processStatus != null) 'processStatus': processStatus,
    if (lastOfferBy != null) 'lastOfferBy': lastOfferBy,
    'pendingResponseBy': pendingResponseBy,
    'counterOfferCount': counterOfferCount,
    if (counterOfferData != null) 'counterOfferData': counterOfferData,
    if (property != null) 'property': property,
    'activeOfferData': {
      'proposedAmount': 250000,
      'currency': 'USD',
      'paymentMethod': 'mortgage',
    },
    'createdAt': '2026-08-01T10:00:00.000Z',
    'updatedAt': updatedAt ?? '2026-08-10T10:00:00.000Z',
  };
}

ClientOffer _parse(Map<String, dynamic> json,
        {Map<String, dynamic>? property}) =>
    ClientOffer.fromJson(json, property: property);

void main() {
  group('Lectura de la oferta enviada', () {
    test('toma monto, moneda y tipo de la oferta activa', () {
      final offer = _parse(_offer());

      expect(offer.offerId, 'offer-1');
      expect(offer.propertyId, 'prop-1');
      expect(offer.proposedAmount, 250000);
      expect(offer.currency, 'USD');
      expect(offer.offerType, 'SALE');
      expect(offer.normalizedPaymentMethod, 'hipoteca');
    });

    test('completa la propiedad inyectada, con su foto principal', () {
      final offer = _parse(_offer(), property: {
        'id': 'prop-1',
        'name': 'Casa hermosa 5',
        'image': 'https://cdn.dovia.test/casa-5.jpg',
      });

      expect(offer.propertyName, 'Casa hermosa 5');
      expect(offer.propertyImageUrl, 'https://cdn.dovia.test/casa-5.jpg');
    });

    test('sin propiedad resuelta la tarjeta no se rompe', () {
      final offer = _parse(_offer());

      expect(offer.propertyName, 'Propiedad');
      expect(offer.propertyImageUrl, isEmpty);
    });

    test('lee la foto tambien del mapa de ambientes de /properties/{id}', () {
      final offer = _parse(_offer(), property: {
        'id': 'prop-1',
        'name': 'Casa',
        'images': {
          'sala': ['https://cdn.dovia.test/sala.jpg'],
          'cocina': ['https://cdn.dovia.test/cocina.jpg'],
        },
      });

      expect(offer.propertyImageUrl, 'https://cdn.dovia.test/sala.jpg');
    });

    test('normaliza los estados que llegan en minuscula', () {
      final offer = _parse(_offer(
        offerStatus: 'counter_offer',
        processStatus: 'IN_NEGOTIATION',
      ));

      expect(offer.offerStatus, 'COUNTER_OFFER');
      expect(offer.processStatus, 'in_negotiation');
    });
  });

  group('Etapa de la negociacion', () {
    test('una oferta recien enviada queda en realizadas', () {
      expect(_parse(_offer()).lane, ClientOfferLane.realizadas);
    });

    test('entra en contraoferta cuando el dueno devolvio otro precio', () {
      expect(_parse(_offer(counterOfferCount: 1)).lane,
          ClientOfferLane.contraoferta);
      expect(
          _parse(_offer(counterOfferData: {'proposedAmount': 200000})).lane,
          ClientOfferLane.contraoferta);
      expect(_parse(_offer(offerStatus: 'COUNTER_OFFER')).lane,
          ClientOfferLane.contraoferta);
    });

    test('pasa a aceptada al aceptarse o al abrirse el proceso legal', () {
      expect(_parse(_offer(offerStatus: 'ACCEPTED')).lane,
          ClientOfferLane.aceptada);
      expect(
          _parse(_offer(processStatus: 'awaiting_legal_review')).lane,
          ClientOfferLane.aceptada);
      expect(_parse(_offer(processStatus: 'contract_signing')).lane,
          ClientOfferLane.aceptada);
    });

    test('los estados sin respuesta posible son terminales', () {
      for (final status in const [
        'REJECTED',
        'REJECTED_BY_CLIENT',
        'CANCELLED',
        'EXPIRED',
        'WITHDRAWN',
      ]) {
        expect(_parse(_offer(offerStatus: status)).isTerminal, isTrue,
            reason: status);
      }
      // El backend tambien marca el desenlace en processStatus.
      expect(_parse(_offer(processStatus: 'rejected')).isTerminal, isTrue);
      expect(_parse(_offer()).isActive, isTrue);
    });
  });

  group('Retiro de la oferta', () {
    test('se puede retirar mientras la negociacion siga viva', () {
      expect(_parse(_offer()).isCancellable, isTrue);
      expect(_parse(_offer(counterOfferCount: 1)).isCancellable, isTrue);
    });

    test('no se retira lo que ya esta cerrado o aceptado', () {
      expect(_parse(_offer(offerStatus: 'ACCEPTED')).isCancellable, isFalse);
      expect(_parse(_offer(processStatus: 'contract_signing')).isCancellable,
          isFalse);
      expect(_parse(_offer(offerStatus: 'REJECTED')).isCancellable, isFalse);
    });

    test('sin offerId no hay nada que retirar', () {
      expect(_parse(_offer(offerId: '')).isCancellable, isFalse);
    });
  });

  group('De quien es la pelota', () {
    test('manda pendingResponseBy cuando el backend lo envia', () {
      expect(
          _parse(_offer(
            counterOfferCount: 1,
            pendingResponseBy: 'CLIENT',
            lastOfferBy: 'CLIENT', // contradictorio a proposito
          )).awaitsClientResponse,
          isTrue);
      expect(
          _parse(_offer(counterOfferCount: 1, pendingResponseBy: 'OWNER'))
              .awaitsClientResponse,
          isFalse);
    });

    test('sin ese dato decide quien hizo la ultima oferta', () {
      expect(
          _parse(_offer(counterOfferCount: 1, lastOfferBy: 'OWNER'))
              .awaitsClientResponse,
          isTrue);
      expect(
          _parse(_offer(counterOfferCount: 1, lastOfferBy: 'CLIENT'))
              .awaitsClientResponse,
          isFalse);
    });

    test('fuera de la contraoferta nunca hay respuesta pendiente', () {
      expect(_parse(_offer(lastOfferBy: 'OWNER')).awaitsClientResponse,
          isFalse);
      expect(
          _parse(_offer(offerStatus: 'ACCEPTED', lastOfferBy: 'OWNER'))
              .awaitsClientResponse,
          isFalse);
      expect(
          _parse(_offer(
            offerStatus: 'REJECTED',
            counterOfferCount: 1,
            lastOfferBy: 'OWNER',
          )).awaitsClientResponse,
          isFalse);
    });
  });

  group('Proceso legal', () {
    int steps(String? processStatus) => _parse(_offer(
          offerStatus: 'ACCEPTED',
          processStatus: processStatus,
        )).legalProgressSteps;

    test('la barra avanza con los cinco pasos reales', () {
      expect(steps(null), 2, reason: 'recien aceptada');
      expect(steps('awaiting_legal_review'), 2);
      expect(steps('agreement_structuring'), 3);
      expect(steps('contract_signing'), 4);
      expect(steps('completed'), 5);
    });

    test('solo completed cierra el proceso', () {
      expect(_parse(_offer(processStatus: 'contract_signing'))
          .isLegalProcessFinished, isFalse);
      expect(_parse(_offer(processStatus: 'completed')).isLegalProcessFinished,
          isTrue);
    });
  });

  group('Panel de Mis Ofertas', () {
    ClientOffersBoard board() => ClientOffersBoard.fromOffers([
          _offer(offerId: 'a', updatedAt: '2026-08-20T10:00:00.000Z'),
          _offer(
              offerId: 'b',
              counterOfferCount: 1,
              lastOfferBy: 'OWNER',
              updatedAt: '2026-08-22T10:00:00.000Z'),
          _offer(
              offerId: 'c',
              offerStatus: 'ACCEPTED',
              processStatus: 'contract_signing',
              updatedAt: '2026-08-18T10:00:00.000Z'),
          _offer(
              offerId: 'd',
              offerStatus: 'REJECTED',
              updatedAt: '2026-08-25T10:00:00.000Z'),
        ]);

    test('"Ofertas realizadas" es el pipeline general: las lleva todas', () {
      expect(board().inLane(ClientOfferLane.realizadas).map((o) => o.offerId),
          ['d', 'b', 'a', 'c']);
    });

    test('los otros dos carriles son subconjuntos suyos', () {
      expect(board().inLane(ClientOfferLane.contraoferta).map((o) => o.offerId),
          ['b']);
      expect(board().inLane(ClientOfferLane.aceptada).map((o) => o.offerId),
          ['c']);
    });

    test('ordena de la mas reciente a la mas vieja', () {
      final realizadas = board().inLane(ClientOfferLane.realizadas);
      expect(realizadas.first.offerId, 'd');
      expect(realizadas.last.offerId, 'c');
    });

    test('el carrusel acota cuantas tarjetas muestra', () {
      expect(board().recentIn(ClientOfferLane.realizadas, limit: 2),
          hasLength(2));
    });

    test('descarta las filas sin offerId', () {
      final result = ClientOffersBoard.fromOffers([
        _offer(offerId: ''),
        'basura',
        _offer(offerId: 'ok'),
      ]);

      expect(result.all.map((o) => o.offerId), ['ok']);
    });

    test('cruza las propiedades por propertyId', () {
      final result = ClientOffersBoard.fromOffers(
        [_offer(propertyId: 'p-9')],
        propertiesById: {
          'p-9': {'id': 'p-9', 'name': 'Casa hermosa 9'},
        },
      );

      expect(result.all.single.propertyName, 'Casa hermosa 9');
    });

    test('el punto rojo se enciende solo con contraofertas sin leer', () {
      final b = board();

      expect(b.hasPendingCounterOffers((_) => true), isTrue);
      expect(b.hasPendingCounterOffers((_) => false), isFalse,
          reason: 'ya vistas');
      // 'b' es la unica contraoferta y ademas espera respuesta del cliente.
      expect(b.hasPendingCounterOffers((o) => o.offerId != 'b'), isFalse);
    });

    test('un tablero vacio no rompe ningun carril', () {
      const empty = ClientOffersBoard.empty();

      expect(empty.isEmpty, isTrue);
      for (final lane in ClientOfferLane.values) {
        expect(empty.inLane(lane), isEmpty);
      }
    });
  });

  group('Firma de lo ya visto', () {
    test('cambia con cualquier movimiento de la negociacion', () {
      final base = _parse(_offer()).seenSignature;

      expect(_parse(_offer(counterOfferCount: 1)).seenSignature,
          isNot(base));
      expect(_parse(_offer(processStatus: 'contract_signing')).seenSignature,
          isNot(base));
      expect(
          _parse(_offer(updatedAt: '2026-08-11T10:00:00.000Z')).seenSignature,
          isNot(base));
      expect(_parse(_offer()).seenSignature, base);
    });
  });

  group('Carriles y rutas', () {
    test('cada carril viaja y vuelve por su slug', () {
      for (final lane in ClientOfferLane.values) {
        expect(ClientOfferLaneX.fromSlug(lane.slug), lane);
      }
    });

    test('un slug desconocido cae en el pipeline general', () {
      expect(ClientOfferLaneX.fromSlug(null), ClientOfferLane.realizadas);
      expect(ClientOfferLaneX.fromSlug('cualquiera'),
          ClientOfferLane.realizadas);
    });

    test('los titulos son los del diseno', () {
      expect(ClientOfferLane.realizadas.laneTitle, 'Ofertas realizadas');
      expect(ClientOfferLane.contraoferta.laneTitle, 'Contraoferta');
      expect(ClientOfferLane.aceptada.laneTitle, 'Oferta aceptadas');
    });
  });

  group('Estado que se le pasa al detalle del comprador', () {
    test('manda el proceso legal cuando existe', () {
      expect(_parse(_offer(processStatus: 'contract_signing')).detailState,
          'contract_signing');
    });

    test('si no, el estado de la oferta en minuscula', () {
      expect(_parse(_offer(offerStatus: 'SENT')).detailState, 'sent');
    });
  });

  group('Tolerancia al JSON crudo del backend', () {
    test('acepta una respuesta decodificada tal cual', () {
      final decoded = jsonDecode(jsonEncode([_offer()])) as List;
      final board = ClientOffersBoard.fromOffers(decoded);

      expect(board.all.single.offerId, 'offer-1');
    });
  });
}
