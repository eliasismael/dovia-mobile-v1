import '/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_card_operative_lister/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_card_operative_lister_widget.dart';
import '/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita_lister_h_q/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita_lister_h_q_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita1_widget.dart'
    show DOVIACLIENTMisPropiedadesVisita1Widget;
import 'package:flutter/material.dart';

class DOVIACLIENTMisPropiedadesVisita1Model
    extends FlutterFlowModel<DOVIACLIENTMisPropiedadesVisita1Widget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // Model for DOVIA_CLIENT_MisPropiedades_Card_Operative_Lister component.
  late DOVIACLIENTMisPropiedadesCardOperativeListerModel
      dOVIACLIENTMisPropiedadesCardOperativeListerModel;
  // Model for DOVIA_CLIENT_MisPropiedades_Visita_ListerHQ component.
  late DOVIACLIENTMisPropiedadesVisitaListerHQModel
      dOVIACLIENTMisPropiedadesVisitaListerHQModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
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
    dOVIACLIENTMisPropiedadesCardOperativeListerModel = createModel(
        context, () => DOVIACLIENTMisPropiedadesCardOperativeListerModel());
    dOVIACLIENTMisPropiedadesVisitaListerHQModel = createModel(
        context, () => DOVIACLIENTMisPropiedadesVisitaListerHQModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    dOVIACLIENTMisPropiedadesCardOperativeListerModel.dispose();
    dOVIACLIENTMisPropiedadesVisitaListerHQModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
