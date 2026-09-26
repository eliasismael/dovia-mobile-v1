import 'package:flutter/material.dart';

import '/dovia_home_client/d_h_c_l_i_e_n_t_costo_emergencia/d_h_c_l_i_e_n_t_costo_emergencia_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_valor_visita_page/d_h_c_l_i_e_n_t_valor_visita_page_widget.dart';
import '/dovia_home_client/service_request_fields.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Retoma el cobro de una solicitud que quedó sin pagar (Ej: el cliente abrió
/// el pago de una emergencia y volvió atrás). La solicitud ya existe en el
/// backend, así que se reabre su pantalla de pago con ese id en vez de crear
/// otra. Emergencias van a su costo fijo; el resto, al valor de la visita.
Future<void> openPendingPayment(
    BuildContext context, Map<String, dynamic> data) async {
  final id = srId(data);
  if (srIsEmergency(data)) {
    DHCLIENTCostoEmergenciaWidget.serviceRequestId = id;
    DHCLIENTCostoEmergenciaWidget.photos = [];
    await context.pushNamed(DHCLIENTCostoEmergenciaWidget.routeName);
  } else {
    DHCLIENTValorVisitaPageWidget.serviceRequestId = id;
    await context.pushNamed(DHCLIENTValorVisitaPageWidget.routeName);
  }
}
