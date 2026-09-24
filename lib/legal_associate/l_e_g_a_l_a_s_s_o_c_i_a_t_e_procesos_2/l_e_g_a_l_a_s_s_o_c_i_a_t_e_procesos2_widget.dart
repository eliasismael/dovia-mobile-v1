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

/// Paso 1 del trámite legal ("Pendiente de cláusulas"): acuerdo congelado de
/// la negociación, revisión de documentos y contacto con las partes.
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

  LegalHqProcessDetail? _detail;
  bool _loading = true;
  bool _agreementOpen = true;
  bool _uploading = false;
  bool _continuing = false;
  String? _busyDocId;

  String get _processId => widget.processId ?? '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCIATEProcesos2Model());
    _load();
  }

  @override
  void dispose() {
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

  // ── Documentos ────────────────────────────────────────────────────────────

  Future<void> _open(LegalHqDocument doc) async {
    final uri = Uri.tryParse(doc.url);
    var ok = false;
    try {
      if (uri != null) {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    if (!ok) _snack('No se pudo abrir el documento', error: true);
  }

  Future<void> _review(LegalHqDocument doc, bool approve) async {
    String? note;
    if (!approve) {
      note = await _askNote();
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

  Future<String?> _askNote() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Qué hay que corregir?'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration:
              const InputDecoration(hintText: 'Ej: la foto está borrosa'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Enviar')),
        ],
      ),
    );
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

  /// Selector nativo del sistema: PDF o foto del documento faltante.
  Future<void> _upload() async {
    final files = await selectFiles(
      multiFile: false,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (files == null || files.isEmpty || !mounted) return;
    final file = files.first;
    safeSetState(() => _uploading = true);
    final res = await DOVIAAPILegalProcessContextGroup
        .createLegalProcessDocumentCall
        .call(
      processId: _processId,
      authToken: currentAuthenticationToken,
      file: FFUploadedFile(name: file.originalFilename, bytes: file.bytes),
    );
    if (!mounted) return;
    safeSetState(() => _uploading = false);
    if (!res.succeeded) {
      _snack(_backendMessage(res, 'No se pudo cargar el documento'),
          error: true);
      return;
    }
    _snack('Documento cargado');
    _load();
  }

  // ── Continuar ─────────────────────────────────────────────────────────────

  /// Pasa el trámite a "En redacción". El backend exige que todos los
  /// documentos requeridos o cargados estén marcados como correctos.
  Future<void> _continue() async {
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
    safeSetState(() => _continuing = true);
    if (detail.process.status == 'NOT_STARTED') {
      final start = await DOVIAAPILegalProcessContextGroup.startLegalProcessCall
          .call(processId: _processId, authToken: currentAuthenticationToken);
      if (!start.succeeded) {
        if (!mounted) return;
        safeSetState(() => _continuing = false);
        _snack(_backendMessage(start, 'No se pudo iniciar el proceso'),
            error: true);
        return;
      }
    }
    final res = await DOVIAAPILegalProcessContextGroup.advanceToDraftingCall
        .call(processId: _processId, authToken: currentAuthenticationToken);
    if (!mounted) return;
    safeSetState(() => _continuing = false);
    if (!res.succeeded) {
      _snack(_backendMessage(res, 'No se pudo pasar a redacción'), error: true);
      return;
    }
    _snack('El trámite pasó a "En redacción"');
    // TODO: abrir la pantalla de redacción cuando exista.
    context.safePop();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepper(),
        const SizedBox(height: 16),
        _buildSummary(d),
        const SizedBox(height: 16),
        _buildAgreement(d.agreement),
        const SizedBox(height: 20),
        _buildBanner('Documentación a revisar antes de comunicarte con los '
            'interesados'),
        const SizedBox(height: 16),
        _buildDocuments(d.documents),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: _uploading ? null : _upload,
            style: _buttonStyle(),
            child: _uploading
                ? _spinner()
                : _text('Cargar documento',
                    color: Colors.white, weight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        _buildBanner('Comunicate con el cliente y el propietario para definir '
            'las cláusulas del acuerdo.'),
        const SizedBox(height: 16),
        _buildParty('Información de propietario', d.owner),
        const SizedBox(height: 12),
        _buildParty('Información de cliente', d.client),
        const SizedBox(height: 20),
        _text(
          'Si ya se definieron las cláusulas del acuerdo, podés pasar a la '
          'parte de redacción',
          align: TextAlign.center,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: _continuing ? null : _continue,
            style: _buttonStyle(),
            child: _continuing
                ? _spinner()
                : _text('Continuar',
                    color: Colors.white, weight: FontWeight.w600, size: 16),
          ),
        ),
      ],
    );
  }

  // Stepper de 4 pasos: el 1 activo, el resto grisado.
  Widget _buildStepper() {
    const steps = [
      'Pendiente de cláusulas',
      'En redacción',
      'Reunión agendada',
      'En revisión Legal HQ',
    ];
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
                          color: i == 0 ? _primary : const Color(0xFFE6E6E6),
                        ),
                        child: _text('${i + 1}',
                            color:
                                i == 0 ? Colors.white : const Color(0xFF9E9E9E),
                            size: 13),
                      ),
                      const SizedBox(height: 6),
                      _text(steps[i],
                          align: TextAlign.center,
                          size: 12,
                          color: i == 0 ? _textDark : const Color(0xFFABABAB)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(LegalHqProcessDetail d) {
    final category = d.process.category;
    final type = category == 'RENT'
        ? 'Arriendo'
        : category == 'SALE'
            ? 'Venta'
            : category;
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
                  color: const Color(0xFFFFF1BC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _text('Pendiente',
                    color: const Color(0xFFF5A700), size: 13),
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

  // Acordeón de solo lectura: condiciones congeladas de la oferta aceptada.
  Widget _buildAgreement(LegalHqAgreement a) {
    String v(String s) => s.isNotEmpty ? s : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => safeSetState(() => _agreementOpen = !_agreementOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _text('Acuerdo', size: 15)),
                Icon(
                    _agreementOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: _textDark),
              ],
            ),
          ),
        ),
        if (_agreementOpen) ...[
          const SizedBox(height: 12),
          _field('Método de pago', v(a.paymentMethodLabel)),
          _field('Propuesta económica', v(a.amountLabel)),
          _field('Enganche', v(a.downPaymentLabel)),
          _field('Tiempo', v(a.termLabel)),
          _field('Banco', v(a.bankName)),
        ],
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

  Widget _buildDocuments(List<LegalHqDocument> docs) {
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
          for (final d in docs) SizedBox(width: w, child: _docCard(d)),
        ],
      );
    });
  }

  Widget _docCard(LegalHqDocument d) {
    final status = d.status;
    final (Color bar, String label) = switch (status) {
      'approved' => (_primary, 'Correcto'),
      'rejected' => (Colors.red, 'Observado'),
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
                  child: _docMenu(d),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        _text(d.label, size: 13, weight: FontWeight.w600, maxLines: 2),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(height: 6, color: bar),
        ),
        const SizedBox(height: 2),
        _text(label, size: 11, color: bar),
      ],
    );
  }

  Widget _docMenu(LegalHqDocument d) {
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
          if (d.status != 'approved')
            const PopupMenuItem(
                value: 'aprobar', child: Text('Marcar como correcto')),
          if (d.status != 'rejected')
            const PopupMenuItem(
                value: 'observar', child: Text('Pedir corrección')),
          const PopupMenuItem(
              value: 'eliminar',
              child: Text('Eliminar', style: TextStyle(color: Colors.red))),
        ] else
          const PopupMenuItem(
              enabled: false, child: Text('Todavía no se cargó')),
      ],
    );
  }

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
        disabledBackgroundColor: _primary.withValues(alpha: 0.6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
