import '/dovia_client/app/ajustes/opciones_de_notificaciones/opciones_de_notificaciones_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_ajustes_widget.dart'
    show DOVIACLIENTAjustesWidget;
import 'package:flutter/material.dart';

class DOVIACLIENTAjustesModel
    extends FlutterFlowModel<DOVIACLIENTAjustesWidget> {
  ///  Local state fields for this page.

  String selectedSection = 'perfil';

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // Model for OpcionesDeNotificaciones component.
  late OpcionesDeNotificacionesModel opcionesDeNotificacionesModel;
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
    opcionesDeNotificacionesModel =
        createModel(context, () => OpcionesDeNotificacionesModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    opcionesDeNotificacionesModel.dispose();
    fixedDoviaIconModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
