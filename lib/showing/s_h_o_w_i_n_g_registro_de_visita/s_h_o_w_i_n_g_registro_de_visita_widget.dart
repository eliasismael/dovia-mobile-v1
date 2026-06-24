import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/showing/s_h_o_w_i_n_g_registro_de_visita_2/s_h_o_w_i_n_g_registro_de_visita2_widget.dart';
import '/showing/s_h_o_w_i_n_g_report_popup/s_h_o_w_i_n_g_report_popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 's_h_o_w_i_n_g_registro_de_visita_model.dart';
export 's_h_o_w_i_n_g_registro_de_visita_model.dart';

// ── A single visit row inside a date block of the schedule ─────────────────
class _ScheduleVisit {
  final String visitId;
  final String title;
  final String address;
  final String ownerName;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String imageUrl;
  final String substatus;

  const _ScheduleVisit({
    required this.visitId,
    this.title = '',
    this.address = '',
    this.ownerName = '',
    this.date = '',
    this.time = '',
    this.imageUrl = '',
    this.substatus = '',
  });

  static _ScheduleVisit fromJson(dynamic j, String dateKey) {
    String title = '';
    String address = '';
    String image = '';
    if (j is Map && j['property'] is Map) {
      final prop = j['property'] as Map;
      title = prop['name']?.toString() ?? '';
      image = prop['image']?.toString() ?? '';
      final addr = prop['address'];
      if (addr is Map) {
        address = addr['fullAddress']?.toString() ?? '';
      }
    }
    String time = '';
    if (j is Map && j['confirmedTimeSlot'] is Map) {
      time = (j['confirmedTimeSlot'] as Map)['time']?.toString() ?? '';
    }
    return _ScheduleVisit(
      visitId: j is Map ? j['id']?.toString() ?? '' : '',
      title: title,
      address: address,
      ownerName: j is Map ? j['ownerFullName']?.toString() ?? '' : '',
      date: dateKey,
      time: time,
      imageUrl: image,
      substatus: j is Map ? j['substatus']?.toString() ?? '' : '',
    );
  }
}

class SHOWINGRegistroDeVisitaWidget extends StatefulWidget {
  const SHOWINGRegistroDeVisitaWidget({super.key});

  static String routeName = 'SHOWING_RegistroDeVisita';
  static String routePath = '/sHOWINGRegistroDeVisita';

  @override
  State<SHOWINGRegistroDeVisitaWidget> createState() =>
      _SHOWINGRegistroDeVisitaWidgetState();
}

