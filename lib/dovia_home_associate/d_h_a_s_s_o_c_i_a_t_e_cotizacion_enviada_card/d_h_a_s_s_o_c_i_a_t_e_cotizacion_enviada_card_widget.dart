import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de "Cotizaciones enviadas" del panel de la empresa.
///
/// Es la tarjeta **de diseño diferenciado** del carril 2: fondo blanco con
/// borde, en vez del beige de las tarjetas accionables. Esa diferencia visual es
/// la que comunica el estado — el presupuesto ya salió y ahora decide el
/// cliente, que lo compara contra los de otras empresas en su propia app.
///
/// Por eso la píldora [Ver trabajo] es **informativa y no responde al toque**:
/// no hay ninguna acción disponible hasta que el cliente acepte o rechace. Se
/// pinta como un rótulo y no como un botón deshabilitado a propósito: un botón
/// gris invita a insistir sobre algo que no depende de la empresa.
class DHASSOCIATECotizacionEnviadaCardWidget extends StatelessWidget {
  const DHASSOCIATECotizacionEnviadaCardWidget({
    super.key,
    required this.title,
    required this.iconPath,
  });

  /// Trabajo cotizado (Ej: "Instalación de TV").
  final String title;

  /// Ícono del rubro, resuelto con el mismo mapeo que el carrusel de servicios.
  final String iconPath;

  static const Color _border = Color(0xFFE5E7EB);
  static const Color _iconSurface = Color(0xFFF3F3EF);
  static const Color _pillSurface = Color(0xFFCCE3E4);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: _iconSurface,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 24.0,
                height: 24.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.publicSans(),
                    color: theme.primaryText,
                    fontSize: 16.0,
                    letterSpacing: 0.32,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: _pillSurface,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(
                    'Ver trabajo',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.publicSans(),
                      color: theme.primary,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
