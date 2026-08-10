import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/dovia_home_image_upload.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_adicional_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_trabajo_adicional_model.dart';

/// Solicitud de **materiales extra** que el asociado levanta durante el trabajo.
///
/// El formulario es "escribe el material adicional que necesitas" + fotos de
/// dónde se usará, que es exactamente
/// `POST /dovia-home/associate/service-requests/{id}/extra-materials` con
/// `{requestedMaterials}` y su evidencia en `installationImageUrls`.
///
/// Sólo se puede pedir con el servicio en `IN_PROGRESS / WORKING` y sin otra
/// solicitud de materiales activa. Crear la solicitud la deja en `QUOTE_PENDING`
/// y mueve el servicio a `MATERIALS_QUOTE_PENDING`: a partir de ahí cotiza DOVIA
/// y decide el cliente, el asociado no interviene más.
///
/// Las imágenes son opcionales y **no** viajan en el body: se adjuntan después
/// con presign → PUT → confirm, que ya necesitan el id de la solicitud creada.
class DHASSOCIATETrabajoAdicionalWidget extends StatefulWidget {
  const DHASSOCIATETrabajoAdicionalWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_TrabajoAdicional';
  static String routePath = '/dHASSOCIATETrabajoAdicional';

  /// Servicio en curso sobre el que se piden los materiales. Se inyecta antes de
  /// navegar, porque go_router navega sólo por nombre (misma convención que el
  /// resto de las pantallas del asociado).
  static String? serviceRequestId;

  @override
  State<DHASSOCIATETrabajoAdicionalWidget> createState() =>
      _DHASSOCIATETrabajoAdicionalWidgetState();
}

