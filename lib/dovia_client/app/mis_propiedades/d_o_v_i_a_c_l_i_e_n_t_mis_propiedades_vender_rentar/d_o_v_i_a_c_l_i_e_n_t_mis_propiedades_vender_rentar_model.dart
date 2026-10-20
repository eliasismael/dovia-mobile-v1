import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart'
    show DOVIACLIENTMisPropiedadesVenderRentarWidget;
import 'package:flutter/material.dart';

/// Los campos del formulario viven en el estado de la pantalla, por clave
/// (ver `property_publication_form.dart`); acá quedan los componentes.
class DOVIACLIENTMisPropiedadesVenderRentarModel
    extends FlutterFlowModel<DOVIACLIENTMisPropiedadesVenderRentarWidget> {
  /// Id de la propiedad creada con todos sus documentos. Si se vuelve a esta
  /// pantalla, "Aceptar" sigue con esa propiedad en vez de crear otra.
  String? createdPropertyId;

  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  late DrawMapComponentModel drawMapComponentModel;
  late PrimaryButtonModel primaryButtonModel;
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    drawMapComponentModel = createModel(context, () => DrawMapComponentModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    drawMapComponentModel.dispose();
    primaryButtonModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
