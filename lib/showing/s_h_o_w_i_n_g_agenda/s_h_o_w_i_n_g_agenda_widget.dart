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
import '/showing/s_h_o_w_i_n_g_to_navegation_app/s_h_o_w_i_n_g_to_navegation_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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

  const _AgendaVisit({
    required this.visitId,
    this.title = '',
    this.address = '',
    this.ownerName = '',
    this.date = '',
    this.time = '',
    this.imageUrl = '',
    this.substatus = '',
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
      _model.selectedDate = DateTime.now();
      _currentFetchedMonth = _model.selectedDate!;
      safeSetState(() {});
      await _fetchSchedule(
          _currentFetchedMonth.year, _currentFetchedMonth.month);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchSchedule(int year, int month) async {
    safeSetState(() => _loading = true);
    final token = currentAuthenticationToken ?? '';

    final res =
        await DOVIAAPIVisitContextGroup.getShowingAgentScheduleCall.call(
      authToken: token,
      year: year,
      month: month,
    );

    if (!res.succeeded) {
      if (mounted) safeSetState(() => _loading = false);
      return;
    }

    final rawData = getJsonField(res.jsonBody, r'$.data');
    if (rawData is! Map) {
      if (mounted) safeSetState(() => _loading = false);
      return;
    }

    final schedule = rawData['schedule'];
    if (schedule is! Map) {
      if (mounted) safeSetState(() => _loading = false);
      return;
    }

    final Map<String, List<_AgendaVisit>> newGrouped = {};
    for (final dateKey in schedule.keys) {
      final listRaw = schedule[dateKey];
      if (listRaw is List) {
        final parsedList = <_AgendaVisit>[];
        for (final v in listRaw) {
          if (v is Map) {
            final prop = v['property'] is Map ? v['property'] as Map : {};
            final loc = prop['location'] is Map ? prop['location'] as Map : {};
            final addressObj =
                loc['address'] is Map ? loc['address'] as Map : {};
            final slot = v['confirmedTimeSlot'] is Map
                ? v['confirmedTimeSlot'] as Map
                : {};

            parsedList.add(_AgendaVisit(
              visitId: v['id']?.toString() ?? '',
              title:
                  prop['name']?.toString() ?? prop['title']?.toString() ?? '',
              imageUrl: prop['image']?.toString() ?? '',
              address: addressObj['fullAddress']?.toString() ?? '',
              ownerName: v['ownerFullName']?.toString() ?? '',
              date: slot['date']?.toString() ?? '',
              time: slot['time']?.toString() ?? '',
              substatus: v['substatus']?.toString() ?? '',
            ));
          }
        }
        parsedList.sort((a, b) => a.time.compareTo(b.time));
        newGrouped[dateKey] = parsedList;
      }
    }

    if (mounted) {
      safeSetState(() {
        _groupedVisits = newGrouped;
        _loading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    if (date.year != _currentFetchedMonth.year ||
        date.month != _currentFetchedMonth.month) {
      _currentFetchedMonth = date;
      _model.selectedDate = date;
      _fetchSchedule(date.year, date.month);
    } else {
      safeSetState(() {
        _model.selectedDate = date;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    String filterDateStr = '';
    if (_model.selectedDate != null) {
      final d = _model.selectedDate!;
      filterDateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    List<String> visibleDates = _groupedVisits.keys.toList()..sort();
    if (filterDateStr.isNotEmpty && _groupedVisits.containsKey(filterDateStr)) {
      visibleDates = [filterDateStr];
    } else if (filterDateStr.isNotEmpty) {
      visibleDates = [];
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
                                  initialDate:
                                      _model.selectedDate ?? DateTime.now(),
                                  onDateSelected: (newDate) {
                                    if (newDate != null)
                                      _onDateSelected(newDate);
                                  },
                                ),
                              ),
                            ),
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 60.0),
                                child: CircularProgressIndicator(
                                    color: Color(0xFF007376)),
                              )
                            else if (visibleDates.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 60.0),
                                child: Text(
                                  'No tienes visitas agendadas para esta fecha.',
                                  style: TextStyle(color: Colors.grey),
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

  Widget _buildVisitCard(_AgendaVisit visit) {
    final primary = const Color(0xFF007376);
    final isToday = _isToday(visit.date);

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
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return Dialog(
                                    elevation: 0,
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    alignment: const AlignmentDirectional(
                                            0.0, 0.0)
                                        .resolve(Directionality.of(context)),
                                    child: const SHOWINGToNavegationAppWidget(),
                                  );
                                },
                              );
                            },
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
