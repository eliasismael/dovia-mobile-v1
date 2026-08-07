import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_adicional_widget.dart'
    show DHASSOCIATETrabajoAdicionalWidget;
import 'package:flutter/material.dart';

class DHASSOCIATETrabajoAdicionalModel
    extends FlutterFlowModel<DHASSOCIATETrabajoAdicionalWidget> {
  ///  State fields for stateful widgets in this page.

  /// Fotos de dónde se usará el material. Son opcionales y se adjuntan después
  /// de crear la solicitud, porque el POST no las recibe.
  List<FFUploadedFile> uploadedMedia = [];

  /// True mientras se crea la solicitud y se suben las fotos, para que el botón
  /// no dispare dos solicitudes (el backend rechaza la segunda como activa).
  bool isSubmitting = false;

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DH_ASSOCIATE_Header component.
  late DHASSOCIATEHeaderModel dHASSOCIATEHeaderModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
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
    textFieldFocusNode?.dispose();
    textController?.dispose();

    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
