import '/backend/api_requests/api_dovia_home.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/legal_hq/legal_hq_process_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/listing_hq/listing_hq_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l_e_g_a_l_h_q_documento_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_h_q_documento_model.dart';

class LEGALHQDocumentoWidget extends StatefulWidget {
  const LEGALHQDocumentoWidget({
    super.key,
    String? nombreDocumento,
    this.processId,
    this.documentId,
    this.documentUrl,
    this.propertyName,
    this.category,
    bool? readOnly,
  })  : nombreDocumento = nombreDocumento ?? 'Contrato de convenio',
        readOnly = readOnly ?? false;

  final String nombreDocumento;

  /// Expediente y documento sobre los que se toma la decisión de Legal HQ.
  final String? processId;
  final String? documentId;

  /// URL del archivo a visualizar.
  final String? documentUrl;

  /// Nombre de la propiedad, que es el título de la cabecera.
  final String? propertyName;

  /// Categoría del expediente: define a quién vuelven las observaciones.
  final String? category;

  /// Consulta histórica: se muestra el documento sin acciones de decisión.
  final bool readOnly;

  static String routeName = 'LEGAL_HQ_Documento';
  static String routePath = '/lEGALHQDocumento';

  @override
  State<LEGALHQDocumentoWidget> createState() => _LEGALHQDocumentoWidgetState();
}

class _LEGALHQDocumentoWidgetState extends State<LEGALHQDocumentoWidget> {
  late LEGALHQDocumentoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// `true` cuando el HQ tocó [Rechazar] y está escribiendo la justificación.
  bool _isRejecting = false;

