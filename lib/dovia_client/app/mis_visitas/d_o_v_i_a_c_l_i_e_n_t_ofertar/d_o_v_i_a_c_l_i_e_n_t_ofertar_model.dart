import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_ofertar_widget.dart'
    show DOVIACLIENTOfertarWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DOVIACLIENTOfertarModel
    extends FlutterFlowModel<DOVIACLIENTOfertarWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel1;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel2;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    secondaryButtonModel1 = createModel(context, () => SecondaryButtonModel());
    secondaryButtonModel2 = createModel(context, () => SecondaryButtonModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    secondaryButtonModel1.dispose();
    secondaryButtonModel2.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
