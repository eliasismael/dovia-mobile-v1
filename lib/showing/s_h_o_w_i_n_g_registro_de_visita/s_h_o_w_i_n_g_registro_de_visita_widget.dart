import '/core/network_image_size.dart';
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

  Future<List<_ScheduleVisit>>? _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGRegistroDeVisitaModel());
    _scheduleFuture = _fetchPastVisits();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Fetch assigned past visits ──────────────────────────────────────────────────
  Future<List<_ScheduleVisit>> _fetchPastVisits() async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getShowingAgentVisitsCall.call(
      authToken: token,
      page: '1',
      limit: '100',
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

    final out = <_ScheduleVisit>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      if (v is! Map) continue;
      // Ya cerradas o reportadas: no van en la bandeja.
      final status = v['status']?.toString() ?? '';
      final sub = v['substatus']?.toString() ?? '';
      if (status == 'COMPLETED' ||
          status == 'CANCELLED' ||
          sub == 'NOT_COMPLETED_REPORTED' ||
          sub == 'PROBLEM_REPORTED') {
        continue;
      }
      final data = overviews[i].succeeded
          ? getJsonField(overviews[i].jsonBody, r'$.data')
          : null;
      final ov = data is Map ? data : const {};

      // El listado trae nombre, dirección, foto, propietario y horario; el
      // overview solo completa lo que falte.
      final summary = v['property'] is Map ? v['property'] as Map : const {};
      final owner = v['ownerProfile'] is Map
          ? v['ownerProfile'] as Map
          : (ov['ownerProfile'] is Map ? ov['ownerProfile'] as Map : const {});
      final ovVisit = ov['visit'] is Map ? ov['visit'] as Map : const {};
      final slot = v['confirmedTimeSlot'] ?? ovVisit['confirmedTimeSlot'];
      final ovAddr = _deepFullAddress(ov['property']);

      out.add(_ScheduleVisit(
        visitId: v['visitId']?.toString() ?? '',
        title: summary['name']?.toString() ?? '',
        address: summary['address']?.toString() ?? ovAddr,
        ownerName: owner['fullName']?.toString() ?? '',
        date: slot is Map ? slot['date']?.toString() ?? '' : '',
        time: slot is Map ? slot['time']?.toString() ?? '' : '',
        imageUrl: summary['image']?.toString() ?? '',
        substatus: sub,
      ));
    }
    return out;
  }

  String _deepFullAddress(dynamic prop) {
    final loc = prop is Map ? prop['location'] : null;
    final addr = loc is Map ? loc['address'] : null;
    return addr is Map ? addr['fullAddress']?.toString() ?? '' : '';
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
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    return '$d de ${months[m]} de ${parts[0]}';
  }

  // Al volver del formulario se recarga: la visita registrada desaparece.
  Future<void> _openForm(String visitId) async {
    await context.pushNamed(
      SHOWINGRegistroDeVisita2Widget.routeName,
      queryParameters: {
        'visitId': serializeParam(visitId, ParamType.String),
      }.withoutNulls,
    );
    if (mounted) safeSetState(() => _scheduleFuture = _fetchPastVisits());
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

    final res =
        await DOVIAAPIVisitContextGroup.showingNotCompletedReportCall.call(
      authToken: currentAuthenticationToken,
      visitId: visitId,
      reason: message.trim(),
    );
    if (!mounted) return;

    if (res.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reporte enviado a Listing HQ.',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      safeSetState(() => _scheduleFuture = _fetchPastVisits());
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
                          FutureBuilder<List<_ScheduleVisit>>(
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

  // ── Build date blocks ("Hoy" - En Plazo) + "Visitas Vencidas" (past 24h) ─────────
  Widget _buildSections(List<_ScheduleVisit> visits) {
    if (visits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No tienes visitas pendientes de registro.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      );
    }

    final now = DateTime.now();
    final enPlazo = <_ScheduleVisit>[];
    final vencidas = <_ScheduleVisit>[];

    for (final v in visits) {
      if (v.substatus == 'CANCELLED') continue;

      DateTime visitDt;
      try {
        final dateParts = v.date.split('-');
        final timeParts = v.time.split(':');
        visitDt = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]));
      } catch (_) {
        continue;
      }

      // If the visit is in the future, don't show it in the registration dashboard yet
      if (visitDt.isAfter(now)) {
        continue;
      }

      // Vencida = la marcó el backend (24 h después de terminada la visita
      // sin reporte pasa a REPORT_EXPIRED).
      if (v.substatus != 'REPORT_EXPIRED') {
        enPlazo.add(v);
      } else {
        vencidas.add(v);
      }
    }

    final children = <Widget>[];

    if (enPlazo.isNotEmpty) {
      children.add(_buildSectionTitle('Hoy ${_formatDate(_todayStr())}'));
      children.add(const SizedBox(height: 14.0));
      for (final v in enPlazo) {
        children.add(Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 14.0),
          child: _buildVisitCard(visit: v, isOverdue: false),
        ));
      }
      children.add(const SizedBox(height: 10.0));
    }

    if (vencidas.isNotEmpty) {
      children.add(_buildSectionTitle('Visitas Vencidas'));
      children.add(const SizedBox(height: 14.0));
      for (final v in vencidas) {
        children.add(Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 14.0),
          child: _buildVisitCard(visit: v, isOverdue: true),
        ));
      }
    }

    if (children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No tienes visitas pendientes de registro.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      );
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
                        cacheWidth:
                            networkImageCacheWidth(width: 80.0, height: 130.0),
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
