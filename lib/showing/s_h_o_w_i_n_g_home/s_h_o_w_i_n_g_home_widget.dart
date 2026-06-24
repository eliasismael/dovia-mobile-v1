import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_properties.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_accept_visit_popup/s_h_o_w_i_n_g_accept_visit_popup_widget.dart';
import '/showing/s_h_o_w_i_n_g_visit_already_accepted_popup/s_h_o_w_i_n_g_visit_already_accepted_popup_widget.dart';
import '/showing/s_h_o_w_i_n_g_registro_de_visita/s_h_o_w_i_n_g_registro_de_visita_widget.dart';
import '/showing/s_h_o_w_i_n_g_registro_de_visita_2/s_h_o_w_i_n_g_registro_de_visita2_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 's_h_o_w_i_n_g_home_model.dart';
export 's_h_o_w_i_n_g_home_model.dart';

// ── Enriched visit data for a Showing card ─────────────────────────────────
class _ShowingVisit {
  final String visitId;
  final String propertyId;
  final String title;
  final String address;
  final String ownerName;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String imageUrl;
  final String status;
  final String substatus;

  const _ShowingVisit({
    required this.visitId,
    this.propertyId = '',
    this.title = '',
    this.address = '',
    this.ownerName = '',
    this.date = '',
    this.time = '',
    this.imageUrl = '',
    this.status = '',
    this.substatus = '',
  });
}

class SHOWINGHomeWidget extends StatefulWidget {
  const SHOWINGHomeWidget({super.key});

  static String routeName = 'SHOWING_Home';
  static String routePath = '/sHOWINGHome';

  @override
  State<SHOWINGHomeWidget> createState() => _SHOWINGHomeWidgetState();
}

class _SHOWINGHomeWidgetState extends State<SHOWINGHomeWidget> {
  late SHOWINGHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _primary = Color(0xFF007376);

