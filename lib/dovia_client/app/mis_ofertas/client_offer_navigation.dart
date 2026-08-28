import '/domain/client_offer_models.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_calificar/d_h_c_l_i_e_n_t_calificar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Abre una oferta enviada desde cualquiera de las tarjetas de "Mis Ofertas" y
/// marca su estado como visto (apaga el punto rojo).
///
/// Reutiliza las pantallas que el comprador ya tenía, sin duplicar flujos:
/// - Ver tu oferta / Ver contraoferta / Ver proceso legal → el detalle
///   `Tu propuesta`, que según el estado de la oferta muestra la negociación,
///   la estructuración del acuerdo o la firma del contrato.
/// - Calificar (proceso terminado) → la pantalla de calificación.
Future<void> openClientOffer(BuildContext context, ClientOffer offer) async {
  if (offer.offerId.isEmpty) return;

  FFAppState().addToSeenClientOffers(offer.seenSignature);

  if (offer.lane == ClientOfferLane.realizadas &&
      (offer.isActive || offer.wasRejectedByOwner)) {
    await context.pushNamed(
      'DOVIA_CLIENT_MisOfertasDetalle',
      queryParameters: {
        'offerId': serializeParam(offer.offerId, ParamType.String),
      }.withoutNulls,
    );
    return;
  }

  if (offer.lane == ClientOfferLane.aceptada && offer.isLegalProcessFinished) {
    DHCLIENTCalificarWidget.serviceRequestId = null;
    DHCLIENTCalificarWidget.visitId = null;
    DHCLIENTCalificarWidget.offerId = offer.offerId;
    DHCLIENTCalificarWidget.targetRole = 'LEGAL_ASSOCIATE';
    DHCLIENTCalificarWidget.jobTitle = offer.propertyName;
    DHCLIENTCalificarWidget.jobDateLabel = null;
    await context.pushNamed('DH_CLIENT_Calificar');
    return;
  }

  await context.pushNamed(
    'DOVIA_CLIENT_MisVisitas_TuPropuesta',
    queryParameters: {
      'offerId': serializeParam(offer.offerId, ParamType.String),
      'paymentMethod':
          serializeParam(offer.normalizedPaymentMethod, ParamType.String),
      'propuestaState': serializeParam(offer.detailState, ParamType.String),
    }.withoutNulls,
  );
}

/// `true` cuando la negociación se movió (el dueño contraofertó, avanzó el
/// proceso legal) y el usuario todavía no la abrió.
bool hasUnreadClientOfferUpdate(ClientOffer offer) =>
    !FFAppState().hasSeenClientOffer(offer.seenSignature);
