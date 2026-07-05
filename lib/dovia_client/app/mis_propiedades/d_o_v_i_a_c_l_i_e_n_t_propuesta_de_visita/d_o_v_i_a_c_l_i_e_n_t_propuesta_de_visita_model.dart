import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propuesta_de_visita_widget.dart'
    show DOVIACLIENTPropuestaDeVisitaWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTPropuestaDeVisitaModel
    extends FlutterFlowModel<DOVIACLIENTPropuestaDeVisitaWidget> {
  // Model for the "Propuesta de visita" screen.

  int? selectedDateIndex;

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
  }
}
