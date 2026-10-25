import '/flutter_flow/flutter_flow_theme.dart';
import '/listing_hq/listing_hq_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de oportunidad del panel de Dovia Home Associate.
///
/// Es la misma tarjeta para "Trabajos disponibles" (la bolsa de trabajos que
/// nadie tomó) y para "Próximos trabajos" (los que este asociado ya aceptó): en
/// el diseño son idénticas y sólo cambia a dónde lleva el ícono de "Ojo".
///
/// En el diseño de escritorio son columnas de 285px; acá la tarjeta ocupa el
/// ancho de la pantalla y el bloque de datos queda a la izquierda del botón de
/// ver detalle.
class DHASSOCIATETrabajoCardWidget extends StatelessWidget {
  const DHASSOCIATETrabajoCardWidget({
    super.key,
    required this.title,
    required this.addressLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.payoutLabel,
    this.priorityLabel,
    this.isUrgent = false,
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
  ///
  /// Null la esconde. Es lo que usa el panel de la empresa: una cotización
  /// nunca es una emergencia, así que la píldora diría siempre "ESTANDAR" y el
  /// diseño de sus tarjetas no la incluye.
  final String? priorityLabel;

  /// Emergencia: píldora roja. Servicio estándar: píldora ámbar.
  final bool isUrgent;

  /// Ver detalle (ícono de "Ojo").
  final VoidCallback? onViewDetail;

  // Píldoras como los estados del cliente: color sólido y texto en blanco.
  static const Color _urgentBackground = ListingHqUi.urgent;
  static const Color _standardBackground = Color(0xFFF5A700);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // Toda la tarjeta hace lo mismo que su botón (ojo / Ver trabajo).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onViewDetail,
      child: Container(
        width: double.infinity,
        decoration: ListingHqUi.cardDecoration(context),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 14.0, 16.0),
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
                        font:
                            GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                        color: theme.primary,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  if (priorityLabel != null) ...[
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color:
                            isUrgent ? _urgentBackground : _standardBackground,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(
                        priorityLabel!,
                        style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
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
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w500),
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
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primary),
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
      ),
    );
  }
}
