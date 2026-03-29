import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_documentos_widget.dart'
    show LEGALASSOCIATEDocumentosWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LEGALASSOCIATEDocumentosModel
    extends FlutterFlowModel<LEGALASSOCIATEDocumentosWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for LEGAL_ASSOCAITE_Navbar component.
  late LEGALASSOCAITENavbarModel lEGALASSOCAITENavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    lEGALASSOCAITENavbarModel =
        createModel(context, () => LEGALASSOCAITENavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    lEGALASSOCAITENavbarModel.dispose();
  }
}
