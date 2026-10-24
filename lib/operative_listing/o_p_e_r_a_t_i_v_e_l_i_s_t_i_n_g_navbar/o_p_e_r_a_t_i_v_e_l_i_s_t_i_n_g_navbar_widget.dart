import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/shared_components/floating_navbar_inset.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_model.dart';

/// Una sección de la barra: sus rutas cuentan como ella para marcarla.
class _Tab {
  const _Tab(this.label, this.asset, this.route, this.routeNames);

  final String label;
  final String asset;
  final String route;
  final List<String> routeNames;
}

/// Barra de abajo del Operative Lister, con el mismo diseño que la del cliente:
/// flota sobre el contenido y la curva de la sección abierta se desliza al
/// cambiar de sección. Avisos y ajustes están en el header.
class OPERATIVELISTINGNavbarWidget extends StatefulWidget {
  const OPERATIVELISTINGNavbarWidget({super.key});

  @override
  State<OPERATIVELISTINGNavbarWidget> createState() => _OPERATIVELISTINGNavbarWidgetState();
}

class _OPERATIVELISTINGNavbarWidgetState extends State<OPERATIVELISTINGNavbarWidget> {
  late OPERATIVELISTINGNavbarModel _model;

  static const double _barHeight = 62.0;

  /// Lo que tarda la curva en llegar a la sección nueva, sin importar la
  /// distancia.
  static const Duration _slideDuration = Duration(milliseconds: 350);

  static final List<_Tab> _tabs = [
    _Tab('Inicio', 'assets/images/DH_icono-navbar-home.svg',
        OPERATIVELISTINGHomeWidget.routeName,
        [OPERATIVELISTINGHomeWidget.routeName]),
    _Tab('Agenda', 'assets/images/IconoCalendario.svg',
        OPERATIVELISTINGAgendaWidget.routeName, [
      OPERATIVELISTINGAgendaWidget.routeName,
      OPERATIVELISTINGPrimeraVisitaWidget.routeName,
    ]),
    _Tab('Checklist', 'assets/images/clipboard-check.svg',
        OPERATIVELISTINGChecklistWidget.routeName, [
      OPERATIVELISTINGChecklistWidget.routeName,
      OPERATIVELISTINGChecklistFormWidget.routeName,
    ]),
  ];

  /// Cada pantalla tiene su propia barra. La que navega deja anotada su
  /// sección, y la de la pantalla nueva desliza la curva desde ahí.
  static int? _pendingSlideFrom;

  late final int? _slideFrom;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGNavbarModel());
    _slideFrom = _pendingSlideFrom;
    _pendingSlideFrom = null;

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  int? _activeIndex(BuildContext context) {
    String? route;
    try {
      route = GoRouterState.of(context).name;
    } catch (_) {
      return null;
    }
    final i = _tabs.indexWhere((t) => t.routeNames.contains(route));
    return i < 0 ? null : i;
  }

  /// Entre secciones la pantalla cambia sin animación: lo único que se mueve
  /// es la curva. El inicio vacía la pila; el resto se apila.
  void _open(int index, int? from) {
    _pendingSlideFrom = from;
    final extra = <String, dynamic>{
      kTransitionInfoKey: const TransitionInfo(
        hasTransition: true,
        duration: Duration.zero,
      ),
    };
    final route = _tabs[index].route;
    if (index == 0) {
      context.goNamed(route, extra: extra);
    } else {
      context.pushNamed(route, extra: extra);
    }
  }

  Widget _item(int index, bool active, int? current) {
    final tab = _tabs[index];
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => _open(index, current),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Center(
                child: SvgPicture.asset(
                  tab.asset,
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.contain,
                  colorFilter: active
                      ? ColorFilter.mode(
                          FlutterFlowTheme.of(context).primary,
                          BlendMode.srcIn,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              tab.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.publicSans(
                color: const Color(0xFF00444B),
                fontSize: 10.0,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 3.0),
            // Hueco para la curva, que se dibuja aparte para poder
            // deslizarse.
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _indicator(double rowWidth, int target) {
    final itemWidth = rowWidth / _tabs.length;
    double centerOf(int i) => itemWidth * i + itemWidth / 2;
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: centerOf(_slideFrom ?? target),
        end: centerOf(target),
      ),
      duration: _slideDuration,
      curve: Curves.easeInOutCubic,
      builder: (context, center, child) => Positioned(
        left: center - 22.0,
        bottom: 0.0,
        child: child!,
      ),
      child: SvgPicture.asset(
        'assets/images/navbar-active-indicator.svg',
        width: 44.0,
        height: 8.0,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _activeIndex(context);
    return FloatingNavbarInset(
      child: Container(
        width: double.infinity,
        height: _barHeight,
        // Separada de los bordes, como la del cliente.
        margin:
            const EdgeInsets.symmetric(horizontal: kFloatingNavbarSideMargin),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(kFloatingNavbarRadius),
          boxShadow: kFloatingNavbarShadow,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        _item(i, i == current, current),
                    ],
                  ),
                ),
                if (current != null) _indicator(constraints.maxWidth, current),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
