// Domain models for the proposals (offers) an owner receives on their
// properties — the "Propuestas Recientes" surface.
//
// The owner sees the same three logical lanes the buyer sees, but from the
// receiving side: Ofertas (new proposals), Contraoferta (negotiations already
// countered) and Oferta aceptada (closed deals that moved on to Legal HQ).

import 'offer_json.dart';

/// Days the owner has to answer a proposal before it expires.
///
/// The backend is the one that flips an unanswered offer to
/// `EXPIRED`/`REJECTED` and notifies the buyer; the app only computes the
/// remaining time so the owner can see the deadline.
const int kOwnerProposalSlaDays = 7;

enum OwnerProposalLane { ofertas, contraoferta, aceptada }

/// Sub-estado dentro de un carril: son las pestañas que filtran el listado
/// completo al que se llega con "Ver más".
enum OwnerProposalFilter {
  ofertasActivas,
  ofertasRechazadas,
  contraofertaEnviada,
  contraofertaRechazada,
  aceptadaProcesoLegal,
  aceptadaFinalizadas,
  aceptadaCalificadas,
}

extension OwnerProposalLaneX on OwnerProposalLane {
  /// Título de la pantalla del listado completo del carril.
  String get listTitle {
    switch (this) {
      case OwnerProposalLane.ofertas:
        return 'Ofertas';
      case OwnerProposalLane.contraoferta:
        return 'Contraofertas';
      case OwnerProposalLane.aceptada:
        return 'Oferta aceptada';
    }
  }

  /// Título del carril dentro de "Propuestas Recientes".
  String get laneTitle {
    switch (this) {
      case OwnerProposalLane.ofertas:
        return 'Ofertas';
      case OwnerProposalLane.contraoferta:
        return 'Contraoferta';
      case OwnerProposalLane.aceptada:
        return 'Oferta aceptada';
    }
  }

  /// Pestañas del listado completo, en el orden del diseño.
  List<OwnerProposalFilter> get filters {
    switch (this) {
      case OwnerProposalLane.ofertas:
        return const [
          OwnerProposalFilter.ofertasActivas,
          OwnerProposalFilter.ofertasRechazadas,
        ];
      case OwnerProposalLane.contraoferta:
        return const [
          OwnerProposalFilter.contraofertaEnviada,
          OwnerProposalFilter.contraofertaRechazada,
        ];
      case OwnerProposalLane.aceptada:
        return const [
          OwnerProposalFilter.aceptadaProcesoLegal,
          OwnerProposalFilter.aceptadaFinalizadas,
          OwnerProposalFilter.aceptadaCalificadas,
        ];
    }
  }

  /// Valor de la ruta, para viajar como query param.
  String get slug {
    switch (this) {
      case OwnerProposalLane.ofertas:
        return 'ofertas';
      case OwnerProposalLane.contraoferta:
        return 'contraoferta';
      case OwnerProposalLane.aceptada:
        return 'aceptada';
    }
  }

  static OwnerProposalLane fromSlug(String? slug) {
    switch (slug) {
      case 'contraoferta':
        return OwnerProposalLane.contraoferta;
      case 'aceptada':
        return OwnerProposalLane.aceptada;
      default:
        return OwnerProposalLane.ofertas;
    }
  }
}

extension OwnerProposalFilterX on OwnerProposalFilter {
  String get label {
    switch (this) {
      case OwnerProposalFilter.ofertasActivas:
        return 'Activas';
      case OwnerProposalFilter.ofertasRechazadas:
        return 'Rechazadas';
      case OwnerProposalFilter.contraofertaEnviada:
        return 'Enviada';
      case OwnerProposalFilter.contraofertaRechazada:
        return 'Rechazada';
      case OwnerProposalFilter.aceptadaProcesoLegal:
        return 'Proceso Legal';
      case OwnerProposalFilter.aceptadaFinalizadas:
        return 'Finalizadas';
      case OwnerProposalFilter.aceptadaCalificadas:
        return 'Calificadas';
    }
  }

