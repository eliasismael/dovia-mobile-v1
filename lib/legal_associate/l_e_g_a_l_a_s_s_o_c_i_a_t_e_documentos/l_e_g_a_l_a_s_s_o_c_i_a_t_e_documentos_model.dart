import '/flutter_flow/flutter_flow_util.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_documentos_widget.dart'
    show LEGALASSOCIATEDocumentosWidget;
import 'package:flutter/material.dart';

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
