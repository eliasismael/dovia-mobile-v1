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
import 'd_h_a_s_s_o_c_i_a_t_e_fuera_de_alcance_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_fuera_de_alcance_model.dart';

/// Reporte de **trabajo fuera de alcance** que el asociado levanta durante la
/// ejecución: tareas que no estaban en el pedido original y aparecieron al
/// abrir la pared, destapar el caño, etc.
///
/// Es `POST /dovia-home/associate/service-requests/{id}/out-of-scope-requests`
/// con `{description, executionMode}` y su evidencia en imágenes.
///
/// `executionMode` es la decisión importante del formulario y por eso se pide
/// explícita:
///   - `REPORTER_CAN_EXECUTE`: el propio asociado puede hacerlo, y el trabajo
///     extra vuelve a él como un compromiso nuevo.
///   - `OTHER_PROVIDER_REQUIRED`: excede su oficio y va a la red de empresas.
///
/// Las imágenes **no** viajan en el body: se adjuntan después con
/// presign → PUT → confirm, que necesitan el id del reporte ya creado.
class DHASSOCIATEFueraDeAlcanceWidget extends StatefulWidget {
  const DHASSOCIATEFueraDeAlcanceWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_FueraDeAlcance';
  static String routePath = '/dHASSOCIATEFueraDeAlcance';

  /// Servicio en curso sobre el que se reporta el hallazgo. Se inyecta antes de
  /// navegar, porque go_router navega sólo por nombre (misma convención que el
  /// resto de las pantallas del asociado).
  static String? serviceRequestId;

  @override
  State<DHASSOCIATEFueraDeAlcanceWidget> createState() =>
      _DHASSOCIATEFueraDeAlcanceWidgetState();
}

/// Opciones de `executionMode` con el texto que ve el asociado.
const List<({String value, String label, String help})> _kExecutionModes = [
  (
    value: 'REPORTER_CAN_EXECUTE',
    label: 'Lo puedo hacer yo',
    help: 'El trabajo extra vuelve a vos como un nuevo compromiso.',
  ),
  (
    value: 'OTHER_PROVIDER_REQUIRED',
    label: 'Necesita otro proveedor',
    help: 'Excede tu oficio: DOVIA lo deriva a la red de empresas.',
  ),
];

