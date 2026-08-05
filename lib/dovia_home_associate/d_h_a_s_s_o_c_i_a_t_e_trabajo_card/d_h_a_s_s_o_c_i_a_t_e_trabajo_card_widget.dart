import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de oportunidad del panel de Dovia Home Associate.
///
/// Es la misma tarjeta para "Trabajos disponibles" (la bolsa de trabajos que
/// nadie tomó) y para "Próximos trabajos" (los que este asociado ya aceptó): en
/// el diseño son idénticas y sólo cambia a dónde lleva el ícono de "Ojo".
///
/// En el diseño de escritorio son dos columnas de 285px; en mobile la tarjeta
/// ocupa el ancho de la pantalla y el bloque de datos se apila a la izquierda
/// del botón de ver detalle.
class DHASSOCIATETrabajoCardWidget extends StatelessWidget {
  const DHASSOCIATETrabajoCardWidget({
    super.key,
    required this.title,
    required this.addressLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.payoutLabel,
    required this.priorityLabel,
    required this.isUrgent,
    this.onViewDetail,
  });

  /// Título del trabajo (Ej: "Instalación de TV").
  final String title;

  /// Zona de la visita. En la bolsa de oportunidades **no** es la dirección
  /// exacta: se revela sólo después de aceptar el trabajo.
  final String addressLabel;

  /// Fecha en la que el cliente pide la visita (`dd/mm/aaaa`).
  final String dateLabel;

  /// Hora de la visita (`Hora: HH:mm`).
  final String timeLabel;

  /// Pago neto del asociado, ya descontada la comisión de DOVIA.
  final String payoutLabel;

  /// Texto de la píldora de prioridad: `ESTANDAR` o `URGENTE`.
  final String priorityLabel;

  /// Emergencia: píldora roja. Servicio estándar: píldora ámbar.
  final bool isUrgent;

  /// Ver detalle (ícono de "Ojo").
  final VoidCallback? onViewDetail;

  static const Color _cardBackground = Color(0xFFF3F3EF);
  // Píldoras del diseño: el color del oficio al 20% de fondo y pleno en el
  // texto (`rgba(232,93,117,0.2)` / `rgba(246,166,35,0.2)`).
  static const Color _urgentText = Color(0xFFE85D75);
  static const Color _urgentBackground = Color(0x33E85D75);
  static const Color _standardText = Color(0xFFF6A623);
  static const Color _standardBackground = Color(0x33F6A623);
  static const Color _eyeBackground = Color(0xFFCCE3E4);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14.0, 12.0, 12.0, 14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: theme.primary,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: isUrgent ? _urgentBackground : _standardBackground,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(
                    priorityLabel,
                    style: GoogleFonts.publicSans(
                      color: isUrgent ? _urgentText : _standardText,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressLabel,
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: theme.primary,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        dateLabel,
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          color: theme.primaryText,
                          fontSize: 17.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        timeLabel,
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: theme.primaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        payoutLabel,
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          color: theme.primaryText,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10.0),
                InkWell(
                  onTap: onViewDetail,
                  borderRadius: BorderRadius.circular(20.0),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: const BoxDecoration(
                      color: _eyeBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.visibility_outlined,
                      color: theme.primary,
                      size: 22.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
