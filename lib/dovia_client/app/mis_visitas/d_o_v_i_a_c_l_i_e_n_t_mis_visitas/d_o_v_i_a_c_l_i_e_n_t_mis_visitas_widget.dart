import '/core/network_image_size.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/api_requests/api_properties.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_manager.dart';
import '/auth/custom_auth/auth_util.dart';
import '/domain/offer_json.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_model.dart';
import '../d_o_v_i_a_c_l_i_e_n_t_sobre_mi_visita/reschedule_visit_widget.dart';
import '/shared_components/dovia_spinner.dart';

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
  Future<ApiCallResponse>?
      _pendingOwnerFuture; // All PENDING visits (MISSING_INFO + RESCHEDULE_REQUIRED)
  Future<ApiCallResponse>? _rescheduledFuture; // NO_SHOW edge cases

  Future<ApiCallResponse>? _upcomingAssignedFuture;
  Future<ApiCallResponse>? _upcomingPendingFuture;
  Future<ApiCallResponse>? _completedFuture;

  /// Todas las visitas, sin filtro: es la unica forma de ver las
  /// canceladas y las ya reprogramadas, que no tienen consulta propia.
  Future<ApiCallResponse>? _allVisitsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisVisitasModel());
    _loadVisits();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _loadVisits() {
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

    _allVisitsFuture = DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: currentAuthenticationToken,
      page: '1',
      limit: '50',
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Una visita ya reprogramada, no una que espera que la reprogramen.
  /// El backend no expone un unico campo para esto, asi que se miran los
  /// que puede mandar; RESCHEDULE_REQUIRED queda afuera a proposito, porque
  /// es justo la que todavia hay que reprogramar.
  bool _wasRescheduled(dynamic visit) {
    if (visit is! Map) return false;

    final substatus = (visit['substatus']?.toString() ?? '').toUpperCase();
    if (substatus == 'RESCHEDULE_REQUIRED') return false;

    final status = (visit['status']?.toString() ?? '').toUpperCase();
    if (substatus.contains('RESCHEDULED') || status.contains('RESCHEDULED')) {
      return true;
    }

    final count = visit['rescheduleCount'] ?? visit['rescheduledCount'];
    if (count is num && count > 0) return true;

    final at = visit['rescheduledAt']?.toString() ?? '';
    return at.isNotEmpty && at != 'null';
  }

  List<dynamic> _parseVisits(ApiCallResponse res) {
    final items = getJsonField(res.jsonBody, r'$.data.items');
    final data = getJsonField(res.jsonBody, r'$.data');
    final list = items is List ? items : (data is List ? data : const []);
    return list.where(_isClientVisit).toList();
  }

  /// Mis visitas es para las visitas que el usuario hace como cliente. Las
  /// `OPERATIVE_LISTER_VISIT` (el operativo que revisa una propiedad propia
  /// antes de publicarla) también vuelven en /visits/me, pero se siguen desde
  /// Mis propiedades. El backend no tiene un único campo para distinguirlas,
  /// así que se mira el tipo y, si no viene, quién es el dueño.
  bool _isClientVisit(dynamic visit) {
    if (visit is! Map) return false;
    final type = [
      visit['type'],
      visit['visitType'],
      visit['kind'],
    ].map((e) => (e?.toString() ?? '').toUpperCase()).join(' ');
    if (type.contains('OPERATIVE') || type.contains('LISTER')) return false;

    final uid = currentUserUid;
    if (uid.isEmpty) return true;
    final property = visit['property'];
    final ownerIds = [
      visit['ownerId'],
      visit['propertyOwnerId'],
      if (property is Map) property['ownerId'],
      if (property is Map) property['userId'],
      if (property is Map && property['owner'] is Map)
        (property['owner'] as Map)['id'],
    ].map((e) => e?.toString() ?? '');
    return !ownerIds.contains(uid);
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
          // Sin SafeArea abajo, como en el inicio: el contenido pasa
          // por debajo de la barra flotante hasta el borde de la pantalla.
          bottom: false,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                // Lo que ocupa el indicador de inicio (iPhone), que ya no
                // descuenta el SafeArea: el final queda sobre la barra.
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIASHAREDHeaderWidget(
                        showLogo: true,
                        showSupport: false,
                        title: 'Mis visitas',
                        showMap: false,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // ── 1 a 3. Los tres carriles de visitas ────────
                          // Se piden juntos y se reparten en el cliente: las
                          // que faltan reprogramar o quedaron canceladas van
                          // con las próximas, completadas solo las
                          // completadas y re-programadas solo las que ya se
                          // reprogramaron.
                          FutureBuilder<List<ApiCallResponse>>(
                            future: Future.wait([
                              _pendingOwnerFuture ??
                                  Future.value(
                                      const ApiCallResponse(null, {}, 0)),
                              _upcomingAssignedFuture ??
                                  Future.value(
                                      const ApiCallResponse(null, {}, 0)),
                              _upcomingPendingFuture ??
                                  Future.value(
                                      const ApiCallResponse(null, {}, 0)),
                              _rescheduledFuture ??
                                  Future.value(
                                      const ApiCallResponse(null, {}, 0)),
                              _allVisitsFuture ??
                                  Future.value(
                                      const ApiCallResponse(null, {}, 0)),
                              _completedFuture ??
                                  Future.value(
                                      const ApiCallResponse(null, {}, 0)),
                            ]),
                            builder: (context, snap) {
                              final upcoming = <dynamic>[];
                              final rescheduled = <dynamic>[];
                              final completed = <dynamic>[];

                              if (snap.hasData) {
                                final seen = <String>{};
                                for (final res in snap.data!) {
                                  for (final v in _parseVisits(res)) {
                                    final id = v['visitId']?.toString() ??
                                        v['id']?.toString() ??
                                        '';
                                    if (!seen.add(id)) continue;

                                    final status =
                                        (v['status']?.toString() ?? '')
                                            .toUpperCase();
                                    if (status == 'COMPLETED') {
                                      completed.add(v);
                                    } else if (_wasRescheduled(v)) {
                                      rescheduled.add(v);
                                    } else {
                                      upcoming.add(v);
                                    }
                                  }
                                }
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Re-programadas solo aparece cuando hay
                                  // alguna: es un caso poco frecuente.
                                  if (rescheduled.isNotEmpty) ...[
                                    _sectionHeader(
                                      'Visitas re-programadas',
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => _VerMasScreen(
                                            title: 'Visitas re-programadas',
                                            items: rescheduled,
                                            cardType: _CardType.reschedule,
                                            onChanged: _refreshPending,
                                          ),
                                        ),
                                      ),
                                      topPadding: 40,
                                    ),
                                    _visitListHorizontal(rescheduled,
                                        cardType: _CardType.reschedule),
                                  ],
                                  _sectionHeader(
                                    'Tus próximas visitas',
                                    () {
                                      if (upcoming.isNotEmpty) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ctx) => _VerMasScreen(
                                                    title:
                                                        'Tus próximas visitas',
                                                    items: upcoming,
                                                    cardType:
                                                        _CardType.upcoming,
                                                    onChanged:
                                                        _refreshPending)));
                                      }
                                    },
                                    topPadding:
                                        rescheduled.isNotEmpty ? 24 : 40,
                                  ),
                                  if (!snap.hasData)
                                    _loader()
                                  else if (upcoming.isEmpty)
                                    _emptyMessage('No tienes próximas visitas.')
                                  else
                                    _visitListHorizontal(upcoming,
                                        cardType: _CardType.upcoming),
                                  _sectionHeader(
                                    'Tus visitas anteriores',
                                    () {
                                      if (completed.isNotEmpty) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ctx) => _VerMasScreen(
                                                    title:
                                                        'Tus visitas anteriores',
                                                    items: completed,
                                                    cardType:
                                                        _CardType.completed)));
                                      }
                                    },
                                  ),
                                  if (!snap.hasData)
                                    _loader()
                                  else if (completed.isEmpty)
                                    _emptyMessage(
                                        'No tienes visitas completadas.')
                                  else
                                    _visitListHorizontal(completed,
                                        cardType: _CardType.completed),
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
                    const Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 12.0),
                        child: FixedDoviaIconWidget(),
                      ),
                    ),
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
  Widget _sectionHeader(String title, VoidCallback onVerMasTap,
      {double topPadding = 24}) {
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
      child: Center(child: DoviaSpinner()),
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
      final visitTime = slot is Map ? slot['time']?.toString() ?? '' : '';
      final imageUrl = property is Map
          ? (firstPropertyPhotoUrl(Map<String, dynamic>.from(property)) ?? '')
          : '';
      final propertyName = property is Map
          ? (property['name']?.toString() ??
              property['title']?.toString() ??
              'Propiedad')
          : 'Propiedad';
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
        onRescheduleSuccess: _refreshPending,
      );
    }).toList();

    // Alto según el contenido: la card más alta define la fila.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              cards[i],
            ],
          ],
        ),
      ),
    );
  }

  void _refreshPending() {
    safeSetState(_loadVisits);
  }

  // ── Ofertas section ─────────────────────────────────────────────────────────
}

