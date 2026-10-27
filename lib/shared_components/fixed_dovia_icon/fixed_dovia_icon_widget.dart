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
/// borde más cercano. Mientras se arrastra aparece una cruz abajo: soltarlo
/// ahí lo oculta hasta que la app se vuelva a abrir.
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

  static const double _closeTargetSize = 60.0;

  /// Distancia (entre centros) a la que la cruz atrapa al ícono.
  static const double _closeRadius = 70.0;

  /// Dónde se dibujó por última vez (coordenadas de pantalla). Lo usa el
  /// tutorial para señalarlo.
  static Rect? lastRect;

  static const String _sideKey = 'dovia_icon_right';
  static const String _topKey = 'dovia_icon_top';

  static final ValueNotifier<_DoviaIconPosition?> _saved =
      ValueNotifier<_DoviaIconPosition?>(null);
  static bool _loaded = false;

  /// El usuario lo soltó sobre la cruz. Vive solo en memoria: al volver a
  /// abrir la app el ícono está de nuevo.
  static final ValueNotifier<bool> _dismissed = ValueNotifier<bool>(false);

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
    FixedDoviaIconWidget._dismissed.addListener(_onSavedChanged);
    _portal.show();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAnchor());
  }

  @override
  void dispose() {
    FixedDoviaIconWidget._saved.removeListener(_onSavedChanged);
    FixedDoviaIconWidget._dismissed.removeListener(_onSavedChanged);
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

  /// Centro de la cruz, abajo en el medio de la pantalla.
  Offset _closeCenter(Size screen) => Offset(
        screen.width / 2,
        screen.height - MediaQuery.paddingOf(context).bottom - 80.0,
      );

  /// Si el ícono, con su esquina en [position], está sobre la cruz.
  bool _overClose(Offset position, Size screen) {
    const half = FixedDoviaIconWidget.size / 2;
    final center = position + const Offset(half, half);
    return (center - _closeCenter(screen)).distance <=
        FixedDoviaIconWidget._closeRadius;
  }

  double _leftFor(bool right, Size screen) => right
      ? screen.width -
          FixedDoviaIconWidget.sideMargin -
          FixedDoviaIconWidget.size
      : FixedDoviaIconWidget.sideMargin;

  void _openSupport() async {
    await showDoviaSupport(context).then((value) => safeSetState(() {}));
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

  Widget _buildCloseTarget(Size screen, {required bool armed}) {
    const size = FixedDoviaIconWidget._closeTargetSize;
    final center = _closeCenter(screen);
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: IgnorePointer(
        child: AnimatedScale(
          scale: armed ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Color(armed ? 0xE6000000 : 0x99000000),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.0),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 28.0),
          ),
        ),
      ),
    );
  }

  Widget _buildFloating(BuildContext overlayContext) {
    final anchor = _anchor;
    // Hasta medir el lugar de la pantalla no se sabe dónde dibujarlo.
    if (anchor == null || FixedDoviaIconWidget._dismissed.value) {
      FixedDoviaIconWidget.lastRect = null;
      return const SizedBox.shrink();
    }

    final screen = MediaQuery.sizeOf(context);
    final saved = FixedDoviaIconWidget._saved.value;
    final maxTop = _maxTop(screen);
    final minTop = _minTop().clamp(0.0, maxTop);

    final dragging = _dragPosition != null;
    final armed = dragging && _overClose(_dragPosition!, screen);
    final double left;
    final double top;
    if (armed) {
      // Sobre la cruz el ícono se centra en ella, como atrapado.
      const half = FixedDoviaIconWidget.size / 2;
      final center = _closeCenter(screen);
      left = center.dx - half;
      top = center.dy - half;
    } else if (dragging) {
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
    final bubble = AnimatedPositioned(
      duration: dragging && !armed
          ? Duration.zero
          : const Duration(milliseconds: 280),
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
          // Mientras se arrastra puede bajar hasta la cruz; al soltarlo
          // vuelve a quedar arriba del navbar.
          final bottom = screen.height -
              MediaQuery.paddingOf(context).bottom -
              FixedDoviaIconWidget.size;
          final position = Offset(
            next.dx.clamp(0.0, screen.width - FixedDoviaIconWidget.size),
            next.dy.clamp(minTop, bottom),
          );
          final wasArmed = _overClose(_dragPosition!, screen);
          if (_overClose(position, screen) != wasArmed) {
            HapticFeedback.mediumImpact();
          }
          setState(() => _dragPosition = position);
        },
        onPanEnd: (_) => _drop(screen, minTop, maxTop),
        onPanCancel: () {
          if (_dragPosition != null) _drop(screen, minTop, maxTop);
        },
        child: _buildBubble(lifted: dragging),
      ),
    );
    return Positioned.fill(
      child: Stack(
        children: [
          if (dragging) _buildCloseTarget(screen, armed: armed),
          bubble,
        ],
      ),
    );
  }

  void _drop(Size screen, double minTop, double maxTop) {
    final position = _dragPosition;
    if (position == null) return;
    if (_overClose(position, screen)) {
      setState(() => _dragPosition = null);
      FixedDoviaIconWidget._dismissed.value = true;
      return;
    }
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