  String get emptyMessage {
    switch (this) {
      case OwnerProposalFilter.ofertasActivas:
        return 'No tienes ofertas activas.';
      case OwnerProposalFilter.ofertasRechazadas:
        return 'No tienes ofertas rechazadas.';
      case OwnerProposalFilter.contraofertaEnviada:
        return 'No tienes contraofertas en curso.';
      case OwnerProposalFilter.contraofertaRechazada:
        return 'No tienes contraofertas rechazadas.';
      case OwnerProposalFilter.aceptadaProcesoLegal:
        return 'No tienes acuerdos en proceso legal.';
      case OwnerProposalFilter.aceptadaFinalizadas:
        return 'No tienes procesos finalizados por calificar.';
      case OwnerProposalFilter.aceptadaCalificadas:
        return 'Todavía no has calificado ningún proceso.';
    }
  }
}

/// Estados terminales: la negociación ya no admite respuesta. Siguen
/// perteneciendo a su carril, pero sólo aparecen en la pestaña de rechazadas.
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
  'COUNTER_OFFER', // el valor que manda hoy /offers/my-properties
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

/// Estados del proceso una vez aceptada la oferta, en orden. Sirven tanto para
/// elegir el carril como para llenar la barra de progreso de la tarjeta.
///
/// `awaiting_legal_review` es el paso inmediato a la aceptacion: la oferta ya
/// esta cerrada pero todavia no tiene asociado legal asignado.
const List<String> _legalProcessOrder = [
  'awaiting_legal_review',
  'agreement_structuring',
  'contract_signing',
  'completed',
];

/// El backend tambien marca el rechazo en `processStatus`.
const Set<String> _terminalProcessStatuses = {'rejected', 'cancelled', 'expired'};

class OwnerProposal {
  final String offerId;
  final String propertyId;
  final String propertyName;
  final String propertyImageUrl;
  final String offerType; // SALE | RENT
  final String paymentMethod; // raw backend value
  final String offerStatus;
  final String processStatus;
  final String lastOfferBy; // CLIENT | OWNER
  final String pendingResponseBy; // CLIENT | OWNER — quien debe responder
  final num? proposedAmount;
  final String currency;
  final String buyerName;
  final bool hasCounterOffer;
  final bool contractSigned;
  final bool isRated;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OwnerProposal({
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
    required this.proposedAmount,
    required this.currency,
    required this.buyerName,
    required this.hasCounterOffer,
    required this.contractSigned,
    required this.isRated,
    required this.createdAt,
    required this.updatedAt,
  });

