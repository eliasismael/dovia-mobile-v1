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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';

import 'd_h_c_l_i_e_n_t_instalacion_model.dart';
export 'd_h_c_l_i_e_n_t_instalacion_model.dart';

class DHCLIENTInstalacionWidget extends StatefulWidget {
  const DHCLIENTInstalacionWidget({super.key});

  static String routeName = 'DH_CLIENT_Instalacion';
  static String routePath = '/dHCLIENTInstalacion';

  /// Título del servicio elegido en el homepage (Ej: "Plomería",
  /// "Instalación"). Debe inyectarse dinámicamente según la categoría que el
  /// cliente haya seleccionado. Se usa un campo estático porque la ruta se
  /// navega solo por nombre (mismo patrón que
  /// [DHCLIENTUbicacionWidget.pendingNextRoute]).
  static String serviceTitle = 'Instalación';

  /// Levantamiento del trabajo (categoría + descripción + fotos) que viaja
  /// hasta la pantalla de Agenda, donde recién se crea la solicitud en el
  /// backend (el POST necesita la fecha, que se elige allí). Se usan campos
  /// estáticos por la misma razón que [serviceTitle]: go_router navega solo
  /// por nombre.
  ///
  /// La categoría se elige **acá**, no en Agenda: es lo que decide qué incluye
  /// la visita y qué lleva el técnico, y el cliente necesita esa claridad
  /// antes de avanzar al pago. Agenda la recibe ya elegida.
  static String? selectedCategoryId;
  static String description = '';
  static List<FFUploadedFile> photos = [];

  /// Limpia el levantamiento anterior. Se llama al iniciar una solicitud nueva
  /// y al terminar de enviarla, para que no se filtre entre solicitudes.
  static void resetDraft() {
    selectedCategoryId = null;
    description = '';
    photos = [];
  }

  @override
  State<DHCLIENTInstalacionWidget> createState() =>
      _DHCLIENTInstalacionWidgetState();
}

class _DHCLIENTInstalacionWidgetState extends State<DHCLIENTInstalacionWidget> {
  late DHCLIENTInstalacionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTInstalacionModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _loadScope();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Alcance del servicio elegido en el homepage: las categorías que se pueden
  /// pedir dentro de él, lo que lleva el técnico y lo que la visita no cubre.
  /// Sale de `GET /dovia-home/catalog/services/{serviceId}/categories`.
  DoviaHomeServiceScope? _scope;
  bool _isLoadingScope = true;
  String? _selectedCategoryId;

