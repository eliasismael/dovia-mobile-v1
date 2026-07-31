import '/dovia_home_associate/associate_service_categories.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_card/d_h_a_s_s_o_c_i_a_t_e_trabajo_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_home_page_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_home_page_model.dart';

/// Panel del Dovia Home Associate (Profesional Independiente), adaptado a
/// mobile desde el diseño de escritorio.
///
/// Reúne en una sola pantalla las dos caras de su trabajo:
///   - **Trabajos disponibles**: la bolsa de solicitudes pagadas que todavía no
///     tomó ningún técnico. Cada tarjeta dice cuánto va a cobrar neto antes de
///     postularse, y esconde la dirección exacta hasta que acepta el trabajo.
///   - **Próximos trabajos**: la agenda de lo que este asociado ya aceptó.
///
/// Restricción de perfil (`Role = Independent`): esta pantalla no expone en
/// ningún punto Cotizaciones ni Trabajos Fuera de Alcance — ni botones, ni
/// tarjetas, ni contadores. Los feeds además descartan client-side cualquier
/// solicitud `QUOTE` / `OUT_OF_SCOPE` que el backend llegara a devolver
/// ([asrIsWorkableByIndependent]), para que un cambio de contrato no le filtre
/// trabajo que no le corresponde.
class DHASSOCIATEHomePageWidget extends StatefulWidget {
  const DHASSOCIATEHomePageWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_HomePage';
  static String routePath = '/dHASSOCIATEHomePage';

  /// Cuántas tarjetas entran en cada sección del panel. El resto se ve con
  /// "Ver más".
  static const int previewCount = 3;

  @override
  State<DHASSOCIATEHomePageWidget> createState() =>
      _DHASSOCIATEHomePageWidgetState();
}

