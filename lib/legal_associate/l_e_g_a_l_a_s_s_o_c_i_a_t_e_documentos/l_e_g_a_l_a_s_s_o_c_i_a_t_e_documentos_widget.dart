import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/listing_hq/listing_hq_ui.dart';
import '/legal_hq/legal_hq_process_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_documentos_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_documentos_model.dart';

/// Qué tiene que hacer el asociado con un documento.
enum _Todo { review, hqRejected, missing, waitingFix }

class _InboxItem {
  const _InboxItem(this.doc, this.todo);
  final LegalHqDocument doc;
  final _Todo todo;
}

class _InboxProcess {
  const _InboxProcess({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.items,
  });
  final String id;
  final String title;
  final String subtitle;
  final String status;
  final List<_InboxItem> items;

  /// Cuántos ítems piden una acción del asociado ya mismo.
  int get urgent => items
      .where((i) => i.todo == _Todo.review || i.todo == _Todo.hqRejected)
      .length;
}

/// Bandeja "Documentos por revisar" del Legal Associate: junta, de todos sus
/// trámites activos, los documentos que esperan su revisión, los que Legal HQ
/// rechazó y los que todavía faltan cargar. Cada trámite abre su detalle.
class LEGALASSOCIATEDocumentosWidget extends StatefulWidget {
  const LEGALASSOCIATEDocumentosWidget({super.key});

  static String routeName = 'LEGAL_ASSOCIATE_Documentos';
  static String routePath = '/lEGALASSOCIATEDocumentos';

  @override
  State<LEGALASSOCIATEDocumentosWidget> createState() =>
      _LEGALASSOCIATEDocumentosWidgetState();
}

class _LEGALASSOCIATEDocumentosWidgetState
    extends State<LEGALASSOCIATEDocumentosWidget> {
  static const Color _primary = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _grey = Color(0xFF6A6A6A);

  late LEGALASSOCIATEDocumentosModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = true;
  List<_InboxProcess> _processes = const [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCIATEDocumentosModel());
    _load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Sólo en IN_PROGRESS y REJECTED el asociado puede subir o revisar
  /// documentos; en los demás estados no hay nada que hacer desde acá.
  Future<void> _load() async {
    final res = await DOVIAAPILegalProcessContextGroup
        .listLegalProcessesAssociateCall
        .call(
      authToken: currentAuthenticationToken ?? '',
      status: 'IN_PROGRESS,REJECTED',
      page: '1',
      limit: '50',
    );
    final raw = res.succeeded ? getJsonField(res.jsonBody, r'$.data') : null;
    final items = (raw is List ? raw : const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final details = await Future.wait(items.map(
        (json) => LegalHqProcessApi.fetchDetail(json['id']?.toString() ?? '')));

    final result = <_InboxProcess>[];
    for (var i = 0; i < items.length; i++) {
      final detail = details[i];
      if (detail == null) continue;
      final todo = _todoFor(detail);
      if (todo.isEmpty) continue;
      final property =
          items[i]['property'] is Map ? items[i]['property'] as Map : const {};
      final name = property['name']?.toString() ?? '';
      final address = property['fullAddress']?.toString() ?? '';
      result.add(_InboxProcess(
        id: detail.process.id,
        title:
            name.isNotEmpty ? name : (address.isNotEmpty ? address : 'Trámite'),
        subtitle: name.isNotEmpty ? address : '',
        status: detail.process.status,
        items: todo,
      ));
    }
    result.sort((a, b) => b.urgent.compareTo(a.urgent));

    if (!mounted) return;
    safeSetState(() {
      _processes = result;
      _loading = false;
    });
  }

  List<_InboxItem> _todoFor(LegalHqProcessDetail d) {
    final rejectedByHq = d.process.status == 'REJECTED';
    final out = <_InboxItem>[];
    for (final doc in d.documents) {
      // El comprobante de pago lo revisa Legal HQ, no el asociado.
      if (doc.type == 'DOVIA_PAYMENT_PROOF') continue;
      _Todo? todo;
      if (rejectedByHq && doc.hqReviewDecision == 'rejected') {
        todo = _Todo.hqRejected;
      } else if (doc.status == 'rejected') {
        todo = _Todo.waitingFix;
      } else if (!doc.hasFile || doc.status == 'missing') {
        if (doc.required_) todo = _Todo.missing;
      } else if (doc.status != 'approved') {
        todo = _Todo.review;
      }
      if (todo != null) out.add(_InboxItem(doc, todo));
    }
    out.sort((a, b) => a.todo.index.compareTo(b.todo.index));
    return out;
  }

  Future<void> _openProcess(_InboxProcess p) async {
    await context.pushNamed(
      LEGALASSOCIATEProcesos2Widget.routeName,
      queryParameters: {'processId': p.id, 'propertyName': p.title},
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // Sin SafeArea abajo: el contenido pasa por debajo de la barra
          // flotante hasta el borde de la pantalla.
          bottom: false,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              RefreshIndicator(
                color: _primary,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Más el indicador de inicio (iPhone): la pantalla no tiene
                  // SafeArea abajo.
                  padding: EdgeInsets.only(
                      bottom: 120 + MediaQuery.viewPaddingOf(context).bottom),
                  children: [
                    const LegalAssociateHeaderWidget(titleText: 'Documentos'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildBody(),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 1),
                child: wrapWithModel(
                  model: _model.lEGALASSOCAITENavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const LEGALASSOCAITENavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: DoviaSpinner()),
      );
    }
    if (_processes.isEmpty) {
      return _notice('Estás al día: no hay documentos para revisar ni '
          'pendientes de carga en tus trámites.');
    }
    final toReview = _processes.fold<int>(
        0, (n, p) => n + p.items.where((i) => i.todo == _Todo.review).length);
    final hqRejected = _processes.fold<int>(0,
        (n, p) => n + p.items.where((i) => i.todo == _Todo.hqRejected).length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _counter('$toReview', 'Por revisar')),
            const SizedBox(width: 12),
            Expanded(child: _counter('$hqRejected', 'Rechazados por HQ')),
          ],
        ),
        const SizedBox(height: 20),
        for (final p in _processes) ...[
          _processCard(p),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _notice(String text) => ListingHqUi.emptyText(context, text);

  Widget _counter(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: GoogleFonts.publicSans(color: _grey, fontSize: 12)),
          ],
        ),
      );

  BoxDecoration get _cardDecoration => ListingHqUi.cardDecoration(context);

  Widget _processCard(_InboxProcess p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openProcess(p),
        child: Ink(
          decoration: _cardDecoration,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.publicSans(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              if (p.subtitle.isNotEmpty)
                Text(p.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.publicSans(color: _grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                  p.status == 'REJECTED'
                      ? 'Legal HQ pidió correcciones'
                      : 'En documentación',
                  style: GoogleFonts.publicSans(
                      color: _primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const Divider(height: 22, color: Color(0xFFEDEDED)),
              for (final item in p.items) _itemRow(item),
              const SizedBox(height: 6),
              ListingHqUi.cardButton('Ver trámite', () => _openProcess(p)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemRow(_InboxItem item) {
    final (label, color) = switch (item.todo) {
      _Todo.review => ('Por revisar', ListingHqUi.pending),
      _Todo.hqRejected => ('Rechazado por HQ', ListingHqUi.alert),
      _Todo.missing => ('Falta cargar', _grey),
      _Todo.waitingFix => ('Esperando corrección', _grey),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(item.doc.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.publicSans(color: _textDark, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(label,
                style: GoogleFonts.publicSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
