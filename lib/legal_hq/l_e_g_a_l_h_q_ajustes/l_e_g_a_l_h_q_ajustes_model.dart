import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'l_e_g_a_l_h_q_ajustes_widget.dart' show LEGALHQAjustesWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LEGALHQAjustesModel extends FlutterFlowModel<LEGALHQAjustesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for Legal_HQ_Header component.
  late LegalHQHeaderModel legalHQHeaderModel;
  // Model for LEGAL_HQ_Navbar component.
  late LEGALHQNavbarModel lEGALHQNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    legalHQHeaderModel = createModel(context, () => LegalHQHeaderModel());
    lEGALHQNavbarModel = createModel(context, () => LEGALHQNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    legalHQHeaderModel.dispose();
    lEGALHQNavbarModel.dispose();
  }
}
