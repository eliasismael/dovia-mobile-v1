import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_cotizaciones_recibidas/d_h_c_l_i_e_n_t_cotizaciones_recibidas_widget.dart';
import '/dovia_home_client/service_request_fields.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Si la tarjeta es una cotización todavía sin decidir, a la que ya le llegó
/// alguna propuesta. Ahí el cliente quiere comparar propuestas, no ver el
/// detalle de lo que pidió.
bool srMayHaveOpenProposals(Map<String, dynamic> data) =>
    srIsQuote(data) &&
    (srString(data['status']) ?? 'PENDING').toUpperCase() == 'PENDING';

/// Abre las propuestas del trabajo si ya tiene alguna y devuelve true. Si no
/// tiene (o no se pudo saber) devuelve false y la tarjeta sigue a su detalle.
Future<bool> openQuoteProposalsIfAny(
  BuildContext context,
  Map<String, dynamic> data,
) async {
  if (!srMayHaveOpenProposals(data)) return false;
  final id = srId(data);
  if (id.isEmpty) return false;

  final response =
      await DOVIAAPIDoviaHomeContextGroup.listQuoteProposalsCall.call(
    serviceRequestId: id,
    authToken: currentAuthenticationToken ?? '',
    limit: 1,
  );
  if (!response.succeeded || !context.mounted) return false;
  final proposals = DOVIAAPIDoviaHomeContextGroup.listQuoteProposalsCall
          .proposalsList(response.jsonBody) ??
      const [];
  if (proposals.isEmpty) return false;

  DHCLIENTCotizacionesRecibidasWidget.serviceRequestId = id;
  DHCLIENTCotizacionesRecibidasWidget.outOfScopeServiceRequestId = null;
  DHCLIENTCotizacionesRecibidasWidget.jobTitle = srString(data['description']);
  await context.pushNamed(DHCLIENTCotizacionesRecibidasWidget.routeName);
  return true;
}
