import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart'
    show DOVIACLIENTMisPropiedadesVenderRentarWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/form_field_controller.dart';

class DOVIACLIENTMisPropiedadesVenderRentarModel
    extends FlutterFlowModel<DOVIACLIENTMisPropiedadesVenderRentarWidget> {
  ///  Local state fields for this page.

  String? createdPropertyId;

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for DOVIA_SHARED_Header component.
  late DOVIASHAREDHeaderModel dOVIASHAREDHeaderModel;
  // State field(s) for DescripcionPropiedad widget.
  FocusNode? descripcionPropiedadFocusNode;
  TextEditingController? descripcionPropiedadTextController;
  String? Function(BuildContext, String?)?
      descripcionPropiedadTextControllerValidator;
  // State field(s) for PrecioVenta widget.
  FocusNode? precioVentaFocusNode;
  TextEditingController? precioVentaTextController;
  String? Function(BuildContext, String?)? precioVentaTextControllerValidator;
  // State field(s) for CantidadARecibir widget.
  FocusNode? cantidadARecibirFocusNode;
  TextEditingController? cantidadARecibirTextController;
  String? Function(BuildContext, String?)?
      cantidadARecibirTextControllerValidator;
  // State field(s) for Mantenimiento widget.
  FocusNode? mantenimientoFocusNode;
  TextEditingController? mantenimientoTextController;
  String? Function(BuildContext, String?)? mantenimientoTextControllerValidator;
  // State field(s) for ImpustoUnicoInmuebles widget.
  FocusNode? impustoUnicoInmueblesFocusNode;
  TextEditingController? impustoUnicoInmueblesTextController;
  String? Function(BuildContext, String?)?
      impustoUnicoInmueblesTextControllerValidator;
  // State field(s) for PrecioRentaMensual widget.
  FocusNode? precioRentaMensualFocusNode;
  TextEditingController? precioRentaMensualTextController;
  String? Function(BuildContext, String?)?
      precioRentaMensualTextControllerValidator;
  // State field(s) for ComisionDovia1Renta widget.
  FocusNode? comisionDovia1RentaFocusNode;
  TextEditingController? comisionDovia1RentaTextController;
  String? Function(BuildContext, String?)?
      comisionDovia1RentaTextControllerValidator;
  // State field(s) for TiempoMinimo widget.
  FocusNode? tiempoMinimoFocusNode;
  TextEditingController? tiempoMinimoTextController;
  String? Function(BuildContext, String?)? tiempoMinimoTextControllerValidator;
  // State field(s) for RentaOtros widget.
  FocusNode? rentaOtrosFocusNode;
  TextEditingController? rentaOtrosTextController;
  String? Function(BuildContext, String?)? rentaOtrosTextControllerValidator;

  // New fields for Rent
  FocusNode? disponibleDesdeFocusNode;
  TextEditingController? disponibleDesdeTextController;
  String? Function(BuildContext, String?)? disponibleDesdeTextControllerValidator;

  FocusNode? usoPermitidoFocusNode;
  TextEditingController? usoPermitidoTextController;
  String? Function(BuildContext, String?)? usoPermitidoTextControllerValidator;

  FocusNode? usoNoPermitidoFocusNode;
  TextEditingController? usoNoPermitidoTextController;
  String? Function(BuildContext, String?)? usoNoPermitidoTextControllerValidator;
  // State field(s) for Zona widget.
  String? zonaValue;
  FormFieldController<String>? zonaValueController;
  // State field(s) for DireccionPropiedad widget.
  FocusNode? direccionPropiedadFocusNode;
  TextEditingController? direccionPropiedadTextController;
  String? Function(BuildContext, String?)?
      direccionPropiedadTextControllerValidator;
  // Model for DrawMapComponent component.
  late DrawMapComponentModel drawMapComponentModel;
  bool isDataUploading_certifiacionDePropiedad = false;
  FFUploadedFile uploadedLocalFile_certifiacionDePropiedad =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for Finca widget.
  FocusNode? fincaFocusNode;
  TextEditingController? fincaTextController;
  String? Function(BuildContext, String?)? fincaTextControllerValidator;
  // State field(s) for Folio widget.
  FocusNode? folioFocusNode;
  TextEditingController? folioTextController;
  String? Function(BuildContext, String?)? folioTextControllerValidator;
  // State field(s) for Libro widget.
  FocusNode? libroFocusNode;
  TextEditingController? libroTextController;
  String? Function(BuildContext, String?)? libroTextControllerValidator;
  // State field(s) for NombrePropietario widget.
  FocusNode? nombrePropietarioFocusNode;
  TextEditingController? nombrePropietarioTextController;
  String? Function(BuildContext, String?)?
      nombrePropietarioTextControllerValidator;
  // State field(s) for NombreRepresentanteLegal widget.
  FocusNode? nombreRepresentanteLegalFocusNode;
  TextEditingController? nombreRepresentanteLegalTextController;
  String? Function(BuildContext, String?)?
      nombreRepresentanteLegalTextControllerValidator;
  bool isDataUploading_propertyOwnerId = false;
  FFUploadedFile uploadedLocalFile_propertyOwnerId =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;
  // Stores action output result for [Backend Call - API (Create Property Basic SALE)] action in PrimaryButton widget.
  ApiCallResponse? apiResultSale;
  // Stores action output result for [Backend Call - API (Create Property Basic RENT)] action in PrimaryButton widget.
  ApiCallResponse? apiResultRent;
  // Stores action output result for [Backend Call - API (Create Property Basic SALE and RENT)] action in PrimaryButton widget.
  ApiCallResponse? apiResultSaleAndRent;
  // Stores action output result for [Backend Call - API (Upload Property Certification)] action in PrimaryButton widget.
  ApiCallResponse? resCertificacionPropriedad;
  // Stores action output result for [Backend Call - API (Upload Property Owner ID Document)] action in PrimaryButton widget.
  ApiCallResponse? resOwnerId;
  // Model for DOVIA_CLIENT_Navbar component.
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
    descripcionPropiedadFocusNode?.dispose();
    descripcionPropiedadTextController?.dispose();

    precioVentaFocusNode?.dispose();
    precioVentaTextController?.dispose();

    cantidadARecibirFocusNode?.dispose();
    cantidadARecibirTextController?.dispose();

    mantenimientoFocusNode?.dispose();
    mantenimientoTextController?.dispose();

    impustoUnicoInmueblesFocusNode?.dispose();
    impustoUnicoInmueblesTextController?.dispose();

    precioRentaMensualFocusNode?.dispose();
    precioRentaMensualTextController?.dispose();

    comisionDovia1RentaFocusNode?.dispose();
    comisionDovia1RentaTextController?.dispose();

    tiempoMinimoFocusNode?.dispose();
    tiempoMinimoTextController?.dispose();

    rentaOtrosFocusNode?.dispose();
    rentaOtrosTextController?.dispose();

    disponibleDesdeFocusNode?.dispose();
    disponibleDesdeTextController?.dispose();

    usoPermitidoFocusNode?.dispose();
    usoPermitidoTextController?.dispose();

    usoNoPermitidoFocusNode?.dispose();
    usoNoPermitidoTextController?.dispose();

    direccionPropiedadFocusNode?.dispose();
    direccionPropiedadTextController?.dispose();

    drawMapComponentModel.dispose();
    fincaFocusNode?.dispose();
    fincaTextController?.dispose();

    folioFocusNode?.dispose();
    folioTextController?.dispose();

    libroFocusNode?.dispose();
    libroTextController?.dispose();

    nombrePropietarioFocusNode?.dispose();
    nombrePropietarioTextController?.dispose();

    nombreRepresentanteLegalFocusNode?.dispose();
    nombreRepresentanteLegalTextController?.dispose();

    primaryButtonModel.dispose();
    dOVIACLIENTNavbarModel.dispose();
  }
}
