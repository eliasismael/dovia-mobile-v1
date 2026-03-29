import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proveedor_card/d_h_c_l_i_e_n_t_proveedor_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_h_c_l_i_e_n_t_casa_a_widget.dart' show DHCLIENTCasaAWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DHCLIENTCasaAModel extends FlutterFlowModel<DHCLIENTCasaAWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // State field(s) for DireccionInput widget.
  FocusNode? direccionInputFocusNode1;
  TextEditingController? direccionInputTextController1;
  String? Function(BuildContext, String?)?
      direccionInputTextController1Validator;
  // State field(s) for DiaInput widget.
  FocusNode? diaInputFocusNode;
  TextEditingController? diaInputTextController;
  String? Function(BuildContext, String?)? diaInputTextControllerValidator;
  // State field(s) for MesInput widget.
  FocusNode? mesInputFocusNode;
  TextEditingController? mesInputTextController;
  String? Function(BuildContext, String?)? mesInputTextControllerValidator;
  // State field(s) for YearInput widget.
  FocusNode? yearInputFocusNode;
  TextEditingController? yearInputTextController;
  String? Function(BuildContext, String?)? yearInputTextControllerValidator;
  // State field(s) for LlegarInput widget.
  FocusNode? llegarInputFocusNode1;
  TextEditingController? llegarInputTextController1;
  String? Function(BuildContext, String?)? llegarInputTextController1Validator;
  // State field(s) for DireccionInput widget.
  FocusNode? direccionInputFocusNode2;
  TextEditingController? direccionInputTextController2;
  String? Function(BuildContext, String?)?
      direccionInputTextController2Validator;
  // State field(s) for LlegarInput widget.
  FocusNode? llegarInputFocusNode2;
  TextEditingController? llegarInputTextController2;
  String? Function(BuildContext, String?)? llegarInputTextController2Validator;
  // Model for DH_CLIENT_ProveedorCard component.
  late DHCLIENTProveedorCardModel dHCLIENTProveedorCardModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_CLIENT_Navbar component.
  late DHCLIENTNavbarModel dHCLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    dHCLIENTProveedorCardModel =
        createModel(context, () => DHCLIENTProveedorCardModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHCLIENTNavbarModel = createModel(context, () => DHCLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    direccionInputFocusNode1?.dispose();
    direccionInputTextController1?.dispose();

    diaInputFocusNode?.dispose();
    diaInputTextController?.dispose();

    mesInputFocusNode?.dispose();
    mesInputTextController?.dispose();

    yearInputFocusNode?.dispose();
    yearInputTextController?.dispose();

    llegarInputFocusNode1?.dispose();
    llegarInputTextController1?.dispose();

    direccionInputFocusNode2?.dispose();
    direccionInputTextController2?.dispose();

    llegarInputFocusNode2?.dispose();
    llegarInputTextController2?.dispose();

    dHCLIENTProveedorCardModel.dispose();
    fixedDoviaIconModel.dispose();
    dHCLIENTNavbarModel.dispose();
  }
}
