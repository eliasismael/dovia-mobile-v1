import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_widget.dart'
    show OPERATIVELISTINGChecklistWidget;
import 'package:flutter/material.dart';

class OPERATIVELISTINGChecklistModel
    extends FlutterFlowModel<OPERATIVELISTINGChecklistWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for OPERATIVE_LISTING_Header component.
  late OPERATIVELISTINGHeaderModel oPERATIVELISTINGHeaderModel;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Model for OPERATIVE_LISTING_Navbar component.
  late OPERATIVELISTINGNavbarModel oPERATIVELISTINGNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    oPERATIVELISTINGHeaderModel =
        createModel(context, () => OPERATIVELISTINGHeaderModel());
    secondaryButtonModel = createModel(context, () => SecondaryButtonModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    oPERATIVELISTINGNavbarModel =
        createModel(context, () => OPERATIVELISTINGNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    oPERATIVELISTINGHeaderModel.dispose();
    secondaryButtonModel.dispose();
    primaryButtonModel.dispose();
    oPERATIVELISTINGNavbarModel.dispose();
  }
}
