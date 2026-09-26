import '/shared_components/status_bar_clip/status_bar_clip.dart';
import '/dovia_home_associate/associate_nav.dart';
import '/backend/api_requests/dovia_home_paginated_loader.dart';
import '/dovia_home_associate/associate_job_filters.dart';
import '/dovia_home_associate/associate_service_categories.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/associate_specialties_loader.dart';
import '/dovia_home_associate/company_quote_board.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizacion/d_h_a_s_s_o_c_i_a_t_e_cotizacion_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizacion_enviada_card/d_h_a_s_s_o_c_i_a_t_e_cotizacion_enviada_card_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_propuesta_enviada/d_h_a_s_s_o_c_i_a_t_e_propuesta_enviada_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar/d_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_cotizaciones_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_cotizaciones_model.dart';

/// Valores del filtro "Estado del trabajo", uno por carril del ciclo de venta.
const String kQuoteFilterActive = 'ACTIVE';
const String kQuoteFilterSubmitted = 'SUBMITTED';
const String kQuoteFilterApproved = 'APPROVED';
const String kQuoteFilterRejected = 'REJECTED';

/// Historial completo de cotizaciones de la empresa. Se abre desde el "Ver más"
/// de la sección Cotizaciones del panel.
///
/// Sale del mismo [loadCompanyQuoteBoard] que el panel —para que las dos
/// pantallas no puedan discrepar—, pero sin el recorte a las primeras tarjetas y
/// con el ciclo de venta completo: al pipeline vivo se le suma el carril de
/// **rechazadas**, que es historial y en el panel no tiene lugar.
///
/// Los tres desplegables son **la única herramienta de navegación** de esta
/// pantalla: no hay barra de búsqueda por texto. Filtrar por rubro, estado y mes
/// es lo que ordena el trabajo; escribir un nombre no ayuda a revisar un
/// pipeline que se mira por bloques.
///
///   - **Tipo de Trabajo**: sólo las especialidades habilitadas de la empresa.
///   - **Estado del trabajo**: uno de los carriles, o todos.
///   - **Fecha del trabajo**: agrupación por mes de la visita pedida.
///
/// Los tres combinan y filtran del lado del cliente sobre lo ya cargado: el
/// marketplace no acepta estos parámetros y, sobre todo, el reparto en carriles
/// ya se resuelve cruzando propuestas contra solicitudes, así que volver al
/// servidor por cada desplegable no ganaría nada.
class DHASSOCIATECotizacionesWidget extends StatefulWidget {
  const DHASSOCIATECotizacionesWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_Cotizaciones';
  static String routePath = '/dHASSOCIATECotizaciones';

  @override
  State<DHASSOCIATECotizacionesWidget> createState() =>
      _DHASSOCIATECotizacionesWidgetState();
}

