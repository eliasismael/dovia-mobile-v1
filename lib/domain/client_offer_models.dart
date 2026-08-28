// Modelos de las ofertas que el usuario ENVÍA como cliente interesado en
// comprar o rentar — la superficie "Mis Ofertas".
//
// Es el reflejo de `owner_proposal_models.dart`: la misma negociación vista
// desde el lado que propone. Por eso aquí sí existe "Cancelar oferta" (uno
// retira lo que ofreció) y en cambio no existe el trilema de aceptar/rechazar
// la oferta original.

import 'offer_json.dart';

/// Carriles del panel, en el orden del diseño.
enum ClientOfferLane { realizadas, contraoferta, aceptada }

/// Pestañas de los listados completos: dos reparten "Ofertas realizadas" y
/// tres siguen el cierre de las "Ofertas aceptadas".
enum ClientOfferFilter {
  enviada,
  rechazada,
  procesoLegal,
  finalizada,
  calificada,
}

extension ClientOfferLaneX on ClientOfferLane {
  /// Título del carril dentro de "Mis Ofertas".
  String get laneTitle {
    switch (this) {
      case ClientOfferLane.realizadas:
        return 'Ofertas realizadas';
      case ClientOfferLane.contraoferta:
        return 'Contraoferta';
      case ClientOfferLane.aceptada:
        return 'Oferta aceptadas';
    }
  }

  /// Título de la pantalla completa a la que lleva "Ver más".
  String get listTitle {
    switch (this) {
      case ClientOfferLane.realizadas:
        return 'Ofertas realizadas';
      case ClientOfferLane.contraoferta:
        return 'Contraofertas';
      case ClientOfferLane.aceptada:
        // Singular, como el header del diseño.
        return 'Oferta aceptada';
    }
  }

  String get emptyMessage {
    switch (this) {
      case ClientOfferLane.realizadas:
        return 'Todavía no has enviado ofertas.';
      case ClientOfferLane.contraoferta:
        return 'Ninguna de tus ofertas entró en contraoferta.';
      case ClientOfferLane.aceptada:
        return 'Todavía no te han aceptado una oferta.';
    }
  }

  List<ClientOfferFilter> get filters {
    switch (this) {
      case ClientOfferLane.realizadas:
        return const [ClientOfferFilter.enviada, ClientOfferFilter.rechazada];
      case ClientOfferLane.contraoferta:
        return const [];
      case ClientOfferLane.aceptada:
        return const [
          ClientOfferFilter.procesoLegal,
          ClientOfferFilter.finalizada,
          ClientOfferFilter.calificada,
        ];
    }
  }

  /// Valor de la ruta, para viajar como query param.
  String get slug {
    switch (this) {
      case ClientOfferLane.realizadas:
        return 'realizadas';
      case ClientOfferLane.contraoferta:
        return 'contraoferta';
      case ClientOfferLane.aceptada:
        return 'aceptada';
    }
  }

  static ClientOfferLane fromSlug(String? slug) {
    switch (slug) {
      case 'contraoferta':
        return ClientOfferLane.contraoferta;
      case 'aceptada':
        return ClientOfferLane.aceptada;
      default:
        return ClientOfferLane.realizadas;
    }
  }
}

extension ClientOfferFilterX on ClientOfferFilter {
  String get label {
    switch (this) {
      case ClientOfferFilter.enviada:
        return 'Enviado';
      case ClientOfferFilter.rechazada:
        return 'Rechazada';
      case ClientOfferFilter.procesoLegal:
        return 'Proceso Legal';
      case ClientOfferFilter.finalizada:
        return 'Finalizadas';
      case ClientOfferFilter.calificada:
        return 'Calificadas';
    }
  }

  String get emptyMessage {
    switch (this) {
      case ClientOfferFilter.enviada:
        return 'Todavía no has enviado ofertas.';
      case ClientOfferFilter.rechazada:
        return 'Ninguna de tus ofertas fue rechazada.';
      case ClientOfferFilter.procesoLegal:
        return 'No tienes trámites en proceso legal.';
      case ClientOfferFilter.finalizada:
        return 'No tienes trámites finalizados por calificar.';
      case ClientOfferFilter.calificada:
        return 'Todavía no has calificado ningún trámite.';
    }
  }
}

