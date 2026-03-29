import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/favorite_houses_card/favorite_houses_card_widget.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_widget.dart'
    show DOVIACLIENTMisFavoritosWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DOVIACLIENTMisFavoritosModel
    extends FlutterFlowModel<DOVIACLIENTMisFavoritosWidget> {
  ///  Local state fields for this page.

  bool isCreatingNewFolder = false;

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
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
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    primaryButtonModel.dispose();
    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
