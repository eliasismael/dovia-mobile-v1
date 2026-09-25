import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proximas_visitas/d_h_c_l_i_e_n_t_proximas_visitas_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/dovia_home_client/service_request_fields.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';

import 'd_h_c_l_i_e_n_t_proximas_visitas_lista_model.dart';
export 'd_h_c_l_i_e_n_t_proximas_visitas_lista_model.dart';

/// Listado completo y filtrable de las solicitudes de servicio del cliente
/// (Dovia Home). Se abre desde el botón "Ver todo" de la sección "Próximas
/// visitas" del Dashboard.
///
/// Cada tarjeta muestra el título del trabajo, la fecha programada y una pill
/// con el estatus actual (una solicitud sin asociado asignado se cataloga como
/// "Pendiente"). Al tapear una tarjeta se abre el detalle en **modo consulta**
/// (solo lectura, sin botón "Aceptar"): [DHCLIENTCasaAWidget].
class DHCLIENTProximasVisitasListaWidget extends StatefulWidget {
  const DHCLIENTProximasVisitasListaWidget({super.key});

  static String routeName = 'DH_CLIENT_ProximasVisitasLista';
  static String routePath = '/dHCLIENTProximasVisitasLista';

  @override
  State<DHCLIENTProximasVisitasListaWidget> createState() =>
      _DHCLIENTProximasVisitasListaWidgetState();
}

