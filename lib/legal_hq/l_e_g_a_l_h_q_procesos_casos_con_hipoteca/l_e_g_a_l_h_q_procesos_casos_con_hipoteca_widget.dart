import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/legal_hq/l_e_g_a_l_h_q_documento/l_e_g_a_l_h_q_documento_widget.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/legal_hq/legal_hq_process_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/listing_hq/listing_hq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l_e_g_a_l_h_q_procesos_casos_con_hipoteca_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_e_g_a_l_h_q_procesos_casos_con_hipoteca_model.dart';

class LEGALHQProcesosCasosConHipotecaWidget extends StatefulWidget {
  const LEGALHQProcesosCasosConHipotecaWidget({
    super.key,
    this.processId,
  });

  /// Expediente hipotecario cuya gestión bancaria se va a trabajar.
  final String? processId;

  static String routeName = 'LEGAL_HQ_Procesos_CasosConHipoteca';
  static String routePath = '/lEGALHQProcesosCasosConHipoteca';

  @override
  State<LEGALHQProcesosCasosConHipotecaWidget> createState() =>
      _LEGALHQProcesosCasosConHipotecaWidgetState();
}

class _LEGALHQProcesosCasosConHipotecaWidgetState
    extends State<LEGALHQProcesosCasosConHipotecaWidget> {
  late LEGALHQProcesosCasosConHipotecaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<LegalHqProcessDetail?> _detailFuture;

  /// El acordeón "Acuerdo" arranca cerrado, como en el diseño.
  bool _acuerdoExpanded = false;

  bool _uploadingAgreement = false;
  bool _advancingStage = false;

  /// Origen ya volcado al formulario del gestor, para no precargarlo de nuevo.
  String? _bankAgentPrefillKey;

  /// Resolución elegida en el desplegable del seguimiento.
  LegalHqEvaluationOutcome? _evaluationOutcome;

  /// El cierre por venta exige haber abierto el comprobante de honorarios al
  /// menos una vez: es el punto de la auditoría.
  bool _paymentProofOpened = false;

  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _beige = Color(0xFFEBEAE3);
  static const Color _alertBg = Color(0x3370ACAD);
  static const Color _grayStep = Color(0xFFE5E7EB);
  static const Color _grayStepText = Color(0xFF99A1AF);
  static const Color _darkText = Color(0xFF1E2939);
  static const Color _inputBg = Color(0xFFFAFAFA);
  static const Color _inputPlaceholder = Color(0x80888888);
  static const Color _dividerColor = Color(0xFFE9EFF2);
  static const Color _rejectionBg = Color(0xFFFFDBDB);
  static const Color _rejectionText = Color(0xFFFB2C36);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALHQProcesosCasosConHipotecaModel());
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
                        // El título de la cabecera es el nombre del inmueble.
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
    final status = detail.process.status;
    final step = legalHqMortgageStep(status);
    final isResolved =
        status == 'REJECTED' || status == 'APPROVED' || status == 'FINISHED';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepper(status),
        const SizedBox(height: 25.0),
        // Desde la etapa 2 la tarjeta suma el resumen de la operación; una vez
        // resuelto el trámite el diseño ya no lista la sucursal.
        _buildInfoCard(
          context,
          detail,
          showOperationSummary: step >= 2,
          showBranch: !isResolved,
          footer: status == 'REJECTED' || !isResolved
              ? const []
              : _buildFeeAudit(detail),
        ),
        const SizedBox(height: 25.0),
        if (status == 'REJECTED')
          ..._buildRejectedStage(detail)
        else if (isResolved)
          ..._buildApprovedStage(detail)
        else if (step >= 3)
          ..._buildEvaluationStage(detail)
        else if (step == 2)
          ..._buildDocumentationStage(detail)
        else
          ..._buildBankManagementStage(detail),
      ],
    );
  }

  /// Etapa 1: auditar comprobantes, generar el convenio y avisar al banco.
  List<Widget> _buildBankManagementStage(LegalHqProcessDetail detail) {
    final process = detail.process;
    final blocker = _bankManagementBlocker(detail);

    return [
      _buildAgreementAccordion(detail.agreement),
      const SizedBox(height: 25.0),
      _buildAlert('Documentacion a revisar y genera el convenio con Dovia'),
      const SizedBox(height: 16.0),
      _buildDocumentsGrid(detail),
      const SizedBox(height: 20.0),
      _buildAquaButton(
        'Cargar Convenio',
        busy: _uploadingAgreement,
        onPressed: () => _uploadAgreement(detail),
      ),
      const SizedBox(height: 25.0),
      _buildAlert(
        'Comunícate con el cliente y el propietario en caso de que no se '
        'firme el convenio',
      ),
      const SizedBox(height: 16.0),
      _buildPartiesRow(detail),
      const SizedBox(height: 25.0),
      _buildAlert(
        'Contacta al banco para iniciar el proceso de financiación.',
        fontSize: 14.0,
      ),
      if (blocker != null)
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            blocker,
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 12.0,
              height: 16 / 12,
            ),
          ),
        ),
      const SizedBox(height: 20.0),
      _buildAquaButton(
        'Continuar',
        busy: _advancingStage,
        // La transición solo existe mientras la gestión bancaria sigue
        // abierta; después el expediente ya avanzó de etapa.
        onPressed:
            process.status == 'BANK_MANAGEMENT_STARTED' && blocker == null
                ? () => _continue(detail)
                : null,
      ),
    ];
  }

  /// Qué impide avanzar la etapa 1, o `null` si el expediente ya puede pasar
  /// a documentación.
  ///
  /// El backend exige confirmar los seis documentos obligatorios antes de
  /// aceptar cualquier cambio de estado, y uno de ellos —el convenio firmado—
  /// no depende del HQ sino del comprador.
  String? _bankManagementBlocker(LegalHqProcessDetail detail) {
    if (detail.documentsComplete) return null;
    if (!detail.hasDoviaAgreement) {
      return 'Cargá el convenio de DOVIA para completar el expediente.';
    }
    if (!detail.hasSignedDoviaAgreement) {
      return 'Falta que el comprador devuelva el convenio firmado desde su '
          'oferta. Hasta entonces el expediente no puede avanzar.';
    }
    final missing = detail.missingRequiredDocuments;
    if (missing.isNotEmpty) {
      return 'Faltan documentos obligatorios: ${missing.join(', ')}.';
    }
    return null;
  }

  /// Etapa 2: registrar al gestor bancario y confirmar la entrega de papeles.
  List<Widget> _buildDocumentationStage(LegalHqProcessDetail detail) {
    _ensureBankAgentControllers(detail);
    final missing = _bankAgentDraft(detail).missingFieldLabels;

    return [
      _buildBankAgentForm(),
      // El botón deshabilitado no explica nada por sí solo: sin esta línea el
      // Legal HQ no sabe qué le falta para avanzar.
      if (missing.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            'Completá los datos del gestor bancario para avanzar: '
            '${missing.join(', ')}.',
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 12.0,
              height: 16 / 12,
            ),
          ),
        ),
      const SizedBox(height: 25.0),
      _buildPartiesRow(detail),
      const SizedBox(height: 25.0),
      _buildSubmissionBanner(detail),
      const SizedBox(height: 20.0),
      _buildAquaButton(
        'Actualizar estado',
        busy: _advancingStage,
        onPressed: missing.isEmpty ? () => _updateStage(detail) : null,
      ),
    ];
  }

  /// Etapa 3: seguimiento de la evaluación bancaria. El gestor y los contactos
  /// quedan de solo lectura para consulta rápida.
  List<Widget> _buildEvaluationStage(LegalHqProcessDetail detail) {
    _ensureBankAgentControllers(detail);
    _model.noteController ??= TextEditingController();
    _model.noteFocusNode ??= FocusNode();

    final bank = detail.agreement.bankName;
    final updatedAt = legalHqShortDate(detail.process.lastActivityAt);

    return [
      _buildBankAgentForm(readOnly: true),
      const SizedBox(height: 25.0),
      _buildPartiesRow(detail),
      const SizedBox(height: 25.0),
      _buildAlert(
        'El banco ${bank.isNotEmpty ? bank : 'asignado'} está evaluando la '
        'solicitud de hipoteca. Fecha de ultima actualizacion: '
        '${updatedAt.isNotEmpty ? updatedAt : 'sin registrar'}',
        fontSize: 12.0,
      ),
      const SizedBox(height: 25.0),
      Text(
        'Cuando el banco de una respuesta se actualizará el estado.',
        style: GoogleFonts.publicSans(
          color: _textDark,
          fontSize: 14.0,
          height: 16 / 14,
        ),
      ),
      const SizedBox(height: 12.0),
      _buildOutcomeDropdown(),
      // La opción de mantenimiento no se explica sola: conviene decir, antes
      // de escribir, que el trámite se queda donde está y que lo único que
      // llega al cliente es la nota.
      if (_evaluationOutcome == LegalHqEvaluationOutcome.stillEvaluating)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'El expediente se queda en evaluación bancaria: lo que viaja al '
            'cliente es la nota, con la fecha de esta actualización.',
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 12.0,
              height: 16 / 12,
            ),
          ),
        ),
      const SizedBox(height: 12.0),
      _buildNoteField(),
      const SizedBox(height: 20.0),
      _buildAquaButton(
        'Actualizar estado',
        busy: _advancingStage,
        onPressed: () => _updateEvaluation(detail),
      ),
    ];
  }

  /// Cierre negativo: el banco rechazó el crédito y hay que liberar el
  /// inmueble.
  List<Widget> _buildRejectedStage(LegalHqProcessDetail detail) {
    return [
      _buildRejectionAlert(detail.process.rejectionReasons),
      const SizedBox(height: 20.0),
      _buildAquaButton(
        'Finalizar proceso',
        busy: _advancingStage,
        onPressed: _finishRejectedProcess,
      ),
    ];
  }

  /// Cierra la vista del expediente rechazado.
  ///
  /// No hay nada que llamar: la transición a `REJECTED` ya cerró el proceso,
  /// rechazó la oferta y dejó la propiedad publicada. El botón solo confirma
  /// que el HQ tomó nota y vuelve al listado.
  void _finishRejectedProcess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceso cerrado. El inmueble sigue publicado'),
      ),
    );
    context.safePop();
  }

  /// Cierre positivo: auditar el cobro de honorarios y dar la venta por
  /// terminada.
  List<Widget> _buildApprovedStage(LegalHqProcessDetail detail) {
    final canFinish = detail.hasPaymentProof && _paymentProofOpened;

    return [
      if (!canFinish)
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            detail.hasPaymentProof
                // La regla de negocio es invisible si no se explica: sin este
                // aviso el botón deshabilitado no tiene explicación.
                ? 'Abrí el comprobante de pago para poder finalizar el proceso.'
                : 'El propietario todavía no subió el comprobante de pago de '
                    'los honorarios.',
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 12.0,
              height: 16 / 12,
            ),
          ),
        ),
      _buildAquaButton(
        'Finalizar proceso',
        busy: _advancingStage,
        onPressed: canFinish ? () => _finishApprovedProcess(detail) : null,
      ),
    ];
  }

  /// Bloque de auditoría del cobro de DOVIA, anidado en la tarjeta de
  /// metadatos como en el diseño.
  List<Widget> _buildFeeAudit(LegalHqProcessDetail detail) {
    return [
      const SizedBox(height: 16.0),
      _buildAlert(
        'Verifica que el Propietario del inmueble haya pagado los honorarios '
        'de Dovia',
        fontSize: 12.0,
      ),
      const SizedBox(height: 16.0),
      _buildPaymentProofRow(detail),
    ];
  }

  Widget _buildPaymentProofRow(LegalHqProcessDetail detail) {
    final available = detail.hasPaymentProof;

    return Container(
      padding: const EdgeInsets.all(10.7),
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(10.7),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Comprobante de pago',
              style: GoogleFonts.publicSans(
                color: _textDark,
                fontSize: 16.0,
                letterSpacing: 0.32,
              ),
            ),
          ),
          const SizedBox(width: 19.0),
          InkWell(
            onTap: () => _openPaymentProof(detail),
            borderRadius: BorderRadius.circular(99.43),
            child: Container(
              width: 46.0,
              height: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: available ? Colors.white : _grayStep,
                border: available ? Border.all(color: _aqua) : null,
                borderRadius: BorderRadius.circular(99.43),
              ),
              child: Icon(
                Icons.download,
                size: 24.0,
                color: available ? _aqua : _grayStepText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Banner rojo con los motivos que dejó el Legal HQ al marcar el rechazo.
  Widget _buildRejectionAlert(List<String> reasons) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 106.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _rejectionBg,
        borderRadius: BorderRadius.circular(16.0),
      ),
      // Centrado y con aire entre el título y los motivos, como los demás
      // avisos de la pantalla: apilados al ras se leían como un solo párrafo.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _rejectionLine('El banco rechazó la hipoteca por:'),
          const SizedBox(height: 8.0),
          if (reasons.isEmpty)
            _rejectionLine('No se registraron motivos.')
          else
            // Por índice, no por valor: dos motivos idénticos son dos líneas.
            for (var i = 0; i < reasons.length; i++) ...[
              if (i > 0) const SizedBox(height: 4.0),
              _rejectionLine(reasons[i]),
            ],
        ],
      ),
    );
  }

  Widget _rejectionLine(String text) => Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.publicSans(
          color: _rejectionText,
          fontSize: 12.0,
          height: 16 / 12,
        ),
      );

  // ── Seguimiento de la evaluación ──────────────────────────────────────────

  Widget _buildOutcomeDropdown() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 2.0, 12.0, 2.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: const Border(
          bottom: BorderSide(color: _dividerColor, width: 1.0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LegalHqEvaluationOutcome>(
          value: _evaluationOutcome,
          isExpanded: true,
          hint: Text(
            'Selecciona el estado actual',
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 16.0,
              height: 24 / 16,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 24.0, color: _textDark),
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 16.0,
            height: 24 / 16,
          ),
          items: [
            for (final outcome in LegalHqEvaluationOutcome.values)
              DropdownMenuItem(
                value: outcome,
                child: Text(outcome.label),
              ),
          ],
          onChanged: (outcome) =>
              safeSetState(() => _evaluationOutcome = outcome),
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nota:',
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 16.0,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          height: 104.0,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextFormField(
            controller: _model.noteController,
            focusNode: _model.noteFocusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 14.0,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Escribe aqui...',
              hintStyle: GoogleFonts.publicSans(
                color: _inputPlaceholder,
                fontSize: 16.0,
                letterSpacing: 0.32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Formulario del gestor bancario ────────────────────────────────────────

  void _ensureBankAgentControllers(LegalHqProcessDetail detail) {
    _model.bankController ??= TextEditingController();
    _model.bankFocusNode ??= FocusNode();
    _model.phoneController ??= TextEditingController();
    _model.phoneFocusNode ??= FocusNode();
    _model.agentNameController ??= TextEditingController();
    _model.agentNameFocusNode ??= FocusNode();
    _model.emailController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    final source = _bankAgentSource(detail);
    // La precarga se aplica una sola vez por origen: si se repitiera en cada
    // build pisaría lo que el Legal HQ está tipeando.
    final key = '${detail.process.id}|${jsonEncode(source.toJson())}';
    if (_bankAgentPrefillKey == key) return;
    _bankAgentPrefillKey = key;

    // El volcado espera al final del frame: escribir en un controlador que ya
    // tiene un TextField escuchando lo haría reconstruirse en pleno build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final changed = [
        _syncField(_model.bankController!, source.bank),
        _syncField(_model.phoneController!, source.phone),
        _syncField(_model.agentNameController!, source.fullName),
        _syncField(_model.emailController!, source.email),
      ].any((wrote) => wrote);
      // Los controladores no avisan a la pantalla, y de ellos dependen el
      // botón y el detalle de lo que falta.
      if (changed) safeSetState(() {});
    });
  }

  /// Escribe el campo solo si cambió, y avisa si lo hizo.
  static bool _syncField(TextEditingController controller, String value) {
    if (controller.text == value) return false;
    controller.text = value;
    return true;
  }

  /// Con qué se precarga el formulario: manda el snapshot del backend y, si el
  /// expediente no lo trae, entra lo último que se registró en este
  /// dispositivo.
  LegalHqBankAgent _bankAgentSource(LegalHqProcessDetail detail) =>
      detail.bankAgent.isEmpty
          ? LegalHqBankAgent.fromJson(
              FFAppState().mortgageBankAgent(detail.process.id))
          : detail.bankAgent;

  /// Lo que hay ahora escrito en el formulario. La sucursal no es un campo del
  /// diseño, así que se arrastra la del snapshot para no perderla al guardar.
  LegalHqBankAgent _bankAgentDraft(LegalHqProcessDetail detail) =>
      LegalHqBankAgent(
        bank: _model.bankController?.text.trim() ?? '',
        bankAddress: _bankAgentSource(detail).bankAddress,
        fullName: _model.agentNameController?.text.trim() ?? '',
        phone: _model.phoneController?.text.trim() ?? '',
        email: _model.emailController?.text.trim() ?? '',
      );

  Widget _buildBankAgentForm({bool readOnly = false}) {
    // Cada tecla revalida: es lo que enciende el botón apenas se completan los
    // cuatro campos, sin tener que salir del formulario.
    final onChanged = readOnly ? null : (String _) => safeSetState(() {});

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: ListingHqUi.cardDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Datos del gestor bancario',
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 16.0,
              letterSpacing: 0.32,
            ),
          ),
          const SizedBox(height: 8.0),
          // El diseño (desktop) va en dos columnas; en el celular se apilan.
          _responsivePair(
            _buildTextField(
              label: 'Banco',
              controller: _model.bankController!,
              focusNode: _model.bankFocusNode!,
              keyboardType: TextInputType.text,
              readOnly: readOnly,
              onChanged: onChanged,
            ),
            _buildTextField(
              label: 'Numero de telefono',
              controller: _model.phoneController!,
              focusNode: _model.phoneFocusNode!,
              keyboardType: TextInputType.phone,
              readOnly: readOnly,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 10.0),
          _responsivePair(
            _buildTextField(
              label: 'Nombre y Apellido',
              controller: _model.agentNameController!,
              focusNode: _model.agentNameFocusNode!,
              keyboardType: TextInputType.name,
              readOnly: readOnly,
              onChanged: onChanged,
            ),
            _buildTextField(
              label: 'Email',
              controller: _model.emailController!,
              focusNode: _model.emailFocusNode!,
              keyboardType: TextInputType.emailAddress,
              readOnly: readOnly,
              textInputAction: TextInputAction.done,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType keyboardType,
    bool readOnly = false,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 14.0,
            letterSpacing: 0.28,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6.0),
        Container(
          height: 36.0,
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onChanged: onChanged,
            textInputAction: textInputAction,
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 14.0,
              letterSpacing: 0.28,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  /// Registro histórico de la entrega: fecha y banco, de solo lectura. La
  /// fecha sale del historial de estados, no del `updatedAt` del expediente,
  /// que se mueve con cualquier cambio posterior.
  Widget _buildSubmissionBanner(LegalHqProcessDetail detail) {
    final date = legalHqShortDate(
      detail.process.statusReachedAt('BANK_DOCUMENTATION_SUBMITTED'),
    );
    final bank = detail.agreement.bankName;

    return _buildAlert(
      'Fecha de envío de documentos: ${date.isNotEmpty ? date : 'Sin registrar'}\n'
      'Banco: ${bank.isNotEmpty ? bank : 'Sin datos'}',
      fontSize: 12.0,
    );
  }

  // ── Rastreador de progreso ────────────────────────────────────────────────

  Widget _buildStepper(String status) {
    final step = legalHqMortgageStep(status);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: ListingHqUi.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proceso de Documentación',
            style: GoogleFonts.publicSans(
              color: _darkText,
              fontSize: 14.0,
              height: 24 / 14,
              letterSpacing: -0.3125,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < kMortgageStepLabels.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < step ? _aqua : _grayStep,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.publicSans(
                            color: i < step ? Colors.white : _grayStepText,
                            fontSize: 14.0,
                            letterSpacing: -0.1504,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        kMortgageStepLabels[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.publicSans(
                          color: i < step ? _textDark : _grayStepText,
                          fontSize: 12.0,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Metadatos base del expediente ─────────────────────────────────────────

  Widget _buildInfoCard(
    BuildContext context,
    LegalHqProcessDetail detail, {
    bool showOperationSummary = false,
    bool showBranch = true,
    List<Widget> footer = const [],
  }) {
    final process = detail.process;
    final statusStyle = legalHqStatusStyle(process.status);
    final agreement = detail.agreement;

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: ListingHqUi.cardDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            legalHqOperationLabel(process.category),
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
          _metaLine('Cliente', detail.client.nameLabel),
          _metaLine('Propietario', detail.owner.nameLabel),
          if (showOperationSummary) ...[
            _metaLine('Monto de la oferta', agreement.amountLabel),
            _metaLine('Banco', agreement.bankName),
            if (showBranch)
              _metaLine('Sucursal/Dirección', detail.bankAgent.bankAddress),
          ],
          // El cierre aprobado cuelga la auditoría del cobro de la misma
          // tarjeta, como en el diseño.
          ...footer,
        ],
      ),
    );
  }

  Widget _metaLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Text(
        '$label: ${value.isNotEmpty ? value : 'Sin datos'}',
        style: GoogleFonts.publicSans(
          color: _textDark,
          fontSize: 14.0,
        ),
      ),
    );
  }

  // ── Acordeón "Acuerdo" ────────────────────────────────────────────────────

  Widget _buildAgreementAccordion(LegalHqAgreement agreement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => safeSetState(() => _acuerdoExpanded = !_acuerdoExpanded),
          child: Container(
            padding:
                const EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 12.0, 10.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              border: const Border(
                bottom: BorderSide(color: _dividerColor, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Acuerdo',
                    style: GoogleFonts.publicSans(
                      color: _textDark,
                      fontSize: 16.0,
                      height: 24 / 16,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _acuerdoExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      size: 24.0, color: _textDark),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _acuerdoExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _agreementField(
                    'Método de pago', agreement.paymentMethodLabel, 'xxx'),
                const SizedBox(height: 12.0),
                _agreementField(
                    'Propuesta económica', agreement.amountLabel, 'xxx'),
                const SizedBox(height: 12.0),
                _agreementField('Enganche', agreement.downPaymentLabel, '%'),
                const SizedBox(height: 12.0),
                _agreementField('Tiempo', agreement.termLabel, 'XM'),
                const SizedBox(height: 12.0),
                _agreementField('Banco', agreement.bankName, 'xx'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Campo de solo lectura del acuerdo. Sin dato cae al placeholder del
  /// diseño, para que se note que la negociación no trajo ese valor.
  Widget _agreementField(String label, String value, String placeholder) {
    final hasValue = value.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(
            color: _textDark,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          height: 42.0,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            hasValue ? value : placeholder,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              color: hasValue ? _textDark : _inputPlaceholder,
              fontSize: 16.0,
              letterSpacing: 0.32,
            ),
          ),
        ),
      ],
    );
  }

  // ── Grilla documental ─────────────────────────────────────────────────────

  Widget _buildDocumentsGrid(LegalHqProcessDetail detail) {
    final process = detail.process;
    final agreementState = detail.doviaAgreementState;

    final cards = <Widget>[
      for (final document in detail.mortgageEvidenceDocuments())
        _buildDocumentCard(
          process: process,
          document: document,
          label: document.label,
          filledSegments: legalHqMortgageDocumentSegments(document),
        ),
      // El convenio siempre ocupa una tarjeta, exista o no el slot todavía, y
      // su texto y su barra siguen el ciclo carga → firma en vez del nombre
      // que le haya puesto el backend al archivo.
      _buildDocumentCard(
        process: process,
        document: detail.doviaAgreementCardDocument,
        label: agreementState.label,
        filledSegments: agreementState.filledSegments,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 16.0,
        // Alto suficiente para la caja, el nombre a dos líneas y la barra.
        mainAxisExtent: 200.0,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildDocumentCard({
    required LegalHqProcess process,
    required LegalHqDocument? document,
    required String label,
    int? filledSegments,
  }) {
    final hasFile = document?.hasFile ?? false;
    final progress = filledSegments ??
        (document == null
            ? 1
            : legalHqDocumentProgress(document).filledSegments);

    return GestureDetector(
      onTap: () => _openDocument(process, document),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Caja aqua cuando el archivo ya está; beige mientras falta.
          Container(
            height: 121.0,
            decoration: BoxDecoration(
              color: hasFile ? _aqua : _beige,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      hasFile
                          ? Icons.file_download_outlined
                          : Icons.hourglass_empty,
                      color: hasFile ? Colors.white : _textDark,
                      size: 22.0,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    hasFile ? (document!.isPdf ? 'PDF' : 'IMG') : 'Sin archivo',
                    style: GoogleFonts.publicSans(
                      color: hasFile ? Colors.white : _textDark,
                      fontSize: 16.0,
                      letterSpacing: 0.32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            label,
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
          _buildSegmentedProgress(progress),
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

  // ── Contacto de las partes ────────────────────────────────────────────────

  Widget _buildPartiesRow(LegalHqProcessDetail detail) {
    return _responsivePair(
      _buildPartyCard('Información de propietario', detail.owner),
      _buildPartyCard('Información de cliente', detail.client),
      spacing: 12.0,
      stretch: true,
    );
  }

  /// Dos widgets lado a lado en pantallas anchas (el diseño es desktop) y
  /// uno debajo del otro en el celular, donde a media pantalla no entran.
  Widget _responsivePair(
    Widget first,
    Widget second, {
    double spacing = 10.0,
    bool stretch = false,
  }) {
    if (MediaQuery.sizeOf(context).width < 600.0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, SizedBox(height: spacing), second],
      );
    }
    final row = Row(
      crossAxisAlignment:
          stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: spacing),
        Expanded(child: second),
      ],
    );
    return stretch ? IntrinsicHeight(child: row) : row;
  }

  Widget _buildPartyCard(String roleLabel, LegalHqParty party) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(5.48),
        border: Border.all(color: _aqua, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3.24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _alertBg,
              borderRadius: BorderRadius.circular(64.87),
            ),
            child: Text(
              roleLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.publicSans(
                color: _textDark.withValues(alpha: 0.8),
                fontSize: 11.0,
                height: 1.6,
                letterSpacing: 0.0697,
              ),
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            party.nameLabel,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              height: 1.6,
              letterSpacing: 0.0697,
            ),
          ),
          const SizedBox(height: 2.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _partyField(party.genderLabel)),
              Expanded(child: _partyField(party.nationalityLabel)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _partyField(party.ageLabel)),
              Expanded(child: _buildPhoneField(party)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _partyField(String value) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.publicSans(
        color: _textDark,
        fontSize: 11.0,
        height: 1.6,
        letterSpacing: 0.0697,
      ),
    );
  }

  /// El teléfono llama con un toque; donde no hay app de llamadas queda la
  /// copia al portapapeles.
  Widget _buildPhoneField(LegalHqParty party) {
    if (party.dialablePhone.isEmpty) return _partyField(party.phoneLabel);

    return InkWell(
      onTap: () => _contactParty(party),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone, size: 11.0, color: _aqua),
          const SizedBox(width: 3.0),
          Flexible(
            child: Text(
              party.phoneLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.publicSans(
                color: _aqua,
                fontSize: 11.0,
                height: 1.6,
                letterSpacing: 0.0697,
                decoration: TextDecoration.underline,
                decorationColor: _aqua,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bloques compartidos ───────────────────────────────────────────────────

  Widget _buildAlert(String text, {double fontSize = 13.0}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _alertBg,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.publicSans(
          color: _textDark,
          fontSize: fontSize,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildAquaButton(
    String label, {
    required VoidCallback? onPressed,
    bool busy = false,
  }) {
    return SizedBox(
      height: 42.0,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _aqua,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _aqua.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        ),
        child: busy
            ? const DoviaSpinner(small: true, color: Colors.white)
            : Text(
                label,
                style: GoogleFonts.publicSans(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  height: 14 / 16,
                ),
              ),
      ),
    );
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  Future<void> _openDocument(
    LegalHqProcess process,
    LegalHqDocument? document,
  ) async {
    if (document == null || !document.hasFile) {
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
        // Sin decisión de HQ: `documents/{id}/hq-review` solo se acepta con el
        // proceso en LEGAL_HQ_REVIEW o REJECTED, y un expediente hipotecario
        // nunca pasa por ahí —nace en BANK_MANAGEMENT_STARTED y se resuelve por
        // el ciclo bancario—. Acá el documento se audita, no se aprueba.
        'readOnly': serializeParam(true, ParamType.bool),
      }.withoutNulls,
    );

    // Al volver del visor la decisión pudo cambiar el checklist.
    if (mounted) safeSetState(_loadData);
  }

  /// Adjunta el convenio de DOVIA sin firmar.
  ///
  /// Escribe el slot de sistema `DOVIA_AGREEMENT_UNSIGNED`. Después el
  /// comprador tiene que devolverlo firmado desde su oferta para que el
  /// expediente pueda avanzar.
  Future<void> _uploadAgreement(LegalHqProcessDetail detail) async {
    if (detail.documentsComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El expediente ya fue confirmado: los documentos '
              'obligatorios quedaron congelados'),
        ),
      );
      return;
    }

    final selectedFiles = await selectFiles(
      multiFile: false,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (selectedFiles == null || selectedFiles.isEmpty || !mounted) return;

    final file = selectedFiles.first;
    safeSetState(() => _uploadingAgreement = true);

    final response = await LegalHqProcessApi.uploadDoviaAgreement(
      processId: detail.process.id,
      file: FFUploadedFile(
        name: file.originalFilename,
        bytes: file.bytes,
      ),
    );

    if (!mounted) return;
    safeSetState(() => _uploadingAgreement = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.succeeded
            ? 'Convenio cargado correctamente'
            : 'No se pudo cargar el convenio. Intentá de nuevo'),
      ),
    );

    if (!response.succeeded) return;
    safeSetState(_loadData);
  }

  /// Avanza la etapa 1: confirma el expediente y lo pasa a documentación.
  ///
  /// Son dos llamadas porque el backend las separa: `documents/complete` es
  /// irreversible y es precondición de cualquier cambio de estado.
  Future<void> _continue(LegalHqProcessDetail detail) async {
    final blocker = _bankManagementBlocker(detail);
    if (blocker != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(blocker)));
      return;
    }

    safeSetState(() => _advancingStage = true);

    // La confirmación documental es irreversible, así que solo se envía si el
    // expediente todavía no la tiene.
    if (!detail.documentsComplete) {
      final completed = await LegalHqProcessApi.completeMortgageDocuments(
        detail.process.id,
      );
      if (!mounted) return;
      if (!completed.succeeded) {
        safeSetState(() => _advancingStage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo confirmar la documentación obligatoria '
                'del expediente'),
          ),
        );
        return;
      }
    }

    final response = await LegalHqProcessApi.updateMortgageStatus(
      processId: detail.process.id,
      status: 'BANK_DOCUMENTATION_SUBMITTED',
      note: 'Documentación entregada al banco',
    );

    if (!mounted) return;
    safeSetState(() => _advancingStage = false);

    if (!response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se confirmó la documentación, pero no se pudo '
              'actualizar el estado del expediente'),
        ),
      );
      safeSetState(_loadData);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documentación enviada al banco')),
    );
    safeSetState(_loadData);
  }

  /// Registra al gestor bancario y pasa el expediente a evaluación.
  ///
  /// El contacto viaja por dos caminos porque ninguno alcanza solo: la nota de
  /// `mortgage/status` lo deja en `stateHistory` —el único registro del lado
  /// del servidor que hoy lo admite, ver [legalHqBankAgentNote]— y el mapa de
  /// [FFAppState] lo devuelve al formulario al reentrar, que si no aparecería
  /// vacío mientras `bankAgentData` siga siendo un snapshot de solo lectura.
  Future<void> _updateStage(LegalHqProcessDetail detail) async {
    final agent = _bankAgentDraft(detail);
    if (!agent.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Faltan datos del gestor bancario: '
              '${agent.missingFieldLabels.join(', ')}'),
        ),
      );
      return;
    }

    safeSetState(() => _advancingStage = true);

    final response = await LegalHqProcessApi.updateMortgageStatus(
      processId: detail.process.id,
      status: 'BANK_EVALUATION',
      note: legalHqBankAgentNote(agent),
    );

    if (!mounted) return;
    safeSetState(() => _advancingStage = false);

    if (!response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo pasar el expediente a evaluación bancaria'),
        ),
      );
      return;
    }

    FFAppState().setMortgageBankAgent(detail.process.id, agent.toJson());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gestor registrado. Expediente en evaluación bancaria'),
      ),
    );
    safeSetState(_loadData);
  }

  /// Aplica la resolución elegida en el seguimiento de la evaluación.
  ///
  /// Las tres opciones viajan por `PUT /mortgage/status`, y la nota queda con
  /// cada una en el `stateHistory` del expediente —append-only—, que es el
  /// historial interno del trámite.
  ///
  /// La de mantenimiento manda el mismo estado a propósito: lo que cambia es
  /// la nota y, con ella, la fecha de última actualización. Hoy esa ruta
  /// rechaza repetir el estado actual, así que el envío vuelve con el aviso
  /// de abajo; se manda igual en vez de bloquearlo acá para que el día que la
  /// ruta lo acepte —o exista una para registrar la novedad sin transición—
  /// esto funcione sin tocar la pantalla.
  Future<void> _updateEvaluation(LegalHqProcessDetail detail) async {
    final outcome = _evaluationOutcome;
    final note = _model.noteController?.text.trim() ?? '';

    if (outcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí el estado actual del trámite')),
      );
      return;
    }

    // Las dos opciones que no cierran con una buena noticia dependen de la
    // nota: sin texto, la actualización de mantenimiento no le lleva nada al
    // cliente y el rechazo no explica por qué.
    if (note.isEmpty && outcome != LegalHqEvaluationOutcome.approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(outcome == LegalHqEvaluationOutcome.rejected
              ? 'Escribí los motivos del rechazo en la nota'
              : 'Escribí en la nota qué novedad avisarle al cliente'),
        ),
      );
      return;
    }

    safeSetState(() => _advancingStage = true);
    final response = await LegalHqProcessApi.updateMortgageStatus(
      processId: detail.process.id,
      status: outcome.status,
      note: note,
    );

    if (!mounted) return;
    safeSetState(() => _advancingStage = false);

    if (!response.succeeded) {
      // La novedad sin cambio de estado es la que hoy no pasa: conviene
      // nombrarlo, y no borrar la nota, para que no se lea como un error
      // suelto ni haya que volver a escribirla.
      final isMaintenance = !outcome.resolvesEvaluation &&
          detail.process.status == 'BANK_EVALUATION';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isMaintenance
              ? 'No se pudo registrar la novedad: el expediente ya está en '
                  'evaluación bancaria y la ruta todavía rechaza repetir el '
                  'estado. La nota quedó escrita.'
              : 'No se pudo actualizar el estado del trámite'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (outcome) {
          LegalHqEvaluationOutcome.approved => 'Hipoteca aprobada',
          LegalHqEvaluationOutcome.rejected => 'Hipoteca rechazada',
          // Entrar a la evaluación y avisar una novedad dentro de ella son la
          // misma opción, pero no la misma noticia.
          LegalHqEvaluationOutcome.stillEvaluating =>
            detail.process.status == 'BANK_EVALUATION'
                ? 'Novedad registrada en el expediente'
                : 'Expediente en evaluación bancaria',
        }),
      ),
    );

    safeSetState(() {
      _evaluationOutcome = null;
      _model.noteController?.clear();
      _loadData();
    });
  }

  /// Abre el comprobante de honorarios y habilita el cierre de la venta.
  Future<void> _openPaymentProof(LegalHqProcessDetail detail) async {
    if (!detail.hasPaymentProof) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todavía no hay comprobante de pago cargado'),
        ),
      );
      return;
    }

    final document = detail.paymentProofDocument;
    if (document != null && document.hasFile) {
      // Queda auditado antes de navegar: al volver, el botón ya está activo.
      safeSetState(() => _paymentProofOpened = true);
      await _openDocument(detail.process, document);
      return;
    }

    // El comprobante llegó como URL suelta: se abre fuera de la app.
    final uri = Uri.tryParse(detail.paymentProofLink);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el comprobante')),
      );
      return;
    }

    if (!mounted) return;
    safeSetState(() => _paymentProofOpened = true);
  }

  /// Cierra la venta exitosa.
  ///
  /// `mortgage/finish` hace todo del lado del backend: pasa el expediente a
  /// `FINISHED`, completa la oferta y deja la propiedad en `SOLD`, lo que
  /// además auto-rechaza el resto de ofertas pendientes.
  Future<void> _finishApprovedProcess(LegalHqProcessDetail detail) async {
    safeSetState(() => _advancingStage = true);
    final response =
        await LegalHqProcessApi.finishMortgageProcess(detail.process.id);

    if (!mounted) return;
    safeSetState(() => _advancingStage = false);

    if (!response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar la venta del inmueble'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Venta finalizada. El inmueble quedó marcado como '
            'vendido'),
      ),
    );
    context.safePop();
  }

  /// Abre el marcador del teléfono. `canLaunchUrl` no sirve de guarda acá:
  /// en Android 11+ devuelve `false` para `tel:` salvo que el manifest declare
  /// la consulta de ACTION_DIAL, así que se intenta la llamada directamente y
  /// el portapapeles queda como salida para web y escritorio.
  Future<void> _contactParty(LegalHqParty party) async {
    final uri = Uri(scheme: 'tel', path: party.dialablePhone);
    try {
      if (await launchUrl(uri)) return;
    } on PlatformException {
      // Sin app de llamadas: se copia el número.
    }

    if (!mounted) return;
    await Clipboard.setData(ClipboardData(text: party.phone));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Teléfono copiado: ${party.phone}')),
    );
  }
}
