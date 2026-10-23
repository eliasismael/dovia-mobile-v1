import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sombra de las barras de navegación flotantes: amplia y difusa alrededor,
/// para despegarlas del contenido que pasa por debajo, más una corta y
/// cercana que marca el borde sin una línea.
const kFloatingNavbarShadow = [
  BoxShadow(
    blurRadius: 44.0,
    spreadRadius: 4.0,
    color: Color(0x4700444B),
    offset: Offset(0.0, 4.0),
  ),
  BoxShadow(
    blurRadius: 14.0,
    color: Color(0x24000000),
    offset: Offset(0.0, 3.0),
  ),
];

/// Margen a los costados de las barras de navegación flotantes.
const kFloatingNavbarSideMargin = 12.0;

/// Radio de las barras flotantes: casi media altura, así los costados quedan
/// bien redondeados.
const kFloatingNavbarRadius = 30.0;

/// Lo que va debajo de la barra de navegación de abajo, en las pantallas que
/// la dejan flotar sobre el contenido (sin SafeArea abajo).
///
/// - iOS: sólo el margen del indicador de inicio. No hay botones, así que el
///   contenido que se ve por debajo es lo que da el efecto flotante.
/// - Android: la app se dibuja detrás de los botones del sistema (borde a
///   borde desde Android 15) y el contenido quedaba ahí, tapado por los
///   botones y un velo oscuro. La franja de los botones va con fondo sólido,
///   y la barra sube [androidGap] para que el contenido pase entre los dos.
///
/// En las pantallas con SafeArea abajo (el resto de las secciones) el margen
/// ya está resuelto: en Android sólo se agrega [androidGap], para que la barra
/// quede a la misma altura que en el inicio.
class FloatingNavbarInset extends StatelessWidget {
  const FloatingNavbarInset({super.key, required this.child});

  final Widget child;

  static const double androidGap = 12.0;
  static const Color _androidStripColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      if (bottom == 0) return child;
      return Padding(padding: EdgeInsets.only(bottom: bottom), child: child);
    }
    if (bottom == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: androidGap),
        child: child,
      );
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Íconos oscuros sobre la franja blanca, sin el velo del sistema.
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: _androidStripColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: androidGap),
          Container(height: bottom, color: _androidStripColor),
        ],
      ),
    );
  }
}
