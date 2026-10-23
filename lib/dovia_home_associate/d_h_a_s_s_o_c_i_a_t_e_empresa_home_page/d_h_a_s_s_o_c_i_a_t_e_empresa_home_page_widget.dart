import '/dovia_home_associate/associate_header_actions.dart';
import '/dovia_home_associate/associate_nav.dart';
import '/backend/api_requests/dovia_home_paginated_loader.dart';
import '/dovia_home_associate/associate_service_categories.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/company_quote_board.dart';
import '/dovia_home_associate/company_quote_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_cotizacion_enviada_card/d_h_a_s_s_o_c_i_a_t_e_cotizacion_enviada_card_widget.dart';
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

import 'd_h_a_s_s_o_c_i_a_t_e_empresa_home_page_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_empresa_home_page_model.dart';

/// Panel del Dovia Home Associate **tipo Empresa** (`Role =
/// HOME_ASSOCIATE_COMPANY`), adaptado a mobile desde el diseño de escritorio.
///
/// La empresa no toma trabajo de la bolsa: gana proyectos presupuestando. Por
/// eso su panel no tiene "Trabajos disponibles" ni "Próximos trabajos" sino el
/// **pipeline de cotizaciones**, partido en los tres carriles del diseño
/// ([loadCompanyQuoteBoard]):
///
///   1. **Cotizaciones activas** — pedidos de clientes Premium que necesitan un
///      presupuesto a medida. El "Ojo" abre el requerimiento completo (fotos y
///      texto del cliente) para armar y enviar la propuesta.
///   2. **Cotizaciones enviadas** — lo que ya presupuestó y el cliente está
///      comparando. El "Ver trabajo" lleva a la misma pantalla de la
///      cotización, en su Estado 2 (sólo lectura + banner de espera).
///   3. **Cotizaciones aprobadas** — los proyectos que ganó. El "Ojo" vuelve a
///      ser accionable y entra al flujo de trabajo estándar (tránsito, aviso de
///      llegada y ejecución), el mismo que usa el perfil Independiente.
///
/// "Servicios" es idéntico al del Independiente —los rubros habilitados y el
/// botón que lleva a pedir uno nuevo con certificados— porque la habilitación
/// por especialidad es la misma para los dos perfiles.
///
/// En el escritorio el ítem "Cotizaciones" se inyecta en el menú lateral; en
/// mobile ese menú es la barra inferior, así que la inyección vive en
/// [DHASSOCIATENavbarWidget], que la muestra sólo para este rol.
class DHASSOCIATEEmpresaHomePageWidget extends StatefulWidget {
  const DHASSOCIATEEmpresaHomePageWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_EmpresaHomePage';
  static String routePath = '/dHASSOCIATEEmpresaHomePage';

  /// Cuántas tarjetas entran en cada carril del panel. El resto se ve con
  /// "Ver más".
  static const int previewCount = 3;

  @override
  State<DHASSOCIATEEmpresaHomePageWidget> createState() =>
      _DHASSOCIATEEmpresaHomePageWidgetState();
}

