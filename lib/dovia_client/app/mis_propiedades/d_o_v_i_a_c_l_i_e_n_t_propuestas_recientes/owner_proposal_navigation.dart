import '/domain/owner_proposal_models.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_calificar/d_h_c_l_i_e_n_t_calificar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Abre una propuesta recibida desde cualquiera de las tarjetas del
/// propietario y marca su estado como visto (apaga el punto rojo).
///
/// El destino depende del carril, y en los carriles ya cerrados reutiliza
/// exactamente el mismo flujo documentado para el comprador/arrendatario:
/// - Ofertas y Contraoferta → detalle con el trilema [Aceptar] / [Rechazar] /
///   [Contraoferta].
/// - Oferta aceptada → Legal HQ ("Ver proceso legal") y, al cerrar el ciclo,
///   la pantalla de calificación.
Future<void> openOwnerProposal(
  BuildContext context,
  OwnerProposal proposal,
) async {
  if (proposal.offerId.isEmpty) return;

  FFAppState().addToSeenOwnerProposals(proposal.seenSignature);

  if (proposal.lane == OwnerProposalLane.aceptada) {
    if (proposal.isLegalProcessFinished) {
      DHCLIENTCalificarWidget.serviceRequestId = null;
      DHCLIENTCalificarWidget.visitId = null;
      DHCLIENTCalificarWidget.offerId = proposal.offerId;
      DHCLIENTCalificarWidget.targetRole = 'LEGAL_ASSOCIATE';
      DHCLIENTCalificarWidget.jobTitle = proposal.propertyName;
      DHCLIENTCalificarWidget.jobDateLabel = null;
      await context.pushNamed('DH_CLIENT_Calificar');
      return;
    }

    await context.pushNamed(
      'DOVIA_CLIENT_MisPropiedades_Acuerdo',
      queryParameters: {
        'paymentMethod':
            serializeParam(proposal.normalizedPaymentMethod, ParamType.String),
        'proposedAmount': serializeParam(
            proposal.proposedAmount?.toString(), ParamType.String),
        'offerId': serializeParam(proposal.offerId, ParamType.String),
      }.withoutNulls,
    );
    return;
  }

  await context.pushNamed(
    'DOVIA_CLIENT_MisPropiedades_Propuesta',
    queryParameters: {
      'proposalType': serializeParam(
          proposal.offerType.toLowerCase().isEmpty
              ? 'sale'
              : proposal.offerType.toLowerCase(),
          ParamType.String),
      'offerId': serializeParam(proposal.offerId, ParamType.String),
    }.withoutNulls,
  );
}

/// `true` cuando la propuesta cambió (llegó nueva, el comprador contraofertó o
/// avanzó el proceso legal) y el propietario todavía no la abrió.
bool hasUnreadOwnerProposalUpdate(OwnerProposal proposal) =>
    !FFAppState().hasSeenOwnerProposal(proposal.seenSignature);
