import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import 'dart:ui';
import 's_h_o_w_i_n_g_propiedades_a_mostrar_widget.dart'
    show SHOWINGPropiedadesAMostrarWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SHOWINGPropiedadesAMostrarModel
    extends FlutterFlowModel<SHOWINGPropiedadesAMostrarWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for SHOWING_Header component.
  late SHOWINGHeaderModel sHOWINGHeaderModel;
  // Model for LISTING_HQ_Navbar component.
  late LISTINGHQNavbarModel lISTINGHQNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    sHOWINGHeaderModel = createModel(context, () => SHOWINGHeaderModel());
    lISTINGHQNavbarModel = createModel(context, () => LISTINGHQNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    sHOWINGHeaderModel.dispose();
    lISTINGHQNavbarModel.dispose();
  }
}
