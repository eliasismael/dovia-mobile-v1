import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/core/amount_input_formatter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/domain/client_offer_detail.dart' show unwrapPropertyJson;
import '/domain/offer_json.dart'
    show offerApiErrorMessage, offerAsMap, offerStr, propertyPathValue;
import '/domain/offer_credit_status.dart';
import '/domain/offer_form_validation.dart';
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_oferta_compra_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_oferta_compra_model.dart';

class DOVIACLIENTOfertaCompraWidget extends StatefulWidget {
  const DOVIACLIENTOfertaCompraWidget({
    super.key,
    required this.propertyId,
    this.offerType = 'compra',
    this.fromSelectionScreen = false,
    this.isAmbosFlow = false,
  });

  final String? propertyId;

  /// 'compra', 'renta', or 'ambos'
  final String offerType;
  final bool fromSelectionScreen;
  final bool isAmbosFlow;

  static String routeName = 'DOVIA_CLIENT_OfertaCompra';
  static String routePath = '/dOVIACLIENTOfertaCompra';

  @override
  State<DOVIACLIENTOfertaCompraWidget> createState() =>
      _DOVIACLIENTOfertaCompraWidgetState();
}

class _DOVIACLIENTOfertaCompraWidgetState
    extends State<DOVIACLIENTOfertaCompraWidget> {
  late DOVIACLIENTOfertaCompraModel _model;

  final _cashPaymentTimeController = FormFieldController<String>(null);
  late final Future<ApiCallResponse> _propertyRequest;

  /// En una oferta "ambos", la renta ya se creó en un intento anterior.
  bool _rentOfferSent = false;

  /// Cierra esta pantalla y, si se llegó desde la de selección, también esa.
  /// El router se toma antes del primer pop: después este `context` ya no
  /// está montado y el segundo pop no se podía hacer con él.
  void _closeOfferScreen() {
    final router = GoRouter.of(context);
    for (var i = 0; i < (widget.fromSelectionScreen ? 2 : 1); i++) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/');
        break;
      }
    }
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTOfertaCompraModel());

    // La propiedad se pide una sola vez: si el Future se creara dentro de
    // build, cada safeSetState (validar, elegir moneda, cambiar de metodo de
    // pago) dispararia otro GET y el formulario parpadearia al spinner.
    _propertyRequest = DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
      propertyId: widget.propertyId,
    );

    _model.precioTextController ??= TextEditingController();
    _model.precioFocusNode ??= FocusNode();

    _model.usoPermitidoTextController ??= TextEditingController();
    _model.usoPermitidoFocusNode ??= FocusNode();

    _model.usoNoPermitidoTextController ??= TextEditingController();
    _model.usoNoPermitidoFocusNode ??= FocusNode();

    _model.otrasConsideracionesTextController ??= TextEditingController();
    _model.otrasConsideracionesFocusNode ??= FocusNode();

    _model.propuestaEconomicaTextController ??= TextEditingController();
    _model.propuestaEconomicaFocusNode ??= FocusNode();

    _model.propuestaRentaTextController ??= TextEditingController();
    _model.propuestaRentaFocusNode ??= FocusNode();

    _model.cONTADOTiempoEstimadoDePagoTextController ??=
        TextEditingController();
    _model.cONTADOTiempoEstimadoDePagoFocusNode ??= FocusNode();

    _model.hIPOTECAEngancheTextController ??= TextEditingController();
    _model.hIPOTECAEngancheFocusNode ??= FocusNode();

    _model.hIPOTECABancoTextController ??= TextEditingController();
    _model.hIPOTECABancoFocusNode ??= FocusNode();

    _model.hIPOTECATiempoAprobacionBancoTextController ??=
        TextEditingController();
    _model.hIPOTECATiempoAprobacionBancoFocusNode ??= FocusNode();

    _model.pROMESAReservaInicialTextController ??= TextEditingController();
    _model.pROMESAReservaInicialFocusNode ??= FocusNode();

    _model.pROMESAPagoFinalTextController ??= TextEditingController();
    _model.pROMESAPagoFinalFocusNode ??= FocusNode();

    _model.pROMESATiempoPromesaTextController ??= TextEditingController();
    _model.pROMESATiempoPromesaFocusNode ??= FocusNode();

    _model.nombreCompradorTextController ??= TextEditingController();
    _model.nombreCompradorFocusNode ??= FocusNode();

    _model.razonSocialTextController ??= TextEditingController();
    _model.razonSocialFocusNode ??= FocusNode();

    _model.representanteLegalTextController ??= TextEditingController();
    _model.representanteLegalFocusNode ??= FocusNode();

    _model.consideracionesTextController ??= TextEditingController();
    _model.consideracionesFocusNode ??= FocusNode();

    _model.fechaInicioContratoTextController ??= TextEditingController();
    _model.fechaInicioContratoFocusNode ??= FocusNode();

    _model.fechaFinalizacionContratoTextController ??= TextEditingController();
    _model.fechaFinalizacionContratoFocusNode ??= FocusNode();

    _model.duracionContratoTextController ??= TextEditingController();
    _model.duracionContratoFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // -- Validacion del formulario ------------------------------------------
  //
  // El backend arma el cuerpo de la oferta por interpolacion de strings, asi
  // que un campo vacio viaja como null y la oferta se cae del lado del
  // servidor sin explicar por que. En vez de dejar que eso pase, cada campo
  // que la API necesita se valida aca: el asterisco rojo lo anuncia y
  // errorText pinta el borde rojo que las decoraciones ya definen.

  /// Mensaje de error vigente por campo. Vacio hasta el primer "Aceptar".
  final Map<String, String?> _fieldErrors = {};

  String _text(TextEditingController? controller) => controller?.text ?? '';

  /// Revalida el formulario segun el tipo de oferta y el metodo de pago.
  /// Devuelve true si se puede enviar.
  bool _validateForm() {
    final errors = validateOfferForm(
      OfferFormInput(
        offerType: widget.offerType,
        paymentMethod: _model.paymentMethod,
        purchaseAmount:
            _text(_model.propuestaEconomicaTextController).replaceAll(',', ''),
        rentAmount:
            _text(_model.propuestaRentaTextController).replaceAll(',', ''),
        cashPaymentTime:
            _text(_model.cONTADOTiempoEstimadoDePagoTextController),
        downPayment: _text(_model.hIPOTECAEngancheTextController),
        bankName: _text(_model.hIPOTECABancoTextController),
        bankApprovalTime:
            _text(_model.hIPOTECATiempoAprobacionBancoTextController),
        initialReserve: _text(_model.pROMESAReservaInicialTextController)
            .replaceAll(',', ''),
        promiseMonths: _text(_model.pROMESATiempoPromesaTextController),
        buyerName: _text(_model.nombreCompradorTextController),
        legalName: _text(_model.razonSocialTextController),
        legalRepresentative: _text(_model.representanteLegalTextController),
        contractStart: _text(_model.fechaInicioContratoTextController),
        contractEnd: _text(_model.fechaFinalizacionContratoTextController),
      ),
    );

    safeSetState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
    });

    return errors.isEmpty;
  }

  /// Avisa que el servidor rechazó la oferta, con el motivo en palabras.
  ///
  /// Antes salía un diálogo "error" con el JSON de la respuesta entero. Los
  /// rangos y los obligatorios ya se atajan en [_validateForm]; esto es la red
  /// de seguridad para lo que sólo el servidor puede saber.
  void _showOfferError(ApiCallResponse? response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(offerApiErrorMessage(response?.jsonBody))),
      );
  }

  /// Limpia el error de un campo apenas el usuario lo corrige, para que el
  /// borde rojo no sobreviva a la correccion.
  void _clearFieldError(String key) {
    if (_fieldErrors.containsKey(key)) {
      safeSetState(() => _fieldErrors.remove(key));
    }
  }

  /// Etiqueta con el asterisco rojo de campo obligatorio.
  Widget _requiredLabel(String text, {TextStyle? style}) {
    final base = style ?? FlutterFlowTheme.of(context).bodyMedium;
    return Text.rich(
      TextSpan(
        text: text,
        style: base,
        children: [
          TextSpan(
            text: ' *',
            style: base.copyWith(
              color: FlutterFlowTheme.of(context).error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Igual que [_requiredLabel] pero el asterisco aparece solo cuando el campo
  /// pasa a ser obligatorio: el representante legal lo es recien cuando se
  /// declara una razon social.
  Widget _maybeRequiredLabel(
    String text, {
    required bool required,
    TextStyle? style,
  }) =>
      required ? _requiredLabel(text, style: style) : Text(text, style: style);

  // -- Caracteristicas que proporciono el propietario ---------------------

  /// Vuelca en los campos de solo lectura lo que publico el propietario.
  ///
  /// GET /properties/{id} responde {data: {...}} pero los getters generados
  /// leen $.data.data.*, asi que hasta ahora estos campos salian vacios.
  /// unwrapPropertyJson acepta las dos formas y propertyPathValue prueba los
  /// alias que el backend usa para cada dato.
  void _syncOwnerFields(ApiCallResponse response) {
    final property = unwrapPropertyJson(offerAsMap(response.jsonBody));
    if (property == null) return;

    final precio = widget.offerType == 'renta'
        ? propertyPathValue(property, const ['rentInfo.monthlyRent', 'price'])
        : propertyPathValue(property, const ['saleInfo.salePrice', 'price']);

    _setReadOnlyText(
        _model.precioTextController, formatAmountText(offerStr(precio) ?? ''));
    _setReadOnlyText(
      _model.usoNoPermitidoTextController,
      offerStr(propertyPathValue(property, const [
        'rentInfo.rentalConditions.notAllowedUses',
        'rentInfo.rentalConditions.prohibitedUses',
        'conditions.notAllowedUses',
        'infoHQ.notAllowedUses',
      ])),
    );
    _setReadOnlyText(
      _model.otrasConsideracionesTextController,
      offerStr(propertyPathValue(property, const [
        'infoHQ.showingConsiderations',
        'rentInfo.rentalConditions.otherConsiderations',
        'rentInfo.rentalConditions.others',
      ])),
    );
  }

  void _setReadOnlyText(TextEditingController? controller, String? value) {
    if (controller == null) return;
    final text = value ?? '';
    if (controller.text != text) controller.text = text;
  }

  /// "Duracion del contrato" se anuncia como un calculo en base a las fechas,
  /// pero se dejaba a mano y no viaja en la peticion: se deriva de las fechas
  /// elegidas para que muestre lo que dice mostrar.
  void _syncContractDuration() {
    final inicio =
        DateTime.tryParse(_model.fechaInicioContratoTextController?.text ?? '');
    final fin = DateTime.tryParse(
        _model.fechaFinalizacionContratoTextController?.text ?? '');
    if (inicio == null || fin == null || !fin.isAfter(inicio)) {
      _model.duracionContratoTextController?.text = '';
      return;
    }
    var meses = (fin.year - inicio.year) * 12 + (fin.month - inicio.month);
    if (fin.day < inicio.day) meses -= 1;
    _model.duracionContratoTextController?.text =
        meses <= 0 ? '' : '$meses ${meses == 1 ? 'mes' : 'meses'}';
  }

  /// Monto mensual propuesto para una renta.
  ///
  /// Lo piden tanto la oferta de renta como la combinada, asi que se arma una
  /// sola vez en vez de duplicar el campo en cada rama del arbol.
  Widget _rentAmountField() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _requiredLabel(
              'Precio mensual propuesto (renta)',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _model.propuestaRentaTextController,
              focusNode: _model.propuestaRentaFocusNode,
              autofocus: false,
              obscureText: false,
              onChanged: (_) => _clearFieldError('propuestaRenta'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                AmountInputFormatter(),
              ],
              decoration: InputDecoration(
                prefixText: '${currencySymbol(_model.selectedCurrency)} ',
                errorText: _fieldErrors['propuestaRenta'],
                isDense: true,
                hintText: 'Ej. 1500.00',
                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Color(0x00000000)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Color(0x00000000)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).tertiary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 14.0,
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiCallResponse>(
      future: _propertyRequest,
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: const Center(
              child: DoviaSpinner(),
            ),
          );
        }
        final dOVIACLIENTOfertaCompraGetPropertyByIDResponse = snapshot.data!;
        _syncOwnerFields(dOVIACLIENTOfertaCompraGetPropertyByIDResponse);

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Stack(
                children: [
                  wrapWithModel(
                    model: _model.cornerGradientBackgroundModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const CornerGradientBackgroundWidget(),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        wrapWithModel(
                          model: _model.dOVIASHAREDHeaderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: DOVIASHAREDHeaderWidget(
                            showLogo: openedFromHome(context),
                            showSupport: false,
                            title: widget.offerType == 'renta'
                                ? 'Oferta de renta'
                                : widget.offerType == 'ambos'
                                    ? 'Oferta de compra y renta'
                                    : 'Oferta de compra',
                            hideActions: true,
                          ),
                        ),
                        Padding(
                          // Sin navbar: solo un margen corto bajo Aceptar.
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Text(
                                          'Características que proporcionó el propietario',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.offerType == 'renta'
                                                    ? 'Precio mensual'
                                                    : 'Precio',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                child: TextFormField(
                                                  controller: _model
                                                      .precioTextController,
                                                  focusNode:
                                                      _model.precioFocusNode,
                                                  autofocus: false,
                                                  enabled: true,
                                                  readOnly: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .precioTextControllerValidator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Uso no permitido de esta propiedad',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                child: TextFormField(
                                                  controller: _model
                                                      .usoNoPermitidoTextController,
                                                  focusNode: _model
                                                      .usoNoPermitidoFocusNode,
                                                  autofocus: false,
                                                  enabled: true,
                                                  readOnly: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .usoNoPermitidoTextControllerValidator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Otras consideraciones',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                child: TextFormField(
                                                  controller: _model
                                                      .otrasConsideracionesTextController,
                                                  focusNode: _model
                                                      .otrasConsideracionesFocusNode,
                                                  autofocus: false,
                                                  enabled: true,
                                                  readOnly: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .otrasConsideracionesTextControllerValidator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: 1.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: Text(
                                            'Tu propuesta',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: Text(
                                            'Moneda de pago',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: 100.0,
                                                decoration:
                                                    const BoxDecoration(),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    _model.selectedCurrency =
                                                        'USD';
                                                    safeSetState(() {});
                                                  },
                                                  text: 'USD',
                                                  options: FFButtonOptions(
                                                    height: 40.0,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                            16.0, 0.0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                    color:
                                                        _model.selectedCurrency ==
                                                                'USD'
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primary
                                                            : const Color(
                                                                0x00FFFFFF),
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .publicSans(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                              color: _model
                                                                          .selectedCurrency ==
                                                                      'USD'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                            ),
                                                    elevation: 0.0,
                                                    borderSide: BorderSide(
                                                      color: _model
                                                                  .selectedCurrency ==
                                                              'USD'
                                                          ? const Color(
                                                              0x00000000)
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: 100.0,
                                                decoration:
                                                    const BoxDecoration(),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    _model.selectedCurrency =
                                                        'QUETZALES';
                                                    safeSetState(() {});
                                                  },
                                                  text: 'Quetzales',
                                                  options: FFButtonOptions(
                                                    height: 40.0,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                            16.0, 0.0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                    color:
                                                        _model.selectedCurrency ==
                                                                'QUETZALES'
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primary
                                                            : const Color(
                                                                0x00FFFFFF),
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .publicSans(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                              color: _model
                                                                          .selectedCurrency ==
                                                                      'QUETZALES'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                            ),
                                                    elevation: 0.0,
                                                    borderSide: BorderSide(
                                                      color: _model
                                                                  .selectedCurrency ==
                                                              'QUETZALES'
                                                          ? const Color(
                                                              0x00000000)
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ].divide(const SizedBox(width: 10.0)),
                                        ),
                                      ),
                                      if (widget.offerType == 'renta')
                                        _rentAmountField(),
                                      if (widget.offerType != 'renta') ...[
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: Text(
                                              'Método de pago',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: FlutterFlowDropDown<String>(
                                            controller: _model
                                                    .dropDownValueController ??=
                                                FormFieldController<String>(
                                              _model.dropDownValue ??=
                                                  _model.paymentMethod,
                                            ),
                                            options: const [
                                              'Contado',
                                              'Hipoteca',
                                              'Promesa de compra'
                                            ],
                                            onChanged: (val) async {
                                              safeSetState(() =>
                                                  _model.dropDownValue = val);
                                              _model.paymentMethod =
                                                  _model.dropDownValue!;
                                              safeSetState(() {});
                                            },
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            height: 40.0,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              size: 24.0,
                                            ),
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            elevation: 2.0,
                                            borderColor: Colors.transparent,
                                            borderWidth: 0.0,
                                            borderRadius: 8.0,
                                            margin: const EdgeInsetsDirectional
                                                .fromSTEB(12.0, 0.0, 12.0, 0.0),
                                            hidesUnderline: true,
                                            isOverButton: false,
                                            isSearchable: false,
                                            isMultiSelect: false,
                                          ),
                                        ),
                                        if (widget.offerType == 'ambos') ...[
                                          _rentAmountField(),
                                        ],
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            decoration: const BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _requiredLabel(
                                                  widget.offerType == 'ambos'
                                                      ? 'Precio propuesto (compra)'
                                                      : 'Propuesta económica',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          1.0,
                                                  child: TextFormField(
                                                    controller: _model
                                                        .propuestaEconomicaTextController,
                                                    focusNode: _model
                                                        .propuestaEconomicaFocusNode,
                                                    autofocus: false,
                                                    onChanged: (_) =>
                                                        _clearFieldError(
                                                            'propuestaEconomica'),
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
                                                    // Separadores de miles y
                                                    // hasta 2 decimales.
                                                    inputFormatters: [
                                                      AmountInputFormatter()
                                                    ],
                                                    enabled: true,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      prefixText:
                                                          '${currencySymbol(_model.selectedCurrency)} ',
                                                      errorText: _fieldErrors[
                                                          'propuestaEconomica'],
                                                      isDense: true,
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .tertiary,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    enableInteractiveSelection:
                                                        true,
                                                    validator: _model
                                                        .propuestaEconomicaTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ),
                                              ].divide(
                                                  const SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                          child: Builder(
                                            builder: (context) {
                                              if (_model.paymentMethod ==
                                                  'Contado') {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 20.0, 0.0, 0.0),
                                                  child: Container(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        1.0,
                                                    decoration:
                                                        const BoxDecoration(),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _requiredLabel(
                                                          'Tiempo estimado de pago tras aceptación de la oferta',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                        FlutterFlowDropDown<
                                                            String>(
                                                          controller:
                                                              _cashPaymentTimeController,
                                                          options:
                                                              kCashPaymentTimeOptions
                                                                  .keys
                                                                  .toList(),
                                                          onChanged: (val) =>
                                                              safeSetState(() {
                                                            _model.cONTADOTiempoEstimadoDePagoTextController!
                                                                    .text =
                                                                '${kCashPaymentTimeOptions[val] ?? ''}';
                                                            _clearFieldError(
                                                                'contadoTiempoPago');
                                                          }),
                                                          width:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .width *
                                                                  1.0,
                                                          height: 48.0,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium,
                                                          hintText:
                                                              'Selecciona el tiempo',
                                                          icon: Icon(
                                                            Icons
                                                                .keyboard_arrow_down_rounded,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            size: 24.0,
                                                          ),
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .tertiary,
                                                          elevation: 0.0,
                                                          borderColor: _fieldErrors[
                                                                      'contadoTiempoPago'] !=
                                                                  null
                                                              ? FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .error
                                                              : Colors
                                                                  .transparent,
                                                          borderWidth: 1.0,
                                                          borderRadius: 10.0,
                                                          margin:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  12.0,
                                                                  4.0,
                                                                  12.0,
                                                                  4.0),
                                                          hidesUnderline: true,
                                                          isOverButton: false,
                                                          isSearchable: false,
                                                          isMultiSelect: false,
                                                        ),
                                                        if (_fieldErrors[
                                                                'contadoTiempoPago'] !=
                                                            null)
                                                          Text(
                                                            _fieldErrors[
                                                                'contadoTiempoPago']!,
                                                            style: TextStyle(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .error,
                                                              fontSize: 12.0,
                                                            ),
                                                          ),
                                                      ].divide(const SizedBox(
                                                          height: 12.0)),
                                                    ),
                                                  ),
                                                );
                                              } else if (_model.paymentMethod ==
                                                  'Hipoteca') {
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          const AlignmentDirectional(
                                                              -1.0, 0.0),
                                                      child: Text(
                                                        'Estructura hipotecaria',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              20.0, 0.0, 0.0),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _requiredLabel(
                                                              'Enganche',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  1.0,
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .hIPOTECAEngancheTextController,
                                                                focusNode: _model
                                                                    .hIPOTECAEngancheFocusNode,
                                                                autofocus:
                                                                    false,
                                                                keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            false),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                onChanged: (_) =>
                                                                    _clearFieldError(
                                                                        'enganche'),
                                                                enabled: true,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  errorText:
                                                                      _fieldErrors[
                                                                          'enganche'],
                                                                  isDense: true,
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  hintText:
                                                                      'x%',
                                                                  hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                cursorColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .hIPOTECAEngancheTextControllerValidator
                                                                    .asValidator(
                                                                        context),
                                                              ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  height:
                                                                      12.0)),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              20.0, 0.0, 0.0),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _requiredLabel(
                                                              'Banco a utilizar',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  1.0,
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .hIPOTECABancoTextController,
                                                                focusNode: _model
                                                                    .hIPOTECABancoFocusNode,
                                                                autofocus:
                                                                    false,
                                                                onChanged: (_) =>
                                                                    _clearFieldError(
                                                                        'banco'),
                                                                enabled: true,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  errorText:
                                                                      _fieldErrors[
                                                                          'banco'],
                                                                  isDense: true,
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                cursorColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .hIPOTECABancoTextControllerValidator
                                                                    .asValidator(
                                                                        context),
                                                              ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  height:
                                                                      12.0)),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              20.0, 0.0, 0.0),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Estado de crédito',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            FlutterFlowDropDown<
                                                                String>(
                                                              controller: _model
                                                                      .hIPOTECAEstadoCreditoValueController ??=
                                                                  FormFieldController<
                                                                      String>(
                                                                _model
                                                                    .hIPOTECAEstadoCreditoValue,
                                                              ),
                                                              options:
                                                                  creditStatusLabels,
                                                              onChanged: (val) =>
                                                                  safeSetState(() =>
                                                                      _model.hIPOTECAEstadoCreditoValue =
                                                                          val),
                                                              width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  1.0,
                                                              height: 48.0,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium,
                                                              hintText:
                                                                  'Selecciona el estado',
                                                              icon: Icon(
                                                                Icons
                                                                    .keyboard_arrow_down_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                size: 24.0,
                                                              ),
                                                              fillColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .alternate,
                                                              elevation: 0.0,
                                                              borderColor: Colors
                                                                  .transparent,
                                                              borderWidth: 1.0,
                                                              borderRadius:
                                                                  10.0,
                                                              margin:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      12.0,
                                                                      4.0,
                                                                      12.0,
                                                                      4.0),
                                                              hidesUnderline:
                                                                  true,
                                                              isOverButton:
                                                                  false,
                                                              isSearchable:
                                                                  false,
                                                              isMultiSelect:
                                                                  false,
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  height:
                                                                      12.0)),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              20.0, 0.0, 0.0),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _requiredLabel(
                                                              'Tiempo estimado para aprobación del banco',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  1.0,
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .hIPOTECATiempoAprobacionBancoTextController,
                                                                focusNode: _model
                                                                    .hIPOTECATiempoAprobacionBancoFocusNode,
                                                                autofocus:
                                                                    false,
                                                                keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            false),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                onChanged: (_) =>
                                                                    _clearFieldError(
                                                                        'tiempoAprobacion'),
                                                                enabled: true,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  errorText:
                                                                      _fieldErrors[
                                                                          'tiempoAprobacion'],
                                                                  isDense: true,
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                cursorColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .hIPOTECATiempoAprobacionBancoTextControllerValidator
                                                                    .asValidator(
                                                                        context),
                                                              ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  height:
                                                                      12.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else if (_model.paymentMethod ==
                                                  'Promesa de compra') {
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          const AlignmentDirectional(
                                                              -1.0, 0.0),
                                                      child: Text(
                                                        'Estructura de pago',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              20.0, 0.0, 0.0),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _requiredLabel(
                                                              'Reserva inicial',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  1.0,
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .pROMESAReservaInicialTextController,
                                                                focusNode: _model
                                                                    .pROMESAReservaInicialFocusNode,
                                                                autofocus:
                                                                    false,
                                                                keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                                inputFormatters: [
                                                                  AmountInputFormatter()
                                                                ],
                                                                onChanged: (_) =>
                                                                    _clearFieldError(
                                                                        'reservaInicial'),
                                                                enabled: true,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  prefixText:
                                                                      '${currencySymbol(_model.selectedCurrency)} ',
                                                                  errorText:
                                                                      _fieldErrors[
                                                                          'reservaInicial'],
                                                                  isDense: true,
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                cursorColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .pROMESAReservaInicialTextControllerValidator
                                                                    .asValidator(
                                                                        context),
                                                              ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  height:
                                                                      12.0)),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              20.0, 0.0, 0.0),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Pago final',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  1.0,
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .pROMESAPagoFinalTextController,
                                                                focusNode: _model
                                                                    .pROMESAPagoFinalFocusNode,
                                                                autofocus:
                                                                    false,
                                                                keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'^\d*\.?\d{0,2}'))
                                                                ],
                                                                enabled: true,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  isDense: true,
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                cursorColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .pROMESAPagoFinalTextControllerValidator
                                                                    .asValidator(
                                                                        context),
                                                              ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  height:
                                                                      12.0)),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              20.0, 0.0, 0.0),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .width *
                                                                1.0,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _requiredLabel(
                                                              'Tiempo de promesa (en meses)',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width *
                                                                  1.0,
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .pROMESATiempoPromesaTextController,
                                                                focusNode: _model
                                                                    .pROMESATiempoPromesaFocusNode,
                                                                autofocus:
                                                                    false,
                                                                keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            false),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .digitsOnly
                                                                ],
                                                                onChanged: (_) =>
                                                                    _clearFieldError(
                                                                        'tiempoPromesa'),
                                                                enabled: true,
                                                                obscureText:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  errorText:
                                                                      _fieldErrors[
                                                                          'tiempoPromesa'],
                                                                  isDense: true,
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                cursorColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                enableInteractiveSelection:
                                                                    true,
                                                                validator: _model
                                                                    .pROMESATiempoPromesaTextControllerValidator
                                                                    .asValidator(
                                                                        context),
                                                              ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  height:
                                                                      12.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Container(
                                                  width: 0.0,
                                                  height: 0.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: Text(
                                              '¿Quién será el comprador?',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ], // end purchase-only sections
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _requiredLabel(
                                                widget.offerType == 'renta'
                                                    ? 'Nombre del arrendatario'
                                                    : 'Nombre del comprador',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                child: TextFormField(
                                                  controller: _model
                                                      .nombreCompradorTextController,
                                                  focusNode: _model
                                                      .nombreCompradorFocusNode,
                                                  autofocus: false,
                                                  onChanged: (_) =>
                                                      _clearFieldError(
                                                          'nombreComprador'),
                                                  enabled: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    errorText: _fieldErrors[
                                                        'nombreComprador'],
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .nombreCompradorTextControllerValidator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: Text(
                                            'Si es empresa',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Razón social',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                child: TextFormField(
                                                  controller: _model
                                                      .razonSocialTextController,
                                                  focusNode: _model
                                                      .razonSocialFocusNode,
                                                  autofocus: false,
                                                  onChanged: (_) {
                                                    _clearFieldError(
                                                        'representanteLegal');
                                                    safeSetState(() {});
                                                  },
                                                  enabled: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .razonSocialTextControllerValidator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _maybeRequiredLabel(
                                                'Representante legal',
                                                required:
                                                    (_model.razonSocialTextController
                                                                ?.text ??
                                                            '')
                                                        .trim()
                                                        .isNotEmpty,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                child: TextFormField(
                                                  controller: _model
                                                      .representanteLegalTextController,
                                                  focusNode: _model
                                                      .representanteLegalFocusNode,
                                                  autofocus: false,
                                                  onChanged: (_) =>
                                                      _clearFieldError(
                                                          'representanteLegal'),
                                                  enabled: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    errorText: _fieldErrors[
                                                        'representanteLegal'],
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .representanteLegalTextControllerValidator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Consideraciones o solicitudes',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                child: TextFormField(
                                                  controller: _model
                                                      .consideracionesTextController,
                                                  focusNode: _model
                                                      .consideracionesFocusNode,
                                                  autofocus: false,
                                                  enabled: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .consideracionesTextControllerValidator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      if (widget.offerType == 'renta' ||
                                          widget.offerType == 'ambos') ...[
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            decoration: const BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Expanded(
                                                      child: _requiredLabel(
                                                        'Fecha de inicio de contrato',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: _requiredLabel(
                                                        'Fecha de finalización',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12.0),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: _model
                                                            .fechaInicioContratoTextController,
                                                        focusNode: _model
                                                            .fechaInicioContratoFocusNode,
                                                        autofocus: false,
                                                        obscureText: false,
                                                        readOnly: true,
                                                        onTap: () async {
                                                          final selectedDate =
                                                              await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                DateTime.now(),
                                                            firstDate:
                                                                DateTime.now(),
                                                            lastDate:
                                                                DateTime(2050),
                                                            builder: (context,
                                                                child) {
                                                              return Theme(
                                                                data: Theme.of(
                                                                        context)
                                                                    .copyWith(
                                                                  colorScheme:
                                                                      ColorScheme
                                                                          .light(
                                                                    primary: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                                child: child!,
                                                              );
                                                            },
                                                          );
                                                          if (selectedDate !=
                                                              null) {
                                                            final yyyy =
                                                                selectedDate
                                                                    .year
                                                                    .toString();
                                                            final mm =
                                                                selectedDate
                                                                    .month
                                                                    .toString()
                                                                    .padLeft(
                                                                        2, '0');
                                                            final dd =
                                                                selectedDate.day
                                                                    .toString()
                                                                    .padLeft(
                                                                        2, '0');
                                                            safeSetState(() {
                                                              _clearFieldError(
                                                                  'fechaInicio');
                                                              _model.fechaInicioContratoTextController
                                                                      ?.text =
                                                                  '$yyyy-$mm-$dd';
                                                              _syncContractDuration();
                                                            });
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          errorText:
                                                              _fieldErrors[
                                                                  'fechaInicio'],
                                                          hintText:
                                                              'Ej. 2024-01-01',
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Color(
                                                                          0x00000000))),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Color(
                                                                          0x00000000))),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide: BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 1.0),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide: BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 1.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .tertiary,
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: _model
                                                            .fechaFinalizacionContratoTextController,
                                                        focusNode: _model
                                                            .fechaFinalizacionContratoFocusNode,
                                                        autofocus: false,
                                                        obscureText: false,
                                                        readOnly: true,
                                                        onTap: () async {
                                                          final initiald =
                                                              DateTime.now();
                                                          final selectedDate =
                                                              await showDatePicker(
                                                            context: context,
                                                            initialDate: DateTime(
                                                                initiald.year +
                                                                    1,
                                                                initiald.month,
                                                                initiald.day),
                                                            firstDate:
                                                                DateTime.now(),
                                                            lastDate:
                                                                DateTime(2050),
                                                            builder: (context,
                                                                child) {
                                                              return Theme(
                                                                data: Theme.of(
                                                                        context)
                                                                    .copyWith(
                                                                  colorScheme:
                                                                      ColorScheme
                                                                          .light(
                                                                    primary: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                                child: child!,
                                                              );
                                                            },
                                                          );
                                                          if (selectedDate !=
                                                              null) {
                                                            final yyyy =
                                                                selectedDate
                                                                    .year
                                                                    .toString();
                                                            final mm =
                                                                selectedDate
                                                                    .month
                                                                    .toString()
                                                                    .padLeft(
                                                                        2, '0');
                                                            final dd =
                                                                selectedDate.day
                                                                    .toString()
                                                                    .padLeft(
                                                                        2, '0');
                                                            safeSetState(() {
                                                              _clearFieldError(
                                                                  'fechaFin');
                                                              _model.fechaFinalizacionContratoTextController
                                                                      ?.text =
                                                                  '$yyyy-$mm-$dd';
                                                              _syncContractDuration();
                                                            });
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          errorText:
                                                              _fieldErrors[
                                                                  'fechaFin'],
                                                          hintText:
                                                              'Ej. 2025-01-01',
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Color(
                                                                          0x00000000))),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Color(
                                                                          0x00000000))),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide: BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 1.0),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide: BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 1.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .tertiary,
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20.0),
                                                Text(
                                                  'Duración del contrato',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                ),
                                                const SizedBox(height: 12.0),
                                                TextFormField(
                                                  controller: _model
                                                      .duracionContratoTextController,
                                                  focusNode: _model
                                                      .duracionContratoFocusNode,
                                                  autofocus: false,
                                                  readOnly: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Cálculo en base a fechas (Ej. 12 meses)',
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Color(
                                                                    0x00000000))),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Color(
                                                                    0x00000000))),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                ),
                                                const SizedBox(height: 20.0),
                                                Text(
                                                  '¿Qué uso le darás a la propiedad?',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                ),
                                                const SizedBox(height: 12.0),
                                                FlutterFlowDropDown<String>(
                                                  controller: _model
                                                          .usoADarPropertyUseValueController ??=
                                                      FormFieldController<
                                                          String>(
                                                    _model.usoADarPropertyUseValue ??=
                                                        'Vivienda personal',
                                                  ),
                                                  options: const [
                                                    'Vivienda personal',
                                                    'Oficina comercial',
                                                    'Oficina',
                                                    'Local comercial',
                                                    'Bodega',
                                                    'Commercial Office Space',
                                                    'Otro'
                                                  ],
                                                  onChanged: (val) =>
                                                      safeSetState(() => _model
                                                              .usoADarPropertyUseValue =
                                                          val),
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          1.0,
                                                  height: 56.0,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium,
                                                  hintText: 'Vivienda personal',
                                                  icon: Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 24.0,
                                                  ),
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .tertiary,
                                                  elevation: 0.0,
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderWidth: 1.0,
                                                  borderRadius: 10.0,
                                                  margin:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          16.0, 4.0, 16.0, 4.0),
                                                  hidesUnderline: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.zero,
                                            child: Text(
                                              'Entiendo que en este complejo NO se permite:\n• Airbnb\n• Subarrendamiento\n• Eventos\n• Mascotas (si aplica)',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.publicSans(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                    lineHeight: 1.3,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Text(
                                          'Al enviar tu propuesta, el propietario podrá aceptarla, rechazarla o solicitar cambios.',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                      Builder(
                                        builder: (context) => Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                          child: wrapWithModel(
                                            model: _model.primaryButtonModel,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: PrimaryButtonWidget(
                                              text: 'Aceptar',
                                              onTap: () async {
                                                // Ningun envio sale sin los
                                                // campos que la API pide: los
                                                // que falten quedan con borde
                                                // rojo y el foco vuelve al
                                                // formulario.
                                                if (!_validateForm()) {
                                                  ScaffoldMessenger.of(context)
                                                    ..hideCurrentSnackBar()
                                                    ..showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Revisa los campos marcados en rojo antes de enviar tu oferta.'),
                                                      ),
                                                    );
                                                  return;
                                                }

                                                var shouldSetState = false;

                                                // Handle BOTH (ambos) offer type: submit rent + purchase
                                                if (widget.offerType ==
                                                    'ambos') {
                                                  // 1. Submit RENT offer. Si ya salió en un intento
                                                  // anterior (falló solo la compra), no se reenvía:
                                                  // reintentar creaba otra oferta de renta.
                                                  if (!_rentOfferSent) {
                                                  final rentResult =
                                                      await DOVIAAPIOfferContextGroup
                                                          .createOfferRENTIndividualCall
                                                          .call(
                                                    propertyId:
                                                        widget.propertyId,
                                                    authToken:
                                                        currentAuthenticationToken,
                                                    contractStartDate: _model
                                                                    .fechaInicioContratoTextController
                                                                    ?.text !=
                                                                null &&
                                                            _model
                                                                .fechaInicioContratoTextController!
                                                                .text
                                                                .isNotEmpty
                                                        ? '${_model.fechaInicioContratoTextController!.text}T00:00:00.000Z'
                                                        : '',
                                                    contractEndDate: _model
                                                                    .fechaFinalizacionContratoTextController
                                                                    ?.text !=
                                                                null &&
                                                            _model
                                                                .fechaFinalizacionContratoTextController!
                                                                .text
                                                                .isNotEmpty
                                                        ? '${_model.fechaFinalizacionContratoTextController!.text}T00:00:00.000Z'
                                                        : '',
                                                    currency:
                                                        _model.selectedCurrency,
                                                    proposedAmount: parseAmount(
                                                        _model.propuestaRentaTextController
                                                                ?.text ??
                                                            ''),
                                                    propertyUse: _model
                                                        .usoADarPropertyUseValue,
                                                    considerations: _model
                                                        .consideracionesTextController
                                                        ?.text,
                                                    tenantType:
                                                        (_model.razonSocialTextController
                                                                        ?.text ??
                                                                    '')
                                                                .isNotEmpty
                                                            ? 'company'
                                                            : 'individual',
                                                    tenantName: _model
                                                        .nombreCompradorTextController
                                                        ?.text,
                                                    tenantLegalName: _model
                                                        .razonSocialTextController
                                                        ?.text,
                                                    tenantRepresentative: _model
                                                        .representanteLegalTextController
                                                        ?.text,
                                                  );
                                                  if (!mounted) return;
                                                  if (!rentResult.succeeded) {
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              offerApiErrorMessage(
                                                        rentResult.jsonBody,
                                                        fallback:
                                                            'Error al enviar la oferta de renta. Inténtalo de nuevo.',
                                                      ))),
                                                    );
                                                    return;
                                                  }
                                                  _rentOfferSent = true;
                                                  }

                                                  // 2. Submit PURCHASE offer
                                                  ApiCallResponse?
                                                      purchaseResult;
                                                  if (_model.paymentMethod ==
                                                      'Contado') {
                                                    purchaseResult =
                                                        await DOVIAAPIOfferContextGroup
                                                            .createOfferPURCHASECashCall
                                                            .call(
                                                      propertyId:
                                                          widget.propertyId,
                                                      authToken:
                                                          currentAuthenticationToken,
                                                      estimatedPaymentTime:
                                                          int.tryParse(_model
                                                              .cONTADOTiempoEstimadoDePagoTextController
                                                              .text),
                                                      currency: _model
                                                          .selectedCurrency,
                                                      proposedAmount:
                                                          parseAmount(_model
                                                              .propuestaEconomicaTextController
                                                              ?.text),
                                                      considerations: _model
                                                          .consideracionesTextController
                                                          .text,
                                                      buyerType:
                                                          _model.razonSocialTextController
                                                                      .text !=
                                                                  ''
                                                              ? 'company'
                                                              : 'individual',
                                                      buyerName: _model
                                                          .nombreCompradorTextController
                                                          .text,
                                                      buyerLegalName: _model
                                                                  .razonSocialTextController
                                                                  .text !=
                                                              ''
                                                          ? _model
                                                              .razonSocialTextController
                                                              .text
                                                          : '',
                                                      buyerRepresentative: _model
                                                                  .razonSocialTextController
                                                                  .text !=
                                                              ''
                                                          ? _model
                                                              .representanteLegalTextController
                                                              .text
                                                          : '',
                                                    );
                                                  } else if (_model
                                                          .paymentMethod ==
                                                      'Hipoteca') {
                                                    purchaseResult =
                                                        await DOVIAAPIOfferContextGroup
                                                            .createOfferPURCHASEMortgageCall
                                                            .call(
                                                      propertyId:
                                                          widget.propertyId,
                                                      authToken:
                                                          currentAuthenticationToken,
                                                      currency: _model
                                                          .selectedCurrency,
                                                      proposedAmount:
                                                          parseAmount(_model
                                                              .propuestaEconomicaTextController
                                                              ?.text),
                                                      considerations: _model
                                                          .consideracionesTextController
                                                          .text,
                                                      buyerType:
                                                          _model.razonSocialTextController
                                                                      .text !=
                                                                  ''
                                                              ? 'company'
                                                              : 'individual',
                                                      buyerName: _model
                                                          .nombreCompradorTextController
                                                          .text,
                                                      downPaymentPercentage:
                                                          int.tryParse(_model
                                                              .hIPOTECAEngancheTextController
                                                              .text),
                                                      bankName: _model
                                                          .hIPOTECABancoTextController
                                                          .text,
                                                      creditStatus:
                                                          creditStatusValueFromLabel(
                                                              _model
                                                                  .hIPOTECAEstadoCreditoValue),
                                                      estimatedApprovalTime:
                                                          int.tryParse(_model
                                                              .hIPOTECATiempoAprobacionBancoTextController
                                                              .text),
                                                      legalName: _model
                                                          .razonSocialTextController
                                                          .text,
                                                      legalRepresentative: _model
                                                          .representanteLegalTextController
                                                          .text,
                                                    );
                                                  } else {
                                                    purchaseResult =
                                                        await DOVIAAPIOfferContextGroup
                                                            .createOfferPURCHASEPurchasePromiseCall
                                                            .call(
                                                      propertyId:
                                                          widget.propertyId,
                                                      authToken:
                                                          currentAuthenticationToken,
                                                      currency: _model
                                                          .selectedCurrency,
                                                      proposedAmount:
                                                          parseAmount(_model
                                                              .propuestaEconomicaTextController
                                                              ?.text),
                                                      considerations: _model
                                                          .consideracionesTextController
                                                          .text,
                                                      buyerType:
                                                          _model.razonSocialTextController
                                                                      .text !=
                                                                  ''
                                                              ? 'company'
                                                              : 'individual',
                                                      buyerName: _model
                                                          .nombreCompradorTextController
                                                          .text,
                                                      buyerLegalName: _model
                                                          .razonSocialTextController
                                                          .text,
                                                      buyerLegalRepresentative:
                                                          _model
                                                              .representanteLegalTextController
                                                              .text,
                                                      initialReserve:
                                                          parseAmount(_model
                                                              .pROMESAReservaInicialTextController
                                                              .text),
                                                      promiseTimeMonths:
                                                          int.tryParse(_model
                                                              .pROMESATiempoPromesaTextController
                                                              .text),
                                                    );
                                                  }

                                                  if (!mounted) return;
                                                  if (!purchaseResult
                                                      .succeeded) {
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          duration: Duration(
                                                              seconds: 6),
                                                          content: Text(
                                                              'Tu oferta de renta ya se envió, pero la de compra no. Toca Aceptar para reintentar solo la compra (la renta no se vuelve a enviar).')),
                                                    );
                                                    return;
                                                  }

                                                  // 3. Show success modal
                                                  if (!context.mounted) return;
                                                  showGeneralDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    barrierLabel:
                                                        MaterialLocalizations
                                                                .of(context)
                                                            .modalBarrierDismissLabel,
                                                    barrierColor:
                                                        Colors.black54,
                                                    transitionDuration:
                                                        Duration.zero,
                                                    pageBuilder:
                                                        (dialogContext, _, __) {
                                                      Future.delayed(
                                                        const Duration(
                                                            seconds: 2),
                                                        () {
                                                          if (dialogContext
                                                              .mounted) {
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop();
                                                          }
                                                        },
                                                      );
                                                      return const Center(
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child:
                                                              PopupExitoWidget(
                                                            title:
                                                                'Se envió la oferta correctamente',
                                                            text:
                                                                'Tu solicitud de oferta ha sido enviada con éxito. Puedes ir a visualizar y hacer seguimiento de esta oferta a Mis visitas',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 2100));

                                                  // 4. Pop past Ofertar screen to property profile if needed
                                                  if (mounted) {
                                                    if (!context.mounted) return;
                                                    context
                                                        .safePop(); // pop OfertaCompra
                                                    if (widget
                                                        .fromSelectionScreen) {
                                                      if (!context.mounted) return;
                                                      context
                                                          .safePop(); // pop Ofertar selection screen
                                                    }
                                                  }
                                                  return;
                                                }

                                                // Handle RENT offer type
                                                if (widget.offerType ==
                                                    'renta') {
                                                  final rentResult =
                                                      await DOVIAAPIOfferContextGroup
                                                          .createOfferRENTIndividualCall
                                                          .call(
                                                    propertyId:
                                                        widget.propertyId,
                                                    authToken:
                                                        currentAuthenticationToken,
                                                    contractStartDate: _model
                                                                    .fechaInicioContratoTextController
                                                                    ?.text !=
                                                                null &&
                                                            _model
                                                                .fechaInicioContratoTextController!
                                                                .text
                                                                .isNotEmpty
                                                        ? '${_model.fechaInicioContratoTextController!.text}T00:00:00.000Z'
                                                        : '',
                                                    contractEndDate: _model
                                                                    .fechaFinalizacionContratoTextController
                                                                    ?.text !=
                                                                null &&
                                                            _model
                                                                .fechaFinalizacionContratoTextController!
                                                                .text
                                                                .isNotEmpty
                                                        ? '${_model.fechaFinalizacionContratoTextController!.text}T00:00:00.000Z'
                                                        : '',
                                                    currency:
                                                        _model.selectedCurrency,
                                                    proposedAmount: parseAmount(
                                                        _model.propuestaRentaTextController
                                                                ?.text ??
                                                            ''),
                                                    propertyUse: _model
                                                        .usoADarPropertyUseValue,
                                                    considerations: _model
                                                        .consideracionesTextController
                                                        ?.text,
                                                    tenantType:
                                                        _model.razonSocialTextController
                                                                        ?.text !=
                                                                    null &&
                                                                _model
                                                                    .razonSocialTextController!
                                                                    .text
                                                                    .isNotEmpty
                                                            ? 'company'
                                                            : 'individual',
                                                    tenantName: _model
                                                        .nombreCompradorTextController
                                                        ?.text,
                                                    tenantLegalName: _model
                                                        .razonSocialTextController
                                                        ?.text,
                                                    tenantRepresentative: _model
                                                        .representanteLegalTextController
                                                        ?.text,
                                                  );

                                                  if (!mounted) return;

                                                  if (!(rentResult.succeeded)) {
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            offerApiErrorMessage(
                                                          rentResult.jsonBody,
                                                          fallback:
                                                              'Error al enviar la oferta de renta. Inténtalo de nuevo.',
                                                        )),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  // Show success modal
                                                  if (!context.mounted) return;
                                                  showGeneralDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    barrierLabel:
                                                        MaterialLocalizations
                                                                .of(context)
                                                            .modalBarrierDismissLabel,
                                                    barrierColor:
                                                        Colors.black54,
                                                    transitionDuration:
                                                        Duration.zero,
                                                    pageBuilder:
                                                        (dialogContext, _, __) {
                                                      Future.delayed(
                                                        const Duration(
                                                            seconds: 2),
                                                        () {
                                                          if (dialogContext
                                                              .mounted) {
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop();
                                                          }
                                                        },
                                                      );
                                                      return const Center(
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child:
                                                              PopupExitoWidget(
                                                            title:
                                                                'Se envió la oferta correctamente',
                                                            text:
                                                                'Tu solicitud de oferta ha sido enviada con éxito. Puedes ir a visualizar y hacer seguimiento de esta oferta a Mis visitas',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 2100));

                                                  if (mounted) {
                                                    _closeOfferScreen();
                                                  }
                                                  return;
                                                }

                                                // Handle PURCHASE offer types
                                                if (_model.paymentMethod ==
                                                    'Contado') {
                                                  _model.ofertaContado =
                                                      await DOVIAAPIOfferContextGroup
                                                          .createOfferPURCHASECashCall
                                                          .call(
                                                    propertyId:
                                                        widget.propertyId,
                                                    authToken:
                                                        currentAuthenticationToken,
                                                    estimatedPaymentTime:
                                                        int.tryParse(_model
                                                            .cONTADOTiempoEstimadoDePagoTextController
                                                            .text),
                                                    currency:
                                                        _model.selectedCurrency,
                                                    proposedAmount: parseAmount(
                                                        _model
                                                            .propuestaEconomicaTextController
                                                            ?.text),
                                                    considerations: _model
                                                        .consideracionesTextController
                                                        .text,
                                                    buyerType:
                                                        _model.razonSocialTextController
                                                                    .text !=
                                                                ''
                                                            ? 'company'
                                                            : 'individual',
                                                    buyerName: _model
                                                        .nombreCompradorTextController
                                                        .text,
                                                    buyerLegalName: _model
                                                                .razonSocialTextController
                                                                .text !=
                                                            ''
                                                        ? _model
                                                            .razonSocialTextController
                                                            .text
                                                        : '',
                                                    buyerRepresentative: _model
                                                                .razonSocialTextController
                                                                .text !=
                                                            ''
                                                        ? _model
                                                            .representanteLegalTextController
                                                            .text
                                                        : '',
                                                  );

                                                  shouldSetState = true;
                                                  if (!(_model.ofertaContado
                                                          ?.succeeded ??
                                                      true)) {
                                                    _showOfferError(
                                                        _model.ofertaContado);
                                                    if (shouldSetState) {
                                                      safeSetState(() {});
                                                    }
                                                    return;
                                                  }
                                                } else {
                                                  if (_model.paymentMethod ==
                                                      'Hipoteca') {
                                                    _model.ofertaHipoteca =
                                                        await DOVIAAPIOfferContextGroup
                                                            .createOfferPURCHASEMortgageCall
                                                            .call(
                                                      propertyId:
                                                          widget.propertyId,
                                                      authToken:
                                                          currentAuthenticationToken,
                                                      currency: _model
                                                          .selectedCurrency,
                                                      proposedAmount:
                                                          parseAmount(_model
                                                              .propuestaEconomicaTextController
                                                              ?.text),
                                                      considerations: _model
                                                          .consideracionesTextController
                                                          .text,
                                                      buyerType:
                                                          _model.razonSocialTextController
                                                                      .text !=
                                                                  ''
                                                              ? 'company'
                                                              : 'individual',
                                                      buyerName: _model
                                                          .nombreCompradorTextController
                                                          .text,
                                                      downPaymentPercentage:
                                                          int.tryParse(_model
                                                              .hIPOTECAEngancheTextController
                                                              .text),
                                                      bankName: _model
                                                          .hIPOTECABancoTextController
                                                          .text,
                                                      creditStatus:
                                                          creditStatusValueFromLabel(
                                                              _model
                                                                  .hIPOTECAEstadoCreditoValue),
                                                      estimatedApprovalTime:
                                                          int.tryParse(_model
                                                              .hIPOTECATiempoAprobacionBancoTextController
                                                              .text),
                                                      legalName: _model
                                                                  .razonSocialTextController
                                                                  .text !=
                                                              ''
                                                          ? _model
                                                              .razonSocialTextController
                                                              .text
                                                          : '',
                                                      legalRepresentative: _model
                                                                  .razonSocialTextController
                                                                  .text !=
                                                              ''
                                                          ? _model
                                                              .representanteLegalTextController
                                                              .text
                                                          : '',
                                                    );

                                                    shouldSetState = true;
                                                    if (!(_model.ofertaHipoteca
                                                            ?.succeeded ??
                                                        true)) {
                                                      _showOfferError(_model
                                                          .ofertaHipoteca);
                                                      if (shouldSetState) {
                                                        safeSetState(() {});
                                                      }
                                                      return;
                                                    }
                                                  } else {
                                                    if (_model.paymentMethod ==
                                                        'Promesa de compra') {
                                                      _model.ofertaPromesa =
                                                          await DOVIAAPIOfferContextGroup
                                                              .createOfferPURCHASEPurchasePromiseCall
                                                              .call(
                                                        authToken:
                                                            currentAuthenticationToken,
                                                        propertyId:
                                                            widget.propertyId,
                                                        currency: _model
                                                            .selectedCurrency,
                                                        proposedAmount:
                                                            parseAmount(_model
                                                                .propuestaEconomicaTextController
                                                                ?.text),
                                                        considerations: _model
                                                            .consideracionesTextController
                                                            .text,
                                                        buyerType:
                                                            _model.razonSocialTextController
                                                                        .text !=
                                                                    ''
                                                                ? 'company'
                                                                : 'individual',
                                                        buyerName: _model
                                                            .nombreCompradorTextController
                                                            .text,
                                                        buyerLegalName: _model
                                                                    .razonSocialTextController
                                                                    .text !=
                                                                ''
                                                            ? _model
                                                                .razonSocialTextController
                                                                .text
                                                            : '',
                                                        buyerLegalRepresentative:
                                                            _model.razonSocialTextController
                                                                        .text !=
                                                                    ''
                                                                ? _model
                                                                    .representanteLegalTextController
                                                                    .text
                                                                : '',
                                                        initialReserve:
                                                            parseAmount(_model
                                                                .pROMESAReservaInicialTextController
                                                                .text),
                                                        promiseTimeMonths:
                                                            int.tryParse(_model
                                                                .pROMESATiempoPromesaTextController
                                                                .text),
                                                      );

                                                      shouldSetState = true;
                                                      if (!(_model.ofertaPromesa
                                                              ?.succeeded ??
                                                          true)) {
                                                        _showOfferError(_model
                                                            .ofertaPromesa);
                                                        if (shouldSetState) {
                                                          safeSetState(() {});
                                                        }
                                                        return;
                                                      }
                                                    } else {
                                                      if (shouldSetState) {
                                                        safeSetState(() {});
                                                      }
                                                      return;
                                                    }
                                                  }
                                                }

                                                if (!context.mounted) return;
                                                showGeneralDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  barrierLabel:
                                                      MaterialLocalizations.of(
                                                              context)
                                                          .modalBarrierDismissLabel,
                                                  barrierColor: Colors.black54,
                                                  transitionDuration:
                                                      Duration.zero,
                                                  pageBuilder:
                                                      (dialogContext, _, __) {
                                                    Future.delayed(
                                                      const Duration(
                                                          seconds: 2),
                                                      () {
                                                        if (dialogContext
                                                            .mounted) {
                                                          Navigator.of(
                                                                  dialogContext)
                                                              .pop();
                                                        }
                                                      },
                                                    );
                                                    return Center(
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: PopupExitoWidget(
                                                          title: widget
                                                                  .isAmbosFlow
                                                              ? 'Oferta de compra enviada'
                                                              : 'Se envió la oferta correctamente',
                                                          text: widget
                                                                  .isAmbosFlow
                                                              ? 'Tu propuesta de compra ha sido enviada. A continuación, serás redirigido al formulario para tu propuesta de renta.'
                                                              : 'Tu solicitud de oferta ha sido enviada con éxito. Puedes ir a visualizar y hacer seguimiento de esta oferta a Mis visitas',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 2100));

                                                // Navigate back to the property profile or transition to Rent
                                                if (mounted) {
                                                  if (widget.isAmbosFlow) {
                                                    if (!context.mounted) return;
                                                    context
                                                        .pushReplacementNamed(
                                                      DOVIACLIENTOfertaCompraWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'propertyId':
                                                            serializeParam(
                                                                widget
                                                                    .propertyId,
                                                                ParamType
                                                                    .String),
                                                        'offerType':
                                                            serializeParam(
                                                                'renta',
                                                                ParamType
                                                                    .String),
                                                        'fromSelectionScreen':
                                                            serializeParam(
                                                                widget
                                                                    .fromSelectionScreen,
                                                                ParamType.bool),
                                                        'isAmbosFlow':
                                                            serializeParam(
                                                                false,
                                                                ParamType.bool),
                                                      }.withoutNulls,
                                                    );
                                                  } else {
                                                    if (!mounted) return;
                                                    _closeOfferScreen();
                                                  }
                                                }

                                                if (shouldSetState) {
                                                  safeSetState(() {});
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
