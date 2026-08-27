import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/owner_proposal_models.dart';

/// Muestra real de `GET /offers/my-properties` y `GET /properties/my-properties`
/// del entorno dev (usuario de prueba), recortada a los campos que consume el
/// modelo. Fija la forma que devuelve el backend hoy:
///
/// - la oferta NO trae `property`, sólo `propertyId`;
/// - `offerStatus` y `processStatus` llegan en minúsculas;
/// - `pendingResponseBy` viene en `null`, así que manda `lastOfferBy`;
/// - `awaiting_legal_review` es un paso del proceso legal;
/// - no existe ningún campo de calificación.
const String _offersJson = '''
{"data":[
 {"offerId":"o-sent","propertyId":"p-1","offerType":"SALE","offerStatus":"sent",
  "processStatus":"in_negotiation","lastOfferBy":"CLIENT","pendingResponseBy":null,
  "counterOfferCount":0,"counterOfferData":null,"contractSigned":false,
  "activeOfferData":{"paymentMethod":"mortgage","currency":"USD","proposedAmount":250000},
  "createdAt":"2026-08-22T18:51:52.943Z","updatedAt":"2026-08-22T18:51:52.943Z"},

 {"offerId":"o-counter-owner","propertyId":"p-1","offerType":"SALE","offerStatus":"counter_offer",
  "processStatus":"in_negotiation","lastOfferBy":"OWNER","pendingResponseBy":null,
  "counterOfferCount":1,"counterOfferData":{"proposedAmount":1400},"contractSigned":false,
  "activeOfferData":{"paymentMethod":"mortgage","currency":"USD","proposedAmount":789},
  "createdAt":"2026-08-08T20:41:00.627Z","updatedAt":"2026-08-09T20:41:00.627Z"},

 {"offerId":"o-counter-client","propertyId":"p-2","offerType":"SALE","offerStatus":"counter_offer",
  "processStatus":"in_negotiation","lastOfferBy":"CLIENT","pendingResponseBy":null,
  "counterOfferCount":2,"counterOfferData":{"proposedAmount":1200},"contractSigned":false,
  "activeOfferData":{"paymentMethod":"cash","currency":"USD","proposedAmount":1000},
  "createdAt":"2026-08-10T20:41:00.627Z","updatedAt":"2026-08-25T20:41:00.627Z"},

 {"offerId":"o-legal","propertyId":"p-2","offerType":"SALE","offerStatus":"accepted",
  "processStatus":"awaiting_legal_review","lastOfferBy":"OWNER","pendingResponseBy":null,
  "counterOfferCount":0,"counterOfferData":null,"contractSigned":false,
  "activeOfferData":{"paymentMethod":"mortgage","currency":"USD","proposedAmount":500000},
  "createdAt":"2026-08-01T20:41:00.627Z","updatedAt":"2026-08-02T20:41:00.627Z"},

 {"offerId":"o-rejected","propertyId":"p-3","offerType":"SALE","offerStatus":"rejected",
  "processStatus":"rejected","lastOfferBy":"CLIENT","pendingResponseBy":null,
  "counterOfferCount":0,"counterOfferData":null,"contractSigned":false,
  "activeOfferData":{"paymentMethod":"cash","currency":"USD","proposedAmount":100},
  "createdAt":"2026-08-05T20:41:00.627Z","updatedAt":"2026-08-06T20:41:00.627Z"}
]}
''';

const String _propertiesJson = '''
{"data":[
 {"id":"p-1","name":"Casa hermosa 7","status":"PUBLISHED","price":1231,
  "listingType":["SALE"],
  "features":{"general":{"landArea":0,"constructionArea":0,"bedrooms":0,"bathrooms":0}}},
 {"id":"p-2","name":"Casa hermosa 6","status":"PUBLISHED","price":9000,
  "listingType":["SALE"],
  "features":{"general":{"landArea":0,"constructionArea":0,"bedrooms":0,"bathrooms":0}}}
]}
''';

