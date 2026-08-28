import '/domain/client_offer_models.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Abre una oferta enviada desde cualquiera de las tarjetas de "Mis Ofertas" y
/// marca su estado como visto (apaga el punto rojo).
///
/// Reutiliza las pantallas que el comprador ya tenía, sin duplicar flujos:
/// - Ver tu oferta / Ver contraoferta / Ver proceso legal → el detalle
///   `Tu propuesta`, que según el estado de la oferta muestra la negociación,
///   la estructuración del acuerdo o el cierre del trámite.
///
/// Las dos pestañas de "Ofertas realizadas" van en cambio al detalle de sólo
/// lectura: un rechazo del propietario no admite respuesta, así que abrirlo en
/// la negociación mostraría un trilema que el backend ya no acepta.
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