  Future<void> _loadScope() async {
    final scope = await loadDoviaHomeServiceScope(
      serviceTitle: DHCLIENTInstalacionWidget.serviceTitle,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    safeSetState(() {
      _scope = scope;
      _isLoadingScope = false;
      // Con una sola categoría no hay nada que preguntar: se elige sola y los
      // recuadros informativos aparecen de entrada, que es lo que el cliente
      // necesita ver.
      final categories = scope?.categories ?? const [];
      if (categories.length == 1) _selectedCategoryId = categories.first.id;
      if (scope?.categoryById(_selectedCategoryId) == null) {
        _selectedCategoryId = null;
      }
    });
  }

  /// Categoría elegida, o null mientras el cliente no haya elegido ninguna.
  /// Es lo que gobierna los dos recuadros informativos y el botón.
  DoviaHomeServiceCategory? get _selectedCategory =>
      _scope?.categoryById(_selectedCategoryId);

  /// Etiqueta del selector: distingue el catálogo cargando del servicio que no
  /// se pudo resolver, porque ahí no hay nada que elegir y el flujo no puede
  /// avanzar hasta que se recargue.
  String get _categoryRowLabel {
    if (_isLoadingScope) return 'Cargando categorías...';
    if (_scope == null) return 'No se pudieron cargar las categorías';
    return _selectedCategory?.name ??
        'Selecciona que categoria del servicio seleccionado';
  }

  Future<void> _pickCategory() async {
    if (_isLoadingScope) return;
    // El servicio no se resolvió (Ej: se entró directo a la ruta o falló la
    // red): se reintenta acá en vez de dejar la fila muerta.
    if (_scope == null) {
      safeSetState(() => _isLoadingScope = true);
      await _loadScope();
      if (!mounted || _scope == null) return;
    }

    final category = await pickDoviaHomeCategory(
      context: context,
      title: 'Categoría del servicio',
      categories: _scope?.categories ?? const [],
      selectedId: _selectedCategoryId,
      emptyMessage: 'Este servicio todavía no tiene categorías disponibles.',
    );
    if (category == null || !mounted) return;
    safeSetState(() => _selectedCategoryId = category.id);
  }

  /// Avanzar sólo exige haber elegido una categoría del catálogo: es el único
  /// dato que el POST necesita de esta pantalla. La descripción y las fotos
  /// son aportes opcionales del cliente y no bloquean el flujo.
  bool get _canContinue => _selectedCategoryId != null;

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

  /// Selector de categoría del catálogo. Es el primer control de la pantalla
  /// porque de él dependen los dos recuadros informativos y el botón.
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona especificamente en que te podemos ayudar dentro del '
          'servicio',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(
                  fontWeight:
                      FlutterFlowTheme.of(context).bodyMedium.fontWeight,
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
          child: DoviaHomeSelectorRow(
            label: _categoryRowLabel,
            expanded: false,
            onTap: _pickCategory,
          ),
        ),
      ],
    );
  }

  /// Recuadro informativo celeste del diseño: un título en negrita y sus
  /// líneas debajo, con un segundo bloque opcional para el "No incluye:" del
  /// recuadro del técnico.
  ///
  /// Los dos recuadros **no se pintan hasta que hay categoría elegida**: antes
  /// de eso no hay alcance que mostrar, y una caja celeste vacía se lee como
  /// contenido que no cargó.
  Widget _buildInfoBanner({
    required String title,
    required List<String> lines,
    String? secondTitle,
    List<String> secondLines = const [],
  }) {
    final theme = FlutterFlowTheme.of(context);
    final bodyStyle = theme.bodyMedium.override(
      font: GoogleFonts.publicSans(),
      color: const Color(0xFF00444B),
      fontSize: 14.0,
      letterSpacing: 0.0,
      lineHeight: 1.35,
    );
    final titleStyle = bodyStyle.override(
      font: GoogleFonts.publicSans(fontWeight: FontWeight.w700),
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0x3370ACAD),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            for (final line in lines)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                child: Text(line, style: bodyStyle),
              ),
            if (secondTitle != null)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Text(secondTitle, style: titleStyle),
              ),
            for (final line in secondLines)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                child: Text(line, style: bodyStyle),
              ),
          ],
        ),
      ),
    );
  }

  /// Recuadro superior: el alcance exacto que el catálogo le adjunta a la
  /// categoría elegida.
  Widget _buildScopeBanner() {
    final category = _selectedCategory;
    if (category == null) return const SizedBox.shrink();
    return _buildInfoBanner(
      title: 'Qué incluye esta categoría:',
      lines: [
        category.description.isNotEmpty
            ? category.description
            : 'El catálogo todavía no detalla el alcance de esta categoría.',
      ],
    );
  }

  /// Recuadro inferior: las herramientas base que trae el técnico y lo que la
  /// visita explícitamente no cubre. Los dos datos son del servicio, no de la
  /// categoría, pero sólo tienen sentido una vez que el cliente eligió qué
  /// necesita, así que siguen la misma regla de aparición.
  Widget _buildTechnicianBanner() {
    if (_selectedCategory == null) return const SizedBox.shrink();
    final brings = _scope?.technicianBrings ?? const <String>[];
    final notIncluded = _scope?.notIncluded ?? const <String>[];
    if (brings.isEmpty && notIncluded.isEmpty) return const SizedBox.shrink();

    return _buildInfoBanner(
      title: '¿Qué lleva el técnico?',
      lines: brings.isNotEmpty
          ? brings
          : const ['El catálogo no detalla las herramientas de este servicio.'],
      secondTitle: notIncluded.isEmpty ? null : 'No incluye:',
      secondLines: notIncluded,
    );
  }

  Widget _buildPhotoThumbnails() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: List.generate(_model.uploadedPhotos.length, (index) {
          final photo = _model.uploadedPhotos[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: photo.bytes != null
                    ? Image.memory(
                        photo.bytes!,
                        width: 90.0,
                        height: 90.0,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 90.0,
                        height: 90.0,
                        color: FlutterFlowTheme.of(context).alternate,
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
                  onTap: () =>
                      safeSetState(() => _model.uploadedPhotos.removeAt(index)),
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
          );
        }),
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
                    child: DOVIASHAREDHeaderWidget(
                      title: DHCLIENTInstalacionWidget.serviceTitle,
                      showCurrency: false,
                      showMap: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 100.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _buildCategorySelector(),
                        _buildScopeBanner(),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: Align(
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
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            child: TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              onChanged: (_) => safeSetState(() {}),
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
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 10.0, 0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: _model.isPhotoUploading ? null : _pickPhotos,
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 104.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: _model.isPhotoUploading
                                  ? SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                          ),
                        ),
                        if (_model.uploadedPhotos.isNotEmpty)
                          _buildPhotoThumbnails(),
                        _buildTechnicianBanner(),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 150.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: _canContinue
                                  ? () async {
                                      // El levantamiento viaja al paso de
                                      // Agenda, que es donde se crea la
                                      // solicitud en el backend. La categoría
                                      // va con él: Agenda ya no la vuelve a
                                      // preguntar.
                                      DHCLIENTInstalacionWidget
                                              .selectedCategoryId =
                                          _selectedCategoryId;
                                      DHCLIENTInstalacionWidget.description =
                                          _model.textController!.text.trim();
                                      DHCLIENTInstalacionWidget.photos =
                                          List.of(_model.uploadedPhotos);
                                      // Agenda crea la solicitud y de ahí
                                      // deriva al cobro (ValorVisita): el pago
                                      // custom exige un serviceId que todavía
                                      // no existe.
                                      DHCLIENTAgendaWidget
                                              .nextRouteAfterSubmit =
                                          DHCLIENTValorVisitaPageWidget
                                              .routeName;
                                      context.pushNamed(
                                          DHCLIENTAgendaWidget.routeName);
                                    }
                                  : null,
                              text: 'Siguiente',
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
}
