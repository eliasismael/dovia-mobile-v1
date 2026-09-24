import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedades/l_i_s_t_i_n_g_h_q_propiedades_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_rechazada/l_i_s_t_i_n_g_h_q_propiedad_rechazada_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_asignada/l_i_s_t_i_n_g_h_q_propiedad_asignada_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_home_model.dart';
export 'l_i_s_t_i_n_g_h_q_home_model.dart';

class _HqCardData {
  final String id;
  final String address;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;
  final String tagText;

  /// Substatus crudo de la visita. Define qué botón muestra la tarjeta cuando
  /// un carril agrupa más de un substatus (ej. asignar vs. re-asignar).
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

class _HqLargeCardData {
  final String id;
  final String title;
  final String ownerName;
  final String address;
  final String imageUrl;

  _HqLargeCardData({
    required this.id,
    required this.title,
    required this.ownerName,
    required this.address,
    required this.imageUrl,
  });
}

class LISTINGHQHomeWidget extends StatefulWidget {
  const LISTINGHQHomeWidget({super.key});

  static String routeName = 'LISTING_HQ_Home';
  static String routePath = '/lISTINGHQHome';

  @override
  State<LISTINGHQHomeWidget> createState() => _LISTINGHQHomeWidgetState();
}

class _LISTINGHQHomeWidgetState extends State<LISTINGHQHomeWidget>
    with RouteAware {
  late LISTINGHQHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Checklist documental todavía en manos del LISTER_HQ: `MISSING_INFO`
  /// (falta subir algún documento requerido) y `DOCS_SUBMITTED` (subidos,
  /// pendientes de aprobar). Mientras la visita esté aquí el backend rechaza
  /// `assign-operative-lister`.
  static const String _kDocsSubstatus = 'MISSING_INFO,DOCS_SUBMITTED';

  /// Listas para asignar operative lister. `RESCHEDULE_REQUIRED` cubre tanto
  /// la solicitud de reagendamiento como el no-show, porque el filtro del
  /// backend es por substatus y ambos comparten ese valor.
  ///
  /// También entran las que siguen con la documentación en revisión: se
  /// asigna en paralelo para que la visita no espere a la certificación.
  static const String _kAssignSubstatus =
      'MISSING_INFO,DOCS_SUBMITTED,READY_TO_ASSIGN_OPERATIVE_LISTING,RESCHEDULE_REQUIRED';
  static const String _kPublishSubstatus = 'READY_TO_PUBLISH';
  static const String _kLegalRejectedStatus = 'REJECTED';
  static const String _kCorrectionsSubstatus = 'CHANGES_REQUESTED';

  // Paleta de las píldoras de estado, tomada del diseño.
  static const Color _kPendingBg = Color(0xFFFFDBBC);
  static const Color _kPendingFg = Color(0xFFF57E00);
  static const Color _kUrgentBg = Color(0xFFFFBCBC);
  static const Color _kUrgentFg = Color(0xFFF52100);
  static const Color _kAlertBg = Color(0xFFF8D5D5);
  static const Color _kAlertFg = Color(0xFFBC0000);

  Future<List<_HqCardData>>? _docsFuture;
  Future<List<_HqCardData>>? _assignFuture;
  Future<List<_HqCardData>>? _publishFuture;
  Future<List<_HqLargeCardData>>? _legalRejectedFuture;
  Future<List<_HqLargeCardData>>? _correctionsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQHomeModel());
    _initFutures();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _initFutures() {
    _docsFuture = _fetchHqCards(substatus: _kDocsSubstatus);
    _assignFuture = _fetchHqCards(substatus: _kAssignSubstatus);
    _publishFuture = _fetchHqCards(substatus: _kPublishSubstatus);
    _legalRejectedFuture = _fetchLegalProcesses(status: _kLegalRejectedStatus);
    _correctionsFuture = _fetchHqLargeCards(substatus: _kCorrectionsSubstatus);
  }

  /// Etiqueta del pill lateral: "Reciente" el primer día y "N Días" después,
  /// para que HQ vea de un vistazo qué tarjeta lleva más tiempo esperando.
  String _ageLabel(dynamic updatedAt) {
    final parsed = DateTime.tryParse(updatedAt?.toString() ?? '');
    if (parsed == null) return 'Pendiente';
    final days = DateTime.now().toUtc().difference(parsed.toUtc()).inDays;
    if (days <= 0) return 'Reciente';
    return days == 1 ? '1 Día' : '$days Días';
  }

