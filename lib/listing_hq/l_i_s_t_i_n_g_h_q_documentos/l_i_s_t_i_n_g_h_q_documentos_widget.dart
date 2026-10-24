import '/core/network_image_size.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_properties.dart';
import '/domain/offer_json.dart' show firstPropertyPhotoUrl;
import '/flutter_flow/flutter_flow_theme.dart';
import '/listing_hq/listing_hq_ui.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes/l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_documentos_model.dart';
import '/shared_components/dovia_spinner.dart';
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

  /// Documentos del checklist con su estado (missing, submitted, approved,
  /// rejected): es lo principal de la tarjeta.
  final List<({String label, String status})> documents;

  _DocCardData({
    this.documents = const [],
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
  // En el orden en que se muestran los filtros.
  static const Map<String, String> _tabStatusMap = {
    'Todos los documentos': '',
    'Pendiente': 'pending',
    'Revisión legal': 'in_legal_review', // TODO: backend will define this
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
      return (text: 'Pendiente', bg: ListingHqUi.pending, fg: Colors.white);
    }

    // Try to read status from item or nested checklist / document fields
    final status = (item['status'] ?? item['documentStatus'] ?? '')
        .toString()
        .toLowerCase();

    if (status.contains('approved') ||
        status.contains('accepted') ||
        status.contains('aceptada')) {
      return (text: 'Aceptada', bg: _approved, fg: Colors.white);
    }
    if (status.contains('legal') || status.contains('review')) {
      return (
        text: 'Revisión legal',
        bg: ListingHqUi.textDark,
        fg: Colors.white,
      );
    }
    if (status.contains('rejected') || status.contains('rechazada')) {
      return (text: 'Rechazada', bg: ListingHqUi.alert, fg: Colors.white);
    }
    if (status.contains('published') || status.contains('publicada')) {
      return (text: 'Publicada', bg: ListingHqUi.aqua, fg: Colors.white);
    }
    // Default: pending
    return (text: 'Pendiente', bg: ListingHqUi.pending, fg: Colors.white);
  }

  static const Color _approved = Color(0xFF249689);
  static const Color _missing = Color(0xFF888888);

  /// Búsqueda local por propiedad, dirección o nombre de documento.
  String _query = '';

  bool _matches(_DocCardData card) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final haystack = [
      card.propertyName,
      card.address,
      ...card.documents.map((d) => d.label),
    ].join(' ').toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }

  /// Fetches documents from the API for the current active tab.
  Future<List<_DocCardData>> _fetchDocuments() async {
    final token = currentAuthenticationToken ?? '';
    final statusFilter = _tabStatusMap[_model.activeTab] ?? '';

    final res =
        await DOVIAAPIVisitContextGroup.getListerHqVisitDocumentsCall.call(
      authToken: token,
      status: statusFilter,
      page: '1',
      limit: '50',
    );

    if (!res.succeeded) return [];

    final raw = getJsonField(res.jsonBody, r'$.data');
    final docs = raw is List ? raw : <dynamic>[];

    // Nombre, dirección y foto no vienen en este listado: se completan con
    // la propiedad (propertyId), una consulta por propiedad distinta.
    final propertyIds = <String>{
      for (final item in docs)
        if (item is Map && (item['propertyId']?.toString() ?? '').isNotEmpty)
          item['propertyId'].toString(),
    };
    final properties = <String, Map<String, dynamic>>{};
    await Future.wait(propertyIds.map((id) async {
      final r = await DOVIAAPIPropertyContextGroup.getPropertyByIDCall
          .call(propertyId: id);
      final data = r.succeeded ? getJsonField(r.jsonBody, r'$.data') : null;
      if (data is Map) properties[id] = Map<String, dynamic>.from(data);
    }));

    return docs.map((item) {
      final id = _resolveVisitId(item);
      String propertyName = '';
      String address = '';
      String imageUrl = '';
      final documentNames = <String>[];
      final documents = <({String label, String status})>[];

      if (item is Map) {
        propertyName = item['propertyName']?.toString() ?? '';
        final prop = properties[item['propertyId']?.toString() ?? ''] ??
            (item['property'] is Map
                ? Map<String, dynamic>.from(item['property'])
                : null);
        if (prop != null) {
          if (propertyName.isEmpty) {
            propertyName =
                prop['name']?.toString() ?? prop['title']?.toString() ?? '';
          }
          final locAddr = _deepMap(prop, ['location', 'address']);
          address = locAddr?['fullAddress']?.toString() ??
              locAddr?['street']?.toString() ??
              prop['fullAddress']?.toString() ??
              '';
          imageUrl =
              firstPropertyPhotoUrl(prop) ?? prop['image']?.toString() ?? '';
        }

        final list = item['documents'] ?? item['documentChecklist'];
        if (list is List) {
          for (final doc in list) {
            if (doc is! Map) continue;
            final label = doc['label']?.toString() ??
                doc['name']?.toString() ??
                doc['type']?.toString() ??
                '';
            if (label.isEmpty) continue;
            documentNames.add(label);
            documents.add((
              label: label,
              status: (doc['status']?.toString() ?? 'missing').toLowerCase(),
            ));
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
        documents: documents,
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
                            20.0, 20.0, 20.0, 110.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ListingHqSearchField(
                              hintText: 'Buscar por propiedad o documento',
                              controller: _model.textController,
                              onChanged: (v) => setState(() => _query = v),
                              onClear: () {
                                _model.textController?.clear();
                                setState(() => _query = '');
                              },
                            ),
                            const SizedBox(height: 12.0),
                            // Mismos filtros que en Propiedades.
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final tab in _tabStatusMap.keys)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(tab),
                                        selected: _model.activeTab == tab,
                                        showCheckmark: false,
                                        onSelected: (_) => _onTabChanged(tab),
                                        selectedColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFFEFF3F4),
                                        side: BorderSide.none,
                                        labelStyle: GoogleFonts.publicSans(
                                          color: _model.activeTab == tab
                                              ? ListingHqUi.textDark
                                              : const Color(0xFF8A8A8A),
                                          fontWeight: _model.activeTab == tab
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        elevation:
                                            _model.activeTab == tab ? 1 : 0,
                                        pressElevation: 0,
                                        shadowColor: ListingHqUi.aqua
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const ListingHqSectionHeader(
                                title: 'Documentos de propiedades'),
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
                                      child: DoviaSpinner(),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 40.0),
                                    child: Center(
                                      child: ListingHqUi.emptyText(context,
                                          'No pudimos cargar los documentos.'),
                                    ),
                                  );
                                }

                                final cards = (snapshot.data ?? [])
                                    .where(_matches)
                                    .toList();

                                if (cards.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 40.0),
                                    child: Center(
                                      child: ListingHqUi.emptyText(
                                        context,
                                        _query.trim().isEmpty
                                            ? 'No hay documentos en esta categoría.'
                                            : 'Ningún documento coincide con la búsqueda.',
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: cards
                                      .map((card) => _buildDocumentCard(card))
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

  static ({String text, Color bg, Color fg}) _docStatus(String status) =>
      switch (status) {
        'approved' => (text: 'Aprobado', bg: _approved, fg: Colors.white),
        'submitted' => (
            text: 'Por revisar',
            bg: ListingHqUi.pending,
            fg: Colors.white
          ),
        'rejected' => (
            text: 'Rechazado',
            bg: ListingHqUi.alert,
            fg: Colors.white
          ),
        _ => (text: 'Falta cargar', bg: _missing, fg: Colors.white),
      };

  Widget _chip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          text,
          style: GoogleFonts.publicSans(
              color: fg, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );

  /// Tarjeta de una visita: la propiedad arriba, chica, como contexto; los
  /// documentos del checklist abajo, cada uno con su estado.
  Widget _buildDocumentCard(_DocCardData card) {
    const textDark = Color(0xFF00444B);
    const grey = Color(0xFF6A6A6A);
    final pendingReview =
        card.documents.where((d) => d.status == 'submitted').length;

    Widget thumb() => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: card.imageUrl.isNotEmpty
              ? Image.network(
                  card.imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/casa_card_sobreMiVisita.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                  cacheWidth: networkImageCacheWidth(width: 52, height: 52),
                )
              : Image.asset(
                  'assets/images/casa_card_sobreMiVisita.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
        );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LISTINGHQPropiedadArchivosPendientesWidget(
                title: card.propertyName,
                visitId: card.visitId,
              ),
            ),
          );
          setState(() {
            _docsFuture = _fetchDocuments();
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: ListingHqUi.cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Propiedad: contexto.
              Row(
                children: [
                  thumb(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.propertyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.publicSans(
                              color: textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        if (card.address.isNotEmpty)
                          Text(
                            card.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.publicSans(
                                color: grey, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _chip(card.statusText, card.statusBgColor,
                      card.statusTextColor),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFEDEDED)),
              // Documentos: lo principal.
              Row(
                children: [
                  Text(
                    'Documentos',
                    style: GoogleFonts.publicSans(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (pendingReview > 0)
                    Text(
                      pendingReview == 1
                          ? '1 por revisar'
                          : '$pendingReview por revisar',
                      style: GoogleFonts.publicSans(
                          color: ListingHqUi.pending,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (card.documents.isEmpty)
                Text(
                  'Todavía no hay documentos en el checklist.',
                  style: GoogleFonts.publicSans(color: grey, fontSize: 13),
                )
              else
                for (final doc in card.documents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined,
                            size: 18, color: Color(0xFF007376)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doc.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.publicSans(
                                color: textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8),
                        () {
                          final st = _docStatus(doc.status);
                          return _chip(st.text, st.bg, st.fg);
                        }(),
                      ],
                    ),
                  ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ver documentos →',
                  style: GoogleFonts.publicSans(
                      color: const Color(0xFF007376),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