/// La negociación ya no admite respuesta.
const Set<String> _terminalOfferStatuses = {
  'REJECTED',
  'REJECTED_BY_OWNER',
  'REJECTED_BY_CLIENT',
  'CANCELLED',
  'CANCELED',
  'EXPIRED',
  'WITHDRAWN',
};

const Set<String> _counterOfferStatuses = {
  'COUNTER_OFFER', // el valor que manda hoy el backend
  'COUNTERED',
  'COUNTER_OFFERED',
  'COUNTER_OFFER_SENT',
  'IN_NEGOTIATION',
  'NEGOTIATING',
};

const Set<String> _acceptedOfferStatuses = {
  'ACCEPTED',
  'ACCEPTED_BY_OWNER',
  'ACCEPTED_BY_CLIENT',
};

/// Estados iniciales de una oferta que el cliente ya envió y para la que
/// todavía espera la primera respuesta del propietario.
const Set<String> _sentOfferStatuses = {'SENT', 'PENDING'};

/// Pasos del proceso una vez aceptada la oferta, en orden.
const List<String> _legalProcessOrder = [
  'awaiting_legal_review',
  'agreement_structuring',
  'contract_signing',
  'completed',
];

/// El backend también marca el desenlace en `processStatus`.
const Set<String> _terminalProcessStatuses = {
  'rejected',
  'cancelled',
  'expired',
};

/// Quiénes son "el dueño" y "el cliente" para el backend.
const Set<String> _ownerActors = {'OWNER', 'SELLER', 'LANDLORD'};
const Set<String> _clientActors = {'CLIENT', 'BUYER', 'TENANT'};

/// Qué le falta calificar al cliente en un trato cerrado.
///
/// Sólo lo devuelve `GET /offers/accepted` en sus filtros de calificación;
/// `/offers/my-offers`, que alimenta el panel, no expone nada de esto. Por eso
/// el board lo cruza aparte: sin este dato la pestaña "Calificadas" no se
/// puede distinguir de "Finalizadas".
class OfferRatingStatus {
  final bool canRate;
  final bool hasRatedLegalAssociate;
  final bool hasRatedLegalHq;
  final bool isFullyRated;

  const OfferRatingStatus({
    required this.canRate,
    required this.hasRatedLegalAssociate,
    required this.hasRatedLegalHq,
    required this.isFullyRated,
  });

  static OfferRatingStatus? fromJson(dynamic json) {
    final map = offerAsMap(json);
    if (map == null) return null;

    final associate = map['hasRatedLegalAssociate'] == true;
    final hq = map['hasRatedLegalHq'] == true;
    return OfferRatingStatus(
      canRate: map['canRate'] == true,
      hasRatedLegalAssociate: associate,
      hasRatedLegalHq: hq,
      // El backend ya lo calcula; si no viniera, dos de dos es lo mismo.
      isFullyRated: map['isFullyRated'] == true || (associate && hq),
    );
  }

  /// Roles ya calificados, en el vocabulario de `targetRole`.
  List<String> get ratedRoles => [
        if (hasRatedLegalAssociate) 'LEGAL_ASSOCIATE',
        if (hasRatedLegalHq) 'LEGAL_OFFICER',
      ];
}

/// Una oferta enviada por el usuario sobre una propiedad ajena.
class ClientOffer {
  final String offerId;
  final String propertyId;
  final String propertyName;
  final String propertyImageUrl;
  final String offerType; // SALE | RENT
  final String paymentMethod; // valor crudo del backend
  final String offerStatus;
  final String processStatus;
  final String lastOfferBy; // CLIENT | OWNER
  final String pendingResponseBy; // quién debe responder
  final String rejectedBy; // CLIENT | OWNER | SYSTEM
  final String rejectionReason;
  final num? proposedAmount;
  final String currency;
  final int counterOfferCount;
  final bool hasCounterOffer;
  final bool contractSigned;

