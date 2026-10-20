// Automatic FlutterFlow imports
import '/core/network_image_size.dart';
import '/backend/schema/structs/index.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import '/custom_code/widgets/index.dart'; // Imports other custom widgets
// import '/flutter_flow/custom_functions.dart'; // Imports custom functions

// import '/custom_code/widgets/index.dart';
// import '/flutter_flow/custom_functions.dart';

class DetalleProcesoWidget extends StatefulWidget {
  static const Color aquaColor = Color(0xFF007376);
  static const Color aqua60Color = Color(0xFF70ACAD);
  static const Color textColor = Color(0xFF00444B);
  static const Color beigeColor = Color(0xFFEBEAE3);
  static const Color grayStep = Color(0xFFE5E7EB);
  static const Color grayStepText = Color(0xFF99A1AF);
  static const Color alertBgColor = Color(0x3370ACAD);
  static const Color pendienteBgColor = Color(0xFFFFF1BC);
  static const Color pendienteTextColor = Color(0xFFF5A700);
  static const Color enRedaccionBgColor = Color(0xFFCCE3E4);
  static const Color reunionBgColor = Color(0xFFD2CCE4);
  static const Color reunionTextColor = Color(0xFF0205B4);
  static const Color rechazadoBgColor = Color(0xFFFFDBDB);
  static const Color rechazadoTextColor = Color(0xFFFB2C36);
  static const Color aprobadoBgColor = Color(0xFFB4FFC1);
  static const Color aprobadoTextColor = Color(0xFF038118);
  static const Color enRevisionBgColor = Color(0xFFFFDBBC);
  static const Color enRevisionTextColor = Color(0xFFF57E00);
  static const Color darkTextColor = Color(0xFF1E2939);
  static const Color inputBgColor = Color(0xFFFAFAFA);
  static const Color grayText = Color(0xFF858585);
  static const Color borderColor = Color(0xFFE9EFF2);

  final double? width;
  final double? height;

  /// Current step: 0, 1, 2, 3, or 4
  final int step;

  /// Optional: 'aprobado' or 'rechazado'. Only applies when step == 4.
  final String? devolucion;

  /// Callback for "Continuar" button (steps 0, 1, 2, 3)
  final VoidCallback? onContinuar;

  // Step 2 optional callbacks
  final VoidCallback? onSubirDocumento;
  final VoidCallback? onDescargarDocumento;
  final VoidCallback? onSubirContrato;

  // Step 3 optional callbacks
  final VoidCallback? onVerUbicacion;
  final VoidCallback? onCancelarReunion;
  final VoidCallback? onReagendarReunion;
  final VoidCallback? onDescargarInformacion;
  final VoidCallback? onVisualizarDocumento;

  /// Step 3: Map widget to display (passed as parameter)
  final Function? mapWidget;

  /// Step 3: Owner card data (optional)
  final UserCardDataStruct? propietarioData;

  /// Step 3: Client card data (optional)
  final UserCardDataStruct? clienteData;

  // Step 4 (no devolucion) callback
  final VoidCallback? onVerContratoSubido;

  // Step 4 rechazado callback
  final VoidCallback? onVolverACargarDocumento;

  // Step 4 aprobado callback
  final VoidCallback? onFinalizarProceso;

  const DetalleProcesoWidget({
    super.key,
    this.width,
    this.height,
    required this.step,
    this.devolucion,
    this.onContinuar,
    this.onSubirDocumento,
    this.onDescargarDocumento,
    this.onSubirContrato,
    this.onVerUbicacion,
    this.onCancelarReunion,
    this.onReagendarReunion,
    this.onDescargarInformacion,
    this.onVisualizarDocumento,
    this.mapWidget,
    this.propietarioData,
    this.clienteData,
    this.onVerContratoSubido,
    this.onVolverACargarDocumento,
    this.onFinalizarProceso,
  });

  @override
  State<DetalleProcesoWidget> createState() => _DetalleProcesoWidgetState();
}

class _DetalleProcesoWidgetState extends State<DetalleProcesoWidget> {
  // Collapsible state for Step 3 sections
  bool _acuerdoExpanded = false;
  bool _documentosExpanded = false;
  bool _adicionalesExpanded = false;

