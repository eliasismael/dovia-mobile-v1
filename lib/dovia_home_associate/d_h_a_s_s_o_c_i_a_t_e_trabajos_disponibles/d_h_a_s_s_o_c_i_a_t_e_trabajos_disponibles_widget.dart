import '/dovia_home_associate/associate_service_categories.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/associate_specialties_loader.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_trabajo_card/d_h_a_s_s_o_c_i_a_t_e_trabajo_card_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
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

/// Valor centinela de la opción "Todo" de cada desplegable. Es un valor y no
/// `null` porque `FlutterFlowDropDown` usa null para "nada elegido" y ahí
/// pintaría el placeholder en vez de decir que no está filtrando.
const String _kAllOption = '__ALL__';

const String _kUrgentOption = 'URGENT';
const String _kStandardOption = 'STANDARD';

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

/// Un mes con trabajos, para el desplegable de fecha.
typedef _MonthOption = ({String key, String label});

/// Todo lo que la pantalla necesita resuelto: las especialidades que pueblan el
/// filtro de tipo y la bolsa de trabajos.
class _Board {
  const _Board({
    required this.categories,
    required this.jobs,
    this.jobsErrorStatus,
  });

  final AssociateCategories categories;

  /// Solicitudes que este perfil puede trabajar, **sin** los filtros de la UI
  /// aplicados: de acá salen también las opciones del desplegable de mes, que
  /// no deben cambiar según lo que el asociado tenga filtrado.
  final List<Map<String, dynamic>> jobs;

  final int? jobsErrorStatus;

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
    final jobsRequest = DOVIAAPIDoviaHomeContextGroup
        .listAvailableAssociateServiceRequestsCall
        .call(authToken: token, limit: 50);

    final categories = await categoriesRequest;
    final jobsResponse = await jobsRequest;

    if (!jobsResponse.succeeded) {
      return _Board(
        categories: categories,
        jobs: const [],
        jobsErrorStatus: jobsResponse.statusCode,
      );
    }

    final raw = DOVIAAPIDoviaHomeContextGroup
            .listAvailableAssociateServiceRequestsCall
            .requestsList(jobsResponse.jsonBody) ??
        const [];

    final board = _Board(
      categories: categories,
      jobs: raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          // Perfil Independiente: sin cotizaciones ni trabajos fuera de alcance.
          .where(asrIsWorkableByIndependent)
          .toList(),
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
    final months = _monthOptions(board.jobs).map((m) => m.key).toSet();
    if (_model.monthKey != null && !months.contains(_model.monthKey)) {
      _model.monthKey = null;
      _model.monthController?.value = _kAllOption;
    }

    final approved = board.categories.approved.map((c) => c.id).toSet();
    if (_model.categoryId != null && !approved.contains(_model.categoryId)) {
      _model.categoryId = null;
      _model.categoryController?.value = _kAllOption;
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

  /// Meses con trabajos, ordenados cronológicamente. Sale de la bolsa completa
  /// para que el desplegable no se vacíe a medida que el asociado filtra.
  List<_MonthOption> _monthOptions(List<Map<String, dynamic>> jobs) {
    final labelsByKey = <String, String>{};
    for (final job in jobs) {
      final key = asrMonthKey(job);
      final label = asrMonthLabel(job);
      if (key != null && label != null) labelsByKey[key] = label;
    }
    final keys = labelsByKey.keys.toList()..sort();
    return [for (final key in keys) (key: key, label: labelsByKey[key]!)];
  }

  void _openOpportunity(Map<String, dynamic> data) {
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

  /// Desplegable del diseño: etiqueta arriba, campo blanco redondeado con la
  /// flecha a la derecha. En escritorio los tres van en fila; en mobile no
  /// entran, así que se apilan.
  Widget _buildDropdown({
    required String label,
    required String hintText,
    required FormFieldController<String> controller,
    required List<String> options,
    required List<String> optionLabels,
    required void Function(String?) onChanged,
    bool disabled = false,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: theme.primaryText,
            fontSize: 16.0,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 8.0),
        FlutterFlowDropDown<String>(
          controller: controller,
          options: options,
          optionLabels: optionLabels,
          onChanged: onChanged,
          width: double.infinity,
          height: 48.0,
          hintText: hintText,
          disabled: disabled,
          textStyle: theme.bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: disabled ? theme.secondaryText : theme.primaryText,
            fontSize: 15.0,
            letterSpacing: 0.3,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.secondaryText,
            size: 24.0,
          ),
          fillColor: theme.secondaryBackground,
          elevation: 2.0,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          borderRadius: 10.0,
          margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 12.0, 4.0),
          hidesUnderline: true,
          isOverButton: false,
          isSearchable: false,
          isMultiSelect: false,
        ),
      ],
    );
  }

  /// Tipo de Trabajo. **Sólo las especialidades aprobadas del asociado**: si es
  /// Plomero y Electricista, esas dos y nada más.
  Widget _buildCategoryFilter(AssociateCategories categories) {
    final approved = categories.approved;

    if (approved.isEmpty) {
      // Sin especialidades aprobadas no hay nada legítimo que ofrecer. Se deja
      // el desplegable visible pero inerte, y se dice por qué: esconderlo haría
      // parecer que la pantalla está rota.
      return _buildDropdown(
        label: 'Tipo de Trabajo',
        hintText: 'Sin especialidades aprobadas',
        controller: _model.categoryController ??=
            FormFieldController<String>(_kAllOption),
        options: const [_kAllOption],
        optionLabels: const ['Sin especialidades aprobadas'],
        onChanged: (_) {},
        disabled: true,
      );
    }

    return _buildDropdown(
      label: 'Tipo de Trabajo',
      hintText: 'Selecciona la especialidad',
      controller: _model.categoryController ??=
          FormFieldController<String>(_kAllOption),
      options: [_kAllOption, ...approved.map((c) => c.id)],
      optionLabels: ['Todas', ...approved.map((c) => c.label)],
      onChanged: (value) => safeSetState(() {
        _model.categoryId =
            (value == null || value == _kAllOption) ? null : value;
      }),
    );
  }

  /// Estado del trabajo: las tres opciones fijas del diseño.
  Widget _buildStatusFilter() {
    return _buildDropdown(
      label: 'Estado del trabajo',
      hintText: 'Selecciona el estado',
      controller: _model.statusController ??=
          FormFieldController<String>(_kAllOption),
      options: const [_kAllOption, _kUrgentOption, _kStandardOption],
      optionLabels: const ['Todo', 'Urgente', 'Estándar'],
      onChanged: (value) => safeSetState(() {
        _model.urgentOnly = switch (value) {
          _kUrgentOption => true,
          _kStandardOption => false,
          _ => null,
        };
      }),
    );
  }

  /// Fecha del trabajo, agrupada por mes.
  Widget _buildMonthFilter(List<_MonthOption> months) {
    return _buildDropdown(
      label: 'Fecha del trabajo',
      hintText: 'Selecciona el mes',
      controller: _model.monthController ??=
          FormFieldController<String>(_kAllOption),
      options: [_kAllOption, ...months.map((m) => m.key)],
      optionLabels: ['Todos los meses', ...months.map((m) => m.label)],
      disabled: months.isEmpty,
      onChanged: (value) => safeSetState(() {
        _model.monthKey =
            (value == null || value == _kAllOption) ? null : value;
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
      children: jobs
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
                onViewDetail: () => _openOpportunity(data),
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
                            _buildMonthFilter(_monthOptions(board.jobs)),
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
