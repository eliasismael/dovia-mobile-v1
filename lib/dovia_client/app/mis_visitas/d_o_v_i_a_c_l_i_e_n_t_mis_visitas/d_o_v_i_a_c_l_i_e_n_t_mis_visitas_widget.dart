import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/backend/api_requests/api_offers.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_manager.dart';
import '/auth/custom_auth/auth_util.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_model.dart';
import '../d_o_v_i_a_c_l_i_e_n_t_sobre_mi_visita/reschedule_visit_widget.dart';

class DOVIACLIENTMisVisitasWidget extends StatefulWidget {
  const DOVIACLIENTMisVisitasWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisVisitas';
  static String routePath = '/dOVIACLIENTMisVisitas';

  @override
  State<DOVIACLIENTMisVisitasWidget> createState() =>
      _DOVIACLIENTMisVisitasWidgetState();
}

class _DOVIACLIENTMisVisitasWidgetState
    extends State<DOVIACLIENTMisVisitasWidget> {
  late DOVIACLIENTMisVisitasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Section futures ────────────────────────────────────────────────────
  Future<ApiCallResponse>? _pendingOwnerFuture;         // All PENDING visits (MISSING_INFO + RESCHEDULE_REQUIRED)
  Future<ApiCallResponse>? _rescheduledFuture;          // NO_SHOW edge cases

  Future<ApiCallResponse>? _upcomingAssignedFuture;
  Future<ApiCallResponse>? _upcomingPendingFuture;
  Future<ApiCallResponse>? _completedFuture;
  Future<ApiCallResponse>? _offersFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisVisitasModel());

    // All PENDING visits — classify by substatus in each visit's response body
    _pendingOwnerFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      status: 'PENDING',
      page: '1',
      limit: '20',
    );

    // NOT_COMPLETED_REPORTED = showing reportó que no completó la visita (edge case)
    _rescheduledFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      substatus: 'NOT_COMPLETED_REPORTED',
      page: '1',
      limit: '10',
    );

    // ── PRÓXIMAS ─────────────────────────────────────────────────────────
    // ASSIGNED = showing agent asignado con slot confirmado
    _upcomingAssignedFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      substatus: 'ASSIGNED',
      page: '1',
      limit: '10',
    );
    // READY_TO_ASSIGN_SHOWING = owner confirmó slot, esperando showing agent
    _upcomingPendingFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      substatus: 'READY_TO_ASSIGN_SHOWING',
      page: '1',
      limit: '10',
    );

    // ── COMPLETADAS ───────────────────────────────────────────────────────
    _completedFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      status: 'COMPLETED',
      page: '1',
      limit: '10',
    );

    // ── OFERTAS ───────────────────────────────────────────────────────────
    _offersFuture = DOVIAAPIOfferContextGroup.listMyOffersCall.call(
      authToken: currentAuthenticationToken,
      limit: '10',
      page: '1',
    );


    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<dynamic> _parseVisits(ApiCallResponse res) {
    final items = getJsonField(res.jsonBody, r'$.data.items');
    if (items is List) return items;
    final data = getJsonField(res.jsonBody, r'$.data');
    if (data is List) return data;
    return [];
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
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIASHAREDHeaderWidget(
                        title: 'Mis visitas',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // ── 1. Tus próximas visitas ────────────────────
                          FutureBuilder<List<ApiCallResponse>>(
                            future: Future.wait([
                              _pendingOwnerFuture     ?? Future.value(ApiCallResponse(null, {}, 0)),
                              _upcomingAssignedFuture ?? Future.value(ApiCallResponse(null, {}, 0)),
                              _upcomingPendingFuture  ?? Future.value(ApiCallResponse(null, {}, 0)),
                              _rescheduledFuture      ?? Future.value(ApiCallResponse(null, {}, 0)),
                            ]),
                            builder: (context, snap) {
                              final merged = <dynamic>[];
                              if (snap.hasData) {
                                final seen = <String>{};
                                for (final res in snap.data!) {
                                  for (final v in _parseVisits(res)) {
                                    final id = v['visitId']?.toString() ?? v['id']?.toString() ?? '';
                                    if (seen.add(id)) merged.add(v);
                                  }
                                }
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(
                                    'Tus próximas visitas',
                                    () {
                                      if (merged.isNotEmpty) {
                                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => _VerMasScreen(title: 'Tus próximas visitas', items: merged, cardType: _CardType.upcoming)));
                                      }
                                    },
                                    topPadding: 40,
                                  ),
                                  if (!snap.hasData) _loader()
                                  else if (merged.isEmpty) _emptyMessage('No tienes próximas visitas.')
                                  else _visitListHorizontal(merged, cardType: _CardType.upcoming),
                                ],
                              );
                            },
                          ),

                          // ── 2. Tus visitas anteriores (Completadas) ─────────────────────
                          FutureBuilder<ApiCallResponse>(
                            future: _completedFuture,
                            builder: (context, snap) {
                              final visits = snap.hasData ? _parseVisits(snap.data!) : <dynamic>[];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(
                                    'Tus visitas anteriores',
                                    () {
                                      if (visits.isNotEmpty) {
                                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => _VerMasScreen(title: 'Tus visitas anteriores', items: visits, cardType: _CardType.completed)));
                                      }
                                    },
                                  ),
                                  if (!snap.hasData) _loader()
                                  else if (visits.isEmpty) _emptyMessage('No tienes visitas completadas.')
                                  else _visitListHorizontal(visits, cardType: _CardType.completed),
                                ],
                              );
                            },
                          ),

                          // ── 3. Tus ofertas ─────────────────────────────
                          _offersSection(),
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
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTMisVisitasWidget.routeName,
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

  // ── Section header ────────────────────────────────────────────────────
  Widget _sectionHeader(String title, VoidCallback onVerMasTap, {double topPadding = 24}) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, topPadding, 0.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  fontSize: 17.0,
                  letterSpacing: 0.33,
                  fontWeight: FontWeight.w600,
                  lineHeight: 1.3,
                ),
          ),
          InkWell(
            onTap: onVerMasTap,
            child: Text(
              'Ver más',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 14.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _emptyMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
      ),
    );
  }

  // ── Horizontal scroll list ────────────────────────────
  Widget _visitListHorizontal(
    List<dynamic> visits, {
    required _CardType cardType,
  }) {
    final cards = visits.map((v) {
      final visitId = v['visitId']?.toString() ?? v['id']?.toString() ?? v['_id']?.toString() ?? '';
      final showingAgentId = v['showingAgentId']?.toString() ?? '';
      final property = v['property'];
      final propertyId = property is Map ? (property['id']?.toString() ?? '') : (v['propertyId']?.toString() ?? '');
      final slot = v['confirmedTimeSlot'];
      final visitDate = slot is Map ? slot['date']?.toString() ?? '' : '';
      final visitTime = slot is Map ? slot['time']?.toString() ?? '' : '';
      final images = property is Map ? property['images'] : null;
      final imageUrl = (images is List && images.isNotEmpty) ? images[0]['url']?.toString() ?? '' : '';
      final propertyName = property is Map ? (property['name']?.toString() ?? property['title']?.toString() ?? 'Propiedad') : 'Propiedad';
      final visitSubstatus = v['substatus']?.toString() ?? '';
      final visitStatus = v['status']?.toString() ?? '';
      final proposed = v['proposedTimeSlots'];
      final proposedSlots = proposed is List ? proposed : <dynamic>[];

      return _VisitCard(
        visitId: visitId,
        propertyId: propertyId,
        propertyName: propertyName,
        visitDate: visitDate,
        visitTime: visitTime,
        imageUrl: imageUrl,
        showingAgentId: showingAgentId,
        visitSubstatus: visitSubstatus,
        visitStatus: visitStatus,
        proposedTimeSlots: proposedSlots,
        cardType: cardType,
      );
    }).toList();

    return SizedBox(
      height: _cardHeight(cardType),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => cards[i],
      ),
    );
  }

  double _cardHeight(_CardType t) {
    return 290;
  }

  // ── Ofertas section ─────────────────────────────────────────────────────────
  Widget _offersSection() {
    return FutureBuilder<ApiCallResponse>(
      future: _offersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _loader();
        final res = snapshot.data!;
        if (!res.succeeded) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Error cargando ofertas.',
                style: TextStyle(color: Colors.red)),
          );
        }
        final data =
            getJsonField(res.jsonBody, r'$.data.items') ??
                getJsonField(res.jsonBody, r'$.data') ??
                [];
        final offers = data is List
            ? data
            : (data is Map && data['items'] != null
                ? data['items'] as List
                : [data]);
        final offerCards = offers.map((offer) => _buildOfferCard(context, offer)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              'Tus ofertas',
              () {
                if (offers.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => _VerMasScreen(title: 'Tus ofertas', items: offers, cardType: _CardType.upcoming, isOffers: true)));
                }
              },
            ),
            if (offers.isEmpty || (offers.length == 1 && offers[0] == null))
              _emptyMessage('No tienes ofertas activas.')
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: offerCards.length,
                  itemBuilder: (context, index) => offerCards[index],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOfferCard(BuildContext context, dynamic offer, {bool isGrid = false}) {
    final offerId = offer['id'] ?? offer['_id'] ?? offer['offerId'] ?? '';
    final amountRaw = offer['offerData']?['proposedAmount'] ?? offer['proposedAmount'] ?? offer['amount'];
    final double amountDouble = amountRaw is num ? amountRaw.toDouble() : double.tryParse(amountRaw?.toString() ?? '') ?? 0.0;
    final amountStr = NumberFormat.currency(symbol: '', decimalDigits: 0).format(amountDouble);
    final currency = offer['offerData']?['currency']?.toString() ?? offer['currency']?.toString() ?? 'USD';
    final paymentMethod = offer['offerData']?['paymentMethod']?.toString() ?? offer['paymentMethod']?.toString() ?? '';
    final processStatus = offer['processStatus']?.toString() ?? '';
    final offerStatus = offer['offerStatus']?.toString() ?? offer['status']?.toString() ?? 'pending';
    final status = processStatus.isNotEmpty ? processStatus : offerStatus;
    final property = offer['property'] ?? offer['propertyId'];
    final propertyName = property is Map ? (property['title'] ?? property['name'] ?? 'Propiedad') : 'Propiedad';

    return Padding(
      padding: isGrid ? EdgeInsets.zero : const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'DOVIA_CLIENT_MisVisitas_TuPropuesta',
            queryParameters: {
              'offerId': offerId,
              'paymentMethod': paymentMethod,
              'propuestaState': status,
            },
          );
        },
        child: Container(
          width: isGrid ? double.infinity : 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      propertyName,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.publicSans(fontWeight: FontWeight.bold),
                            fontSize: 16.0,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 10.0,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Oferta: $currency \$ $amountStr',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(fontWeight: FontWeight.w500),
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card type enum ─────────────────────────────────────────────────────────
enum _CardType { reschedule, upcoming, completed }

// ── Individual visit card widget ───────────────────────────────────────────
class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.visitId,
    required this.propertyId,
    required this.propertyName,
    required this.visitDate,
    required this.visitTime,
    required this.imageUrl,
    required this.showingAgentId,
    required this.cardType,
    this.visitSubstatus = '',
    this.visitStatus = '',
    this.proposedTimeSlots = const [],
  });

  final String visitId;
  final String propertyId;
  final String propertyName;
  final String visitDate;
  final String visitTime;
  final String imageUrl;
  final String showingAgentId;
  final String visitSubstatus;
  final String visitStatus;
  final List<dynamic> proposedTimeSlots;
  final _CardType cardType;

  static const Color primary = Color(0xFF007376);
  static const Color dark = Color(0xFF00444B);
  static const Color pillBg = Color(0xFFCCE3E4);

  String _formatDate(String raw) {
    if (raw.isEmpty) return 'Sin fecha';
    try {
      final parts = raw.split('-');
      if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    } catch (_) {}
    return raw;
  }

  void _navigateToDetail(BuildContext ctx) {
    ctx.pushNamed(
      'DOVIA_CLIENT_SobreMiVisita',
      queryParameters: {
        'propertyId': serializeParam(propertyId, ParamType.String),
        'visitId': serializeParam(visitId, ParamType.String),
        'showingAgentId': serializeParam(showingAgentId, ParamType.String),
      }.withoutNulls,
    );
  }

  // MISSING_INFO = owner aún no confirmó ningún slot → "Pendiente"
  bool get isPending => visitStatus == 'PENDING' && visitSubstatus == 'MISSING_INFO';
  // RESCHEDULE_REQUIRED = owner rechazó slots, cliente debe proponer nuevas fechas → "Reprogramar"
  bool get isReschedule => visitSubstatus == 'RESCHEDULE_REQUIRED';
  // ASSIGNED / READY_TO_ASSIGN_SHOWING = owner confirmó un slot → "Programada"
  bool get isConfirmed => visitSubstatus == 'ASSIGNED' || visitSubstatus == 'READY_TO_ASSIGN_SHOWING';

  String get _label {
    if (cardType == _CardType.completed) return 'Completada';
    if (isPending) return 'Pendiente';
    if (isReschedule) return 'Reprogramar';
    if (isConfirmed) return 'Programada';
    return 'Visita';
  }

  Color get _labelColor {
    if (cardType == _CardType.completed) return primary;
    if (isPending) return Colors.orange;
    if (isReschedule) return Colors.red;
    if (isConfirmed) return primary;
    return primary;
  }

  void _onRescheduleTap(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.9,
        child: RescheduleVisitWidget(
          visitId: visitId,
          visitSubstatus: visitSubstatus,
        ),
      ),
    );
  }

  void _onCancelTap(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancelar visita'),
        content: const Text('¿Estás seguro de que deseas cancelar esta visita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final res = await DOVIAAPIVisitContextGroup.cancelVisitCall.call(
                authToken: currentAuthenticationToken,
                visitId: visitId,
              );
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(res.succeeded ? 'Visita cancelada' : 'Error al cancelar la visita')),
                );
              }
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 10),
            // ── Badge ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _labelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _label,
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 11, fontWeight: FontWeight.w600, color: _labelColor),
              ),
            ),
            const SizedBox(height: 4),
            // ── Date / info ───────────────────────────────────────────
            if (isPending) ..._pendingInfo()
            else if (isReschedule)
              const Text(
                'El propietario solicita nuevas fechas',
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Colors.red),
                maxLines: 2,
              )
            else ...[
              Text(
                _formatDate(visitDate),
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, fontWeight: FontWeight.w500, color: dark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (visitTime.isNotEmpty)
                Text(visitTime, style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Colors.grey)),
            ],
            const Spacer(),
            // ── Actions ───────────────────────────────────────────────
            ..._buildActions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _pendingInfo() {
    if (proposedTimeSlots.isEmpty) {
      return [
        const Text(
          'Esperando confirmación del propietario',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Colors.orange),
          maxLines: 2,
        ),
      ];
    }
    final first = proposedTimeSlots.first;
    final date = first is Map ? (first['date']?.toString() ?? '') : '';
    final time = first is Map ? (first['time']?.toString() ?? '') : '';
    return [
      Text(
        _formatDate(date),
        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, fontWeight: FontWeight.w500, color: dark),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      if (time.isNotEmpty)
        Text(time, style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Colors.grey)),
    ];
  }

  List<Widget> _buildActions(BuildContext context) {
    if (cardType == _CardType.completed) {
      return [
        _pill(context, Icons.remove_red_eye_outlined, 'Ver detalle', onTap: () => _navigateToDetail(context)),
      ];
    }
    if (isPending) {
      return [
        _cancelPill(context),
      ];
    }
    if (isReschedule) {
      return [
        _pill(context, Icons.calendar_today, 'Agendar cita', onTap: () => _onRescheduleTap(context)),
      ];
    }
    if (isConfirmed) {
      return [
        _pill(context, Icons.remove_red_eye_outlined, 'Sobre mi visita', onTap: () => _navigateToDetail(context)),
        const SizedBox(height: 6),
        _cancelPill(context),
      ];
    }
    return [
      _pill(context, Icons.remove_red_eye_outlined, 'Sobre mi visita', onTap: () => _navigateToDetail(context)),
    ];
  }

  Widget _pill(BuildContext context, IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 30,
        decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(99)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: primary),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13, fontWeight: FontWeight.w500, color: primary)),
          ],
        ),
      ),
    );
  }

  Widget _cancelPill(BuildContext context) {
    return GestureDetector(
      onTap: () => _onCancelTap(context),
      child: Container(
        width: double.infinity,
        height: 30,
        decoration: BoxDecoration(border: Border.all(color: Colors.red.withOpacity(0.5)), borderRadius: BorderRadius.circular(99)),
        child: const Center(
          child: Text('Cancelar visita', style: TextStyle(fontFamily: 'Public Sans', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red)),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
      child: const Icon(Icons.home_outlined, color: Colors.grey, size: 36),
    );
  }
}

class _VerMasScreen extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final _CardType cardType;
  final bool isOffers;

  const _VerMasScreen({
    required this.title,
    required this.items,
    required this.cardType,
    this.isOffers = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
        title: Text(
          title,
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 18.0,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: isOffers ? 110 : (cardType == _CardType.upcoming ? 290 : 260),
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              if (isOffers) {
                // To reuse _buildOfferCard we'd need a reference or duplicate it.
                // We'll duplicate the logic for _OfferCard since _buildOfferCard is inside the state class.
                return _OfferCard(offer: items[index]);
              }
              final v = items[index];
              final visitId = v['visitId']?.toString() ?? v['id']?.toString() ?? v['_id']?.toString() ?? '';
              final showingAgentId = v['showingAgentId']?.toString() ?? '';
              final property = v['property'];
              final propertyId = property is Map ? (property['id']?.toString() ?? '') : (v['propertyId']?.toString() ?? '');
              final slot = v['confirmedTimeSlot'];
              final visitDate = slot is Map ? slot['date']?.toString() ?? '' : '';
              final visitTime = slot is Map ? slot['time']?.toString() ?? '' : '';
              final images = property is Map ? property['images'] : null;
              final imageUrl = (images is List && images.isNotEmpty) ? images[0]['url']?.toString() ?? '' : '';
              final propertyName = property is Map ? (property['name']?.toString() ?? property['title']?.toString() ?? 'Propiedad') : 'Propiedad';
              final visitSubstatus = v['substatus']?.toString() ?? '';
              final visitStatus = v['status']?.toString() ?? '';
              final proposed = v['proposedTimeSlots'];
              final proposedSlots = proposed is List ? proposed : <dynamic>[];

              return _VisitCard(
                visitId: visitId,
                propertyId: propertyId,
                propertyName: propertyName,
                visitDate: visitDate,
                visitTime: visitTime,
                imageUrl: imageUrl,
                showingAgentId: showingAgentId,
                visitSubstatus: visitSubstatus,
                visitStatus: visitStatus,
                proposedTimeSlots: proposedSlots,
                cardType: cardType,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final dynamic offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final offerId = offer['id'] ?? offer['_id'] ?? offer['offerId'] ?? '';
    final amountRaw = offer['offerData']?['proposedAmount'] ?? offer['proposedAmount'] ?? offer['amount'];
    final double amountDouble = amountRaw is num ? amountRaw.toDouble() : double.tryParse(amountRaw?.toString() ?? '') ?? 0.0;
    final amountStr = NumberFormat.currency(symbol: '', decimalDigits: 0).format(amountDouble);
    final currency = offer['offerData']?['currency']?.toString() ?? offer['currency']?.toString() ?? 'USD';
    final paymentMethod = offer['offerData']?['paymentMethod']?.toString() ?? offer['paymentMethod']?.toString() ?? '';
    final processStatus = offer['processStatus']?.toString() ?? '';
    final offerStatus = offer['offerStatus']?.toString() ?? offer['status']?.toString() ?? 'pending';
    final status = processStatus.isNotEmpty ? processStatus : offerStatus;
    final property = offer['property'] ?? offer['propertyId'];
    final propertyName = property is Map ? (property['title'] ?? property['name'] ?? 'Propiedad') : 'Propiedad';

    return InkWell(
      onTap: () {
        context.pushNamed(
          'DOVIA_CLIENT_MisVisitas_TuPropuesta',
          queryParameters: {
            'offerId': offerId,
            'paymentMethod': paymentMethod,
            'propuestaState': status,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              propertyName,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.bold),
                    fontSize: 14.0,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.toUpperCase(),
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 9.0,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_offer_outlined, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '\$ $amountStr',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(fontWeight: FontWeight.w500),
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 12.0,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