// ── Card type enum ─────────────────────────────────────────────────────────
enum _CardType { reschedule, upcoming, completed }

// ── Individual visit card widget ───────────────────────────────────────────
class _VisitCard extends StatefulWidget {
  _VisitCard({
    required this.visitId,
    required this.propertyId,
    required this.propertyName,
    required this.visitDate,
    required this.visitTime,
    required this.imageUrl,
    this.fillHeight = true,
    required this.showingAgentId,
    required this.cardType,
    this.visitSubstatus = '',
    this.visitStatus = '',
    this.proposedTimeSlots = const [],
    this.onRescheduleSuccess,
  });

  final String visitId;
  final String propertyId;
  final String propertyName;
  final String visitDate;
  final String visitTime;
  final String imageUrl;

  /// En los carruseles la tarjeta tiene alto fijo y el botón va al fondo;
  /// en la grilla de "Ver más" mide sólo lo que ocupa su contenido.
  final bool fillHeight;
  final String showingAgentId;
  final String visitSubstatus;
  final String visitStatus;
  final List<dynamic> proposedTimeSlots;
  final _CardType cardType;
  final VoidCallback? onRescheduleSuccess;

  // Session-level cache so the same property is fetched only once.
  static final Map<String, String> _nameCache = {};
  static final Map<String, String> _photoCache = {};

