import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/legal_hq/legal_hq_process_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos2_model.dart';
export 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos2_model.dart';

/// Pantalla del trámite legal del asociado. Muestra el paso que corresponde
/// al estado del proceso:
///
/// 1. Pendiente de cláusulas (`NOT_STARTED` / `IN_PROGRESS`): acuerdo,
///    revisión de documentos y contacto con las partes.
/// 2. En redacción (`DRAFTING`): descarga del documento base y carga del
///    contrato final.
/// 3. Reunión agendada (`MEETING_COORDINATION` / `MEETING_SCHEDULED`): agenda
///    de la firma, carga del contrato firmado y envío a Legal HQ.
/// 4. En revisión Legal HQ (`LEGAL_HQ_REVIEW`), con sus salidas `REJECTED`
///    (corregir y reenviar) y `APPROVED` / `FINISHED` (cierre).
class LEGALASSOCIATEProcesos2Widget extends StatefulWidget {
  const LEGALASSOCIATEProcesos2Widget({
    super.key,
    this.processId,
    this.propertyName,
  });

  final String? processId;

  /// Nombre de la propiedad (el detalle del trámite solo trae la dirección).
  final String? propertyName;

  static String routeName = 'LEGAL_ASSOCIATE_Procesos_2';
  static String routePath = '/lEGALASSOCIATEProcesos2';

  @override
  State<LEGALASSOCIATEProcesos2Widget> createState() =>
      _LEGALASSOCIATEProcesos2WidgetState();
}

