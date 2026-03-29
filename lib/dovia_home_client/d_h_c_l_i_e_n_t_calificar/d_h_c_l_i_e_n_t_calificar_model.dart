import '/dovia_home_client/d_h_c_l_i_e_n_t_califico_exito/d_h_c_l_i_e_n_t_califico_exito_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import 'd_h_c_l_i_e_n_t_calificar_widget.dart' show DHCLIENTCalificarWidget;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DHCLIENTCalificarModel extends FlutterFlowModel<DHCLIENTCalificarWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // State field(s) for RatingBar widget.
  double? ratingBarValue;
  // State field(s) for DireccionInput widget.
  FocusNode? direccionInputFocusNode;
  TextEditingController? direccionInputTextController;
  String? Function(BuildContext, String?)?
      direccionInputTextControllerValidator;
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
    direccionInputFocusNode?.dispose();
    direccionInputTextController?.dispose();

    fixedDoviaIconModel.dispose();
    dHCLIENTNavbarModel.dispose();
  }
}
