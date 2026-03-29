import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado_widget.dart'
    show DHASSOCIATETrabajoFinalizadoWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DHASSOCIATETrabajoFinalizadoModel
    extends FlutterFlowModel<DHASSOCIATETrabajoFinalizadoWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DH_ASSOCIATE_Header component.
  late DHASSOCIATEHeaderModel dHASSOCIATEHeaderModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_ASSOCIATE_Navbar component.
  late DHASSOCIATENavbarModel dHASSOCIATENavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dHASSOCIATEHeaderModel =
        createModel(context, () => DHASSOCIATEHeaderModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHASSOCIATENavbarModel =
        createModel(context, () => DHASSOCIATENavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dHASSOCIATEHeaderModel.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
