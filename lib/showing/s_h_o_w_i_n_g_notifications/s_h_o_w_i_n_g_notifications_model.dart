import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import 's_h_o_w_i_n_g_notifications_widget.dart'
    show SHOWINGNotificationsWidget;
import 'package:flutter/material.dart';

class SHOWINGNotificationsModel
    extends FlutterFlowModel<SHOWINGNotificationsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for SHOWING_Header component.
  late SHOWINGHeaderModel sHOWINGHeaderModel;
  // Model for OPERATIVE_LISTING_Navbar component.
  late OPERATIVELISTINGNavbarModel oPERATIVELISTINGNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    sHOWINGHeaderModel = createModel(context, () => SHOWINGHeaderModel());
    oPERATIVELISTINGNavbarModel =
        createModel(context, () => OPERATIVELISTINGNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    sHOWINGHeaderModel.dispose();
    oPERATIVELISTINGNavbarModel.dispose();
  }
}