class _DHASSOCIATEHomePageWidgetState extends State<DHASSOCIATEHomePageWidget> {
  late DHASSOCIATEHomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<ApiCallResponse> _availableJobsFuture;
  late Future<ApiCallResponse> _myJobsFuture;
  late Future<ApiCallResponse> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEHomePageModel());

    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    _loadFeeds();
    _categoriesFuture =
        DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall.call(
      authToken: currentAuthenticationToken ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// (Re)dispara los dos listados. Se vuelve a llamar al regresar del detalle:
  /// si el asociado tomó un trabajo, tiene que salir de la bolsa y aparecer en
  /// su agenda sin que tenga que recargar la app a mano.
  void _loadFeeds() {
    final token = currentAuthenticationToken ?? '';
    _availableJobsFuture = DOVIAAPIDoviaHomeContextGroup
        .listAvailableAssociateServiceRequestsCall
        .call(authToken: token, limit: 20);
    _myJobsFuture =
        DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall.call(
      authToken: token,
      limit: 20,
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Filtros del panel: búsqueda por palabras clave + categoría del carrusel.
  // ---------------------------------------------------------------------------

  AssociateServiceCategory? _selectedCategory(
      List<AssociateServiceCategory> categories) {
    final id = _model.selectedCategoryId;
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Map<String, dynamic>> _applyFilters(
    List<dynamic> raw,
    List<AssociateServiceCategory> categories,
  ) {
    final category = _selectedCategory(categories);
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        // Perfil Independiente: nunca cotizaciones ni fuera de alcance.
        .where(asrIsWorkableByIndependent)
        .where((data) => asrMatchesQuery(data, _model.searchQuery))
        .where((data) =>
            category == null ||
            associateRequestMatchesCategory(data, category))
        .toList();
  }

  /// Agenda activa: lo que este asociado ya aceptó y todavía tiene por delante.
  /// Los trabajos finalizados salen de "Próximos trabajos".
  bool _isUpcoming(Map<String, dynamic> data) =>
      (asrString(data['status']) ?? 'PENDING').toUpperCase() != 'FINISHED';

  // ---------------------------------------------------------------------------
  // Navegación.
  // ---------------------------------------------------------------------------

  /// Ojo de "Trabajos disponibles": abre el detalle de la oportunidad, donde el
  /// asociado decide si se postula.
  void _openOpportunity(Map<String, dynamic> data) {
    DHASSOCIATETrabajoARealizarWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName)
        .then((_) => safeSetState(_loadFeeds));
  }

  /// Ojo de "Próximos trabajos": abre el detalle de la visita ya comprometida
  /// (dirección exacta, instrucciones de ingreso, mapa).
  void _openScheduledJob(Map<String, dynamic> data) {
    DHASSOCIATETuTrabajoWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETuTrabajoWidget.routeName)
        .then((_) => safeSetState(_loadFeeds));
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  /// Cabecera del panel. El diseño de escritorio esconde los accesos de carrito
  /// y diagnósticos, así que en mobile queda sólo el logo y el título.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/D-verde.svg',
            width: 28.0,
            height: 36.0,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Dovia Home Associate',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                    lineHeight: 1.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barra "Búsqueda con IA": el asociado escribe lo que sabe hacer o lo que
  /// busca ("Fuga de agua", "Instalación TV") y los dos feeds se filtran.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(32.0),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8.0,
              color: Color(0x1A000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18.0, 4.0, 12.0, 4.0),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/search.svg',
                width: 20.0,
                height: 20.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextFormField(
                  controller: _model.searchController,
                  focusNode: _model.searchFocusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) =>
                      safeSetState(() => _model.searchQuery = value),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Búsqueda con IA',
                    hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              if (_model.searchQuery.isNotEmpty)
                InkWell(
                  onTap: () => safeSetState(() {
                    _model.searchController?.clear();
                    _model.searchQuery = '';
                  }),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Encabezado de sección con su acción a la derecha.
  Widget _buildSectionHeader(
    String title, {
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 17.0,
                  letterSpacing: 0.0,
                  lineHeight: 1.3,
                ),
          ),
        ),
        FFButtonWidget(
          onPressed: onAction,
          text: actionText,
          options: FFButtonOptions(
            height: 30.0,
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 6.0, 20.0, 6.0),
            iconPadding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: const Color(0xFFCCE3E4),
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.normal),
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      ],
    );
  }

  /// Carrusel horizontal de categorías. El botón de la sección dice "Agregar":
  /// desde acá el asociado suma especialidades a su perfil, no navega a un
  /// catálogo de compra.
  Widget _buildCategoriesCarousel(List<AssociateServiceCategory> categories) {
    if (categories.isEmpty) {
      return Text(
        'Todavía no tenés categorías habilitadas. Agregá las que sabés hacer '
        'para empezar a recibir trabajos.',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 12.0,
              letterSpacing: 0.0,
            ),
      );
    }

    return SizedBox(
      height: 100.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11.0),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _model.selectedCategoryId == category.id;

          return InkWell(
            onTap: () => safeSetState(() {
              // Segundo toque sobre la misma categoría = quitar el filtro.
              _model.selectedCategoryId = isSelected ? null : category.id;
            }),
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: 100.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isSelected
                      ? FlutterFlowTheme.of(context).primary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF70ACAD),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        category.iconPath,
                        width: 24.0,
                        height: 24.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      category.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(
                                fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3EF),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        message,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 13.0,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  /// Lista de tarjetas de una sección del panel.
  Widget _buildJobsSection({
    required Future<ApiCallResponse> future,
    required List? Function(dynamic) extractList,
    required List<AssociateServiceCategory> categories,
    required bool Function(Map<String, dynamic>) extraFilter,
    required void Function(Map<String, dynamic>) onViewDetail,
    required String emptyMessage,
  }) {
    return FutureBuilder<ApiCallResponse>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final response = snapshot.data!;
        if (!response.succeeded) {
          return _buildEmptyState(
              'No pudimos cargar los trabajos. Intentá de nuevo en un momento.');
        }

        final raw = extractList(response.jsonBody) ?? const [];
        final jobs = _applyFilters(raw, categories).where(extraFilter).toList();
        if (jobs.isEmpty) return _buildEmptyState(emptyMessage);

        return Column(
          children: jobs
              .take(DHASSOCIATEHomePageWidget.previewCount)
              .map(
                (data) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: DHASSOCIATETrabajoCardWidget(
                    title: asrServiceName(data),
                    addressLabel: asrZoneLabel(data),
                    dateLabel: asrFormattedDate(data),
                    timeLabel: asrTimeLabel(data),
                    payoutLabel: asrPayoutLabel(data),
                    priorityLabel: asrPriorityLabel(data),
                    isUrgent: asrIsEmergency(data),
                    onViewDetail: () => onViewDetail(data),
                  ),
                ),
              )
              .toList(),
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
              // El catálogo envuelve al resto del panel: las categorías
              // habilitadas también definen contra qué filtra el carrusel.
              FutureBuilder<ApiCallResponse>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  final response = snapshot.data;
                  final categories = (response != null && response.succeeded)
                      ? parseAssociateCategories(
                          DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall
                                  .servicesList(response.jsonBody) ??
                              const [])
                      : const <AssociateServiceCategory>[];

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildSearchBar(),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 28.0, 20.0, 120.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                'Servicios',
                                actionText: 'Agregar',
                                onAction: () => context
                                    .pushNamed(
                                        DHASSOCIATEServiciosWidget.routeName)
                                    .then((_) => safeSetState(() {})),
                              ),
                              const SizedBox(height: 14.0),
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                const SizedBox(
                                  height: 100.0,
                                  child:
                                      Center(child: CircularProgressIndicator()),
                                )
                              else
                                _buildCategoriesCarousel(categories),
                              const SizedBox(height: 32.0),
                              _buildSectionHeader(
                                'Trabajos disponibles:',
                                actionText: 'Ver más',
                                onAction: () => context
                                    .pushNamed(
                                        DHASSOCIATETrabajosDisponiblesWidget
                                            .routeName)
                                    .then((_) => safeSetState(_loadFeeds)),
                              ),
                              const SizedBox(height: 14.0),
                              _buildJobsSection(
                                future: _availableJobsFuture,
                                extractList: DOVIAAPIDoviaHomeContextGroup
                                    .listAvailableAssociateServiceRequestsCall
                                    .requestsList,
                                categories: categories,
                                extraFilter: (_) => true,
                                onViewDetail: _openOpportunity,
                                emptyMessage:
                                    'Por ahora no hay trabajos disponibles en '
                                    'tu zona con estos filtros.',
                              ),
                              const SizedBox(height: 32.0),
                              _buildSectionHeader(
                                'Próximos trabajos',
                                actionText: 'Ver más',
                                onAction: () => context
                                    .pushNamed(
                                        DHASSOCIATEProximosTrabajosWidget
                                            .routeName)
                                    .then((_) => safeSetState(_loadFeeds)),
                              ),
                              const SizedBox(height: 14.0),
                              _buildJobsSection(
                                future: _myJobsFuture,
                                extractList: DOVIAAPIDoviaHomeContextGroup
                                    .listAssociateServiceRequestsCall
                                    .requestsList,
                                categories: categories,
                                extraFilter: _isUpcoming,
                                onViewDetail: _openScheduledJob,
                                emptyMessage:
                                    'Todavía no aceptaste ningún trabajo. '
                                    'Postulate a los que están disponibles.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
      ),
    );
  }
}