  // Unassigned (self-assignable), assigned-today, assigned-upcoming
  Future<List<_ShowingVisit>>? _acceptableFuture;
  Future<List<_ShowingVisit>>? _todayFuture;
  Future<List<_ShowingVisit>>? _acceptedFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGHomeModel());
    _loadAll();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _loadAll() {
    _acceptableFuture = _fetchUnassigned();
    _todayFuture = _fetchAssigned(today: 'true');
    _acceptedFuture = _fetchAssigned(filter: 'upcoming');
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Data helpers ─────────────────────────────────────────────────────────
  String _slot(dynamic visit, String field) {
    if (visit is! Map) return '';
    final slot = visit['confirmedTimeSlot'];
    if (slot is! Map) return '';
    return slot[field]?.toString() ?? '';
  }

  Map? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur : null;
  }

  // Unassigned visits expose only propertyId — enrich via Get Property by ID.
  Future<List<_ShowingVisit>> _fetchUnassigned() async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getShowingAgentUnassignedVisitsCall
        .call(authToken: token, page: '1', limit: '10');
    if (!res.succeeded) return [];

    final raw = getJsonField(res.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    final propFutures = visits.map((v) {
      final pid = v is Map ? v['propertyId']?.toString() ?? '' : '';
      return DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(propertyId: pid);
    }).toList();
    final props = await Future.wait(propFutures);

    final out = <_ShowingVisit>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      String title = '';
      String address = '';
      String image = '';
      final p = props[i];
      if (p.succeeded) {
        final d = getJsonField(p.jsonBody, r'$.data.data');
        if (d is Map) {
          title = d['name']?.toString() ?? d['title']?.toString() ?? '';
          image = d['image']?.toString() ?? '';
          final addr = _deepMap(d, ['location', 'address']);
          address = addr?['fullAddress']?.toString() ?? '';
        }
      }
      out.add(_ShowingVisit(
        visitId: v is Map ? v['visitId']?.toString() ?? '' : '',
        propertyId: v is Map ? v['propertyId']?.toString() ?? '' : '',
        title: title,
        address: address,
        imageUrl: image,
        date: _slot(v, 'date'),
        time: _slot(v, 'time'),
      ));
    }
    return out;
  }

  // Assigned visits carry property.image; enrich address/owner via overview
  // (ownerProfile is privacy-gated and may be null until 2h before the visit).
  Future<List<_ShowingVisit>> _fetchAssigned({String? today, String? filter}) async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getShowingAgentVisitsCall.call(
      authToken: token,
      today: today,
      filter: filter,
      page: '1',
      limit: '10',
    );
    if (!res.succeeded) return [];

    final raw = getJsonField(res.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    final ovFutures = visits.map((v) {
      final id = v is Map ? v['visitId']?.toString() ?? '' : '';
      return DOVIAAPIVisitContextGroup.getShowingVisitOverviewCall
          .call(authToken: token, visitId: id);
    }).toList();
    final overviews = await Future.wait(ovFutures);

    final out = <_ShowingVisit>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      String image = '';
      if (v is Map && v['property'] is Map) {
        image = (v['property'] as Map)['image']?.toString() ?? '';
      }

      String title = '';
      String address = '';
      String ownerName = '';
      final ov = overviews[i];
      if (ov.succeeded) {
        final data = getJsonField(ov.jsonBody, r'$.data');
        if (data is Map) {
          final prop = data['property'];
          if (prop is Map) {
            title = prop['name']?.toString() ?? '';
            final addr = _deepMap(prop, ['location', 'address']);
            address = addr?['fullAddress']?.toString() ?? '';
          }
          final owner = data['ownerProfile'];
          if (owner is Map) {
            ownerName = owner['fullName']?.toString() ?? '';
          }
        }
      }

      out.add(_ShowingVisit(
        visitId: v is Map ? v['visitId']?.toString() ?? '' : '',
        title: title,
        address: address,
        ownerName: ownerName,
        imageUrl: image,
        date: _slot(v, 'date'),
        time: _slot(v, 'time'),
        status: v is Map ? v['status']?.toString() ?? '' : '',
        substatus: v is Map ? v['substatus']?.toString() ?? '' : '',
      ));
    }
    return out;
  }

  // ── Accept (self-assign) ─────────────────────────────────────────────────
  Future<void> _onAccept(String visitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const SHOWINGAcceptVisitPopupWidget(),
        );
      },
    );
    if (confirmed != true) return;

    final res = await DOVIAAPIVisitContextGroup.showingAgentAcceptVisitCall
        .call(authToken: currentAuthenticationToken, visitId: visitId);
    if (!mounted) return;

    if (res.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Visita aceptada con éxito.',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          duration: const Duration(milliseconds: 3000),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      safeSetState(_loadAll);
    } else if (res.statusCode == 409) {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: const AlignmentDirectional(0.0, 0.0)
                .resolve(Directionality.of(context)),
            child: const SHOWINGVisitAlreadyAcceptedPopupWidget(),
          );
        },
      );
      safeSetState(_loadAll);
    } else {
      final errorCode = (getJsonField(res.jsonBody, r'$.errorCode') ??
              getJsonField(res.jsonBody, r'$.code') ??
              getJsonField(res.jsonBody, r'$.message'))
          ?.toString() ??
          '';
      final msg = errorCode == 'SHOWING_ASSIGNMENT_WINDOW_CLOSED'
          ? 'Ya no puedes aceptar esta visita: falta 1 hora o menos.'
          : 'No se pudo aceptar la visita. Inténtalo de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  void _openForm(String visitId) {
    context.pushNamed(
      SHOWINGRegistroDeVisita2Widget.routeName,
      queryParameters: {
        'visitId': serializeParam(visitId, ParamType.String),
      }.withoutNulls,
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
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.sHOWINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGHeaderWidget(
                        title: 'Home',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Visitas que puedes aceptar (unassigned)
                          _sectionTitle('Visitas que puedes aceptar',
                              topPadding: 20),
                          _horizontalList(
                            future: _acceptableFuture,
                            emptyMsg: 'No hay visitas disponibles por ahora.',
                            height: 200,
                            cardBuilder: (v) => _buildOpportunityCard(v),
                          ),

                          // 2. Visitas de hoy (assigned today)
                          _sectionTitleWithAction(
                            'Visitas de hoy',
                            onVerTodo: () => context.pushNamed(
                                SHOWINGRegistroDeVisitaWidget.routeName),
                          ),
                          _horizontalList(
                            future: _todayFuture,
                            emptyMsg: 'No tienes visitas para hoy.',
                            height: 190,
                            cardBuilder: (v) => _buildVisitCard(
                              visit: v,
                              showStatus: true,
                              buttonText: 'Registrar visita',
                              onPressed: () => _openForm(v.visitId),
                            ),
                          ),

                          // 3. Visitas aceptadas (assigned upcoming)
                          _sectionTitleWithAction(
                            'Visitas aceptadas',
                            onVerTodo: () => context.pushNamed(
                                SHOWINGRegistroDeVisitaWidget.routeName),
                          ),
                          _horizontalList(
                            future: _acceptedFuture,
                            emptyMsg: 'No tienes visitas aceptadas.',
                            height: 190,
                            cardBuilder: (v) => _buildVisitCard(
                              visit: v,
                              showStatus: false,
                              buttonText: 'Registrar visita',
                              onPressed: () => _openForm(v.visitId),
                            ),
                          ),
                        ],
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
                    wrapWithModel(
                      model: _model.sHOWINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGNavbarWidget(),
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

  // ── Section + list scaffolding ───────────────────────────────────────────
  Widget _sectionTitle(String title, {double topPadding = 30}) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, topPadding, 0.0, 10.0),
      child: Text(
        title,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _sectionTitleWithAction(String title,
      {required VoidCallback onVerTodo}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          FFButtonWidget(
            onPressed: onVerTodo,
            text: 'Ver todo',
            options: FFButtonOptions(
              height: 30.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              color: FlutterFlowTheme.of(context).accent1,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.normal),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 14.0,
                  ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalList({
    required Future<List<_ShowingVisit>>? future,
    required String emptyMsg,
    required double height,
    required Widget Function(_ShowingVisit) cardBuilder,
  }) {
    return FutureBuilder<List<_ShowingVisit>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              emptyMsg,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          );
        }
        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snap.data!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) => cardBuilder(snap.data![i]),
          ),
        );
      },
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${parts[2]} de ${months[m]} de ${parts[0]}';
  }

  Widget _cardImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: url.isNotEmpty
          ? Image.network(
              url,
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/casa_card_sobreMiVisita.png',
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/images/casa_card_sobreMiVisita.png',
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
    );
  }

  // ── Opportunity card (unassigned → Aceptar) ──────────────────────────────
  Widget _buildOpportunityCard(_ShowingVisit v) {
    return Container(
      width: 320.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
              blurRadius: 4.0, color: Color(0x33000000), offset: Offset(0.0, 2.0))
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardImage(v.imageUrl),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title.isNotEmpty ? v.title : 'Propiedad',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 16.0),
                          color: const Color(0xFF0F3E48),
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  if (v.address.isNotEmpty)
                    Text(
                      'Dirección: ${v.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: _primary,
                          ),
                    ),
                  if (v.date.isNotEmpty)
                    Text(
                      'Fecha: ${_formatDate(v.date)}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: _primary,
                          ),
                    ),
                  if (v.time.isNotEmpty)
                    Text(
                      'Hora: ${v.time}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: _primary,
                          ),
                    ),
                  const SizedBox(height: 12.0),
                  FFButtonWidget(
                    onPressed: () => _onAccept(v.visitId),
                    text: 'Aceptar',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 30.0,
                      color: Colors.transparent,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.inter(
                                color: _primary, fontSize: 14.0),
                          ),
                      elevation: 0.0,
                      borderSide: const BorderSide(color: _primary, width: 1.0),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Visit card (assigned) ────────────────────────────────────────────────
  Widget _buildVisitCard({
    required _ShowingVisit visit,
    required bool showStatus,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 320.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
              blurRadius: 4.0, color: Color(0x33000000), offset: Offset(0.0, 2.0))
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardImage(visit.imageUrl),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.title.isNotEmpty ? visit.title : 'Propiedad',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 16.0),
                          color: const Color(0xFF0F3E48),
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  if (visit.address.isNotEmpty)
                    Text(
                      'Dirección: ${visit.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: _primary,
                          ),
                    ),
                  if (visit.time.isNotEmpty)
                    Text(
                      'Hora: ${visit.time}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: _primary,
                          ),
                    ),
                  if (visit.ownerName.isNotEmpty)
                    Text(
                      visit.ownerName,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: _primary,
                          ),
                    ),
                  if (showStatus && visit.substatus.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estatus',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(fontSize: 12.0),
                                color: _primary,
                              ),
                        ),
                        _buildStatusPill(_statusLabel(visit.substatus)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12.0),
                  FFButtonWidget(
                    onPressed: onPressed,
                    text: buttonText,
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 30.0,
                      color: _primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.inter(
                                color: Colors.white, fontSize: 14.0),
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String substatus) {
    switch (substatus) {
      case 'ASSIGNED':
        return 'Pendiente';
      case 'VISIT_IN_PROGRESS':
      case 'AWAITING_REPORT':
        return 'En proceso';
      case 'CANCELLED':
        return 'Cancelada';
      default:
        return substatus;
    }
  }

  Widget _buildStatusPill(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'Pendiente':
        bgColor = const Color(0xFFFFD78D);
        textColor = Colors.orange;
        break;
      case 'En proceso':
        bgColor = const Color(0xFFD6E4FF);
        textColor = const Color(0xFF1890FF);
        break;
      case 'Cancelada':
        bgColor = const Color(0xFFFFF1F0);
        textColor = const Color(0xFFF5222D);
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF8C8C8C);
    }
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 2.0, 12.0, 2.0),
        child: Text(
          status,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 12.0),
                color: textColor,
              ),
        ),
      ),
    );
  }
}