  /// [property] permite inyectar la propiedad desde `/properties/my-properties`:
  /// el endpoint de ofertas sólo devuelve `propertyId`, así que sin esto las
  /// tarjetas no tendrían ni nombre ni foto.
  factory OwnerProposal.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? property,
  }) {
    final active = offerAsMap(json['activeOfferData']);
    final original = offerAsMap(json['originalOfferData']) ?? offerAsMap(json['offerData']);
    final counter = offerAsMap(json['counterOfferData']) ?? offerAsMap(json['counterOffer']);
    final propertyJson = offerAsMap(json['property']) ?? offerAsMap(property);

    String pick(String key) =>
        offerStr(active?[key]) ??
        offerStr(counter?[key]) ??
        offerStr(original?[key]) ??
        offerStr(json[key]) ??
        '';

    return OwnerProposal(
      offerId: offerStr(json['offerId']) ?? offerStr(json['id']) ?? offerStr(json['_id']) ?? '',
      propertyId: offerStr(propertyJson?['id']) ??
          offerStr(json['propertyId']) ??
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
          (offerStr(json['offerStatus']) ?? offerStr(json['status']) ?? '').toUpperCase(),
      processStatus: offerProcessStatus(json),
      lastOfferBy: (offerStr(json['lastOfferBy']) ?? '').toUpperCase(),
      pendingResponseBy:
          (offerStr(json['pendingResponseBy']) ?? '').toUpperCase(),
      proposedAmount: offerNum(active?['proposedAmount']) ??
          offerNum(counter?['proposedAmount']) ??
          offerNum(original?['proposedAmount']) ??
          offerNum(json['proposedAmount']) ??
          offerNum(json['amount']),
      currency: (pick('currency').isEmpty ? 'USD' : pick('currency')).toUpperCase(),
      buyerName: offerStr(offerAsMap(active?['buyerInfo'])?['name']) ??
          offerStr(offerAsMap(original?['buyerInfo'])?['name']) ??
          offerStr(offerAsMap(json['client'])?['name']) ??
          '',
      hasCounterOffer: counter != null && counter.isNotEmpty,
      contractSigned: json['contractSigned'] == true ||
          offerStr(json['contractSigned'])?.toLowerCase() == 'true',
      isRated: json['isRated'] == true ||
          json['rated'] == true ||
          json['hasRating'] == true ||
          offerStr(json['ratedAt']) != null ||
          offerAsMap(json['rating']) != null ||
          (json['ratings'] is List && (json['ratings'] as List).isNotEmpty),
      createdAt: DateTime.tryParse(offerStr(json['createdAt']) ?? ''),
      updatedAt: DateTime.tryParse(
          offerStr(json['updatedAt']) ?? offerStr(json['lastOfferAt']) ?? ''),
    );
  }

  /// Carril al que pertenece la propuesta. Lo decide la forma de la
  /// negociación, no su vigencia: una oferta rechazada sigue en su carril y
  /// sólo se separa después con [filter].
  OwnerProposalLane get lane {
    if (_acceptedOfferStatuses.contains(offerStatus) ||
        _legalProcessOrder.contains(processStatus)) {
      return OwnerProposalLane.aceptada;
    }
    if (hasCounterOffer || _counterOfferStatuses.contains(offerStatus)) {
      return OwnerProposalLane.contraoferta;
    }
    return OwnerProposalLane.ofertas;
  }

  /// La negociación ya no admite respuesta (rechazada, cancelada o expirada).
  /// El backend lo marca en `offerStatus` y a veces también en `processStatus`.
  bool get isTerminal =>
      _terminalOfferStatuses.contains(offerStatus) ||
      _terminalProcessStatuses.contains(processStatus);

  /// Pestaña del listado completo en la que cae la propuesta.
  OwnerProposalFilter get filter {
    switch (lane) {
      case OwnerProposalLane.ofertas:
        return isTerminal
            ? OwnerProposalFilter.ofertasRechazadas
            : OwnerProposalFilter.ofertasActivas;
      case OwnerProposalLane.contraoferta:
        return isTerminal
            ? OwnerProposalFilter.contraofertaRechazada
            : OwnerProposalFilter.contraofertaEnviada;
      case OwnerProposalLane.aceptada:
        if (!isLegalProcessFinished) {
          return OwnerProposalFilter.aceptadaProcesoLegal;
        }
        return isRated
            ? OwnerProposalFilter.aceptadaCalificadas
            : OwnerProposalFilter.aceptadaFinalizadas;
    }
  }

  /// Visible en el carrusel y en la vista espejo de tres carriles: allí sólo
  /// van las negociaciones vivas. Las terminales viven en su pestaña.
  bool get isActive => !isTerminal;

  /// `contado` | `hipoteca` | `promesa` — the vocabulary the detail and legal
  /// screens expect on their `paymentMethod` query parameter.
  String get normalizedPaymentMethod {
    final s = paymentMethod.toLowerCase();
    if (s.contains('mortgage') || s.contains('hipoteca')) return 'hipoteca';
    if (s.contains('promise') || s.contains('promesa')) return 'promesa';
    return 'contado';
  }

  /// Avance del proceso legal, de 0 a 5, para la barra segmentada de la
  /// tarjeta. El paso 1 es la negociación, ya cerrada en este carril.
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

  /// Moment the SLA clock started: the last movement on the negotiation, or the
  /// creation date when the backend does not expose one.
  DateTime? get slaStartedAt => updatedAt ?? createdAt;

  DateTime? get responseDeadline =>
      slaStartedAt?.add(const Duration(days: kOwnerProposalSlaDays));

  /// Whole days left to answer. Negative once the deadline has passed, `null`
  /// when the backend gave us no date to compute from.
  int? get daysLeftToRespond {
    final deadline = responseDeadline;
    if (deadline == null) return null;
    return deadline.difference(DateTime.now()).inHours ~/ 24;
  }

  /// El plazo sólo corre mientras el propietario deba una respuesta.
  ///
  /// En una contraoferta la pelota puede estar de cualquier lado, así que se
  /// mira quién debe responder; sin ese dato del backend no se afirma que el
  /// dueño deba algo (mejor no mostrar plazo que mostrar uno que no aplica).
  bool get awaitsOwnerResponse {
    if (isTerminal) return false;
    switch (lane) {
      case OwnerProposalLane.ofertas:
        // La oferta original siempre la envía el comprador.
        return true;
      case OwnerProposalLane.contraoferta:
        if (pendingResponseBy.isNotEmpty) {
          return pendingResponseBy == 'OWNER' ||
              pendingResponseBy == 'SELLER' ||
              pendingResponseBy == 'LANDLORD';
        }
        if (lastOfferBy.isNotEmpty) {
          return lastOfferBy == 'CLIENT' ||
              lastOfferBy == 'BUYER' ||
              lastOfferBy == 'TENANT';
        }
        return false;
      case OwnerProposalLane.aceptada:
        return false;
    }
  }

  bool get isResponseOverdue {
    if (!awaitsOwnerResponse) return false;
    final deadline = responseDeadline;
    return deadline != null && DateTime.now().isAfter(deadline);
  }

  /// Identity used to remember whether the owner already saw this state of the
  /// negotiation. Any movement (new status, new legal step, new counteroffer)
  /// produces a different signature and therefore lights the badge up again.
  String get seenSignature => [
        offerId,
        offerStatus,
        processStatus,
        contractSigned ? '1' : '0',
        updatedAt?.toIso8601String() ?? '',
      ].join('|');
}

