import '/dovia_home_client/d_h_c_l_i_e_n_t_proveedor_card/d_h_c_l_i_e_n_t_proveedor_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'd_h_c_l_i_e_n_t_casa_a_widget.dart' show DHCLIENTCasaAWidget;
import 'package:flutter/material.dart';

class DHCLIENTCasaAModel extends FlutterFlowModel<DHCLIENTCasaAWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DH_CLIENT_ProveedorCard component.
  late DHCLIENTProveedorCardModel dHCLIENTProveedorCardModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dHCLIENTProveedorCardModel =
        createModel(context, () => DHCLIENTProveedorCardModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dHCLIENTProveedorCardModel.dispose();
  }
}
