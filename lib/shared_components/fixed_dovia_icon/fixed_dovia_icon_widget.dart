import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fixed_dovia_icon_model.dart';
export 'fixed_dovia_icon_model.dart';

/// Posición que eligió el usuario para el ícono flotante: de qué lado quedó
/// pegado y a qué altura. Es la misma en todas las pantallas y se guarda en
/// el celular.
class _DoviaIconPosition {
  const _DoviaIconPosition({required this.right, required this.top});

  final bool right;
  final double top;
}

/// Ícono flotante de Dovia. Un toque abre el soporte; deslizando el dedo
/// sobre él se arrastra por la pantalla y al soltarlo se pega al
/// borde más cercano.
///
/// Cada pantalla lo sigue ubicando en su lugar de siempre (arriba del
/// navbar): ese lugar queda como posición por defecto y como límite de
/// abajo. El ícono en sí se dibuja en el Overlay para poder moverse por
/// toda la pantalla.
class FixedDoviaIconWidget extends StatefulWidget {
  const FixedDoviaIconWidget({super.key});

  static const double size = 52.0;
  static const double sideMargin = 15.0;

  /// Espacio que se deja arriba para no taparle el header a la pantalla.
  static const double headerSpace = 90.0;

  /// Dónde se dibujó por última vez (coordenadas de pantalla). Lo usa el
  /// tutorial para señalarlo.
  static Rect? lastRect;

  static const String _sideKey = 'dovia_icon_right';
  static const String _topKey = 'dovia_icon_top';

  static final ValueNotifier<_DoviaIconPosition?> _saved =
      ValueNotifier<_DoviaIconPosition?>(null);
  static bool _loaded = false;

  static Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final top = prefs.getDouble(_topKey);
    if (top != null) {
      _saved.value =
          _DoviaIconPosition(right: prefs.getBool(_sideKey) ?? true, top: top);
    }
  }

  static Future<void> _store(_DoviaIconPosition position) async {
    _saved.value = position;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sideKey, position.right);
    await prefs.setDouble(_topKey, position.top);
  }

  @override
  State<FixedDoviaIconWidget> createState() => _FixedDoviaIconWidgetState();
}

class _FixedDoviaIconWidgetState extends State<FixedDoviaIconWidget> {
  late FixedDoviaIconModel _model;

  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();

  /// Lugar donde la pantalla ubica al ícono, en coordenadas del Overlay.
  Offset? _anchor;

  /// Posición mientras se arrastra (esquina superior izquierda).
  Offset? _dragPosition;
  Offset _grabOffset = Offset.zero;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FixedDoviaIconModel());
    FixedDoviaIconWidget._load();
    FixedDoviaIconWidget._saved.addListener(_onSavedChanged);
    _portal.show();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAnchor());
  }

  @override
  void dispose() {
    FixedDoviaIconWidget._saved.removeListener(_onSavedChanged);
    _model.maybeDispose();

    super.dispose();
  }

  void _onSavedChanged() => safeSetState(() {});

  RenderBox? get _overlayBox =>
      Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;

  void _measureAnchor() {
    if (!mounted) return;
    final anchorBox =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox = _overlayBox;
    if (anchorBox == null || overlayBox == null || !anchorBox.hasSize) return;
    final anchor = anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    if (anchor != _anchor) safeSetState(() => _anchor = anchor);
  }

  double _minTop() =>
      MediaQuery.paddingOf(context).top + FixedDoviaIconWidget.headerSpace;

  double _maxTop(Size screen) {
    final anchor = _anchor;
    if (anchor != null) return anchor.dy;
    return screen.height - FixedDoviaIconWidget.size - 100.0;
  }

  double _leftFor(bool right, Size screen) => right
      ? screen.width -
          FixedDoviaIconWidget.sideMargin -
          FixedDoviaIconWidget.size
      : FixedDoviaIconWidget.sideMargin;

  void _openSupport() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: const DoviaSupportWidget(),
        );
      },
    ).then((value) => safeSetState(() {}));
  }

  Widget _buildBubble({required bool lifted}) {
    return AnimatedScale(
      scale: lifted ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Container(
        width: FixedDoviaIconWidget.size,
        height: FixedDoviaIconWidget.size,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: lifted ? 18.0 : 12.0,
              color: Color(lifted ? 0x66000000 : 0x59000000),
              offset: Offset(0.0, lifted ? 7.0 : 4.0),
            ),
          ],
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: SvgPicture.asset(
          'assets/images/D-blanca.svg',
          width: 18.0,
          height: 23.0,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }

  Widget _buildFloating(BuildContext overlayContext) {
    final anchor = _anchor;
    // Hasta medir el lugar de la pantalla no se sabe dónde dibujarlo.
    if (anchor == null) return const SizedBox.shrink();

    final screen = MediaQuery.sizeOf(context);
    final saved = FixedDoviaIconWidget._saved.value;
    final maxTop = _maxTop(screen);
    final minTop = _minTop().clamp(0.0, maxTop);

    final dragging = _dragPosition != null;
    final double left;
    final double top;
    if (dragging) {
      left = _dragPosition!.dx;
      top = _dragPosition!.dy;
    } else if (saved != null) {
      left = _leftFor(saved.right, screen);
      top = saved.top.clamp(minTop, maxTop);
    } else {
      left = anchor.dx;
      top = anchor.dy;
    }

    FixedDoviaIconWidget.lastRect = Rect.fromLTWH(
        left, top, FixedDoviaIconWidget.size, FixedDoviaIconWidget.size);
    return AnimatedPositioned(
      duration: dragging ? Duration.zero : const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _openSupport,
        onPanStart: (details) {
          HapticFeedback.selectionClick();
          _grabOffset = details.localPosition;
          setState(() => _dragPosition = Offset(left, top));
        },
        onPanUpdate: (details) {
          final overlayBox = _overlayBox;
          if (overlayBox == null) return;
          final local = overlayBox.globalToLocal(details.globalPosition);
          final next = local - _grabOffset;
          setState(() => _dragPosition = Offset(
                next.dx.clamp(0.0, screen.width - FixedDoviaIconWidget.size),
                next.dy.clamp(minTop, maxTop),
              ));
        },
        onPanEnd: (_) => _drop(screen, minTop, maxTop),
        onPanCancel: () {
          if (_dragPosition != null) _drop(screen, minTop, maxTop);
        },
        child: _buildBubble(lifted: dragging),
      ),
    );
  }

  void _drop(Size screen, double minTop, double maxTop) {
    final position = _dragPosition;
    if (position == null) return;
    final center = position.dx + FixedDoviaIconWidget.size / 2;
    final right = center >= screen.width / 2;
    final top = position.dy.clamp(minTop, maxTop);
    setState(() => _dragPosition = null);
    FixedDoviaIconWidget._store(_DoviaIconPosition(right: right, top: top));
  }

  @override
  Widget build(BuildContext context) {
    // Si la pantalla cambió de tamaño, se vuelve a medir su lugar.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAnchor());
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildFloating,
      // Reserva el lugar de siempre: sirve de referencia y de límite.
      child: SizedBox(
        key: _anchorKey,
        width: FixedDoviaIconWidget.size,
        height: FixedDoviaIconWidget.size,
      ),
    );
  }
}
