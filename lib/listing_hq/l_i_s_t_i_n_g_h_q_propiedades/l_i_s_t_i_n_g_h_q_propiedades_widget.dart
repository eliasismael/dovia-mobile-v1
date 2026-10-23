import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_asignada/l_i_s_t_i_n_g_h_q_propiedad_asignada_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_propiedades_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_i_s_t_i_n_g_h_q_propiedades_model.dart';

class _HqCardData {
  final String id;
  final String address;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;
  final String tagText;

  /// Substatus crudo de la visita, para elegir el botón cuando una sección
  /// agrupa más de un substatus.
  final String substatus;

  _HqCardData({
    required this.id,
    required this.address,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.tagText,
    this.substatus = '',
  });
}

class LISTINGHQPropiedadesWidget extends StatefulWidget {
  const LISTINGHQPropiedadesWidget({super.key});

  static String routeName = 'LISTING_HQ_Propiedades';
  static String routePath = '/lISTINGHQPropiedades';

  @override
  State<LISTINGHQPropiedadesWidget> createState() =>
      _LISTINGHQPropiedadesWidgetState();
}

class _LISTINGHQPropiedadesWidgetState extends State<LISTINGHQPropiedadesWidget>
    with RouteAware {
  late LISTINGHQPropiedadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Checklist documental todavía en manos del LISTER_HQ; bloquea la
  /// asignación del operative hasta que todos los requeridos estén aprobados.
  static const String _kDocsSubstatus = 'MISSING_INFO,DOCS_SUBMITTED';

  /// `RESCHEDULE_REQUIRED` cubre el reagendamiento pedido y el no-show:
  /// el filtro del backend es por substatus y ambos comparten ese valor.
  static const String _kAssignSubstatus =
      'READY_TO_ASSIGN_OPERATIVE_LISTING,RESCHEDULE_REQUIRED';
  static const String _kPublishSubstatus = 'READY_TO_PUBLISH';

  // Paleta de las píldoras de estado, tomada del diseño.
  static const Color _kPendingBg = Color(0xFFFFDBBC);
  static const Color _kPendingFg = Color(0xFFF57E00);
  static const Color _kUrgentBg = Color(0xFFFFBCBC);
  static const Color _kUrgentFg = Color(0xFFF52100);

  Future<List<_HqCardData>>? _docsFuture;
  Future<List<_HqCardData>>? _assignFuture;
  Future<List<_HqCardData>>? _publishFuture;
  Future<List<_HqCardData>>? _legalFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQPropiedadesModel());
    _initFutures();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _initFutures() {
    _docsFuture = _fetchHqCards(substatus: _kDocsSubstatus);
    _assignFuture = _fetchHqCards(substatus: _kAssignSubstatus);
    _publishFuture = _fetchHqCards(substatus: _kPublishSubstatus);
    _legalFuture = _fetchLegalProcesses(status: '');
  }

  /// Etiqueta del pill lateral: "Reciente" el primer día y "N Días" después.
  String _ageLabel(dynamic updatedAt) {
    final parsed = DateTime.tryParse(updatedAt?.toString() ?? '');
    if (parsed == null) return 'Pendiente';
    final days = DateTime.now().toUtc().difference(parsed.toUtc()).inDays;
    if (days <= 0) return 'Reciente';
    return days == 1 ? '1 Día' : '$days Días';
  }

  /// Traduce el substatus de la visita al par (etiqueta, estatus) de la tarjeta.
  ({String tag, String status, Color bg, Color fg}) _cardLabels(
    String substatus,
    dynamic updatedAt,
  ) {
    switch (substatus) {
      case 'MISSING_INFO':
        return (
          tag: 'Faltan documentos',
          status: 'Pendiente',
          bg: _kPendingBg,
          fg: _kPendingFg
        );
      case 'DOCS_SUBMITTED':
        return (
          tag: 'Documentos por revisar',
          status: 'Pendiente',
          bg: _kPendingBg,
          fg: _kPendingFg
        );
      case 'READY_TO_ASSIGN_OPERATIVE_LISTING':
        return (
          tag: 'Programar',
          status: _ageLabel(updatedAt),
          bg: _kPendingBg,
          fg: _kPendingFg
        );
      case 'RESCHEDULE_REQUIRED':
        return (
          tag: 'Re-programar',
          status: 'Urgente',
          bg: _kUrgentBg,
          fg: _kUrgentFg
        );
      case 'READY_TO_PUBLISH':
        return (
          tag: 'Visita realizada',
          status: 'Pendiente',
          bg: _kPendingBg,
          fg: _kPendingFg
        );
      default:
        return (
          tag: 'Pendiente',
          status: 'Pendiente',
          bg: _kPendingBg,
          fg: _kPendingFg
        );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  /// Al volver del checklist o de la asignación, el substatus de la visita
  /// pudo cambiar y con él la sección donde corresponde mostrarla.
  @override
  void didPopNext() {
    _handleRefresh();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;
    setState(() {
      _initFutures();
    });
  }

  Map<String, dynamic>? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur as Map<String, dynamic> : null;
  }

  Future<List<_HqCardData>> _fetchHqCards({
    required String substatus,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getListerHqVisitsCall.call(
      authToken: token,
      substatus: substatus,
      page: '1',
      limit: '10',
    );
    if (!res.succeeded) return [];
    final raw = getJsonField(res.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    return visits.map((v) {
      final id = v is Map ? v['id']?.toString() ?? '' : '';
      final visitSubstatus = v is Map ? v['substatus']?.toString() ?? '' : '';
      String address = '';
      if (v is Map) {
        // `/visits/lister-hq` expone la propiedad resumida como
        // `propertyInfo`; se conserva `property` por compatibilidad.
        final prop = v['propertyInfo'] ?? v['property'];
        if (prop is Map) {
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ??
              prop['name']?.toString() ??
              '';
        }
      }
      final labels = _cardLabels(
        visitSubstatus,
        v is Map ? v['updatedAt'] : null,
      );
      return _HqCardData(
        id: id,
        address: address,
        statusText: labels.status,
        statusBgColor: labels.bg,
        statusTextColor: labels.fg,
        tagText: labels.tag,
        substatus: visitSubstatus,
      );
    }).toList();
  }

  Future<List<_HqCardData>> _fetchLegalProcesses({
    required String status,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPILegalProcessContextGroup
        .listLegalProcessesListerHQCall
        .call(
      authToken: token,
      status: status,
      page: '1',
      limit: '10',
    );
    if (!res.succeeded) return [];
    final raw = getJsonField(res.jsonBody, r'$.data');
    final processes = raw is List ? raw : <dynamic>[];

    return processes.map((p) {
      final id = p is Map ? p['id']?.toString() ?? '' : '';
      String address = '';
      if (p is Map) {
        final prop = p['property'] ??
            (p['visit'] is Map ? p['visit']['property'] : null);
        if (prop is Map) {
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ??
              '';
        }
      }
      return _HqCardData(
        id: id,
        address: address,
        statusText: 'Pausada',
        statusBgColor: _kUrgentBg,
        statusTextColor: _kUrgentFg,
        tagText: 'Urgente',
      );
    }).toList();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                    fontSize: 16.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCard({
    required String address,
    required String tagText,
    required String statusText,
    required Color statusBgColor,
    required Color statusTextColor,
    required String buttonText,
    VoidCallback? onPressed,
    VoidCallback? onEyePressed,
  }) {
    return Container(
      width: 250.0,
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          ),
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(15.0, 10.0, 15.0, 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address.isNotEmpty ? 'Dirección: $address' : 'Dirección: N/A',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              height: 22.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent1,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    tagText,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.publicSans(),
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 12.0,
                        ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estatus',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        fontSize: 12.0,
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        10.0, 2.0, 10.0, 2.0),
                    child: Text(
                      statusText,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: statusTextColor,
                            fontSize: 12.0,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: onPressed ?? () {},
                    text: buttonText,
                    options: FFButtonOptions(
                      height: 30.0,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w300,
                                ),
                                color: Colors.white,
                                fontSize: 13.0,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
                if (onEyePressed != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        8.0, 0.0, 0.0, 0.0),
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).accent1,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.visibility_outlined,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 16.0,
                        ),
                        onPressed: onEyePressed,
                      ),
                    ),
                  ),
              ],
            ),
          ].divide(const SizedBox(height: 8.0)),
        ),
      ),
    );
  }

  // ── Búsqueda y filtros (como en Documentos) ───────────────────────────────
  final _searchController = TextEditingController();
  String _query = '';
  String _section = 'all';

  static const _sectionFilters = [
    ('all', 'Todas'),
    ('docs', 'Documentación'),
    ('assign', 'Asignar Operative'),
    ('publish', 'Por publicar'),
    ('legal', 'Proceso legal'),
  ];

  bool _showSection(String key) => _section == 'all' || _section == key;

  static String _fold(String v) {
    const from = 'áéíóúüñÁÉÍÓÚÜÑ';
    const to = 'aeiouunAEIOUUN';
    final b = StringBuffer();
    for (final c in v.split('')) {
      final i = from.indexOf(c);
      b.write(i >= 0 ? to[i] : c);
    }
    return b.toString().toLowerCase();
  }

  /// Coincide con la dirección, la etiqueta o el estado de la tarjeta.
  bool _matches(_HqCardData e) {
    final q = _fold(_query.trim());
    if (q.isEmpty) return true;
    final haystack = _fold('${e.address} ${e.tagText} ${e.statusText}');
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }

  Widget _buildFilters() {
    const primary = Color(0xFF007376);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Buscar por dirección o estado...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF8A8A8A)),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (key, label) in _sectionFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _section == key,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _section = key),
                      selectedColor: Colors.white,
                      backgroundColor: const Color(0xFFEFF3F4),
                      side: BorderSide.none,
                      labelStyle: GoogleFonts.publicSans(
                        color: _section == key
                            ? const Color(0xFF00444B)
                            : const Color(0xFF8A8A8A),
                        fontWeight:
                            _section == key ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: _section == key ? 1 : 0,
                      pressElevation: 0,
                      shadowColor: primary.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<Widget> cards) {
    if (cards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          _query.trim().isEmpty
              ? 'No hay propiedades en esta sección'
              : 'Ninguna propiedad coincide con la búsqueda',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        height: 160.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: cards,
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: DoviaSpinner(),
      ),
    );
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
              RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.lISTINGHQHeaderModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const LISTINGHQHeaderWidget(
                          titleText: 'Propiedades',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 100.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _buildFilters(),
                            // Sección 1: Checklist documental pendiente.
                            if (_showSection('docs')) ...[
                              _buildSectionHeader(
                                'Propiedades a revisar su documentación',
                              ),
                              FutureBuilder<List<_HqCardData>>(
                                future: _docsFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return _buildLoader();
                                  return _buildHorizontalList(
                                    snapshot.data!
                                        .where(_matches)
                                        .map((e) => _buildCarouselCard(
                                              address: e.address,
                                              tagText: e.tagText,
                                              statusText: e.statusText,
                                              statusBgColor: e.statusBgColor,
                                              statusTextColor:
                                                  e.statusTextColor,
                                              buttonText: 'Revisar ahora',
                                              onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LISTINGHQPropiedadArchivosPendientesWidget(
                                                    title: e.address,
                                                    visitId: e.id,
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  );
                                },
                              ),
                            ],

                            // Sección 2: Asignar Operative Listing
                            if (_showSection('assign')) ...[
                              _buildSectionHeader(
                                'Propiedades que necesitan asignar un Operative Listing',
                              ),
                              FutureBuilder<List<_HqCardData>>(
                                future: _assignFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return _buildLoader();
                                  return _buildHorizontalList(
                                    snapshot.data!
                                        .where(_matches)
                                        .map((e) => _buildCarouselCard(
                                              address: e.address,
                                              tagText: e.tagText,
                                              statusText: e.statusText,
                                              statusBgColor: e.statusBgColor,
                                              statusTextColor:
                                                  e.statusTextColor,
                                              buttonText: e.substatus ==
                                                      'RESCHEDULE_REQUIRED'
                                                  ? 'Asignar de nuevo'
                                                  : 'Asignar Operative Listing',
                                              onPressed: () =>
                                                  context.pushNamed(
                                                LISTINGHQPropiedadAsignadaWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'visitId': serializeParam(
                                                      e.id, ParamType.String),
                                                }.withoutNulls,
                                              ),
                                              onEyePressed: () =>
                                                  context.pushNamed(
                                                'LISTING_HQ_Propiedad',
                                                queryParameters: {
                                                  'visitId': serializeParam(
                                                      e.id, ParamType.String),
                                                }.withoutNulls,
                                              ),
                                            ))
                                        .toList(),
                                  );
                                },
                              ),
                            ],

                            // Sección 3: Fotos cargadas, pendientes de revisión.
                            if (_showSection('publish')) ...[
                              _buildSectionHeader(
                                'Propiedades pendientes por publicar',
                              ),
                              FutureBuilder<List<_HqCardData>>(
                                future: _publishFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return _buildLoader();
                                  return _buildHorizontalList(
                                    snapshot.data!
                                        .where(_matches)
                                        .map((e) => _buildCarouselCard(
                                              address: e.address,
                                              tagText: e.tagText,
                                              statusText: e.statusText,
                                              statusBgColor: e.statusBgColor,
                                              statusTextColor:
                                                  e.statusTextColor,
                                              buttonText: 'Revisar checklist',
                                              onPressed: () =>
                                                  context.pushNamed(
                                                'LISTING_HQ_Propiedad',
                                                queryParameters: {
                                                  'visitId': serializeParam(
                                                      e.id, ParamType.String),
                                                }.withoutNulls,
                                              ),
                                            ))
                                        .toList(),
                                  );
                                },
                              ),
                            ],

                            // Sección 4: En proceso legal
                            if (_showSection('legal')) ...[
                              _buildSectionHeader(
                                'Propiedades en proceso legal',
                              ),
                              FutureBuilder<List<_HqCardData>>(
                                future: _legalFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return _buildLoader();
                                  return _buildHorizontalList(
                                    snapshot.data!
                                        .where(_matches)
                                        .map((e) => _buildCarouselCard(
                                              address: e.address,
                                              tagText: e.tagText,
                                              statusText: e.statusText,
                                              statusBgColor: e.statusBgColor,
                                              statusTextColor:
                                                  e.statusTextColor,
                                              buttonText: 'Revisar fotos',
                                              onPressed: () =>
                                                  context.pushNamed(
                                                'LISTING_HQ_Propiedad',
                                                queryParameters: {
                                                  'visitId': serializeParam(
                                                      e.id, ParamType.String),
                                                }.withoutNulls,
                                              ),
                                            ))
                                        .toList(),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.lISTINGHQNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const LISTINGHQNavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
