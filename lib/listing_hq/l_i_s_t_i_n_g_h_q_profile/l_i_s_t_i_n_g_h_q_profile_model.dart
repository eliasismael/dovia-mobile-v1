import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'l_i_s_t_i_n_g_h_q_profile_widget.dart' show LISTINGHQProfileWidget;
import 'package:flutter/material.dart';

class LISTINGHQProfileModel extends FlutterFlowModel<LISTINGHQProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for LISTING_HQ_Header component.
  late LISTINGHQHeaderModel lISTINGHQHeaderModel;
  // Model for LISTING_HQ_Navbar component.
  late LISTINGHQNavbarModel lISTINGHQNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    lISTINGHQHeaderModel = createModel(context, () => LISTINGHQHeaderModel());
    lISTINGHQNavbarModel = createModel(context, () => LISTINGHQNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    lISTINGHQHeaderModel.dispose();
    lISTINGHQNavbarModel.dispose();
  }
}
