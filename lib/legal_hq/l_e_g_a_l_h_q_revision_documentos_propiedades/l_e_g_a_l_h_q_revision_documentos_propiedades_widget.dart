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
import 'l_e_g_a_l_h_q_revision_documentos_propiedades_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_h_q_revision_documentos_propiedades_model.dart';

class LEGALHQRevisionDocumentosPropiedadesWidget extends StatefulWidget {
  const LEGALHQRevisionDocumentosPropiedadesWidget({
    super.key,
    this.processId,
  });

  /// Expediente legal que el Legal HQ va a auditar.
  final String? processId;

  static String routeName = 'LEGAL_HQ_RevisionDocumentosPropiedades';
  static String routePath = '/lEGALHQRevisionDocumentosPropiedades';

  @override
  State<LEGALHQRevisionDocumentosPropiedadesWidget> createState() =>
      _LEGALHQRevisionDocumentosPropiedadesWidgetState();
}

class _LEGALHQRevisionDocumentosPropiedadesWidgetState
    extends State<LEGALHQRevisionDocumentosPropiedadesWidget> {
  late LEGALHQRevisionDocumentosPropiedadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<LegalHqProcessDetail?> _detailFuture;

  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _beige = Color(0xFFEBEAE3);

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => LEGALHQRevisionDocumentosPropiedadesModel());
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
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // El título de la cabecera es el nombre de la propiedad.
                        wrapWithModel(
                          model: _model.legalHQHeaderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: LegalHQHeaderWidget(
                            text: detail?.process.title ?? 'Expediente',
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
            'No se pudo cargar el expediente',
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Información base del expediente ───────────────────────────────
        Container(
          decoration: ListingHqUi.cardDecoration(context),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _headlineForCategory(process.category),
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
              const SizedBox(height: 8.0),
              Text(
                'Propietario: ${process.ownerName.isNotEmpty ? process.ownerName : 'Sin datos'}',
                style: GoogleFonts.publicSans(
                  color: _textDark,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30.0),

        // ── Grilla de documentos ──────────────────────────────────────────
        Text(
          _documentsTitleForCategory(process.category),
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.32,
            height: 1.375,
          ),
        ),
        const SizedBox(height: 16.0),

        if (detail.documents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                'Este expediente todavía no tiene documentos cargados',
                textAlign: TextAlign.center,
                style: GoogleFonts.publicSans(
                  color: _textDark,
                  fontSize: 14.0,
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 20.0,
              // Alto suficiente para caja + nombre + estado + barra.
              mainAxisExtent: 235.0,
            ),
            itemCount: detail.documents.length,
            itemBuilder: (context, index) => _buildDocumentCard(
              context,
              process,
              detail.documents[index],
            ),
          ),
        if (process.status == 'APPROVED' &&
            (process.category == 'SALE' || process.category == 'RENT')) ...[
          const SizedBox(height: 28.0),
          LegalHqFinishCard(
            detail: detail,
            processId: widget.processId ?? '',
            onFinished: () => safeSetState(() {
              _detailFuture =
                  LegalHqProcessApi.fetchDetail(widget.processId ?? '');
            }),
          ),
        ],
      ],
    );
  }

  // ── Tarjeta de documento ──────────────────────────────────────────────────

  Widget _buildDocumentCard(
    BuildContext context,
    LegalHqProcess process,
    LegalHqDocument document,
  ) {
    final progress = legalHqDocumentProgress(document);

    return GestureDetector(
      onTap: () => _openDocument(process, document),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Caja beige con el tipo de archivo y el ícono para abrirlo
          Container(
            height: 121.0,
            decoration: BoxDecoration(
              color: _beige,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      document.hasFile
                          ? Icons.file_download_outlined
                          : Icons.hourglass_empty,
                      color: _textDark,
                      size: 22.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    document.hasFile
                        ? (document.isPdf ? 'PDF' : 'IMG')
                        : 'Sin archivo',
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

  /// Barra segmentada del diseño: tramos llenos en aqua y el resto al 50 %.
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

  // ── Navegación al visor ───────────────────────────────────────────────────

  Future<void> _openDocument(
    LegalHqProcess process,
    LegalHqDocument document,
  ) async {
    if (!document.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El documento todavía no fue subido'),
        ),
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
      }.withoutNulls,
    );

    // Al volver del visor la decisión pudo cambiar el checklist.
    if (mounted) safeSetState(_loadData);
  }

  // ── Textos según el tipo de expediente ────────────────────────────────────

  String _headlineForCategory(String category) {
    switch (category) {
      case kCategoryPublication:
        return 'Propiedad por publicar';
      case kCategoryMortgage:
        return 'Compraventa con hipoteca';
      case kCategoryRent:
        return 'Arrendamiento';
      default:
        return 'Compraventa';
    }
  }

  String _documentsTitleForCategory(String category) {
    return category == kCategoryPublication
        ? 'Documentos de la propiedad a publicar'
        : 'Documentos del expediente';
  }
}