class _DHASSOCIATETrabajoAdicionalWidgetState
    extends State<DHASSOCIATETrabajoAdicionalWidget> {
  late DHASSOCIATETrabajoAdicionalModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Servicio fijado al abrir la pantalla, para que el envío no dependa de un
  /// estático que otra navegación pueda cambiar por debajo.
  String? _serviceRequestId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATETrabajoAdicionalModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _serviceRequestId = DHASSOCIATETrabajoAdicionalWidget.serviceRequestId;
    DHASSOCIATETrabajoAdicionalWidget.serviceRequestId = null;

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Selector nativo del dispositivo. Sólo fotos: el presign de materiales
  /// rechaza cualquier archivo que no sea imagen.
  Future<void> _pickMedia() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
      pickerFontFamily: 'Public Sans',
    );
    if (selectedMedia == null ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }

    safeSetState(() {
      _model.uploadedMedia.addAll(
        selectedMedia.map(
          (m) => FFUploadedFile(
            name: m.storagePath.split('/').last,
            bytes: m.bytes,
            height: m.dimensions?.height,
            width: m.dimensions?.width,
            blurHash: m.blurHash,
            originalFilename: m.originalFilename,
          ),
        ),
      );
    });
  }

  /// Crea la solicitud y, si hay fotos, las adjunta.
  ///
  /// El orden es forzoso: las rutas de imágenes van contra
  /// `{extraMaterialsRequestId}`, que sólo existe después del POST. Un fallo de
  /// fotos no invalida la solicitud —ya está creada y DOVIA ya puede cotizar—,
  /// así que se avisa y se sigue.
  Future<void> _submit() async {
    final serviceRequestId = _serviceRequestId;
    if (serviceRequestId == null || serviceRequestId.isEmpty) {
      _showMessage('No se encontró el trabajo para pedir materiales.');
      return;
    }

    final requestedMaterials = _model.textController?.text.trim() ?? '';
    if (requestedMaterials.isEmpty) {
      _showMessage('Escribe qué material necesitas.');
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final call = DOVIAAPIDoviaHomeContextGroup.requestExtraMaterialsCall;
      final response = await call.call(
        serviceRequestId: serviceRequestId,
        requestedMaterials: requestedMaterials,
        authToken: token,
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage(_submitError(response));
        return;
      }

      final requestId = call.id(response.jsonBody);
      final upload = requestId == null
          ? null
          : await _uploadInstallationImages(serviceRequestId, requestId, token);
      if (!mounted) return;

      _showMessage(upload != null && upload.isPartial
          ? 'Materiales solicitados, pero algunas fotos no se pudieron subir.'
          : 'Materiales solicitados. DOVIA los cotizará y el cliente decide.');
      Navigator.pop(context);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// Los errores de dominio de este flujo se le explican distinto al asociado:
  /// "ya hay una solicitud activa" no se resuelve reintentando.
  String _submitError(ApiCallResponse response) {
    switch (doviaHomeErrorCode(response)) {
      case 'DOVIA_HOME_EXTRA_MATERIALS_REQUEST_ALREADY_ACTIVE':
        return 'Ya hay una solicitud de materiales en curso para este trabajo.';
      case 'DOVIA_HOME_EXTRA_MATERIALS_INVALID_STATE':
        return 'Sólo puedes pedir materiales con el trabajo en curso.';
      default:
        return 'No se pudo enviar la solicitud. Intenta de nuevo.';
    }
  }

  Future<DoviaHomeUploadResult> _uploadInstallationImages(
    String serviceRequestId,
    String extraMaterialsRequestId,
    String token,
  ) {
    final presignCall =
        DOVIAAPIDoviaHomeContextGroup.presignExtraMaterialsImagesCall;
    final confirmCall =
        DOVIAAPIDoviaHomeContextGroup.confirmExtraMaterialsImagesCall;
    final media = _model.uploadedMedia;

    return uploadDoviaHomeImages(
      uploads: [
        for (var i = 0; i < media.length; i++)
          if (media[i].bytes != null)
            DoviaHomeUpload(
              fileName: media[i].name ?? 'instalacion_$i.jpg',
              bytes: media[i].bytes!,
              mimeType:
                  doviaHomeMimeTypeFor(media[i].name ?? 'instalacion_$i.jpg'),
            ),
      ],
      presign: (uploads) => presignCall.call(
        serviceRequestId: serviceRequestId,
        extraMaterialsRequestId: extraMaterialsRequestId,
        uploads: uploads,
        authToken: token,
      ),
      confirm: (storageKeys) => confirmCall.call(
        serviceRequestId: serviceRequestId,
        extraMaterialsRequestId: extraMaterialsRequestId,
        storageKeys: storageKeys,
        authToken: token,
      ),
      extractItems: presignCall.items,
      extractUrls: confirmCall.imageUrls,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Contenido de la caja de carga: las miniaturas elegidas o el placeholder
  /// del diseño mientras no haya ninguna.
  Widget _mediaPreview() {
    final media = _model.uploadedMedia;
    if (media.isEmpty) {
      return SvgPicture.asset(
        'assets/images/AddMediaImage.svg',
        width: 200.0,
        height: 200.0,
        fit: BoxFit.cover,
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8.0),
      itemCount: media.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8.0),
      itemBuilder: (_, index) {
        final bytes = media[index].bytes;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: bytes == null
              ? const SizedBox(width: 88.0)
              : Image.memory(bytes, width: 88.0, height: 88.0, fit: BoxFit.cover),
        );
      },
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
                      model: _model.dHASSOCIATEHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATEHeaderWidget(
                        tittleText: 'Materiales adicionales',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 35.0, 20.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        decoration: const BoxDecoration(),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
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
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Text(
                                          'Escribe el material adicional que necesitas',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.publicSans(
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
                                                    FlutterFlowTheme.of(context)
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
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          child: TextFormField(
                                            controller: _model.textController,
                                            focusNode:
                                                _model.textFieldFocusNode,
                                            autofocus: false,
                                            enabled: true,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
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
                                              hintText: 'Escribe aquí',
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
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
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      20.0, 0.0, 0.0, 100.0),
                                            ),
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
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            enableInteractiveSelection: true,
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                        'Cargar las imágenes de donde lo usarán',
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
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: _pickMedia,
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: 104.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: _mediaPreview(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 18.0, 0.0, 80.0),
                                child: FFButtonWidget(
                                  onPressed:
                                      _model.isSubmitting ? null : _submit,
                                  text: _model.isSubmitting
                                      ? 'Enviando…'
                                      : 'Solicitar',
                                  options: FFButtonOptions(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: 42.0,
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                    iconPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
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
                                          color: Colors.white,
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
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      ),
    );
  }
}
