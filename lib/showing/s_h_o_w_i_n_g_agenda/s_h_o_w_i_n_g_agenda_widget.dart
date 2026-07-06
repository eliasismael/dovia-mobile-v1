import '/backend/api_requests/api_visits.dart';
import '/auth/custom_auth/auth_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/showing/s_h_o_w_i_n_g_propiedad_a_mostrar/s_h_o_w_i_n_g_propiedad_a_mostrar_widget.dart';
import '/showing/s_h_o_w_i_n_g_report_popup/s_h_o_w_i_n_g_report_popup_widget.dart';
import '/showing/s_h_o_w_i_n_g_to_navegation_app/s_h_o_w_i_n_g_to_navegation_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 's_h_o_w_i_n_g_agenda_model.dart';
export 's_h_o_w_i_n_g_agenda_model.dart';

class _AgendaVisit {
  final String visitId;
  final String title;
  final String address;
  final String ownerName;
  final String date;
  final String time;
  final String imageUrl;
  final String substatus;
  final double? lat;
  final double? lng;

  const _AgendaVisit({
    required this.visitId,
    this.title = '',
    this.address = '',
    this.ownerName = '',
    this.date = '',
    this.time = '',
    this.imageUrl = '',
    this.substatus = '',
    this.lat,
    this.lng,
  });
}

class SHOWINGAgendaWidget extends StatefulWidget {
  const SHOWINGAgendaWidget({super.key});

  static String routeName = 'SHOWING_Agenda';
  static String routePath = '/sHOWINGAgenda';

  @override
  State<SHOWINGAgendaWidget> createState() => _SHOWINGAgendaWidgetState();
}

class _SHOWINGAgendaWidgetState extends State<SHOWINGAgendaWidget> {
  late SHOWINGAgendaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;
  Map<String, List<_AgendaVisit>> _groupedVisits = {};
  DateTime _currentFetchedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGAgendaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Start with no day filter → show the whole month grouped by date.
      _model.selectedDate = null;
      _currentFetchedMonth = DateTime.now();
      safeSetState(() {});
      await _loadVisits();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // The Agenda mirrors the Home's data source (Get Showing Agent Visits +
  // per-visit overview) so it shows exactly the same assigned visits, across
  // every status, grouped by day. Fetched once; month/day filtering happens
  // client-side.
  Future<void> _loadVisits() async {
    safeSetState(() => _loading = true);
    final token = currentAuthenticationToken ?? '';

    final res = await DOVIAAPIVisitContextGroup.getShowingAgentVisitsCall.call(
      authToken: token,
      page: '1',
      limit: '100',
    );

    if (!res.succeeded) {
      if (mounted) safeSetState(() => _loading = false);
      return;
    }

    final raw = getJsonField(res.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    // Enrich each visit with title/address/owner/coordinates via its overview.
    final ovFutures = visits.map((v) {
      final id = v is Map ? v['visitId']?.toString() ?? '' : '';
      return DOVIAAPIVisitContextGroup.getShowingVisitOverviewCall
          .call(authToken: token, visitId: id);
    }).toList();
    final overviews = await Future.wait(ovFutures);

    final Map<String, List<_AgendaVisit>> grouped = {};
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      if (v is! Map) continue;

      String image = '';
      if (v['property'] is Map) {
        image = (v['property'] as Map)['image']?.toString() ?? '';
      }
      final slot =
          v['confirmedTimeSlot'] is Map ? v['confirmedTimeSlot'] as Map : {};
      final date = slot['date']?.toString() ?? '';
      final time = slot['time']?.toString() ?? '';

      String title = '';
      String address = '';
      String ownerName = v['ownerFullName']?.toString() ?? '';
      double? lat;
      double? lng;

      final ov = overviews[i];
      if (ov.succeeded) {
        final data = getJsonField(ov.jsonBody, r'$.data');
        if (data is Map) {
          final prop = data['property'];
          if (prop is Map) {
            title =
                prop['name']?.toString() ?? prop['title']?.toString() ?? '';
            if (image.isEmpty) image = prop['image']?.toString() ?? '';
            final addr = _deepMap(prop, ['location', 'address']);
            address = addr?['fullAddress']?.toString() ?? '';
            final coords = _deepValue(prop, ['location', 'geo', 'coordinates']);
            if (coords is List && coords.length >= 2) {
              lng = (coords[0] as num?)?.toDouble();
              lat = (coords[1] as num?)?.toDouble();
            }
          }
          final owner = data['ownerProfile'];
          if (owner is Map && ownerName.isEmpty) {
            ownerName = owner['fullName']?.toString() ?? '';
          }
        }
      }

      if (date.isEmpty) continue; // can't place it on the calendar

      (grouped[date] ??= []).add(_AgendaVisit(
        visitId: v['visitId']?.toString() ?? '',
        title: title,
        address: address,
        ownerName: ownerName,
        date: date,
        time: time,
        imageUrl: image,
        substatus: v['substatus']?.toString() ?? '',
        lat: lat,
        lng: lng,
      ));
    }

    for (final list in grouped.values) {
      list.sort((a, b) => a.time.compareTo(b.time));
    }

    if (mounted) {
      safeSetState(() {
        _groupedVisits = grouped;
        _loading = false;
      });
    }
  }

