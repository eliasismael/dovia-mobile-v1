import '/dovia_home_associate/associate_current_job.dart';
import '/dovia_home_associate/associate_nav.dart';
import 'dart:async';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/dovia_home_image_upload.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_home_page/d_h_a_s_s_o_c_i_a_t_e_home_page_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/listing_hq/listing_hq_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado_model.dart';

/// Cierre del trabajo: el asociado carga la evidencia de lo que hizo y sus
/// recomendaciones para el cliente. Se llega desde "Finalizar trabajos/visitas"
/// con el trabajo en curso.
///
/// Al confirmar se muestra el modal de éxito y el asociado vuelve al panel. El
/// **registro en solo lectura** de un trabajo ya cerrado —con la calificación
/// del cliente— es otra pantalla ([DHASSOCIATETrabajoRealizadoWidget]), a la
/// que se llega desde las tarjetas de "Trabajos terminados" de la agenda.
///
/// El modo solo lectura de acá queda como defensa por si igual se entra con una
/// solicitud FINISHED: lo decide el estado de [requestData], así que no puede
/// quedar desincronizado.
class DHASSOCIATETrabajoFinalizadoWidget extends StatefulWidget {
  const DHASSOCIATETrabajoFinalizadoWidget({
    super.key,
    this.routeId,
    this.routeProposalId,
  });

  /// Id del trabajo que viene en la ruta (`?id=`). Manda sobre el campo
  /// estático cuando no coinciden: ver [associateRouteParams].
  final String? routeId;

  /// Id de la propuesta que viene en la ruta (`?proposalId=`).
  final String? routeProposalId;

  /// Solicitud que se está cerrando, o el trabajo terminado que se abrió desde
  /// el historial. Se fija antes de navegar; null cuando se entra a la pantalla
  /// sin haber elegido un trabajo, en cuyo caso quedan los placeholders del
  /// diseño y el formulario editable.
  static Map<String, dynamic>? requestData;

  static String routeName = 'DH_ASSOCIATE_TrabajoFinalizado';
  static String routePath = '/dHASSOCIATETrabajoFinalizado';

  @override
  State<DHASSOCIATETrabajoFinalizadoWidget> createState() =>
      _DHASSOCIATETrabajoFinalizadoWidgetState();
}