class _DHASSOCIATEEmpresaHomePageWidgetState
    extends State<DHASSOCIATEEmpresaHomePageWidget> {
  late DHASSOCIATEEmpresaHomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<CompanyQuoteBoard> _boardFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEEmpresaHomePageModel());

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

  /// (Re)dispara el pipeline completo. Se vuelve a llamar al volver de enviar
  /// una propuesta o de trabajar un proyecto: la oportunidad tiene que pasar de
  /// carril sin que la empresa recargue la app a mano.
  void _loadBoard() {
    _boardFuture =
        loadCompanyQuoteBoard(authToken: currentAuthenticationToken ?? '');
  }

  // ---------------------------------------------------------------------------
  // Filtros: búsqueda por palabras clave + rubro del carrusel.
  // ---------------------------------------------------------------------------

  AssociateServiceCategory? _selectedCategory(
      List<AssociateServiceCategory> categories) {
    final id = _model.selectedCategoryId;
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<Map<String, dynamic>> _filterRequests(
    List<Map<String, dynamic>> requests,
    List<AssociateServiceCategory> categories,
  ) {
    final category = _selectedCategory(categories);
    return requests
        .where((data) =>
            associateRequestMatchesQuery(data, _model.searchQuery, categories))
        .where((data) =>
            category == null || associateRequestMatchesCategory(data, category))
        .toList();
  }

  /// Las propuestas enviadas se filtran contra la solicitud que cotizan. La que
  /// ya no está en el marketplace no tiene rubro que evaluar: con un rubro
  /// elegido queda fuera, porque no se puede afirmar que corresponda al filtro.
  List<CompanyQuoteSubmission> _filterSubmissions(
    List<CompanyQuoteSubmission> submissions,
    List<AssociateServiceCategory> categories,
  ) {
    final category = _selectedCategory(categories);
    return submissions.where((submission) {
      final request = submission.request;
      if (category != null) {
        if (request == null) return false;
        if (!associateRequestMatchesCategory(request, category)) return false;
      }
      final query = _model.searchQuery.trim();
      if (query.isEmpty) return true;
      if (request != null &&
          associateRequestMatchesQuery(request, query, categories)) {
        return true;
      }
      return submission.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Navegación.
  // ---------------------------------------------------------------------------

  /// Ojo de "Cotizaciones activas": abre el requerimiento del cliente, donde la
  /// empresa arma y envía su propuesta económica.
  void _openOpportunity(Map<String, dynamic> data) {
    DHASSOCIATECotizacionWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATECotizacionWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadBoard));
  }

  /// "Cotizaciones enviadas": la misma pantalla que arma la propuesta, ahora
  /// en Estado 2 (sólo lectura + banner de espera) — la empresa puede releer
  /// qué presupuesto mandó sin tener que abrir el historial.
  void _openSubmission(CompanyQuoteSubmission submission) {
    DHASSOCIATECotizacionWidget.requestData = submission.request;
    DHASSOCIATECotizacionWidget.proposalData = submission.proposal;
    context
        .pushNamed(DHASSOCIATECotizacionWidget.routeName,
            queryParameters: associateRouteParams(
                request: submission.request, proposal: submission.proposal))
        .then((_) => safeSetState(_loadBoard));
  }

  /// Ojo de "Cotizaciones aprobadas": entra al flujo de trabajo estándar. Es la
  /// misma pantalla del Independiente porque, ganado el proyecto, la empresa es
  /// el asociado asignado y opera contra los mismos endpoints.
  void _openWonProject(Map<String, dynamic> data) {
    DHASSOCIATETrabajoARealizarWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName,
            queryParameters: associateRouteParams(request: data))
        .then((_) => safeSetState(_loadBoard));
  }

  void _openHistory() {
    context
        .pushNamed(DHASSOCIATECotizacionesWidget.routeName)
        .then((_) => safeSetState(_loadBoard));
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  /// Cabecera del panel: logo, título y los accesos a Servicios y Próximos
  /// trabajos.
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
                  letterSpacing: 0.34,
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

  /// Título de un carril, sin acción propia: los tres cuelgan del "Ver más" de
  /// la sección Cotizaciones.
  Widget _buildLaneTitle(String title) => Text(
        title,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 17.0,
              letterSpacing: 0.34,
              lineHeight: 1.3,
            ),
      );

  /// Carrusel horizontal de los rubros **habilitados para esta empresa**. El
  /// botón de la sección dice "Añadir": desde acá pide operar un rubro nuevo
  /// enviando sus certificados.
  Widget _buildCategoriesCarousel(List<AssociateServiceCategory> categories) {
    if (categories.isEmpty) {
      return _buildEmptyState(
        'Tu empresa todavía no tiene rubros habilitados. Añade los que operas '
        'para empezar a recibir cotizaciones.',
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
              // Segundo toque sobre el mismo rubro = quitar el filtro.
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

  /// Carril de tarjetas accionables (activas y aprobadas): mismo formato, sólo
  /// cambia a dónde lleva el "Ojo".
  Widget _buildRequestLane({
    required List<Map<String, dynamic>> requests,
    required bool failed,
    required int? errorStatus,
    required void Function(Map<String, dynamic>) onViewDetail,
    required String emptyMessage,
  }) {
    if (failed) {
      return _buildEmptyState(CompanyQuoteBoard.errorMessage(errorStatus));
    }
    if (requests.isEmpty) return _buildEmptyState(emptyMessage);

    return Column(
      children: requests
          .take(DHASSOCIATEEmpresaHomePageWidget.previewCount)
          .map(
            (data) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: DHASSOCIATETrabajoCardWidget(
                title: associateRequestTitle(data, _trades),
                // La dirección va enmascarada: la empresa todavía no ganó el
                // proyecto y la exacta se revela al aceptarlo.
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

  /// Carril 2: presupuestos ya enviados. La píldora ahora lleva a la misma
  /// pantalla de la cotización, en Estado 2 (sólo lectura + banner de
  /// espera): antes no había nada que ver ahí, pero ahora sí hay un
  /// presupuesto propio para releer.
  /// Oficios aprobados de la empresa, para titular e iconizar cada
  /// cotización con su oficio en vez del genérico "Servicio por cotizar".
  List<AssociateServiceCategory> _trades = const [];

  Widget _buildSubmittedLane(
      CompanyQuoteBoard board, List<CompanyQuoteSubmission> submissions) {
    if (board.proposalsFailed) {
      return _buildEmptyState(
          CompanyQuoteBoard.errorMessage(board.proposalsErrorStatus));
    }
    if (submissions.isEmpty) {
      return _buildEmptyState(
          'Todavía no enviaste ningún presupuesto. Cotiza una oportunidad '
          'activa para empezar.');
    }

    return Column(
      children: submissions
          .take(DHASSOCIATEEmpresaHomePageWidget.previewCount)
          .map(
            (submission) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: DHASSOCIATECotizacionEnviadaCardWidget(
                title: associateSubmittedTitle(submission.request == null
                    ? submission.title
                    : associateRequestTitle(submission.request!, _trades)),
                subtitle: 'Aguardando respuesta del cliente',
                iconPath: submission.request == null
                    ? associateCategoryIcon(null, submission.title)
                    : associateRequestIcon(submission.request!, _trades),
                onViewWork: () => _openSubmission(submission),
              ),
            ),
          )
          .toList(),
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
              FutureBuilder<CompanyQuoteBoard>(
                future: _boardFuture,
                builder: (context, snapshot) {
                  final board = snapshot.data;
                  _trades = board?.categories.approved ?? const [];
                  final categories = board?.categories.approved ??
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                'Servicios',
                                actionText: 'Añadir',
                                onAction: () => context
                                    .pushNamed(
                                        DHASSOCIATEServiciosWidget.routeName)
                                    .then((_) => safeSetState(_loadBoard)),
                              ),
                              const SizedBox(height: 14.0),
                              if (board == null)
                                const SizedBox(
                                  height: 100.0,
                                  child: Center(child: DoviaSpinner()),
                                )
                              else if (board.categories.failed)
                                _buildEmptyState(board.categories.errorMessage)
                              else
                                _buildCategoriesCarousel(categories),
                              const SizedBox(height: 32.0),
                              _buildSectionHeader(
                                'Cotizaciones',
                                actionText: 'Ver más',
                                onAction: _openHistory,
                              ),
                              if (board == null)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.0),
                                  child: Center(child: DoviaSpinner()),
                                )
                              else
                                ..._buildLanes(board),
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

  List<Widget> _buildLanes(CompanyQuoteBoard board) {
    final categories = board.categories.approved;

    return [
      if (board.truncated) ...[
        const SizedBox(height: 14.0),
        _buildEmptyState(
          'Estamos mostrando las primeras $kDoviaHomeMaxItems cotizaciones. '
          'Puede que haya más en tu historial.',
        ),
      ],
      const SizedBox(height: 14.0),
      _buildLaneTitle('Cotizaciones activas:'),
      const SizedBox(height: 14.0),
      _buildRequestLane(
        requests: _filterRequests(board.active, categories),
        failed: board.marketplaceFailed,
        errorStatus: board.marketplaceErrorStatus,
        onViewDetail: _openOpportunity,
        emptyMessage:
            'Por ahora no hay pedidos de cotización para tus rubros con estos '
            'filtros.',
      ),
      const SizedBox(height: 24.0),
      _buildLaneTitle('Cotizaciones enviadas:'),
      const SizedBox(height: 14.0),
      _buildSubmittedLane(
          board, _filterSubmissions(board.submitted, categories)),
      const SizedBox(height: 24.0),
      _buildLaneTitle('Cotizaciones aprobadas:'),
      const SizedBox(height: 14.0),
      _buildRequestLane(
        requests: _filterRequests(board.approved, categories),
        failed: board.approvedFailed,
        errorStatus: board.approvedErrorStatus,
        onViewDetail: _openWonProject,
        emptyMessage:
            'Todavía no ganaste ningún proyecto. Los presupuestos aprobados '
            'aparecen acá listos para ejecutar.',
      ),
    ];
  }
}
