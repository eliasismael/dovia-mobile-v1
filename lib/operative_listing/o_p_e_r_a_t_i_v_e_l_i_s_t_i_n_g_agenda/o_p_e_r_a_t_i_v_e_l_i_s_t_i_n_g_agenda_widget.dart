import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_primera_visita/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_primera_visita_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_agenda_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_agenda_model.dart';

// ── Data model for an agenda visit card ─────────────────────────────
class _AgendaVisitData {
  final String visitId;
  final String propertyName;
  final String address;
  final String date; // "2026-05-19"
  final String time; // "10:00"

  const _AgendaVisitData({
    required this.visitId,
    required this.propertyName,
    required this.address,
    required this.date,
    required this.time,
  });
}

class OPERATIVELISTINGAgendaWidget extends StatefulWidget {
  const OPERATIVELISTINGAgendaWidget({super.key});

  static String routeName = 'OPERATIVE_LISTING_Agenda';
  static String routePath = '/oPERATIVELISTINGAgenda';

  @override
  State<OPERATIVELISTINGAgendaWidget> createState() =>
      _OPERATIVELISTINGAgendaWidgetState();
}

class _OPERATIVELISTINGAgendaWidgetState
    extends State<OPERATIVELISTINGAgendaWidget> {
  late OPERATIVELISTINGAgendaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = true;
  List<_AgendaVisitData> _allVisits = [];
  Map<String, List<_AgendaVisitData>> _groupedVisits = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGAgendaModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.selectedDate = getCurrentTimestamp;
      safeSetState(() {});
      await _fetchVisits();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchVisits() async {
    final token = currentAuthenticationToken ?? '';

    final listRes =
        await DOVIAAPIVisitContextGroup.getOperativeListerVisitsCall.call(
      authToken: token,
      substatus: 'ASSIGNED',
      page: '1',
      limit: '50',
    );

    if (!listRes.succeeded) {
      if (mounted) safeSetState(() => _loading = false);
      return;
    }

    final raw = getJsonField(listRes.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    // Sort ascending by date+time
    visits.sort((a, b) {
      final da = _slotStr(a, 'confirmedSlot', 'date');
      final ta = _slotStr(a, 'confirmedSlot', 'time');
      final db = _slotStr(b, 'confirmedSlot', 'date');
      final tb = _slotStr(b, 'confirmedSlot', 'time');
      final cmp = da.compareTo(db);
      return cmp != 0 ? cmp : ta.compareTo(tb);
    });

    // We also need the property details from overview to show address/propertyName
    final overviewFutures = visits.map((v) {
      final id = v is Map ? v['id']?.toString() ?? '' : '';
      return DOVIAAPIVisitContextGroup.getOperativeListerVisitOverviewCall
          .call(authToken: token, visitId: id);
    }).toList();

    final overviews = await Future.wait(overviewFutures);

    final result = <_AgendaVisitData>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      final visitId = v is Map ? v['id']?.toString() ?? '' : '';
      final date = _slotStr(v, 'confirmedSlot', 'date');
      final time = _slotStr(v, 'confirmedSlot', 'time');

      final ov = overviews[i];
      String propertyName = '';
      String address = '';

      if (ov.succeeded) {
        final data = getJsonField(ov.jsonBody, r'$.data');
        if (data is Map) {
          final prop = data['property'];
          if (prop is Map) {
            propertyName =
                prop['name']?.toString() ?? prop['title']?.toString() ?? '';
            final locAddr = _deepMap(prop, ['location', 'address']);
            address = locAddr?['fullAddress']?.toString() ??
                locAddr?['street']?.toString() ??
                '';
          }
        }
      }

      if (propertyName.isEmpty && address.isNotEmpty) {
        propertyName = address;
        address = '';
      }

      result.add(_AgendaVisitData(
        visitId: visitId,
        propertyName: propertyName,
        address: address,
        date: date,
        time: time,
      ));
    }

    if (mounted) {
      safeSetState(() {
        _allVisits = result;
        _groupVisits();
        _loading = false;
      });
    }
  }

  void _groupVisits() {
    _groupedVisits.clear();
    for (var visit in _allVisits) {
      final key = visit.date;
      if (key.isEmpty) continue;
      if (!_groupedVisits.containsKey(key)) {
        _groupedVisits[key] = [];
      }
      _groupedVisits[key]!.add(visit);
    }
  }

  String _slotStr(dynamic visit, String slotKey, String field) {
    if (visit is! Map) return '';
    final slot = visit[slotKey];
    if (slot is! Map) return '';
    return slot[field]?.toString() ?? '';
  }

  Map<String, dynamic>? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur as Map<String, dynamic> : null;
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime dt = DateTime.parse(dateStr);
      final List<String> weekdays = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo'
      ];
      final List<String> months = [
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
      return '${weekdays[dt.weekday - 1]}, ${dt.day} de ${months[dt.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateShort(String dateStr) {
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  bool _isToday(String dateStr) {
    try {
      final DateTime dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si se seleccionó una fecha en DateSelector, mostramos solo esa fecha.
    // Convertimos _model.selectedDate a string 'YYYY-MM-DD' para filtrar.
    String filterDateStr = '';
    if (_model.selectedDate != null) {
      final d = _model.selectedDate!;
      filterDateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    List<String> visibleDates = _groupedVisits.keys.toList();
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
                      model: _model.oPERATIVELISTINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGHeaderWidget(
                        titleText: 'Agenda',
                      ),
                    ),
                    Padding(
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
                                onDateSelected: (newDate) async {
                                  _model.selectedDate = newDate;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFF007376),
                              ),
                            )
                          else if (visibleDates.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60.0),
                              child: Text(
                                'No hay visitas asignadas para esta fecha.',
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
                                      _formatDate(dateKey),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  ..._groupedVisits[dateKey]!.map((visit) {
                                    return _buildVisitCard(context, visit);
                                  }),
                                ],
                              );
                            }),
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
                      model: _model.oPERATIVELISTINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGNavbarWidget(),
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

  Widget _buildVisitCard(BuildContext context, _AgendaVisitData visit) {
    return GestureDetector(
      onTap: () {
        final isReadOnly = !_isToday(visit.date);
        context.pushNamed(
          OPERATIVELISTINGPrimeraVisitaWidget.routeName,
          queryParameters: {
            'visitId': serializeParam(visit.visitId, ParamType.String),
            'isPrimeraVisita': serializeParam(true, ParamType.bool),
            'propertyName':
                serializeParam(visit.propertyName, ParamType.String),
            'isReadOnly': serializeParam(isReadOnly, ParamType.bool),
          }.withoutNulls,
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 15.0, 20.0, 15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.propertyName.isNotEmpty
                            ? visit.propertyName
                            : 'Dirección',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDateShort(visit.date)} a las ${visit.time}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                  fontWeight: FontWeight.normal),
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF5A5A5A),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).accent1,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.remove_red_eye,
                        color: Color(0xFF007376),
                        size: 14.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
