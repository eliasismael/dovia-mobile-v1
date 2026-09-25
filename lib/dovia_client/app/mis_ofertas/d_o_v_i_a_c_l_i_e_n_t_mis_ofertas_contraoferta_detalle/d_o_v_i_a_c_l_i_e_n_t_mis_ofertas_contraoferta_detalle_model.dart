import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_contraoferta_detalle_widget.dart'
    show DOVIACLIENTMisOfertasContraofertaDetalleWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisOfertasContraofertaDetalleModel
    extends FlutterFlowModel<DOVIACLIENTMisOfertasContraofertaDetalleWidget> {
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  late FixedDoviaIconModel fixedDoviaIconModel;
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