  Map? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur : null;
  }

  dynamic _deepValue(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur;
  }

  // Data is loaded once for all months; selecting a day just filters the list.
  void _onDateSelected(DateTime date) {
    safeSetState(() {
      _currentFetchedMonth = DateTime(date.year, date.month, 1);
      _model.selectedDate = date;
    });
  }

  // Arrows moved the month while no day was selected → show that month's full
  // (unfiltered) list.
  void _onMonthChanged(DateTime firstOfMonth) {
    safeSetState(() {
      _currentFetchedMonth = firstOfMonth;
      _model.selectedDate = null;
    });
  }

  // Clear the day filter and go back to the full month grouped by date.
  void _clearDayFilter() {
    safeSetState(() {
      _model.selectedDate = null;
    });
  }

  // Confirm and open the device navigation app for a visit, mirroring the
  // behaviour of the visit-detail screen. Prefers coordinates and falls back
  // to the address string.
  Future<void> _startRoute(_AgendaVisit visit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const SHOWINGToNavegationAppWidget(),
        );
      },
    );
    if (confirm != true) return;

    // Unlock the private contact info on the visit-detail screen too.
    if (visit.visitId.isNotEmpty) {
      try {
        FFAppState().addToRouteStartedVisits(visit.visitId);
      } catch (_) {}
    }

    String? query;
    if (visit.lat != null && visit.lng != null) {
      query = '${visit.lat},${visit.lng}';
    } else if (visit.address.isNotEmpty) {
      query = Uri.encodeComponent(visit.address);
    }

    if (query == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No hay ubicación disponible para esta visita.')),
        );
      }
      return;
    }

    final googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$query');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo abrir la app de navegación.')),
        );
      }
    } catch (_) {}
  }

  String _formatDateString(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '',
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
        'Diciembre'
      ];
      return '${dt.day} de ${months[dt.month]} de ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  bool _isToday(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    } catch (_) {
      return false;
    }
  }

  // A visit is "overdue" when >24h passed since its scheduled start and it
  // hasn't been registered/closed yet.
  bool _isOverdue(_AgendaVisit visit) {
    final s = visit.substatus.toUpperCase();
    if (s == 'COMPLETED' || s == 'CANCELLED') return false;
    if (visit.date.isEmpty) return false;
    try {
      final d = visit.date.split('-');
      final t = visit.time.isNotEmpty ? visit.time.split(':') : ['0', '0'];
      final dt = DateTime(
        int.parse(d[0]),
        int.parse(d[1]),
        int.parse(d[2]),
        int.parse(t[0]),
        t.length > 1 ? int.parse(t[1]) : 0,
      );
      return DateTime.now().difference(dt).inHours > 24;
    } catch (_) {
      return false;
    }
  }

  // Report an overdue visit: justify the delay, then unassign/republish it.
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
      _loadVisits();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el reporte.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String filterDateStr = '';
    if (_model.selectedDate != null) {
      final d = _model.selectedDate!;
      filterDateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    List<String> visibleDates;
    if (filterDateStr.isNotEmpty) {
      // A specific day is selected → show only that day.
      visibleDates =
          _groupedVisits.containsKey(filterDateStr) ? [filterDateStr] : [];
    } else {
      // Full-month view → every day of the displayed month, grouped by date.
      visibleDates = _groupedVisits.keys.where((k) {
        final dt = DateTime.tryParse(k);
        return dt != null &&
            dt.year == _currentFetchedMonth.year &&
            dt.month == _currentFetchedMonth.month;
      }).toList()
        ..sort();
    }

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
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.sHOWINGHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const SHOWINGHeaderWidget(
                      title: 'Agenda',
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 100.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 70.0,
                                child: custom_widgets.DateSelectorWidget(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 70.0,
                                  dayNavigation: true,
                                  selectedDate: _model.selectedDate,
                                  displayMonth: _currentFetchedMonth,
                                  onDateSelected: (newDate) {
                                    if (newDate != null)
                                      _onDateSelected(newDate);
                                  },
                                  onMonthChanged: (firstOfMonth) =>
                                      _onMonthChanged(firstOfMonth),
                                ),
                              ),
                            ),
                            if (_model.selectedDate != null)
                              _buildFilterChip(filterDateStr),
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 60.0),
                                child: CircularProgressIndicator(
                                    color: Color(0xFF007376)),
                              )
                            else if (visibleDates.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 60.0),
                                child: Text(
                                  _model.selectedDate != null
                                      ? 'No tienes visitas agendadas para esta fecha.'
                                      : 'No tienes visitas agendadas para este mes.',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              ...visibleDates.map((dateKey) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 20.0, 0.0, 10.0),
                                      child: Text(
                                        _isToday(dateKey)
                                            ? 'Hoy ${_formatDateString(dateKey)}'
                                            : _formatDateString(dateKey),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600),
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    ..._groupedVisits[dateKey]!.map((visit) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: _buildVisitCard(visit),
                                      );
                                    }),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.sHOWINGNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const SHOWINGNavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Banner shown above the list when a single day is being filtered, with a
  // shortcut back to the full-month view.
  Widget _buildFilterChip(String filterDateStr) {
    const primary = Color(0xFF007376);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mostrando ${_formatDateString(filterDateStr)}',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14.0),
                    color: const Color(0xFF0F3E48),
                  ),
            ),
          ),
          GestureDetector(
            onTap: _clearDayFilter,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: primary, width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, size: 14.0, color: primary),
                  const SizedBox(width: 4.0),
                  Text(
                    'Ver todo el mes',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 12.0),
                          color: primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(_AgendaVisit visit) {
    final primary = const Color(0xFF007376);
    final isToday = _isToday(visit.date);
    final overdue = _isOverdue(visit);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: visit.imageUrl.isNotEmpty
                  ? Image.network(
                      visit.imageUrl,
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
            ),
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
                            color: primary,
                          ),
                    ),
                  if (visit.time.isNotEmpty)
                    Text(
                      'Hora: ${visit.time}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: primary,
                          ),
                    ),
                  if (visit.ownerName.isNotEmpty)
                    Text(
                      visit.ownerName,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontSize: 12.0),
                            color: primary,
                          ),
                    ),
                  if (visit.substatus.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estatus',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(fontSize: 12.0),
                                    color: primary,
                                  ),
                        ),
                        _buildStatusPill(visit.substatus),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12.0),
                  if (overdue)
                    FFButtonWidget(
                      onPressed: () => _onReport(visit.visitId),
                      text: 'Reportar',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 30.0,
                        color: const Color(0xFFC90A0A),
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.inter(
                                      color: Colors.white, fontSize: 14.0),
                                ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    )
                  else
                    Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            context.pushNamed(
                              SHOWINGPropiedadAMostrarWidget.routeName,
                              queryParameters: {
                                'visitId': serializeParam(
                                    visit.visitId, ParamType.String),
                              }.withoutNulls,
                            );
                          },
                          text: 'Detalles',
                          options: FFButtonOptions(
                            height: 30.0,
                            color: Colors.transparent,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.inter(
                                      color: primary, fontSize: 14.0),
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(color: primary, width: 1.0),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () => _startRoute(visit),
                            text: 'Iniciar ruta',
                            options: FFButtonOptions(
                              height: 30.0,
                              color: primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                        color: Colors.white, fontSize: 14.0),
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String substatus) {
    String statusStr = substatus;
    Color bgColor = const Color(0xFFF5F5F5);
    Color textColor = const Color(0xFF8C8C8C);

    switch (substatus) {
      case 'ASSIGNED':
        statusStr = 'Pendiente';
        bgColor = const Color(0xFFFFD78D);
        textColor = Colors.orange;
        break;
      case 'VISIT_IN_PROGRESS':
      case 'AWAITING_REPORT':
        statusStr = 'En proceso';
        bgColor = const Color(0xFFD6E4FF);
        textColor = const Color(0xFF1890FF);
        break;
      case 'CANCELLED':
        statusStr = 'Cancelada';
        bgColor = const Color(0xFFFFF1F0);
        textColor = const Color(0xFFF5222D);
        break;
      case 'COMPLETED':
        statusStr = 'Registrada';
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF8C8C8C);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 2.0, 12.0, 2.0),
        child: Text(
          statusStr,
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
