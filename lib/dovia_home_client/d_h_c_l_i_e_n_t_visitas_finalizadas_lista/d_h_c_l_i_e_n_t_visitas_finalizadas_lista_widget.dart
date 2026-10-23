import '/dovia_home_client/service_request_fields.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proximas_visitas/d_h_c_l_i_e_n_t_proximas_visitas_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import '/shared_components/header_navigation.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/dovia_home_paginated_loader.dart';

import 'd_h_c_l_i_e_n_t_visitas_finalizadas_lista_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_h_c_l_i_e_n_t_visitas_finalizadas_lista_model.dart';

/// Historial completo y filtrable de los servicios finalizados del cliente
/// (Dovia Home). Se abre desde el botón "Ver todo" de la sección de historial
/// del Dashboard.
///
/// El listado se acota a las solicitudes FINISHED (filtro server-side) y ofrece
/// tres filtros de búsqueda: Tipo de Trabajo, Estado del trabajo y Fecha del
/// trabajo.
///
/// Cada tarjeta muestra el título del trabajo, la fecha y una píldora con el
/// estado final real: "Finalizada" (verde) o "Reportado" (rojo). Se ignora
/// deliberadamente el texto "Pendiente" del diseño visual: en un historial la
/// solicitud ya terminó. Al tapear una tarjeta se abre el registro inmutable
/// (solo lectura): [DHCLIENTTrabajoFinalizadoWidget].
class DHCLIENTVisitasFinalizadasListaWidget extends StatefulWidget {
  const DHCLIENTVisitasFinalizadasListaWidget({super.key});

  static String routeName = 'DH_CLIENT_VisitasFinalizadasLista';
  static String routePath = '/dHCLIENTVisitasFinalizadasLista';

  @override
  State<DHCLIENTVisitasFinalizadasListaWidget> createState() =>
      _DHCLIENTVisitasFinalizadasListaWidgetState();
}

/// Resultado de leer el historial completo (todas las páginas).
class _HistoryResult {
  const _HistoryResult({required this.visits, required this.failed});

  final List<Map<String, dynamic>> visits;

  /// La lectura falló sin traer nada. Si una página intermedia falla se
  /// devuelve lo acumulado con `failed: false` (mejor un historial parcial que
  /// una pantalla de error).
  final bool failed;
}

