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
  // Reprogramadas: 3 separate calls because API may not support comma-separated substatus
  Future<ApiCallResponse>? _rescheduleRequestedFuture;  // owner asked for new date
  Future<ApiCallResponse>? _rescheduleRequiredFuture;   // reschedule required
  Future<ApiCallResponse>? _rescheduledFuture;          // client sent new slots

  Future<ApiCallResponse>? _upcomingAssignedFuture;
  Future<ApiCallResponse>? _upcomingPendingFuture;
  Future<ApiCallResponse>? _completedFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisVisitasModel());

    // ── REPROGRAMADAS ────────────────────────────────────────────────────
    // MISSING_INFO = owner no confirmó slot / solicitó otro horario
    _rescheduleRequestedFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      substatus: 'MISSING_INFO',
      page: '1',
      limit: '10',
    );
    // ASSIGNMENT_EXPIRED = expiró sin que ningún showing agent se asignara
    _rescheduleRequiredFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      substatus: 'ASSIGNMENT_EXPIRED',
      page: '1',
      limit: '10',
    );
    // NOT_COMPLETED_REPORTED = showing reportó que no completó la visita
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
                          // ── 1. Visitas re-programadas ──────────────────
                          _sectionHeader('Visitas re-programadas',
                              topPadding: 40),
                          FutureBuilder<List<ApiCallResponse>>(
                            future: Future.wait([
                              _rescheduleRequestedFuture ?? Future.value(ApiCallResponse(null, {}, 0)),
                              _rescheduleRequiredFuture  ?? Future.value(ApiCallResponse(null, {}, 0)),
                              _rescheduledFuture         ?? Future.value(ApiCallResponse(null, {}, 0)),
                            ]),
                            builder: (context, snap) {
                              if (!snap.hasData) return _loader();
                              // Merge and deduplicate across all 3 substatus calls
                              final seen = <String>{};
                              final visits = <dynamic>[];
                              for (final res in snap.data!) {
                                for (final v in _parseVisits(res)) {
                                  final id = v['visitId']?.toString() ?? v['id']?.toString() ?? '';
                                  if (seen.add(id)) visits.add(v);
                                }
                              }
                              if (visits.isEmpty) {
                                return _emptyMessage(
                                    'No tienes visitas re-programadas.');
                              }
                              return _visitListHorizontal(
                                visits,
                                cardType: _CardType.reschedule,
                              );
                            },
                          ),

                          // ── 2. Tus próximas visitas ────────────────────
                          _sectionHeader('Tus próximas visitas'),
                          FutureBuilder<List<ApiCallResponse>>(
                            future: (_upcomingAssignedFuture != null && _upcomingPendingFuture != null)
                                ? Future.wait([_upcomingAssignedFuture!, _upcomingPendingFuture!])
                                : Future.value(<ApiCallResponse>[]),
                            builder: (context, snap) {
                              if (!snap.hasData) return _loader();
                              final d = snap.data!;
                              final assigned = d.isNotEmpty ? _parseVisits(d[0]) : <dynamic>[];
                              final pending = d.length > 1 ? _parseVisits(d[1]) : <dynamic>[];
                              // Merge, deduplicate by visitId
                              final seen = <String>{};
                              final merged = <dynamic>[];
                              for (final v in [...assigned, ...pending]) {
                                final id = v['visitId']?.toString() ??
                                    v['id']?.toString() ??
                                    '';
                                if (seen.add(id)) merged.add(v);
                              }
                              if (merged.isEmpty) {
                                return _emptyMessage(
                                    'No tienes próximas visitas.');
                              }
                              return _visitListHorizontal(
                                merged,
                                cardType: _CardType.upcoming,
                              );
                            },
                          ),

                          // ── 3. Visitas Completadas ─────────────────────
                          _sectionHeader('Visitas Completadas'),
                          FutureBuilder<ApiCallResponse>(
                            future: _completedFuture,
                            builder: (context, snap) {
                              if (!snap.hasData) return _loader();
                              final visits = _parseVisits(snap.data!);
                              if (visits.isEmpty) {
                                return _emptyMessage(
                                    'No tienes visitas completadas.');
                              }
                              return _visitListHorizontal(
                                visits,
                                cardType: _CardType.completed,
                              );
                            },
                          ),

                          // ── 4. Tus ofertas ─────────────────────────────
                          _sectionHeader('Tus ofertas'),
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
  Widget _sectionHeader(String title, {double topPadding = 24}) {
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

  // ── Horizontal scroll list of visit cards ────────────────────────────
  Widget _visitListHorizontal(
    List<dynamic> visits, {
    required _CardType cardType,
  }) {
    return SizedBox(
      height: _cardHeight(cardType),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visits.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final v = visits[i];
          final visitId = v['visitId']?.toString() ??
              v['id']?.toString() ??
              v['_id']?.toString() ??
              '';
          final showingAgentId = v['showingAgentId']?.toString() ?? '';
          final property = v['property'];
          final propertyId = property is Map
              ? (property['id']?.toString() ?? '')
              : (v['propertyId']?.toString() ?? '');
          final slot = v['confirmedTimeSlot'];
          final visitDate = slot is Map ? slot['date']?.toString() ?? '' : '';
          final images = property is Map ? property['images'] : null;
          final imageUrl = (images is List && images.isNotEmpty)
              ? images[0]['url']?.toString() ?? ''
              : '';
          final propertyName = property is Map
              ? (property['name']?.toString() ??
                  property['title']?.toString() ??
                  'Propiedad')
              : 'Propiedad';
          final visitSubstatus = v['substatus']?.toString() ?? '';

          return _VisitCard(
            visitId: visitId,
            propertyId: propertyId,
            propertyName: propertyName,
            visitDate: visitDate,
            imageUrl: imageUrl,
            showingAgentId: showingAgentId,
            visitSubstatus: visitSubstatus,
            cardType: cardType,
          );
        },
      ),
    );
  }

  double _cardHeight(_CardType t) {
    // image 120 + padding 10*2 + label ~20 + date ~22 + spacing 12+4+14 + button 30 = ~242
    return 260;
  }

  // ── Ofertas section (unchanged logic, kept intact) ────────────────────
  Widget _offersSection() {
    return FutureBuilder<ApiCallResponse>(
      future: DOVIAAPIOfferContextGroup.listMyOffersCall.call(
        authToken: currentAuthenticationToken,
        limit: '10',
        page: '1',
      ),
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
        if (offers.isEmpty ||
            (offers.length == 1 && offers[0] == null)) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No tienes ofertas activas.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            final offerId = offer['id'] ??
                offer['_id'] ??
                offer['offerId'] ??
                '';
            final amountRaw = offer['offerData']?['proposedAmount'] ??
                offer['proposedAmount'] ??
                offer['amount'];
            final double amountDouble = amountRaw is num
                ? amountRaw.toDouble()
                : double.tryParse(amountRaw?.toString() ?? '') ?? 0.0;
            final amountStr =
                NumberFormat.currency(symbol: '', decimalDigits: 0)
                    .format(amountDouble);
            final currency =
                offer['offerData']?['currency']?.toString() ??
                    offer['currency']?.toString() ??
                    'USD';
            final paymentMethod =
                offer['offerData']?['paymentMethod']?.toString() ??
                    offer['paymentMethod']?.toString() ??
                    '';
            final processStatus =
                offer['processStatus']?.toString() ?? '';
            final offerStatus = offer['offerStatus']?.toString() ??
                offer['status']?.toString() ??
                'pending';
            final status =
                processStatus.isNotEmpty ? processStatus : offerStatus;
            final property =
                offer['property'] ?? offer['propertyId'];
            final propertyName = property is Map
                ? (property['title'] ?? property['name'] ?? 'Propiedad')
                : 'Propiedad';

            return Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              propertyName,
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.bold),
                                    fontSize: 16.0,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    color: FlutterFlowTheme.of(context)
                                        .primary,
                                    fontSize: 10.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.local_offer_outlined,
                              size: 16,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText),
                          const SizedBox(width: 4),
                          Text(
                            'Oferta: $currency \$ $amountStr',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w500),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
    required this.imageUrl,
    required this.showingAgentId,
    required this.cardType,
    this.visitSubstatus = '',
  });

  final String visitId;
  final String propertyId;
  final String propertyName;
  final String visitDate;
  final String imageUrl;
  final String showingAgentId;
  final String visitSubstatus;
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

  String get _label {
    switch (cardType) {
      case _CardType.reschedule:
        return 'Re-programada';
      case _CardType.upcoming:
        return 'Programada';
      case _CardType.completed:
        return 'Completada';
    }
  }

  String get _btnLabel {
    switch (cardType) {
      case _CardType.reschedule:
        return 'Re-Programar';
      case _CardType.upcoming:
        return 'Sobre mi visita';
      case _CardType.completed:
        return 'Calificar';
    }
  }

  void _onBtnTap(BuildContext ctx) {
    switch (cardType) {
      case _CardType.reschedule:
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
        break;
      case _CardType.upcoming:
      case _CardType.completed:
        _navigateToDetail(ctx);
        break;
    }
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
            // ── Full-width image ───────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 12),
            // ── Label ─────────────────────────────────────────────────
            Text(
              _label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: primary,
              ),
            ),
            const SizedBox(height: 4),
            // ── Date ──────────────────────────────────────────────────
            Text(
              _formatDate(visitDate),
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: dark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // ── Pill button ───────────────────────────────────────────
            GestureDetector(
              onTap: () => _onBtnTap(context),
              child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 18,
                      color: primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _btnLabel,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.home_outlined, color: Colors.grey, size: 36),
    );
  }
}

