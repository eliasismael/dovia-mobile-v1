import '/flutter_flow/flutter_flow_util.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'l_e_g_a_l_h_q_procesos_widget.dart' show LEGALHQProcesosWidget;
import 'package:flutter/material.dart';

class LEGALHQProcesosModel extends FlutterFlowModel<LEGALHQProcesosWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field for the search bar (ID de inmueble / dirección).
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
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
    textFieldFocusNode?.dispose();
    textController?.dispose();
    legalHQHeaderModel.dispose();
    lEGALHQNavbarModel.dispose();
  }
}
