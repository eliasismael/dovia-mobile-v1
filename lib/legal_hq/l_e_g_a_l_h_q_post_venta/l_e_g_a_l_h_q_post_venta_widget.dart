import '/legal_hq/legal_hq_finish_card.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_hq/l_e_g_a_l_h_q_documento/l_e_g_a_l_h_q_documento_widget.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/legal_hq/legal_hq_process_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/listing_hq/listing_hq_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_e_g_a_l_h_q_post_venta_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_h_q_post_venta_model.dart';

/// Cierre de Operación: el Legal HQ audita los documentos finales que ya revisó
/// el Legal Associate y consulta el historial de versiones del contrato antes
/// de dar el visto bueno al cierre.
class LEGALHQPostVentaWidget extends StatefulWidget {
  const LEGALHQPostVentaWidget({
    super.key,
    this.processId,
  });

  final String? processId;

  static String routeName = 'LEGAL_HQ_PostVenta';
  static String routePath = '/lEGALHQPostVenta';

  @override
  State<LEGALHQPostVentaWidget> createState() => _LEGALHQPostVentaWidgetState();
}

class _LEGALHQPostVentaWidgetState extends State<LEGALHQPostVentaWidget> {
  late LEGALHQPostVentaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<LegalHqProcessDetail?> _detailFuture;

  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _beige = Color(0xFFEBEAE3);
  static const Color _versionTagBg = Color(0xFFEFEFEF);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALHQPostVentaModel());
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _loadData() {
    final processId = widget.processId ?? '';
    _detailFuture = processId.isEmpty
        ? Future.value(null)
        : LegalHqProcessApi.fetchDetail(processId);
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
              FutureBuilder<LegalHqProcessDetail?>(
                future: _detailFuture,
                builder: (context, snapshot) {
                  final loading =
                      snapshot.connectionState == ConnectionState.waiting;
                  final detail = snapshot.data;

                  return SingleChildScrollView(
                    // Lo que ocupa el indicador de inicio (iPhone), que ya no
                    // descuenta el SafeArea: el final queda sobre la barra.
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.viewPaddingOf(context).bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        wrapWithModel(
                          model: _model.legalHQHeaderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: LegalHQHeaderWidget(
                            text: detail?.process.title ?? 'Cierre',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 30.0, 20.0, 120.0),
                          child: loading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 80.0),
                                  child: Center(
                                    child: DoviaSpinner(),
                                  ),
                                )
                              : detail == null
                                  ? _buildError(context)
                                  : _buildContent(context, detail),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    wrapWithModel(
                      model: _model.lEGALHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LEGALHQNavbarWidget(),
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

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: Column(
        children: [
          Icon(Icons.error_outline,
              color: FlutterFlowTheme.of(context).secondaryText, size: 40.0),
          const SizedBox(height: 12.0),
          Text(
            'No se pudo cargar el cierre de la operación',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Verificá que el expediente siga asignado a tu usuario.',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 13.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LegalHqProcessDetail detail) {
    final process = detail.process;
    final statusStyle = legalHqStatusStyle(process.status);
    final reviewable = detail.reviewableDocuments;
    final versions = detail.contractVersions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Cabecera y metadatos del cierre ────────────────────────────
        Container(
          decoration: ListingHqUi.cardDecoration(context),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cierre de Operación',
                style: GoogleFonts.publicSans(
                  color: _textDark,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    'Estatus',
                    style: GoogleFonts.publicSans(
                      color: _aqua,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container(
                        height: 23.0,
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: statusStyle.background,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Text(
                          statusStyle.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.publicSans(
                            color: statusStyle.foreground,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              _metaLine('Cliente', process.clientName),
              const SizedBox(height: 4.0),
              _metaLine('Propietario', process.ownerName),
              const SizedBox(height: 4.0),
              // Clave para la auditoría: a quién se está revisando.
              _metaLine('Legal Associate asignado', process.legalAssociateName),
            ],
          ),
        ),

        const SizedBox(height: 30.0),

        // ── 2. Grilla de documentos auditados ─────────────────────────────
        Text(
          'Documentos revisados por Dovia Legal Associate',
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.32,
            height: 1.375,
          ),
        ),
        const SizedBox(height: 16.0),

        if (reviewable.isEmpty)
          _emptyBlock('Todavía no hay documentos revisados en este expediente')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 20.0,
              mainAxisExtent: 235.0,
            ),
            itemCount: reviewable.length,
            itemBuilder: (context, index) => _buildDocumentCard(
              context,
              process,
              reviewable[index],
            ),
          ),

        if (detail.process.status == 'APPROVED' &&
            (detail.process.category == 'SALE' ||
                detail.process.category == 'RENT')) ...[
          const SizedBox(height: 28.0),
          LegalHqFinishCard(
            detail: detail,
            processId: widget.processId ?? '',
            onFinished: () => safeSetState(_loadData),
          ),
        ],

        const SizedBox(height: 30.0),

        // ── 3. Historial de versiones del contrato ────────────────────────
        Text(
          'Historial de versiones del contrato',
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.32,
            height: 1.375,
          ),
        ),
        const SizedBox(height: 16.0),

        if (versions.isEmpty)
          _emptyBlock('Este expediente todavía no tiene versiones de contrato')
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final version in versions)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                  child: _buildVersionRow(context, process, version),
                ),
            ],
          ),
      ],
    );
  }

  Widget _metaLine(String label, String value) {
    return Text(
      '$label: ${value.isNotEmpty ? value : 'Sin datos'}',
      style: GoogleFonts.publicSans(
        color: _textDark,
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _emptyBlock(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.publicSans(color: _textDark, fontSize: 14.0),
        ),
      ),
    );
  }

  // ── Tarjeta de documento auditado ─────────────────────────────────────────

  Widget _buildDocumentCard(
    BuildContext context,
    LegalHqProcess process,
    LegalHqDocument document,
  ) {
    final progress = legalHqDocumentProgress(document);

    return GestureDetector(
      onTap: () => _openDocument(process, document, readOnly: false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 121.0,
            decoration: BoxDecoration(
              color: _beige,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                const Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.file_download_outlined,
                        color: _textDark, size: 22.0),
                  ),
                ),
                Center(
                  child: Text(
                    document.isPdf ? 'PDF' : 'IMG',
                    style: GoogleFonts.publicSans(
                      color: _textDark,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            document.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            progress.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              color: _aqua,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8.0),
          _buildSegmentedProgress(progress.filledSegments),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgress(int filledSegments) {
    return SizedBox(
      height: 13.0,
      child: Row(
        children: List.generate(kDocumentProgressSegments, (index) {
          final isFilled = index < filledSegments;
          final isFirst = index == 0;
          final isLast = index == kDocumentProgressSegments - 1;
          return Expanded(
            child: Container(
              height: 13.0,
              decoration: BoxDecoration(
                color: isFilled ? _aqua : _aqua.withValues(alpha: 0.5),
                border: isFirst
                    ? null
                    : const Border(
                        left: BorderSide(color: Color(0xFF3B8F92), width: 1.0),
                      ),
                borderRadius: BorderRadius.horizontal(
                  left: isFirst ? const Radius.circular(100.0) : Radius.zero,
                  right: isLast ? const Radius.circular(100.0) : Radius.zero,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Fila del historial de versiones ───────────────────────────────────────

  Widget _buildVersionRow(
    BuildContext context,
    LegalHqProcess process,
    LegalHqContractVersion version,
  ) {
    return GestureDetector(
      // Solo lectura: el historial sirve para comparar, no para decidir.
      onTap: () => _openDocument(process, version.document, readOnly: true),
      child: Row(
        children: [
          Container(
            width: 56.0,
            height: 36.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _versionTagBg,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              version.tag,
              style: GoogleFonts.publicSans(
                color: _textDark,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              version.document.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.publicSans(
                color: _aqua,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: _aqua, size: 20.0),
        ],
      ),
    );
  }

  // ── Navegación al visor ───────────────────────────────────────────────────

  Future<void> _openDocument(
    LegalHqProcess process,
    LegalHqDocument document, {
    required bool readOnly,
  }) async {
    if (!document.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El documento todavía no fue subido')),
      );
      return;
    }

    await context.pushNamed(
      LEGALHQDocumentoWidget.routeName,
      queryParameters: {
        'processId': serializeParam(process.id, ParamType.String),
        'documentId': serializeParam(document.id, ParamType.String),
        'nombreDocumento': serializeParam(document.label, ParamType.String),
        'documentUrl': serializeParam(document.url, ParamType.String),
        'propertyName': serializeParam(process.title, ParamType.String),
        'category': serializeParam(process.category, ParamType.String),
        'readOnly': serializeParam(readOnly, ParamType.bool),
      }.withoutNulls,
    );

    if (mounted) safeSetState(_loadData);
  }
}
