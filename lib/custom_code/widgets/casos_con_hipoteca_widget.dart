// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class CasosConHipotecaWidget extends StatelessWidget {
  static const Color aquaColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color grayStep = Color(0xFFE5E7EB);
  static const Color grayStepText = Color(0xFF99A1AF);
  static const Color alertBgColor = Color(0x3370ACAD);
  static const Color darkTextColor = Color(0xFF1E2939);

  static const Color gestionBadgeBgColor = Color(0xFFD2CCE4);
  static const Color gestionBadgeTextColor = Color(0xFF0306B4);
  static const Color documentacionBadgeBgColor = Color(0xFFD2CCE4);
  static const Color documentacionBadgeTextColor = Color(0xFF0306B4);
  static const Color enEvaluacionBgColor = Color(0xFFFFDBBC);
  static const Color enEvaluacionTextColor = Color(0xFFF57E00);
  static const Color rechazadoBgColor = Color(0xFFFFDBDB);
  static const Color rechazadoTextColor = Color(0xFFFB2C36);
  static const Color aprobadoBgColor = Color(0xFFB4FFC1);
  static const Color aprobadoTextColor = Color(0xFF038118);
  static const Color rejectionAlertBgColor = Color(0xFFFFDBDB);

  final double? width;
  final double? height;

  /// Current step: 1, 2, or 3
  final int step;

  /// Optional: 'aprobado' or 'rechazado'. Only applies when step == 3.
  final String? devolucion;

  /// Callback for "Actualizar estado" button (steps 1, 2, 3)
  final VoidCallback? onActualizarEstado;

  /// Callback for "Finalizar proceso" button (step 3 rechazado & aprobado)
  final VoidCallback? onFinalizarProceso;

  const CasosConHipotecaWidget({
    super.key,
    this.width,
    this.height,
    required this.step,
    this.devolucion,
    this.onActualizarEstado,
    this.onFinalizarProceso,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Progress Bar (always shown)
          _buildStepProgressBar(),
          const SizedBox(height: 25),

          // Info Card (always shown)
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
              color: darkTextColor,
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
      'Gestión\nbancaria\niniciada',
      'Documentación',
      'En\nevaluación\nbancaria',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 3; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: i < step ? aquaColor : grayStep,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: i < step ? Colors.white : grayStepText,
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
                    color: i < step ? textColor : grayStepText,
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
    double statusWidth;

    if (step == 3 && devolucion == 'rechazado') {
      statusText = 'Rechazado';
      statusBgColor = rechazadoBgColor;
      statusTextColor = rechazadoTextColor;
      statusWidth = 114;
    } else if (step == 3 && devolucion == 'aprobado') {
      statusText = 'Aprobado';
      statusBgColor = aprobadoBgColor;
      statusTextColor = aprobadoTextColor;
      statusWidth = 114;
    } else if (step == 3) {
      statusText = 'En evaluación bancaria';
      statusBgColor = enEvaluacionBgColor;
      statusTextColor = enEvaluacionTextColor;
      statusWidth = 195;
    } else if (step == 2) {
      statusText = 'Documentación enviada al banco';
      statusBgColor = documentacionBadgeBgColor;
      statusTextColor = documentacionBadgeTextColor;
      statusWidth = 248;
    } else {
      // step == 1
      statusText = 'Gestión bancaria iniciada';
      statusBgColor = gestionBadgeBgColor;
      statusTextColor = gestionBadgeTextColor;
      statusWidth = 215;
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
            'Compra con hipoteca',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
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
                  color: aquaColor,
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
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
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Cliente: XX',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const Text(
            'Propietario: XX',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const Text(
            'Monto de la oferta: XX',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const Text(
            'Banco: XX',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP-SPECIFIC CONTENT ──────────────────────────────────────────
  List<Widget> _buildStepContent() {
    switch (step) {
      case 1:
        return _buildStep1Content();
      case 2:
        return _buildStep2Content();
      case 3:
        return _buildStep3Content();
      default:
        return [];
    }
  }

  // ─── STEP 1 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep1Content() {
    return [
      _buildAlertBox(
        'Contacta al banco para iniciar el proceso de financiación.',
      ),
      const SizedBox(height: 20),
      _buildAquaButton('Actualizar estado', onPressed: onActualizarEstado),
    ];
  }

  // ─── STEP 2 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep2Content() {
    return [
      _buildAlertBox(
        'Fecha de envío de documentos: DD/MM/AAAA\nBanco: XX',
      ),
      const SizedBox(height: 20),
      _buildAquaButton('Actualizar estado', onPressed: onActualizarEstado),
    ];
  }

  // ─── STEP 3 ─────────────────────────────────────────────────────────
  List<Widget> _buildStep3Content() {
    if (devolucion == 'rechazado') {
      return _buildStep3RechazadoContent();
    } else if (devolucion == 'aprobado') {
      return _buildStep3AprobadoContent();
    } else {
      return _buildStep3DefaultContent();
    }
  }

  // Step 3 default (en evaluación bancaria)
  List<Widget> _buildStep3DefaultContent() {
    return [
      _buildAlertBox(
        'El banco está evaluando la solicitud de hipoteca.',
      ),
      const SizedBox(height: 20),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Cuando el banco de una respuesta se actualizará el estado.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 16 / 14,
          ),
        ),
      ),
      const SizedBox(height: 16),
      _buildAquaButton('Actualizar estado', onPressed: onActualizarEstado),
    ];
  }

  // Step 3 rechazado
  List<Widget> _buildStep3RechazadoContent() {
    return [
      _buildRejectionAlertBox(
        'El banco rechazó la hipoteca por:\nx\nx\nx',
      ),
      const SizedBox(height: 20),
      _buildAquaButton('Finalizar proceso', onPressed: onFinalizarProceso),
    ];
  }

  // Step 3 aprobado
  List<Widget> _buildStep3AprobadoContent() {
    return [
      const SizedBox(height: 20),
      _buildAquaButton('Finalizar proceso', onPressed: onFinalizarProceso),
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
        color: alertBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textColor,
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
        color: rejectionAlertBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: rechazadoTextColor,
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
          backgroundColor: aquaColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: aquaColor),
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
}
