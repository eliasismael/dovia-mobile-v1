import '/dovia_home_client/d_h_c_l_i_e_n_t_material_aprobado/d_h_c_l_i_e_n_t_material_aprobado_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_h_c_l_i_e_n_t_materiales_widget.dart' show DHCLIENTMaterialesWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DHCLIENTMaterialesModel
    extends FlutterFlowModel<DHCLIENTMaterialesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // State field(s) for ApellidosInput widget.
  FocusNode? apellidosInputFocusNode1;
  TextEditingController? apellidosInputTextController1;
  String? Function(BuildContext, String?)?
      apellidosInputTextController1Validator;
  // State field(s) for ApellidosInput widget.
  FocusNode? apellidosInputFocusNode2;
  TextEditingController? apellidosInputTextController2;
  String? Function(BuildContext, String?)?
      apellidosInputTextController2Validator;
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
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHCLIENTNavbarModel = createModel(context, () => DHCLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    apellidosInputFocusNode1?.dispose();
    apellidosInputTextController1?.dispose();

    apellidosInputFocusNode2?.dispose();
    apellidosInputTextController2?.dispose();

    fixedDoviaIconModel.dispose();
    dHCLIENTNavbarModel.dispose();
  }
}
