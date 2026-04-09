import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_oferta_compra_widget.dart'
    show DOVIACLIENTOfertaCompraWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DOVIACLIENTOfertaCompraModel
    extends FlutterFlowModel<DOVIACLIENTOfertaCompraWidget> {
  ///  Local state fields for this page.

  String paymentMethod = 'Contado';

  String selectedCurrency = 'USD';

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // State field(s) for Precio widget.
  FocusNode? precioFocusNode;
  TextEditingController? precioTextController;
  String? Function(BuildContext, String?)? precioTextControllerValidator;
  // State field(s) for UsoPermitido widget.
  FocusNode? usoPermitidoFocusNode;
  TextEditingController? usoPermitidoTextController;
  String? Function(BuildContext, String?)? usoPermitidoTextControllerValidator;
  // State field(s) for UsoNoPermitido widget.
  FocusNode? usoNoPermitidoFocusNode;
  TextEditingController? usoNoPermitidoTextController;
  String? Function(BuildContext, String?)?
      usoNoPermitidoTextControllerValidator;
  // State field(s) for OtrasConsideraciones widget.
  FocusNode? otrasConsideracionesFocusNode;
  TextEditingController? otrasConsideracionesTextController;
  String? Function(BuildContext, String?)?
      otrasConsideracionesTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for PropuestaEconomica widget.
  FocusNode? propuestaEconomicaFocusNode;
  TextEditingController? propuestaEconomicaTextController;
  String? Function(BuildContext, String?)?
      propuestaEconomicaTextControllerValidator;
  // State field(s) for CONTADO_TiempoEstimadoDePago widget.
  FocusNode? cONTADOTiempoEstimadoDePagoFocusNode;
  TextEditingController? cONTADOTiempoEstimadoDePagoTextController;
  String? Function(BuildContext, String?)?
      cONTADOTiempoEstimadoDePagoTextControllerValidator;
  // State field(s) for HIPOTECA_Enganche widget.
  FocusNode? hIPOTECAEngancheFocusNode;
  TextEditingController? hIPOTECAEngancheTextController;
  String? Function(BuildContext, String?)?
      hIPOTECAEngancheTextControllerValidator;
  // State field(s) for HIPOTECA_Banco widget.
  FocusNode? hIPOTECABancoFocusNode;
  TextEditingController? hIPOTECABancoTextController;
  String? Function(BuildContext, String?)? hIPOTECABancoTextControllerValidator;
  // State field(s) for HIPOTECA_EstadoCredito widget.
  FocusNode? hIPOTECAEstadoCreditoFocusNode;
  TextEditingController? hIPOTECAEstadoCreditoTextController;
  String? Function(BuildContext, String?)?
      hIPOTECAEstadoCreditoTextControllerValidator;
  // State field(s) for HIPOTECA_TiempoAprobacionBanco widget.
  FocusNode? hIPOTECATiempoAprobacionBancoFocusNode;
  TextEditingController? hIPOTECATiempoAprobacionBancoTextController;
  String? Function(BuildContext, String?)?
      hIPOTECATiempoAprobacionBancoTextControllerValidator;
  // State field(s) for PROMESA_ReservaInicial widget.
  FocusNode? pROMESAReservaInicialFocusNode;
  TextEditingController? pROMESAReservaInicialTextController;
  String? Function(BuildContext, String?)?
      pROMESAReservaInicialTextControllerValidator;
  // State field(s) for PROMESA_PagoFinal widget.
  FocusNode? pROMESAPagoFinalFocusNode;
  TextEditingController? pROMESAPagoFinalTextController;
  String? Function(BuildContext, String?)?
      pROMESAPagoFinalTextControllerValidator;
  // State field(s) for PROMESA_TiempoPromesa widget.
  FocusNode? pROMESATiempoPromesaFocusNode;
  TextEditingController? pROMESATiempoPromesaTextController;
  String? Function(BuildContext, String?)?
      pROMESATiempoPromesaTextControllerValidator;
  // State field(s) for NombreComprador widget.
  FocusNode? nombreCompradorFocusNode;
  TextEditingController? nombreCompradorTextController;
  String? Function(BuildContext, String?)?
      nombreCompradorTextControllerValidator;
  // State field(s) for RazonSocial widget.
  FocusNode? razonSocialFocusNode;
  TextEditingController? razonSocialTextController;
  String? Function(BuildContext, String?)? razonSocialTextControllerValidator;
  // State field(s) for RepresentanteLegal widget.
  FocusNode? representanteLegalFocusNode;
  TextEditingController? representanteLegalTextController;
  String? Function(BuildContext, String?)?
      representanteLegalTextControllerValidator;
  // State field(s) for Consideraciones widget.
  FocusNode? consideracionesFocusNode;
  TextEditingController? consideracionesTextController;
  String? Function(BuildContext, String?)?
      consideracionesTextControllerValidator;

  // State field(s) for rent proposed amount (used in 'ambos' mode)
  FocusNode? propuestaRentaFocusNode;
  TextEditingController? propuestaRentaTextController;
  String? Function(BuildContext, String?)? propuestaRentaTextControllerValidator;

  // New State field(s) for RENT dates
  FocusNode? fechaInicioContratoFocusNode;
  TextEditingController? fechaInicioContratoTextController;
  String? Function(BuildContext, String?)? fechaInicioContratoTextControllerValidator;

  FocusNode? fechaFinalizacionContratoFocusNode;
  TextEditingController? fechaFinalizacionContratoTextController;
  String? Function(BuildContext, String?)? fechaFinalizacionContratoTextControllerValidator;

  FocusNode? duracionContratoFocusNode;
  TextEditingController? duracionContratoTextController;
  String? Function(BuildContext, String?)? duracionContratoTextControllerValidator;
  
  // State field(s) for DropDown widget.
  String? usoADarPropertyUseValue;
  FormFieldController<String>? usoADarPropertyUseValueController;
  
  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Stores action output result for [Backend Call - API (Create Offer  PURCHASE Cash)] action in PrimaryButton widget.
  ApiCallResponse? ofertaContado;
  // Stores action output result for [Backend Call - API (Create Offer  PURCHASE Mortgage)] action in PrimaryButton widget.
  ApiCallResponse? ofertaHipoteca;
  // Stores action output result for [Backend Call - API (Create Offer - PURCHASE (Purchase Promise))] action in PrimaryButton widget.
  ApiCallResponse? ofertaPromesa;
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
    precioFocusNode?.dispose();
    precioTextController?.dispose();

    usoPermitidoFocusNode?.dispose();
    usoPermitidoTextController?.dispose();

    usoNoPermitidoFocusNode?.dispose();
    usoNoPermitidoTextController?.dispose();

    otrasConsideracionesFocusNode?.dispose();
    otrasConsideracionesTextController?.dispose();

    propuestaEconomicaFocusNode?.dispose();
    propuestaEconomicaTextController?.dispose();

    cONTADOTiempoEstimadoDePagoFocusNode?.dispose();
    cONTADOTiempoEstimadoDePagoTextController?.dispose();

    hIPOTECAEngancheFocusNode?.dispose();
    hIPOTECAEngancheTextController?.dispose();

    hIPOTECABancoFocusNode?.dispose();
    hIPOTECABancoTextController?.dispose();

    hIPOTECAEstadoCreditoFocusNode?.dispose();
    hIPOTECAEstadoCreditoTextController?.dispose();

    hIPOTECATiempoAprobacionBancoFocusNode?.dispose();
    hIPOTECATiempoAprobacionBancoTextController?.dispose();

    pROMESAReservaInicialFocusNode?.dispose();
    pROMESAReservaInicialTextController?.dispose();

    pROMESAPagoFinalFocusNode?.dispose();
    pROMESAPagoFinalTextController?.dispose();

    pROMESATiempoPromesaFocusNode?.dispose();
    pROMESATiempoPromesaTextController?.dispose();

    nombreCompradorFocusNode?.dispose();
    nombreCompradorTextController?.dispose();

    razonSocialFocusNode?.dispose();
    razonSocialTextController?.dispose();

    representanteLegalFocusNode?.dispose();
    representanteLegalTextController?.dispose();

    consideracionesFocusNode?.dispose();
    consideracionesTextController?.dispose();

    propuestaRentaFocusNode?.dispose();
    propuestaRentaTextController?.dispose();

    fechaInicioContratoFocusNode?.dispose();
    fechaInicioContratoTextController?.dispose();

    fechaFinalizacionContratoFocusNode?.dispose();
    fechaFinalizacionContratoTextController?.dispose();

    duracionContratoFocusNode?.dispose();
    duracionContratoTextController?.dispose();

    primaryButtonModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
