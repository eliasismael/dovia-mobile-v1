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
import '/shared_components/dovia_spinner.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_home_model.dart';

// ── Data model for a fully-enriched visit card ─────────────────────────────
class _VisitCardData {
  final String visitId;
  final String propertyName;
  final String address;
  final String ownerName;
  final String date; // "2026-05-19"
  final String time; // "10:00"
  final double? lat;
  final double? lng;

  /// Substatus con el que vino la visita: decide si todavía se puede reportar.
  final String substatus;

  /// Fecha y hora de la visita, si el backend la informa.
  DateTime? get slotDateTime {
    final d = DateTime.tryParse(date);
    if (d == null) return null;
    final parts = time.split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(d.year, d.month, d.day, h, m);
  }

  /// Pasaron 24 horas desde la visita y sigue sin hacerse: pasa a
  /// Pendientes para reagendarla con HQ.
  bool get isOverdue {
    final slot = slotDateTime;
    return substatus != 'RESCHEDULE_REQUIRED' &&
        slot != null &&
        DateTime.now().isAfter(slot.add(const Duration(hours: 24)));
  }

  const _VisitCardData({
    required this.visitId,
    required this.propertyName,
    required this.address,
    required this.ownerName,
    required this.date,
    required this.time,
    this.lat,
    this.lng,
    this.substatus = '',
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGHomeModel());
    _loadVisits();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Substatus de visitas ya asignadas a este operative. HQ asigna recién con
  /// la documentación aprobada, así que todas llegan como `ASSIGNED`.
  static const List<String> _kActiveSubstatuses = ['ASSIGNED'];

  /// Próximas = asignadas y en plazo. Pendientes = vencidas (24 h después
  /// de la visita sin hacerla) y las ya reportadas, que esperan a HQ.
  void _loadVisits() {
    final all = Future.wait([
      for (final sub in _kActiveSubstatuses) _fetchEnriched(substatus: sub),
      _fetchEnriched(substatus: 'RESCHEDULE_REQUIRED'),
    ]).then((lists) => lists.expand((l) => l).toList());

    int bySlot(_VisitCardData a, _VisitCardData b) {
      final da = a.slotDateTime, db = b.slotDateTime;
      if (da == null || db == null) return da == null ? 1 : -1;
      return da.compareTo(db);
    }

    _upcomingFuture = all.then((list) {
      final upcoming = list
          .where((v) => v.substatus != 'RESCHEDULE_REQUIRED' && !v.isOverdue)
          .toList()
        ..sort(bySlot);
      return upcoming;
    });
    _pendingFuture = all.then((list) => list
        .where((v) => v.substatus == 'RESCHEDULE_REQUIRED' || v.isOverdue)
        .toList()
      ..sort(bySlot));
  }

  /// Tras reagendar, la visita sale de próximas y aparece en Pendientes como
  /// "En revisión por HQ".
  void _reload() => safeSetState(_loadVisits);

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Fetch list then enrich each visit with its overview ─────────────────
  Future<List<_VisitCardData>> _fetchEnriched(
      {required String substatus}) async {
    final token = currentAuthenticationToken ?? '';

    final listRes =
        await DOVIAAPIVisitContextGroup.getOperativeListerVisitsCall.call(
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
      return DOVIAAPIVisitContextGroup.getOperativeListerVisitOverviewCall
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
            propertyName =
                prop['name']?.toString() ?? prop['title']?.toString() ?? '';
            final locAddr = _deepMap(prop, ['location', 'address']);
            address = locAddr?['fullAddress']?.toString() ??
                locAddr?['street']?.toString() ??
                '';
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
        substatus: substatus,
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

  /// Fila horizontal que toma el alto de la tarjeta más alta, en vez de un
  /// alto fijo que dejaba espacio vacío.
  Widget _horizontalCards(
      int count, Widget Function(BuildContext, int) itemBuilder) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              itemBuilder(context, i),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Es la pantalla raíz del operative: atrás de Android llevaba al login.
    return PopScope(
      canPop: false,
      child: GestureDetector(
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
                          showBack: false,
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
                                          OPERATIVELISTINGAgendaWidget
                                              .routeName),
                                      topPadding: 32,
                                    ),
                                    if (!snap.hasData)
                                      _loader()
                                    else if (snap.data!.isEmpty)
                                      _emptyMsg('No tienes próximas visitas.')
                                    else
                                      _horizontalCards(snap.data!.length,
                                          (ctx, i) {
                                        final cardData = snap.data![i];
                                        return _UpcomingCard(
                                          data: cardData,
                                          onCardTap: () => context.pushNamed(
                                            OPERATIVELISTINGPrimeraVisitaWidget
                                                .routeName,
                                            queryParameters: {
                                              'visitId': serializeParam(
                                                  cardData.visitId,
                                                  ParamType.String),
                                              'isPrimeraVisita': serializeParam(
                                                  false, ParamType.bool),
                                              'propertyName': serializeParam(
                                                  cardData.propertyName,
                                                  ParamType.String),
                                            }.withoutNulls,
                                          ),
                                          onVoyEnCamino: () =>
                                              context.pushNamed(
                                            OPERATIVELISTINGPrimeraVisitaWidget
                                                .routeName,
                                            queryParameters: {
                                              'visitId': serializeParam(
                                                  cardData.visitId,
                                                  ParamType.String),
                                              'isPrimeraVisita': serializeParam(
                                                  false, ParamType.bool),
                                              'propertyName': serializeParam(
                                                  cardData.propertyName,
                                                  ParamType.String),
                                            }.withoutNulls,
                                          ),
                                        );
                                      }),
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
                                          OPERATIVELISTINGAgendaWidget
                                              .routeName),
                                    ),
                                    if (!snap.hasData)
                                      _loader()
                                    else if (snap.data!.isEmpty)
                                      _emptyMsg('No tienes visitas pendientes.')
                                    else
                                      _horizontalCards(
                                          snap.data!.length,
                                          (ctx, i) => _PendingCard(
                                              data: snap.data![i],
                                              onRescheduled: _reload)),
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
          // Link de texto, con el estilo de los "Ver más" del resto de la app.
          GestureDetector(
            onTap: onVerMas,
            child: Text(
              'Ver más',
              style: GoogleFonts.publicSans(
                color: _primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loader() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: DoviaSpinner()),
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
class _UpcomingCard extends StatefulWidget {
  final _VisitCardData data;
  final VoidCallback onVoyEnCamino;
  final VoidCallback onCardTap;

  const _UpcomingCard({
    required this.data,
    required this.onVoyEnCamino,
    required this.onCardTap,
  });

  @override
  State<_UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<_UpcomingCard> {
  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
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
        return '${parts[2]} de ${months[m]} de ${parts[0]}';
      }
    } catch (_) {}
    return raw;
  }

  Future<void> _openMaps(BuildContext ctx) async {
    if (widget.data.lat == null || widget.data.lng == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
            content: Text('Coordenadas no disponibles para esta propiedad')),
      );
      return;
    }
    final lat = widget.data.lat!;
    final lng = widget.data.lng!;
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
    return GestureDetector(
      onTap: widget.onCardTap,
      child: Container(
        // Ocupa casi todo el ancho: con una sola visita no queda un hueco.
        width: MediaQuery.sizeOf(context).width - 56,
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
              widget.data.propertyName.isNotEmpty
                  ? widget.data.propertyName
                  : 'Propiedad',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Address
            if (widget.data.address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Dirección: ${widget.data.address}',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: _primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Owner name
            if (widget.data.ownerName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                widget.data.ownerName,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: _primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Date
            if (widget.data.date.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Fecha: ${_formatDate(widget.data.date)}',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 15,
                  color: _dark,
                ),
              ),
            ],
            // Time
            if (widget.data.time.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Hora: ${widget.data.time}',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 15,
                  color: _dark,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openMaps(context),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF70ACAD).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Ubicación',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          color: _dark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onVoyEnCamino,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Voy en camino',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
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
      ),
    );
  }
}

