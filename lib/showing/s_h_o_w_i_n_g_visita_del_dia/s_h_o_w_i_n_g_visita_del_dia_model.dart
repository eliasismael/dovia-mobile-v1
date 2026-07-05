import '/flutter_flow/flutter_flow_util.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 's_h_o_w_i_n_g_visita_del_dia_widget.dart'
    show SHOWINGVisitaDelDiaWidget;
import 'package:flutter/material.dart';

class SHOWINGVisitaDelDiaModel
    extends FlutterFlowModel<SHOWINGVisitaDelDiaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for SHOWING_Navbar component.
  late SHOWINGNavbarModel sHOWINGNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    sHOWINGNavbarModel = createModel(context, () => SHOWINGNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    sHOWINGNavbarModel.dispose();
  }
}
