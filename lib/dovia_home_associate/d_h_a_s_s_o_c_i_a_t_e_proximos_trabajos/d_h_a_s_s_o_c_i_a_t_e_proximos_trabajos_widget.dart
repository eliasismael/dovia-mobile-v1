import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
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

import 'd_h_a_s_s_o_c_i_a_t_e_proximos_trabajos_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_proximos_trabajos_model.dart';

/// Agenda completa del asociado. Se abre desde el "Ver más" de la sección
/// "Próximos trabajos" del panel.
///
/// Son compromisos ya adquiridos: la tarjeta es la misma que la de la bolsa de
/// oportunidades, pero el ícono de "Ojo" abre el detalle de la visita en curso
/// (dirección exacta, instrucciones de ingreso y mapa).
class DHASSOCIATEProximosTrabajosWidget extends StatefulWidget {
  const DHASSOCIATEProximosTrabajosWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_ProximosTrabajos';
  static String routePath = '/dHASSOCIATEProximosTrabajos';

  @override
  State<DHASSOCIATEProximosTrabajosWidget> createState() =>
      _DHASSOCIATEProximosTrabajosWidgetState();
}

class _DHASSOCIATEProximosTrabajosWidgetState
    extends State<DHASSOCIATEProximosTrabajosWidget> {
  late DHASSOCIATEProximosTrabajosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<ApiCallResponse> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEProximosTrabajosModel());

    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    _loadJobs();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _loadJobs() {
    // Sin filtro `status`: el endpoint acepta un único valor y la agenda cubre
    // varios estados (TAKEN, IN_PROGRESS). Los finalizados se excluyen
    // client-side salvo que el asociado los pida.
    _jobsFuture =
        DOVIAAPIDoviaHomeContextGroup.listAssociateServiceRequestsCall.call(
      authToken: currentAuthenticationToken ?? '',
      limit: 50,
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _isFinished(Map<String, dynamic> data) =>
      (asrString(data['status']) ?? 'PENDING').toUpperCase() == 'FINISHED';

  List<Map<String, dynamic>> _applyFilters(List<dynamic> raw) {
    final jobs = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        // Perfil Independiente: sin cotizaciones ni trabajos fuera de alcance.
        .where(asrIsWorkableByIndependent)
        .where((data) => asrMatchesQuery(data, _model.searchQuery))
        .where((data) => _model.includeFinished || !_isFinished(data))
        .toList();

    // La agenda se lee en orden cronológico; lo que no tiene fecha va al final.
    jobs.sort((a, b) {
      final da = asrFilterDate(a);
      final db = asrFilterDate(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return jobs;
  }

  void _openScheduledJob(Map<String, dynamic> data) {
    DHASSOCIATETuTrabajoWidget.requestData = data;
    context
        .pushNamed(DHASSOCIATETuTrabajoWidget.routeName)
        .then((_) => safeSetState(_loadJobs));
  }

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            Checkbox(
                              value: _model.includeFinished,
                              activeColor: FlutterFlowTheme.of(context).primary,
                              onChanged: (value) => safeSetState(
                                  () => _model.includeFinished = value ?? false),
                            ),
                            Expanded(
                              child: Text(
                                'Incluir trabajos finalizados',
                                style: GoogleFonts.inter(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        FutureBuilder<ApiCallResponse>(
                          future: _jobsFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            final response = snapshot.data!;
                            if (!response.succeeded) {
                              return Text(
                                'No pudimos cargar tu agenda. Intentá de nuevo '
                                'en un momento.',
                                style: GoogleFonts.inter(
                                  color:
                                      FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 13.0,
                                ),
                              );
                            }

                            final jobs = _applyFilters(
                                DOVIAAPIDoviaHomeContextGroup
                                        .listAssociateServiceRequestsCall
                                        .requestsList(response.jsonBody) ??
                                    const []);
                            if (jobs.isEmpty) {
                              return Text(
                                'Todavía no tenés trabajos agendados.',
                                style: GoogleFonts.inter(
                                  color:
                                      FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 13.0,
                                ),
                              );
                            }

                            return Column(
                              children: jobs
                                  .map(
                                    (data) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: DHASSOCIATETrabajoCardWidget(
                                        title: asrServiceName(data),
                                        addressLabel: asrZoneLabel(data),
                                        dateLabel: asrFormattedDate(data),
                                        timeLabel: asrTimeLabel(data),
                                        payoutLabel: asrPayoutLabel(data),
                                        priorityLabel: asrPriorityLabel(data),
                                        isUrgent: asrIsEmergency(data),
                                        onViewDetail: () =>
                                            _openScheduledJob(data),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
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