  @override
  State<_VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<_VisitCard> {
  late String _displayName;
  late String _displayImage;

  static const Color primary = Color(0xFF007376);
  static const Color dark = Color(0xFF00444B);
  static const Color pillBg = Color(0xFFCCE3E4);

  @override
  void initState() {
    super.initState();
    final cached = _VisitCard._nameCache[widget.propertyId];
    final cachedPhoto = _VisitCard._photoCache[widget.propertyId];

    _displayImage =
        widget.imageUrl.isNotEmpty ? widget.imageUrl : (cachedPhoto ?? '');
    if (widget.imageUrl.isNotEmpty) {
      _VisitCard._photoCache[widget.propertyId] = widget.imageUrl;
    }

    if (cached != null) {
      _displayName = cached;
    } else if (widget.propertyName.isNotEmpty &&
        widget.propertyName != 'Propiedad') {
      _displayName = widget.propertyName;
      _VisitCard._nameCache[widget.propertyId] = _displayName;
    } else {
      _displayName = widget.propertyName;
    }

    // La visita no siempre trae la propiedad completa. Si falta el nombre o
    // la foto se piden a la propiedad, que sí los devuelve.
    final needsName = _VisitCard._nameCache[widget.propertyId] == null;
    final needsPhoto = _displayImage.isEmpty;
    if (widget.propertyId.isNotEmpty && (needsName || needsPhoto)) {
      _fetchPropertyDetails();
    }
  }

  Future<void> _fetchPropertyDetails() async {
    final res = await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
      propertyId: widget.propertyId,
    );
    if (!mounted || !res.succeeded) return;
    final data = getJsonField(res.jsonBody, r'$.data.data') ??
        getJsonField(res.jsonBody, r'$.data');
    if (data is! Map) return;

    final name = data['name']?.toString() ?? data['title']?.toString() ?? '';
    final photo = firstPropertyPhotoUrl(Map<String, dynamic>.from(data)) ?? '';

    if (name.isNotEmpty) _VisitCard._nameCache[widget.propertyId] = name;
    if (photo.isNotEmpty) _VisitCard._photoCache[widget.propertyId] = photo;
    if (name.isEmpty && photo.isEmpty) return;

    setState(() {
      if (name.isNotEmpty) _displayName = name;
      if (photo.isNotEmpty && _displayImage.isEmpty) _displayImage = photo;
    });
  }

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
        'propertyId': serializeParam(widget.propertyId, ParamType.String),
        'visitId': serializeParam(widget.visitId, ParamType.String),
        'showingAgentId':
            serializeParam(widget.showingAgentId, ParamType.String),
      }.withoutNulls,
    );
  }

  bool get isReschedule => widget.visitSubstatus == 'RESCHEDULE_REQUIRED';
  bool get isConfirmed =>
      widget.visitSubstatus == 'ASSIGNED' ||
      widget.visitSubstatus == 'READY_TO_ASSIGN_SHOWING';

  /// El propietario todavía no eligió ninguna de las fechas propuestas.
  bool get isPending =>
      !isReschedule &&
      !isConfirmed &&
      (widget.visitStatus == 'PENDING' ||
          widget.visitSubstatus == 'MISSING_INFO');

  /// Tocar la card: si hay que reprogramar abre "Agendar cita", si no el
  /// detalle de la visita.
  void _onCardTap(BuildContext ctx) {
    if (widget.cardType == _CardType.reschedule || isReschedule) {
      _onRescheduleTap(ctx);
    } else {
      _navigateToDetail(ctx);
    }
  }

  String get _label {
    if (widget.cardType == _CardType.completed) return 'Completada';
    if (widget.cardType == _CardType.reschedule) return 'Re-programada';
    if (isPending) return 'Pendiente';
    if (isReschedule) return 'Reprogramar';
    if (isConfirmed) return 'Programada';
    return 'Visita';
  }

  Color get _labelColor {
    if (widget.cardType == _CardType.completed) return primary;
    if (widget.cardType == _CardType.reschedule) return primary;
    if (isPending) return Colors.orange;
    if (isReschedule) return Colors.red;
    if (isConfirmed) return primary;
    return primary;
  }

  Future<void> _onRescheduleTap(BuildContext ctx) async {
    final result = await showRescheduleVisitSheet(
      ctx,
      visitId: widget.visitId,
      visitSubstatus: widget.visitSubstatus,
    );
    if (result == true) widget.onRescheduleSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onCardTap(context),
      behavior: HitTestBehavior.opaque,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final actions = _buildActions(context);
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
            // Si la propiedad no tiene fotos no se muestra ninguna imagen.
            if (_displayImage.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _displayImage,
                  width: double.infinity,
                  height: 95,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  cacheWidth: networkImageCacheWidth(
                      width: double.infinity, height: 95),
                ),
              ),
              const SizedBox(height: 8),
            ],
            // ── Nombre y estado ───────────────────────────────────────
            Text(
              _displayName,
              style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: dark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // El estado va debajo del nombre, a todo el ancho de la tarjeta.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _labelColor,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                _label,
                style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            // ── Date / info ───────────────────────────────────────────
            if (isPending)
              ..._pendingInfo()
            else if (isReschedule)
              const Text(
                'El propietario solicita nuevas fechas',
                style: TextStyle(
                    fontFamily: 'Public Sans', fontSize: 12, color: Colors.red),
                maxLines: 2,
              )
            else ...[
              Text(
                _formatDate(widget.visitDate),
                style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: dark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.visitTime.isNotEmpty)
                Text(widget.visitTime,
                    style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: Colors.grey)),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              if (widget.fillHeight)
                const Spacer()
              else
                const SizedBox(height: 12),
              // ── Actions ─────────────────────────────────────────────
              ...actions,
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _pendingInfo() {
    if (widget.proposedTimeSlots.isEmpty) {
      return [
        const Text(
          'Esperando confirmación del propietario',
          style: TextStyle(
              fontFamily: 'Public Sans', fontSize: 12, color: Colors.orange),
          maxLines: 2,
        ),
      ];
    }
    return widget.proposedTimeSlots.take(3).toList().asMap().entries.map((e) {
      final slot = e.value;
      final date = slot is Map ? (slot['date']?.toString() ?? '') : '';
      final time = slot is Map ? (slot['time']?.toString() ?? '') : '';
      const style =
          TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: dark);
      // Ocupa todo el ancho de la tarjeta: la fecha a la izquierda y la hora
      // a la derecha.
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${e.key + 1}. ${_formatDate(date)}',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(time, style: style),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildActions(BuildContext context) {
    if (widget.cardType == _CardType.reschedule) {
      return [
        _pill(context, Icons.remove_red_eye_outlined, 'Re-Programar',
            onTap: () => _onRescheduleTap(context)),
      ];
    }
    if (widget.cardType == _CardType.completed) {
      return [
        _pill(context, Icons.remove_red_eye_outlined, 'Ver detalle',
            onTap: () => _navigateToDetail(context)),
      ];
    }
    // Pendiente: sin acción en la tarjeta. Al tocarla se abre "Sobre mi
    // visita", donde se puede cancelar.
    if (isPending) return const [];
    if (isReschedule) {
      return [
        _pill(context, Icons.calendar_today, 'Agendar cita',
            onTap: () => _onRescheduleTap(context)),
      ];
    }
    if (isConfirmed) {
      return [
        _pill(context, Icons.remove_red_eye_outlined, 'Sobre mi visita',
            onTap: () => _navigateToDetail(context)),
      ];
    }
    return [
      _pill(context, Icons.remove_red_eye_outlined, 'Sobre mi visita',
          onTap: () => _navigateToDetail(context)),
    ];
  }

  Widget _pill(BuildContext context, IconData icon, String label,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 30,
        decoration: BoxDecoration(
            color: pillBg, borderRadius: BorderRadius.circular(99)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: primary),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: primary)),
          ],
        ),
      ),
    );
  }
}