class _DHCLIENTProximasVisitasListaWidgetState
    extends State<DHCLIENTProximasVisitasListaWidget> {
  late DHCLIENTProximasVisitasListaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<ApiCallResponse> _visitsFuture;

  static const String _allOption = 'Todos';

  /// Estatus finalizados que NO forman parte de "Próximas visitas". Se excluyen
  /// client-side porque la llamada trae todas las solicitudes del cliente.
  /// El enum del backend es: PENDING, TAKEN, IN_PROGRESS, FINISHED.
  static const Set<String> _finalizedStatuses = {'FINISHED'};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTProximasVisitasListaModel());

    final token = currentAuthenticationToken ?? '';
    // Trae todas las solicitudes del cliente para el listado. NO se envía el
    // filtro `status`: el backend rechaza el string multi-valor
    // ("status invalido", 400), así que las solicitudes finalizadas se excluyen
    // client-side ([_finalizedStatuses]) junto con el resto de filtros de la UI.
    _visitsFuture = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall.call(
      authToken: token,
      limit: 50,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers de extracción de datos de la solicitud. El mapeo de campos contra el
  // payload real vive en [service_request_fields.dart], compartido con el
  // Dashboard para que ambas pantallas pinten la misma solicitud igual.
  // ---------------------------------------------------------------------------

  String _statusLabel(Map<String, dynamic> data) =>
      srStatusLabel(data, DHCLIENTHomepageWidget.confirmedVisitIds);

  // ---------------------------------------------------------------------------
  // Filtros.
  // ---------------------------------------------------------------------------

  bool get _hasActiveFilters =>
      (_model.typeFilter != null && _model.typeFilter != _allOption) ||
      (_model.statusFilter != null && _model.statusFilter != _allOption) ||
      _model.dateFilter != null;

  /// Solo "Próximas visitas": excluye las solicitudes ya finalizadas.
  bool _isUpcoming(Map<String, dynamic> data) => !_finalizedStatuses
      .contains((srString(data['status']) ?? '').toUpperCase());

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> visits) {
    return visits.where((data) {
      if (!_isUpcoming(data)) return false;

      final type = _model.typeFilter;
      if (type != null && type != _allOption && srServiceName(data) != type) {
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
        final d = srFilterDate(data);
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

  /// Mismos filtros, aplicados a las visitas agregadas de forma optimista al
  /// crear la solicitud ([DHCLIENTHomepageWidget.upcomingVisits]).
  bool _matchesLocalFilters(ScheduledVisit visit) {
    final type = _model.typeFilter;
    if (type != null && type != _allOption && visit.service != type) {
      return false;
    }
    final status = _model.statusFilter;
    if (status != null && status != _allOption && visit.status != status) {
      return false;
    }
    final date = _model.dateFilter;
    if (date != null) {
      final d = visit.scheduledAt;
      if (d == null ||
          d.year != date.year ||
          d.month != date.month ||
          d.day != date.day) {
        return false;
      }
    }
    return true;
  }

  /// Solicitudes que el Dashboard ya pinta pero que el backend todavía no
  /// devuelve en el listado. Sin esto la pantalla muestra menos visitas que el
  /// Home y el cliente cree que su solicitud se perdió.
  ///
  /// Se descartan las que el backend ya devolvió (mismo id) para no duplicar.
  List<ScheduledVisit> _localVisits(List<Map<String, dynamic>> backendVisits) {
    final backendIds = backendVisits
        .map((data) => (data['id'] ?? data['serviceRequestId'])?.toString())
        .whereType<String>()
        .toSet();
    return DHCLIENTHomepageWidget.upcomingVisits
        .where((v) => v.id == null || !backendIds.contains(v.id))
        .where(_matchesLocalFilters)
        .toList();
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

  /// Abre el detalle de la solicitud en **modo consulta** (solo lectura). Sin
  /// botón "Aceptar" y sin edición de campos: es estrictamente un registro.
  void _openDetail(Map<String, dynamic> data) {
    DHCLIENTCasaAWidget.requestData = data;
    DHCLIENTCasaAWidget.houseName = srHouseName(data);
    // Modo consulta: este listado es un registro, no el flujo de confirmación,
    // así que el detalle nunca muestra el botón "Aceptar". La tarjeta del
    // asociado se muestra/oculta dentro del detalle según el estatus.
    final id = srId(data);
    DHCLIENTCasaAWidget.readOnly = true;
    DHCLIENTCasaAWidget.alreadyConfirmed =
        DHCLIENTHomepageWidget.confirmedVisitIds.contains(id);
    context
        .pushNamed(DHCLIENTCasaAWidget.routeName)
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
                    child: FutureBuilder<ApiCallResponse>(
                      future: _visitsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final response = snapshot.data!;
                        // El parser corre sobre `jsonBody`: pasarle el
                        // ApiCallResponse deja a JsonPath sin nada que recorrer
                        // y devuelve null en silencio (listado siempre vacío).
                        final rawList = response.succeeded
                            ? (DOVIAAPIDoviaHomeContextGroup
                                    .listServiceRequestsCall
                                    .requestsList(response.jsonBody) ??
                                [])
                            : [];
                        final visits = rawList
                            .whereType<Map>()
                            .map((e) => Map<String, dynamic>.from(e))
                            .toList();

                        // Las opciones salen de las visitas próximas (no de las
                        // finalizadas, que este listado no muestra) y no
                        // dependen del resto de filtros, para que el desplegable
                        // no se vacíe al filtrar.
                        final typeOptions = <String>{
                          _allOption,
                          for (final v in DHCLIENTHomepageWidget.upcomingVisits)
                            v.service,
                          for (final v in visits)
                            if (_isUpcoming(v)) srServiceName(v),
                        }.toList();

                        final filtered = _applyFilters(visits);
                        final localVisits = _localVisits(visits);
                        final hasAnyVisit = visits.isNotEmpty ||
                            DHCLIENTHomepageWidget.upcomingVisits.isNotEmpty;
                        final hasResults =
                            filtered.isNotEmpty || localVisits.isNotEmpty;

                        return SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 8.0, 20.0, 120.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilters(typeOptions),
                              const SizedBox(height: 20.0),
                              if (!response.succeeded && !hasAnyVisit)
                                _emptyState(
                                    'No se pudieron cargar tus servicios.')
                              else if (!hasAnyVisit)
                                _emptyState(
                                    'Aún no tienes servicios solicitados.')
                              else if (!hasResults)
                                _emptyState(_hasActiveFilters
                                    ? 'No hay servicios que coincidan con los filtros.'
                                    : 'Aún no tienes próximas visitas.')
                              else ...[
                                // Recién solicitadas: el Dashboard ya las
                                // muestra. No abren detalle porque todavía no
                                // existe el registro en el backend.
                                ...localVisits.map(
                                  (visit) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: DHCLIENTProximasVisitasWidget(
                                      title: visit.service,
                                      date: '${visit.date} · ${visit.time}',
                                      status: visit.status,
                                      isEmergency: visit.isEmergency,
                                      icom: srServiceIconAsset(visit.service),
                                    ),
                                  ),
                                ),
                                ...filtered.map((data) {
                                  final status = _statusLabel(data);
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: InkWell(
                                      onTap: () => _openDetail(data),
                                      borderRadius: BorderRadius.circular(14.0),
                                      child: DHCLIENTProximasVisitasWidget(
                                        title: srServiceName(data),
                                        date: srFormattedDate(data),
                                        status: status,
                                        isEmergency: srIsEmergency(data),
                                        showRedDot: status == 'Confirmar',
                                        icom: srServiceIconAsset(
                                            srServiceName(data)),
                                      ),
                                    ),
                                  );
                                }),
                              ],
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
                          0.0, 0.0, 15.0, 100.0),
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
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.safePop();
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).alternate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_left,
                color: FlutterFlowTheme.of(context).primary,
                size: 24.0,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Próximas Visitas',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
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
          hint: 'Tipo de trabajo',
          onChanged: (val) => safeSetState(() => _model.typeFilter = val),
        ),
        const SizedBox(height: 16.0),
        _filterLabel('Estado del trabajo'),
        const SizedBox(height: 8.0),
        _dropdown(
          controller: _model.statusController ??=
              FormFieldController<String>(_model.statusFilter),
          // Mismas etiquetas que devuelve [_statusLabel] para las solicitudes
          // no finalizadas, para que toda tarjeta visible sea filtrable.
          options: const [
            _allOption,
            'Pendiente',
            kPendingQuoteStatusLabel,
            'Confirmar',
            'Programada',
            'En progreso',
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
