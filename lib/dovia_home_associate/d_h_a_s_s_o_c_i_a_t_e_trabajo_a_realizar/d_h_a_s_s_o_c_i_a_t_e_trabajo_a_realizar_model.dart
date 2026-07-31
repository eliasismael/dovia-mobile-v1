import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar_widget.dart'
    show DHASSOCIATETrabajoARealizarWidget;
import 'package:flutter/material.dart';

class DHASSOCIATETrabajoARealizarModel
    extends FlutterFlowModel<DHASSOCIATETrabajoARealizarWidget> {
  ///  State fields for stateful widgets in this page.

  /// Detalle fresco de la solicitud traído del backend. Reemplaza al dato que
  /// llegó del listado en cuanto responde.
  Map<String, dynamic>? detail;

  /// Lectura del detalle en curso.
  bool isLoadingDetail = false;

  /// Postulación en curso: bloquea el botón para no tomar dos veces el mismo
  /// trabajo con un doble tap.
  bool isTaking = false;

  /// El asociado ya tomó este trabajo en esta pantalla. Evita ofrecerle
  /// postularse de nuevo antes de que vuelva al panel.
  bool taken = false;

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DH_ASSOCIATE_Header component.
  late DHASSOCIATEHeaderModel dHASSOCIATEHeaderModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_ASSOCIATE_Navbar component.
  late DHASSOCIATENavbarModel dHASSOCIATENavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dHASSOCIATEHeaderModel =
        createModel(context, () => DHASSOCIATEHeaderModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHASSOCIATENavbarModel =
        createModel(context, () => DHASSOCIATENavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dHASSOCIATEHeaderModel.dispose();
    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
