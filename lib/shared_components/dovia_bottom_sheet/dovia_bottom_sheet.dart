import 'package:flutter/material.dart';

/// Abre [child] como hoja inferior de Dovia: fondo oscurecido, entrada suave
/// desde abajo y, al cerrarse, sube despacio un momento y después cae de
/// golpe. [child] se dibuja pegado al borde inferior y sube con el teclado.
Future<T?> showDoviaBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Cerrar',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 520),
    pageBuilder: (ctx, _, __) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(color: Colors.transparent, child: child),
      ),
    ),
    transitionBuilder: (ctx, animation, _, child) {
      final closing = animation.status == AnimationStatus.reverse;
      final Animation<Offset> offset = closing
          ? TweenSequence<Offset>([
              // Tramo final del cierre: cae de golpe hasta salir.
              TweenSequenceItem(
                tween: Tween(
                        begin: const Offset(0, 1), end: const Offset(0, -0.05))
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
                weight: 55,
              ),
              // Primer tramo del cierre: sube despacio un momento.
              TweenSequenceItem(
                tween: Tween(begin: const Offset(0, -0.05), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeIn)),
                weight: 45,
              ),
            ]).animate(animation)
          : Tween(begin: const Offset(0, 1), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic))
              .animate(animation);
      return SlideTransition(position: offset, child: child);
    },
  );
}
