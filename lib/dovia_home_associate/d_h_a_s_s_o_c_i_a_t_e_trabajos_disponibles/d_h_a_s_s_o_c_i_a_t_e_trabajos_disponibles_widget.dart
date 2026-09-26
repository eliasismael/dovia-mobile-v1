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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_trabajos_disponibles_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_trabajos_disponibles_model.dart';

/// Bolsa completa de oportunidades del asociado. Se abre desde el "Ver más" de
/// la sección "Trabajos disponibles" del panel.
///
/// Lista las solicitudes pagadas que todavía no tomó ningún técnico. Igual que
/// en el panel, la dirección exacta se mantiene oculta (sólo zona) hasta que el
/// asociado acepta el trabajo, y el monto es el neto que va a cobrar.
///
/// Tres filtros, con la lógica que pide el diseño:
///   - **Tipo de Trabajo**: se puebla *sólo* con las especialidades aprobadas
///     del asociado, no con el catálogo entero de DOVIA.
///   - **Estado del trabajo**: Todo / Urgente (emergencias) / Estándar.
///   - **Fecha del trabajo**: agrupa por mes, para planificar a mediano plazo.
///
/// Los tres filtran del lado del cliente sobre la misma respuesta del
/// marketplace: el endpoint no acepta estos parámetros, y pedir de vuelta al
/// servidor por cada cambio de desplegable haría parpadear la lista sin ganar
/// nada.
class DHASSOCIATETrabajosDisponiblesWidget extends StatefulWidget {
  const DHASSOCIATETrabajosDisponiblesWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_TrabajosDisponibles';
  static String routePath = '/dHASSOCIATETrabajosDisponibles';

  @override
  State<DHASSOCIATETrabajosDisponiblesWidget> createState() =>
      _DHASSOCIATETrabajosDisponiblesWidgetState();
}

/// Todo lo que la pantalla necesita resuelto: las especialidades que pueblan el
/// filtro de tipo y la bolsa de trabajos.
class _Board {
  const _Board({
    required this.categories,
    required this.jobs,
    this.jobsErrorStatus,
    this.jobsTruncated = false,
  });

  final AssociateCategories categories;

  /// Solicitudes que este perfil puede trabajar, **sin** los filtros de la UI
  /// aplicados: de acá salen también las opciones del desplegable de mes, que
  /// no deben cambiar según lo que el asociado tenga filtrado.
  final List<Map<String, dynamic>> jobs;

  final int? jobsErrorStatus;

  /// La bolsa no entró entera en el tope de páginas. Se avisa en pantalla en
  /// vez de recortar en silencio.
  final bool jobsTruncated;

  bool get jobsFailed => jobsErrorStatus != null;

  String get jobsErrorMessage => jobsErrorStatus == 403
      ? 'Tu perfil no tiene permisos para ver la bolsa de trabajos. '
          'Contactá al equipo de DOVIA.'
      : 'No pudimos cargar los trabajos disponibles. Intentá de nuevo en un '
          'momento.';
}

