import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_fuera_de_alcance/d_h_a_s_s_o_c_i_a_t_e_fuera_de_alcance_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_adicional/d_h_a_s_s_o_c_i_a_t_e_trabajo_adicional_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado/d_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar_model.dart';

class DHASSOCIATETrabajoARealizarWidget extends StatefulWidget {
  const DHASSOCIATETrabajoARealizarWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_TrabajoARealizar';
  static String routePath = '/dHASSOCIATETrabajoARealizar';

  /// Oportunidad que el asociado abrió desde la bolsa de trabajos disponibles.
  /// Se fija antes de navegar; null cuando se entra sin haber elegido una, en
  /// cuyo caso el encabezado queda con el placeholder del diseño.
  static Map<String, dynamic>? requestData;

  @override
  State<DHASSOCIATETrabajoARealizarWidget> createState() =>
      _DHASSOCIATETrabajoARealizarWidgetState();
}

class _DHASSOCIATETrabajoARealizarWidgetState
    extends State<DHASSOCIATETrabajoARealizarWidget> {
  late DHASSOCIATETrabajoARealizarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATETrabajoARealizarModel());

    _loadDetail();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Solicitud vigente: el detalle del backend si ya respondió, y mientras
  /// tanto lo que trajo el listado para no dejar la pantalla vacía.
  Map<String, dynamic>? get _request =>
      _model.detail ?? DHASSOCIATETrabajoARealizarWidget.requestData;

  /// Relee la solicitud del backend. El listado del marketplace es un resumen;
  /// esta llamada trae el estado actualizado, que es lo que decide si todavía
  /// se puede postular (otro asociado pudo haberla tomado mientras tanto).
  Future<void> _loadDetail() async {
    final id = _requestId;
    if (id.isEmpty) return;

    safeSetState(() => _model.isLoadingDetail = true);
    try {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .getAssociateServiceRequestCall
          .call(
        serviceRequestId: id,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;
      if (!response.succeeded) return;

      final data = getJsonField(response.jsonBody, r'''$.data''');
      if (data is Map) {
        safeSetState(() => _model.detail = Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Sin detalle fresco la pantalla sigue mostrando lo que trajo el
      // listado; no se bloquea al asociado por un fallo de red.
    } finally {
      if (mounted) safeSetState(() => _model.isLoadingDetail = false);
    }
  }

  String get _requestId {
    final data = _request;
    return data == null ? '' : asrId(data);
  }

  /// ¿Se le ofrece postularse? Sólo si la solicitud sigue libre y no la tomó ya
  /// en esta misma pantalla.
  bool get _canApply {
    final data = _request;
    if (data == null || _model.taken) return false;
    return _requestId.isNotEmpty && asrIsTakeable(data);
  }

  String get _status {
    final data = _request;
    return data == null ? '' : asrStatus(data);
  }

  /// Ya tomó el trabajo pero todavía no confirmó su llegada: se le muestra la
  /// dirección exacta, el mapa y el check-in. Cubre el estado `TAKEN` que
  /// devuelve el backend y también el instante optimista entre tomar el
  /// trabajo (o notificar la llegada) y que la relectura del detalle lo
  /// confirme, para no mostrar por un momento la sección equivocada.
  bool get _showArrivalSection {
    if (_canApply || _model.checkedIn) return false;
    return _status != 'IN_PROGRESS' && _status != 'FINISHED';
  }

  /// Ya está en sitio: acciones de ejecución del trabajo (materiales,
  /// adicionales, cierre).
  bool get _showExecutionActions => !_canApply && !_showArrivalSection;

  /// El encabezado sigue al estado, como en el diseño: mientras el trabajo se
  /// mira o se va a hacer es "Tu trabajo", y recién con el asociado en sitio
  /// —ejecutando— pasa a "Trabajo a realizar".
  String get _headerTitle =>
      _showExecutionActions ? 'Trabajo a realizar' : 'Tu trabajo';

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Postulación: toma atómica de la solicitud. El backend rechaza la segunda
  /// toma, así que un 409 no es un error del asociado sino que otro llegó
  /// primero, y se le dice con esas palabras.
  ///
  /// Al confirmar, la pantalla se queda donde está: es la misma vista de
  /// "Tu trabajo" del diseño, que ahora pasa a mostrar la dirección exacta,
  /// el mapa y el check-in en vez de volver al panel — la información deja
  /// de estar oculta apenas se acepta, sin un paso extra de navegación.
  Future<void> _applyToJob() async {
    final id = _requestId;
    if (id.isEmpty || _model.isTaking) return;

    safeSetState(() => _model.isTaking = true);
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.takeServiceRequestCall.call(
        serviceRequestId: id,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage(response.statusCode == 409
            ? 'Otro asociado tomó este trabajo antes que vos.'
            : 'No pudimos postularte a este trabajo. Intentá de nuevo.');
        return;
      }

      safeSetState(() => _model.taken = true);
      _showMessage('¡Listo! Ya podés ver la dirección exacta y el mapa.');
      // Relee el detalle: es lo que trae la dirección exacta, las
      // instrucciones de ingreso y las coordenadas, que el listado del
      // marketplace no expone.
      await _loadDetail();
    } catch (_) {
      _showMessage('No pudimos postularte a este trabajo. Intentá de nuevo.');
    } finally {
      if (mounted) safeSetState(() => _model.isTaking = false);
    }
  }

  /// Centro del mapa: coordenadas del domicilio de la visita, con el mismo
  /// fallback (Ciudad de Guatemala) que usa el selector de dirección del
  /// cliente cuando la solicitud todavía no las trae.
  double get _mapLatitude {
    final data = _request;
    return (data == null ? null : asrLatitude(data)) ?? 14.634915;
  }

  double get _mapLongitude {
    final data = _request;
    return (data == null ? null : asrLongitude(data)) ?? -90.506882;
  }

  /// Ubicación GPS actual del asociado para el check-in. El backend la usa
  /// para verificar que esté en el radio del domicilio antes de avisarle al
  /// cliente, así que sin coordenadas no se manda el check-in: se pide el
  /// permiso de ubicación en el momento en vez de asumirlo concedido.
  Future<Position?> _captureCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage(
          'Activá la ubicación del dispositivo para notificar tu llegada.');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage(
          'Necesitamos permiso de ubicación para notificar tu llegada.');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      _showMessage('No pudimos obtener tu ubicación. Intentá de nuevo.');
      return null;
    }
  }

  /// Notifica que el asociado llegó al punto (`POST .../start`): la solicitud
  /// pasa de `TAKEN` a `IN_PROGRESS` ("En Sitio") y el backend le dispara al
  /// cliente el push de que el técnico está en la puerta.
  Future<void> _startWork() async {
    final id = _requestId;
    if (id.isEmpty || _model.isStarting) return;

    safeSetState(() => _model.isStarting = true);
    try {
      final position = await _captureCurrentPosition();
      if (position == null) return;

      final response =
          await DOVIAAPIDoviaHomeContextGroup.startServiceRequestCall.call(
        serviceRequestId: id,
        latitude: position.latitude,
        longitude: position.longitude,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage('No se pudo notificar tu llegada. Intenta de nuevo.');
        return;
      }

      safeSetState(() => _model.checkedIn = true);
      _showMessage('Le avisamos al cliente que ya llegaste.');
      await _loadDetail();
    } finally {
      if (mounted) safeSetState(() => _model.isStarting = false);
    }
  }

  /// Resumen de la oportunidad que el asociado abrió desde la bolsa: título,
  /// cuándo pide la visita el cliente y cuánto va a cobrar neto. La ubicación
  /// sigue siendo sólo la zona: la dirección exacta se revela recién cuando
  /// toma el trabajo.
  String _summaryLine(int index) {
    final data = _request;
    if (data == null) return 'x\n';
    switch (index) {
      case 0:
        // El servicio dice el oficio y la categoría qué se va a hacer:
        // sin ella el asociado no sabe si va a destapar un drenaje o a
        // reparar una fuga. Las solicitudes previas al cambio de
        // contrato no la traen, y ahí la línea queda como estaba.
        final category = asrCategoryName(data);
        return category == null
            ? '${asrServiceName(data)}\n'
            : '${asrServiceName(data)} · $category\n';
      case 1:
        return '${asrLongDate(data)} · ${asrTimeLabel(data)}\n';
      default:
        return '${asrZoneLabel(data)} · ${asrPayoutLabel(data)}\n';
    }
  }

  /// Texto de la sección "Debes llevar". El contrato todavía no trae el dato
  /// (ver [asrWhatToBring]), así que se dice explícitamente que no hay
  /// indicaciones en vez de dejar la caja vacía.
  String get _whatToBringText {
    final data = _request;
    return (data == null ? null : asrWhatToBring(data)) ??
        'Sin indicaciones de materiales para esta visita.';
  }

  /// Oportunidad todavía libre: se muestra la ficha de la visita con la
  /// dirección **enmascarada**. Es el estado del diseño previo a aceptar: el
  /// asociado ve qué trabajo es y qué necesita llevar, pero la dirección
  /// exacta de un cliente que todavía no lo contrató no se revela.
  Widget _buildPreAcceptanceSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildInfoBox(
          'Dirección exacta',
          'Se revela cuando aceptes el trabajo.',
        ),
        _buildInfoBox('Debes llevar', _whatToBringText),
      ],
    );
  }

  /// Materiales extra: abre el formulario de pedido. El backend sólo lo acepta
  /// con el servicio en curso, que es justo cuando se muestra este botón.
  void _openExtraMaterials() {
    DHASSOCIATETrabajoAdicionalWidget.serviceRequestId = _requestId;
    context
        .pushNamed(DHASSOCIATETrabajoAdicionalWidget.routeName)
        .then((_) => _loadDetail());
  }

  /// Trabajo fuera de alcance: abre el reporte de tareas que no estaban en el
  /// pedido original y aparecieron durante la ejecución.
  void _openOutOfScope() {
    DHASSOCIATEFueraDeAlcanceWidget.serviceRequestId = _requestId;
    context
        .pushNamed(DHASSOCIATEFueraDeAlcanceWidget.routeName)
        .then((_) => _loadDetail());
  }

  /// Cierre del trabajo: se carga el informe y la evidencia en la pantalla de
  /// finalización, y al volver se relee el detalle para reflejar el estado.
  void _openFinishWork() {
    final data = _request;
    if (data == null) return;
    DHASSOCIATETrabajoFinalizadoWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoFinalizadoWidget.routeName)
        .then((_) => _loadDetail());
  }

  /// Botón de postulación. Sólo aparece para una oportunidad todavía libre: en
  /// un trabajo ya tomado la pantalla queda con las acciones de ejecución.
  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
      child: FFButtonWidget(
        // FFButtonWidget espera el Future y muestra su propio indicador; el
        // guard sólo evita que un segundo tap dispare otra toma.
        onPressed: _model.isTaking ? null : () => _applyToJob(),
        text: 'Postularme a este trabajo',
        options: FFButtonOptions(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 42.0,
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          color: FlutterFlowTheme.of(context).primary,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: Colors.white,
                letterSpacing: 0.0,
              ),
          elevation: 0.0,
          borderRadius: BorderRadius.circular(25.0),
          disabledColor: FlutterFlowTheme.of(context).alternate,
          disabledTextColor: FlutterFlowTheme.of(context).secondaryText,
        ),
      ),
    );
  }

  /// Etiqueta + caja de sólo lectura, el mismo estilo que ya usa "Trabajos a
  /// realizar" para mostrar datos de la visita.
  Widget _buildInfoBox(String label, String value) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(
                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  fontSize: 16.0,
                  letterSpacing: 0.32,
                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              padding: const EdgeInsetsDirectional.fromSTEB(13.0, 13.0, 13.0, 13.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dirección exacta, mapa e instrucciones de ingreso: se desocultan apenas
  /// se toma el trabajo, junto con el check-in para avisarle al cliente que
  /// el técnico llegó. Las instrucciones sólo se pintan si el cliente
  /// efectivamente dejó alguna — no hay nada que mostrarle al asociado si no
  /// dejó indicaciones.
  Widget _buildArrivalSection() {
    final data = _request;
    final address = data == null ? null : asrExactAddress(data);
    final instructions = data == null ? null : asrAccessInstructions(data);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildInfoBox('Dirección exacta', address ?? 'Dirección por confirmar'),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mapa',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 200.0,
                  child: custom_widgets.InteractiveMap(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: 200.0,
                    accessToken: FFAppConstants.MapboxAccessToken,
                    startLat: _mapLatitude,
                    startLng: _mapLongitude,
                    // El pin marca el domicilio del cliente: se mira, no se
                    // elige. Sin esto el asociado puede arrastrarlo.
                    readOnly: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (instructions != null)
          _buildInfoBox('Instrucciones de ingreso', instructions),
        _buildInfoBox('Debes llevar', _whatToBringText),
        Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
            child: Text(
              'Ya llegué al punto',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
          child: FFButtonWidget(
            onPressed: _model.isStarting ? null : () => _startWork(),
            text: _model.isStarting
                ? 'Notificando…'
                : 'Enviar mi ubicación y notificar',
            options: FFButtonOptions(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 42.0,
              padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    color: Colors.white,
                    letterSpacing: 0.0,
                  ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(25.0),
              disabledColor: FlutterFlowTheme.of(context).alternate,
              disabledTextColor: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ),
      ],
    );
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
        body: Stack(
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
                    model: _model.dHASSOCIATEHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: DHASSOCIATEHeaderWidget(
                      tittleText: _headerTitle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 35.0, 20.0, 0.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      decoration: const BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            decoration: const BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Trabajos a realizar',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.28,
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 0.0),
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              15.0, 12.0, 15.0, 0.0),
                                      child: RichText(
                                        textScaler:
                                            MediaQuery.of(context).textScaler,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: _summaryLine(0),
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        fontSize: 12.0,
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
                                            TextSpan(
                                              text: _summaryLine(1),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                            ),
                                            TextSpan(
                                              text: _summaryLine(2),
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        fontSize: 12.0,
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
                                            )
                                          ],
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
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 21.0, 0.0, 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Imagenes o video del trabajo',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.publicSans(
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
                                                .primary,
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
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Image.network(
                                                'https://picsum.photos/seed/806/600',
                                                width: 92.0,
                                                height: 92.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                'https://picsum.photos/seed/177/600',
                                                width: 92.0,
                                                height: 92.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                'https://picsum.photos/seed/201/600',
                                                width: 92.0,
                                                height: 92.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Image.network(
                                                'https://picsum.photos/seed/353/600',
                                                width: 92.0,
                                                height: 92.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ].divide(const SizedBox(width: 15.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Oportunidad todavía libre: lo único que puede hacer
                          // el asociado es postularse. Tomado y sin
                          // check-in todavía, se desoculta la dirección/mapa
                          // y el aviso de llegada. Ya en sitio, las acciones
                          // de ejecución (materiales, trabajos adicionales,
                          // finalizar).
                          if (_canApply) _buildPreAcceptanceSection(),
                          if (_canApply) _buildApplyButton(),
                          if (_showArrivalSection) _buildArrivalSection(),
                          if (_showExecutionActions)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 21.0, 0.0, 0.0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: _openExtraMaterials,
                                      text: 'Necesito materiales adicionales',
                                      options: FFButtonOptions(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height: 42.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: _openOutOfScope,
                                      text: 'Se necesitan trabajos adicionales',
                                      options: FFButtonOptions(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height: 42.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: _openFinishWork,
                                      text: 'Finalizar trabajos/visitas',
                                      options: FFButtonOptions(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height: 42.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 20.0)),
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
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 5.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: wrapWithModel(
                      model: _model.dHASSOCIATENavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATENavbarWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
