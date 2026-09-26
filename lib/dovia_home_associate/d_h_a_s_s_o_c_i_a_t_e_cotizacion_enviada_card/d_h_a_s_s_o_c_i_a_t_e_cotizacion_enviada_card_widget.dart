import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de cotización con la píldora [Ver trabajo]: fondo blanco con borde,
/// ícono del rubro y el nombre del trabajo.
///
/// La usan dos pantallas con intenciones distintas:
///
///   - El **panel** la pinta en "Cotizaciones enviadas" sin [onViewWork]. Ahí la
///     píldora es un rótulo y no responde al toque: el presupuesto ya salió y no
///     hay nada que hacer hasta que el cliente decida. Se deja como rótulo y no
///     como botón deshabilitado a propósito: un botón gris invita a insistir
///     sobre algo que no depende de la empresa.
///   - El **historial de "Cotizaciones"** la pinta para los cuatro estados con
///     [onViewWork], que es la acción del diseño: lleva a cotizar, a leer el
///     presupuesto enviado o a ejecutar el proyecto según en qué estado esté.
class DHASSOCIATECotizacionEnviadaCardWidget extends StatelessWidget {
  const DHASSOCIATECotizacionEnviadaCardWidget({
    super.key,
    required this.title,
    required this.iconPath,
    this.subtitle,
    this.onViewWork,
  });

  /// Estado en una línea, entre el título y [Ver trabajo] (Ej: "Aguardando
  /// respuesta del cliente"). Null la esconde.
  final String? subtitle;

  /// Trabajo cotizado (Ej: "Instalación de TV").
  final String title;

  /// Ícono del rubro, resuelto con el mismo mapeo que el carrusel de servicios.
  final String iconPath;

  /// Acción de la píldora [Ver trabajo]. Null la deja como rótulo informativo.
  final VoidCallback? onViewWork;

  /// El mismo verde que los servicios del Dovia Home cliente.
  static const Color _iconSurface = Color(0xFF007376);
  static const Color _pillSurface = Color(0xFFCCE3E4);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // Toda la tarjeta hace lo mismo que su botón (ojo / Ver trabajo).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onViewWork,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12.0,
              offset: Offset(0.0, 4.0),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Un tercio de la tarjeta: el ícono del rubro, grande y en verde,
            // sin caja detrás.
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 56.0,
                  height: 56.0,
                  fit: BoxFit.contain,
                  colorFilter:
                      const ColorFilter.mode(_iconSurface, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            // Los otros dos tercios: título, estado y [Ver trabajo].
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.publicSans(),
                      color: theme.primaryText,
                      fontSize: 16.0,
                      letterSpacing: 0.32,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.publicSans(),
                        color: theme.secondaryText,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8.0),
                  InkWell(
                    onTap: onViewWork,
                    borderRadius: BorderRadius.circular(100.0),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Container(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