class _DHASSOCIATECotizacionesWidgetState
    extends State<DHASSOCIATECotizacionesWidget> {
  late DHASSOCIATECotizacionesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<CompanyQuoteBoard> _boardFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATECotizacionesModel());

    _loadBoard();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _loadBoard() {
    _boardFuture =
        loadCompanyQuoteBoard(authToken: currentAuthenticationToken ?? '')
            .then((board) {
      _reconcileFilters(board);
      return board;
    });
  }

  /// Suelta los filtros que dejaron de existir después de recargar — el último
  /// pedido de "Agosto 2026" se lo llevó otra empresa, o le revocaron un rubro.
  ///
  /// El desplegable solo ya se defiende (ignora un valor que no esté entre sus
  /// opciones y vuelve al placeholder), pero el filtro seguiría aplicado: la
  /// empresa vería la lista vacía y un desplegable que dice que no está
  /// filtrando nada.
  void _reconcileFilters(CompanyQuoteBoard board) {
    final months =
        associateMonthOptions(_datedRequests(board)).map((m) => m.key).toSet();
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

  /// Todas las solicitudes del historial, **sin** los filtros de la UI
  /// aplicados: de acá salen las opciones del desplegable de fecha, que no deben
  /// cambiar según lo que la empresa tenga filtrado.
  List<Map<String, dynamic>> _datedRequests(CompanyQuoteBoard board) => [
        ...board.active,
        ...board.approved,
        for (final submission in [...board.submitted, ...board.rejected])
          if (submission.request != null) submission.request!,
      ];

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

  bool _matchesRequest(
    Map<String, dynamic> request,
    AssociateServiceCategory? category,
  ) {
    if (category != null &&
        !associateRequestMatchesCategory(request, category)) {
      return false;
    }
    if (_model.monthKey != null && asrMonthKey(request) != _model.monthKey) {
      return false;
    }
    return true;
  }

  List<Map<String, dynamic>> _filterRequests(
    List<Map<String, dynamic>> requests,
    AssociateServiceCategory? category,
  ) =>
      requests.where((r) => _matchesRequest(r, category)).toList();

  /// Una propuesta se filtra por la solicitud que cotiza. Sin ella —cotización
  /// ya cerrada por el cliente— no hay rubro ni fecha que evaluar: con cualquiera
  /// de los dos filtros elegidos queda fuera, porque no se puede afirmar que
  /// corresponda. Sin filtros se muestra igual: es parte de su historial.
  List<CompanyQuoteSubmission> _filterSubmissions(
    List<CompanyQuoteSubmission> submissions,
    AssociateServiceCategory? category,
  ) {
    return submissions.where((submission) {
      final request = submission.request;
      if (request != null) return _matchesRequest(request, category);
      return category == null && _model.monthKey == null;
    }).toList();
  }

  bool _showsLane(String lane) =>
      _model.statusFilter == null || _model.statusFilter == lane;

  // ---------------------------------------------------------------------------
  // Navegación: el [Ver trabajo] de la tarjeta lleva a un lugar distinto según
  // el estado, porque en cada uno lo que sigue es otra cosa.
  // ---------------------------------------------------------------------------

  /// Activa: todavía no presupuestó. Abre el requerimiento del cliente, que es
  /// donde arma y envía la propuesta económica.
  void _openOpportunity(Map<String, dynamic> data) {
    DHASSOCIATECotizacionWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATECotizacionWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadBoard));
  }

  /// Enviada: la misma pantalla de la cotización, en Estado 2 (sólo lectura +
  /// banner de espera) — no hay nada que operar hasta que el cliente decida,
  /// pero sí algo que releer.
  void _openSubmittedQuote(CompanyQuoteSubmission submission) {
    DHASSOCIATECotizacionWidget.requestData = submission.request;
    DHASSOCIATECotizacionWidget.proposalData = submission.proposal;
    context
        .pushNamed(DHASSOCIATECotizacionWidget.routeName,
            queryParameters: associateRouteParams(
                request: submission.request, proposal: submission.proposal))
        .then((_) => safeSetState(_loadBoard));
  }

  /// Rechazada: la decisión ya se tomó y no hay estado dinámico que mostrar,
  /// así que queda en su propia vista de sólo lectura.
  void _openRejectedQuote(CompanyQuoteSubmission submission) {
    DHASSOCIATEPropuestaEnviadaWidget.proposalData = submission.proposal;
    DHASSOCIATEPropuestaEnviadaWidget.requestData = submission.request;
    context
        .pushNamed(DHASSOCIATEPropuestaEnviadaWidget.routeName,
            queryParameters: associateRouteParams(
                request: submission.request, proposal: submission.proposal))
        .then((_) => safeSetState(_loadBoard));
  }

  /// Aprobada: es un proyecto ganado y entra al flujo operativo estándar
  /// (notificar tránsito, iniciar el trabajo, cerrarlo), el mismo del perfil
  /// Independiente.
  void _openWonProject(Map<String, dynamic> data) {
    DHASSOCIATETrabajoARealizarWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadBoard));
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  /// Rubro. **Sólo las especialidades habilitadas de la empresa**: no tiene
  /// sentido ofrecerle filtrar por un rubro en el que no puede operar.
  Widget _buildCategoryFilter(AssociateCategories categories) {
    final approved = categories.approved;

    if (approved.isEmpty) {
      return AssociateJobFilterDropdown(
        label: 'Tipo de Trabajo',
        hintText: 'Sin rubros habilitados',
        controller: _model.categoryController ??=
            FormFieldController<String>(kAssociateFilterAll),
        options: const [kAssociateFilterAll],
        optionLabels: const ['Sin rubros habilitados'],
        onChanged: (_) {},
        disabled: true,
      );
    }

    return AssociateJobFilterDropdown(
      label: 'Tipo de Trabajo',
      hintText: 'Selecciona el tipo de trabajo',
      controller: _model.categoryController ??=
          FormFieldController<String>(kAssociateFilterAll),
      options: [kAssociateFilterAll, ...approved.map((c) => c.id)],
      optionLabels: ['Todos', ...approved.map((c) => c.label)],
      onChanged: (value) => safeSetState(() {
        _model.categoryId =
            (value == null || value == kAssociateFilterAll) ? null : value;
      }),
    );
  }

  /// Estado: los cuatro momentos del ciclo de venta.
  Widget _buildStatusFilter() {
    return AssociateJobFilterDropdown(
      label: 'Estado del trabajo',
      hintText: 'Selecciona el estado',
      controller: _model.statusController ??=
          FormFieldController<String>(kAssociateFilterAll),
      options: const [
        kAssociateFilterAll,
        kQuoteFilterActive,
        kQuoteFilterSubmitted,
        kQuoteFilterApproved,
        kQuoteFilterRejected,
      ],
      optionLabels: const [
        'Todas',
        'Activas',
        'Enviadas',
        'Aprobadas',
        'Rechazadas',
      ],
      onChanged: (value) => safeSetState(() {
        _model.statusFilter =
            (value == null || value == kAssociateFilterAll) ? null : value;
      }),
    );
  }

  Widget _buildMonthFilter(List<AssociateMonthOption> months) {
    return AssociateJobFilterDropdown(
      label: 'Fecha del trabajo',
      hintText: 'Selecciona la fecha',
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

  /// Título del bloque de cada estado. El diseño no los lleva —muestra una
  /// grilla pareja de tarjetas— pero con el filtro en "Todas" son lo único que
  /// dice en qué punto del ciclo está cada tarjeta, y la tarjeta sólo tiene
  /// lugar para el nombre del trabajo.
  Widget _buildLaneTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Text(
          title,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 17.0,
                letterSpacing: 0.34,
              ),
        ),
      );

  Widget _buildCard({
    required String title,
    required String iconPath,
    required VoidCallback onViewWork,
    String? subtitle,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: DHASSOCIATECotizacionEnviadaCardWidget(
          title: title,
          iconPath: iconPath,
          subtitle: subtitle,
          onViewWork: onViewWork,
        ),
      );

  /// Carril de solicitudes (activas y aprobadas). Sólo cambia a dónde lleva el
  /// [Ver trabajo].
  Widget _buildRequestLane({
    required List<Map<String, dynamic>> requests,
    required bool failed,
    required int? errorStatus,
    required void Function(Map<String, dynamic>) onViewWork,
    required String emptyMessage,
  }) {
    if (failed) {
      return _buildMessage(CompanyQuoteBoard.errorMessage(errorStatus));
    }
    if (requests.isEmpty) return _buildMessage(emptyMessage);

    return Column(
      children: [
        for (final data in requests)
          _buildCard(
            title: associateRequestTitle(data, _trades),
            iconPath: associateRequestIcon(data, _trades),
            onViewWork: () => onViewWork(data),
          ),
      ],
    );
  }

  /// Carril de propuestas (enviadas y rechazadas). Comparten tarjeta; a dónde
  /// lleva el [Ver trabajo] lo decide quien llama, porque una releé el
  /// presupuesto en su pantalla dinámica y la otra en la vista fija de
  /// rechazadas.
  Widget _buildSubmissionLane({
    required CompanyQuoteBoard board,
    required List<CompanyQuoteSubmission> submissions,
    required String emptyMessage,
    required void Function(CompanyQuoteSubmission) onViewWork,
    String? subtitle,
  }) {
    if (board.proposalsFailed) {
      return _buildMessage(
          CompanyQuoteBoard.errorMessage(board.proposalsErrorStatus));
    }
    if (submissions.isEmpty) return _buildMessage(emptyMessage);

    return Column(
      children: [
        for (final submission in submissions)
          _buildCard(
            title: associateSubmittedTitle(submission.request == null
                ? submission.title
                : associateRequestTitle(submission.request!, _trades)),
            subtitle: subtitle,
            iconPath: submission.request == null
                ? associateCategoryIcon(null, submission.title)
                : associateRequestIcon(submission.request!, _trades),
            onViewWork: () => onViewWork(submission),
          ),
      ],
    );
  }

  /// Oficios aprobados de la empresa, para titular e iconizar cada
  /// cotización con su oficio en vez del genérico "Servicio por cotizar".
  List<AssociateServiceCategory> _trades = const [];

  Widget _buildResults(CompanyQuoteBoard board) {
    _trades = board.categories.approved;
    final category = _selectedCategory(board.categories.approved);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (board.truncated) ...[
          _buildMessage(
            'Estamos mostrando las primeras $kDoviaHomeMaxItems cotizaciones. '
            'Puede que haya más en tu historial.',
          ),
          const SizedBox(height: 8.0),
        ],
        if (_showsLane(kQuoteFilterActive)) ...[
          _buildLaneTitle('Cotizaciones activas:'),
          _buildRequestLane(
            requests: _filterRequests(board.active, category),
            failed: board.marketplaceFailed,
            errorStatus: board.marketplaceErrorStatus,
            onViewWork: _openOpportunity,
            emptyMessage: 'No hay oportunidades abiertas con estos filtros.',
          ),
          const SizedBox(height: 24.0),
        ],
        if (_showsLane(kQuoteFilterSubmitted)) ...[
          _buildLaneTitle('Cotizaciones enviadas:'),
          _buildSubmissionLane(
            board: board,
            submissions: _filterSubmissions(board.submitted, category),
            emptyMessage: 'No hay presupuestos enviados con estos filtros.',
            onViewWork: _openSubmittedQuote,
            subtitle: 'Aguardando respuesta del cliente',
          ),
          const SizedBox(height: 24.0),
        ],
        if (_showsLane(kQuoteFilterApproved)) ...[
          _buildLaneTitle('Cotizaciones aprobadas:'),
          _buildRequestLane(
            requests: _filterRequests(board.approved, category),
            failed: board.approvedFailed,
            errorStatus: board.approvedErrorStatus,
            onViewWork: _openWonProject,
            emptyMessage: 'No hay proyectos ganados con estos filtros.',
          ),
          const SizedBox(height: 24.0),
        ],
        if (_showsLane(kQuoteFilterRejected)) ...[
          _buildLaneTitle('Cotizaciones rechazadas:'),
          _buildSubmissionLane(
            board: board,
            submissions: _filterSubmissions(board.rejected, category),
            emptyMessage: 'No hay cotizaciones rechazadas con estos filtros.',
            onViewWork: _openRejectedQuote,
            subtitle: 'El cliente rechazó el presupuesto',
          ),
        ],
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
                      tittleText: 'Cotizaciones',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
                    child: FutureBuilder<CompanyQuoteBoard>(
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
                            _buildCategoryFilter(board.categories),
                            const SizedBox(height: 16.0),
                            _buildStatusFilter(),
                            const SizedBox(height: 16.0),
                            _buildMonthFilter(
                                associateMonthOptions(_datedRequests(board))),
                            const SizedBox(height: 24.0),
                            _buildResults(board),
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
