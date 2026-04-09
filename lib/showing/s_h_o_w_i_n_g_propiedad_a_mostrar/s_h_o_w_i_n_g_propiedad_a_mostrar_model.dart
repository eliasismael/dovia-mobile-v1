import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import 's_h_o_w_i_n_g_propiedad_a_mostrar_widget.dart'
    show SHOWINGPropiedadAMostrarWidget;
import 'package:flutter/material.dart';

class SHOWINGPropiedadAMostrarModel
    extends FlutterFlowModel<SHOWINGPropiedadAMostrarWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for SHOWING_Header component.
  late SHOWINGHeaderModel sHOWINGHeaderModel;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Model for LISTING_HQ_Navbar component.
  late LISTINGHQNavbarModel lISTINGHQNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    sHOWINGHeaderModel = createModel(context, () => SHOWINGHeaderModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    lISTINGHQNavbarModel = createModel(context, () => LISTINGHQNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    sHOWINGHeaderModel.dispose();
    primaryButtonModel.dispose();
    lISTINGHQNavbarModel.dispose();
  }
}
