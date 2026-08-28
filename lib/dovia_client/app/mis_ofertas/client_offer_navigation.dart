import '/domain/client_offer_models.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Abre una oferta enviada desde cualquiera de las tarjetas de "Mis Ofertas" y
/// marca su estado como visto (apaga el punto rojo).
///
/// Cada carril abre el detalle que corresponde a su etapa:
/// - Rechazo del propietario y oferta inicial a la espera → detalle de sólo
///   lectura: no hay nada que responder ahí.
/// - Contraoferta viva → la pantalla de negociación, con la comparación de las
///   dos propuestas y el trilema.
/// - Proceso legal y cierre → el detalle `Tu propuesta`, que según el estado
///   muestra la estructuración del acuerdo o el cierre del trámite.
///
/// "Finalizadas" y "Calificadas" abren las dos la misma pantalla de cierre —la
/// calificación vive ahí, en un modal por profesional—; lo que cambia es que
/// la segunda entra como archivo, sin acciones, y eso viaja en `ratedRoles`.
Future<void> openClientOffer(BuildContext context, ClientOffer offer) async {
  if (offer.offerId.isEmpty) return;

  FFAppState().addToSeenClientOffers(offer.seenSignature);

  if (opensReadOnlyOfferDetail(offer)) {
    await context.pushNamed(
      'DOVIA_CLIENT_MisOfertasDetalle',
      queryParameters: {
        'offerId': serializeParam(offer.offerId, ParamType.String),
      }.withoutNulls,
    );
    return;
  }

  if (offer.lane == ClientOfferLane.contraoferta) {
    await context.pushNamed(
      'DOVIA_CLIENT_MisOfertasContraofertaDetalle',
      queryParameters: {
        'offerId': serializeParam(offer.offerId, ParamType.String),
      }.withoutNulls,
    );
    return;
  }

  await context.pushNamed(
    'DOVIA_CLIENT_MisVisitas_TuPropuesta',
    queryParameters: {
      'offerId': serializeParam(offer.offerId, ParamType.String),
      'paymentMethod':
          serializeParam(offer.normalizedPaymentMethod, ParamType.String),
      'propuestaState': serializeParam(offer.detailState, ParamType.String),
      'ratedRoles':
          serializeParam(offer.ratedRoles.join(','), ParamType.String),
    }.withoutNulls,
  );
}

/// `true` para lo que vive en las pestañas de "Ofertas realizadas": la oferta
/// inicial a la espera de respuesta y cualquier rechazo del propietario.
///
/// Son los dos casos que el detalle muestra en sólo lectura; el resto sigue
/// yendo a la negociación o al proceso legal.
bool opensReadOnlyOfferDetail(ClientOffer offer) =>
    offer.wasRejectedByOwner ||
    (offer.lane == ClientOfferLane.realizadas && offer.isActive);

/// `true` cuando la negociación se movió (el dueño contraofertó, avanzó el
/// proceso legal) y el usuario todavía no la abrió.
bool hasUnreadClientOfferUpdate(ClientOffer offer) =>
    !FFAppState().hasSeenClientOffer(offer.seenSignature);
