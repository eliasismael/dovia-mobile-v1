import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/showing/s_h_o_w_i_n_g_to_navegation_app/s_h_o_w_i_n_g_to_navegation_app_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import 's_h_o_w_i_n_g_header_model.dart';
import '/shared_components/notification_badge.dart';
export 's_h_o_w_i_n_g_header_model.dart';

class SHOWINGHeaderWidget extends StatefulWidget {
  const SHOWINGHeaderWidget({
    super.key,
    required this.title,
    this.actionWidget,
    this.showRouteButton = false,
  });

  final String? title;
  final Widget? actionWidget;

  /// Botón para iniciar la ruta a la visita de hoy: sólo en el home.
  final bool showRouteButton;

  @override
  State<SHOWINGHeaderWidget> createState() => _SHOWINGHeaderWidgetState();
}

class _SHOWINGHeaderWidgetState extends State<SHOWINGHeaderWidget> {
  late SHOWINGHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  bool _openingMap = false;

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// El mapa solo se abre si el Showing tiene una visita asignada hoy.
  /// Lleva a la próxima del día (o a la última, si ya pasaron todas).
  Future<void> _openTodayVisitMap() async {
    if (_openingMap) return;
    _openingMap = true;
    try {
      final token = currentAuthenticationToken ?? '';
      final res = await DOVIAAPIVisitContextGroup.getShowingAgentVisitsCall
          .call(authToken: token, page: '1', limit: '50');
      if (!mounted) return;
      final raw = res.succeeded ? getJsonField(res.jsonBody, r'$.data') : null;
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      final today = <({String id, String time})>[];
      for (final v in raw is List ? raw : const []) {
        if (v is! Map) continue;
        final slot = v['confirmedTimeSlot'];
        if (slot is! Map || slot['date']?.toString() != todayStr) continue;
        final id = v['visitId']?.toString() ?? v['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          today.add((id: id, time: slot['time']?.toString() ?? ''));
        }
      }
      if (today.isEmpty) {
        _snack('No tenés visitas para hoy.');
        return;
      }
      today.sort((a, b) => a.time.compareTo(b.time));
      final nowHm = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
      final next = today.firstWhere((v) => v.time.compareTo(nowHm) >= 0,
          orElse: () => today.last);

      // Dirección y coordenadas de la propiedad de esa visita.
      final ov = await DOVIAAPIVisitContextGroup.getShowingVisitOverviewCall
          .call(authToken: token, visitId: next.id);
      if (!mounted) return;
      final prop =
          ov.succeeded ? getJsonField(ov.jsonBody, r'$.data.property') : null;
      String query = '';
      if (prop is Map) {
        final location = prop['location'];
        final geo = location is Map ? location['geo'] : null;
        final coords = geo is Map ? geo['coordinates'] : null;
        final address = location is Map ? location['address'] : null;
        if (coords is List && coords.length >= 2) {
          query = '${coords[1]},${coords[0]}'; // GeoJSON: [lng, lat]
        } else if (address is Map) {
          query = address['fullAddress']?.toString() ?? '';
        }
      }
      if (query.isEmpty) {
        _snack('Tu visita de hoy no tiene dirección cargada.');
        return;
      }

      final go = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => const Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: SHOWINGToNavegationAppWidget(),
        ),
      );
      if (go != true) return;
      final uri = Uri.parse('https://www.google.com/maps/dir/?api=1'
          '&destination=${Uri.encodeComponent(query)}');
      var opened = false;
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!opened) _snack('No se pudo abrir el mapa');
    } finally {
      _openingMap = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 42.0, 20.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.safePop();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SvgPicture.asset(
                        'assets/images/IconoVolverAtras.svg',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    context.pushNamed(SHOWINGHomeWidget.routeName);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: SvgPicture.asset(
                      'assets/images/D-verde.svg',
                      width: 28.0,
                      height: 36.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ].divide(const SizedBox(width: 8.0)),
            ),
          ),
          // Expanded + margen: nombres largos bajan de linea en vez
          // de pegarse al logo.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.title!,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    )
                  ],
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          widget.actionWidget ??
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(SHOWINGAgendaWidget.routeName);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: SvgPicture.asset(
                          'assets/images/calendar.svg',
                          width: 8.0,
                          height: 8.0,
                          fit: BoxFit.none,
                        ),
                      ),
                    ),
                  ),
                  if (widget.showRouteButton)
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await _openTodayVisitMap();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: SvgPicture.asset(
                            'assets/images/Vector23.svg',
                            width: 8.0,
                            height: 8.0,
                            fit: BoxFit.none,
                          ),
                        ),
                      ),
                    ),
                  // Notificaciones: pasó de la barra de abajo al header.
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(SHOWINGNotificationsWidget.routeName);
                      },
                      child: Center(
                        child: NotificationBadge(
                            child: SvgPicture.asset(
                          'assets/images/DH_icono-navbar-notificaciones.svg',
                          width: 20.0,
                          height: 20.0,
                          fit: BoxFit.contain,
                        )),
                      ),
                    ),
                  ),
                ].divide(const SizedBox(width: 8.0)),
              ),
        ],
      ),
    );
  }
}
