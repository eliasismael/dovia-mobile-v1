import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_agregar_caracteristica_widget.dart'
    show OPERATIVELISTINGAgregarCaracteristicaWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OPERATIVELISTINGAgregarCaracteristicaModel
    extends FlutterFlowModel<OPERATIVELISTINGAgregarCaracteristicaWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;

  @override
  void initState(BuildContext context) {
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    primaryButtonModel.dispose();
  }
}
