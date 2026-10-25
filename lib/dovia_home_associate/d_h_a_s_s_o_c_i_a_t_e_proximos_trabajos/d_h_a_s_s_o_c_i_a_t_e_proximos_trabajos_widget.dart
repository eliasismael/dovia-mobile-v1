import '/shared_components/status_bar_clip/status_bar_clip.dart';
import '/dovia_home_associate/associate_nav.dart';
import '/dovia_home_associate/associate_job_filters.dart';
import '/backend/api_requests/dovia_home_paginated_loader.dart';
import '/dovia_home_associate/associate_service_categories.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/associate_specialties_loader.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_card/d_h_a_s_s_o_c_i_a_t_e_trabajo_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import '/listing_hq/listing_hq_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_proximos_trabajos_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_proximos_trabajos_model.dart';

/// Agenda completa del asociado. Se abre desde el "Ver más" de la sección
/// "Próximos trabajos" del panel.
///
/// Son compromisos ya adquiridos, partidos en las dos secciones del diseño:
///   - **Trabajos aceptados**: los que ya tomó y todavía no ejecutó. El ícono de
///     "Ojo" abre el flujo de tránsito/ejecución ([DHASSOCIATETuTrabajoWidget]).
///   - **Trabajos terminados**: su historial. Ahí el "Ojo" abre el resumen del
///     trabajo en **solo lectura** ([DHASSOCIATETrabajoRealizadoWidget]): el
///     informe y la evidencia que mandó, más el feedback del cliente.
///
/// Los tres filtros son los mismos de la bolsa de oportunidades y aplican a las
/// **dos secciones a la vez**, como pide el diseño: cambiar un desplegable
/// actualiza aceptados y terminados en la misma pasada.
class DHASSOCIATEProximosTrabajosWidget extends StatefulWidget {
  const DHASSOCIATEProximosTrabajosWidget(
      {super.key, this.onlyFinished = false});

  /// `?seccion=terminados`: la misma búsqueda y filtros, pero sólo sobre el
  /// historial de trabajos terminados (el "Ver más" de ese carrusel).
  final bool onlyFinished;

  static String routeName = 'DH_ASSOCIATE_ProximosTrabajos';
  static String routePath = '/dHASSOCIATEProximosTrabajos';

  @override
  State<DHASSOCIATEProximosTrabajosWidget> createState() =>
      _DHASSOCIATEProximosTrabajosWidgetState();
}

/// Todo lo que la pantalla necesita resuelto: las especialidades que pueblan el
/// filtro de tipo y la agenda del asociado.
class _Agenda {
  const _Agenda({
    required this.categories,
    required this.jobs,
    this.jobsErrorStatus,
    this.jobsTruncated = false,
  });

  final AssociateCategories categories;

  /// Agenda completa —aceptados y terminados juntos—, **sin** los filtros de la
  /// UI aplicados: de acá salen las opciones del desplegable de mes, que no
  /// deben cambiar según lo que el asociado tenga filtrado.
  final List<Map<String, dynamic>> jobs;

  final int? jobsErrorStatus;

  /// La agenda no entró entera en el tope de páginas. Se avisa en pantalla: un
  /// historial recortado en silencio se lee como historial completo.
  final bool jobsTruncated;

  bool get jobsFailed => jobsErrorStatus != null;

  String get jobsErrorMessage => jobsErrorStatus == 403
      ? 'Tu perfil no tiene permisos para ver tu agenda. Contactá al equipo de '
          'DOVIA.'
      : 'No pudimos cargar tu agenda. Intentá de nuevo en un momento.';
}