  /// Estado de calificación del trato, cuando se pudo cruzar con
  /// `GET /offers/accepted`. `null` mientras no se conozca.
  final OfferRatingStatus? ratingStatus;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClientOffer({
    required this.offerId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyImageUrl,
    required this.offerType,
    required this.paymentMethod,
    required this.offerStatus,
    required this.processStatus,
    required this.lastOfferBy,
    required this.pendingResponseBy,
    required this.rejectedBy,
    required this.rejectionReason,
    required this.proposedAmount,
    required this.currency,
    required this.counterOfferCount,
    required this.hasCounterOffer,
    required this.contractSigned,
    required this.ratingStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  /// [property] llega de `GET /properties/{id}`: el listado de ofertas sólo
  /// devuelve `propertyId`, así que sin ese cruce la tarjeta no tendría ni
  /// nombre ni foto del inmueble.
  /// [ratingStatus] llega del cruce con `GET /offers/accepted`: el listado que
  /// alimenta el panel no dice qué se calificó ya.
  factory ClientOffer.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? property,
    Map<String, dynamic>? ratingStatus,
  }) {
    final active = offerAsMap(json['activeOfferData']);
    final original =
        offerAsMap(json['originalOfferData']) ?? offerAsMap(json['offerData']);
    final counter = offerAsMap(json['counterOfferData']) ??
        offerAsMap(json['counterOffer']);
    final propertyJson = offerAsMap(json['property']) ?? offerAsMap(property);

    String pick(String key) =>
        offerStr(active?[key]) ??
        offerStr(counter?[key]) ??
        offerStr(original?[key]) ??
        offerStr(json[key]) ??
        '';

    return ClientOffer(
      offerId: offerStr(json['offerId']) ??
          offerStr(json['id']) ??
          offerStr(json['_id']) ??
          '',
      propertyId: offerStr(json['propertyId']) ??
          offerStr(propertyJson?['id']) ??
          offerStr(propertyJson?['_id']) ??
          '',
      propertyName: offerStr(propertyJson?['name']) ??
          offerStr(propertyJson?['title']) ??
          offerStr(json['propertyName']) ??
          'Propiedad',
      propertyImageUrl: firstPropertyPhotoUrl(propertyJson) ?? '',
      offerType: (offerStr(json['offerType']) ?? '').toUpperCase(),
      paymentMethod: pick('paymentMethod'),
      offerStatus:
          (offerStr(json['offerStatus']) ?? offerStr(json['status']) ?? '')
              .toUpperCase(),
      processStatus: (offerStr(json['processStatus']) ??
              offerStr(offerAsMap(json['legalProcess'])?['status']) ??
              '')
          .toLowerCase(),
      lastOfferBy: (offerStr(json['lastOfferBy']) ?? '').toUpperCase(),
      pendingResponseBy:
          (offerStr(json['pendingResponseBy']) ?? '').toUpperCase(),
      rejectedBy: (offerStr(json['rejectedBy']) ??
              offerStr(offerAsMap(json['rejection'])?['rejectedBy']) ??
              '')
          .toUpperCase(),
      rejectionReason: offerRejectionReason(json) ?? '',
      proposedAmount: offerNum(active?['proposedAmount']) ??
          offerNum(counter?['proposedAmount']) ??
          offerNum(original?['proposedAmount']) ??
          offerNum(json['proposedAmount']) ??
          offerNum(json['amount']),
      currency:
          (pick('currency').isEmpty ? 'USD' : pick('currency')).toUpperCase(),
      counterOfferCount: (offerNum(json['counterOfferCount']) ?? 0).toInt(),
      hasCounterOffer: counter != null && counter.isNotEmpty,
      contractSigned: json['contractSigned'] == true ||
          offerStr(json['contractSigned'])?.toLowerCase() == 'true',
      ratingStatus: OfferRatingStatus.fromJson(json['ratingStatus']) ??
          OfferRatingStatus.fromJson(ratingStatus),
      createdAt: DateTime.tryParse(offerStr(json['createdAt']) ?? ''),
      updatedAt: DateTime.tryParse(
          offerStr(json['updatedAt']) ?? offerStr(json['lastOfferAt']) ?? ''),
    );
  }

