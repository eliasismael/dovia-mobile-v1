import 'package:flutter/material.dart';

/// Flecha discreta dentro de un círculo claro con sombra suave: la misma de
/// los carruseles del home, para usar en cualquier carrusel de la app.
class CarouselArrowButton extends StatelessWidget {
  const CarouselArrowButton({
    super.key,
    required this.isLeft,
    required this.onTap,
  });

  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 6.0,
              color: Color(0x26000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        child: Icon(
          isLeft ? Icons.chevron_left : Icons.chevron_right,
          color: const Color(0xFF00444B),
          size: 20.0,
        ),
      ),
    );
  }
}
