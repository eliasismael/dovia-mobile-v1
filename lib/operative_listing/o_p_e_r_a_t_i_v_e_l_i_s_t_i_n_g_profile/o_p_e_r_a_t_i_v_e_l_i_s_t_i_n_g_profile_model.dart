import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_profile_widget.dart'
    show OPERATIVELISTINGProfileWidget;
import 'package:flutter/material.dart';

class OPERATIVELISTINGProfileModel
    extends FlutterFlowModel<OPERATIVELISTINGProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for OPERATIVE_LISTING_Header component.
  late OPERATIVELISTINGHeaderModel oPERATIVELISTINGHeaderModel;
  // Model for OPERATIVE_LISTING_Navbar component.
  late OPERATIVELISTINGNavbarModel oPERATIVELISTINGNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    oPERATIVELISTINGHeaderModel =
        createModel(context, () => OPERATIVELISTINGHeaderModel());
    oPERATIVELISTINGNavbarModel =
        createModel(context, () => OPERATIVELISTINGNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    oPERATIVELISTINGHeaderModel.dispose();
    oPERATIVELISTINGNavbarModel.dispose();
  }
}
