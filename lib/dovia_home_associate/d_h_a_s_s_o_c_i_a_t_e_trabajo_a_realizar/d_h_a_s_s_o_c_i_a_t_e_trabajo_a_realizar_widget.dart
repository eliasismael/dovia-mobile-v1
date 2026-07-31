import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Postulación: toma atómica de la solicitud. El backend rechaza la segunda
  /// toma, así que un 409 no es un error del asociado sino que otro llegó
  /// primero, y se le dice con esas palabras.
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
      _showMessage('¡Listo! El trabajo quedó en tus próximos trabajos.');
      // Vuelve al panel, que recarga los dos feeds: la solicitud sale de la
      // bolsa y aparece en la agenda.
      Navigator.pop(context);
    } catch (_) {
      _showMessage('No pudimos postularte a este trabajo. Intentá de nuevo.');
    } finally {
      if (mounted) safeSetState(() => _model.isTaking = false);
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
        return '${asrServiceName(data)}\n';
      case 1:
        return '${asrLongDate(data)} · ${asrTimeLabel(data)}\n';
      default:
        return '${asrZoneLabel(data)} · ${asrPayoutLabel(data)}\n';
    }
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
                    child: const DHASSOCIATEHeaderWidget(
                      tittleText: 'Trabajo a realizar',
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
                          // el asociado es postularse. Las acciones de
                          // ejecución (materiales, trabajos adicionales,
                          // finalizar) son de un trabajo ya tomado.
                          if (_canApply) _buildApplyButton(),
                          if (!_canApply)
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
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
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
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
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
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
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