// ── Pending visit card ─────────────────────────────────────────────────────
class _PendingCard extends StatefulWidget {
  final _VisitCardData data;
  final VoidCallback onRescheduled;

  const _PendingCard({required this.data, required this.onRescheduled});

  @override
  State<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends State<_PendingCard> {
  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);
  static const Color _badgeBg = Color(0xFFF8D5D5);
  static const Color _badgeText = Color(0xFFBC0000);

  /// Ya reportada: espera a que HQ le asigne una fecha nueva.
  bool get _isUnderReview => widget.data.substatus == 'RESCHEDULE_REQUIRED';

  void _onReschedule() => _openReschedule(context,
      visitId: widget.data.visitId, onDone: widget.onRescheduled);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width - 56,
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
          Container(
            width: 72,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.home_outlined, color: Colors.grey, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.data.propertyName.isNotEmpty
                      ? widget.data.propertyName
                      : 'Propiedad',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.data.address.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Dirección: ${widget.data.address}',
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      color: _primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (widget.data.ownerName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.data.ownerName,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      color: _primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _isUnderReview ? const Color(0xFFFFF3CD) : _badgeBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isUnderReview ? 'En revisión por HQ' : 'Plazo vencido',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          _isUnderReview ? const Color(0xFF856404) : _badgeText,
                    ),
                  ),
                ),
                // Vencida: sin botones de navegación, solo reagendar.
                if (!_isUnderReview) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _onReschedule,
                    child: Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Reagendar con HQ',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reagendar con HQ ───────────────────────────────────────────────────────

