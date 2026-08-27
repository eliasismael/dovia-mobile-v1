import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_widget.dart'
    show DOVIACLIENTMisOfertasWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisOfertasModel
    extends FlutterFlowModel<DOVIACLIENTMisOfertasWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for the "Búsqueda con IA" TextField.
  FocusNode? searchFocusNode;
  TextEditingController? searchController;

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // Model for FixedDoviaIcon component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    searchFocusNode?.dispose();
    searchController?.dispose();
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