  /// `true` mientras se envía la decisión al backend.
  bool _isSubmitting = false;

  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _red = Color(0xFFD92D20);
  static const Color _disabledGrey = Color(0xFFE3E3E3);
  static const Color _disabledText = Color(0xFF9A9A9A);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALHQDocumentoModel());
    _loadProcessStatus();

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    // La justificación es obligatoria: el botón Enviar se habilita con texto.
    _model.textController!.addListener(_onNoteChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.textController?.removeListener(_onNoteChanged);
    _model.dispose();

    super.dispose();
  }

  void _onNoteChanged() => safeSetState(() {});

  bool get _hasNote => (_model.textController?.text ?? '').trim().isNotEmpty;

  bool get _isPublication => widget.category == kCategoryPublication;

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
              SingleChildScrollView(
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
                        text: widget.propertyName?.isNotEmpty == true
                            ? widget.propertyName!
                            : 'Documento',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 24.0, 20.0, 120.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDocumentHeader(context),
                          const SizedBox(height: 12.0),
                          _buildViewerBox(context),
                          // En consulta histórica no hay decisión que tomar.
                          if (widget.readOnly) ...[
                            const SizedBox(height: 16.0),
                            _buildReadOnlyNotice(context),
                          ] else if (!_statusLoaded) ...[
                            const SizedBox(height: 16.0),
                            const Center(
                              child: DoviaSpinner(small: true),
                            ),
                          ] else if (_awaitingSubmission) ...[
                            const SizedBox(height: 16.0),
                            _buildNotSubmittedNotice(),
                          ] else if ((_hqDecision != null || _processClosed) &&
                              !_changingDecision) ...[
                            const SizedBox(height: 16.0),
                            _buildDecisionState(),
                          ] else if (_changingDecision) ...[
                            const SizedBox(height: 16.0),
                            _buildRejectionForm(context),
                          ] else ...[
                            const SizedBox(height: 16.0),
                            _buildDecisionButtons(context),
                            if (_isRejecting) ...[
                              const SizedBox(height: 20.0),
                              _buildRejectionForm(context),
                            ],
                          ],
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

  // ── Nombre del documento + descarga ───────────────────────────────────────

  Widget _buildDocumentHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.nombreDocumento,
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12.0),
        GestureDetector(
          onTap: _downloadDocument,
          child: Container(
            width: 56.0,
            height: 28.0,
            alignment: Alignment.center,
            // Botón secundario: blanco con borde, como en el cliente.
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _aqua),
              borderRadius: BorderRadius.circular(99.0),
            ),
            child: const Icon(
              Icons.file_download_outlined,
              color: _aqua,
              size: 18.0,
            ),
          ),
        ),
      ],
    );
  }

  // ── Visor del documento ───────────────────────────────────────────────────

  Widget _buildViewerBox(BuildContext context) {
    return Opacity(
      // Al rechazar, el documento se atenúa junto con los botones.
      opacity: _isRejecting ? 0.5 : 1.0,
      child: Container(
        height: 420.0,
        decoration: ListingHqUi.cardDecoration(context),
        clipBehavior: Clip.antiAlias,
        child: _buildDocumentViewer(),
      ),
    );
  }

  Widget _buildDocumentViewer() {
    final url = widget.documentUrl ?? '';
    if (url.isEmpty) return _unsupportedPlaceholder();

    final isPdf = url.toLowerCase().contains('.pdf') ||
        url.toLowerCase().contains('/pdf');
    if (isPdf) {
      return SfPdfViewer.network(url);
    }

    return InteractiveViewer(
      child: Image.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _unsupportedPlaceholder(),
      ),
    );
  }

  Widget _unsupportedPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined,
              color: FlutterFlowTheme.of(context).secondaryText, size: 40.0),
          const SizedBox(height: 10.0),
          Text(
            'No se puede previsualizar este archivo',
            style: GoogleFonts.publicSans(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Consulta de una versión histórica ─────────────────────────────────────

  Widget _buildReadOnlyNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFCCE3E4),
        borderRadius: BorderRadius.circular(10.0),
      ),
      // Aviso: fondo suave y texto, sin ícono.
      child: Text(
        'Versión histórica en modo solo lectura',
        style: GoogleFonts.publicSans(
          color: _aqua,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Estado del proceso. El backend sólo acepta decisiones de Legal HQ en
  /// LEGAL_HQ_REVIEW o REJECTED: antes, el Legal Associate tiene que iniciar
  /// el proceso, juntar los documentos y enviarlo a revisión.
  String? _processStatus;

  /// Hasta saber el estado no se muestran ni los botones ni el aviso: si no,
  /// los botones aparecen un instante y después los reemplaza el aviso.
  bool _statusLoaded = false;

  Future<void> _loadProcessStatus() async {
    final id = widget.processId ?? '';
    if (id.isEmpty) {
      safeSetState(() => _statusLoaded = true);
      return;
    }
    final detail = await LegalHqProcessApi.fetchDetail(id);
    if (!mounted) return;
    String? decision;
    for (final doc in detail?.documents ?? const <LegalHqDocument>[]) {
      if (doc.id == widget.documentId) {
        decision = doc.hqReviewDecision;
        break;
      }
    }
    safeSetState(() {
      _processStatus = detail?.process.status;
      _hqDecision = (decision ?? '').isEmpty ? null : decision;
      _statusLoaded = true;
    });
  }

  /// Decisión que ya tomó Legal HQ sobre este documento (`approved` /
  /// `rejected`), o null si todavía no lo revisó.
  String? _hqDecision;

  /// El backend deja pasar un documento aprobado a rechazado (Ej: fue un
  /// error) mientras el proceso siga en revisión o rechazado. Lo inverso no:
  /// un rechazado sólo se destraba con un archivo nuevo del asociado.
  bool _changingDecision = false;

  bool get _processClosed =>
      _processStatus == 'APPROVED' || _processStatus == 'FINISHED';

  Widget _plainNotice(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0x2670ACAD),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          text,
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _buildDecisionState() {
    if (_processClosed) {
      return _plainNotice('El proceso ya fue aprobado: las decisiones sobre '
          'sus documentos quedaron cerradas.');
    }
    if (_hqDecision == 'rejected') {
      return _plainNotice('Rechazaste este documento. El Legal Associate tiene '
          'que volver a subirlo corregido para que puedas revisarlo de nuevo.');
    }
    // Aprobado.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _plainNotice('Ya aprobaste este documento.'),
        const SizedBox(height: 12.0),
        SizedBox(
          height: 44.0,
          child: OutlinedButton(
            onPressed: () => safeSetState(() {
              _changingDecision = true;
              _isRejecting = true;
            }),
            style: OutlinedButton.styleFrom(
              backgroundColor: _red,
              side: const BorderSide(color: _red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0)),
            ),
            child: Text(
              'Me equivoqué, rechazarlo',
              style: GoogleFonts.publicSans(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get _awaitingSubmission {
    final status = _processStatus;
    return status != null &&
        status != 'LEGAL_HQ_REVIEW' &&
        status != 'REJECTED' &&
        status != 'APPROVED' &&
        status != 'FINISHED';
  }

  Widget _buildNotSubmittedNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        'Podrás aprobar o rechazar este documento cuando el proceso '
        'esté "Pendiente de tu revisión". Ahora está '
        '"${legalHqStatusStyle(_processStatus ?? '').label}": el Legal '
        'Associate todavía no lo envió a revisión de Legal HQ.',
        style: GoogleFonts.publicSans(
          color: const Color(0xFF8A4B0B),
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Aprobar / Rechazar ────────────────────────────────────────────────────

  Widget _buildDecisionButtons(BuildContext context) {
    // Mientras se escribe la justificación, ambos botones quedan bloqueados.
    final blocked = _isRejecting || _isSubmitting;

    return Row(
      children: [
        Expanded(
          child: _decisionButton(
            label: 'Aprobar',
            icon: Icons.check_circle_outline,
            background: blocked ? _aqua.withValues(alpha: 0.35) : _aqua,
            foreground: Colors.white,
            onPressed: blocked ? null : _approveDocument,
            loading: _approving,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _decisionButton(
            label: 'Rechazar',
            icon: Icons.highlight_off,
            background: blocked ? _red.withValues(alpha: 0.35) : _red,
            foreground: Colors.white,
            onPressed:
                blocked ? null : () => safeSetState(() => _isRejecting = true),
          ),
        ),
      ],
    );
  }

  Widget _decisionButton({
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      height: 44.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              DoviaSpinner(small: true, color: foreground)
            else
              Icon(icon, size: 18.0, color: foreground),
            const SizedBox(width: DoviaSpinner.textGap),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.publicSans(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Formulario de rechazo ─────────────────────────────────────────────────

  Widget _buildRejectionForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Indica porque rechazas los documentos.',
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6.0),
        // Quien corrige es quien carga los documentos del proceso: el Listing
        // HQ en publicaciones y el Legal Associate en ventas y rentas (el
        // backend le avisa a él, no al propietario).
        Text(
          _isPublication
              ? 'Le avisaremos al Listing HQ para que revise las observaciones '
                  'y vuelva a subir el documento corregido.'
              : 'Le avisaremos al Legal Associate para que revise las '
                  'observaciones y vuelva a subir el documento corregido.',
          style: GoogleFonts.publicSans(
            color: _aqua,
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 14.0),
        Container(
          decoration: ListingHqUi.cardDecoration(context),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          child: TextField(
            controller: _model.textController,
            focusNode: _model.textFieldFocusNode,
            maxLines: 5,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Escribe aquí...',
              hintStyle: GoogleFonts.publicSans(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 14.0,
              ),
            ),
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 14.0,
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        SizedBox(
          height: 48.0,
          child: ElevatedButton(
            // Obligatorio: sin justificación no se puede enviar.
            onPressed: (_hasNote && !_isSubmitting) ? _rejectDocument : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _aqua,
              disabledBackgroundColor: _disabledGrey,
              foregroundColor: Colors.white,
              disabledForegroundColor: _disabledText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            child: _isSubmitting
                ? const DoviaSpinner(small: true, color: Colors.white)
                : Text(
                    'Enviar',
                    style: GoogleFonts.publicSans(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10.0),
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  _model.textController?.clear();
                  safeSetState(() {
                    _isRejecting = false;
                    _changingDecision = false;
                  });
                },
          child: Text(
            'Cancelar',
            style: GoogleFonts.publicSans(
              color: _aqua,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  /// Aprobación en curso: el botón muestra un spinner desde el toque hasta
  /// que aparece el popup de resultado.
  bool _approving = false;

  Future<void> _approveDocument() async {
    safeSetState(() => _approving = true);
    final result = await _submitDecision(status: 'approved');
    if (!mounted) return;
    if (result == null) {
      safeSetState(() => _approving = false);
      return;
    }

    // El backend recalcula el estado del proceso a partir de las decisiones de
    // todos los documentos: solo cuando quedan todos aprobados pasa a APPROVED.
    final detail = await LegalHqProcessApi.fetchDetail(widget.processId ?? '');
    if (!mounted) return;

    final processApproved = detail?.process.status == 'APPROVED';
    safeSetState(() => _approving = false);
    await _showResultPopup(
      title: 'Se aprobó con éxito',
      text: processApproved
          ? (_isPublication
              ? 'La propiedad quedo habilitada para publicación.'
              : 'El expediente quedó aprobado.')
          : 'El documento quedó aprobado. Todavía quedan documentos por revisar.',
    );
  }

  Future<void> _rejectDocument() async {
    final note = (_model.textController?.text ?? '').trim();
    final result = await _submitDecision(status: 'rejected', note: note);
    if (result == null || !mounted) return;

    await _showResultPopup(
      title: 'Se envió correctamente',
      text: _isPublication
          ? 'Las observaciones han sido enviadas al Listing HQ.'
          : 'Las observaciones han sido enviadas al Legal Associate.',
    );
  }

  /// Envía la decisión. Devuelve `true` si el backend la aceptó, o `null`
  /// cuando falló (ya se mostró el error).
  Future<bool?> _submitDecision({
    required String status,
    String note = '',
  }) async {
    final processId = widget.processId ?? '';
    final documentId = widget.documentId ?? '';

    if (processId.isEmpty || documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta la referencia del documento')),
      );
      return null;
    }

    safeSetState(() => _isSubmitting = true);

    final response = await LegalHqProcessApi.reviewDocument(
      processId: processId,
      documentId: documentId,
      status: status,
      note: note,
    );

    if (!mounted) return null;

    // Con éxito los botones siguen bloqueados hasta que el popup devuelve al
    // expediente: si se liberaban acá, volvían un instante a su color fuerte.
    if (!response.succeeded) {
      safeSetState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // El motivo del backend (Ej: el proceso no está en revisión o no
          // está asignado a este Legal HQ) dice qué hacer; el genérico no.
          content: Text([
            status == 'approved'
                ? 'No se pudo aprobar el documento'
                : 'No se pudo enviar el rechazo',
            if (doviaHomeErrorMessage(response) != null)
              doviaHomeErrorMessage(response)!,
          ].join(': ')),
        ),
      );
      return null;
    }

    return true;
  }

  /// Modal central con check verde; al cerrarlo vuelve al expediente.
  Future<void> _showResultPopup({
    required String title,
    required String text,
  }) async {
    await showDialog(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: GestureDetector(
            onTap: () => Navigator.pop(dialogContext),
            child: PopupExitoWidget(
              title: title,
              text: text,
              continueText: 'Continuar',
              onContinue: () => Navigator.pop(dialogContext),
            ),
          ),
        );
      },
    );

    if (mounted) context.safePop();
  }

  Future<void> _downloadDocument() async {
    final url = widget.documentUrl ?? '';
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento')),
      );
    }
  }
}
