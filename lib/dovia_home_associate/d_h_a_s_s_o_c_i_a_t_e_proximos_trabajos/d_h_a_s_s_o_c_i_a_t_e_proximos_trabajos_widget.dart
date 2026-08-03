import '/dovia_home_associate/associate_job_filters.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_proximos_trabajos_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_proximos_trabajos_model.dart';

/// Agenda completa del asociado. Se abre desde el "Ver más" de la sección
/// "Próximos trabajos" del panel.
///
/// Son compromisos ya adquiridos, partidos en las dos secciones del diseño:
///   - **Trabajos aceptados**: los que ya tomó y todavía no ejecutó. El ícono de
///     "Ojo" abre el flujo de tránsito/ejecución ([DHASSOCIATETuTrabajoWidget]).
///   - **Trabajos terminados**: su historial. Ahí el "Ojo" abre el registro del
///     trabajo en **solo lectura** ([DHASSOCIATETrabajoFinalizadoWidget], que se
///     pone inerte cuando la solicitud ya está FINISHED).
///
/// Los tres filtros son los mismos de la bolsa de oportunidades y aplican a las
/// **dos secciones a la vez**, como pide el diseño: cambiar un desplegable
/// actualiza aceptados y terminados en la misma pasada.
class DHASSOCIATEProximosTrabajosWidget extends StatefulWidget {
  const DHASSOCIATEProximosTrabajosWidget({super.key});

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
  });

  final AssociateCategories categories;

  /// Agenda completa —aceptados y terminados juntos—, **sin** los filtros de la
  /// UI aplicados: de acá salen las opciones del desplegable de mes, que no
  /// deben cambiar según lo que el asociado tenga filtrado.
  final List<Map<String, dynamic>> jobs;

  final int? jobsErrorStatus;

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

  /// Ancho de tarjeta del diseño de escritorio.
  static const double _cardWidth = 285.0;
  static const double _gridGap = 14.0;

  /// A partir de acá entran al menos dos columnas de tarjetas y la fila de
  /// filtros del diseño; por debajo se apila todo.
  static const double _wideBreakpoint = 700.0;

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
    final jobsRequest =
        DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall.call(
      authToken: token,
      limit: 50,
    );

    final categories = await categoriesRequest;
    final jobsResponse = await jobsRequest;

    if (!jobsResponse.succeeded) {
      return _Agenda(
        categories: categories,
        jobs: const [],
        jobsErrorStatus: jobsResponse.statusCode,
      );
    }

    final raw = DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall
            .requestsList(jobsResponse.jsonBody) ??
        const [];

    final agenda = _Agenda(
      categories: categories,
      jobs: raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          // Perfil Independiente: sin cotizaciones ni trabajos fuera de alcance.
          .where(asrIsWorkableByIndependent)
          .toList(),
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
        .where((data) => asrMatchesQuery(data, _model.searchQuery))
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
        .pushNamed(DHASSOCIATETuTrabajoWidget.routeName)
        .then((_) => safeSetState(_loadAgenda));
  }

  /// Trabajo terminado: registro en solo lectura. La pantalla se pone inerte
  /// sola al ver que la solicitud está FINISHED.
  void _openFinishedJob(Map<String, dynamic> data) {
    DHASSOCIATETrabajoFinalizadoWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoFinalizadoWidget.routeName)
        .then((_) => safeSetState(_loadAgenda));
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
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
        padding: const EdgeInsetsDirectional.fromSTEB(18.0, 4.0, 18.0, 4.0),
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
          ],
        ),
      ),
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

  /// Los tres desplegables. En escritorio van en fila como el diseño; en mobile
  /// no entran tres columnas legibles, así que se apilan.
  Widget _buildFilters(_Agenda agenda, double maxWidth) {
    final filters = [
      _buildCategoryFilter(agenda.categories),
      _buildStatusFilter(),
      _buildMonthFilter(associateMonthOptions(agenda.jobs)),
    ];

    if (maxWidth < _wideBreakpoint) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filters.divide(const SizedBox(height: 16.0)),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filters
          .map<Widget>((filter) => Expanded(child: filter))
          .toList()
          .divide(const SizedBox(width: 24.0)),
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

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 17.0,
              letterSpacing: 0.34,
            ),
      );

  /// Cuadrícula de tarjetas. En escritorio se acomodan tantas columnas de
  /// ~285px como entren; en mobile queda una sola, que es la misma cuadrícula
  /// con una columna.
  Widget _buildGrid(
    List<Map<String, dynamic>> jobs,
    double maxWidth, {
    required void Function(Map<String, dynamic>) onViewDetail,
  }) {
    Widget card(Map<String, dynamic> data) => DHASSOCIATETrabajoCardWidget(
          title: asrServiceName(data),
          addressLabel: asrZoneLabel(data),
          dateLabel: asrFormattedDate(data),
          timeLabel: asrTimeLabel(data),
          payoutLabel: asrPayoutLabel(data),
          priorityLabel: asrPriorityLabel(data),
          isUrgent: asrIsEmergency(data),
          onViewDetail: () => onViewDetail(data),
        );

    if (maxWidth < _wideBreakpoint) {
      return Column(
        children: jobs
            .map((data) => Padding(
                  padding: const EdgeInsets.only(bottom: _gridGap),
                  child: card(data),
                ))
            .toList(),
      );
    }

    final columns =
        ((maxWidth + _gridGap) / (_cardWidth + _gridGap)).floor().clamp(1, 4);
    final columnWidth = (maxWidth - _gridGap * (columns - 1)) / columns;

    return Wrap(
      spacing: _gridGap,
      runSpacing: _gridGap,
      children: jobs
          .map((data) => SizedBox(width: columnWidth, child: card(data)))
          .toList(),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> jobs,
    required String emptyMessage,
    required double maxWidth,
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
          _buildGrid(jobs, maxWidth, onViewDetail: onViewDetail),
      ],
    );
  }

  Widget _buildAgenda(_Agenda agenda, double maxWidth) {
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
        _buildSection(
          title: 'Trabajos aceptados',
          jobs: accepted,
          maxWidth: maxWidth,
          emptyMessage: filtering
              ? 'No hay trabajos aceptados con estos filtros.'
              : 'Todavía no aceptaste ningún trabajo. Postulate a los que '
                  'están disponibles.',
          onViewDetail: _openScheduledJob,
        ),
        const SizedBox(height: 32.0),
        _buildSection(
          title: 'Trabajos terminados',
          jobs: finished,
          maxWidth: maxWidth,
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
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dHASSOCIATEHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHASSOCIATEHeaderWidget(
                      tittleText: 'Próximos trabajos',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;

                        return FutureBuilder<_Agenda>(
                          future: _agendaFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final agenda = snapshot.data!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSearchBar(),
                                const SizedBox(height: 20.0),
                                _buildFilters(agenda, maxWidth),
                                const SizedBox(height: 28.0),
                                _buildAgenda(agenda, maxWidth),
                              ],
                            );
                          },
                        );
                      },
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
