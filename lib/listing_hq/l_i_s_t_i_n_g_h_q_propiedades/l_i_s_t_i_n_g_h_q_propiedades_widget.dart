import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_asignada/l_i_s_t_i_n_g_h_q_propiedad_asignada_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_propiedades_model.dart';
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

  /// Checklist documental todavía en manos del LISTER_HQ. No bloquea la
  /// asignación: estas propiedades también aparecen para asignar.
  static const String _kDocsSubstatus = 'MISSING_INFO,DOCS_SUBMITTED';

  /// `RESCHEDULE_REQUIRED` cubre el reagendamiento pedido y el no-show:
  /// el filtro del backend es por substatus y ambos comparten ese valor.
  ///
  /// También entran las que siguen con la documentación en revisión: se
  /// asigna en paralelo para que la visita no espere a la certificación.
  static const String _kAssignSubstatus =
      'MISSING_INFO,DOCS_SUBMITTED,READY_TO_ASSIGN_OPERATIVE_LISTING,RESCHEDULE_REQUIRED';
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

  Widget _buildHorizontalList(List<Widget> cards) {
    if (cards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          'No hay propiedades en esta sección',
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
        child: CircularProgressIndicator(),
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
                            20.0, 0.0, 20.0, 80.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Sección 1: Checklist documental pendiente.
                            _buildSectionHeader(
                              'Propiedades revisar documentacion',
                            ),
                            FutureBuilder<List<_HqCardData>>(
                              future: _docsFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                return _buildHorizontalList(
                                  snapshot.data!
                                      .map((e) => _buildCarouselCard(
                                            address: e.address,
                                            tagText: e.tagText,
                                            statusText: e.statusText,
                                            statusBgColor: e.statusBgColor,
                                            statusTextColor: e.statusTextColor,
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

                            // Sección 2: Asignar Operative Listing
                            _buildSectionHeader(
                              'Propiedades que necesitan asignar un Operative Listing',
                            ),
                            FutureBuilder<List<_HqCardData>>(
                              future: _assignFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                return _buildHorizontalList(
                                  snapshot.data!
                                      .map((e) => _buildCarouselCard(
                                            address: e.address,
                                            tagText: e.tagText,
                                            statusText: e.statusText,
                                            statusBgColor: e.statusBgColor,
                                            statusTextColor: e.statusTextColor,
                                            buttonText: e.substatus ==
                                                    'RESCHEDULE_REQUIRED'
                                                ? 'Asignar de nuevo'
                                                : 'Asignar Operative Listing',
                                            onPressed: () => context.pushNamed(
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

                            // Sección 3: Fotos cargadas, pendientes de revisión.
                            _buildSectionHeader(
                              'Propiedades pendientes por publicar',
                            ),
                            FutureBuilder<List<_HqCardData>>(
                              future: _publishFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                return _buildHorizontalList(
                                  snapshot.data!
                                      .map((e) => _buildCarouselCard(
                                            address: e.address,
                                            tagText: e.tagText,
                                            statusText: e.statusText,
                                            statusBgColor: e.statusBgColor,
                                            statusTextColor: e.statusTextColor,
                                            buttonText: 'Revisar checklist',
                                            onPressed: () => context.pushNamed(
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

                            // Sección 4: En proceso legal
                            _buildSectionHeader(
                              'Propiedades en proceso legal',
                            ),
                            FutureBuilder<List<_HqCardData>>(
                              future: _legalFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                return _buildHorizontalList(
                                  snapshot.data!
                                      .map((e) => _buildCarouselCard(
                                            address: e.address,
                                            tagText: e.tagText,
                                            statusText: e.statusText,
                                            statusBgColor: e.statusBgColor,
                                            statusTextColor: e.statusTextColor,
                                            buttonText: 'Revisar fotos',
                                            onPressed: () => context.pushNamed(
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
