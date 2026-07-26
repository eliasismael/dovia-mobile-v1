import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'd_h_c_l_i_e_n_t_fuera_de_alcance_widget.dart'
    show DHCLIENTFueraDeAlcanceWidget;
import 'package:flutter/material.dart';

class DHCLIENTFueraDeAlcanceModel
    extends FlutterFlowModel<DHCLIENTFueraDeAlcanceWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  bool isLoadingDiagnosis = false;

  /// True cuando la lectura del diagnóstico falló: la pantalla avisa en vez de
  /// mostrarse vacía como si el asociado no hubiera cargado nada.
  bool diagnosisLoadFailed = false;

  /// True mientras se autoriza o se cierra la solicitud, para que la decisión
  /// contraria no pueda dispararse al mismo tiempo.
  bool isSubmitting = false;
  String? diagnosisText;
  List<String> diagnosisImagesUrls = [];

  /// Estatus de la solicitud fuera de alcance (`CLIENT_APPROVAL_PENDING`
  /// mientras espera la decisión del cliente, `QUOTING` una vez autorizada,
  /// cerrada si el cliente la finalizó). Null si todavía no se leyó.
  String? requestStatus;

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

    fixedDoviaIconModel.dispose();
    dHCLIENTNavbarModel.dispose();
  }
}
