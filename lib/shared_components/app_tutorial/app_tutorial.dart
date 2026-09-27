import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un paso del tutorial. Sin [target] el cartel va centrado (bienvenida).
class TutorialStep {
  const TutorialStep({
    required this.title,
    required this.text,
    this.target,
  });

  final String title;
  final String text;

  /// Devuelve el rectángulo (en coordenadas de pantalla) de lo que se
  /// describe, o null si no está en pantalla.
  final Rect? Function()? target;
}

/// Rectángulo en pantalla del widget que tiene [key].
Rect? rectOfKey(GlobalKey key) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Tutorial guiado de pantalla completa: oscurece la app, bloquea los toques
/// y va señalando cada parte con un cartel verde con flecha. Siempre muestra
/// el número de paso, "Omitir" y "Siguiente".
class AppTutorial {
  static const _doneKeyPrefix = 'app_tutorial_done_';

  /// Si el tutorial [id] ya se vio (o se omitió) para [userId] en este
  /// teléfono.
  static Future<bool> isDone(String id, String userId) async =>
      (await SharedPreferences.getInstance())
          .getBool('$_doneKeyPrefix${id}_$userId') ??
      false;

  static Future<void> markDone(String id, String userId) async =>
      (await SharedPreferences.getInstance())
          .setBool('$_doneKeyPrefix${id}_$userId', true);

  static Future<void> show(BuildContext context, List<TutorialStep> steps) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => _TutorialOverlay(steps: steps),
      transitionBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}

class _TutorialOverlay extends StatefulWidget {
  const _TutorialOverlay({required this.steps});

  final List<TutorialStep> steps;

  @override
  State<_TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<_TutorialOverlay> {
  static const Color _green = Color(0xF2007376);
  static const double _arrow = 10.0;
  static const double _gap = 10.0;

  int _index = 0;

  TutorialStep get _step => widget.steps[_index];
  bool get _isLast => _index == widget.steps.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    // El resaltado no invade las barras del sistema (estado y botones de
    // Android): se recorta al área visible de la app.
    final raw = _step.target?.call()?.inflate(6.0);
    final target = raw == null
        ? null
        : Rect.fromLTRB(
            raw.left.clamp(4.0, screen.width),
            raw.top.clamp(padding.top, screen.height),
            raw.right.clamp(0.0, screen.width - 4.0),
            raw.bottom.clamp(0.0, screen.height - padding.bottom),
          );

    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Fondo oscuro con un hueco sobre lo que se describe. Absorbe
            // todos los toques: la app de atrás no responde.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                // Sin nada que señalar (bienvenida) no hay hueco; el
                // TweenAnimationBuilder no acepta un final null.
                child: target == null
                    ? CustomPaint(painter: _DimPainter())
                    : TweenAnimationBuilder<Rect?>(
                        tween: RectTween(end: target),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        builder: (_, rect, __) =>
                            CustomPaint(painter: _DimPainter(hole: rect)),
                      ),
              ),
            ),
            _buildCard(screen, padding, target),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Size screen, EdgeInsets padding, Rect? target) {
    const side = 16.0;
    final cardWidth = screen.width - side * 2;

    final card = Container(
      width: cardWidth,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x40000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso ${_index + 1} de ${widget.steps.length}',
            style: GoogleFonts.publicSans(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _step.title,
            style: GoogleFonts.publicSans(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _step.text,
            style: GoogleFonts.publicSans(
              color: Colors.white,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  'Omitir tutorial',
                  style: GoogleFonts.publicSans(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF007376),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(
                  _isLast ? 'Finalizar' : 'Siguiente',
                  style: GoogleFonts.publicSans(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Bienvenida: centrado, sin flecha.
    if (target == null) {
      return Center(child: card);
    }

    // Arriba o abajo de lo señalado, según dónde haya más lugar.
    final below = target.center.dy < screen.height / 2;
    final arrowX =
        (target.center.dx - side).clamp(24.0, cardWidth - 24.0).toDouble();
    final arrow = CustomPaint(
      size: const Size(_arrow * 2, _arrow),
      painter: _ArrowPainter(up: below, color: _green),
    );
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (below)
          Padding(
              padding: EdgeInsets.only(left: arrowX - _arrow), child: arrow),
        card,
        if (!below)
          Padding(
              padding: EdgeInsets.only(left: arrowX - _arrow), child: arrow),
      ],
    );

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: side,
      top: below
          ? (target.bottom + _gap).clamp(padding.top + 8, screen.height)
          : null,
      bottom: below
          ? null
          : (screen.height - target.top + _gap)
              .clamp(padding.bottom + 8, screen.height),
      child: column,
    );
  }
}

class _DimPainter extends CustomPainter {
  _DimPainter({this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xB3000000);
    final full = Path()..addRect(Offset.zero & size);
    final h = hole;
    if (h == null) {
      canvas.drawPath(full, paint);
      return;
    }
    final cut = Path()
      ..addRRect(RRect.fromRectAndRadius(h, const Radius.circular(14)));
    canvas.drawPath(Path.combine(PathOperation.difference, full, cut), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(h, const Radius.circular(14)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.hole != hole;
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.up, required this.color});

  final bool up;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.up != up || old.color != color;
}
