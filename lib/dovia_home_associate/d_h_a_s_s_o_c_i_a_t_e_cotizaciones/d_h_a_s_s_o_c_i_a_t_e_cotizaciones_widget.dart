import '/backend/api_requests/dovia_home_paginated_loader.dart';
import '/dovia_home_associate/associate_job_filters.dart';
import '/dovia_home_associate/associate_service_categories.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/associate_specialties_loader.dart';
import '/dovia_home_associate/company_quote_board.dart';
import '/dovia_home_associate/company_quote_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizacion/d_h_a_s_s_o_c_i_a_t_e_cotizacion_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizacion_enviada_card/d_h_a_s_s_o_c_i_a_t_e_cotizacion_enviada_card_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar/d_h_a_s_s_o_c_i_a_t_e_trabajo_a_realizar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_card/d_h_a_s_s_o_c_i_a_t_e_trabajo_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_cotizaciones_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_cotizaciones_model.dart';

/// Valores del filtro "Estatus", uno por carril del pipeline.
const String kQuoteFilterActive = 'ACTIVE';
const String kQuoteFilterSubmitted = 'SUBMITTED';
const String kQuoteFilterApproved = 'APPROVED';

/// Historial completo de cotizaciones de la empresa. Se abre desde el "Ver más"
/// de la sección Cotizaciones del panel.
///
/// Muestra los **mismos tres carriles** que el panel —sale del mismo
/// [loadCompanyQuoteBoard], para que las dos pantallas no puedan discrepar— pero
/// sin el recorte a las primeras tarjetas y con los tres filtros del diseño:
///
///   - **Rubro**: sólo las especialidades habilitadas de la empresa.
///   - **Estatus**: uno de los carriles, o los tres.
///   - **Mes**: agrupa por mes de la visita pedida, para revisar el pipeline
///     hacia atrás y hacia adelante.
///
/// Los tres filtran del lado del cliente sobre lo ya cargado: el marketplace no
/// acepta estos parámetros y, sobre todo, el reparto en carriles ya se resuelve
/// cruzando propuestas contra solicitudes, así que volver al servidor por cada
/// desplegable no ganaría nada.
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
    final months = associateMonthOptions(_datedRequests(board))
        .map((m) => m.key)
        .toSet();
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

  /// Todas las solicitudes del pipeline, **sin** los filtros de la UI aplicados:
  /// de acá salen las opciones del desplegable de mes, que no deben cambiar
  /// según lo que la empresa tenga filtrado.
  List<Map<String, dynamic>> _datedRequests(CompanyQuoteBoard board) => [
        ...board.active,
        ...board.approved,
        for (final submission in board.submitted)
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
    if (!asrMatchesQuery(request, _model.searchQuery)) return false;
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

  /// Una propuesta enviada se filtra por la solicitud que cotiza. Sin ella
  /// —cotización ya cerrada por el cliente— sólo se puede evaluar el texto: con
  /// rubro o mes elegidos queda fuera, porque no hay con qué afirmar que
  /// corresponde al filtro.
  List<CompanyQuoteSubmission> _filterSubmissions(
    List<CompanyQuoteSubmission> submissions,
    AssociateServiceCategory? category,
  ) {
    return submissions.where((submission) {
      final request = submission.request;
      if (request != null) return _matchesRequest(request, category);
      if (category != null || _model.monthKey != null) return false;
      final query = _model.searchQuery.trim().toLowerCase();
      return query.isEmpty || submission.title.toLowerCase().contains(query);
    }).toList();
  }

  bool _showsLane(String lane) =>
      _model.statusFilter == null || _model.statusFilter == lane;

  // ---------------------------------------------------------------------------
  // Navegación.
  // ---------------------------------------------------------------------------

  void _openOpportunity(Map<String, dynamic> data) {
    DHASSOCIATECotizacionWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATECotizacionWidget.routeName)
        .then((_) => safeSetState(_loadBoard));
  }

  void _openWonProject(Map<String, dynamic> data) {
    DHASSOCIATETrabajoARealizarWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName)
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

  /// Rubro. **Sólo las especialidades habilitadas de la empresa**: no tiene
  /// sentido ofrecerle filtrar por un rubro en el que no puede operar.
  Widget _buildCategoryFilter(AssociateCategories categories) {
    final approved = categories.approved;

    if (approved.isEmpty) {
      return AssociateJobFilterDropdown(
        label: 'Rubro',
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
      label: 'Rubro',
      hintText: 'Selecciona el rubro',
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

  /// Estatus: los tres carriles del pipeline.
  Widget _buildStatusFilter() {
    return AssociateJobFilterDropdown(
      label: 'Estatus',
      hintText: 'Selecciona el estatus',
      controller: _model.statusController ??=
          FormFieldController<String>(kAssociateFilterAll),
      options: const [
        kAssociateFilterAll,
        kQuoteFilterActive,
        kQuoteFilterSubmitted,
        kQuoteFilterApproved,
      ],
      optionLabels: const ['Todas', 'Activas', 'Enviadas', 'Aprobadas'],
      onChanged: (value) => safeSetState(() {
        _model.statusFilter =
            (value == null || value == kAssociateFilterAll) ? null : value;
      }),
    );
  }

  Widget _buildMonthFilter(List<AssociateMonthOption> months) {
    return AssociateJobFilterDropdown(
      label: 'Mes',
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

  Widget _buildRequestLane({
    required List<Map<String, dynamic>> requests,
    required bool failed,
    required int? errorStatus,
    required void Function(Map<String, dynamic>) onViewDetail,
    required String emptyMessage,
  }) {
    if (failed) {
      return _buildMessage(CompanyQuoteBoard.errorMessage(errorStatus));
    }
    if (requests.isEmpty) return _buildMessage(emptyMessage);

    return Column(
      children: requests
          .map(
            (data) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: DHASSOCIATETrabajoCardWidget(
                title: asrServiceName(data),
                addressLabel: asrZoneLabel(data),
                dateLabel: asrFormattedDate(data),
                timeLabel: asrTimeLabel(data),
                payoutLabel: cqEarningsLabel(data),
                onViewDetail: () => onViewDetail(data),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSubmittedLane(
    CompanyQuoteBoard board,
    List<CompanyQuoteSubmission> submissions,
  ) {
    if (board.proposalsFailed) {
      return _buildMessage(
          CompanyQuoteBoard.errorMessage(board.proposalsErrorStatus));
    }
    if (submissions.isEmpty) {
      return _buildMessage('No hay presupuestos enviados con estos filtros.');
    }

    return Column(
      children: submissions
          .map(
            (submission) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: DHASSOCIATECotizacionEnviadaCardWidget(
                title: submission.title,
                iconPath: submission.request == null
                    ? associateCategoryIcon(null, submission.title)
                    : associateCategoryIcon(
                        asrServiceCode(submission.request!),
                        asrServiceName(submission.request!),
                      ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBoard(CompanyQuoteBoard board) {
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
            onViewDetail: _openOpportunity,
            emptyMessage: 'No hay oportunidades abiertas con estos filtros.',
          ),
          const SizedBox(height: 24.0),
        ],
        if (_showsLane(kQuoteFilterSubmitted)) ...[
          _buildLaneTitle('Cotizaciones enviadas:'),
          _buildSubmittedLane(
              board, _filterSubmissions(board.submitted, category)),
          const SizedBox(height: 24.0),
        ],
        if (_showsLane(kQuoteFilterApproved)) ...[
          _buildLaneTitle('Cotizaciones aprobadas:'),
          _buildRequestLane(
            requests: _filterRequests(board.approved, category),
            failed: board.approvedFailed,
            errorStatus: board.approvedErrorStatus,
            onViewDetail: _openWonProject,
            emptyMessage: 'No hay proyectos ganados con estos filtros.',
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
            SingleChildScrollView(
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
                            _buildSearchBar(),
                            const SizedBox(height: 20.0),
                            _buildCategoryFilter(board.categories),
                            const SizedBox(height: 16.0),
                            _buildStatusFilter(),
                            const SizedBox(height: 16.0),
                            _buildMonthFilter(
                                associateMonthOptions(_datedRequests(board))),
                            const SizedBox(height: 24.0),
                            _buildBoard(board),
                          ],
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
