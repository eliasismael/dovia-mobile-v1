import 'package:flutter/material.dart';

/// Suaviza el borde de un carrusel horizontal por donde las tarjetas se van
/// de la vista: un velo gris claro que se desvanece hacia adentro. Así no
/// quedan cortadas en seco y el scroll se siente más suave.
///
/// Sólo aparece del lado contrario al último scroll: al avanzar, el izquierdo
/// (por donde salen las tarjetas); al volver, el derecho. Antes de mover el
/// carrusel no hay velo.
class HorizontalFadeEdges extends StatefulWidget {
  const HorizontalFadeEdges({
    super.key,
    required this.child,
    this.fadeWidth = 36.0,
  });

  /// Un scroll horizontal (Ej: SingleChildScrollView o ListView).
  final Widget child;
  final double fadeWidth;

  /// Gris claro del velo, apenas opaco en el borde.
  static const Color _veil = Color(0xB3F2F4F4);

  @override
  State<HorizontalFadeEdges> createState() => _HorizontalFadeEdgesState();
}

class _HorizontalFadeEdgesState extends State<HorizontalFadeEdges> {
  bool _fadeStart = false;
  bool _fadeEnd = false;

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.horizontal) return false;
    var fadeStart = _fadeStart;
    var fadeEnd = _fadeEnd;
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0.0;
      if (delta > 0) {
        fadeStart = true;
        fadeEnd = false;
      } else if (delta < 0) {
        fadeStart = false;
        fadeEnd = true;
      }
    }
    // En los extremos no hay nada que se esté yendo por ese lado.
    if (metrics.pixels <= metrics.minScrollExtent + 1) fadeStart = false;
    if (metrics.pixels >= metrics.maxScrollExtent - 1) fadeEnd = false;
    if (fadeStart != _fadeStart || fadeEnd != _fadeEnd) {
      setState(() {
        _fadeStart = fadeStart;
        _fadeEnd = fadeEnd;
      });
    }
    return false;
  }

  Widget _veil({required bool visible, required bool start}) {
    return Positioned(
      top: 0.0,
      bottom: 0.0,
      left: start ? 0.0 : null,
      right: start ? null : 0.0,
      width: widget.fadeWidth,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: start ? Alignment.centerLeft : Alignment.centerRight,
                end: start ? Alignment.centerRight : Alignment.centerLeft,
                colors: [
                  HorizontalFadeEdges._veil,
                  HorizontalFadeEdges._veil.withAlpha(0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: widget.child,
        ),
        _veil(visible: _fadeStart, start: true),
        _veil(visible: _fadeEnd, start: false),
      ],
    );
  }
}
