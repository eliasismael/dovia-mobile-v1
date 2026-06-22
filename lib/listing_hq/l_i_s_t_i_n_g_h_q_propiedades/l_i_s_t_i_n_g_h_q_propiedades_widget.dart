import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/popup_asignar_operative/popup_asignar_operative_widget.dart';
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

  _HqCardData({
    required this.id,
    required this.address,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.tagText,
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

class _LISTINGHQPropiedadesWidgetState
    extends State<LISTINGHQPropiedadesWidget> {
  late LISTINGHQPropiedadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const String _kAssignSubstatus = 'READY_TO_ASSIGN_OPERATIVE_LISTING';
  static const String _kPublishSubstatus = 'READY_TO_PUBLISH';

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
    _assignFuture = _fetchHqCards(
      substatus: _kAssignSubstatus,
      defaultTag: 'Programar',
      defaultStatus: 'Pendiente',
    );
    _publishFuture = _fetchHqCards(
      substatus: _kPublishSubstatus,
      defaultTag: 'Visita realizada',
      defaultStatus: 'Pendiente',
    );
    _legalFuture = _fetchLegalProcesses(status: '');
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
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
    required String defaultTag,
    required String defaultStatus,
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
      String address = '';
      if (v is Map) {
        final prop = v['property'];
        if (prop is Map) {
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ?? prop['name']?.toString() ?? '';
        }
      }
      return _HqCardData(
        id: id,
        address: address,
        statusText: defaultStatus,
        statusBgColor: const Color(0xFFF4D476),
        statusTextColor: const Color(0xFFF99F58),
        tagText: defaultTag,
      );
    }).toList();
  }

  Future<List<_HqCardData>> _fetchLegalProcesses({
    required String status,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPILegalProcessContextGroup.listLegalProcessesListerHQCall.call(
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
        final prop = p['property'] ?? (p['visit'] is Map ? p['visit']['property'] : null);
        if (prop is Map) {
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ?? '';
        }
      }
      return _HqCardData(
        id: id,
        address: address,
        statusText: 'Pausada',
        statusBgColor: const Color(0x33FF5963),
        statusTextColor: const Color(0xFFFF5963),
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
                ),
                if (onEyePressed != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
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
                            // Sección 1: Asignar Operative Listing
                            _buildSectionHeader(
                              'Propiedades que necesitan asignar un Operative Listing',
                            ),
                            FutureBuilder<List<_HqCardData>>(
                              future: _assignFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                return _buildHorizontalList(
                                  snapshot.data!.map((e) => _buildCarouselCard(
                                    address: e.address,
                                    tagText: e.tagText,
                                    statusText: e.statusText,
                                    statusBgColor: e.statusBgColor,
                                    statusTextColor: e.statusTextColor,
                                    buttonText: 'Asignar Operative Listing',
                                    onPressed: () async {
                                      final assigned = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => Dialog(
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                          alignment: const AlignmentDirectional(0.0, 0.0)
                                              .resolve(Directionality.of(context)),
                                          child: PopupAsignarOperativeWidget(
                                            visitId: e.id,
                                            propertyAddress: e.address,
                                          ),
                                        ),
                                      );
                                      if (assigned != true || !context.mounted) return;
                                      setState(() {
                                        _initFutures();
                                      });
                                    },
                                    onEyePressed: () => context.pushNamed(
                                      'LISTING_HQ_Propiedad',
                                      queryParameters: {
                                        'visitId': serializeParam(e.id, ParamType.String),
                                      }.withoutNulls,
                                    ),
                                  )).toList(),
                                );
                              },
                            ),

                            // Sección 2: Asignadas para publicar
                            _buildSectionHeader(
                              'Propiedades asignadas para publicar',
                            ),
                            FutureBuilder<List<_HqCardData>>(
                              future: _publishFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                return _buildHorizontalList(
                                  snapshot.data!.map((e) => _buildCarouselCard(
                                    address: e.address,
                                    tagText: e.tagText,
                                    statusText: e.statusText,
                                    statusBgColor: e.statusBgColor,
                                    statusTextColor: e.statusTextColor,
                                    buttonText: 'Revisar checklist',
                                    onPressed: () => context.pushNamed(
                                      'LISTING_HQ_Propiedad',
                                      queryParameters: {
                                        'visitId': serializeParam(e.id, ParamType.String),
                                      }.withoutNulls,
                                    ),
                                  )).toList(),
                                );
                              },
                            ),

                            // Sección 3: En proceso legal
                            _buildSectionHeader(
                              'Propiedades en proceso legal',
                            ),
                            FutureBuilder<List<_HqCardData>>(
                              future: _legalFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return _buildLoader();
                                return _buildHorizontalList(
                                  snapshot.data!.map((e) => _buildCarouselCard(
                                    address: e.address,
                                    tagText: e.tagText,
                                    statusText: e.statusText,
                                    statusBgColor: e.statusBgColor,
                                    statusTextColor: e.statusTextColor,
                                    buttonText: 'Actualizar Documentacion Legal',
                                    onPressed: () => context.pushNamed(
                                      'LISTING_HQ_Propiedad',
                                      queryParameters: {
                                        'visitId': serializeParam(e.id, ParamType.String),
                                      }.withoutNulls,
                                    ),
                                  )).toList(),
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
