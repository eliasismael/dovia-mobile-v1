import 'package:flutter/material.dart';

/// Recorta lo que se desplaza por debajo de la barra de estado (hora,
/// batería, notificaciones) para que el contenido no pase por detrás.
///
/// No mueve nada: el contenido arranca donde estaba y el fondo de la pantalla
/// sigue viéndose detrás de la barra; sólo se corta lo que sube al scrollear.
class StatusBarClip extends StatelessWidget {
  const StatusBarClip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: _BelowTopClipper(MediaQuery.viewPaddingOf(context).top),
      child: child,
    );
  }
}

class _BelowTopClipper extends CustomClipper<Rect> {
  const _BelowTopClipper(this.top);

  final double top;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0.0, top.clamp(0.0, size.height), size.width, size.height);

  @override
  bool shouldReclip(_BelowTopClipper oldClipper) => oldClipper.top != top;
}