  /// Etapa de la negociación. Ojo: no es "el carril donde se muestra" — el
  /// carril "Ofertas realizadas" es el pipeline general y las lleva todas
  /// (ver [ClientOffersBoard.inLane]).
  ClientOfferLane get lane {
    if (_acceptedOfferStatuses.contains(offerStatus) ||
        _legalProcessOrder.contains(processStatus)) {
      return ClientOfferLane.aceptada;
    }
    if (counterOfferCount > 0 ||
        hasCounterOffer ||
        _counterOfferStatuses.contains(offerStatus)) {
      return ClientOfferLane.contraoferta;
    }
    return ClientOfferLane.realizadas;
  }

  bool get isTerminal =>
      _terminalOfferStatuses.contains(offerStatus) ||
      _terminalProcessStatuses.contains(processStatus);

  bool get isActive => !isTerminal;

  /// Oferta inicial enviada, sin contraoferta ni aceptación posterior.
  ///
  /// Se valida también el carril para tolerar payloads inconsistentes donde el
  /// backend conserva `SENT` aunque ya haya agregado `counterOfferData`.
  bool get isSentAwaitingOwnerResponse =>
      _sentOfferStatuses.contains(offerStatus) &&
      lane == ClientOfferLane.realizadas &&
      !isTerminal;

  /// Sólo se retira lo que todavía está en juego: una vez aceptada la oferta
  /// el trato pasó a Legal HQ y ya no se cancela desde aquí.
  bool get isCancellable =>
      !isTerminal && lane != ClientOfferLane.aceptada && offerId.isNotEmpty;

  /// `true` cuando fue el propietario quien rechazó la negociación.
  /// Los retiros del cliente y los vencimientos no van en "Rechazada".
  bool get wasRejectedByOwner {
    if (!isTerminal) return false;
    if (rejectedBy.isNotEmpty) return _ownerActors.contains(rejectedBy);
    return offerStatus == 'REJECTED' ||
        offerStatus == 'REJECTED_BY_OWNER' ||
        processStatus == 'rejected';
  }

  /// `true` cuando la pelota está del lado del cliente: el dueño contraofertó
  /// y falta que el comprador acepte, rechace o vuelva a ofertar.
  bool get awaitsClientResponse {
    if (isTerminal || lane != ClientOfferLane.contraoferta) return false;
    if (pendingResponseBy.isNotEmpty) {
      return _clientActors.contains(pendingResponseBy);
    }
    if (lastOfferBy.isNotEmpty) return _ownerActors.contains(lastOfferBy);
    return false;
  }

  /// `contado` | `hipoteca` | `promesa`, el vocabulario que esperan el detalle
  /// y las pantallas legales en su query param `paymentMethod`.
  String get normalizedPaymentMethod {
    final s = paymentMethod.toLowerCase();
    if (s.contains('mortgage') || s.contains('hipoteca')) return 'hipoteca';
    if (s.contains('promise') || s.contains('promesa')) return 'promesa';
    return 'contado';
  }

  /// Estado que entiende la pantalla de detalle del cliente.
  String get detailState =>
      processStatus.isNotEmpty ? processStatus : offerStatus.toLowerCase();

  /// Avance del proceso legal, de 0 a 5, para la barra segmentada. El paso 1
  /// es la negociación, ya cerrada en este carril.
  int get legalProgressSteps {
    switch (processStatus) {
      case 'completed':
        return 5;
      case 'contract_signing':
        return 4;
      case 'agreement_structuring':
        return 3;
      case 'awaiting_legal_review':
        return 2;
      default:
        return 2; // recién aceptada, a la espera del asociado legal
    }
  }

  bool get isLegalProcessFinished => processStatus == 'completed';

  /// El cliente ya calificó a los dos profesionales del trato.
  bool get isRated => ratingStatus?.isFullyRated ?? false;

  /// Roles ya calificados, para que la pantalla de cierre nazca sin las
  /// acciones que ya no corresponden.
  List<String> get ratedRoles => ratingStatus?.ratedRoles ?? const [];

  /// Pestaña de "Ofertas aceptadas" en la que cae el trato.
  ///
  /// Las tres reparten el carril entero —cada trato está en una y sólo una—
  /// porque son etapas sucesivas del cierre: Legal HQ trabajando, Legal HQ
  /// terminado a la espera de la calificación, y el archivo ya calificado.
  ClientOfferFilter get acceptedFilter {
    if (!isLegalProcessFinished) return ClientOfferFilter.procesoLegal;
    return isRated
        ? ClientOfferFilter.calificada
        : ClientOfferFilter.finalizada;
  }

