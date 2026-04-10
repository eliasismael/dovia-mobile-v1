import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'l_i_s_t_i_n_g_h_q_notifications_widget.dart'
    show LISTINGHQNotificationsWidget;
import 'package:flutter/material.dart';

class LISTINGHQNotificationsModel
    extends FlutterFlowModel<LISTINGHQNotificationsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for LISTING_HQ_Header component.
  late LISTINGHQHeaderModel lISTINGHQHeaderModel;
  // Model for OPERATIVE_LISTING_Navbar component.
  late OPERATIVELISTINGNavbarModel oPERATIVELISTINGNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    lISTINGHQHeaderModel = createModel(context, () => LISTINGHQHeaderModel());
    oPERATIVELISTINGNavbarModel =
        createModel(context, () => OPERATIVELISTINGNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    lISTINGHQHeaderModel.dispose();
    oPERATIVELISTINGNavbarModel.dispose();
  }
}
