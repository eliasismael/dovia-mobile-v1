import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/dovia_home_image_upload.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_adicional/d_h_a_s_s_o_c_i_a_t_e_trabajo_adicional_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_realizado/d_h_a_s_s_o_c_i_a_t_e_trabajo_realizado_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_trabajo_finalizado_model.dart';

/// Cierre del trabajo: el asociado carga la evidencia de lo que hizo y sus
/// recomendaciones para el cliente.
///
/// La misma pantalla sirve de **registro en solo lectura** una vez que la
/// solicitud quedó FINISHED — es a donde lleva el "Ojo" de la sección "Trabajos
/// terminados" de la agenda. No hace falta un flag aparte: si el trabajo ya
/// terminó no hay nada que cargar, así que el estado de la solicitud
/// ([requestData]) es lo que decide, y no puede quedar desincronizado.
class DHASSOCIATETrabajoFinalizadoWidget extends StatefulWidget {
  const DHASSOCIATETrabajoFinalizadoWidget({super.key});

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

    _fillCompletionFields();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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

  /// Caja de carga de fotos del diseño. Con fotos elegidas muestra las
  /// miniaturas; sin ellas, el placeholder original.
  Widget _mediaSlot(
    List<FFUploadedFile> media,
    void Function(List<FFUploadedFile>) assign,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // En solo lectura la evidencia ya se cargó: no hay nada que adjuntar.
        onTap: _readOnly ? null : () => _pickMedia(media, assign),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 104.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: media.isEmpty
                ? SvgPicture.asset(
                    'assets/images/AddMediaImage.svg',
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  )
                : ListView.separated(
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
                            : Image.memory(
                                bytes,
                                width: 88.0,
                                height: 88.0,
                                fit: BoxFit.cover,
                              ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  /// Cierra el trabajo.
  ///
  /// El orden importa: las imágenes se confirman **antes** del finish, porque
  /// `finish` no recibe imágenes y una vez finalizada la solicitud ya no se le
  /// adjunta evidencia. La evidencia es opcional, así que un fallo de subida no
  /// impide cerrar: se avisa y se cierra igual.
  Future<void> _finish() async {
    final data = _request;
    final id = data == null ? '' : asrId(data);
    if (id.isEmpty) {
      _showMessage('No se encontró el trabajo a cerrar.');
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
        _showMessage('No se pudo cerrar el trabajo. Intenta de nuevo.');
        return;
      }

      _showMessage(partial
          ? 'Trabajo cerrado, pero algunas fotos no se pudieron subir.'
          : 'Trabajo cerrado. ¡Gracias!');

      // Cerrado el trabajo, se pasa al registro de lo que se le envió al
      // cliente. Reemplaza esta pantalla en la pila (`pushReplacement`) para
      // que el "volver" del resumen no traiga de vuelta el formulario de un
      // trabajo que ya se cerró.
      final finished = {...?_request, 'status': 'FINISHED'};
      DHASSOCIATETrabajoRealizadoWidget.requestData = finished;
      context.pushReplacementNamed(
          DHASSOCIATETrabajoRealizadoWidget.routeName);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
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

  /// Acceso a la solicitud de materiales extra.
  ///
  /// Se ofrece sólo con el trabajo en curso: el contrato exige
  /// `IN_PROGRESS / WORKING` y una vez cerrado no hay a qué agregarle materiales.
  Widget _requestMaterialsButton() => FFButtonWidget(
        onPressed: _model.isSubmitting
            ? null
            : () {
                final data = _request;
                DHASSOCIATETrabajoAdicionalWidget.serviceRequestId =
                    data == null ? null : asrId(data);
                context.pushNamed(DHASSOCIATETrabajoAdicionalWidget.routeName);
              },
        text: 'Solicitar material adicional',
        options: FFButtonOptions(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 42.0,
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          iconPadding:
              const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          color: FlutterFlowTheme.of(context).secondaryBackground,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: FlutterFlowTheme.of(context).primary,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
          elevation: 0.0,
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(25.0),
        ),
      );

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
                                        'En caso de dejar materiales, ¿dónde los dejaste?',
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
                                    // Categoría LEFTOVER_MATERIALS del contrato:
                                    // se confirma en su propia tanda, aparte de
                                    // las fotos del trabajo.
                                    _mediaSlot(
                                      _model.leftoverMedia,
                                      (files) => _model.leftoverMedia = files,
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
                                      // Único acceso a la solicitud de
                                      // materiales extra: el contrato sólo la
                                      // permite con el trabajo en curso, que es
                                      // exactamente donde está esta pantalla.
                                      _requestMaterialsButton(),
                                      const SizedBox(height: 12.0),
                                      FFButtonWidget(
                                    onPressed:
                                        _model.isSubmitting ? null : _finish,
                                    text: _model.isSubmitting
                                        ? 'Cerrando…'
                                        : 'Terminado',
                                    options: FFButtonOptions(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 42.0,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 0.0, 16.0, 0.0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
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