  /// Traduce el substatus de la visita al par (etiqueta, estatus) que muestra
  /// la tarjeta.
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

  /// Se dispara al volver de una pantalla apilada sobre el home. Revisar o
  /// subir documentos cambia el substatus de la visita en el backend, así que
  /// los carriles hay que releerlos: si no, la propiedad sigue apareciendo en
  /// el carril viejo.
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

  Future<List<_HqLargeCardData>> _fetchLegalProcesses({
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
      String title = 'Propiedad';
      String address = '';
      String ownerName = '';
      if (p is Map) {
        final prop = p['property'] ??
            (p['visit'] is Map ? p['visit']['property'] : null);
        if (prop is Map) {
          title = prop['name']?.toString() ??
              prop['title']?.toString() ??
              'Propiedad';
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ??
              '';
        }
        final owner = p['ownerProfile'] ??
            (p['visit'] is Map ? p['visit']['ownerProfile'] : null);
        if (owner is Map) {
          ownerName = owner['fullName']?.toString() ?? '';
        }
      }
      return _HqLargeCardData(
        id: id,
        title: title,
        ownerName: ownerName,
        address: address,
        imageUrl: 'assets/images/casa_card_sobreMiVisita.png',
      );
    }).toList();
  }

  Future<List<_HqLargeCardData>> _fetchHqLargeCards({
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
      String title = 'Propiedad';
      String address = '';
      String ownerName = '';
      if (v is Map) {
        final prop = v['property'];
        if (prop is Map) {
          title = prop['name']?.toString() ??
              prop['title']?.toString() ??
              'Propiedad';
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ??
              '';
        }
        final owner = v['ownerProfile'];
        if (owner is Map) {
          ownerName = owner['fullName']?.toString() ?? '';
        }
      }
      return _HqLargeCardData(
        id: id,
        title: title,
        ownerName: ownerName,
        address: address,
        imageUrl: 'assets/images/casa_card_sobreMiVisita.png',
      );
    }).toList();
  }

  Widget _buildSectionHeader(String title, String routeToPush,
      {bool isExpanded = false, VoidCallback? onToggle}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          FFButtonWidget(
            onPressed: onToggle ??
                () {
                  if (routeToPush.isNotEmpty) {
                    context.pushNamed(routeToPush);
                  }
                },
            text: onToggle != null
                ? (isExpanded ? 'Ver menos' : 'Ver todo')
                : 'Ver todo',
            options: FFButtonOptions(
              height: 30.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              color: FlutterFlowTheme.of(context).accent1,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.publicSans(),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 14.0,
                  ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(24.0),
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
            FFButtonWidget(
              onPressed: onPressed ??
                  () {
                    print('Button pressed ...');
                  },
              text: buttonText,
              options: FFButtonOptions(
                width: double.infinity,
                height: 30.0,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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

  Widget _buildLargeCard(
    String title,
    String ownerName,
    String address, {
    VoidCallback? onPressed,
    String buttonText = 'Ver más',
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 15.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
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
          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/casa_card_sobreMiVisita.png',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isNotEmpty ? title : 'Propiedad',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                            fontSize: 16.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      address.isNotEmpty
                          ? 'Dirección: $address'
                          : 'Dirección: N/A',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            fontSize: 12.0,
                          ),
                    ),
                    if (ownerName.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        ownerName,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              fontSize: 12.0,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _kAlertBg,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            10.0, 4.0, 10.0, 4.0),
                        child: Text(
                          'Falta información',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: _kAlertFg,
                                    fontSize: 12.0,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    FFButtonWidget(
                      onPressed: onPressed ?? () {},
                      text: buttonText,
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 30.0,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.publicSans(),
                                  color: Colors.white,
                                  fontSize: 13.0,
                                ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(24.0),
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
                          titleText: 'Home',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 20.0, 20.0, 0.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed('LISTING_HQ_BusquedaPropiedad');
                          },
                          child: Container(
                            width: double.infinity,
                            height: 64.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
                                    child: SvgPicture.asset(
                                      'assets/images/search.svg',
                                      width: 24.0,
                                      height: 24.0,
                                      fit: BoxFit.none,
                                      colorFilter: ColorFilter.mode(
                                        FlutterFlowTheme.of(context)
                                            .primaryText,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  Text(
                                    'Búsqueda con IA',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(),
                                          color: const Color(0xFF888888),
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 80.0), // Padding bottom for navbar
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Fila 1: Checklist documental pendiente. Estas
                            // propiedades también salen en la fila 2: el
                            // operative se asigna sin esperar la revisión.
                            _buildSectionHeader(
                              'Propiedades revisar documentacion',
                              LISTINGHQPropiedadesWidget.routeName,
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

                            // Fila 2: Asignar Operative Listing
                            _buildSectionHeader(
                              'Asignar Operative Listing a una propiedad',
                              LISTINGHQPropiedadesWidget.routeName,
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
                                                : 'Asignar',
                                            onPressed: () => context.pushNamed(
                                              LISTINGHQPropiedadAsignadaWidget
                                                  .routeName,
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

                            // Fila 3: Fotos cargadas, pendientes de revisión.
                            _buildSectionHeader(
                              'Propiedades pendientes por publicar',
                              LISTINGHQPropiedadesWidget.routeName,
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

                            // Fila 4: Propiedades Rechazadas por Dovia Legal
                            _buildSectionHeader(
                              'Propiedades Rechazadas por Dovia Legal',
                              '',
                              isExpanded: _model.isRechazadasExpanded,
                              onToggle: () {
                                setState(() {
                                  _model.isRechazadasExpanded =
                                      !_model.isRechazadasExpanded;
                                });
                              },
                            ),
                            FutureBuilder<List<_HqLargeCardData>>(
                              future: _legalRejectedFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                if (snapshot.data!.isEmpty) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Text(
                                      'No hay propiedades en esta sección',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                    ),
                                  );
                                }
                                final first = snapshot.data!.first;
                                final rest = snapshot.data!.skip(1).toList();
                                return Column(
                                  children: [
                                    _buildLargeCard(
                                      first.title,
                                      first.ownerName,
                                      first.address,
                                      buttonText:
                                          'Actualizar Documentacion Legal',
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LISTINGHQPropiedadRechazadaWidget(
                                                  processId: first.id),
                                        ),
                                      ),
                                    ),
                                    AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      child: _model.isRechazadasExpanded
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: rest
                                                  .map((e) => _buildLargeCard(
                                                        e.title,
                                                        e.ownerName,
                                                        e.address,
                                                        buttonText:
                                                            'Actualizar Documentacion Legal',
                                                        onPressed: () =>
                                                            Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                LISTINGHQPropiedadRechazadaWidget(
                                                                    processId:
                                                                        e.id),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                );
                              },
                            ),

                            // Fila 5: Propiedades a la espera de correcciones
                            _buildSectionHeader(
                              'Propiedades a la espera de correcciones',
                              '',
                              isExpanded: _model.isCorreccionesExpanded,
                              onToggle: () {
                                setState(() {
                                  _model.isCorreccionesExpanded =
                                      !_model.isCorreccionesExpanded;
                                });
                              },
                            ),
                            FutureBuilder<List<_HqLargeCardData>>(
                              future: _correctionsFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                if (snapshot.data!.isEmpty) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Text(
                                      'No hay propiedades en esta sección',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                    ),
                                  );
                                }
                                final first = snapshot.data!.first;
                                final rest = snapshot.data!.skip(1).toList();
                                return Column(
                                  children: [
                                    _buildLargeCard(
                                      first.title,
                                      first.ownerName,
                                      first.address,
                                      buttonText: 'Contactar con Propietario',
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LISTINGHQPropiedadArchivosPendientesWidget(
                                                  title: first.title,
                                                  visitId: first.id),
                                        ),
                                      ),
                                    ),
                                    AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      child: _model.isCorreccionesExpanded
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: rest
                                                  .map((e) => _buildLargeCard(
                                                        e.title,
                                                        e.ownerName,
                                                        e.address,
                                                        buttonText:
                                                            'Contactar con Propietario',
                                                        onPressed: () =>
                                                            Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                LISTINGHQPropiedadArchivosPendientesWidget(
                                                                    title:
                                                                        e.title,
                                                                    visitId:
                                                                        e.id),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                            )
                                          : const SizedBox.shrink(),
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
              ),
              Align(
                alignment: const AlignmentDirectional(
                    0.0, 1.0), // Fix alignment to bottom
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