class _DHASSOCIATEFueraDeAlcanceWidgetState
    extends State<DHASSOCIATEFueraDeAlcanceWidget> {
  late DHASSOCIATEFueraDeAlcanceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Servicio fijado al abrir la pantalla, para que el envío no dependa de un
  /// estático que otra navegación pueda cambiar por debajo.
  String? _serviceRequestId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEFueraDeAlcanceModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _serviceRequestId = DHASSOCIATEFueraDeAlcanceWidget.serviceRequestId;
    DHASSOCIATEFueraDeAlcanceWidget.serviceRequestId = null;

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Selector nativo del dispositivo. Sólo fotos: el presign del reporte
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

  /// Crea el reporte y, si hay fotos, las adjunta.
  ///
  /// El orden es forzoso: las rutas de imágenes van contra el id del reporte,
  /// que sólo existe después del POST. Un fallo de fotos no invalida el reporte
  /// —ya está creado y DOVIA ya puede tratarlo—, así que se avisa y se sigue.
  Future<void> _submit() async {
    final serviceRequestId = _serviceRequestId;
    if (serviceRequestId == null || serviceRequestId.isEmpty) {
      _showMessage('No se encontró el trabajo para reportar.');
      return;
    }

    final description = _model.textController?.text.trim() ?? '';
    if (description.isEmpty) {
      _showMessage('Describe el trabajo adicional que hace falta.');
      return;
    }

    final executionMode = _model.executionMode;
    if (executionMode == null) {
      _showMessage('Indicá si vos podés hacer el trabajo extra.');
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final call = DOVIAAPIDoviaHomeContextGroup.createOutOfScopeRequestCall;
      final response = await call.call(
        serviceRequestId: serviceRequestId,
        description: description,
        executionMode: executionMode,
        authToken: token,
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage(_submitError(response));
        return;
      }

      final requestId = call.requestId(response.jsonBody);
      final upload = requestId == null
          ? null
          : await _uploadImages(requestId, token);
      if (!mounted) return;

      _showMessage(upload != null && upload.isPartial
          ? 'Reporte enviado, pero algunas fotos no se pudieron subir.'
          : 'Reporte enviado. DOVIA lo revisa y el cliente decide.');
      Navigator.pop(context);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// Los errores de dominio de este flujo se le explican distinto al asociado:
  /// "el trabajo no está en curso" no se resuelve reintentando.
  String _submitError(ApiCallResponse response) {
    switch (doviaHomeErrorCode(response)) {
      case 'DOVIA_HOME_OUT_OF_SCOPE_REQUEST_ALREADY_ACTIVE':
        return 'Ya hay un reporte de trabajo adicional en curso para este '
            'trabajo.';
      case 'DOVIA_HOME_OUT_OF_SCOPE_INVALID_STATE':
        return 'Sólo puedes reportar trabajos adicionales con el trabajo en '
            'curso.';
      default:
        return 'No se pudo enviar el reporte. Intenta de nuevo.';
    }
  }

  Future<DoviaHomeUploadResult> _uploadImages(String requestId, String token) {
    final presignCall =
        DOVIAAPIDoviaHomeContextGroup.presignOutOfScopeImagesCall;
    final confirmCall =
        DOVIAAPIDoviaHomeContextGroup.confirmOutOfScopeImagesCall;
    final media = _model.uploadedMedia;

    return uploadDoviaHomeImages(
      uploads: [
        for (var i = 0; i < media.length; i++)
          if (media[i].bytes != null)
            DoviaHomeUpload(
              fileName: media[i].name ?? 'hallazgo_$i.jpg',
              bytes: media[i].bytes!,
              mimeType: doviaHomeMimeTypeFor(media[i].name ?? 'hallazgo_$i.jpg'),
            ),
      ],
      presign: (uploads) => presignCall.call(
        requestId: requestId,
        uploads: uploads,
        authToken: token,
      ),
      confirm: (storageKeys) => confirmCall.call(
        requestId: requestId,
        storageKeys: storageKeys,
        authToken: token,
      ),
      extractItems: presignCall.items,
      extractUrls: confirmCall.images,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _label(String text) => Align(
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

  /// Selector de `executionMode`. Son dos caminos de negocio distintos, así que
  /// se muestran con su consecuencia escrita en vez de un rótulo suelto.
  Widget _buildExecutionModePicker() {
    return Column(
      children: [
        for (final mode in _kExecutionModes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () => safeSetState(() => _model.executionMode = mode.value),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: _model.executionMode == mode.value
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).alternate,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _model.executionMode == mode.value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.label,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Text(
                            mode.help,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
              : Image.memory(bytes,
                  width: 88.0, height: 88.0, fit: BoxFit.cover),
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
                      tittleText: 'Trabajos adicionales',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 35.0, 20.0, 140.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('¿Qué trabajo adicional hace falta?'),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          maxLines: 5,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Ej: al reparar la tubería se descubrió '
                                'que hay que romper más pared de lo previsto.',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0x00000000), width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0x00000000), width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.publicSans(),
                                fontSize: 13.0,
                                letterSpacing: 0.0,
                              ),
                          validator: _model.textControllerValidator
                              .asValidator(context),
                        ),
                        const SizedBox(height: 21.0),
                        _label('¿Quién puede hacerlo?'),
                        const SizedBox(height: 12.0),
                        _buildExecutionModePicker(),
                        const SizedBox(height: 11.0),
                        _label('Fotos del hallazgo (opcional)'),
                        const SizedBox(height: 12.0),
                        InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: _pickMedia,
                          child: Container(
                            width: double.infinity,
                            height: 120.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: _mediaPreview(),
                          ),
                        ),
                        const SizedBox(height: 21.0),
                        FFButtonWidget(
                          onPressed: _model.isSubmitting ? null : () => _submit(),
                          text: _model.isSubmitting
                              ? 'Enviando…'
                              : 'Enviar reporte',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
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
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(25.0),
                            disabledColor:
                                FlutterFlowTheme.of(context).alternate,
                            disabledTextColor:
                                FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  wrapWithModel(
                    model: _model.dHASSOCIATENavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHASSOCIATENavbarWidget(),
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