class _VerMasScreen extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final _CardType cardType;

  final VoidCallback? onChanged;

  const _VerMasScreen({
    required this.title,
    required this.items,
    required this.cardType,
    this.onChanged,
  });

  @override
  State<_VerMasScreen> createState() => _VerMasScreenState();
}

class _VerMasScreenState extends State<_VerMasScreen> {
  /// Tarjetas que animan su entrada: las que entran en la primera pantalla.
  static const _animatedCards = 8;

  late final List<dynamic> items = List.of(widget.items);

  String get title => widget.title;
  _CardType get cardType => widget.cardType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      // Mismo SafeArea que la pantalla de Mis Visitas, para que el header
      // quede a la misma altura.
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            const CornerGradientBackgroundWidget(),
            Column(
              children: [
                DOVIASHAREDHeaderWidget(
                  showLogo: true,
                  showSupport: false,
                  title: title,
                  showMap: false,
                  showCurrency: false,
                  hideActions: true,
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    // Dos columnas; cada tarjeta mide lo que ocupa su contenido
                    // y cada fila, lo que su tarjeta más alta.
                    final cardWidth = (constraints.maxWidth - 32 - 10) / 2;
                    Widget card(int index) {
                      final item = SizedBox(
                        width: cardWidth,
                        child: _buildItem(items[index]),
                      );
                      // Solo las que se ven al abrir entran desde la
                      // izquierda, una tras otra; animarlas todas trababa los
                      // celulares viejos con muchas visitas.
                      if (index >= _animatedCards) return item;
                      return _SlideInFromLeft(
                        delay: Duration(milliseconds: 90 * index),
                        child: item,
                      );
                    }

                    // Por filas y con builder: solo se arman (y cargan su
                    // foto) las tarjetas que están en pantalla.
                    final rows = (items.length + 1) ~/ 2;
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                      itemCount: rows,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, row) {
                        final first = row * 2;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            card(first),
                            if (first + 1 < items.length) ...[
                              const SizedBox(width: 10),
                              card(first + 1),
                            ],
                          ],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(dynamic v) {
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
    final visitTime = slot is Map ? slot['time']?.toString() ?? '' : '';
    final imageUrl = property is Map
        ? (firstPropertyPhotoUrl(Map<String, dynamic>.from(property)) ?? '')
        : '';
    final propertyName = property is Map
        ? (property['name']?.toString() ??
            property['title']?.toString() ??
            'Propiedad')
        : 'Propiedad';
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
      fillHeight: false,
      showingAgentId: showingAgentId,
      visitSubstatus: visitSubstatus,
      visitStatus: visitStatus,
      proposedTimeSlots: proposedSlots,
      cardType: cardType,
      // Cancelada o reprogramada: sale de la grilla y se recarga
      // la pantalla de atrás.
      onRescheduleSuccess: () {
        setState(() => items.remove(v));
        widget.onChanged?.call();
      },
    );
  }
}

/// Entra desde la izquierda con un fundido, después de [delay].
class _SlideInFromLeft extends StatefulWidget {
  const _SlideInFromLeft({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_SlideInFromLeft> createState() => _SlideInFromLeftState();
}

class _SlideInFromLeftState extends State<_SlideInFromLeft>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(-0.35, 0), end: Offset.zero)
            .animate(_curve),
        child: widget.child,
      ),
    );
  }
}
