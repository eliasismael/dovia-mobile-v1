import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_planes/d_h_c_l_i_e_n_t_planes_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_c_forma_pago_suscripcion1_widget.dart'
    show DCFormaPagoSuscripcion1Widget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DCFormaPagoSuscripcion1Model
    extends FlutterFlowModel<DCFormaPagoSuscripcion1Widget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // Model for DH_CLIENT_Planes component.
  late DHCLIENTPlanesModel dHCLIENTPlanesModel;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    dHCLIENTPlanesModel = createModel(context, () => DHCLIENTPlanesModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    dHCLIENTPlanesModel.dispose();
    primaryButtonModel.dispose();
    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
