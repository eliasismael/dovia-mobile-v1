import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_e_problema_enviado/d_h_c_l_i_e_n_t_e_problema_enviado_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'd_h_c_l_i_e_n_t_reportar_problema_model.dart';
export 'd_h_c_l_i_e_n_t_reportar_problema_model.dart';

/// Superficie de los campos del diseño (#FAFAFA).
const Color _kFieldSurface = Color(0xFFFAFAFA);

/// Reclamo bajo garantía sobre un trabajo finalizado. Sólo se llega aquí dentro
/// de la ventana de 7 días posterior a la finalización (la caducidad la evalúa
/// "Trabajo finalizado", que bloquea el botón de entrada).
///
/// El envío genera el ticket de Alta Prioridad en el panel de Customer Success:
/// ese trigger es responsabilidad del backend al recibir el reporte.
///
/// El contexto del trabajo viaja por campos estáticos porque las rutas se
/// construyen sin parámetros (ver nav.dart).
class DHCLIENTReportarProblemaWidget extends StatefulWidget {
  const DHCLIENTReportarProblemaWidget({super.key});

  /// Para POST /associate-feedback/dovia-home/services/{serviceRequestId}/reports
  /// — es la vía normal de esta pantalla. El backend resuelve el asociado desde
  /// la solicitud, por eso no se envía `targetRole`.
  static String? serviceRequestId;

  /// Para POST /associate-feedback/visits/{visitId}/reports
  static String? visitId;

  /// Para POST /associate-feedback/offers/{offerId}/reports — tiene prioridad
  /// sobre [visitId].
  static String? offerId;

  /// SHOWING_AGENT | LISTER_HQ | OPERATIVE_LISTER | LEGAL_ASSOCIATE |
  /// LEGAL_OFFICER
  static String targetRole = 'SHOWING_AGENT';

  static String routeName = 'DH_CLIENT_ReportarProblema';
  static String routePath = '/dHCLIENTReportarProblema';

  @override
  State<DHCLIENTReportarProblemaWidget> createState() =>
      _DHCLIENTReportarProblemaWidgetState();
}