  /// Última señal de vida de la negociación, para ordenar los carriles.
  DateTime? get lastMovementAt => updatedAt ?? createdAt;

  /// Identidad del estado visto. Cualquier movimiento (contraoferta nueva,
  /// avance legal, cambio de estado) produce otra firma y vuelve a encender el
  /// punto rojo.
  String get seenSignature => [
        offerId,
        offerStatus,
        processStatus,
        counterOfferCount.toString(),
        contractSigned ? '1' : '0',
        updatedAt?.toIso8601String() ?? '',
      ].join('|');
}

/// Todas las ofertas enviadas, listas para repartir en los tres carriles.
class ClientOffersBoard {
  final List<ClientOffer> all;

  const ClientOffersBoard(this.all);

  const ClientOffersBoard.empty() : all = const [];

  bool get isEmpty => all.isEmpty;

  /// Ofertas de un carril, de la más reciente a la más vieja.
  ///
  /// "Ofertas realizadas" es el pipeline general y por diseño muestra TODAS
  /// las ofertas en cualquier estado; los otros dos carriles son subconjuntos
  /// suyos (la misma oferta aparece en "realizadas" y en "contraoferta").
  List<ClientOffer> inLane(ClientOfferLane lane) {
    if (lane == ClientOfferLane.realizadas) return _newestFirst(all);
    return _newestFirst(all.where((o) => o.lane == lane));
  }

  /// Los retiros del cliente y vencimientos no pertenecen a ninguna pestaña
  /// de "Ofertas realizadas": no siguen enviados y tampoco los rechazó el
  /// propietario. Las tres de "Ofertas aceptadas", en cambio, sí reparten su
  /// carril completo (ver [ClientOffer.acceptedFilter]).
  List<ClientOffer> byFilter(ClientOfferFilter filter) => _newestFirst(
        all.where((offer) => switch (filter) {
              ClientOfferFilter.enviada =>
                offer.isSentAwaitingOwnerResponse,
              ClientOfferFilter.rechazada => offer.wasRejectedByOwner,
              ClientOfferFilter.procesoLegal ||
              ClientOfferFilter.finalizada ||
              ClientOfferFilter.calificada =>
                offer.lane == ClientOfferLane.aceptada &&
                    offer.acceptedFilter == filter,
            }),
      );

  /// Lo que va al carrusel del panel: el arranque del carril, acotado.
  List<ClientOffer> recentIn(ClientOfferLane lane, {int limit = 10}) =>
      inLane(lane).take(limit).toList();

  /// `true` si el dueño contraofertó y el cliente todavía no lo abrió: es el
  /// punto rojo junto al título "Contraoferta".
  bool hasPendingCounterOffers(bool Function(ClientOffer) isUnread) =>
      inLane(ClientOfferLane.contraoferta)
          .any((o) => o.awaitsClientResponse && isUnread(o));

  /// [propertiesById] son las propiedades ya resueltas y [ratingStatusByOffer]
  /// el cruce con `GET /offers/accepted`, indexados por id.
  factory ClientOffersBoard.fromOffers(
    List<dynamic> offers, {
    Map<String, Map<String, dynamic>> propertiesById = const {},
    Map<String, Map<String, dynamic>> ratingStatusByOffer = const {},
  }) {
    final items = <ClientOffer>[];
    for (final raw in offers) {
      final map = offerAsMap(raw);
      if (map == null) continue;
      final id = offerStr(map['offerId']) ??
          offerStr(map['id']) ??
          offerStr(map['_id']) ??
          '';
      final offer = ClientOffer.fromJson(
        map,
        property: propertiesById[offerStr(map['propertyId']) ?? ''],
        ratingStatus: ratingStatusByOffer[id],
      );
      if (offer.offerId.isEmpty) continue;
      items.add(offer);
    }
    return ClientOffersBoard(items);
  }
}

List<ClientOffer> _newestFirst(Iterable<ClientOffer> offers) {
  final items = offers.toList()
    ..sort((a, b) {
      final aDate = a.lastMovementAt;
      final bDate = b.lastMovementAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
  return items;
}