/// Todas las propuestas recibidas, repartidas por carril.
///
/// Guarda también las terminales: el carrusel y la vista espejo muestran sólo
/// las vivas ([activeIn]), mientras que el listado completo de cada carril las
/// separa por pestaña ([byFilter]).
class OwnerProposalsBoard {
  final List<OwnerProposal> ofertas;
  final List<OwnerProposal> contraofertas;
  final List<OwnerProposal> aceptadas;

  const OwnerProposalsBoard({
    required this.ofertas,
    required this.contraofertas,
    required this.aceptadas,
  });

  const OwnerProposalsBoard.empty()
      : ofertas = const [],
        contraofertas = const [],
        aceptadas = const [];

  List<OwnerProposal> get all => [...ofertas, ...contraofertas, ...aceptadas];

  bool get isEmpty => all.isEmpty;

  /// Todo lo del carril, vivo y terminal.
  List<OwnerProposal> inLane(OwnerProposalLane lane) {
    switch (lane) {
      case OwnerProposalLane.ofertas:
        return ofertas;
      case OwnerProposalLane.contraoferta:
        return contraofertas;
      case OwnerProposalLane.aceptada:
        return aceptadas;
    }
  }

  /// Sólo las negociaciones vivas del carril, ordenadas de más nueva a más
  /// vieja: es lo que ven el carrusel y la vista espejo.
  List<OwnerProposal> activeIn(OwnerProposalLane lane) =>
      _newestFirst(inLane(lane).where((p) => p.isActive));

  /// Las propuestas de una pestaña del listado completo.
  List<OwnerProposal> byFilter(OwnerProposalFilter filter) =>
      _newestFirst(all.where((p) => p.filter == filter));

  /// Propuestas vivas más recientes de los tres carriles, para el carrusel del
  /// panel de Mis Propiedades.
  List<OwnerProposal> recent({int limit = 10}) =>
      _newestFirst(all.where((p) => p.isActive)).take(limit).toList();

  /// [propertiesById] son las propiedades del dueño indexadas por id, para
  /// completar lo que la oferta no trae (nombre y foto).
  factory OwnerProposalsBoard.fromOffers(
    List<dynamic> offers, {
    Map<String, Map<String, dynamic>> propertiesById = const {},
  }) {
    final ofertas = <OwnerProposal>[];
    final contraofertas = <OwnerProposal>[];
    final aceptadas = <OwnerProposal>[];

    for (final raw in offers) {
      final map = offerAsMap(raw);
      if (map == null) continue;
      final proposal = OwnerProposal.fromJson(
        map,
        property: propertiesById[offerStr(map['propertyId']) ?? ''],
      );
      if (proposal.offerId.isEmpty) continue;
      switch (proposal.lane) {
        case OwnerProposalLane.ofertas:
          ofertas.add(proposal);
          break;
        case OwnerProposalLane.contraoferta:
          contraofertas.add(proposal);
          break;
        case OwnerProposalLane.aceptada:
          aceptadas.add(proposal);
          break;
      }
    }

    return OwnerProposalsBoard(
      ofertas: ofertas,
      contraofertas: contraofertas,
      aceptadas: aceptadas,
    );
  }
}

List<OwnerProposal> _newestFirst(Iterable<OwnerProposal> proposals) {
  final items = proposals.toList()
    ..sort((a, b) {
      final aDate = a.slaStartedAt;
      final bDate = b.slaStartedAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
  return items;
}
