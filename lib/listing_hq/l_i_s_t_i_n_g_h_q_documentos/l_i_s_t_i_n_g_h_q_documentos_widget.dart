import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_documentos_model.dart';
export 'l_i_s_t_i_n_g_h_q_documentos_model.dart';

/// Data class for a document card from the API.
class _DocCardData {
  final String visitId;
  final String propertyName;
  final String address;
  final String imageUrl;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;
  final List<String> documentNames;

  _DocCardData({
    required this.visitId,
    required this.propertyName,
    required this.address,
    required this.imageUrl,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.documentNames,
  });
}

class LISTINGHQDocumentosWidget extends StatefulWidget {
  const LISTINGHQDocumentosWidget({super.key});

  static String routeName = 'LISTING_HQ_Documentos';
  static String routePath = '/lISTINGHQDocumentos';

  @override
  State<LISTINGHQDocumentosWidget> createState() =>
      _LISTINGHQDocumentosWidgetState();
}

class _LISTINGHQDocumentosWidgetState extends State<LISTINGHQDocumentosWidget> {
  late LISTINGHQDocumentosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Map of tab label → API status filter value.
  /// Empty string means "no filter" (all documents).
  static const Map<String, String> _tabStatusMap = {
    'Pendiente': 'pending',
    'Revision legal': 'IN_PROGRESS',
    'Todos los documentos': '',
  };

  Future<List<_DocCardData>>? _docsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQDocumentosModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _docsFuture = _fetchDocuments();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Resolves the visit ID from a response item, checking multiple
  /// possible field locations (matching the home widget pattern).
  String _resolveVisitId(dynamic item) {
    if (item is! Map) return '';
    final visitId = item['visitId']?.toString();
    if (visitId != null && visitId.isNotEmpty) return visitId;
    final visit = item['visit'];
    if (visit is Map) {
      final nestedId = visit['id']?.toString();
      if (nestedId != null && nestedId.isNotEmpty) return nestedId;
    }
    return item['id']?.toString() ?? '';
  }