class _LEGALASSOCIATEProcesos2WidgetState
    extends State<LEGALASSOCIATEProcesos2Widget> {
  late LEGALASSOCIATEProcesos2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const _primary = Color(0xFF007376);
  static const _textDark = Color(0xFF00444B);
  static const _banner = Color(0xFFDCE9EA);
  static const _pill = Color(0xFFCFE3E3);
  static const _strip = Color(0xFFE9E8E2);

  LegalHqProcessDetail? _detail;
  bool _loading = true;
  bool _agreementOpen = true;
  bool _documentsOpen = true;
  bool _extrasOpen = true;
  bool _uploading = false;
  bool _continuing = false;
  bool _scheduleModalShown = false;
  String? _busyDocId;

  /// Notas de la reunión de firma; viajan con el envío a Legal HQ.
  final _notesController = TextEditingController();

  String get _processId => widget.processId ?? '';
  String get _status => _detail?.process.status ?? '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCIATEProcesos2Model());
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_processId.isEmpty) {
      safeSetState(() => _loading = false);
      return;
    }
    final detail = await LegalHqProcessApi.fetchDetail(_processId);
    if (!mounted) return;
    safeSetState(() {
      _detail = detail;
      _loading = false;
    });
    // Recién llegado al paso 3 sin reunión: se abre la agenda sola.
    if (detail != null &&
        detail.process.status == 'MEETING_COORDINATION' &&
        detail.activeAppointment == null &&
        !_scheduleModalShown) {
      _scheduleModalShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _schedule();
      });
    }
  }

  void _snack(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red : _primary,
    ));
  }

  String _backendMessage(ApiCallResponse res, String fallback) {
    final msg = getJsonField(res.jsonBody, r'$.message');
    final text = msg is List ? msg.join('\n') : msg?.toString();
    return text != null && text.isNotEmpty ? text : fallback;
  }

  /// Ejecuta una acción del backend con el botón principal en espera y
  /// recarga el trámite si salió bien.
  Future<bool> _run(
    Future<ApiCallResponse> Function() call, {
    required String ok,
    required String fail,
  }) async {
    safeSetState(() => _continuing = true);
    final res = await call();
    if (!mounted) return false;
    safeSetState(() => _continuing = false);
    if (!res.succeeded) {
      _snack(_backendMessage(res, fail), error: true);
      return false;
    }
    _snack(ok);
    await _load();
    return true;
  }

  Future<FFUploadedFile?> _pickFile() async {
    final files = await selectFiles(
      multiFile: false,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (files == null || files.isEmpty || !mounted) return null;
    final file = files.first;
    return FFUploadedFile(name: file.originalFilename, bytes: file.bytes);
  }

  /// Sube un archivo con el selector nativo y recarga el trámite.
  Future<void> _uploadWith(
    Future<ApiCallResponse> Function(FFUploadedFile file) call, {
    String ok = 'Documento cargado',
  }) async {
    final file = await _pickFile();
    if (file == null) return;
    safeSetState(() => _uploading = true);
    final res = await call(file);
    if (!mounted) return;
    safeSetState(() => _uploading = false);
    if (!res.succeeded) {
      _snack(_backendMessage(res, 'No se pudo cargar el documento'),
          error: true);
      return;
    }
    _snack(ok);
    _load();
  }

  Future<void> _openUrl(String url, {String error = 'No se pudo abrir'}) async {
    final uri = Uri.tryParse(url);
    var ok = false;
    try {
      if (uri != null) {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    if (!ok) _snack(error, error: true);
  }

  Future<void> _open(LegalHqDocument doc) =>
      _openUrl(doc.url, error: 'No se pudo abrir el documento');

  // ── Paso 1: revisión de documentos ────────────────────────────────────────

  Future<void> _review(LegalHqDocument doc, bool approve) async {
    String? note;
    if (!approve) {
      note = await _askText(
        title: '¿Qué hay que corregir?',
        hint: 'Ej: la foto está borrosa',
        action: 'Enviar',
      );
      if (note == null) return;
    }
    safeSetState(() => _busyDocId = doc.id);
    final res = await DOVIAAPILegalProcessContextGroup
        .reviewLegalProcessDocumentCall
        .call(
      processId: _processId,
      documentId: doc.id,
      authToken: currentAuthenticationToken,
      status: approve ? 'approved' : 'rejected',
      note: note,
    );
    if (!mounted) return;
    safeSetState(() => _busyDocId = null);
    if (!res.succeeded) {
      _snack(_backendMessage(res, 'No se pudo revisar el documento'),
          error: true);
      return;
    }
    _snack(approve ? 'Documento marcado como correcto' : 'Documento observado');
    _load();
  }

  Future<void> _delete(LegalHqDocument doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar documento'),
        content: Text('¿Eliminar "${doc.fileName}"? Podés volver a cargarlo '
            'después.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;
    safeSetState(() => _busyDocId = doc.id);
    final res = await DOVIAAPILegalProcessContextGroup
        .deleteLegalProcessDocumentCall
        .call(
      processId: _processId,
      documentId: doc.id,
      authToken: currentAuthenticationToken,
    );
    if (!mounted) return;
    safeSetState(() => _busyDocId = null);
    if (!res.succeeded) {
      _snack(_backendMessage(res, 'No se pudo eliminar el documento'),
          error: true);
      return;
    }
    _snack('Documento eliminado');
    _load();
  }

  Future<void> _uploadCustomDocument() => _uploadWith(
        (file) => DOVIAAPILegalProcessContextGroup
            .createLegalProcessDocumentCall
            .call(
          processId: _processId,
          authToken: currentAuthenticationToken,
          file: file,
        ),
      );

  /// Pasa el trámite a "En redacción". El backend exige que todos los
  /// documentos requeridos o cargados estén marcados como correctos.
  Future<void> _advanceToDrafting() async {
    final detail = _detail;
    if (detail == null) return;
    final pending = detail.documents
        .where((d) => (d.required_ || d.hasFile) && d.status != 'approved')
        .toList();
    if (pending.isNotEmpty) {
      _snack(
        'Antes de continuar marcá como correctos todos los documentos '
        '(${pending.length} pendiente${pending.length == 1 ? '' : 's'}).',
        error: true,
      );
      return;
    }
    if (detail.process.status == 'NOT_STARTED') {
      safeSetState(() => _continuing = true);
      final start = await DOVIAAPILegalProcessContextGroup.startLegalProcessCall
          .call(processId: _processId, authToken: currentAuthenticationToken);
      if (!mounted) return;
      safeSetState(() => _continuing = false);
      if (!start.succeeded) {
        _snack(_backendMessage(start, 'No se pudo iniciar el proceso'),
            error: true);
        return;
      }
    }
    await _run(
      () => DOVIAAPILegalProcessContextGroup.advanceToDraftingCall
          .call(processId: _processId, authToken: currentAuthenticationToken),
      ok: 'El trámite pasó a "En redacción"',
      fail: 'No se pudo pasar a redacción',
    );
  }

  // ── Paso 2: redacción ─────────────────────────────────────────────────────

  bool get _hasContract => _detail?.unsignedContractUrl.isNotEmpty ?? false;

  Future<void> _uploadContract() => _uploadWith(
        (file) =>
            DOVIAAPILegalProcessContextGroup.uploadUnsignedContractCall.call(
          processId: _processId,
          authToken: currentAuthenticationToken,
          file: file,
        ),
        ok: 'Contrato cargado',
      );

  /// Documento base para redactar: el convenio de DOVIA de la operación o,
  /// si ya hay uno, el último borrador del contrato.
  String get _baseDocumentUrl {
    final agreement = _detail?.doviaAgreementCardDocument;
    if (agreement != null && agreement.hasFile) return agreement.url;
    return _detail?.unsignedContractUrl ?? '';
  }

  Future<void> _downloadBase() async {
    final url = _baseDocumentUrl;
    if (url.isEmpty) {
      _snack('Todavía no hay un documento base para descargar', error: true);
      return;
    }
    await _openUrl(url, error: 'No se pudo descargar el documento');
  }

  Future<void> _advanceToMeeting() => _run(
        () => DOVIAAPILegalProcessContextGroup.advanceToMeetingCoordinationCall
            .call(processId: _processId, authToken: currentAuthenticationToken),
        ok: 'Contrato listo. Agendá la reunión de firma.',
        fail: 'No se pudo avanzar a la reunión',
      );

  // ── Paso 3: reunión de firma ──────────────────────────────────────────────

  /// Abre "Agenda la reunion". Sin reunión vigente la crea; con una, la
  /// re-agenda con la dirección anterior pre-llenada y fecha y hora vacías.
  Future<void> _schedule() async {
    final current = _detail?.activeAppointment;
    final result = await showDialog<(String, DateTime)>(
      context: context,
      builder: (_) => _ScheduleMeetingDialog(
        initialAddress: current != null
            ? current.address
            : (_detail?.lastAppointmentAddress ?? ''),
      ),
    );
    if (result == null || !mounted) return;
    final (address, scheduledAt) = result;
    final iso = scheduledAt.toUtc().toIso8601String();
    if (current == null) {
      await _run(
        () => DOVIAAPILegalProcessContextGroup.scheduleAppointmentCall.call(
          processId: _processId,
          authToken: currentAuthenticationToken,
          scheduledAt: iso,
          address: address,
        ),
        ok: 'Reunión agendada. Avisamos al propietario y al cliente.',
        fail: 'No se pudo agendar la reunión',
      );
    } else {
      await _run(
        () => DOVIAAPILegalProcessContextGroup.rescheduleAppointmentCall.call(
          processId: _processId,
          appointmentId: current.id,
          authToken: currentAuthenticationToken,
          newScheduledAt: iso,
          address: address,
        ),
        ok: 'Reunión re-agendada. Avisamos a las partes.',
        fail: 'No se pudo re-agendar la reunión',
      );
    }
  }

  Future<void> _cancelMeeting() async {
    final current = _detail?.activeAppointment;
    if (current == null) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelMeetingDialog(),
    );
    if (reason == null || !mounted) return;
    await _run(
      () => DOVIAAPILegalProcessContextGroup.cancelAppointmentCall.call(
        processId: _processId,
        appointmentId: current.id,
        authToken: currentAuthenticationToken,
        cancelReason: reason,
      ),
      ok: 'Reunión cancelada. Avisamos a las partes.',
      fail: 'No se pudo cancelar la reunión',
    );
  }

  Future<void> _uploadSignedContract() => _uploadWith(
        (file) =>
            DOVIAAPILegalProcessContextGroup.uploadSignedContractCall.call(
          processId: _processId,
          authToken: currentAuthenticationToken,
          file: file,
        ),
        ok: 'Contrato firmado cargado',
      );

  LegalHqDocument? get _signedContract {
    for (final d in _detail?.documents ?? const <LegalHqDocument>[]) {
      if (d.type == 'SIGNED_CONTRACT' && d.hasFile) return d;
    }
    return null;
  }

  Future<void> _submitToHq() async {
    if (_signedContract == null) {
      _snack('Cargá el contrato firmado antes de enviar a Legal HQ',
          error: true);
      return;
    }
    final ok = await _run(
      () => DOVIAAPILegalProcessContextGroup.submitToHQReviewCall.call(
        processId: _processId,
        authToken: currentAuthenticationToken,
        meetingNotes: _notesController.text,
      ),
      ok: 'Enviado a Legal HQ para su revisión',
      fail: 'No se pudo enviar a Legal HQ',
    );
    if (ok && mounted) context.safePop();
  }

  // ── Paso 4: revisión de Legal HQ ──────────────────────────────────────────

  List<LegalHqDocument> get _rejectedDocuments => [
        for (final d in _detail?.documents ?? const <LegalHqDocument>[])
          if (d.status == 'rejected' || d.hqReviewDecision == 'rejected') d,
      ];

  /// Motivos del rechazo: la nota que dejó HQ en cada documento rechazado
  /// o, si no hay, la nota del cambio de estado.
  List<String> get _rejectionReasons {
    final reasons = [
      for (final d in _rejectedDocuments)
        d.note.isNotEmpty ? '${d.label}: ${d.note}' : d.label,
    ];
    if (reasons.isNotEmpty) return reasons;
    return _detail?.process.rejectionReasons ?? const [];
  }

  Future<void> _reuploadRejected() async {
    final rejected = _rejectedDocuments;
    if (rejected.isEmpty) {
      _snack('No hay documentos rechazados para volver a cargar');
      return;
    }
    var doc = rejected.first;
    if (rejected.length > 1) {
      final picked = await showDialog<LegalHqDocument>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('¿Qué documento vas a volver a cargar?'),
          children: [
            for (final d in rejected)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, d),
                child: Text(d.label),
              ),
          ],
        ),
      );
      if (picked == null) return;
      doc = picked;
    }
    await _uploadWith(
      (file) =>
          DOVIAAPILegalProcessContextGroup.uploadLegalProcessDocumentCall.call(
        processId: _processId,
        documentId: doc.id,
        authToken: currentAuthenticationToken,
        file: file,
      ),
      ok: 'Documento corregido cargado',
    );
  }

  Future<void> _resubmitToHq() async {
    final blocking = (_detail?.documents ?? const <LegalHqDocument>[])
        .where((d) => d.status == 'rejected' || d.status == 'missing')
        .toList();
    if (blocking.isNotEmpty) {
      _snack(
        'Volvé a cargar los documentos rechazados antes de reenviar '
        '(${blocking.length} pendiente${blocking.length == 1 ? '' : 's'}).',
        error: true,
      );
      return;
    }
    await _run(
      () => DOVIAAPILegalProcessContextGroup.resubmitToHQReviewCall
          .call(processId: _processId, authToken: currentAuthenticationToken),
      ok: 'Reenviado a Legal HQ',
      fail: 'No se pudo reenviar a Legal HQ',
    );
  }

  /// Cierra el trámite aprobado. El backend exige el comprobante de pago a
  /// DOVIA, que sube el cliente desde su app.
  Future<void> _finish() async {
    if (!(_detail?.hasPaymentProof ?? false)) {
      _snack('Falta que el cliente cargue el comprobante de pago a DOVIA',
          error: true);
      return;
    }
    final ok = await _run(
      () => DOVIAAPILegalProcessContextGroup.finishLegalProcessCall
          .call(processId: _processId, authToken: currentAuthenticationToken),
      ok: 'Proceso finalizado. Avisamos al cliente y al propietario.',
      fail: 'No se pudo finalizar el proceso',
    );
    if (ok && mounted) context.safePop();
  }

  // ── Contacto ──────────────────────────────────────────────────────────────

  Future<void> _call(LegalHqParty p) async {
    try {
      if (await launchUrl(Uri(scheme: 'tel', path: p.dialablePhone))) return;
    } catch (_) {}
    _snack('No se pudo abrir el teléfono', error: true);
  }

  Future<void> _whatsapp(LegalHqParty p) async {
    final number = p.dialablePhone.replaceAll('+', '');
    try {
      if (await launchUrl(Uri.parse('https://wa.me/$number'),
          mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    _snack('No se pudo abrir WhatsApp', error: true);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final title = (widget.propertyName?.isNotEmpty ?? false)
        ? widget.propertyName!
        : (detail?.process.title ?? 'Proceso');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 110),
                  children: [
                    wrapWithModel(
                      model: _model.legalAssociateHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LegalAssociateHeaderWidget(titleText: title),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: _primary)),
                            )
                          : detail == null
                              ? _text('No se pudo cargar el trámite.',
                                  align: TextAlign.center)
                              : _buildBody(detail),
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

  Widget _buildBody(LegalHqProcessDetail d) {
    final Widget step = switch (d.process.status) {
      'DRAFTING' => _buildDrafting(d),
      'MEETING_COORDINATION' || 'MEETING_SCHEDULED' => _buildMeeting(d),
      'LEGAL_HQ_REVIEW' => _buildHqReview(d),
      'REJECTED' => _buildRejected(d),
      'APPROVED' || 'FINISHED' => _buildApproved(d),
      _ => _buildClauses(d),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepper(),
        const SizedBox(height: 16),
        _buildSummary(d),
        const SizedBox(height: 16),
        step,
      ],
    );
  }

  // Paso 1 — Pendiente de cláusulas.
  Widget _buildClauses(LegalHqProcessDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAgreement(d.agreement),
        const SizedBox(height: 20),
        _buildBanner('Documentación a revisar antes de comunicarte con los '
            'interesados'),
        const SizedBox(height: 16),
        _buildDocuments(d.documents, editable: true),
        const SizedBox(height: 16),
        _secondaryButton('Cargar documento', _uploadCustomDocument),
        const SizedBox(height: 20),
        _buildBanner('Comunicate con el cliente y el propietario para definir '
            'las cláusulas del acuerdo.'),
        const SizedBox(height: 16),
        _buildParties(d),
        const SizedBox(height: 20),
        _text(
          'Si ya se definieron las cláusulas del acuerdo, podés pasar a la '
          'parte de redacción',
          align: TextAlign.center,
        ),
        const SizedBox(height: 10),
        _primaryButton('Continuar', _advanceToDrafting),
      ],
    );
  }

  // Paso 2 — En redacción.
  Widget _buildDrafting(LegalHqProcessDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('Contrato'),
        _hasContract
            ? _uploadStrip(
                _contractName(d),
                bold: true,
                actions: [
                  _stripIcon(Icons.visibility_outlined, 'Ver contrato',
                      () => _openUrl(d.unsignedContractUrl)),
                  _stripIcon(
                      Icons.swap_horiz, 'Reemplazar contrato', _uploadContract),
                ],
              )
            : _uploadStrip('Subir contrato', actions: [
                _stripIcon(Icons.upload, 'Subir contrato', _uploadContract),
              ]),
        const SizedBox(height: 16),
        _sectionLabel('Documento'),
        _uploadStrip(
          'Descargue el documento para editarlo si es necesario',
          actions: [
            _stripIcon(Icons.download, 'Descargar documento', _downloadBase),
            _stripIcon(
                Icons.upload, 'Subir versión corregida', _uploadContract),
          ],
        ),
        const SizedBox(height: 32),
        if (!_hasContract) ...[
          _text('Subí el contrato final para poder continuar.',
              align: TextAlign.center, size: 13),
          const SizedBox(height: 10),
        ],
        _primaryButton('Continuar', _hasContract ? _advanceToMeeting : null),
      ],
    );
  }

  // Paso 3 — Reunión agendada.
  Widget _buildMeeting(LegalHqProcessDetail d) {
    final appointment = d.activeAppointment;
    final scheduled = d.process.status == 'MEETING_SCHEDULED';
    final signed = _signedContract;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (appointment == null)
          _card(
            Column(
              children: [
                _text(
                  'Agenda la reunión para realizar la firma de la '
                  'documentación e ingresa la dirección donde se van a '
                  'encontrar',
                  align: TextAlign.center,
                ),
                const SizedBox(height: 12),
                IconButton(
                  onPressed: _continuing ? null : _schedule,
                  iconSize: 64,
                  tooltip: 'Agendar reunión',
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFF3F9A9C)),
                ),
              ],
            ),
          )
        else
          _buildAppointment(appointment),
        const SizedBox(height: 16),
        _buildParties(d),
        const SizedBox(height: 16),
        _buildAgreement(d.agreement),
        const SizedBox(height: 8),
        _accordion(
          'Documentos',
          _documentsOpen,
          () => safeSetState(() => _documentsOpen = !_documentsOpen),
          [
            _buildBanner(scheduled
                ? 'Actualiza los documentos, el contrato firmado por los '
                    'clientes para realizar el envío al HQ legal'
                : 'Solo puedes visualizar el documento, no se puede editar'),
            const SizedBox(height: 12),
            _buildDocuments([
              _unsignedContractDocument(d),
              if (signed != null) signed,
            ], editable: false),
            if (scheduled) ...[
              const SizedBox(height: 12),
              _secondaryButton(
                  signed == null
                      ? 'Cargar documento'
                      : 'Reemplazar contrato firmado',
                  _uploadSignedContract),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _accordion(
          'Adicionales',
          _extrasOpen,
          () => safeSetState(() => _extrasOpen = !_extrasOpen),
          [
            _text('Notas de la reunión'),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: GoogleFonts.publicSans(color: _textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Escribe aquí...',
                filled: true,
                fillColor: const Color(0xFFF3F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (scheduled && signed == null) ...[
          _text('Cargá el contrato firmado para enviar el trámite a Legal HQ.',
              align: TextAlign.center, size: 13),
          const SizedBox(height: 10),
        ],
        _primaryButton(
            'Continuar', scheduled && signed != null ? _submitToHq : null),
      ],
    );
  }

  Widget _buildAppointment(LegalHqAppointment a) {
    final when = a.scheduledAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text('Fecha: ${when == null ? '—' : _longDate(when)}'),
              const SizedBox(height: 8),
              _text('Hora: ${when == null ? '—' : _timeRange(when)}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _outlineButton('Cancelar', const Color(0xFFE0201B),
                        _continuing ? null : _cancelMeeting),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _outlineButton(
                        'Re-agendar', _primary, _continuing ? null : _schedule),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _text('Dirección de donde se encontrarán',
            size: 12, color: const Color(0xFF6B7F80)),
        const SizedBox(height: 8),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Color(0xFFE0201B), size: 40),
              const SizedBox(height: 8),
              _text(a.address.isNotEmpty ? a.address : '—',
                  align: TextAlign.center, weight: FontWeight.w600),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: a.address.isEmpty
                ? null
                : () => _openUrl(
                      'https://www.google.com/maps/search/?api=1&query='
                      '${Uri.encodeComponent(a.address)}',
                      error: 'No se pudo abrir el mapa',
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6FAFAF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: _text('Ver ubicación', color: Colors.white, size: 13),
          ),
        ),
      ],
    );
  }

  // Paso 4 — En revisión Legal HQ (solo lectura).
  Widget _buildHqReview(LegalHqProcessDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBanner('Legal HQ está revisando los documentos. Cuando estén '
            'aprobados o rechazados te llegará una notificación.'),
        const SizedBox(height: 12),
        _accordion(
          'Documentos',
          _documentsOpen,
          () => safeSetState(() => _documentsOpen = !_documentsOpen),
          [
            _buildBanner(
                'Solo puedes visualizar el documento, no se puede editar'),
            const SizedBox(height: 12),
            _buildDocuments(_filedDocuments(d), editable: false),
          ],
        ),
        if (d.meetingNotes.isNotEmpty) ...[
          const SizedBox(height: 8),
          _meetingNotesAccordion(d),
        ],
      ],
    );
  }

  // Paso 4 — Rechazado por Legal HQ.
  Widget _buildRejected(LegalHqProcessDetail d) {
    final reasons = _rejectionReasons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDADA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text('Legal HQ rechazó los documentos por:',
                  color: const Color(0xFFE0201B), weight: FontWeight.w600),
              const SizedBox(height: 6),
              if (reasons.isEmpty)
                _text('Sin detalle del motivo.',
                    color: const Color(0xFFE0201B), size: 13)
              else
                for (final r in reasons)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child:
                        _text('• $r', color: const Color(0xFFE0201B), size: 13),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionLabel('Documentos'),
        _uploadStrip('Volver a cargar documento', actions: [
          _stripIcon(
              Icons.upload, 'Volver a cargar documento', _reuploadRejected),
        ]),
        const SizedBox(height: 16),
        _buildDocuments(_filedDocuments(d), editable: false, showStatus: true),
        const SizedBox(height: 24),
        _primaryButton('Reenviar a Legal HQ', _resubmitToHq),
      ],
    );
  }

  // Paso 4 — Aprobado / finalizado.
  Widget _buildApproved(LegalHqProcessDetail d) {
    final finished = d.process.status == 'FINISHED';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _accordion(
          'Documentos',
          _documentsOpen,
          () => safeSetState(() => _documentsOpen = !_documentsOpen),
          [
            // En APPROVED el backend no deja cargar documentos al asociado:
            // el único que falta, el comprobante de pago, lo sube el cliente.
            _buildBanner(finished
                ? 'El trámite está finalizado.'
                : d.hasPaymentProof
                    ? 'El cliente ya cargó el comprobante de pago. Revisá los '
                        'documentos y finalizá el proceso.'
                    : 'Legal HQ aprobó el trámite. Falta que el cliente cargue '
                        'el comprobante de pago a DOVIA para poder finalizarlo.'),
            const SizedBox(height: 12),
            _buildDocuments(_filedDocuments(d), editable: false),
          ],
        ),
        if (d.meetingNotes.isNotEmpty) ...[
          const SizedBox(height: 8),
          _meetingNotesAccordion(d),
        ],
        if (!finished) ...[
          const SizedBox(height: 32),
          _primaryButton('Finalizar proceso y notificar',
              d.hasPaymentProof ? _finish : null),
        ],
      ],
    );
  }

  /// Notas de la reunión ya enviadas a HQ, solo lectura.
  Widget _meetingNotesAccordion(LegalHqProcessDetail d) => _accordion(
        'Adicionales',
        _extrasOpen,
        () => safeSetState(() => _extrasOpen = !_extrasOpen),
        [_field('Notas de la reunión', d.meetingNotes)],
      );

  List<LegalHqDocument> _filedDocuments(LegalHqProcessDetail d) => [
        if (d.unsignedContractUrl.isNotEmpty) _unsignedContractDocument(d),
        for (final doc in d.documents)
          if (doc.hasFile) doc,
      ];

  /// El contrato sin firmar no es un documento del checklist sino un campo
  /// del proceso; se muestra como una tarjeta más.
  LegalHqDocument _unsignedContractDocument(LegalHqProcessDetail d) =>
      LegalHqDocument(
        id: 'unsigned-contract',
        label: 'Contrato',
        status: 'approved',
        url: d.unsignedContractUrl,
        originalName: _contractName(d),
      );

  String _contractName(LegalHqProcessDetail d) =>
      d.unsignedContractName.isNotEmpty
          ? d.unsignedContractName
          : _fileNameFromUrl(d.unsignedContractUrl);

  String _fileNameFromUrl(String url) {
    final segments = Uri.tryParse(url)?.pathSegments ?? const [];
    if (segments.isEmpty) return 'Contrato';
    return Uri.decodeComponent(segments.last);
  }

  // ── Piezas comunes ────────────────────────────────────────────────────────

  /// Paso activo del stepper (0 a 3) según el estado del trámite.
  int get _currentStep => switch (_status) {
        'DRAFTING' => 1,
        'MEETING_COORDINATION' || 'MEETING_SCHEDULED' => 2,
        'LEGAL_HQ_REVIEW' || 'REJECTED' || 'APPROVED' || 'FINISHED' => 3,
        _ => 0,
      };

  Widget _buildStepper() {
    const steps = [
      'Pendiente de cláusulas',
      'En redacción',
      'Reunión agendada',
      'En revisión Legal HQ',
    ];
    final current = _currentStep;
    final allDone = _status == 'APPROVED' || _status == 'FINISHED';
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _text('Proceso de Documentación', weight: FontWeight.w500),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < steps.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              i <= current ? _primary : const Color(0xFFE6E6E6),
                        ),
                        child: i < current || (allDone && i == current)
                            ? const Icon(Icons.check,
                                size: 18, color: Colors.white)
                            : _text('${i + 1}',
                                color: i == current
                                    ? Colors.white
                                    : const Color(0xFF9E9E9E),
                                size: 13),
                      ),
                      const SizedBox(height: 6),
                      _text(steps[i],
                          align: TextAlign.center,
                          size: 12,
                          weight: i == current
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: i <= current
                              ? _textDark
                              : const Color(0xFFABABAB)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color, Color) get _badge => switch (_status) {
        'DRAFTING' => ('En redacción', _primary, _pill),
        'MEETING_COORDINATION' || 'MEETING_SCHEDULED' => (
            'Reunión agendada',
            const Color(0xFF2F2A9E),
            const Color(0xFFD9D5F2)
          ),
        'LEGAL_HQ_REVIEW' => (
            'En revisión Legal HQ',
            const Color(0xFFF07E00),
            const Color(0xFFFFDDB8)
          ),
        'REJECTED' => (
            'Rechazado',
            const Color(0xFFE0201B),
            const Color(0xFFFFD6D6)
          ),
        'APPROVED' => (
            'Aprobado',
            const Color(0xFF1E8A2E),
            const Color(0xFFBDF5B8)
          ),
        'FINISHED' => (
            'Finalizado',
            const Color(0xFF1E8A2E),
            const Color(0xFFBDF5B8)
          ),
        _ => ('Pendiente', const Color(0xFFF5A700), const Color(0xFFFFF1BC)),
      };

  Widget _buildSummary(LegalHqProcessDetail d) {
    final category = d.process.category;
    final type = category == 'RENT'
        ? 'Arriendo'
        : category == 'SALE'
            ? 'Venta'
            : category;
    final (label, fg, bg) = _badge;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _text('Tipo: $type'),
          const SizedBox(height: 4),
          Row(
            children: [
              _text('Estatus', color: _primary),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _text(label, color: fg, size: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _text(
              'Dirección: ${d.process.address.isNotEmpty ? d.process.address : '—'}'),
        ],
      ),
    );
  }

  Widget _accordion(
    String title,
    bool open,
    VoidCallback onToggle,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _text(title, size: 15)),
                Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _textDark),
              ],
            ),
          ),
        ),
        if (open) ...[
          const SizedBox(height: 12),
          ...children,
        ],
      ],
    );
  }

  // Acordeón de solo lectura: condiciones congeladas de la oferta aceptada.
  Widget _buildAgreement(LegalHqAgreement a) {
    String v(String s) => s.isNotEmpty ? s : '—';
    return _accordion(
      'Acuerdo',
      _agreementOpen,
      () => safeSetState(() => _agreementOpen = !_agreementOpen),
      [
        _field('Método de pago', v(a.paymentMethodLabel)),
        _field('Propuesta económica', v(a.amountLabel)),
        _field('Enganche', v(a.downPaymentLabel)),
        _field('Tiempo', v(a.termLabel)),
        _field('Banco', v(a.bankName)),
      ],
    );
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _text(label),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _text(value, color: const Color(0xFF5E7274)),
            ),
          ],
        ),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _text(text, size: 13),
      );

  /// Franja gris con acciones a la derecha ("Subir contrato ↑").
  Widget _uploadStrip(
    String text, {
    required List<Widget> actions,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: _strip,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: _text(text,
                maxLines: 2,
                weight: bold ? FontWeight.w600 : FontWeight.normal),
          ),
          if (_uploading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: _primary),
              ),
            )
          else
            ...actions,
        ],
      ),
    );
  }

  Widget _stripIcon(IconData icon, String tooltip, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Tooltip(
              message: tooltip,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(icon, size: 18, color: _textDark),
              ),
            ),
          ),
        ),
      );

  Widget _buildDocuments(
    List<LegalHqDocument> docs, {
    required bool editable,
    bool? showStatus,
  }) {
    if (docs.isEmpty) {
      return _text('Todavía no hay documentos cargados.',
          align: TextAlign.center);
    }
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 700 ? 4 : 2;
      const gap = 10.0;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: 16,
        children: [
          for (final d in docs)
            SizedBox(
              width: w,
              child: _docCard(d,
                  editable: editable, showStatus: showStatus ?? editable),
            ),
        ],
      );
    });
  }

  Widget _docCard(
    LegalHqDocument d, {
    required bool editable,
    required bool showStatus,
  }) {
    final (Color bar, String label) = switch (d.status) {
      'approved' => (_primary, 'Correcto'),
      'rejected' => (Colors.red, editable ? 'Observado' : 'Rechazado'),
      'submitted' => (const Color(0xFFF5A700), 'Por revisar'),
      _ => (const Color(0xFFBDBDBD), 'Falta cargar'),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: d.hasFile ? () => _open(d) : null,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: d.hasFile ? _primary : const Color(0xFFE9E8E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: _busyDocId == d.id
                      ? _spinner()
                      : _text(d.hasFile ? (d.isPdf ? 'PDF' : 'Imagen') : '—',
                          color: d.hasFile ? Colors.white : _textDark),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: _docMenu(d, editable: editable),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        _text(d.label, size: 13, weight: FontWeight.w600, maxLines: 2),
        if (showStatus) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(height: 6, color: bar),
          ),
          const SizedBox(height: 2),
          _text(label, size: 11, color: bar),
        ],
      ],
    );
  }

  Widget _docMenu(LegalHqDocument d, {required bool editable}) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones',
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.more_vert, size: 18, color: Colors.white),
      ),
      onSelected: (v) {
        switch (v) {
          case 'ver':
          case 'descargar':
            _open(d);
          case 'aprobar':
            _review(d, true);
          case 'observar':
            _review(d, false);
          case 'eliminar':
            _delete(d);
        }
      },
      itemBuilder: (_) => [
        if (d.hasFile) ...[
          const PopupMenuItem(value: 'ver', child: Text('Ver')),
          const PopupMenuItem(value: 'descargar', child: Text('Descargar')),
          if (editable) ...[
            if (d.status != 'approved')
              const PopupMenuItem(
                  value: 'aprobar', child: Text('Marcar como correcto')),
            if (d.status != 'rejected')
              const PopupMenuItem(
                  value: 'observar', child: Text('Pedir corrección')),
            const PopupMenuItem(
                value: 'eliminar',
                child: Text('Eliminar', style: TextStyle(color: Colors.red))),
          ],
        ] else
          const PopupMenuItem(
              enabled: false, child: Text('Todavía no se cargó')),
      ],
    );
  }

  Widget _buildParties(LegalHqProcessDetail d) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildParty('Información de propietario', d.owner),
          const SizedBox(height: 12),
          _buildParty('Información de cliente', d.client),
        ],
      );

  Widget _buildParty(String title, LegalHqParty p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF8FC1C3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _pill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _text(title, size: 13, color: _primary),
          ),
          const SizedBox(height: 8),
          _text(p.nameLabel,
              weight: FontWeight.w700, size: 16, align: TextAlign.center),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _text('Sexo: ${p.genderLabel}', size: 13)),
            Expanded(
                child: _text('Nacionalidad: ${p.nationalityLabel}', size: 13)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: _text('Edad: ${p.ageLabel}', size: 13)),
            Expanded(child: _text('Teléfono: ${p.phoneLabel}', size: 13)),
          ]),
          if (p.phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _call(p),
                    icon: const Icon(Icons.call, size: 18, color: _primary),
                    label: _text('Llamar', color: _primary, size: 13),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _whatsapp(p),
                    icon: const Icon(Icons.chat, size: 18, color: _primary),
                    label: _text('WhatsApp', color: _primary, size: 13),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────

  Future<String?> _askText({
    required String title,
    required String hint,
    required String action,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(action)),
        ],
      ),
    );
  }

  static const _weekdays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  String _longDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${d.day} de ${_months[d.month - 1]} '
      'de ${d.year}';

  static String _clock(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'a.m.' : 'p.m.'}';
  }

  /// La reunión se muestra como un bloque de una hora.
  String _timeRange(DateTime d) =>
      '${_clock(d)} – ${_clock(d.add(const Duration(hours: 1)))}';

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 6),
          ],
        ),
        child: child,
      );

  Widget _buildBanner(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _banner,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _text(text, align: TextAlign.center),
      );

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: _primary,
        disabledBackgroundColor: const Color(0xFFBDBDBD),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      );

  /// Botón principal inferior; `null` lo deja grisado.
  Widget _primaryButton(String label, VoidCallback? onPressed) => SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: _continuing ? null : onPressed,
          style: _buttonStyle(),
          child: _continuing
              ? _spinner()
              : _text(label,
                  color: Colors.white, weight: FontWeight.w600, size: 16),
        ),
      );

  Widget _secondaryButton(String label, VoidCallback onPressed) => SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: _uploading ? null : onPressed,
          style: _buttonStyle(),
          child: _uploading
              ? _spinner()
              : _text(label, color: Colors.white, weight: FontWeight.w600),
        ),
      );

  Widget _outlineButton(String label, Color color, VoidCallback? onPressed) =>
      OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: _text(label, color: color, weight: FontWeight.w600),
      );

  Widget _spinner() => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );

  Widget _text(
    String text, {
    Color color = _textDark,
    double size = 14,
    FontWeight weight = FontWeight.normal,
    TextAlign? align,
    int? maxLines,
  }) =>
      Text(
        text,
        textAlign: align,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        style: GoogleFonts.publicSans(
            color: color, fontSize: size, fontWeight: weight),
      );
}