List<dynamic> _offers() => (jsonDecode(_offersJson)['data'] as List);

Map<String, Map<String, dynamic>> _propertiesById() {
  final items = jsonDecode(_propertiesJson)['data'] as List;
  return {
    for (final p in items)
      p['id'] as String: Map<String, dynamic>.from(p as Map),
  };
}

OwnerProposalsBoard _board() => OwnerProposalsBoard.fromOffers(
      _offers(),
      propertiesById: _propertiesById(),
    );

OwnerProposal _byId(String id) =>
    _board().all.firstWhere((p) => p.offerId == id);

void main() {
  group('Payload real de /offers/my-properties', () {
    test('los estados en minuscula caen en el carril correcto', () {
      final board = _board();

      expect(board.ofertas.map((p) => p.offerId),
          containsAll(['o-sent', 'o-rejected']));
      expect(board.contraofertas.map((p) => p.offerId),
          containsAll(['o-counter-owner', 'o-counter-client']));
      expect(board.aceptadas.map((p) => p.offerId), ['o-legal']);
    });

    test('counter_offer es reconocido como contraoferta', () {
      expect(_byId('o-counter-owner').lane, OwnerProposalLane.contraoferta);
      expect(_byId('o-counter-client').lane, OwnerProposalLane.contraoferta);
    });

    test('el rechazo marcado en processStatus tambien es terminal', () {
      final rejected = _byId('o-rejected');

      expect(rejected.isTerminal, isTrue);
      expect(rejected.filter, OwnerProposalFilter.ofertasRechazadas);
      expect(rejected.awaitsOwnerResponse, isFalse);
    });

    test('awaiting_legal_review es proceso legal, no negociacion', () {
      final legal = _byId('o-legal');

      expect(legal.lane, OwnerProposalLane.aceptada);
      expect(legal.filter, OwnerProposalFilter.aceptadaProcesoLegal);
      expect(legal.legalProgressSteps, 2);
      expect(legal.isLegalProcessFinished, isFalse);
    });

    test('con pendingResponseBy nulo decide lastOfferBy', () {
      // El dueno ya contraoferto: la pelota es del comprador.
      expect(_byId('o-counter-owner').awaitsOwnerResponse, isFalse);
      // El comprador contraoferto de vuelta: el dueno debe responder.
      expect(_byId('o-counter-client').awaitsOwnerResponse, isTrue);
      // La oferta original siempre le debe respuesta al dueno.
      expect(_byId('o-sent').awaitsOwnerResponse, isTrue);
    });

    test('la propiedad se completa cruzando por propertyId', () {
      expect(_byId('o-sent').propertyName, 'Casa hermosa 7');
      expect(_byId('o-legal').propertyName, 'Casa hermosa 6');
    });

    test('una propiedad que no vino en la lista no rompe la tarjeta', () {
      // p-3 no esta en /properties/my-properties.
      expect(_byId('o-rejected').propertyName, 'Propiedad');
      expect(_byId('o-rejected').propertyImageUrl, isEmpty);
    });

    test('sin propiedades resueltas las propuestas siguen clasificando', () {
      final board = OwnerProposalsBoard.fromOffers(_offers());

      expect(board.all, hasLength(5));
      expect(board.all.every((p) => p.propertyName == 'Propiedad'), isTrue);
    });

    test('el carrusel solo lleva propuestas vivas', () {
      expect(_board().recent().map((p) => p.offerId),
          isNot(contains('o-rejected')));
    });

    test('ninguna oferta del backend trae hoy campo de calificacion', () {
      // Documenta la limitacion: sin ese dato todo lo completado cae en
      // "Finalizadas" y nada llega a "Calificadas".
      for (final offer in _offers()) {
        expect((offer as Map).keys.where((k) => '$k'.contains('rat')), isEmpty);
      }
      expect(_board().byFilter(OwnerProposalFilter.aceptadaCalificadas),
          isEmpty);
    });
  });
}
