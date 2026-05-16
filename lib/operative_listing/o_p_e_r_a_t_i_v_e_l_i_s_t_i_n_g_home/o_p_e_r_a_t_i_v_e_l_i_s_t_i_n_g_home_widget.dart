import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_home_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_home_model.dart';

// ── Data model for a fully-enriched visit card ─────────────────────────────
class _VisitCardData {
  final String visitId;
  final String propertyName;
  final String address;
  final String ownerName;
  final String date;   // "2026-05-19"
  final String time;   // "10:00"
  final double? lat;
  final double? lng;

  const _VisitCardData({
    required this.visitId,
    required this.propertyName,
    required this.address,
    required this.ownerName,
    required this.date,
    required this.time,
    this.lat,
    this.lng,
  });
}

class OPERATIVELISTINGHomeWidget extends StatefulWidget {
  const OPERATIVELISTINGHomeWidget({super.key});

  static String routeName = 'OPERATIVE_LISTING_Home';
  static String routePath = '/oPERATIVELISTINGHome';

  @override
  State<OPERATIVELISTINGHomeWidget> createState() =>
      _OPERATIVELISTINGHomeWidgetState();
}

class _OPERATIVELISTINGHomeWidgetState
    extends State<OPERATIVELISTINGHomeWidget> {
  late OPERATIVELISTINGHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Each future resolves to an enriched list by calling list + overview per visit
  Future<List<_VisitCardData>>? _upcomingFuture;
  Future<List<_VisitCardData>>? _pendingFuture;

  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);
  static const Color _pillBg = Color(0xFFCCE3E4);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGHomeModel());
    _upcomingFuture = _fetchEnriched(substatus: 'ASSIGNED');
    // Pendientes = MISSING_INFO + RESCHEDULE_REQUIRED merged
    _pendingFuture = Future.wait([
      _fetchEnriched(substatus: 'MISSING_INFO'),
      _fetchEnriched(substatus: 'RESCHEDULE_REQUIRED'),
    ]).then((lists) => [...lists[0], ...lists[1]]);
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Fetch list then enrich each visit with its overview ─────────────────
  Future<List<_VisitCardData>> _fetchEnriched({required String substatus}) async {
    final token = currentAuthenticationToken ?? '';

    final listRes = await DOVIAAPIVisitContextGroup
        .getOperativeListerVisitsCall
        .call(
      authToken: token,
      substatus: substatus,
      page: '1',
      limit: '10',
    );

    if (!listRes.succeeded) return [];

    // List response: data is a flat array
    final raw = getJsonField(listRes.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    // Sort ascending by date+time before enriching
    visits.sort((a, b) {
      final da = _slotStr(a, 'confirmedSlot', 'date');
      final ta = _slotStr(a, 'confirmedSlot', 'time');
      final db = _slotStr(b, 'confirmedSlot', 'date');
      final tb = _slotStr(b, 'confirmedSlot', 'time');
      final cmp = da.compareTo(db);
      return cmp != 0 ? cmp : ta.compareTo(tb);
    });

    // Parallel overview calls
    final overviewFutures = visits.map((v) {
      final id = v is Map ? v['id']?.toString() ?? '' : '';
      return DOVIAAPIVisitContextGroup
          .getOperativeListerVisitOverviewCall
          .call(authToken: token, visitId: id);
    }).toList();

    final overviews = await Future.wait(overviewFutures);

    final result = <_VisitCardData>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      final visitId = v is Map ? v['id']?.toString() ?? '' : '';

      // Fast path: date/time from list (confirmedSlot)
      final date = _slotStr(v, 'confirmedSlot', 'date');
      final time = _slotStr(v, 'confirmedSlot', 'time');

      // Enrich from overview
      final ov = overviews[i];
      String propertyName = '';
      String address = '';
      String ownerName = '';
      double? lat;
      double? lng;

      if (ov.succeeded) {
        final data = getJsonField(ov.jsonBody, r'$.data');
        if (data is Map) {
          final prop = data['property'];
          if (prop is Map) {
            propertyName = prop['name']?.toString() ??
                prop['title']?.toString() ?? '';
            final locAddr = _deepMap(prop, ['location', 'address']);
            address = locAddr?['fullAddress']?.toString() ??
                locAddr?['street']?.toString() ?? '';
            final coords = _deepValue(prop, ['location', 'geo', 'coordinates']);
            if (coords is List && coords.length >= 2) {
              lng = (coords[0] as num?)?.toDouble();
              lat = (coords[1] as num?)?.toDouble();
            }
          }
          final owner = data['ownerProfile'];
          if (owner is Map) {
            ownerName = owner['fullName']?.toString() ?? '';
          }
        }
      }

      // Fallback: if no property name, show address
      if (propertyName.isEmpty && address.isNotEmpty) {
        propertyName = address;
        address = '';
      }

      result.add(_VisitCardData(
        visitId: visitId,
        propertyName: propertyName,
        address: address,
        ownerName: ownerName,
        date: date,
        time: time,
        lat: lat,
        lng: lng,
      ));
    }
    return result;
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

  dynamic _deepValue(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur;
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
                      model: _model.oPERATIVELISTINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGHeaderWidget(
                        titleText: 'Home',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // ── Tus próximas visitas ────────────────────────
                          FutureBuilder<List<_VisitCardData>>(
                            future: _upcomingFuture,
                            builder: (context, snap) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(
                                    'Tus próximas visitas',
                                    onVerMas: () => context.pushNamed(
                                        OPERATIVELISTINGAgendaWidget.routeName),
                                    topPadding: 32,
                                  ),
                                  if (!snap.hasData)
                                    _loader()
                                  else if (snap.data!.isEmpty)
                                    _emptyMsg('No tienes próximas visitas.')
                                  else
                                    SizedBox(
                                      height: 190,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snap.data!.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (ctx, i) => _UpcomingCard(
                                          data: snap.data![i],
                                          onVoyEnCamino: () => context.pushNamed(
                                              OPERATIVELISTINGPrimeraVisitaWidget
                                                  .routeName),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          // ── Pendientes ──────────────────────────────────
                          FutureBuilder<List<_VisitCardData>>(
                            future: _pendingFuture,
                            builder: (context, snap) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(
                                    'Pendientes',
                                    onVerMas: () => context.pushNamed(
                                        OPERATIVELISTINGAgendaWidget.routeName),
                                  ),
                                  if (!snap.hasData)
                                    _loader()
                                  else if (snap.data!.isEmpty)
                                    _emptyMsg('No tienes visitas pendientes.')
                                  else
                                    SizedBox(
                                      height: 150,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snap.data!.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (ctx, i) =>
                                            _PendingCard(data: snap.data![i]),
                                      ),
                                    ),
                                ],
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

  Widget _sectionHeader(
    String title, {
    required VoidCallback onVerMas,
    double topPadding = 24,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, topPadding, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: _dark,
                  fontSize: 17,
                  letterSpacing: 0.34,
                  fontWeight: FontWeight.w600,
                ),
          ),
          GestureDetector(
            onTap: onVerMas,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _pillBg,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: Alignment.center,
              child: Text(
                'Ver más',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(),
                      color: _primary,
                      fontSize: 14,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loader() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _emptyMsg(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      );
}

// ── Upcoming visit card ────────────────────────────────────────────────────
class _UpcomingCard extends StatelessWidget {
  final _VisitCardData data;
  final VoidCallback onVoyEnCamino;

  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);

  const _UpcomingCard({required this.data, required this.onVoyEnCamino});

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
        const months = [
          '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
          'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
        ];
        final m = int.tryParse(parts[1]) ?? 0;
        return '${parts[2]} de ${months[m]} de ${parts[0]}';
      }
    } catch (_) {}
    return raw;
  }

  Future<void> _openMaps(BuildContext ctx) async {
    if (data.lat == null || data.lng == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
            content: Text('Coordenadas no disponibles para esta propiedad')),
      );
      return;
    }
    final lat = data.lat!;
    final lng = data.lng!;
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } else {
      final googleUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property name
          Text(
            data.propertyName.isNotEmpty ? data.propertyName : 'Propiedad',
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _dark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Address
          if (data.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Dirección: ${data.address}',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                color: _primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Owner name
          if (data.ownerName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              data.ownerName,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                color: _primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Date
          if (data.date.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Fecha: ${_formatDate(data.date)}',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                color: _dark,
              ),
            ),
          ],
          // Time
          if (data.time.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Hora: ${data.time}',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                color: _dark,
              ),
            ),
          ],
          const Spacer(),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openMaps(context),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF70ACAD).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Ubicación',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: _dark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onVoyEnCamino,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Voy en camino',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pending visit card ─────────────────────────────────────────────────────
class _PendingCard extends StatelessWidget {
  final _VisitCardData data;

  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);
  static const Color _badgeBg = Color(0xFFF8D5D5);
  static const Color _badgeText = Color(0xFFBC0000);

  const _PendingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Placeholder image (no image URL in overview response)
          Container(
            width: 72,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home_outlined, color: Colors.grey, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.propertyName.isNotEmpty ? data.propertyName : 'Propiedad',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (data.address.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Dirección: ${data.address}',
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      color: _primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (data.ownerName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    data.ownerName,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      color: _primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                // Falta información badge
                Container(
                  width: double.infinity,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Falta información',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _badgeText,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Re-agendar button
                Container(
                  width: double.infinity,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Re-agendar cita con HQ',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
