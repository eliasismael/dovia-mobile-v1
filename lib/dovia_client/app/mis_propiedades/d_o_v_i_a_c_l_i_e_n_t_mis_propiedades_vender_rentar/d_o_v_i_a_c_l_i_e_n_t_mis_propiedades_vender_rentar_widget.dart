import '/core/dovia_zones.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/core/amount_input_formatter.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_model.dart';

class DOVIACLIENTMisPropiedadesVenderRentarWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesVenderRentarWidget({
    super.key,
    required this.title,
    required this.transactionType,
  });

  final String? title;
  final PropertyPublicationType? transactionType;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_VenderRentar';
  static String routePath = '/dOVIACLIENTMisPropiedadesVenderRentar';

  @override
  State<DOVIACLIENTMisPropiedadesVenderRentarWidget> createState() =>
      _DOVIACLIENTMisPropiedadesVenderRentarWidgetState();
}

class _DOVIACLIENTMisPropiedadesVenderRentarWidgetState
    extends State<DOVIACLIENTMisPropiedadesVenderRentarWidget>
    with WidgetsBindingObserver {
  late DOVIACLIENTMisPropiedadesVenderRentarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Punto que el propietario marca en el mapa. Es la única fuente de las
  /// coordenadas de la propiedad. Al escribir la dirección se geocodifica y el
  /// pin se ubica solo, pero el propietario puede corregirlo tocando el mapa.
  double? _selectedLatitude;
  double? _selectedLongitude;

  /// Último resultado de geocodificar la dirección; se le pasa al mapa para
  /// que mueva el pin.
  double? _geocodedLatitude;
  double? _geocodedLongitude;
  String _lastGeocodedQuery = '';
  bool _keyboardWasOpen = false;

  /// Se busca la dirección al salir del input.
  void _onAddressFocusChanged() {
    if (!(_model.direccionPropiedadFocusNode?.hasFocus ?? true)) {
      _geocodeAddress();
    }
  }

  /// En el celular, cerrar el teclado no le quita el foco al input: se
  /// detecta aca y se busca igual.
  @override
  void didChangeMetrics() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return;
    final keyboardOpen = views.first.viewInsets.bottom > 0;
    if (_keyboardWasOpen &&
        !keyboardOpen &&
        (_model.direccionPropiedadFocusNode?.hasFocus ?? false)) {
      _geocodeAddress();
    }
    _keyboardWasOpen = keyboardOpen;
  }

  /// Busca la dirección escrita (dentro de la zona elegida) con Mapbox y
  /// ubica el pin en el resultado.
  Future<void> _geocodeAddress() async {
    final address =
        (_model.direccionPropiedadTextController?.text ?? '').trim();
    if (address.length < 4) return;
    final zone = _model.zonaValue;
    final query = [
      address,
      if (zone != null && zone.isNotEmpty) zone,
      'Guatemala',
    ].join(', ');
    if (query == _lastGeocodedQuery) return;
    _lastGeocodedQuery = query;

    // Con zona elegida, solo se aceptan resultados dentro de ella.
    final zoneFilter = mapboxZoneFilter(zone);
    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${Uri.encodeComponent(query)}.json'
        '?access_token=${FFAppConstants.MapboxAccessToken}'
        '&country=gt&limit=5&language=es$zoneFilter',
      );
      final response = await http.get(url);
      if (response.statusCode != 200 || !mounted) return;
      // Si el usuario siguió escribiendo, este resultado ya es viejo.
      if (query != _lastGeocodedQuery) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      if (features.isEmpty) return;
      final match = bestAddressMatch(features, address);
      // Mapbox devuelve [longitud, latitud].
      final coords = match['center'] as List<dynamic>;
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      safeSetState(() {
        _geocodedLatitude = lat;
        _geocodedLongitude = lng;
        _selectedLatitude = lat;
        _selectedLongitude = lng;
      });
      _clearFieldError('ubicacion');
    } catch (_) {
      // Sin resultado el propietario marca el punto a mano.
    }
  }

  String _apiErrorMessage(dynamic response, String fallback) {
    if (response is Map) {
      final message = response['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = response['errors'];
      if (errors is List) {
        for (final error in errors) {
          if (error is Map) {
            final message = error['message']?.toString().trim();
            if (message != null && message.isNotEmpty) {
              return message;
            }
          }
        }
      }
    }

    return fallback;
  }

  /// Revisa el formulario antes de llamar al backend y devuelve un problema
  /// por linea.
  ///
  /// Los precios viajan parseados: entero para venta, mantenimiento, impuesto
  /// y tiempo minimo, decimal para la renta mensual. Un texto que no parsea
  /// llega como `null` y la propiedad se crearia sin ese dato, sin aviso.
  ///
  /// Los errores quedan en [_fieldErrors] (campo -> mensaje) y cada campo los
  /// muestra debajo, con el borde en rojo. Se cargan en el orden en que los
  /// campos aparecen en pantalla, así el primero es el más alto.
  Map<String, String> _collectValidationErrors() {
    final errors = <String, String>{};
    final transactionType = widget.transactionType?.name ?? '';
    const requiredMsg = 'Completá este campo.';

    void requireText(String field, TextEditingController? controller) {
      if ((controller?.text.trim() ?? '').isEmpty) {
        errors[field] = requiredMsg;
      }
    }

    void checkNumber(
      String field,
      TextEditingController? controller, {
      required bool isRequired,
      bool decimal = false,
    }) {
      // Los montos llegan con separadores de miles.
      final raw = controller?.text.replaceAll(',', '').trim() ?? '';
      if (raw.isEmpty) {
        if (isRequired) errors[field] = requiredMsg;
        return;
      }

      final num? value = decimal ? double.tryParse(raw) : int.tryParse(raw);
      if (value == null) {
        errors[field] = decimal
            ? 'Ingresá un número, podés usar decimales.'
            : 'Ingresá un número entero, sin letras ni símbolos.';
        return;
      }
      if (value < 0) {
        errors[field] = 'No puede ser un número negativo.';
      }
    }

    requireText(
        'descripcionPropiedad', _model.descripcionPropiedadTextController);

    if (transactionType.contains('SALE')) {
      checkNumber('precioVenta', _model.precioVentaTextController,
          isRequired: true);
      checkNumber('cantidadARecibir', _model.cantidadARecibirTextController,
          isRequired: false, decimal: true);
      checkNumber('mantenimiento', _model.mantenimientoTextController,
          isRequired: false);
      checkNumber(
          'impustoUnicoInmuebles', _model.impustoUnicoInmueblesTextController,
          isRequired: false);
    }

    if (transactionType.contains('RENT')) {
      checkNumber('precioRentaMensual', _model.precioRentaMensualTextController,
          isRequired: true, decimal: true);
      checkNumber('tiempoMinimo', _model.tiempoMinimoTextController,
          isRequired: false);
    }

    if (_model.zonaValue == null || _model.zonaValue == '') {
      errors['zona'] = 'Seleccioná una zona.';
    }

    requireText('direccionPropiedad', _model.direccionPropiedadTextController);

    // Sin punto en el mapa la propiedad quedaría sin coordenadas y el
    // operative lister no podría llegar.
    if (_selectedLatitude == null || _selectedLongitude == null) {
      errors['ubicacion'] = 'Marcá el punto en el mapa.';
    }

    // Datos del Registro de la Propiedad.
    requireText('finca', _model.fincaTextController);
    requireText('folio', _model.folioTextController);
    requireText('libro', _model.libroTextController);

    requireText('nombrePropietario', _model.nombrePropietarioTextController);
    if (_isCompany) {
      requireText('nombreRepresentanteLegal',
          _model.nombreRepresentanteLegalTextController);
    }

    return errors;
  }

  /// A nombre de quién está la propiedad. Con "Sociedad" el representante
  /// legal pasa a ser obligatorio.
  String _ownerType = 'Propietario';
  bool get _isCompany => _ownerType == 'Sociedad';
  final _ownerTypeController = FormFieldController<String>('Propietario');

  /// Comisión DOVIA sobre la venta. El IVA todavía no se descuenta.
  static const double _doviaCommission = 0.035;

  /// Llena "Cantidad a recibir" con el precio de venta menos la comisión.
  void _updateAmountToReceive() {
    final target = _model.cantidadARecibirTextController;
    if (target == null) return;
    final price = parseAmount(_model.precioVentaTextController?.text);
    final text = price == null
        ? ''
        : formatAmountText((price * (1 - _doviaCommission)).toStringAsFixed(2));
    if (target.text != text) target.text = text;
  }

  /// Error visible de cada campo tras tocar "Aceptar".
  Map<String, String> _fieldErrors = {};
  final Map<String, GlobalKey> _fieldKeys = {};
  GlobalKey _fieldKey(String field) =>
      _fieldKeys.putIfAbsent(field, () => GlobalKey());

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      safeSetState(() => _fieldErrors = {..._fieldErrors}..remove(field));
    }
  }

  /// Marca los campos con error y lleva el scroll al primero.
  void _showFieldErrors(Map<String, String> errors) {
    safeSetState(() => _fieldErrors = errors);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _fieldKeys[errors.keys.first]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.3,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Texto de error bajo los campos que no son TextFormField (zona, mapa).
  Widget _fieldErrorText(String field) {
    final error = _fieldErrors[field];
    return Padding(
      key: _fieldKey(field),
      padding: EdgeInsetsDirectional.fromSTEB(
          12.0, error == null ? 0.0 : 6.0, 0.0, 0.0),
      child: error == null
          ? const SizedBox.shrink()
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                error,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).error,
                  fontSize: 12.0,
                ),
              ),
            ),
    );
  }

  /// Vista previa del archivo elegido.
  ///
  /// Sin archivo muestra el mismo placeholder de siempre. Con una imagen
  /// muestra la miniatura y con un documento el nombre, porque un PDF no se
  /// puede previsualizar acá. En los dos casos sigue envuelto en el InkWell
  /// que abre el selector, así que se puede reemplazar tocándolo.
  Widget _uploadPreview(FFUploadedFile file) {
    final width = MediaQuery.sizeOf(context).width * 1.0;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      return SvgPicture.asset(
        'assets/images/AddMediaImage.svg',
        width: width,
        height: 150.0,
        fit: BoxFit.cover,
      );
    }

    final filename = file.originalFilename.trim().isNotEmpty
        ? file.originalFilename.trim()
        : (file.name ?? '').trim();
    final isImage =
        RegExp(r'\.(png|jpe?g|gif|webp|bmp|heic|heif)$', caseSensitive: false)
            .hasMatch(filename);

    if (isImage) {
      return Image.memory(
        bytes,
        width: width,
        height: 150.0,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: width,
      height: 150.0,
      color: FlutterFlowTheme.of(context).secondaryBackground,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 44.0,
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 10.0),
          Text(
            filename.isEmpty ? 'Documento cargado' : filename,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  fontSize: 13.0,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPublicationError(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('No se pudo publicar la propiedad'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesVenderRentarModel());

    _model.descripcionPropiedadTextController ??= TextEditingController();
    _model.descripcionPropiedadFocusNode ??= FocusNode();

    _model.precioVentaTextController ??= TextEditingController();
    _model.precioVentaFocusNode ??= FocusNode();

    _model.cantidadARecibirTextController ??= TextEditingController();
    _model.cantidadARecibirFocusNode ??= FocusNode();
    _model.precioVentaTextController!.addListener(_updateAmountToReceive);

    _model.mantenimientoTextController ??= TextEditingController();
    _model.mantenimientoFocusNode ??= FocusNode();

    _model.impustoUnicoInmueblesTextController ??= TextEditingController();
    _model.impustoUnicoInmueblesFocusNode ??= FocusNode();

    _model.precioRentaMensualTextController ??= TextEditingController();
    _model.precioRentaMensualFocusNode ??= FocusNode();

    _model.comisionDovia1RentaTextController ??= TextEditingController();
    _model.comisionDovia1RentaFocusNode ??= FocusNode();

    _model.tiempoMinimoTextController ??= TextEditingController();
    _model.disponibleDesdeTextController ??= TextEditingController();
    _model.disponibleDesdeFocusNode ??= FocusNode();
    _model.usoPermitidoTextController ??= TextEditingController();
    _model.usoPermitidoFocusNode ??= FocusNode();
    _model.usoNoPermitidoTextController ??= TextEditingController();
    _model.usoNoPermitidoFocusNode ??= FocusNode();
    _model.tiempoMinimoFocusNode ??= FocusNode();

    _model.rentaOtrosTextController ??= TextEditingController();
    _model.rentaOtrosFocusNode ??= FocusNode();

    _model.direccionPropiedadTextController ??= TextEditingController();
    _model.direccionPropiedadFocusNode ??= FocusNode();

    _model.direccionPropiedadFocusNode!.addListener(_onAddressFocusChanged);
    WidgetsBinding.instance.addObserver(this);

    _model.fincaTextController ??= TextEditingController();
    _model.fincaFocusNode ??= FocusNode();

    _model.folioTextController ??= TextEditingController();
    _model.folioFocusNode ??= FocusNode();

    _model.libroTextController ??= TextEditingController();
    _model.libroFocusNode ??= FocusNode();

    // Al corregir un campo se le saca el error.
    for (final entry in {
      'descripcionPropiedad': _model.descripcionPropiedadTextController,
      'precioVenta': _model.precioVentaTextController,
      'cantidadARecibir': _model.cantidadARecibirTextController,
      'mantenimiento': _model.mantenimientoTextController,
      'impustoUnicoInmuebles': _model.impustoUnicoInmueblesTextController,
      'precioRentaMensual': _model.precioRentaMensualTextController,
      'tiempoMinimo': _model.tiempoMinimoTextController,
      'direccionPropiedad': _model.direccionPropiedadTextController,
      'finca': _model.fincaTextController,
      'folio': _model.folioTextController,
      'libro': _model.libroTextController,
    }.entries) {
      entry.value?.addListener(() => _clearFieldError(entry.key));
    }

    _model.nombrePropietarioTextController ??= TextEditingController();
    _model.nombrePropietarioFocusNode ??= FocusNode();

    _model.nombreRepresentanteLegalTextController ??= TextEditingController();
    _model.nombreRepresentanteLegalFocusNode ??= FocusNode();

    _model.nombrePropietarioTextController!
        .addListener(() => _clearFieldError('nombrePropietario'));
    _model.nombreRepresentanteLegalTextController!
        .addListener(() => _clearFieldError('nombreRepresentanteLegal'));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.direccionPropiedadFocusNode?.removeListener(_onAddressFocusChanged);
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        title: widget.title!,
                        showCurrency: false,
                        showMap: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 16.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Con esta información preparamos y validamos tu propiedad para comercializarla en DOVIA.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: Text.rich(
                                TextSpan(
                                    text:
                                        'Describe de manera natural tu propiedad y el complejo ',
                                    children: [
                                      TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error))
                                    ]),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                key: _fieldKey('descripcionPropiedad'),
                                controller:
                                    _model.descripcionPropiedadTextController,
                                focusNode: _model.descripcionPropiedadFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  errorText:
                                      _fieldErrors['descripcionPropiedad'],
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText:
                                      'Casa en Zona 14 con jardín, 3 habitaciones y vista a los volcanes.',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 40.0, 0.0, 40.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model
                                    .descripcionPropiedadTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              if ((String transactionType) {
                                return transactionType.contains("SALE");
                              }(widget.transactionType!.name)) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 0.0),
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    decoration: const BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Text.rich(
                                            TextSpan(
                                                text: 'Precio de venta ',
                                                children: [
                                                  TextSpan(
                                                      text: '*',
                                                      style: TextStyle(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error))
                                                ]),
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
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                key: _fieldKey('precioVenta'),
                                                controller: _model
                                                    .precioVentaTextController,
                                                focusNode:
                                                    _model.precioVentaFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  AmountInputFormatter(
                                                      decimalDigits: 0),
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  prefixText:
                                                      '${currencySymbol()} ',
                                                  errorText: _fieldErrors[
                                                      'precioVenta'],
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                  hintText: '1,500,000',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .precioVentaTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: Text(
                                              'Cantidad a recibir (3.5% + IVA)',
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
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                key: _fieldKey(
                                                    'cantidadARecibir'),
                                                controller: _model
                                                    .cantidadARecibirTextController,
                                                focusNode: _model
                                                    .cantidadARecibirFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                // Se calcula solo a partir del
                                                // precio de venta.
                                                readOnly: true,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  AmountInputFormatter(),
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  prefixText:
                                                      '${currencySymbol()} ',
                                                  errorText: _fieldErrors[
                                                      'cantidadARecibir'],
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                  hintText:
                                                      'Se calcula con el precio de venta',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .cantidadARecibirTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: Text(
                                              'Mantenimiento',
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
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                key: _fieldKey('mantenimiento'),
                                                controller: _model
                                                    .mantenimientoTextController,
                                                focusNode: _model
                                                    .mantenimientoFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  AmountInputFormatter(
                                                      decimalDigits: 0),
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  prefixText:
                                                      '${currencySymbol()} ',
                                                  errorText: _fieldErrors[
                                                      'mantenimiento'],
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                  hintText: '1,200',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .mantenimientoTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: Text(
                                              'Impuesto único sobre inmuebles',
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
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                key: _fieldKey(
                                                    'impustoUnicoInmuebles'),
                                                controller: _model
                                                    .impustoUnicoInmueblesTextController,
                                                focusNode: _model
                                                    .impustoUnicoInmueblesFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  AmountInputFormatter(
                                                      decimalDigits: 0),
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  prefixText:
                                                      '${currencySymbol()} ',
                                                  errorText: _fieldErrors[
                                                      'impustoUnicoInmuebles'],
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                        font: GoogleFonts.inter(
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .impustoUnicoInmueblesTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  width: 0.0,
                                  height: 0.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                );
                              }
                            },
                          ),
                          Builder(
                            builder: (context) {
                              if ((String txType) {
                                return txType.contains("RENT");
                              }(widget.transactionType!.name)) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 0.0),
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    decoration: const BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Text.rich(
                                            TextSpan(
                                                text:
                                                    'Precio de renta mensual (incluyendo IVA y mantenimiento) ',
                                                children: [
                                                  TextSpan(
                                                      text: '*',
                                                      style: TextStyle(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error))
                                                ]),
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
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                key: _fieldKey(
                                                    'precioRentaMensual'),
                                                controller: _model
                                                    .precioRentaMensualTextController,
                                                focusNode: _model
                                                    .precioRentaMensualFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  AmountInputFormatter(),
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  prefixText:
                                                      '${currencySymbol()} ',
                                                  errorText: _fieldErrors[
                                                      'precioRentaMensual'],
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                  hintText: '0.00',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .precioRentaMensualTextControllerValidator
                                                    .asValidator(context),
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
                                              'En renta nuestra comisión es equivalente a un mes de renta.',
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
                                        // Align(
                                        //   alignment:
                                        //       AlignmentDirectional(-1.0, 0.0),
                                        //   child: Padding(
                                        //     padding:
                                        //         EdgeInsetsDirectional.fromSTEB(
                                        //             0.0, 10.0, 0.0, 0.0),
                                        //     child: Container(
                                        //       width: MediaQuery.sizeOf(context)
                                        //               .width *
                                        //           1.0,
                                        //       child: TextFormField(
                                        //         controller: _model
                                        //             .comisionDovia1RentaTextController,
                                        //         focusNode: _model
                                        //             .comisionDovia1RentaFocusNode,
                                        //         autofocus: false,
                                        //         enabled: true,
                                        //         obscureText: false,
                                        //         decoration: InputDecoration(
                                        //           isDense: true,
                                        //           labelStyle: FlutterFlowTheme
                                        //                   .of(context)
                                        //               .labelMedium
                                        //               .override(
                                        //                 font: GoogleFonts.inter(
                                        //                   fontWeight:
                                        //                       FlutterFlowTheme.of(
                                        //                               context)
                                        //                           .labelMedium
                                        //                           .fontWeight,
                                        //                   fontStyle:
                                        //                       FlutterFlowTheme.of(
                                        //                               context)
                                        //                           .labelMedium
                                        //                           .fontStyle,
                                        //                 ),
                                        //                 letterSpacing: 0.0,
                                        //                 fontWeight:
                                        //                     FlutterFlowTheme.of(
                                        //                             context)
                                        //                         .labelMedium
                                        //                         .fontWeight,
                                        //                 fontStyle:
                                        //                     FlutterFlowTheme.of(
                                        //                             context)
                                        //                         .labelMedium
                                        //                         .fontStyle,
                                        //               ),
                                        //           hintText: '\$',
                                        //           hintStyle: FlutterFlowTheme
                                        //                   .of(context)
                                        //               .labelMedium
                                        //               .override(
                                        //                 font: GoogleFonts.inter(
                                        //                   fontWeight:
                                        //                       FlutterFlowTheme.of(
                                        //                               context)
                                        //                           .labelMedium
                                        //                           .fontWeight,
                                        //                   fontStyle:
                                        //                       FlutterFlowTheme.of(
                                        //                               context)
                                        //                           .labelMedium
                                        //                           .fontStyle,
                                        //                 ),
                                        //                 letterSpacing: 0.0,
                                        //                 fontWeight:
                                        //                     FlutterFlowTheme.of(
                                        //                             context)
                                        //                         .labelMedium
                                        //                         .fontWeight,
                                        //                 fontStyle:
                                        //                     FlutterFlowTheme.of(
                                        //                             context)
                                        //                         .labelMedium
                                        //                         .fontStyle,
                                        //               ),
                                        //           enabledBorder:
                                        //               OutlineInputBorder(
                                        //             borderSide: BorderSide(
                                        //               color: Color(0x00000000),
                                        //               width: 1.0,
                                        //             ),
                                        //             borderRadius:
                                        //                 BorderRadius.circular(
                                        //                     8.0),
                                        //           ),
                                        //           focusedBorder:
                                        //               OutlineInputBorder(
                                        //             borderSide: BorderSide(
                                        //               color: Color(0x00000000),
                                        //               width: 1.0,
                                        //             ),
                                        //             borderRadius:
                                        //                 BorderRadius.circular(
                                        //                     8.0),
                                        //           ),
                                        //           errorBorder:
                                        //               OutlineInputBorder(
                                        //             borderSide: BorderSide(
                                        //               color:
                                        //                   FlutterFlowTheme.of(
                                        //                           context)
                                        //                       .error,
                                        //               width: 1.0,
                                        //             ),
                                        //             borderRadius:
                                        //                 BorderRadius.circular(
                                        //                     8.0),
                                        //           ),
                                        //           focusedErrorBorder:
                                        //               OutlineInputBorder(
                                        //             borderSide: BorderSide(
                                        //               color:
                                        //                   FlutterFlowTheme.of(
                                        //                           context)
                                        //                       .error,
                                        //               width: 1.0,
                                        //             ),
                                        //             borderRadius:
                                        //                 BorderRadius.circular(
                                        //                     8.0),
                                        //           ),
                                        //           filled: true,
                                        //           fillColor:
                                        //               FlutterFlowTheme.of(
                                        //                       context)
                                        //                   .secondaryBackground,
                                        //         ),
                                        //         style:
                                        //             FlutterFlowTheme.of(context)
                                        //                 .bodyMedium
                                        //                 .override(
                                        //                   font:
                                        //                       GoogleFonts.inter(
                                        //                     fontWeight:
                                        //                         FlutterFlowTheme.of(
                                        //                                 context)
                                        //                             .bodyMedium
                                        //                             .fontWeight,
                                        //                     fontStyle:
                                        //                         FlutterFlowTheme.of(
                                        //                                 context)
                                        //                             .bodyMedium
                                        //                             .fontStyle,
                                        //                   ),
                                        //                   letterSpacing: 0.0,
                                        //                   fontWeight:
                                        //                       FlutterFlowTheme.of(
                                        //                               context)
                                        //                           .bodyMedium
                                        //                           .fontWeight,
                                        //                   fontStyle:
                                        //                       FlutterFlowTheme.of(
                                        //                               context)
                                        //                           .bodyMedium
                                        //                           .fontStyle,
                                        //                 ),
                                        //         keyboardType:
                                        //             const TextInputType
                                        //                 .numberWithOptions(
                                        //                 decimal: true),
                                        //         cursorColor:
                                        //             FlutterFlowTheme.of(context)
                                        //                 .primaryText,
                                        //         enableInteractiveSelection:
                                        //             true,
                                        //         validator: _model
                                        //             .comisionDovia1RentaTextControllerValidator
                                        //             .asValidator(context),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 28.0, 0.0, 4.0),
                                            child: Text(
                                              'Condiciones de renta',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                            ),
                                          ),
                                        ),
                                        // Align(
                                        //   alignment:
                                        //       AlignmentDirectional(-1.0, 0.0),
                                        //   child: Padding(
                                        //     padding:
                                        //         EdgeInsetsDirectional.fromSTEB(
                                        //             0.0, 10.0, 0.0, 0.0),
                                        //     child: Text(
                                        //       'Disponible desde',
                                        //       style: FlutterFlowTheme.of(
                                        //               context)
                                        //           .bodyMedium
                                        //           .override(
                                        //               font: GoogleFonts.inter(),
                                        //               letterSpacing: 0.0),
                                        //     ),
                                        //   ),
                                        // ),
                                        // Align(
                                        //   alignment:
                                        //       AlignmentDirectional(-1.0, 0.0),
                                        //   child: Padding(
                                        //     padding:
                                        //         EdgeInsetsDirectional.fromSTEB(
                                        //             0.0, 10.0, 0.0, 0.0),
                                        //     child: Container(
                                        //       width: MediaQuery.sizeOf(context)
                                        //               .width *
                                        //           1.0,
                                        //       child: TextFormField(
                                        //         controller: _model
                                        //             .disponibleDesdeTextController,
                                        //         focusNode: _model
                                        //             .disponibleDesdeFocusNode,
                                        //         autofocus: false,
                                        //         obscureText: false,
                                        //         decoration: InputDecoration(
                                        //           isDense: true,
                                        //           filled: true,
                                        //           fillColor:
                                        //               FlutterFlowTheme.of(
                                        //                       context)
                                        //                   .secondaryBackground,
                                        //         ),
                                        //         style: FlutterFlowTheme.of(
                                        //                 context)
                                        //             .bodyMedium
                                        //             .override(
                                        //                 font:
                                        //                     GoogleFonts.inter(),
                                        //                 letterSpacing: 0.0),
                                        //         keyboardType:
                                        //             TextInputType.text,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 14.0, 0.0, 0.0),
                                            child: Text(
                                              'Tiempo mínimo (años)',
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
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                key: _fieldKey('tiempoMinimo'),
                                                controller: _model
                                                    .tiempoMinimoTextController,
                                                focusNode: _model
                                                    .tiempoMinimoFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  errorText: _fieldErrors[
                                                      'tiempoMinimo'],
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                  hintText: '2',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .tiempoMinimoTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Align(
                                        //   alignment:
                                        //       AlignmentDirectional(-1.0, 0.0),
                                        //   child: Padding(
                                        //     padding:
                                        //         EdgeInsetsDirectional.fromSTEB(
                                        //             0.0, 10.0, 0.0, 0.0),
                                        //     child: Text(
                                        //       'Uso permitido',
                                        //       style: FlutterFlowTheme.of(
                                        //               context)
                                        //           .bodyMedium
                                        //           .override(
                                        //               font: GoogleFonts.inter(),
                                        //               letterSpacing: 0.0),
                                        //     ),
                                        //   ),
                                        // ),
                                        // Align(
                                        //   alignment:
                                        //       AlignmentDirectional(-1.0, 0.0),
                                        //   child: Padding(
                                        //     padding:
                                        //         EdgeInsetsDirectional.fromSTEB(
                                        //             0.0, 10.0, 0.0, 0.0),
                                        //     child: Container(
                                        //       width: MediaQuery.sizeOf(context)
                                        //               .width *
                                        //           1.0,
                                        //       child: TextFormField(
                                        //         controller: _model
                                        //             .usoPermitidoTextController,
                                        //         focusNode: _model
                                        //             .usoPermitidoFocusNode,
                                        //         autofocus: false,
                                        //         obscureText: false,
                                        //         decoration: InputDecoration(
                                        //           isDense: true,
                                        //           filled: true,
                                        //           fillColor:
                                        //               FlutterFlowTheme.of(
                                        //                       context)
                                        //                   .secondaryBackground,
                                        //         ),
                                        //         style: FlutterFlowTheme.of(
                                        //                 context)
                                        //             .bodyMedium
                                        //             .override(
                                        //                 font:
                                        //                     GoogleFonts.inter(),
                                        //                 letterSpacing: 0.0),
                                        //         keyboardType:
                                        //             TextInputType.multiline,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        // Align(
                                        //   alignment:
                                        //       AlignmentDirectional(-1.0, 0.0),
                                        //   child: Padding(
                                        //     padding:
                                        //         EdgeInsetsDirectional.fromSTEB(
                                        //             0.0, 10.0, 0.0, 0.0),
                                        //     child: Text(
                                        //       'Uso no permitido',
                                        //       style: FlutterFlowTheme.of(
                                        //               context)
                                        //           .bodyMedium
                                        //           .override(
                                        //               font: GoogleFonts.inter(),
                                        //               letterSpacing: 0.0),
                                        //     ),
                                        //   ),
                                        // ),
                                        // Align(
                                        //   alignment:
                                        //       AlignmentDirectional(-1.0, 0.0),
                                        //   child: Padding(
                                        //     padding:
                                        //         EdgeInsetsDirectional.fromSTEB(
                                        //             0.0, 10.0, 0.0, 0.0),
                                        //     child: Container(
                                        //       width: MediaQuery.sizeOf(context)
                                        //               .width *
                                        //           1.0,
                                        //       child: TextFormField(
                                        //         controller: _model
                                        //             .usoNoPermitidoTextController,
                                        //         focusNode: _model
                                        //             .usoNoPermitidoFocusNode,
                                        //         autofocus: false,
                                        //         obscureText: false,
                                        //         decoration: InputDecoration(
                                        //           isDense: true,
                                        //           filled: true,
                                        //           fillColor:
                                        //               FlutterFlowTheme.of(
                                        //                       context)
                                        //                   .secondaryBackground,
                                        //         ),
                                        //         style: FlutterFlowTheme.of(
                                        //                 context)
                                        //             .bodyMedium
                                        //             .override(
                                        //                 font:
                                        //                     GoogleFonts.inter(),
                                        //                 letterSpacing: 0.0),
                                        //         keyboardType:
                                        //             TextInputType.multiline,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: Text(
                                              'Otros',
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
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                controller: _model
                                                    .rentaOtrosTextController,
                                                focusNode:
                                                    _model.rentaOtrosFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                  hintText:
                                                      'Ej. no se permiten mascotas',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .rentaOtrosTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  width: 0.0,
                                  height: 0.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                );
                              }
                            },
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Zona donde se encuentra el inmueble ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
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
                                    TextSpan(
                                      text: '*',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .error,
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
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 10.0, 0.0, 0.0),
                            child: FlutterFlowDropDown<String>(
                              controller: _model.zonaValueController ??=
                                  FormFieldController<String>(null),
                              options: kDoviaZones,
                              onChanged: (val) {
                                safeSetState(() => _model.zonaValue = val);
                                _clearFieldError('zona');
                                // La zona afina la búsqueda de la dirección.
                                _geocodeAddress();
                              },
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 50.0,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              hintText: 'Selecciona zona...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              elevation: 2.0,
                              borderColor: _fieldErrors.containsKey('zona')
                                  ? FlutterFlowTheme.of(context).error
                                  : Colors.transparent,
                              borderWidth:
                                  _fieldErrors.containsKey('zona') ? 1.0 : 0.0,
                              borderRadius: 8.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              hidesUnderline: true,
                              isOverButton: false,
                              isSearchable: false,
                              isMultiSelect: false,
                            ),
                          ),
                          _fieldErrorText('zona'),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: Text.rich(
                                TextSpan(
                                    text: 'Dirección de la propiedad ',
                                    children: [
                                      TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error))
                                    ]),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                key: _fieldKey('direccionPropiedad'),
                                controller:
                                    _model.direccionPropiedadTextController,
                                focusNode: _model.direccionPropiedadFocusNode,
                                // En web tocar afuera no quita el foco por
                                // defecto; asi la busqueda corre igual.
                                onTapOutside: (_) => _model
                                    .direccionPropiedadFocusNode
                                    ?.unfocus(),
                                onFieldSubmitted: (_) => _model
                                    .direccionPropiedadFocusNode
                                    ?.unfocus(),
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  errorText: _fieldErrors['direccionPropiedad'],
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Escribe la dirección',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 20.0, 0.0, 20.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model
                                    .direccionPropiedadTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.drawMapComponentModel,
                              updateCallback: () => safeSetState(() {}),
                              child: DrawMapComponentWidget(
                                height: 300.0,
                                singlePointMode: true,
                                centerLatitude:
                                    kDoviaZoneCenters[_model.zonaValue]?.$1,
                                centerLongitude:
                                    kDoviaZoneCenters[_model.zonaValue]?.$2,
                                markedLatitude: _geocodedLatitude,
                                markedLongitude: _geocodedLongitude,
                                // El punto marcado ya es la ubicación.
                                showConfirmButton: false,
                                onPointSelected: (latitude, longitude) async {
                                  safeSetState(() {
                                    _selectedLatitude = latitude;
                                    _selectedLongitude = longitude;
                                  });
                                  _clearFieldError('ubicacion');
                                },
                                onPointCleared: () {
                                  safeSetState(() {
                                    _selectedLatitude = null;
                                    _selectedLongitude = null;
                                  });
                                },
                              ),
                            ),
                          ),
                          _fieldErrorText('ubicacion'),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 28.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Información legal',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Tu información y la de tu propiedad es confidencial y sólo se utilizará para verificar la propiedad.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: Text(
                                'Certificación de propiedad (en caso de tenerla)',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final selectedFiles = await selectFiles(
                                  multiFile: false,
                                );
                                if (selectedFiles != null) {
                                  safeSetState(() => _model
                                          .isDataUploading_certifiacionDePropiedad =
                                      true);
                                  var selectedUploadedFiles =
                                      <FFUploadedFile>[];

                                  try {
                                    selectedUploadedFiles = selectedFiles
                                        .map((m) => FFUploadedFile(
                                              name:
                                                  m.storagePath.split('/').last,
                                              bytes: m.bytes,
                                              originalFilename:
                                                  m.originalFilename,
                                            ))
                                        .toList();
                                  } finally {
                                    _model.isDataUploading_certifiacionDePropiedad =
                                        false;
                                  }
                                  if (selectedUploadedFiles.length ==
                                      selectedFiles.length) {
                                    safeSetState(() {
                                      _model.uploadedLocalFile_certifiacionDePropiedad =
                                          selectedUploadedFiles.first;
                                    });
                                  } else {
                                    safeSetState(() {});
                                    return;
                                  }
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: _uploadPreview(
                                  _model
                                      .uploadedLocalFile_certifiacionDePropiedad,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text.rich(
                                TextSpan(text: 'Finca ', children: [
                                  TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .error))
                                ]),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                key: _fieldKey('finca'),
                                controller: _model.fincaTextController,
                                focusNode: _model.fincaFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  errorText: _fieldErrors['finca'],
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Ej. 1234',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 20.0, 0.0, 20.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model.fincaTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text.rich(
                                TextSpan(text: 'Folio ', children: [
                                  TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .error))
                                ]),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                key: _fieldKey('folio'),
                                controller: _model.folioTextController,
                                focusNode: _model.folioFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  errorText: _fieldErrors['folio'],
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Ej. 56',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 20.0, 0.0, 20.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model.folioTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text.rich(
                                TextSpan(text: 'Libro ', children: [
                                  TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .error))
                                ]),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                key: _fieldKey('libro'),
                                controller: _model.libroTextController,
                                focusNode: _model.libroFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  errorText: _fieldErrors['libro'],
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Ej. 789E',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 20.0, 0.0, 20.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model.libroTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                'La propiedad está a nombre de',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: FlutterFlowDropDown<String>(
                              controller: _ownerTypeController,
                              options: const ['Propietario', 'Sociedad'],
                              onChanged: (val) {
                                safeSetState(() {
                                  _ownerType = val ?? 'Propietario';
                                  if (!_isCompany) {
                                    _fieldErrors = {..._fieldErrors}
                                      ..remove('nombreRepresentanteLegal');
                                  }
                                });
                              },
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 50.0,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(),
                                    letterSpacing: 0.0,
                                  ),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              elevation: 2.0,
                              borderColor: Colors.transparent,
                              borderWidth: 0.0,
                              borderRadius: 8.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              hidesUnderline: true,
                              isOverButton: false,
                              isSearchable: false,
                              isMultiSelect: false,
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text.rich(
                                TextSpan(
                                    text: _isCompany
                                        ? 'Nombre de sociedad '
                                        : 'Nombre de propietario ',
                                    children: [
                                      TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error))
                                    ]),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                key: _fieldKey('nombrePropietario'),
                                controller:
                                    _model.nombrePropietarioTextController,
                                focusNode: _model.nombrePropietarioFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  errorText: _fieldErrors['nombrePropietario'],
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: _isCompany
                                      ? 'Nombre de la sociedad'
                                      : 'Nombre completo',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 20.0, 0.0, 20.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model
                                    .nombrePropietarioTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text.rich(
                                TextSpan(
                                    text: 'Nombre del representante legal ',
                                    children: [
                                      if (_isCompany)
                                        TextSpan(
                                            text: '*',
                                            style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error))
                                    ]),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                key: _fieldKey('nombreRepresentanteLegal'),
                                controller: _model
                                    .nombreRepresentanteLegalTextController,
                                focusNode:
                                    _model.nombreRepresentanteLegalFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  errorText:
                                      _fieldErrors['nombreRepresentanteLegal'],
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Nombre completo',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 20.0, 0.0, 20.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model
                                    .nombreRepresentanteLegalTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                'Subir identificación del propietario/representante legal',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final selectedFiles = await selectFiles(
                                  multiFile: false,
                                );
                                if (selectedFiles != null) {
                                  safeSetState(() => _model
                                      .isDataUploading_propertyOwnerId = true);
                                  var selectedUploadedFiles =
                                      <FFUploadedFile>[];

                                  try {
                                    selectedUploadedFiles = selectedFiles
                                        .map((m) => FFUploadedFile(
                                              name:
                                                  m.storagePath.split('/').last,
                                              bytes: m.bytes,
                                              originalFilename:
                                                  m.originalFilename,
                                            ))
                                        .toList();
                                  } finally {
                                    _model.isDataUploading_propertyOwnerId =
                                        false;
                                  }
                                  if (selectedUploadedFiles.length ==
                                      selectedFiles.length) {
                                    safeSetState(() {
                                      _model.uploadedLocalFile_propertyOwnerId =
                                          selectedUploadedFiles.first;
                                    });
                                  } else {
                                    safeSetState(() {});
                                    return;
                                  }
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: _uploadPreview(
                                  _model.uploadedLocalFile_propertyOwnerId,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).accent1,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 40.0, 20.0, 40.0),
                                child: Text(
                                  'Revisaremos la información que ingresaste para asegurar que todo esté correcto y listo para continuar con el proceso.\n\nSi eres el propietario legal, te enviaremos un Acuerdo de Autorización para que apruebes la comercialización de tu propiedad dentro de DOVIA.\n\nSi la cuenta fue creada por un familiar, administrador o representante, te pediremos que confirmes la relación con el propietario y que éste firme digitalmente la autorización correspondiente.\n\nTodo el proceso es sencillo, guiado y 100% seguro.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.3,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.primaryButtonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: PrimaryButtonWidget(
                                text: 'Aceptar',
                                onTap: () async {
                                  // Una sola pasada de validación: se marcan
                                  // todos los campos que faltan y el scroll
                                  // va al primero.
                                  final validationErrors =
                                      _collectValidationErrors();
                                  if (validationErrors.isNotEmpty) {
                                    _showFieldErrors(validationErrors);
                                    return;
                                  }
                                  safeSetState(() => _fieldErrors = {});
                                  var shouldSetState = false;
                                  if (widget.transactionType ==
                                      PropertyPublicationType.SALE) {
                                    _model.apiResultSale =
                                        await DOVIAAPIPropertyContextGroup
                                            .createPropertyBasicSALECall
                                            .call(
                                      authToken: currentAuthenticationToken,
                                      name: _model
                                          .descripcionPropiedadTextController
                                          .text,
                                      address: _model
                                          .direccionPropiedadTextController
                                          .text,
                                      longitude: _selectedLongitude,
                                      latitude: _selectedLatitude,
                                      finca: _model.fincaTextController.text,
                                      follio: _model.folioTextController.text,
                                      libro: _model.libroTextController.text,
                                      salePrice: int.tryParse(_model
                                          .precioVentaTextController.text
                                          .replaceAll(',', '')),
                                      maintenanceFee: int.tryParse(_model
                                          .mantenimientoTextController.text
                                          .replaceAll(',', '')),
                                      singlePropertyTax: int.tryParse(_model
                                          .impustoUnicoInmueblesTextController
                                          .text
                                          .replaceAll(',', '')),
                                      isCompanyOwned: _model
                                              .nombreRepresentanteLegalTextController
                                              .text !=
                                          '',
                                      companyName: _model
                                          .nombrePropietarioTextController.text,
                                      legalRepresentative: _model
                                          .nombreRepresentanteLegalTextController
                                          .text,
                                    );

                                    shouldSetState = true;
                                    if ((_model.apiResultSale?.succeeded ??
                                        false)) {
                                      _model.createdPropertyId =
                                          DOVIAAPIPropertyContextGroup
                                              .createPropertyBasicSALECall
                                              .propertyId(
                                        (_model.apiResultSale?.jsonBody ?? ''),
                                      );
                                      safeSetState(() {});
                                    } else {
                                      await _showPublicationError(
                                        _apiErrorMessage(
                                          _model.apiResultSale?.jsonBody,
                                          'No se pudo crear la publicación de venta.',
                                        ),
                                      );
                                      if (shouldSetState) safeSetState(() {});
                                      return;
                                    }
                                  } else {
                                    if (widget.transactionType ==
                                        PropertyPublicationType.RENT) {
                                      _model.apiResultRent =
                                          await DOVIAAPIPropertyContextGroup
                                              .createPropertyBasicRENTCall
                                              .call(
                                        authToken: currentAuthenticationToken,
                                        name: _model
                                            .descripcionPropiedadTextController
                                            .text,
                                        address: _model
                                            .direccionPropiedadTextController
                                            .text,
                                        longitude: _selectedLongitude,
                                        latitude: _selectedLatitude,
                                        finca: _model.fincaTextController.text,
                                        follio: _model.folioTextController.text,
                                        libro: _model.libroTextController.text,
                                        monthlyRent: double.tryParse(_model
                                            .precioRentaMensualTextController
                                            .text
                                            .replaceAll(',', '')),
                                        minimumTimeRent: int.tryParse(_model
                                            .tiempoMinimoTextController.text),
                                        othersRent: _model
                                            .rentaOtrosTextController.text,
                                        allowedUses: _model
                                            .usoPermitidoTextController.text,
                                        prohibitedUses: _model
                                            .usoNoPermitidoTextController.text,
                                        availableFrom: _model
                                            .disponibleDesdeTextController.text,
                                        isCompanyOwned: _model
                                                .nombreRepresentanteLegalTextController
                                                .text !=
                                            '',
                                        companyName: _model
                                            .nombrePropietarioTextController
                                            .text,
                                        legalRepresentative: _model
                                            .nombreRepresentanteLegalTextController
                                            .text,
                                      );

                                      shouldSetState = true;
                                      if ((_model.apiResultRent?.succeeded ??
                                          false)) {
                                        _model.createdPropertyId =
                                            DOVIAAPIPropertyContextGroup
                                                .createPropertyBasicRENTCall
                                                .propertyId(
                                          (_model.apiResultRent?.jsonBody ??
                                              ''),
                                        );
                                        safeSetState(() {});
                                      } else {
                                        await _showPublicationError(
                                          _apiErrorMessage(
                                            _model.apiResultRent?.jsonBody,
                                            'No se pudo crear la publicación de renta.',
                                          ),
                                        );
                                        if (shouldSetState) safeSetState(() {});
                                        return;
                                      }
                                    } else {
                                      if (widget.transactionType ==
                                          PropertyPublicationType
                                              .SALE_AND_RENT) {
                                        _model.apiResultSaleAndRent =
                                            await DOVIAAPIPropertyContextGroup
                                                .createPropertyBasicSALEAndRENTCall
                                                .call(
                                          authToken: currentAuthenticationToken,
                                          name: _model
                                              .descripcionPropiedadTextController
                                              .text,
                                          address: _model
                                              .direccionPropiedadTextController
                                              .text,
                                          longitude: _selectedLongitude,
                                          latitude: _selectedLatitude,
                                          finca:
                                              _model.fincaTextController.text,
                                          follio:
                                              _model.folioTextController.text,
                                          libro:
                                              _model.libroTextController.text,
                                          salePrice: double.tryParse(_model
                                              .precioVentaTextController.text
                                              .replaceAll(',', '')),
                                          maintenanceFee: double.tryParse(_model
                                              .mantenimientoTextController.text
                                              .replaceAll(',', '')),
                                          singlePropertyTax: double.tryParse(_model
                                              .impustoUnicoInmueblesTextController
                                              .text
                                              .replaceAll(',', '')),
                                          monthlyRent: double.tryParse(_model
                                              .precioRentaMensualTextController
                                              .text
                                              .replaceAll(',', '')),
                                          minimumTimeRent: int.tryParse(_model
                                              .tiempoMinimoTextController.text),
                                          othersRent: _model
                                              .rentaOtrosTextController.text,
                                          allowedUses: _model
                                              .usoPermitidoTextController.text,
                                          prohibitedUses: _model
                                              .usoNoPermitidoTextController
                                              .text,
                                          availableFrom: _model
                                              .disponibleDesdeTextController
                                              .text,
                                          isCompanyOwned: _model
                                                  .nombreRepresentanteLegalTextController
                                                  .text !=
                                              '',
                                          companyName: _model
                                              .nombrePropietarioTextController
                                              .text,
                                          legalRepresentative: _model
                                              .nombreRepresentanteLegalTextController
                                              .text,
                                        );

                                        shouldSetState = true;
                                        if ((_model.apiResultSaleAndRent
                                                ?.succeeded ??
                                            false)) {
                                          _model.createdPropertyId =
                                              getJsonField(
                                            (_model.apiResultSaleAndRent
                                                    ?.jsonBody ??
                                                ''),
                                            r'''$.data.property.id''',
                                          ).toString();
                                          safeSetState(() {});
                                        } else {
                                          await _showPublicationError(
                                            _apiErrorMessage(
                                              _model.apiResultSaleAndRent
                                                  ?.jsonBody,
                                              'No se pudo crear la publicación de venta y renta.',
                                            ),
                                          );
                                          if (shouldSetState)
                                            safeSetState(() {});
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

                                  final createdPropertyId =
                                      _model.createdPropertyId?.trim();
                                  if (createdPropertyId == null ||
                                      createdPropertyId.isEmpty ||
                                      createdPropertyId == 'null') {
                                    await _showPublicationError(
                                      'La propiedad fue creada, pero no se recibió su identificador para cargar los documentos.',
                                    );
                                    if (shouldSetState) safeSetState(() {});
                                    return;
                                  }

                                  final documentErrors = <String>[];
                                  await Future.wait([
                                    Future(() async {
                                      final hasCertification = _model
                                              .uploadedLocalFile_certifiacionDePropiedad
                                              .bytes
                                              ?.isNotEmpty ??
                                          false;
                                      if (!hasCertification) {
                                        documentErrors.add(
                                          'No seleccionaste la certificación de la propiedad.',
                                        );
                                        return;
                                      }

                                      _model.resCertificacionPropriedad =
                                          await DOVIAAPIPropertyContextGroup
                                              .uploadPropertyCertificationCall
                                              .call(
                                        propertyId: createdPropertyId,
                                        authToken: currentAuthenticationToken,
                                        file: _model
                                            .uploadedLocalFile_certifiacionDePropiedad,
                                      );
                                      shouldSetState = true;
                                      if (!(_model.resCertificacionPropriedad
                                              ?.succeeded ??
                                          false)) {
                                        documentErrors.add(
                                          'Certificación de la propiedad: ${_apiErrorMessage(_model.resCertificacionPropriedad?.jsonBody, 'no se pudo subir el documento.')}',
                                        );
                                      }
                                    }),
                                    Future(() async {
                                      final hasOwnerId = _model
                                              .uploadedLocalFile_propertyOwnerId
                                              .bytes
                                              ?.isNotEmpty ??
                                          false;
                                      if (!hasOwnerId) {
                                        documentErrors.add(
                                          'No seleccionaste el documento de identidad del propietario.',
                                        );
                                        return;
                                      }

                                      _model.resOwnerId =
                                          await DOVIAAPIPropertyContextGroup
                                              .uploadPropertyOwnerIDDocumentCall
                                              .call(
                                        propertyId: createdPropertyId,
                                        authToken: currentAuthenticationToken,
                                        file: _model
                                            .uploadedLocalFile_propertyOwnerId,
                                      );
                                      shouldSetState = true;
                                      if (!(_model.resOwnerId?.succeeded ??
                                          false)) {
                                        documentErrors.add(
                                          'Documento de identidad del propietario: ${_apiErrorMessage(_model.resOwnerId?.jsonBody, 'no se pudo subir el documento.')}',
                                        );
                                      }
                                    }),
                                  ]);

                                  if (documentErrors.isNotEmpty) {
                                    await _showPublicationError(
                                      documentErrors.join('\n'),
                                    );
                                    if (shouldSetState) safeSetState(() {});
                                    return;
                                  }

                                  context.pushNamed(
                                    DOVIACLIENTMisPropiedadesAgendarVisitaWidget
                                        .routeName,
                                    queryParameters: {
                                      'propertyId': serializeParam(
                                        _model.createdPropertyId,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );

                                  if (shouldSetState) safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
