import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/texto_y_boton/texto_y_boton_widget.dart';
import 'dart:ui';
import 'legal_associate_home_widget.dart' show LegalAssociateHomeWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LegalAssociateHomeModel
    extends FlutterFlowModel<LegalAssociateHomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for LegalAssociate_Header component.
  late LegalAssociateHeaderModel legalAssociateHeaderModel;
  // Model for TextoYBoton component.
  late TextoYBotonModel textoYBotonModel;
  // Model for LEGAL_ASSOCAITE_Navbar component.
  late LEGALASSOCAITENavbarModel lEGALASSOCAITENavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    legalAssociateHeaderModel =
        createModel(context, () => LegalAssociateHeaderModel());
    textoYBotonModel = createModel(context, () => TextoYBotonModel());
    lEGALASSOCAITENavbarModel =
        createModel(context, () => LEGALASSOCAITENavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    legalAssociateHeaderModel.dispose();
    textoYBotonModel.dispose();
    lEGALASSOCAITENavbarModel.dispose();
  }
}
