import '/shared_components/status_bar_clip/status_bar_clip.dart';
import '/dovia_home_client/category_picker.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/service_catalog.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';

import 'd_h_c_l_i_e_n_t_emergencias_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_h_c_l_i_e_n_t_emergencias_model.dart';

class DHCLIENTEmergenciasWidget extends StatefulWidget {
  const DHCLIENTEmergenciasWidget({super.key});

  static String routeName = 'DH_CLIENT_Emergencias';
  static String routePath = '/dHCLIENTEmergencias';

  @override
  State<DHCLIENTEmergenciasWidget> createState() =>
      _DHCLIENTEmergenciasWidgetState();
}

class _DHCLIENTEmergenciasWidgetState extends State<DHCLIENTEmergenciasWidget> {
  late DHCLIENTEmergenciasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Categorías de emergencia del catálogo. El POST exige `categoryId`, y de
  /// ahí sale el servicio de emergencia activo del lado del backend.
  DoviaHomeServiceScope? _scope;
  bool _isLoadingScope = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTEmergenciasModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    // Rehabilita el botón [Enviar] en tiempo real según haya descripción.
    _model.textController!.addListener(_onDescriptionChanged);

    _loadScope();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.textController?.removeListener(_onDescriptionChanged);
    _model.dispose();

    super.dispose();
  }

  void _onDescriptionChanged() => safeSetState(() {});

  /// El botón [Enviar] se habilita únicamente cuando el usuario ingresó una
  /// descripción en el campo de texto y eligió el tipo de emergencia: los dos
  /// datos son obligatorios para crear la solicitud.
  bool get _canSubmit => _hasDescription && _selectedCategoryId != null;

  bool get _hasDescription =>
      (_model.textController?.text.trim().isNotEmpty) ?? false;

  /// Trae las categorías de emergencia. No recibe servicio: el backend
  /// resuelve cuál es el de tipo `EMERGENCY` vigente.
  Future<void> _loadScope() async {
    final scope = await loadDoviaHomeEmergencyScope(
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    safeSetState(() {
      _scope = scope;
      _isLoadingScope = false;
      final categories = scope?.categories ?? const [];
      // Con una sola categoría no tiene sentido preguntar.
      if (categories.length == 1) _selectedCategoryId = categories.first.id;
      if (scope?.categoryById(_selectedCategoryId) == null) {
        _selectedCategoryId = null;
      }
    });
  }

  String get _categoryRowLabel {
    if (_isLoadingScope) return 'Cargando tipos de emergencia...';
    if (_scope == null) return 'No se pudo cargar el tipo de emergencia';
    return _scope?.categoryById(_selectedCategoryId)?.name ??
        'Selecciona el tipo de emergencia';
  }

  Future<void> _pickCategory() async {
    if (_isLoadingScope) return;
    // El catálogo no cargó (Ej: falló la red): se reintenta acá en vez de
    // dejar la fila muerta.
    if (_scope == null) {
      safeSetState(() => _isLoadingScope = true);
      await _loadScope();
      if (!mounted || _scope == null) return;
    }

    final category = await pickDoviaHomeCategory(
      context: context,
      title: 'Tipo de emergencia',
      categories: _scope?.categories ?? const [],
      selectedId: _selectedCategoryId,
      emptyMessage: 'No hay tipos de emergencia disponibles en este momento.',
    );
    if (category == null || !mounted) return;
    safeSetState(() => _selectedCategoryId = category.id);
  }

  /// Zona de carga de fotografías: selector nativo Cámara / Galería. Las fotos
  /// son opcionales, se adjuntan a la solicitud al confirmar el pago.
  Future<void> _pickPhotos() async {
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
    safeSetState(() => _model.isPhotoUploading = true);
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
      safeSetState(() => _model.uploadedPhotos.addAll(files));
    } finally {
      safeSetState(() => _model.isPhotoUploading = false);
    }
  }

  Widget _buildPhotoThumbnails() {
    final photos = _model.uploadedPhotos;
    final columns = (photos.length + 1).clamp(1, 4);
    const spacing = 8.0;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final tileHeight = tileWidth.clamp(0.0, 160.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var index = 0; index < photos.length; index++)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: photos[index].bytes != null
                            ? Image.memory(
                                photos[index].bytes!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4.0,
                      right: 4.0,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => safeSetState(() => photos.removeAt(index)),
                        child: Container(
                          width: 22.0,
                          height: 22.0,
                          decoration: const BoxDecoration(
                            color: Color(0xCC000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _model.isPhotoUploading ? null : _pickPhotos,
              child: Container(
                width: tileWidth,
                height: tileHeight,
                decoration: BoxDecoration(
                  color: const Color(0x2670ACAD),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: _model.isPhotoUploading
                    ? const DoviaSpinner(small: true)
                    : Icon(
                        Icons.add,
                        size: 28.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
              ),
            ),
          ],
        );
      }),
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
            StatusBarClip(
                child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: DOVIASHAREDHeaderWidget(
                      showLogo: openedFromHome(context),
                      showSupport: false,
                      showMap: false,
                      showCurrency: false,
                      title: 'Emergencias',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 150.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Aviso de nivel de servicio (obligatorio).
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: Text(
                            'Atención prioritaria de emergencia, con respuesta en menos de 18 horas',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w700),
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        // Tipo de emergencia: el backend exige el
                        // `categoryId` para crear la solicitud.
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: DoviaHomeSelectorRow(
                            label: _categoryRowLabel,
                            expanded: false,
                            onTap: _pickCategory,
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Text(
                            'Cuéntanos que necesitas ',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
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
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            child: TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              autofocus: false,
                              enabled: true,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                                    'Describe el problema o el trabajo que deseas realizar.  Trata de ser específico',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                                        10.0, 50.0, 0.0, 50.0),
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
                              textAlign: TextAlign.start,
                              maxLines: null,
                              cursorColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              enableInteractiveSelection: true,
                              validator: _model.textControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Text(
                            'Agregar fotos',
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
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 10.0, 0.0, 0.0),
                            child: Text(
                              'Las imágenes nos ayudan a asignarte el técnico adecuado y darte un mejor servicio.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 12.0,
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
                        // Zona de carga de fotografías (opcional).
                        if (_model.uploadedPhotos.isEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 10.0, 0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap:
                                  _model.isPhotoUploading ? null : _pickPhotos,
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 104.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: _model.isPhotoUploading
                                    ? const DoviaSpinner(small: true)
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: const BoxDecoration(
                                              color: Color(0x2670ACAD),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 20.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Toca para agregar fotos',
                                            style: GoogleFonts.publicSans(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          )
                        else
                          _buildPhotoThumbnails(),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 28.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              // Sólo se habilita con el tipo de emergencia y
                              // la descripción cargados.
                              onPressed: _canSubmit
                                  ? () async {
                                      // El levantamiento viaja al paso de cobro,
                                      // que crea la solicitud de emergencia y
                                      // le adjunta las fotos.
                                      //
                                      // Se limpia la solicitud anterior: si un
                                      // intento previo quedó sin pagar, su id
                                      // sigue en el estático y esta emergencia
                                      // nueva se cobraría contra aquélla.
                                      DHCLIENTCostoEmergenciaWidget
                                          .serviceRequestId = null;
                                      DHCLIENTCostoEmergenciaWidget.categoryId =
                                          _selectedCategoryId;
                                      DHCLIENTCostoEmergenciaWidget
                                              .description =
                                          _model.textController!.text.trim();
                                      DHCLIENTCostoEmergenciaWidget.photos =
                                          List.of(_model.uploadedPhotos);
                                      context.pushNamed(
                                          DHCLIENTCostoEmergenciaWidget
                                              .routeName);
                                    }
                                  : null,
                              text: 'Enviar',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 42.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                disabledColor: const Color(0xFFDFDFDF),
                                disabledTextColor: const Color(0xFF6A6A6A),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
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
                          0.0, 0.0, 15.0, 12.0),
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
}
