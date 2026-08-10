import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_cotizacion_widget.dart'
    show DHASSOCIATECotizacionWidget;
import 'package:flutter/material.dart';

class DHASSOCIATECotizacionModel
    extends FlutterFlowModel<DHASSOCIATECotizacionWidget> {
  ///  State fields for stateful widgets in this page.

  /// Monto total de la propuesta, en GTQ. Es el número que el cliente compara
  /// contra las otras empresas y el que se le cobra si acepta.
  FocusNode? amountFocusNode;
  TextEditingController? amountController;
  String? Function(BuildContext, String?)? amountControllerValidator;

  /// PDF con el presupuesto detallado. El endpoint lo exige: la propuesta es el
  /// documento, el monto sólo su resumen.
  FFUploadedFile? proposalFile;

  bool isPickingFile = false;
  bool isSubmitting = false;

  /// Propuesta ya enviada en esta pantalla. Evita un segundo envío sobre la
  /// misma oportunidad sin tener que releer el listado.
  bool submitted = false;

  /// Detalle del requerimiento tal como lo devuelve
  /// `GET /dovia-home/company/service-requests/{id}`: es lo que trae las fotos
  /// y el texto completo del cliente, que el listado del marketplace resume.
  Map<String, dynamic>? detail;
  bool isLoadingDetail = false;

  // Model for DH_ASSOCIATE_Header component.
  late DHASSOCIATEHeaderModel dHASSOCIATEHeaderModel;
  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_ASSOCIATE_Navbar component.
  late DHASSOCIATENavbarModel dHASSOCIATENavbarModel;

  @override
  void initState(BuildContext context) {
    dHASSOCIATEHeaderModel =
        createModel(context, () => DHASSOCIATEHeaderModel());
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    fixedDoviaIconModel = createModel(context, () => FixedDoviaIconModel());
    dHASSOCIATENavbarModel =
        createModel(context, () => DHASSOCIATENavbarModel());
  }

  @override
  void dispose() {
    amountFocusNode?.dispose();
    amountController?.dispose();
    dHASSOCIATEHeaderModel.dispose();
    cornerGradientBackgroundModel.dispose();
    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
