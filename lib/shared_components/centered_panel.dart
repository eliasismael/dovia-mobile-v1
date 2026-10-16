import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Abre [child] centrado (90 % del ancho y 75 % del alto) sobre un fondo
/// oscuro, con un fundido al abrir y al cerrar. Tocar el fondo lo cierra.
///
/// Con el teclado abierto se centra en lo que queda libre y se achica si no
/// entra, para que el campo de texto quede a la vista.
Future<T?> showCenteredPanel<T>(BuildContext context, Widget child) =>
    showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: const Color(0x99000000),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) {
        final media = MediaQuery.of(context);
        final keyboard = media.viewInsets.bottom;
        final free = media.size.height - keyboard - media.padding.top - 16.0;
        return Padding(
          padding: EdgeInsets.only(top: media.padding.top, bottom: keyboard),
          child: Center(
            child: SizedBox(
              width: media.size.width * 0.9,
              height: math.min(media.size.height * 0.75, free),
              child: Material(
                type: MaterialType.transparency,
                child: child,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
