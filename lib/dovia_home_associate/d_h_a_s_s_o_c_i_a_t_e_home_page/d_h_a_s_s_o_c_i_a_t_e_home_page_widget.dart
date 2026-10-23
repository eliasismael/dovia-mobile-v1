import '/dovia_home_associate/associate_current_job.dart';
import '/dovia_home_associate/associate_header_actions.dart';
import '/dovia_home_associate/associate_nav.dart';
import '/dovia_home_associate/associate_service_categories.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/associate_specialties_loader.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_card/d_h_a_s_s_o_c_i_a_t_e_trabajo_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
import '/shared_components/dovia_spinner.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_home_page_model.dart';

/// Panel del Dovia Home Associate (Profesional Independiente), adaptado a
/// mobile desde el diseño de escritorio.
///
/// Reúne en una sola pantalla las dos caras de su trabajo:
///   - **Servicios**: el carrusel de filtros rápidos, poblado **sólo con los
///     oficios que tiene aprobados** ([loadAssociateCategories]); el botón de
///     la sección dice "Agregar" y lleva a pedir especialidades nuevas.
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
  late Future<AssociateCategories> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEHomePageModel());

    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    _loadFeeds();
    _loadCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Catálogo cruzado contra las especialidades aprobadas del asociado. Se
  /// vuelve a pedir al volver de "Agregar": si sumó una especialidad, tiene que
  /// aparecer en el carrusel sin recargar la app a mano.
  void _loadCategories() {
    _categoriesFuture =
        loadAssociateCategories(authToken: currentAuthenticationToken ?? '');
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
        .where((data) =>
            associateRequestMatchesQuery(data, _model.searchQuery, categories))
        .where((data) =>
            category == null || associateRequestMatchesCategory(data, category))
        .toList();
  }

  /// Agenda activa: lo que este asociado ya aceptó y todavía tiene por delante.
  /// Los trabajos finalizados salen de "Próximos trabajos".
  /// El que ya está en ejecución (`IN_PROGRESS`) tampoco: va en "En curso".
  bool _isUpcoming(Map<String, dynamic> data) {
    final status = asrStatus(data);
    return status != 'FINISHED' && status != 'IN_PROGRESS';
  }

  /// Trabajo en ejecución: el asociado ya avisó su llegada.
  bool _isInProgress(Map<String, dynamic> data) =>
      asrStatus(data) == 'IN_PROGRESS';

  /// Abre el trabajo en curso en su pantalla de ejecución (trabajos
  /// adicionales / finalizar), igual que el ítem "En curso" de la navbar.
  void _openInProgress(Map<String, dynamic> data) {
    DHASSOCIATETrabajoARealizarWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadFeeds));
  }

  /// Resumen de solo lectura de un trabajo ya cerrado.
  void _openFinished(Map<String, dynamic> data) {
    DHASSOCIATETrabajoRealizadoWidget.requestData = data;
    context.pushNamed(DHASSOCIATETrabajoRealizadoWidget.routeName,
        queryParameters: associateRouteParams(request: data));
  }

  /// Carrusel "Trabajos terminados": los últimos cerrados, cada tarjeta abre
  /// su resumen ("Trabajo realizado"). Sin ninguno, la sección se ve igual con
  /// un texto chico que lo dice.
  Widget _buildFinishedCarousel(List<AssociateServiceCategory> categories) {
    return FutureBuilder<ApiCallResponse>(
      future: _myJobsFuture,
      builder: (context, snapshot) {
        final response = snapshot.data;
        if (response == null || !response.succeeded) {
          return const SizedBox.shrink();
        }
        final jobs = _applyFilters(
                DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall
                        .requestsList(response.jsonBody) ??
                    const [],
                categories)
            .where(asrIsFinished)
            .toList()
          ..sort((a, b) => (asrFilterDate(b) ?? DateTime(0))
              .compareTo(asrFilterDate(a) ?? DateTime(0)));

        final cardWidth = MediaQuery.sizeOf(context).width * 0.8;
        return Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Trabajos terminados',
                actionText: 'Ver más',
                onAction: () => context.pushNamed(
                    DHASSOCIATEProximosTrabajosWidget.routeName,
                    queryParameters: {
                      'seccion': 'terminados'
                    }).then((_) => safeSetState(_loadFeeds)),
              ),
              const SizedBox(height: 14.0),
              if (jobs.isEmpty)
                Text(
                  'Todavía no tienes trabajos finalizados.',
                  style: GoogleFonts.publicSans(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 12.0,
                  ),
                )
              else
                SizedBox(
                  height: 190.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                    itemBuilder: (context, index) => SizedBox(
                      width: cardWidth,
                      child: DHASSOCIATETrabajoCardWidget(
                        title: asrServiceName(jobs[index]),
                        addressLabel: asrZoneLabel(jobs[index]),
                        dateLabel: asrFormattedDate(jobs[index]),
                        timeLabel: asrTimeLabel(jobs[index]),
                        payoutLabel: asrPayoutLabel(jobs[index]),
                        onViewDetail: () => _openFinished(jobs[index]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Sección "En curso": sólo existe si hay un trabajo en ejecución.
  Widget _buildInProgressSection() {
    return FutureBuilder<ApiCallResponse>(
      future: _myJobsFuture,
      builder: (context, snapshot) {
        final response = snapshot.data;
        if (response == null || !response.succeeded) {
          return const SizedBox.shrink();
        }
        final jobs = (DOVIAAPIDoviaHomeContextGroup
                    .listAssociateServiceRequestsCall
                    .requestsList(response.jsonBody) ??
                const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .where(_isInProgress)
            .toList();
        if (jobs.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'En curso',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 17.0,
                      letterSpacing: 0.0,
                      lineHeight: 1.3,
                    ),
              ),
              const SizedBox(height: 14.0),
              for (final data in jobs) _jobCard(data, _openInProgress),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Navegación.
  // ---------------------------------------------------------------------------

  /// Ojo de "Trabajos disponibles": abre el detalle de la oportunidad, donde el
  /// asociado decide si se postula.
  void _openOpportunity(Map<String, dynamic> data) {
    DHASSOCIATETrabajoARealizarWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadFeeds));
  }

  /// Ojo de "Próximos trabajos": abre el detalle de la visita ya comprometida
  /// (dirección exacta, instrucciones de ingreso, mapa).
  void _openScheduledJob(Map<String, dynamic> data) {
    DHASSOCIATETuTrabajoWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETuTrabajoWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadFeeds));
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  /// Cabecera del panel. El diseño de escritorio esconde los accesos de carrito
  /// y diagnósticos, así que en mobile queda sólo el logo y el título.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 42.0, 20.0, 0.0),
      // Título centrado en la pantalla, no entre los íconos: la D y los
      // accesos quedan encima, a cada lado.
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Home',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  lineHeight: 1.2,
                ),
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/D-verde.svg',
                width: 28.0,
                height: 36.0,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              const AssociateHeaderActions(),
            ],
          ),
        ],
      ),
    );
  }

  /// Barra de búsqueda: el asociado escribe un servicio u oficio
  /// ("albañilería", "eléctrico"), una zona ("zona 10") o una fecha
  /// ("12/07", "julio") y los dos feeds se filtran.
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
                    hintText: 'Buscar por servicio, zona o fecha',
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
        // Acción como texto sin fondo, igual que el "Ver más" del resto de
        // la app.
        InkWell(
          onTap: onAction,
          child: Text(
            actionText,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 14.0,
                ),
          ),
        ),
      ],
    );
  }

  /// Carrusel horizontal de los oficios **aprobados para este asociado**. El
  /// botón de la sección dice "Agregar": desde acá suma especialidades a su
  /// perfil, no navega a un catálogo de compra.
  Widget _buildCategoriesCarousel(List<AssociateServiceCategory> categories) {
    if (categories.isEmpty) {
      return Text(
        'Todavía no tenés servicios habilitados. Agregá los que sabés hacer '
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
      height: 116.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Aire para que no se corte la sombra de las tarjetas.
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        clipBehavior: Clip.none,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10.0,
                    offset: Offset(0.0, 3.0),
                  ),
                ],
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
                      // Igual que los servicios del Dovia Home cliente.
                      color: const Color(0xFF007376),
                      borderRadius: BorderRadius.circular(14.0),
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
        color: const Color(0x2670ACAD),
        borderRadius: BorderRadius.circular(12.0),
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
    bool dimWhileBusy = false,
  }) {
    return FutureBuilder<ApiCallResponse>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: DoviaSpinner()),
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

        // Con un trabajo en ejecución no se arranca otro: las tarjetas se ven
        // tenues y al tocarlas se avisa.
        final busy = dimWhileBusy &&
            raw
                .whereType<Map>()
                .any((e) => _isInProgress(Map<String, dynamic>.from(e)));

        return Column(
          children: [
            for (final data
                in jobs.take(DHASSOCIATEHomePageWidget.previewCount))
              _jobCard(data, onViewDetail, dimmed: busy),
          ],
        );
      },
    );
  }

  Widget _jobCard(Map<String, dynamic> data,
          void Function(Map<String, dynamic>) onViewDetail,
          {bool dimmed = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: dimmed
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                      const SnackBar(content: Text(kJobInProgressNotice))),
                child: AbsorbPointer(
                  child: Opacity(
                    opacity: 0.45,
                    child: _cardFor(data, onViewDetail),
                  ),
                ),
              )
            : _cardFor(data, onViewDetail),
      );

  Widget _cardFor(Map<String, dynamic> data,
          void Function(Map<String, dynamic>) onViewDetail) =>
      DHASSOCIATETrabajoCardWidget(
        title: asrServiceName(data),
        addressLabel: asrZoneLabel(data),
        dateLabel: asrFormattedDate(data),
        timeLabel: asrTimeLabel(data),
        payoutLabel: asrPayoutLabel(data),
        priorityLabel: asrPriorityLabel(data),
        isUrgent: asrIsEmergency(data),
        onViewDetail: () => onViewDetail(data),
      );

  // Los dos feeds juntos, armados una sola vez por carga: si se recreara en
  // cada tecla, el FutureBuilder volvería a mostrar el spinner.
  Future<List<ApiCallResponse>>? _searchFeedsFuture;
  Object? _searchFeedsKey;
  Future<List<ApiCallResponse>> _searchFeeds() {
    final key = Object.hash(_availableJobsFuture, _myJobsFuture);
    if (_searchFeedsFuture == null || _searchFeedsKey != key) {
      _searchFeedsKey = key;
      _searchFeedsFuture = Future.wait([_availableJobsFuture, _myJobsFuture]);
    }
    return _searchFeedsFuture!;
  }

  /// Con texto en la búsqueda el panel muestra sólo lo que coincide: cada
  /// tarjeta bajo la sección a la que pertenece (Trabajos disponibles o
  /// Próximos trabajos), y una sección sólo si tiene resultados.
  Widget _buildSearchResults(List<AssociateServiceCategory> categories) {
    return FutureBuilder<List<ApiCallResponse>>(
      future: _searchFeeds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: DoviaSpinner()),
          );
        }
        final available = _applyFilters(
                DOVIAAPIDoviaHomeContextGroup
                        .listAvailableAssociateServiceRequestsCall
                        .requestsList(snapshot.data![0].jsonBody) ??
                    const [],
                categories)
            .where(asrIsTakeable)
            .toList();
        final mine = _applyFilters(
                DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall
                        .requestsList(snapshot.data![1].jsonBody) ??
                    const [],
                categories)
            .where(_isUpcoming)
            .toList();
        final inProgress = _applyFilters(
                DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall
                        .requestsList(snapshot.data![1].jsonBody) ??
                    const [],
                categories)
            .where(_isInProgress)
            .toList();

        if (available.isEmpty && mine.isEmpty && inProgress.isEmpty) {
          return _buildEmptyState(
              'No encontramos trabajos para "${_model.searchQuery.trim()}".');
        }

        Widget section(String title, List<Map<String, dynamic>> jobs,
                void Function(Map<String, dynamic>) open,
                {bool dimmed = false}) =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font:
                            GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 17.0,
                        letterSpacing: 0.0,
                        lineHeight: 1.3,
                      ),
                ),
                const SizedBox(height: 14.0),
                for (final data in jobs) _jobCard(data, open, dimmed: dimmed),
              ],
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (inProgress.isNotEmpty) ...[
              section('En curso', inProgress, _openInProgress),
              const SizedBox(height: 18.0),
            ],
            if (available.isNotEmpty)
              section('Trabajos disponibles:', available, _openOpportunity),
            if (available.isNotEmpty && mine.isNotEmpty)
              const SizedBox(height: 18.0),
            if (mine.isNotEmpty)
              section('Próximos trabajos', mine, _openScheduledJob,
                  dimmed: (DOVIAAPIDoviaHomeContextGroup
                              .listAssociateServiceRequestsCall
                              .requestsList(snapshot.data![1].jsonBody) ??
                          const [])
                      .whereType<Map>()
                      .any((e) => _isInProgress(Map<String, dynamic>.from(e)))),
          ],
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
              FutureBuilder<AssociateCategories>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  // Sólo los oficios que el asociado tiene aprobados: el
                  // carrusel no puede ofrecerle filtrar por un trabajo que no
                  // está habilitado a tomar.
                  final categories = snapshot.data?.approved ??
                      const <AssociateServiceCategory>[];

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
                          child: _model.searchQuery.trim().isNotEmpty
                              ? _buildSearchResults(categories)
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(
                                      'Servicios',
                                      actionText: 'Agregar',
                                      onAction: () => context
                                          .pushNamed(DHASSOCIATEServiciosWidget
                                              .routeName)
                                          .then((_) =>
                                              safeSetState(_loadCategories)),
                                    ),
                                    const SizedBox(height: 14.0),
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting)
                                      const SizedBox(
                                        height: 100.0,
                                        child: Center(child: DoviaSpinner()),
                                      )
                                    else if (snapshot.data?.failed ?? false)
                                      _buildEmptyState(
                                          snapshot.data!.errorMessage)
                                    else
                                      _buildCategoriesCarousel(categories),
                                    _buildInProgressSection(),
                                    const SizedBox(height: 32.0),
                                    _buildSectionHeader(
                                      'Trabajos disponibles:',
                                      actionText: 'Ver más',
                                      onAction: () => context
                                          .pushNamed(
                                              DHASSOCIATETrabajosDisponiblesWidget
                                                  .routeName)
                                          .then(
                                              (_) => safeSetState(_loadFeeds)),
                                    ),
                                    const SizedBox(height: 14.0),
                                    _buildJobsSection(
                                      future: _availableJobsFuture,
                                      extractList: DOVIAAPIDoviaHomeContextGroup
                                          .listAvailableAssociateServiceRequestsCall
                                          .requestsList,
                                      categories: categories,
                                      // La bolsa es sólo lo que nadie tomó todavía.
                                      // El endpoint acepta `status` como filtro
                                      // opcional y admite TAKEN entre sus valores,
                                      // así que sin este descarte una solicitud ya
                                      // asignada podría quedar visible.
                                      extraFilter: asrIsTakeable,
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
                                          .then(
                                              (_) => safeSetState(_loadFeeds)),
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
                                      dimWhileBusy: true,
                                      emptyMessage:
                                          'Todavía no aceptaste ningún trabajo. '
                                          'Postulate a los que están disponibles.',
                                    ),
                                    _buildFinishedCarousel(categories),
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
