import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_servicios_widget.dart'
    show DHASSOCIATEServiciosWidget;
import 'package:flutter/material.dart';

class DHASSOCIATEServiciosModel
    extends FlutterFlowModel<DHASSOCIATEServiciosWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DH_ASSOCIATE_Header component.
  late DHASSOCIATEHeaderModel dHASSOCIATEHeaderModel;

  /// Especialidad elegida para la solicitud. Es un único id y no un set: el
  /// flujo exige "1 formulario por especialización", así que el selector se
  /// comporta como un radio button.
  String? selectedSpecialtyId;

  // State field(s) for the "experiencia" TextField.
  FocusNode? experienceFocusNode;
  TextEditingController? experienceController;
  String? Function(BuildContext, String?)? experienceControllerValidator;

  /// Certificado o título de respaldo. Uno solo, por la misma regla de "1
  /// formulario por especialización".
  FFUploadedFile? certificate;
  bool isPickingCertificate = false;

  /// Evita reenvíos mientras el POST está en vuelo.
  bool isSubmitting = false;

  /// Especialidades que este asociado ya solicitó **en esta sesión**. Se atenúan
  /// en el selector para que no mande dos veces la misma solicitud apenas ve el
  /// modal de éxito.
  ///
  /// Se superpone a las pendientes que devuelve `GET /users/me/specialties`, y
  /// no las reemplaza: cubre la ventana entre el envío y la recarga del listado.
  /// La defensa definitiva contra duplicados es del backend.
  final Set<String> requestedSpecialtyIds = {};

  // Model for FIXED_DOVIA_ICON component.
  late FixedDoviaIconModel fixedDoviaIconModel;
  // Model for DH_ASSOCIATE_Navbar component.
  late DHASSOCIATENavbarModel dHASSOCIATENavbarModel;

  /// Deja el formulario como recién abierto, después de un envío exitoso.
  void resetForm() {
    selectedSpecialtyId = null;
    experienceController?.clear();
    certificate = null;
  }

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
    experienceFocusNode?.dispose();
    experienceController?.dispose();

    fixedDoviaIconModel.dispose();
    dHASSOCIATENavbarModel.dispose();
  }
}