class _DHASSOCIATEProximosTrabajosWidgetState
    extends State<DHASSOCIATEProximosTrabajosWidget> {
  late DHASSOCIATEProximosTrabajosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<_Agenda> _agendaFuture;

  /// Separación entre tarjetas, la del diseño.
  static const double _cardGap = 14.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEProximosTrabajosModel());

    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    _loadAgenda();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Datos.
  // ---------------------------------------------------------------------------

  void _loadAgenda() {
    _agendaFuture = _fetchAgenda();
  }

  /// Especialidades y agenda en paralelo: las dos llamadas arrancan antes del
  /// primer `await`.
  Future<_Agenda> _fetchAgenda() async {
    final token = currentAuthenticationToken ?? '';

    final categoriesRequest = loadAssociateCategories(authToken: token);
    // Sin filtro `status`: el endpoint acepta un único valor y la agenda cubre
    // varios (TAKEN, IN_PROGRESS, FINISHED). La separación en secciones se hace
    // client-side, que además es lo que necesita el diseño para pintar las dos
    // a la vez.
    //
    // Y se pagina hasta el final: aceptados y terminados comparten este
    // listado, así que con una sola página el historial le comería el cupo a
    // los trabajos que todavía hay que hacer.
    final call = DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall;
    final jobsRequest = loadAllDoviaHomePages(
      fetchPage: (page, limit) =>
          call.call(authToken: token, page: page, limit: limit),
      extractList: call.requestsList,
      // Perfil Independiente: sin cotizaciones ni trabajos fuera de alcance.
      keep: asrIsWorkableByIndependent,
    );

    final categories = await categoriesRequest;
    final jobs = await jobsRequest;

    if (jobs.failed) {
      return _Agenda(
        categories: categories,
        jobs: const [],
        jobsErrorStatus: jobs.errorStatus,
      );
    }

    final agenda = _Agenda(
      categories: categories,
      jobs: jobs.items,
      jobsTruncated: jobs.truncated,
    );
    _reconcileFilters(agenda);
    return agenda;
  }

  /// Suelta los filtros que dejaron de existir después de recargar — el último
  /// trabajo de "Agosto 2026" se reprogramó, o le revocaron una especialidad.
  ///
  /// El desplegable solo ya se defiende (ignora un valor que no esté entre sus
  /// opciones y vuelve al placeholder), pero el filtro seguiría aplicado: el
  /// asociado vería las dos secciones vacías y un desplegable que dice que no
  /// está filtrando nada. Se corre fuera del build, al resolver la carga.
  void _reconcileFilters(_Agenda agenda) {
    final months = associateMonthOptions(agenda.jobs).map((m) => m.key).toSet();
    if (_model.monthKey != null && !months.contains(_model.monthKey)) {
      _model.monthKey = null;
      _model.monthController?.value = kAssociateFilterAll;
    }

    final approved = agenda.categories.approved.map((c) => c.id).toSet();
    if (_model.categoryId != null && !approved.contains(_model.categoryId)) {
      _model.categoryId = null;
      _model.categoryController?.value = kAssociateFilterAll;
    }
  }

  // ---------------------------------------------------------------------------
  // Filtros y secciones.
  // ---------------------------------------------------------------------------

  AssociateServiceCategory? _selectedCategory(
      List<AssociateServiceCategory> approved) {
    final id = _model.categoryId;
    if (id == null) return null;
    for (final category in approved) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Aplica los tres desplegables (más la búsqueda) sobre un conjunto de
  /// trabajos. Se corre por separado sobre cada sección con el mismo criterio:
  /// de ahí que un cambio de filtro actualice las dos a la vez.
  List<Map<String, dynamic>> _applyFilters(
    _Agenda agenda,
    Iterable<Map<String, dynamic>> jobs,
  ) {
    final category = _selectedCategory(agenda.categories.approved);
    return jobs
        .where((data) => associateRequestMatchesQuery(
            data, _model.searchQuery, agenda.categories.approved))
        .where((data) =>
            category == null || associateRequestMatchesCategory(data, category))
        .where((data) =>
            _model.urgentOnly == null ||
            asrIsEmergency(data) == _model.urgentOnly)
        .where((data) =>
            _model.monthKey == null || asrMonthKey(data) == _model.monthKey)
        .toList();
  }

  /// Ordena por fecha. Los aceptados se leen hacia adelante (lo más próximo
  /// primero, que es lo que hay que ir a hacer) y el historial hacia atrás (lo
  /// último que se terminó primero). Lo que no tiene fecha va al final en los
  /// dos casos.
  List<Map<String, dynamic>> _sortedByDate(
    List<Map<String, dynamic>> jobs, {
    required bool ascending,
  }) {
    final sorted = [...jobs];
    sorted.sort((a, b) {
      final da = asrFilterDate(a);
      final db = asrFilterDate(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return ascending ? da.compareTo(db) : db.compareTo(da);
    });
    return sorted;
  }

  /// Trabajos que el asociado ya aceptó pero todavía no ejecutó.
  List<Map<String, dynamic>> _acceptedJobs(_Agenda agenda) => _sortedByDate(
        _applyFilters(agenda, agenda.jobs.where((d) => !asrIsFinished(d))),
        ascending: true,
      );

  /// Trabajos que ya finalizó: su historial de servicios.
  List<Map<String, dynamic>> _finishedJobs(_Agenda agenda) => _sortedByDate(
        _applyFilters(agenda, agenda.jobs.where(asrIsFinished)),
        ascending: false,
      );

  // ---------------------------------------------------------------------------
  // Navegación.
  // ---------------------------------------------------------------------------

  /// Trabajo aceptado: sigue el flujo de tránsito / ejecución.
  void _openScheduledJob(Map<String, dynamic> data) {
    DHASSOCIATETuTrabajoWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETuTrabajoWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadAgenda));
  }

  /// Trabajo terminado: resumen en solo lectura —informe, evidencia enviada y
  /// feedback del cliente—.
  void _openFinishedJob(Map<String, dynamic> data) {
    DHASSOCIATETrabajoRealizadoWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoRealizadoWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadAgenda));
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return ListingHqSearchField(
      controller: _model.searchController,
      hintText: 'Buscar por servicio, zona o fecha',
      onChanged: (value) => safeSetState(() => _model.searchQuery = value),
      onClear: () => safeSetState(() {
        _model.searchController?.clear();
        _model.searchQuery = '';
      }),
    );
  }

  /// Tipo de Trabajo. **Sólo las especialidades aprobadas del asociado**: si es
  /// Plomero y Electricista, esas dos y nada más.
  Widget _buildCategoryFilter(AssociateCategories categories) {
    final approved = categories.approved;

    if (approved.isEmpty) {
      // Sin especialidades aprobadas no hay nada legítimo que ofrecer, y se
      // dice por qué en vez de dejar un desplegable vacío sin explicación.
      return AssociateJobFilterDropdown(
        label: 'Tipo de Trabajo',
        hintText: 'Sin especialidades aprobadas',
        controller: _model.categoryController ??=
            FormFieldController<String>(kAssociateFilterAll),
        options: const [kAssociateFilterAll],
        optionLabels: const ['Sin especialidades aprobadas'],
        onChanged: (_) {},
        disabled: true,
      );
    }

    return AssociateJobFilterDropdown(
      label: 'Tipo de Trabajo',
      hintText: 'Selecciona la especialidad',
      controller: _model.categoryController ??=
          FormFieldController<String>(kAssociateFilterAll),
      options: [kAssociateFilterAll, ...approved.map((c) => c.id)],
      optionLabels: ['Todas', ...approved.map((c) => c.label)],
      onChanged: (value) => safeSetState(() {
        _model.categoryId =
            (value == null || value == kAssociateFilterAll) ? null : value;
      }),
    );
  }

  /// Estado del trabajo: las tres opciones fijas del diseño.
  Widget _buildStatusFilter() {
    return AssociateJobFilterDropdown(
      label: 'Estado del trabajo',
      hintText: 'Selecciona el estado',
      controller: _model.statusController ??=
          FormFieldController<String>(kAssociateFilterAll),
      options: const [
        kAssociateFilterAll,
        kAssociateFilterUrgent,
        kAssociateFilterStandard,
      ],
      optionLabels: const ['Todo', 'Urgente', 'Estándar'],
      onChanged: (value) => safeSetState(() {
        _model.urgentOnly = switch (value) {
          kAssociateFilterUrgent => true,
          kAssociateFilterStandard => false,
          _ => null,
        };
      }),
    );
  }

  /// Fecha del trabajo, agrupada por mes.
  Widget _buildMonthFilter(List<AssociateMonthOption> months) {
    return AssociateJobFilterDropdown(
      label: 'Fecha del trabajo',
      hintText: 'Selecciona el mes',
      controller: _model.monthController ??=
          FormFieldController<String>(kAssociateFilterAll),
      options: [kAssociateFilterAll, ...months.map((m) => m.key)],
      optionLabels: ['Todos los meses', ...months.map((m) => m.label)],
      disabled: months.isEmpty,
      onChanged: (value) => safeSetState(() {
        _model.monthKey =
            (value == null || value == kAssociateFilterAll) ? null : value;
      }),
    );
  }

  /// Los tres desplegables. En el diseño de escritorio van en una fila de tres
  /// columnas; en mobile no entran tres campos legibles al lado del otro, así
  /// que se apilan —el mismo orden y el mismo alto de toque que en la bolsa de
  /// oportunidades.
  Widget _buildFilters(_Agenda agenda) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryFilter(agenda.categories),
        _buildStatusFilter(),
        _buildMonthFilter(associateMonthOptions(agenda.jobs)),
      ].divide(const SizedBox(height: 16.0)),
    );
  }

  Widget _buildMessage(String message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          message,
          style: GoogleFonts.inter(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 13.0,
          ),
        ),
      );

  Widget _buildSectionTitle(String title) =>
      Text(title, style: ListingHqUi.sectionTitle(context));

  /// Las tarjetas de una sección. La cuadrícula de tres columnas del diseño de
  /// escritorio es, en mobile, una sola columna a ancho de pantalla: la misma
  /// tarjeta y el mismo orden, apilados.
  /// Oficios aprobados, para mostrar el de cada trabajo en su tarjeta.
  List<AssociateServiceCategory> _approved = const [];

  Widget _buildCards(
    List<Map<String, dynamic>> jobs, {
    required void Function(Map<String, dynamic>) onViewDetail,
  }) {
    return Column(
      children: jobs
          .map(
            (data) => Padding(
              padding: const EdgeInsets.only(bottom: _cardGap),
              child: DHASSOCIATETrabajoCardWidget(
                title: associateRequestCardTitle(data, _approved),
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
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> jobs,
    required String emptyMessage,
    required void Function(Map<String, dynamic>) onViewDetail,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 14.0),
        if (jobs.isEmpty)
          _buildMessage(emptyMessage)
        else
          _buildCards(jobs, onViewDetail: onViewDetail),
      ],
    );
  }

  Widget _buildAgenda(_Agenda agenda) {
    _approved = agenda.categories.approved;
    if (agenda.jobsFailed) return _buildMessage(agenda.jobsErrorMessage);

    final accepted = _acceptedJobs(agenda);
    final finished = _finishedJobs(agenda);

    // "Sin resultados" y "todavía no tenés nada" son cosas distintas: la
    // primera se arregla soltando un filtro y la segunda no.
    final filtering = _model.searchQuery.trim().isNotEmpty ||
        _model.categoryId != null ||
        _model.urgentOnly != null ||
        _model.monthKey != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (agenda.jobsTruncated) ...[
          _buildMessage(
            'Estamos mostrando tus primeros $kDoviaHomeMaxItems '
            'trabajos. Puede que falte parte de tu historial.',
          ),
          const SizedBox(height: 8.0),
        ],
        if (!widget.onlyFinished) ...[
          _buildSection(
            title: 'Trabajos aceptados',
            jobs: accepted,
            emptyMessage: filtering
                ? 'No hay trabajos aceptados con estos filtros.'
                : 'Todavía no aceptaste ningún trabajo. Postulate a los que '
                    'están disponibles.',
            onViewDetail: _openScheduledJob,
          ),
          const SizedBox(height: 32.0),
        ],
        _buildSection(
          title: 'Trabajos terminados',
          jobs: finished,
          emptyMessage: filtering
              ? 'No hay trabajos terminados con estos filtros.'
              : 'Todavía no terminaste ningún trabajo.',
          onViewDetail: _openFinishedJob,
        ),
      ],
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
            // Lo que sube al scrollear no pasa por detrás de la hora y la
            // batería.
            StatusBarClip(
                child: SingleChildScrollView(
              // Espacio de la barra de navegación del sistema (sin SafeArea).
              padding:
                  EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dHASSOCIATEHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: DHASSOCIATEHeaderWidget(
                      tittleText: widget.onlyFinished
                          ? 'Trabajos terminados'
                          : 'Próximos trabajos',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
                    child: FutureBuilder<_Agenda>(
                      future: _agendaFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: DoviaSpinner()),
                          );
                        }
                        final agenda = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 20.0),
                            _buildFilters(agenda),
                            const SizedBox(height: 28.0),
                            _buildAgenda(agenda),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),
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
