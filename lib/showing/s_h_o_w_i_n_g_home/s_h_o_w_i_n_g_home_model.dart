import '/flutter_flow/flutter_flow_util.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import 's_h_o_w_i_n_g_home_widget.dart' show SHOWINGHomeWidget;
import 'package:flutter/material.dart';

class SHOWINGHomeModel extends FlutterFlowModel<SHOWINGHomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for SHOWING_Header component.
  late SHOWINGHeaderModel sHOWINGHeaderModel;
  // Model for SHOWING_Navbar component.
  late SHOWINGNavbarModel sHOWINGNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    sHOWINGHeaderModel = createModel(context, () => SHOWINGHeaderModel());
    sHOWINGNavbarModel = createModel(context, () => SHOWINGNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    sHOWINGHeaderModel.dispose();
    sHOWINGNavbarModel.dispose();
  }
}