/// Modal "Agenda la reunion": dirección, fecha y hora. Devuelve la dirección
/// y la fecha-hora elegidas.
class _ScheduleMeetingDialog extends StatefulWidget {
  const _ScheduleMeetingDialog({this.initialAddress = ''});

  final String initialAddress;

  @override
  State<_ScheduleMeetingDialog> createState() => _ScheduleMeetingDialogState();
}

class _ScheduleMeetingDialogState extends State<_ScheduleMeetingDialog> {
  static const _primary = Color(0xFF007376);
  static const _textDark = Color(0xFF00444B);

  late final _address = TextEditingController(text: widget.initialAddress);
  DateTime? _date;
  TimeOfDay? _time;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _accept() {
    final address = _address.text.trim();
    final date = _date;
    final time = _time;
    if (address.isEmpty || date == null || time == null) {
      setState(() => _error = 'Completá la dirección, la fecha y la hora.');
      return;
    }
    final when =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (when.isBefore(DateTime.now())) {
      setState(() => _error = 'Elegí una fecha y hora futuras.');
      return;
    }
    Navigator.pop(context, (address, when));
  }

  Widget _selector(String label, String? value, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? label,
                  style: GoogleFonts.publicSans(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _textDark),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;
    final time = _time;
    final style = GoogleFonts.publicSans(color: _textDark, fontSize: 14);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Agenda la reunión',
                  style:
                      GoogleFonts.publicSans(color: _textDark, fontSize: 18)),
              const SizedBox(height: 14),
              Text('Ingresa la dirección', style: style),
              const SizedBox(height: 6),
              TextField(
                controller: _address,
                style: style,
                decoration: InputDecoration(
                  hintText: 'Ej: Oficina DOVIA Centro',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Ingresa la fecha y hora', style: style),
              const SizedBox(height: 8),
              _selector(
                'Selecciona la fecha',
                date == null
                    ? null
                    : '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/${date.year}',
                _pickDate,
              ),
              const SizedBox(height: 8),
              _selector(
                'Selecciona la hora',
                time?.format(context),
                _pickTime,
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: GoogleFonts.publicSans(
                        color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _accept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text('Aceptar',
                      style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pop-up para cancelar la reunión. El motivo es obligatorio.
class _CancelMeetingDialog extends StatefulWidget {
  const _CancelMeetingDialog();

  @override
  State<_CancelMeetingDialog> createState() => _CancelMeetingDialogState();
}

class _CancelMeetingDialogState extends State<_CancelMeetingDialog> {
  static const _primary = Color(0xFF007376);
  static const _textDark = Color(0xFF00444B);

  final _reason = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cuéntanos por qué tienes que cancelar la reunión',
              textAlign: TextAlign.center,
              style: GoogleFonts.publicSans(
                  color: _textDark, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reason,
              maxLines: 4,
              style: GoogleFonts.publicSans(color: _textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Escribe aquí...',
                errorText: _showError ? 'Contanos el motivo' : null,
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final text = _reason.text.trim();
                  if (text.isEmpty) {
                    setState(() => _showError = true);
                    return;
                  }
                  Navigator.pop(context, text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('Enviar reporte',
                    style: GoogleFonts.publicSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