class _DHASSOCIATETrabajoFinalizadoWidgetState
    extends State<DHASSOCIATETrabajoFinalizadoWidget> {
  late DHASSOCIATETrabajoFinalizadoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic>? get _request =>
      DHASSOCIATETrabajoFinalizadoWidget.requestData;

  /// El trabajo ya está cerrado: la pantalla es el registro de lo que se hizo,
  /// no el formulario para cerrarlo.
  bool get _readOnly {
    final data = _request;
    return data != null && asrIsFinished(data);
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATETrabajoFinalizadoModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    DHASSOCIATETrabajoFinalizadoWidget.requestData = resolveRouteRequest(
        DHASSOCIATETrabajoFinalizadoWidget.requestData, widget.routeId);
    _fillCompletionFields();
    _loadRouteDetail();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Abierta sólo con el id de la ruta (notificación, deep link, hot
  /// restart): pide el trabajo para poder mostrarlo.
  Future<void> _loadRouteDetail() async {
    final data = _request;
    if (!isRouteStub(data)) return;
    final response =
        await DOVIAAPIDoviaHomeContextGroup.getAssociateServiceRequestCall.call(
      serviceRequestId: asrId(data!),
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted || !response.succeeded) return;
    final detail = getJsonField(response.jsonBody, r'''$.data''');
    if (detail is! Map) return;
    safeSetState(() {
      DHASSOCIATETrabajoFinalizadoWidget.requestData =
          Map<String, dynamic>.from(detail);
      _fillCompletionFields();
    });
  }

  /// Vuelca lo que el asociado ya había reportado al cerrar el trabajo. No pisa
  /// lo que haya escrito a mano en un cierre en curso.
  void _fillCompletionFields() {
    final data = _request;
    if (data == null) return;

    final description = asrCompletionDescription(data);
    if (description != null && (_model.textController1?.text ?? '').isEmpty) {
      _model.textController1?.text = description;
    }

    final recommendations = asrCompletionRecommendations(data);
    if (recommendations != null &&
        (_model.textController2?.text ?? '').isEmpty) {
      _model.textController2?.text = recommendations;
    }
  }

  /// Selector nativo del dispositivo para la evidencia del trabajo.
  ///
  /// Sólo fotos: el presign de imágenes de cierre rechaza cualquier archivo que
  /// no sea imagen.
  Future<void> _pickMedia(
    List<FFUploadedFile> current,
    void Function(List<FFUploadedFile>) assign,
  ) async {
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
      assign([
        ...current,
        ...selectedMedia.map(
          (m) => FFUploadedFile(
            name: m.storagePath.split('/').last,
            bytes: m.bytes,
            height: m.dimensions?.height,
            width: m.dimensions?.width,
            blurHash: m.blurHash,
            originalFilename: m.originalFilename,
          ),
        ),
      ]);
    });
  }

  /// Carga de fotos igual que en Emergencias de Dovia Home: sin fotos, un
  /// recuadro "Toca para agregar fotos"; con fotos, la grilla de miniaturas
  /// (cada una con su ✕) y un cuadro "+" para sumar más. En solo lectura la
  /// evidencia ya se cargó: se muestran las miniaturas sin acciones.
  Widget _mediaSlot(
    List<FFUploadedFile> media,
    void Function(List<FFUploadedFile>) assign,
  ) {
    final primary = FlutterFlowTheme.of(context).primary;
    void pick() => _pickMedia(media, assign);

    if (media.isEmpty) {
      if (_readOnly) return const SizedBox(height: 12.0);
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: pick,
          child: Container(
            width: double.infinity,
            height: 104.0,
            decoration: ListingHqUi.cardDecoration(context),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: const BoxDecoration(
                    color: Color(0x2670ACAD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_a_photo_outlined,
                      size: 20.0, color: primary),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Toca para agregar fotos',
                  style: GoogleFonts.publicSans(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final columns = (media.length + (_readOnly ? 0 : 1)).clamp(1, 4);
    const spacing = 8.0;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final tileHeight = tileWidth.clamp(0.0, 160.0);
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var index = 0; index < media.length; index++)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: media[index].bytes != null
                            ? Image.memory(media[index].bytes!,
                                fit: BoxFit.cover)
                            : Container(
                                color: FlutterFlowTheme.of(context).alternate),
                      ),
                    ),
                    if (!_readOnly)
                      Positioned(
                        top: 4.0,
                        right: 4.0,
                        child: InkWell(
                          onTap: () => safeSetState(
                              () => assign([...media]..removeAt(index))),
                          child: Container(
                            width: 22.0,
                            height: 22.0,
                            decoration: const BoxDecoration(
                              color: Color(0xCC000000),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (!_readOnly)
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: pick,
                child: Container(
                  width: tileWidth,
                  height: tileHeight,
                  decoration: BoxDecoration(
                    color: const Color(0x2670ACAD),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: 28.0, color: primary),
                ),
              ),
          ],
        );
      }),
    );
  }

  /// Cierra el trabajo.
  ///
  /// Evidencia del trabajo (fotos + descripción) es obligatoria para cerrar:
  /// sin ellas no hay con qué armar el reporte que se le manda al cliente. Los
  /// materiales sobrantes y las recomendaciones, en cambio, son opcionales — no
  /// todo trabajo deja materiales ni necesita una recomendación aparte.
  ///
  /// El orden de ejecución importa: las imágenes se confirman **antes** del
  /// finish, porque `finish` no recibe imágenes y una vez finalizada la
  /// solicitud ya no se le puede adjuntar evidencia. Una vez pasada la
  /// validación de que haya al menos una foto, un fallo de *subida* ya no
  /// bloquea el cierre: se avisa y se cierra igual.
  Future<void> _finish() async {
    final data = _request;
    final id = data == null ? '' : asrId(data);
    if (id.isEmpty) {
      _showMessage('No se encontró el trabajo a cerrar.');
      return;
    }

    if (_model.uploadedMedia.isEmpty) {
      _showMessage(
          'Agrega al menos una foto de los trabajos realizados para poder '
          'cerrar.');
      return;
    }

    final description = _model.textController1?.text.trim() ?? '';
    if (description.isEmpty) {
      // `completionDescription` es obligatorio en el contrato: sin él el POST
      // se rechaza, así que se pide antes de gastar la subida de imágenes.
      _showMessage('Describe los trabajos realizados para poder cerrar.');
      return;
    }
    final recommendations = _model.textController2?.text.trim() ?? '';

    safeSetState(() => _model.isSubmitting = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final work = await _uploadCompletionImages(
          id, token, 'WORK', _model.uploadedMedia);
      if (!mounted) return;
      final leftover = await _uploadCompletionImages(
          id, token, 'LEFTOVER_MATERIALS', _model.leftoverMedia);
      if (!mounted) return;
      final partial = work.isPartial || leftover.isPartial;

      final response =
          await DOVIAAPIDoviaHomeContextGroup.finishServiceRequestCall.call(
        serviceRequestId: id,
        completionDescription: description,
        clientRecommendations: recommendations.isEmpty ? null : recommendations,
        authToken: token,
      );
      if (!mounted) return;

      if (!response.succeeded) {
        // El backend explica por qué; si es por el estado, se relee el
        // trabajo para decir en cuál quedó.
        final reason = getJsonField(response.jsonBody, r'''$.message''');
        final text = reason is List ? reason.join(', ') : reason?.toString();
        if ((text ?? '').toLowerCase().contains('estado')) {
          final fresh = await DOVIAAPIDoviaHomeContextGroup
              .getAssociateServiceRequestCall
              .call(serviceRequestId: id, authToken: token);
          if (!mounted) return;
          final detail = fresh.succeeded
              ? getJsonField(fresh.jsonBody, r'''$.data''')
              : null;
          if (detail is Map) {
            _showMessage('No se pudo cerrar el trabajo. '
                '${asrFinishBlockedReason(Map<String, dynamic>.from(detail))}');
            return;
          }
        }
        _showMessage(text != null && text.isNotEmpty
            ? 'No se pudo cerrar el trabajo: $text'
            : 'No se pudo cerrar el trabajo (error ${response.statusCode}).');
        return;
      }
      AssociateCurrentJob.invalidate();

      await _showSuccessDialog(partial: partial);
      if (!mounted) return;

      // Cerrado el trabajo, el asociado vuelve al panel. Se usa `goNamed` y no
      // `push` para no dejar en la pila el formulario de un trabajo que ya se
      // cerró: desde el panel llega a este trabajo por "Trabajos terminados".
      context.goNamed(DHASSOCIATEHomePageWidget.routeName);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// Modal de cierre exitoso. El diseño no le pone botón, así que se cierra
  /// solo y el flujo sigue al panel; igual se puede tocar afuera para saltearlo.
  ///
  /// Cuando alguna foto no subió se lo dice acá: es el único aviso que va a
  /// ver, porque enseguida se navega y un SnackBar se perdería en la
  /// transición.
  Future<void> _showSuccessDialog({required bool partial}) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: const AlignmentDirectional(0.0, 0.0)
            .resolve(Directionality.of(context)),
        child: _AutoCloseDialogContent(
          child: PopupExitoWidget(
            title: 'Se envió con éxito',
            text: partial
                ? 'Tu trabajo ya fue cerrado con éxito, se informará al '
                    'cliente. Algunas fotos no se pudieron subir.'
                : 'Tu trabajo ya fue cerrado con éxito, se informará al '
                    'cliente.',
          ),
        ),
      ),
    );
  }

  /// Sube una tanda de evidencia con el ciclo presign → PUT → confirm.
  ///
  /// [category] es `WORK` o `LEFTOVER_MATERIALS`, las dos del contrato. Cada una
  /// va en su propia tanda porque el backend las persiste por separado.
  Future<DoviaHomeUploadResult> _uploadCompletionImages(
    String serviceRequestId,
    String token,
    String category,
    List<FFUploadedFile> media,
  ) {
    final presignCall =
        DOVIAAPIDoviaHomeContextGroup.presignCompletionImagesCall;
    final confirmCall =
        DOVIAAPIDoviaHomeContextGroup.confirmCompletionImagesCall;

    return uploadDoviaHomeImages(
      uploads: [
        for (var i = 0; i < media.length; i++)
          if (media[i].bytes != null)
            DoviaHomeUpload(
              fileName: media[i].name ?? 'evidencia_$i.jpg',
              bytes: media[i].bytes!,
              mimeType:
                  doviaHomeMimeTypeFor(media[i].name ?? 'evidencia_$i.jpg'),
            ),
      ],
      presign: (uploads) => presignCall.call(
        serviceRequestId: serviceRequestId,
        category: category,
        uploads: uploads,
        authToken: token,
      ),
      confirm: (storageKeys) => confirmCall.call(
        serviceRequestId: serviceRequestId,
        category: category,
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

  @override
  void dispose() {
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
                      model: _model.dHASSOCIATEHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DHASSOCIATEHeaderWidget(
                        tittleText: _readOnly
                            ? 'Trabajo realizado'
                            : 'Trabajo finalizado',
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
                                        _readOnly
                                            ? 'Imágenes del trabajo realizado'
                                            : 'Cargar imágenes de trabajos realizados',
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
                                    // Categoría WORK del contrato.
                                    _mediaSlot(
                                      _model.uploadedMedia,
                                      (files) => _model.uploadedMedia = files,
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
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Text(
                                          _readOnly
                                              ? 'Trabajos realizados'
                                              : 'Describe los trabajos realizados',
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
                                            controller: _model.textController1,
                                            focusNode:
                                                _model.textFieldFocusNode1,
                                            autofocus: false,
                                            enabled: !_readOnly,
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
                                              hintText: _readOnly
                                                  ? 'Sin datos cargados'
                                                  : 'Escribe aquí',
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
                                              // Sin esto, el campo deshabilitado
                                              // del modo solo lectura se pinta
                                              // con el subrayado por defecto de
                                              // Material y rompe el diseño.
                                              disabledBorder:
                                                  OutlineInputBorder(
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
                                                .textController1Validator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Mismo margen que el resto de las secciones.
                              Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 21.0, 0.0, 0.0),
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
                                          child: Text(
                                            'En caso de dejar materiales, ¿dónde los dejaste?',
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
                                                  letterSpacing: 0.28,
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
                                        // Categoría LEFTOVER_MATERIALS del contrato:
                                        // se confirma en su propia tanda, aparte de
                                        // las fotos del trabajo.
                                        _mediaSlot(
                                          _model.leftoverMedia,
                                          (files) =>
                                              _model.leftoverMedia = files,
                                        ),
                                      ],
                                    ),
                                  )),
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
                                          'Recomendaciones para el cliente',
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
                                            controller: _model.textController2,
                                            focusNode:
                                                _model.textFieldFocusNode2,
                                            autofocus: false,
                                            enabled: !_readOnly,
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
                                              hintText: _readOnly
                                                  ? 'Sin datos cargados'
                                                  : 'Escribe aquí',
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
                                              // Sin esto, el campo deshabilitado
                                              // del modo solo lectura se pinta
                                              // con el subrayado por defecto de
                                              // Material y rompe el diseño.
                                              disabledBorder:
                                                  OutlineInputBorder(
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
                                                .textController2Validator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // En solo lectura no hay nada que cerrar: el
                              // trabajo ya terminó.
                              if (_readOnly)
                                const SizedBox(height: 98.0)
                              else
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 18.0, 0.0, 80.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FFButtonWidget(
                                        onPressed: _model.isSubmitting
                                            ? null
                                            : _finish,
                                        text: _model.isSubmitting
                                            ? 'Cerrando…'
                                            : 'Terminado',
                                        options: FFButtonOptions(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: 42.0,
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.publicSans(
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
                                          borderRadius:
                                              BorderRadius.circular(25.0),
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

/// Envoltorio que cierra el diálogo solo después de [duration].
///
/// El modal de éxito del diseño no tiene botón, así que sin esto quedaría
/// trabado. Vive acá y no dentro de `PopupExitoWidget` porque ese componente
/// lo comparten pantallas que sí cierran con un botón.
class _AutoCloseDialogContent extends StatefulWidget {
  const _AutoCloseDialogContent({required this.child});

  /// Lo suficiente para leer el mensaje sin que la espera moleste.
  static const Duration duration = Duration(seconds: 2);

  final Widget child;

  @override
  State<_AutoCloseDialogContent> createState() =>
      _AutoCloseDialogContentState();
}

class _AutoCloseDialogContentState extends State<_AutoCloseDialogContent> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_AutoCloseDialogContent.duration, () {
      // `canPop` cubre que el usuario ya lo haya cerrado tocando afuera.
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