class _DHCLIENTReportarProblemaWidgetState
    extends State<DHCLIENTReportarProblemaWidget> {
  late DHCLIENTReportarProblemaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTReportarProblemaModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// La descripción del problema es obligatoria; la evidencia es opcional.
  bool get _canSubmit =>
      (_model.textController?.text.trim().isNotEmpty ?? false) &&
      !_model.isSubmitting;

  /// Selector nativo del dispositivo: Cámara / Galería.
  ///
  /// Sólo fotos: el presign de reportes del backend rechaza cualquier archivo
  /// que no sea imagen, así que ofrecer video terminaría en un adjunto perdido.
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
    safeSetState(() => _model.isMediaUploading = true);
    try {
      final files = selectedMedia
          .map((m) => FFUploadedFile(
                name: m.storagePath.split('/').last,
                bytes: m.bytes,
                height: m.dimensions?.height,
                width: m.dimensions?.width,
                blurHash: m.blurHash,
                originalFilename: m.originalFilename,
              ))
          .toList();
      safeSetState(() => _model.uploadedMedia.addAll(files));
    } finally {
      safeSetState(() => _model.isMediaUploading = false);
    }
  }

  /// El backend valida el tipo declarado, así que se deriva de la extensión en
  /// vez de asumir JPEG para todo.
  String _mimeTypeFor(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'image/jpeg';
    }
  }

  /// Adjunta la evidencia al reporte con el flujo presign → PUT → confirm. Es
  /// best-effort: el reporte ya está creado, así que un fallo de subida no debe
  /// invalidar el reclamo.
  Future<void> _uploadEvidence(String serviceRequestId, String reportId) async {
    final media = _model.uploadedMedia;
    if (media.isEmpty) return;

    final token = currentAuthenticationToken ?? '';
    final mimeTypes = <String>[];
    final uploads = <Map<String, dynamic>>[];
    for (var i = 0; i < media.length; i++) {
      final fileName = media[i].name ?? 'evidencia_$i.jpg';
      final mimeType = _mimeTypeFor(fileName);
      mimeTypes.add(mimeType);
      uploads.add({
        'clientUploadId': 'upload_$i',
        'fileName': fileName,
        'mimeType': mimeType,
        'sizeBytes': media[i].bytes?.length ?? 0,
      });
    }

    final presignRes = await DOVIAAPIAssociateFeedbackContextGroup
        .presignDoviaHomeReportImagesCall
        .call(
      serviceRequestId: serviceRequestId,
      uploads: uploads,
      authToken: token,
    );
    if (!presignRes.succeeded) return;

    final items = DOVIAAPIAssociateFeedbackContextGroup
        .presignDoviaHomeReportImagesCall
        .items(presignRes.jsonBody);
    if (items == null || items.isEmpty) return;

    final storageKeys = <String>[];
    for (final item in items) {
      if (item is! Map) continue;
      final clientUploadId = item['clientUploadId']?.toString() ?? '';
      final uploadUrl = item['uploadUrl']?.toString();
      final storageKey = item['storageKey']?.toString();
      final index =
          int.tryParse(clientUploadId.replaceAll('upload_', '')) ?? -1;
      if (uploadUrl == null || index < 0 || index >= media.length) continue;

      final bytes = media[index].bytes;
      if (bytes == null) continue;

      final putRes = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': mimeTypes[index]},
        body: bytes,
      );
      if (putRes.statusCode >= 200 &&
          putRes.statusCode < 300 &&
          storageKey != null) {
        storageKeys.add(storageKey);
      }
    }

    if (storageKeys.isEmpty) return;
    await DOVIAAPIAssociateFeedbackContextGroup.confirmDoviaHomeReportImagesCall
        .call(
      serviceRequestId: serviceRequestId,
      reportId: reportId,
      storageKeys: storageKeys,
      authToken: token,
    );
  }

  Future<void> _submit() async {
    final description = _model.textController?.text.trim() ?? '';
    if (description.isEmpty) return;

    safeSetState(() => _model.isSubmitting = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final serviceRequestId = DHCLIENTReportarProblemaWidget.serviceRequestId;
      final offerId = DHCLIENTReportarProblemaWidget.offerId;
      final visitId = DHCLIENTReportarProblemaWidget.visitId;

      ApiCallResponse? response;
      if (serviceRequestId != null && serviceRequestId.isNotEmpty) {
        response = await DOVIAAPIAssociateFeedbackContextGroup
            .createDoviaHomeAssociateReportCall
            .call(
          serviceRequestId: serviceRequestId,
          message: description,
          authToken: token,
        );
        // Las imágenes se adjuntan al reporte ya creado (nace con
        // `imageUrls: []`), por eso la subida va después del POST.
        if (response.succeeded) {
          final reportId = DOVIAAPIAssociateFeedbackContextGroup
              .createDoviaHomeAssociateReportCall
              .id(response.jsonBody);
          if (reportId != null && reportId.isNotEmpty) {
            await _uploadEvidence(serviceRequestId, reportId);
          }
        }
      } else if (offerId != null && offerId.isNotEmpty) {
        response = await DOVIAAPIAssociateFeedbackContextGroup
            .createOfferAssociateReportCall
            .call(
          offerId: offerId,
          targetRole: DHCLIENTReportarProblemaWidget.targetRole,
          message: description,
          authToken: token,
        );
      } else if (visitId != null && visitId.isNotEmpty) {
        response = await DOVIAAPIAssociateFeedbackContextGroup
            .createVisitAssociateReportCall
            .call(
          visitId: visitId,
          targetRole: DHCLIENTReportarProblemaWidget.targetRole,
          message: description,
          authToken: token,
        );
      }

      if (response != null && !response.succeeded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('No se pudo enviar el reporte. Intenta de nuevo.'),
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: const DHCLIENTEProblemaEnviadoWidget(),
            ),
          );
        },
      );

      // Tras cerrar el modal, de vuelta al Dashboard.
      if (mounted) {
        context.goNamed(DHCLIENTHomepageWidget.routeName);
      }
    } finally {
      if (mounted) {
        safeSetState(() => _model.isSubmitting = false);
      }
    }
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
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      // Título de pantalla en plural, como el diseño (el botón
                      // de entrada sí es "Reportar problema", en singular).
                      title: 'Reportar problemas',
                      showCurrency: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _fieldLabel('Describe el problema'),
                        const SizedBox(height: 12.0),
                        _buildDescripcion(),
                        const SizedBox(height: 18.0),
                        _fieldLabel('Sube imágenes o videos si es necesario'),
                        const SizedBox(height: 12.0),
                        _buildDropZone(),
                        if (_model.uploadedMedia.isNotEmpty)
                          _buildMediaThumbnails(),
                        const SizedBox(height: 30.0),
                        FFButtonWidget(
                          onPressed: _canSubmit ? _submit : null,
                          text: _model.isSubmitting ? 'Enviando...' : 'Enviar',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 42.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 10.0, 20.0, 10.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600),
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                            disabledColor:
                                FlutterFlowTheme.of(context).alternate,
                            disabledTextColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(25.0),
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
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 100.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.dHCLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHCLIENTNavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Align(
        alignment: const AlignmentDirectional(-1.0, 0.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 16.0,
                letterSpacing: 0.32,
              ),
        ),
      );

  Widget _buildDescripcion() {
    return SizedBox(
      height: 104.0,
      child: TextFormField(
        controller: _model.textController,
        focusNode: _model.textFieldFocusNode,
        autofocus: false,
        obscureText: false,
        // El botón [Enviar] se habilita en cuanto hay texto.
        onChanged: (_) => safeSetState(() {}),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Escribe aquí...',
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 16.0,
                letterSpacing: 0.32,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: _kFieldSurface,
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(15.0, 16.0, 15.0, 16.0),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              fontSize: 16.0,
              letterSpacing: 0.32,
            ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        cursorColor: FlutterFlowTheme.of(context).primaryText,
        validator: _model.textControllerValidator.asValidator(context),
      ),
    );
  }

  /// Zona de carga que abre el selector nativo del dispositivo.
  Widget _buildDropZone() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: _model.isMediaUploading ? null : _pickMedia,
      child: Container(
        width: double.infinity,
        height: 104.0,
        decoration: BoxDecoration(
          color: _kFieldSurface,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: _model.isMediaUploading
            ? SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : SvgPicture.asset(
                'assets/images/AddMediaImage.svg',
                width: 24.0,
                height: 24.0,
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  Widget _buildMediaThumbnails() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: List.generate(_model.uploadedMedia.length, (index) {
          final media = _model.uploadedMedia[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: media.bytes != null
                    ? Image.memory(
                        media.bytes!,
                        width: 90.0,
                        height: 90.0,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _mediaFallback(),
                      )
                    : _mediaFallback(),
              ),
              Positioned(
                top: 4.0,
                right: 4.0,
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () =>
                      safeSetState(() => _model.uploadedMedia.removeAt(index)),
                  child: Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: const BoxDecoration(
                      color: Color(0xCC000000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Marcador para una imagen que no se pudo decodificar en la previsualización.
  Widget _mediaFallback() => Container(
        width: 90.0,
        height: 90.0,
        color: FlutterFlowTheme.of(context).alternate,
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Icon(
          Icons.image_outlined,
          color: FlutterFlowTheme.of(context).secondaryText,
          size: 28.0,
        ),
      );
}
