import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_c_l_i_e_n_t_visitas_finalizadas_lista_widget.dart'
    show DHCLIENTVisitasFinalizadasListaWidget;
import 'package:flutter/material.dart';

class DHCLIENTVisitasFinalizadasListaModel
    extends FlutterFlowModel<DHCLIENTVisitasFinalizadasListaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_CLIENT_Navbar component.
  late DHCLIENTNavbarModel dHCLIENTNavbarModel;

  // Filtros dinamicos.
  // Tipo de trabajo (serviceName). null = "Todos".
  String? typeFilter;
  FormFieldController<String>? typeController;
  // Estado del trabajo (label mostrado en la pill). null = "Todos".
  String? statusFilter;
  FormFieldController<String>? statusController;
  // Fecha del trabajo. null = cualquier fecha.
  DateTime? dateFilter;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHCLIENTNavbarModel = createModel(context, () => DHCLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    fixedDoviaIconModel.dispose();
    dHCLIENTNavbarModel.dispose();
  }
}
