import '/backend/api_requests/api_calls.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import 'd_o_v_i_a_c_l_i_e_n_t_oferta_renta_widget.dart'
    show DOVIACLIENTOfertaRentaWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DOVIACLIENTOfertaRentaModel
    extends FlutterFlowModel<DOVIACLIENTOfertaRentaWidget> {
  ///  Local state fields for this page.

  String selectedCurrency = 'USD';

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // State field(s) for PrecioMensual widget.
  FocusNode? precioMensualFocusNode;
  TextEditingController? precioMensualTextController;
  String? Function(BuildContext, String?)? precioMensualTextControllerValidator;
  // State field(s) for UsoPermitido widget.
  FocusNode? usoPermitidoFocusNode;
  TextEditingController? usoPermitidoTextController;
  String? Function(BuildContext, String?)? usoPermitidoTextControllerValidator;
  // State field(s) for UsoNoPermitido widget.
  FocusNode? usoNoPermitidoFocusNode1;
  TextEditingController? usoNoPermitidoTextController1;
  String? Function(BuildContext, String?)?
      usoNoPermitidoTextController1Validator;
  // State field(s) for OtrasConsideraciones widget.
  FocusNode? otrasConsideracionesFocusNode;
  TextEditingController? otrasConsideracionesTextController;
  String? Function(BuildContext, String?)?
      otrasConsideracionesTextControllerValidator;
  // State field(s) for UsoNoPermitido widget.
  FocusNode? usoNoPermitidoFocusNode2;
  TextEditingController? usoNoPermitidoTextController2;
  String? Function(BuildContext, String?)?
      usoNoPermitidoTextController2Validator;
  // State field(s) for UsoNoPermitido widget.
  FocusNode? usoNoPermitidoFocusNode3;
  TextEditingController? usoNoPermitidoTextController3;
  String? Function(BuildContext, String?)?
      usoNoPermitidoTextController3Validator;
  // State field(s) for PropuestaEconomica widget.
  FocusNode? propuestaEconomicaFocusNode1;
  TextEditingController? propuestaEconomicaTextController1;
  String? Function(BuildContext, String?)?
      propuestaEconomicaTextController1Validator;
  // State field(s) for PropuestaEconomica widget.
  FocusNode? propuestaEconomicaFocusNode2;
  TextEditingController? propuestaEconomicaTextController2;
  String? Function(BuildContext, String?)?
      propuestaEconomicaTextController2Validator;
  // State field(s) for PropuestaEconomica widget.
  FocusNode? propuestaEconomicaFocusNode3;
  TextEditingController? propuestaEconomicaTextController3;
  String? Function(BuildContext, String?)?
      propuestaEconomicaTextController3Validator;
  // State field(s) for PropuestaEconomica widget.
  FocusNode? propuestaEconomicaFocusNode4;
  TextEditingController? propuestaEconomicaTextController4;
  String? Function(BuildContext, String?)?
      propuestaEconomicaTextController4Validator;
  // State field(s) for PropuestaEconomica widget.
  FocusNode? propuestaEconomicaFocusNode5;
  TextEditingController? propuestaEconomicaTextController5;
  String? Function(BuildContext, String?)?
      propuestaEconomicaTextController5Validator;
  // State field(s) for NombreArrendatario widget.
  FocusNode? nombreArrendatarioFocusNode;
  TextEditingController? nombreArrendatarioTextController;
  String? Function(BuildContext, String?)?
      nombreArrendatarioTextControllerValidator;
  // State field(s) for RazonSocial widget.
  FocusNode? razonSocialFocusNode;
  TextEditingController? razonSocialTextController;
  String? Function(BuildContext, String?)? razonSocialTextControllerValidator;
  // State field(s) for RepresentanteLegal widget.
  FocusNode? representanteLegalFocusNode;
  TextEditingController? representanteLegalTextController;
  String? Function(BuildContext, String?)?
      representanteLegalTextControllerValidator;
  // Stores the API call response for rent offer creation.
  ApiCallResponse? apiResultRentOffer;
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Model for DOVIA_CLIENT_Navbar component.
  late DOVIACLIENTNavbarModel dOVIACLIENTNavbarModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    dOVIASHAREDHeaderModel =
        createModel(context, () => DOVIASHAREDHeaderModel());
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
    dOVIACLIENTNavbarModel =
        createModel(context, () => DOVIACLIENTNavbarModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    dOVIASHAREDHeaderModel.dispose();
    precioMensualFocusNode?.dispose();
    precioMensualTextController?.dispose();

    usoPermitidoFocusNode?.dispose();
    usoPermitidoTextController?.dispose();

    usoNoPermitidoFocusNode1?.dispose();
    usoNoPermitidoTextController1?.dispose();

    otrasConsideracionesFocusNode?.dispose();
    otrasConsideracionesTextController?.dispose();

    usoNoPermitidoFocusNode2?.dispose();
    usoNoPermitidoTextController2?.dispose();

    usoNoPermitidoFocusNode3?.dispose();
    usoNoPermitidoTextController3?.dispose();

    propuestaEconomicaFocusNode1?.dispose();
    propuestaEconomicaTextController1?.dispose();

    propuestaEconomicaFocusNode2?.dispose();
    propuestaEconomicaTextController2?.dispose();

    propuestaEconomicaFocusNode3?.dispose();
    propuestaEconomicaTextController3?.dispose();

    propuestaEconomicaFocusNode4?.dispose();
    propuestaEconomicaTextController4?.dispose();

    propuestaEconomicaFocusNode5?.dispose();
    propuestaEconomicaTextController5?.dispose();

    nombreArrendatarioFocusNode?.dispose();
    nombreArrendatarioTextController?.dispose();

    razonSocialFocusNode?.dispose();
    razonSocialTextController?.dispose();

    representanteLegalFocusNode?.dispose();
    representanteLegalTextController?.dispose();

    primaryButtonModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