  // Collapsible state for Step 4 (no devolucion) documents section
  bool _step4DocumentosExpanded = false;

  // Shortcut accessors
  int get step => widget.step;
  String? get devolucion => widget.devolucion;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Progress Bar (only for steps 1-4)
          if (step >= 1) ...[
            _buildStepProgressBar(),
            const SizedBox(height: 25),
          ],

          // Info Card (all steps)
          _buildInfoCard(),
          const SizedBox(height: 12),

          // Step-specific content
          ..._buildStepContent(),
        ],
      ),
    );
  }

  // ─── STEP PROGRESS BAR ──────────────────────────────────────────────
  Widget _buildStepProgressBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proceso de Documentación',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DetalleProcesoWidget.darkTextColor,
              height: 24 / 14,
              letterSpacing: -0.3125,
            ),
          ),
          const SizedBox(height: 12),
          _buildStepCircles(),
        ],
      ),
    );
  }

  Widget _buildStepCircles() {
    final List<String> labels = [
      'Pendiente\nde cláusulas',
      'En\nredacción',
      'Reunión\nagendada',
      'En revisión\nLegal HQ',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 4; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: i < step
                        ? DetalleProcesoWidget.aquaColor
                        : DetalleProcesoWidget.grayStep,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: i < step
                            ? Colors.white
                            : DetalleProcesoWidget.grayStepText,
                        letterSpacing: -0.1504,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: i < step
                        ? DetalleProcesoWidget.textColor
                        : DetalleProcesoWidget.grayStepText,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── INFO CARD ──────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    String statusText;
    Color statusBgColor;
    Color statusTextColor;
    double statusWidth = 114;

    if (step == 4 && devolucion == 'rechazado') {
      statusText = 'Rechazado';
      statusBgColor = DetalleProcesoWidget.rechazadoBgColor;
      statusTextColor = Colors.red;
    } else if (step == 4 && devolucion == 'aprobado') {
      statusText = 'Aprobado';
      statusBgColor = DetalleProcesoWidget.aprobadoBgColor;
      statusTextColor = DetalleProcesoWidget.aprobadoTextColor;
    } else if (step == 4) {
      // Step 4 without devolucion = "En revisión Legal HQ"
      statusText = 'En revisión Legal HQ';
      statusBgColor = DetalleProcesoWidget.enRevisionBgColor;
      statusTextColor = DetalleProcesoWidget.enRevisionTextColor;
      statusWidth = 178;
    } else if (step == 3) {
      statusText = 'Reunión agendada';
      statusBgColor = DetalleProcesoWidget.reunionBgColor;
      statusTextColor = DetalleProcesoWidget.reunionTextColor;
      statusWidth = 151;
    } else if (step == 2) {
      statusText = 'En redacción';
      statusBgColor = DetalleProcesoWidget.enRedaccionBgColor;
      statusTextColor = DetalleProcesoWidget.aquaColor;
    } else {
      statusText = 'Pendiente';
      statusBgColor = DetalleProcesoWidget.pendienteBgColor;
      statusTextColor = DetalleProcesoWidget.pendienteTextColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo: Arriendo',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DetalleProcesoWidget.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estatus',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: DetalleProcesoWidget.aquaColor,
                ),
              ),
              Container(
                width: statusWidth,
                height: 23,
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Dirección: XXX',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DetalleProcesoWidget.textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP-SPECIFIC CONTENT ──────────────────────────────────────────
  List<Widget> _buildStepContent() {
    switch (step) {
      case 0:
        return _buildStep0Content();
      case 1:
        return _buildStep1Content();
      case 2:
        return _buildStep2Content();
      case 3:
        return _buildStep3Content();
      case 4:
        return _buildStep4Content();
      default:
        return [];
    }
  }

  // ─── STEP 0 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep0Content() {
    return [
      _buildAlertBox(
        'Comunícate con el cliente y el propietario para definir las cláusulas del acuerdo.',
      ),
      const SizedBox(height: 180),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Si ya se definieron las cláusulas del acuerdo, puede pasar a la parte de redacción',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DetalleProcesoWidget.textColor,
            height: 16 / 14,
          ),
        ),
      ),
      const SizedBox(height: 16),
      _buildAquaButton('Continuar', onPressed: widget.onContinuar),
    ];
  }

  // ─── STEP 1 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep1Content() {
    return [
      _buildAlertBox(
        'Comunícate con el cliente y el propietario para definir las cláusulas del acuerdo.',
      ),
      const SizedBox(height: 180),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Si ya se definieron las cláusulas del acuerdo, puede pasar a la parte de redacción',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DetalleProcesoWidget.textColor,
            height: 16 / 14,
          ),
        ),
      ),
      const SizedBox(height: 16),
      _buildAquaButton('Continuar', onPressed: widget.onContinuar),
    ];
  }

  // ─── STEP 2 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep2Content() {
    return [
      const SizedBox(height: 20),
      _buildDocumentSection(
        title: 'Contrato',
        description: 'Subir contrato',
        actions: [
          _buildIconCircleButton(
            icon: Icons.upload_outlined,
            onPressed: widget.onSubirContrato,
          ),
        ],
      ),
      const SizedBox(height: 20),
      _buildDocumentSection(
        title: 'Documento',
        description: 'Descargue el documento para editarlo si es necesario',
        actions: [
          _buildIconCircleButton(
            icon: Icons.download_outlined,
            onPressed: widget.onDescargarDocumento,
          ),
          const SizedBox(width: 5.4),
          _buildIconCircleButton(
            icon: Icons.upload_outlined,
            onPressed: widget.onSubirDocumento,
          ),
        ],
      ),
      const SizedBox(height: 40),
      _buildAquaButton('Continuar', onPressed: widget.onContinuar),
    ];
  }

  // ─── STEP 3 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep3Content() {
    return [
      // Date/Time card
      _buildDateTimeCard(),
      const SizedBox(height: 15),
      // Map section with "Ver ubicación" button
      _buildMapSection(),
      const SizedBox(height: 15),
      // User cards carousel (only if at least one card data is provided)
      if (widget.propietarioData != null || widget.clienteData != null) ...[
        _buildUserCardsRow(),
        const SizedBox(height: 15),
      ],
      // Acuerdo collapsible dropdown
      _buildCollapsibleDropdown(
        title: 'Acuerdo',
        isExpanded: _acuerdoExpanded,
        onTap: () => setState(() => _acuerdoExpanded = !_acuerdoExpanded),
        children: [
          const SizedBox(height: 10),
          _buildReadOnlyInput(label: 'Método de pago', placeholder: 'xxx'),
          const SizedBox(height: 12),
          _buildReadOnlyInput(
            label: 'Propuesta económica',
            placeholder: 'xxx',
          ),
          const SizedBox(height: 12),
          _buildReadOnlyInput(label: 'Enganche', placeholder: '%'),
          const SizedBox(height: 12),
          _buildReadOnlyInput(label: 'Tiempo', placeholder: 'XM'),
          const SizedBox(height: 12),
          _buildReadOnlyInput(label: 'Banco', placeholder: 'xx'),
          const SizedBox(height: 12),
          _buildAquaButton(
            'Descargar información',
            onPressed: widget.onDescargarInformacion,
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Documentos collapsible dropdown
      _buildCollapsibleDropdown(
        title: 'Documentos',
        isExpanded: _documentosExpanded,
        onTap: () => setState(() => _documentosExpanded = !_documentosExpanded),
        children: [
          const SizedBox(height: 10),
          _buildAlertBox(
            'Solo puedes visualizar el documento, no se puede editar',
          ),
          const SizedBox(height: 10),
          _buildPdfPreview(),
        ],
      ),
      const SizedBox(height: 10),
      // Adicionales collapsible dropdown
      _buildCollapsibleDropdown(
        title: 'Adicionales',
        isExpanded: _adicionalesExpanded,
        onTap: () =>
            setState(() => _adicionalesExpanded = !_adicionalesExpanded),
        children: [
          const SizedBox(height: 8),
          _buildNotasInput(),
        ],
      ),
      const SizedBox(height: 20),
      // Continuar button
      _buildAquaButton('Continuar', onPressed: widget.onContinuar),
      const SizedBox(height: 20),
    ];
  }

  // ─── STEP 4 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep4Content() {
    if (devolucion == 'rechazado') {
      return _buildStep4RechazadoContent();
    } else if (devolucion == 'aprobado') {
      return _buildStep4AprobadoContent();
    } else {
      return _buildStep4DefaultContent();
    }
  }

  // ─── STEP 4 DEFAULT (no devolucion) ─────────────────────────────────
  List<Widget> _buildStep4DefaultContent() {
    return [
      // Alert explaining the process
      _buildAlertBox(
        'Legal HQ está revisando los documentos. Cuando estes aprobados o rechazados le llegará una notificación.',
      ),
      const SizedBox(height: 15),
      // Documentos collapsible dropdown
      _buildCollapsibleDropdown(
        title: 'Documentos',
        isExpanded: _step4DocumentosExpanded,
        onTap: () => setState(
            () => _step4DocumentosExpanded = !_step4DocumentosExpanded),
        children: [
          const SizedBox(height: 10),
          _buildAlertBox(
            'Solo puedes visualizar el documento, no se puede editar',
          ),
          const SizedBox(height: 10),
          // PDF preview with onVerContratoSubido
          _buildPdfPreview(onTap: widget.onVerContratoSubido),
        ],
      ),
    ];
  }

  // ─── STEP 4 RECHAZADO ──────────────────────────────────────────────
  List<Widget> _buildStep4RechazadoContent() {
    return [
      _buildRejectionAlertBox(
        'Legal HQ rechazó los documentos por:\nx\nx\nx',
      ),
      const SizedBox(height: 15),
      _buildDocumentSection(
        title: 'Documentos',
        description: 'Volver a cargar documento',
        actions: [
          _buildIconCircleButton(
            icon: Icons.upload_outlined,
            onPressed: widget.onVolverACargarDocumento,
          ),
        ],
      ),
    ];
  }

  // ─── STEP 4 APROBADO ───────────────────────────────────────────────
  List<Widget> _buildStep4AprobadoContent() {
    return [
      const SizedBox(height: 200),
      _buildAquaButton(
        'Finalizar proceso',
        onPressed: widget.onFinalizarProceso,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED / HELPER COMPONENTS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAlertBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DetalleProcesoWidget.alertBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: DetalleProcesoWidget.textColor,
          height: 16 / 12,
        ),
      ),
    );
  }

  Widget _buildRejectionAlertBox(String text) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 106),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DetalleProcesoWidget.rechazadoBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: DetalleProcesoWidget.rechazadoTextColor,
          height: 16 / 12,
        ),
      ),
    );
  }

  Widget _buildAquaButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DetalleProcesoWidget.aquaColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: DetalleProcesoWidget.aquaColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 14 / 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String description,
    required List<Widget> actions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DetalleProcesoWidget.textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: DetalleProcesoWidget.beigeColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: DetalleProcesoWidget.textColor,
                    height: 1.6,
                    letterSpacing: 0.0697,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconCircleButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4.19),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x3370ACAD),
              blurRadius: 2.7,
              offset: Offset(0, 2.7),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: DetalleProcesoWidget.textColor,
        ),
      ),
    );
  }

  // ─── COLLAPSIBLE DROPDOWN ───────────────────────────────────────────

  Widget _buildCollapsibleDropdown({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row (tappable)
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: DetalleProcesoWidget.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DetalleProcesoWidget.textColor,
                        height: 24 / 14,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 24,
                      color: DetalleProcesoWidget.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Collapsible content
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  // ─── STEP 3 SPECIFIC BUILDERS ───────────────────────────────────────

  Widget _buildDateTimeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha: Martes, 23 de abril de 2026',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DetalleProcesoWidget.textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hora: 10:00 a.m. – 11:00 a.m.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DetalleProcesoWidget.textColor,
            ),
          ),
          const SizedBox(height: 12),
          // Cancelar & Re-agendar buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 29,
                  child: OutlinedButton(
                    onPressed: widget.onCancelarReunion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 14 / 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SizedBox(
                  height: 29,
                  child: OutlinedButton(
                    onPressed: widget.onReagendarReunion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DetalleProcesoWidget.aquaColor,
                      side: const BorderSide(
                        color: DetalleProcesoWidget.aquaColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                    ),
                    child: const Text(
                      'Re-agendar',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 14 / 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dirección de donde se encontrarán',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DetalleProcesoWidget.grayText,
          ),
        ),
        const SizedBox(height: 7),
        // Map: use provided widget or show a placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: double.infinity,
            height: 322,
            child: widget.mapWidget?.call() ??
                Container(
                  color: DetalleProcesoWidget.inputBgColor,
                  child: const Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 60,
                      color: DetalleProcesoWidget.aqua60Color,
                    ),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 7),
        // Ver ubicación button
        SizedBox(
          width: double.infinity,
          height: 29,
          child: ElevatedButton(
            onPressed: widget.onVerUbicacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: DetalleProcesoWidget.aqua60Color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            ),
            child: const Text(
              'Ver ubicación',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCardsRow() {
    return SizedBox(
      height: 248,
      child: Row(
        children: [
          if (widget.propietarioData != null)
            Expanded(child: _buildUserCard(widget.propietarioData!)),
          if (widget.propietarioData != null && widget.clienteData != null)
            const SizedBox(width: 21),
          if (widget.clienteData != null)
            Expanded(child: _buildUserCard(widget.clienteData!)),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserCardDataStruct data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.48),
        border: Border.all(color: DetalleProcesoWidget.aquaColor, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
              border: Border.all(
                color: DetalleProcesoWidget.aquaColor.withValues(alpha: 0.3),
              ),
            ),
            child: ClipOval(child: _buildImage(data.imageUrl)),
          ),
          const SizedBox(height: 12),
          // Role label
          Container(
            width: 126,
            padding: const EdgeInsets.symmetric(vertical: 3.24),
            decoration: BoxDecoration(
              color: DetalleProcesoWidget.alertBgColor,
              borderRadius: BorderRadius.circular(65),
            ),
            child: Text(
              data.roleLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 8.8,
                fontWeight: FontWeight.w400,
                color: DetalleProcesoWidget.textColor.withValues(alpha: 0.8),
                height: 1.6,
                letterSpacing: 0.0697,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12.32,
              fontWeight: FontWeight.w700,
              color: DetalleProcesoWidget.textColor,
              height: 1.6,
              letterSpacing: 0.0697,
            ),
          ),
          const SizedBox(height: 2),
          // Info rows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  data.sexo,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    color: DetalleProcesoWidget.textColor,
                    height: 1.6,
                    letterSpacing: 0.0697,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  data.nacionalidad,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    color: DetalleProcesoWidget.textColor,
                    height: 1.6,
                    letterSpacing: 0.0697,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  data.edad,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    color: DetalleProcesoWidget.textColor,
                    height: 1.6,
                    letterSpacing: 0.0697,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  data.telefono,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    color: DetalleProcesoWidget.textColor,
                    height: 1.6,
                    letterSpacing: 0.0697,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds an image widget that handles network URLs, asset paths, etc.
  Widget _buildImage(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.person,
          size: 50,
          color: DetalleProcesoWidget.aqua60Color,
        ),
        cacheWidth: networkImageCacheWidth(width: 100, height: 100),
      );
    } else {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.person,
          size: 50,
          color: DetalleProcesoWidget.aqua60Color,
        ),
      );
    }
  }

  Widget _buildReadOnlyInput({
    required String label,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: DetalleProcesoWidget.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: DetalleProcesoWidget.inputBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            placeholder,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0x80888888),
              letterSpacing: 0.28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfPreview({VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PDF box
        GestureDetector(
          onTap: onTap ?? widget.onVisualizarDocumento,
          child: Container(
            width: double.infinity,
            height: 121,
            decoration: BoxDecoration(
              color: DetalleProcesoWidget.aquaColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            child: const Center(
              child: Text(
                'PDF',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 0.32,
                ),
              ),
            ),
          ),
        ),
        // Contrato label
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Contrato',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DetalleProcesoWidget.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotasInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas de la reunión',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DetalleProcesoWidget.textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 104,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: DetalleProcesoWidget.inputBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.topLeft,
          child: const Text(
            'Escribe aquí...',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0x80888888),
              letterSpacing: 0.28,
              height: 49.849 / 14,
            ),
          ),
        ),
      ],
    );
  }
}