/// Pide el motivo; si se envía, muestra el éxito y avisa para recargar.
void _openReschedule(BuildContext context,
    {required String visitId, required VoidCallback onDone}) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: _RescheduleReasonSheet(
        visitId: visitId,
        onSuccess: () async {
          Navigator.of(dialogContext).pop();
          await _showRescheduleSuccess(context);
          onDone();
        },
      ),
    ),
  );
}

Future<void> _showRescheduleSuccess(BuildContext context) {
  const primary = Color(0xFF007376);
  const dark = Color(0xFF00444B);
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              'Se envió con éxito',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pronto se comunicarán contigo desde HQ para reagendar la visita.',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Reschedule reason bottom sheet ─────────────────────────────────────────
class _RescheduleReasonSheet extends StatefulWidget {
  final String visitId;
  final VoidCallback onSuccess;

  const _RescheduleReasonSheet({
    required this.visitId,
    required this.onSuccess,
  });

  @override
  State<_RescheduleReasonSheet> createState() => _RescheduleReasonSheetState();
}

class _RescheduleReasonSheetState extends State<_RescheduleReasonSheet> {
  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);

  final _controller = TextEditingController();
  bool _loading = false;
  String? _fieldError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      setState(() => _fieldError = 'Escribe el motivo para poder enviarlo.');
      return;
    }
    setState(() {
      _fieldError = null;
      _loading = true;
    });

    final res = await DOVIAAPIVisitContextGroup
        .operativeListerRescheduleRequestCall
        .call(
      authToken: currentAuthenticationToken,
      visitId: widget.visitId,
      reason: reason,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.succeeded) {
      widget.onSuccess();
    } else {
      // El motivo del backend (ej. la visita no está en una etapa que admita
      // reporte) en vez de un error genérico.
      final body = res.jsonBody;
      String? detail;
      if (body is Map) {
        final errors = body['errors'];
        if (errors is List && errors.isNotEmpty && errors.first is Map) {
          detail = (errors.first as Map)['message']?.toString();
        }
        detail ??= body['message']?.toString();
      }
      debugPrint('[Operative reporte] ${res.statusCode}: ${res.bodyText}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(detail == null || detail.isEmpty
              ? 'Error al enviar la solicitud (HTTP ${res.statusCode})'
              : 'Error al enviar la solicitud: $detail'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuéntanos por qué tienes que\nreagendar la visita',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _dark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 6,
            onChanged: (_) {
              if (_fieldError != null) setState(() => _fieldError = null);
            },
            decoration: InputDecoration(
              errorText: _fieldError,
              hintText: 'Escribe aquí...',
              hintStyle: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Color(0xFFB0B8C1),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: _primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const DoviaSpinner(small: true, color: Colors.white)
                  : const Text(
                      'Enviar solicitud',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