class _DHCLIENTVisitasFinalizadasListaWidgetState
    extends State<DHCLIENTVisitasFinalizadasListaWidget> {
  late DHCLIENTVisitasFinalizadasListaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<_HistoryResult> _visitsFuture;

  static const String _allOption = 'Todos';

  /// Estatus que componen el historial. La llamada ya filtra por FINISHED
  /// server-side; este set queda como guarda defensiva por si el backend
  /// ignorara el parámetro `status`.
  /// El enum del backend es: PENDING, TAKEN, IN_PROGRESS, FINISHED.
  static const Set<String> _finalizedStatuses = {'FINISHED'};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTVisitasFinalizadasListaModel());

    _visitsFuture = _fetchHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Lee el historial **completo** recorriendo las páginas del endpoint.
  ///
  /// El AC pide "un historial completo": con una sola llamada de `limit: 50` el
  /// cliente que acumula servicios deja de ver los más viejos sin ningún aviso.
  /// Se pagina en el fetch (no en la UI) para no introducir un control de
  /// "cargar más" que el diseño no tiene.
  ///
  /// El historial se acota a un único estatus (FINISHED), así que se filtra
  /// server-side: el endpoint valida `status` contra el enum
  /// PENDING/TAKEN/IN_PROGRESS/FINISHED y acepta un valor único. (La pantalla
  /// hermana "Próximas visitas" necesita varios estatus a la vez —un string
  /// multi-valor devuelve 400 "status invalido"—, por eso ella sí filtra
  /// client-side; acá no aplica.)
  ///
  /// Filtrar en el server además es lo correcto para un historial: pidiendo el
  /// listado sin filtro, `limit` se consume con solicitudes de cualquier
  /// estatus y las finalizadas pueden quedar fuera de la página a medida que el
  /// cliente acumula solicitudes activas.
  Future<_HistoryResult> _fetchHistory() async {
    final token = currentAuthenticationToken ?? '';
    final call = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall;

    final page = await loadAllDoviaHomePages(
      fetchPage: (page, limit) => call.call(
        authToken: token,
        status: 'FINISHED',
        page: page,
        limit: limit,
      ),
      extractList: call.requestsList,
    );

    return _HistoryResult(visits: page.items, failed: page.failed);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers de extracción de datos de la solicitud.
  // ---------------------------------------------------------------------------

  String? _str(dynamic v) =>
      (v is String && v.trim().isNotEmpty) ? v.trim() : null;

  String _serviceName(Map<String, dynamic> data) =>
      _str(data['serviceName']) ?? 'Servicio';

  /// Fecha programada (appointment.scheduledAt) o, si no existe, la de creación.
  DateTime? _visitDate(Map<String, dynamic> data) {
    final apt = data['appointment'];
    final raw =
        _str(apt is Map ? apt['scheduledAt'] : null) ?? _str(data['createdAt']);
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  // El app solo inicializa el locale 'en', por eso las fechas en español se
  // arman manualmente (mismo criterio que el resto de pantallas del cliente).
  static const List<String> _weekdaysEs = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  static const List<String> _monthsEs = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  String _formattedDate(Map<String, dynamic> data) {
    final d = _visitDate(data);
    if (d == null) return 'Fecha pendiente';
    final weekday = _weekdaysEs[d.weekday - 1];
    final month = _monthsEs[d.month - 1];
    return '$weekday, ${d.day} de $month';
  }

  /// Detección best-effort de si el cliente reportó un problema sobre este
  /// trabajo finalizado. El shape del backend es incierto, por eso se prueban
  /// varias claves. Determina la píldora roja "Reportado".
  bool _isReported(Map<String, dynamic> data) {
    if (data['reported'] == true ||
        data['hasReport'] == true ||
        data['isReported'] == true) {
      return true;
    }
    if (_str(data['reportedAt']) != null) return true;
    final sub = (_str(data['subStatus']) ?? '').toUpperCase();
    if (sub.contains('REPORT')) return true;
    return false;
  }

  /// Regla de estatus para el historial. El listado ya está acotado a las
  /// solicitudes FINISHED, así que la píldora sólo distingue el estado final
  /// real: "Reportado" (rojo) si el cliente reportó un problema, o
  /// "Finalizada" (verde) en caso contrario. Se ignora deliberadamente el
  /// texto "Pendiente" del diseño visual.
  String _statusLabel(Map<String, dynamic> data) {
    return _isReported(data) ? 'Reportado' : 'Finalizada';
  }

  // ---------------------------------------------------------------------------
  // Filtros.
  // ---------------------------------------------------------------------------

  bool get _hasActiveFilters =>
      (_model.typeFilter != null && _model.typeFilter != _allOption) ||
      (_model.statusFilter != null && _model.statusFilter != _allOption) ||
      _model.dateFilter != null;

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> visits) {
    return visits.where((data) {
      // Solo "Visitas finalizadas": excluye las solicitudes no finalizadas.
      final rawStatus = (_str(data['status']) ?? '').toUpperCase();
      if (!_finalizedStatuses.contains(rawStatus)) return false;

      final type = _model.typeFilter;
      if (type != null && type != _allOption && _serviceName(data) != type) {
        return false;
      }
      final status = _model.statusFilter;
      if (status != null &&
          status != _allOption &&
          _statusLabel(data) != status) {
        return false;
      }
      final date = _model.dateFilter;
      if (date != null) {
        final d = _visitDate(data);
        if (d == null ||
            d.year != date.year ||
            d.month != date.month ||
            d.day != date.day) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _model.dateFilter ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      safeSetState(() => _model.dateFilter = picked);
    }
  }

  /// Abre el detalle "Trabajo finalizado" del servicio (registro inmutable de
  /// solo lectura). Los datos exactos y bloqueados de esa solicitud se pasan por
  /// el campo estático [DHCLIENTTrabajoFinalizadoWidget.requestData].
  void _openDetail(Map<String, dynamic> data) {
    DHCLIENTTrabajoFinalizadoWidget.requestData = data;
    context
        .pushNamed(DHCLIENTTrabajoFinalizadoWidget.routeName)
        .then((_) => safeSetState(() {}));
  }

  // ---------------------------------------------------------------------------
  // UI.
  // ---------------------------------------------------------------------------

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
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: FutureBuilder<_HistoryResult>(
                      future: _visitsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: DoviaSpinner());
                        }
                        final result = snapshot.data!;
                        final visits = result.visits;

                        final typeOptions = <String>{
                          _allOption,
                          for (final v in visits) _serviceName(v),
                        }.toList();

                        final filtered = _applyFilters(visits);

                        return SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 8.0, 20.0, 120.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilters(typeOptions),
                              const SizedBox(height: 20.0),
                              if (result.failed)
                                _emptyState(
                                    'No se pudieron cargar tus servicios.')
                              else if (visits.isEmpty)
                                _emptyState(
                                    'Aún no tienes visitas finalizadas.')
                              else if (filtered.isEmpty)
                                _emptyState(_hasActiveFilters
                                    ? 'No hay servicios que coincidan con los filtros.'
                                    : 'Aún no tienes visitas finalizadas.')
                              else
                                ...filtered.map(
                                  (data) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: InkWell(
                                      onTap: () => _openDetail(data),
                                      borderRadius: BorderRadius.circular(14.0),
                                      child: DHCLIENTProximasVisitasWidget(
                                        title: _serviceName(data),
                                        date: _formattedDate(data),
                                        status: _statusLabel(data),
                                        icom: srIconAsset(data),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
                          0.0, 0.0, 15.0, 12.0),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12.0),
      child: DOVIASHAREDHeaderWidget(
        title: 'Visitas Finalizadas',
        showLogo: openedFromHome(context),
        hideActions: true,
      ),
    );
  }

  Widget _buildFilters(List<String> typeOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterLabel('Tipo de Trabajo'),
        const SizedBox(height: 8.0),
        _dropdown(
          controller: _model.typeController ??=
              FormFieldController<String>(_model.typeFilter),
          options: typeOptions,
          hint: 'Selecciona la transacción',
          onChanged: (val) => safeSetState(() => _model.typeFilter = val),
        ),
        const SizedBox(height: 16.0),
        _filterLabel('Estado del trabajo'),
        const SizedBox(height: 8.0),
        _dropdown(
          controller: _model.statusController ??=
              FormFieldController<String>(_model.statusFilter),
          options: const [
            _allOption,
            'Finalizada',
            'Reportado',
          ],
          hint: 'Selecciona el tipo',
          onChanged: (val) => safeSetState(() => _model.statusFilter = val),
        ),
        const SizedBox(height: 16.0),
        _filterLabel('Fecha del trabajo'),
        const SizedBox(height: 8.0),
        _dateField(),
      ],
    );
  }

  Widget _filterLabel(String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              fontSize: 13.0,
              letterSpacing: 0.0,
              color: FlutterFlowTheme.of(context).primary,
            ),
      );

  Widget _dropdown({
    required FormFieldController<String> controller,
    required List<String> options,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return FlutterFlowDropDown<String>(
      controller: controller,
      options: options,
      onChanged: onChanged,
      width: double.infinity,
      height: 56.0,
      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(),
            letterSpacing: 0.0,
          ),
      hintText: hint,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: FlutterFlowTheme.of(context).primary,
        size: 24.0,
      ),
      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
      elevation: 2.0,
      borderColor: FlutterFlowTheme.of(context).alternate,
      borderWidth: 1.0,
      borderRadius: 12.0,
      margin: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 12.0, 0.0),
      hidesUnderline: true,
      isOverButton: false,
      isSearchable: false,
      isMultiSelect: false,
    );
  }

  Widget _dateField() {
    final date = _model.dateFilter;
    final label = date != null
        ? DateFormat('dd/MM/yyyy').format(date)
        : 'Selecciona la fecha';
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: double.infinity,
        height: 56.0,
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 12.0, 0.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                      color: date != null
                          ? FlutterFlowTheme.of(context).primaryText
                          : FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ),
            if (date != null)
              InkWell(
                onTap: () => safeSetState(() => _model.dateFilter = null),
                child: Icon(
                  Icons.close,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 20.0,
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 24.0,
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) => Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0.0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
        ),
      );
}