class _DHASSOCIATETrabajosDisponiblesWidgetState
    extends State<DHASSOCIATETrabajosDisponiblesWidget> {
  late DHASSOCIATETrabajosDisponiblesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<_Board> _boardFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATETrabajosDisponiblesModel());

    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    _loadBoard();

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

  void _loadBoard() {
    _boardFuture = _fetchBoard();
  }

  /// Especialidades y bolsa de trabajos en paralelo: las dos llamadas arrancan
  /// antes del primer `await`.
  Future<_Board> _fetchBoard() async {
    final token = currentAuthenticationToken ?? '';

    final categoriesRequest = loadAssociateCategories(authToken: token);
    // Se pagina hasta el final: los filtros corren client-side sobre lo que se
    // trajo, así que con una sola página filtrar por mes u oficio daría un
    // resultado que parece completo y no lo es.
    final call =
        DOVIAAPIDoviaHomeContextGroup.listAvailableAssociateServiceRequestsCall;
    final jobsRequest = loadAllDoviaHomePages(
      fetchPage: (page, limit) =>
          call.call(authToken: token, page: page, limit: limit),
      extractList: call.requestsList,
      keep: (data) =>
          // Perfil Independiente: sin cotizaciones ni trabajos fuera de alcance.
          asrIsWorkableByIndependent(data) &&
          // Y sólo lo que nadie tomó: `status` es un filtro opcional del
          // endpoint y TAKEN es uno de sus valores válidos.
          asrIsTakeable(data),
    );

    final categories = await categoriesRequest;
    final jobs = await jobsRequest;

    if (jobs.failed) {
      return _Board(
        categories: categories,
        jobs: const [],
        jobsErrorStatus: jobs.errorStatus,
      );
    }

    final board = _Board(
      categories: categories,
      jobs: jobs.items,
      jobsTruncated: jobs.truncated,
    );
    _reconcileFilters(board);
    return board;
  }

  /// Suelta los filtros que dejaron de existir después de recargar — el último
  /// trabajo de "Agosto 2026" se lo llevó otro asociado, o le revocaron una
  /// especialidad.
  ///
  /// El desplegable solo ya se defiende (ignora un valor que no esté entre sus
  /// opciones y vuelve al placeholder), pero el filtro seguiría aplicado: el
  /// asociado vería la bolsa vacía y un desplegable que dice que no está
  /// filtrando nada. Se corre fuera del build, al resolver la carga.
  void _reconcileFilters(_Board board) {
    final months = associateMonthOptions(board.jobs).map((m) => m.key).toSet();
    if (_model.monthKey != null && !months.contains(_model.monthKey)) {
      _model.monthKey = null;
      _model.monthController?.value = kAssociateFilterAll;
    }

    final approved = board.categories.approved.map((c) => c.id).toSet();
    if (_model.categoryId != null && !approved.contains(_model.categoryId)) {
      _model.categoryId = null;
      _model.categoryController?.value = kAssociateFilterAll;
    }
  }

  // ---------------------------------------------------------------------------
  // Filtros.
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

  List<Map<String, dynamic>> _applyFilters(_Board board) {
    final category = _selectedCategory(board.categories.approved);
    return board.jobs
        .where((data) => associateRequestMatchesQuery(
            data, _model.searchQuery, board.categories.approved))
        .where((data) =>
            category == null || associateRequestMatchesCategory(data, category))
        .where((data) =>
            _model.urgentOnly == null ||
            asrIsEmergency(data) == _model.urgentOnly)
        .where((data) =>
            _model.monthKey == null || asrMonthKey(data) == _model.monthKey)
        .toList();
  }

  void _openOpportunity(Map<String, dynamic> data) {
    DHASSOCIATETrabajoARealizarWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadBoard));
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

  Widget _buildBoard(_Board board) {
    if (board.jobsFailed) return _buildMessage(board.jobsErrorMessage);

    final jobs = _applyFilters(board);
    if (jobs.isEmpty) {
      return _buildMessage(board.jobs.isEmpty
          ? 'Por ahora no hay trabajos disponibles en tu zona.'
          : 'No hay trabajos disponibles con estos filtros.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (board.jobsTruncated) ...[
          _buildMessage(
            'Estamos mostrando las primeras $kDoviaHomeMaxItems '
            'oportunidades. Puede que haya más trabajos disponibles.',
          ),
          const SizedBox(height: 8.0),
        ],
        ...jobs.map(
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
              onViewDetail: () => _openOpportunity(data),
            ),
          ),
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
                    child: const DHASSOCIATEHeaderWidget(
                      tittleText: 'Trabajos disponibles',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
                    child: FutureBuilder<_Board>(
                      future: _boardFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final board = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 20.0),
                            _buildCategoryFilter(board.categories),
                            const SizedBox(height: 16.0),
                            _buildStatusFilter(),
                            const SizedBox(height: 16.0),
                            _buildMonthFilter(
                                associateMonthOptions(board.jobs)),
                            const SizedBox(height: 24.0),
                            _buildBoard(board),
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