  /// Walks a nested map by [keys] and returns the inner map (or null).
  Map<String, dynamic>? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur as Map<String, dynamic> : null;
  }

  /// Resolves display status information from the raw API item.
  ({String text, Color bg, Color fg}) _resolveStatus(dynamic item) {
    if (item is! Map) {
      return (
        text: 'Pendiente',
        bg: const Color(0xFFFFDCCB),
        fg: Colors.orange,
      );
    }

    // Try to read status from item or nested checklist / document fields
    final status = (item['status'] ?? item['documentStatus'] ?? '').toString().toLowerCase();

    if (status.contains('approved') || status.contains('accepted') || status.contains('aceptada')) {
      return (
        text: 'Aceptada',
        bg: const Color(0x3370ACAD),
        fg: const Color(0xFF007376),
      );
    }
    if (status.contains('legal') || status.contains('review')) {
      return (
        text: 'Revisión legal',
        bg: const Color(0xFFE0E7FF),
        fg: const Color(0xFF4F46E5),
      );
    }
    if (status.contains('rejected') || status.contains('rechazada')) {
      return (
        text: 'Rechazada',
        bg: const Color(0xFFFFE4E4),
        fg: const Color(0xFFDC2626),
      );
    }
    if (status.contains('published') || status.contains('publicada')) {
      return (
        text: 'Publicada',
        bg: const Color(0xFFD1FAE5),
        fg: const Color(0xFF059669),
      );
    }
    // Default: pending
    return (
      text: 'Pendiente',
      bg: const Color(0xFFFFDCCB),
      fg: Colors.orange,
    );
  }

  /// Fetches documents from the API for the current active tab.
  Future<List<_DocCardData>> _fetchDocuments() async {
    final token = currentAuthenticationToken ?? '';
    final statusFilter = _tabStatusMap[_model.activeTab] ?? '';

    final res = await DOVIAAPIVisitContextGroup.getListerHqVisitDocumentsCall.call(
      authToken: token,
      status: statusFilter,
      page: '1',
      limit: '50',
    );

    if (!res.succeeded) return [];

    final raw = getJsonField(res.jsonBody, r'$.data');
    final docs = raw is List ? raw : <dynamic>[];

    return docs.map((item) {
      final id = _resolveVisitId(item);
      String propertyName = '';
      String address = '';
      String imageUrl = '';
      List<String> documentNames = [];

      if (item is Map) {
        // Extract property info
        final prop = item['property'] ??
            (item['visit'] is Map ? item['visit']['property'] : null);
        if (prop is Map) {
          propertyName = prop['name']?.toString() ??
              prop['title']?.toString() ?? '';
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ?? '';
          imageUrl = prop['image']?.toString() ?? '';
        }

        // Extract document names from checklist items
        final checklist = item['documentChecklist'] ??
            item['checklist'] ??
            (item['visit'] is Map ? item['visit']['documentChecklist'] : null);
        if (checklist is List) {
          for (final doc in checklist) {
            if (doc is Map) {
              final docName = doc['name']?.toString() ??
                  doc['type']?.toString() ?? '';
              if (docName.isNotEmpty) {
                documentNames.add(docName);
              }
            }
          }
        }

        // Fallback: extract document names from documents list
        if (documentNames.isEmpty) {
          final documents = item['documents'];
          if (documents is List) {
            for (final doc in documents) {
              if (doc is Map) {
                final docName = doc['fileName']?.toString() ??
                    doc['name']?.toString() ?? '';
                if (docName.isNotEmpty) {
                  documentNames.add(docName);
                }
              }
            }
          }
        }
      }

      final statusInfo = _resolveStatus(item);

      return _DocCardData(
        visitId: id,
        propertyName: propertyName.isNotEmpty ? propertyName : 'Propiedad',
        address: address,
        imageUrl: imageUrl,
        statusText: statusInfo.text,
        statusBgColor: statusInfo.bg,
        statusTextColor: statusInfo.fg,
        documentNames: documentNames,
      );
    }).toList();
  }

  /// Called when the user taps a tab.
  void _onTabChanged(String tab) {
    setState(() {
      _model.activeTab = tab;
      _docsFuture = _fetchDocuments();
    });
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
                onRefresh: () async {
                  setState(() {
                    _docsFuture = _fetchDocuments();
                  });
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.lISTINGHQHeaderModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const LISTINGHQHeaderWidget(
                          titleText: 'Documentos',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 20.0, 20.0, 80.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Search bar
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 20.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      // Search action
                                    },
                                    child: Container(
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(25.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(25.0),
                                          topRight: Radius.circular(0.0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                10.0, 10.0, 10.0, 10.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: SvgPicture.asset(
                                            'assets/images/lupa.svg',
                                            width: 24.0,
                                            height: 24.0,
                                            fit: BoxFit.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      width: 200.0,
                                      child: TextFormField(
                                        controller: _model.textController,
                                        focusNode: _model.textFieldFocusNode,
                                        autofocus: false,
                                        enabled: true,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelStyle: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                          hintText: 'Buscar documentos...',
                                          hintStyle: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(0.0),
                                              bottomRight: Radius.circular(25.0),
                                              topLeft: Radius.circular(0.0),
                                              topRight: Radius.circular(25.0),
                                            ),
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(0.0),
                                              bottomRight: Radius.circular(25.0),
                                              topLeft: Radius.circular(0.0),
                                              topRight: Radius.circular(25.0),
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context)
                                                  .error,
                                              width: 1.0,
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(0.0),
                                              bottomRight: Radius.circular(25.0),
                                              topLeft: Radius.circular(0.0),
                                              topRight: Radius.circular(25.0),
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context)
                                                  .error,
                                              width: 1.0,
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(0.0),
                                              bottomRight: Radius.circular(25.0),
                                              topLeft: Radius.circular(0.0),
                                              topRight: Radius.circular(25.0),
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        maxLines: null,
                                        cursorColor: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        enableInteractiveSelection: true,
                                        validator: _model.textControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Tabs
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 20.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          4.0, 4.0, 4.0, 4.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        'Pendiente',
                                        'Revision legal',
                                        'Todos los documentos'
                                      ].map((tab) {
                                        final isActive =
                                            _model.activeTab == tab;
                                        return Padding(
                                          padding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                  0.0, 0.0, 4.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor:
                                                Colors.transparent,
                                            onTap: () async {
                                              _onTabChanged(tab);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(16.0, 10.0,
                                                      16.0, 10.0),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0),
                                                boxShadow: isActive
                                                    ? const [
                                                        BoxShadow(
                                                          blurRadius: 4.0,
                                                          color: Color(
                                                              0x0D000000),
                                                          offset: Offset(
                                                              0.0, 2.0),
                                                        )
                                                      ]
                                                    : [],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  tab,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.inter(),
                                                        color: isActive
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                        fontWeight: isActive
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .normal,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Section title
                            Align(
                              alignment:
                                  const AlignmentDirectional(-1.0, 0.0),
                              child: Text(
                                'Documentos de propiedades',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                              ),
                            ),
                            // Dynamic document cards
                            FutureBuilder<List<_DocCardData>>(
                              future: _docsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 40.0),
                                    child: Center(
                                      child: Text(
                                        'Error al cargar documentos',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  );
                                }

                                final cards = snapshot.data ?? [];

                                if (cards.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 40.0),
                                    child: Center(
                                      child: Text(
                                        'No hay documentos en esta categoría',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: cards
                                      .map((card) =>
                                          _buildDocumentCard(card))
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
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    wrapWithModel(
                      model: _model.lISTINGHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQNavbarWidget(),
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

  /// Builds a single document card from API data.
  Widget _buildDocumentCard(_DocCardData card) {
    final docsText = card.documentNames.isNotEmpty
        ? card.documentNames.join(', ')
        : 'Sin documentos';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LISTINGHQPropiedadArchivosPendientesWidget(
                title: card.propertyName,
                visitId: card.visitId,
              ),
            ),
          );
        },
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                10.0, 10.0, 10.0, 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
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
                    child: card.imageUrl.isNotEmpty
                        ? Image.network(
                            card.imageUrl,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/casa_card_sobreMiVisita.png',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/casa_card_sobreMiVisita.png',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment:
                              const AlignmentDirectional(-1.0, 0.0),
                          child: RichText(
                            textScaler:
                                MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${card.propertyName}\n',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                ),
                                TextSpan(
                                  text: docsText,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                ),
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                    fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                    lineHeight: 1.5,
                                  ),
                            ),
                          ),
                        ),
                        Align(
                          alignment:
                              const AlignmentDirectional(0.0, 1.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Estatus',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                    ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: card.statusBgColor,
                                  borderRadius:
                                      BorderRadius.circular(24.0),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional
                                          .fromSTEB(
                                          16.0, 2.0, 16.0, 2.0),
                                  child: Text(
                                    card.statusText,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: card.statusTextColor,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ].divide(const SizedBox(width: 10.0)),
            ),
          ),
        ),
      ),
    );
  }
}