class _SHOWINGRegistroDeVisitaWidgetState
    extends State<SHOWINGRegistroDeVisitaWidget> {
  late SHOWINGRegistroDeVisitaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color aqua = Color(0xFF007376);
  static const Color reportRed = Color(0xFFC90A0A);

  Future<Map<String, List<_ScheduleVisit>>>? _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGRegistroDeVisitaModel());
    _scheduleFuture = _fetchSchedule();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Fetch the current month's schedule, grouped by date (yyyy-MM-dd) ──────
  Future<Map<String, List<_ScheduleVisit>>> _fetchSchedule() async {
    final token = currentAuthenticationToken ?? '';
    final now = DateTime.now();
    final res = await DOVIAAPIVisitContextGroup.getShowingAgentScheduleCall.call(
      authToken: token,
      year: now.year,
      month: now.month,
    );
    if (!res.succeeded) return {};

    final schedule = getJsonField(res.jsonBody, r'$.schedule');
    final out = <String, List<_ScheduleVisit>>{};
    if (schedule is Map) {
      schedule.forEach((key, value) {
        final dateKey = key.toString();
        final items = value is List ? value : <dynamic>[];
        out[dateKey] =
            items.map((e) => _ScheduleVisit.fromJson(e, dateKey)).toList();
      });
    }
    return out;
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(String raw) {
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    return '$d de ${months[m]} de ${parts[0]}';
  }

  void _openForm(String visitId) {
    context.pushNamed(
      SHOWINGRegistroDeVisita2Widget.routeName,
      queryParameters: {
        'visitId': serializeParam(visitId, ParamType.String),
      }.withoutNulls,
    );
  }

  Future<void> _onReport(String visitId) async {
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const SHOWINGReportPopupWidget(),
        );
      },
    );
    if (message == null || message.trim().isEmpty) return;

    final res = await DOVIAAPIVisitContextGroup.showingReportProblemCall.call(
      authToken: currentAuthenticationToken,
      visitId: visitId,
      message: message.trim(),
    );
    if (!mounted) return;

    if (res.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reporte enviado.',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      safeSetState(() => _scheduleFuture = _fetchSchedule());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el reporte.')),
      );
    }
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
                        title: 'Registro de visita',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 24.0),
                          FutureBuilder<Map<String, List<_ScheduleVisit>>>(
                            future: _scheduleFuture,
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              return _buildSections(snap.data!);
                            },
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

  // ── Build date blocks (today/future) + "Visitas Vencidas" (past) ─────────
  Widget _buildSections(Map<String, List<_ScheduleVisit>> schedule) {
    if (schedule.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No tienes visitas asignadas este mes.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      );
    }

    final today = _todayStr();
    final dates = schedule.keys.toList()..sort();
    final future = dates.where((d) => d.compareTo(today) >= 0).toList();
    final past = dates.where((d) => d.compareTo(today) < 0).toList();

    // Overdue = past visits still actionable (exclude cancelled)
    final overdue = <_ScheduleVisit>[];
    for (final d in past) {
      for (final v in schedule[d]!) {
        if (v.substatus != 'CANCELLED') overdue.add(v);
      }
    }

    final children = <Widget>[];
    for (final d in future) {
      final isToday = d == today;
      children.add(_buildSectionTitle(
          isToday ? 'Hoy ${_formatDate(d)}' : _formatDate(d)));
      children.add(const SizedBox(height: 14.0));
      for (final v in schedule[d]!) {
        children.add(Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 14.0),
          child: _buildVisitCard(visit: v, isOverdue: false),
        ));
      }
      children.add(const SizedBox(height: 10.0));
    }

    if (overdue.isNotEmpty) {
      children.add(_buildSectionTitle('Visitas Vencidas'));
      children.add(const SizedBox(height: 14.0));
      for (final v in overdue) {
        children.add(Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 14.0),
          child: _buildVisitCard(visit: v, isOverdue: true),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // ==================== AI SEARCH BAR (visual) ====================
  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.search_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 22.0,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                'Búsqueda con IA',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(
                        fontWeight: FontWeight.normal,
                      ),
                      color: const Color(0x80888888),
                      fontSize: 15.0,
                      letterSpacing: 0.3,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION TITLE ====================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(
              fontWeight: FontWeight.w600,
            ),
            color: const Color(0xFF00444B),
            fontSize: 17.0,
            letterSpacing: 0.34,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  // ==================== VISIT CARD ====================
  Widget _buildVisitCard({
    required _ScheduleVisit visit,
    required bool isOverdue,
  }) {
    final isCancelled = visit.substatus == 'CANCELLED';
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (!isOverdue && !isCancelled) {
          _openForm(visit.visitId);
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: visit.imageUrl.isNotEmpty
                    ? Image.network(
                        visit.imageUrl,
                        width: 80.0,
                        height: 130.0,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/casa_card_sobreMiVisita.png',
                          width: 80.0,
                          height: 130.0,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/casa_card_sobreMiVisita.png',
                        width: 80.0,
                        height: 130.0,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 14.0),
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
                            font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w500,
                            ),
                            color: const Color(0xFF00444B),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    if (visit.address.isNotEmpty)
                      _buildCardLine('Dirección: ${visit.address}'),
                    _buildCardLine('Fecha: ${_formatDate(visit.date)}'),
                    if (visit.time.isNotEmpty)
                      _buildCardLine('Hora: ${visit.time}'),
                    if (visit.ownerName.isNotEmpty)
                      _buildCardLine(visit.ownerName),
                    const SizedBox(height: 12.0),
                    if (isCancelled)
                      _buildCardLine('Cancelada')
                    else
                      FFButtonWidget(
                        onPressed: () async {
                          if (isOverdue) {
                            await _onReport(visit.visitId);
                          } else {
                            _openForm(visit.visitId);
                          }
                        },
                        text: isOverdue ? 'Reportar' : 'Registrar visita',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 32.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: isOverdue ? reportRed : aqua,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
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

  Widget _buildCardLine(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(
                fontWeight: FontWeight.normal,
              ),
              color: aqua,
              fontSize: 12.0,
            ),
      ),
    );
  }
}
