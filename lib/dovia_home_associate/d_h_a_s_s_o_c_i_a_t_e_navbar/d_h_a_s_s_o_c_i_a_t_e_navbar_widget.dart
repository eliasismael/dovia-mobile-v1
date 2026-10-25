import 'dart:async';

import '/dovia_home_associate/associate_current_job.dart';
import '/dovia_home_associate/associate_nav.dart';
import '/dovia_home_associate/associate_role.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/shared_components/floating_navbar_inset.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_navbar_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_navbar_model.dart';

/// Una sección de la barra: sus rutas cuentan como ella para marcarla.
class _Tab {
  const _Tab(this.label, this.asset, this.routeNames, this.open,
      {this.tinted = false});

  final String label;
  final String asset;
  final List<String> routeNames;
  final void Function(BuildContext context, Map<String, dynamic> extra) open;

  /// Íconos que vienen en gris o en blanco: se tiñen del verde de los demás.
  final bool tinted;
}

/// Barra de abajo del Dovia Home Associate, con el mismo diseño que la del
/// cliente: flota sobre el contenido y la curva de la sección abierta se
/// desliza al cambiar de sección. Avisos y ajustes están en el header, y
/// Servicios y Próximos trabajos, que estaban en el header, pasaron acá.
///
/// **Depende del rol**: el independiente ve Próximos trabajos y la empresa,
/// Cotizaciones (sus endpoints le responderían 403 al independiente). "En
/// curso" sólo aparece mientras hay un trabajo que ya avisó su llegada.
class DHASSOCIATENavbarWidget extends StatefulWidget {
  const DHASSOCIATENavbarWidget({super.key});

  @override
  State<DHASSOCIATENavbarWidget> createState() =>
      _DHASSOCIATENavbarWidgetState();
}

class _DHASSOCIATENavbarWidgetState extends State<DHASSOCIATENavbarWidget> {
  late DHASSOCIATENavbarModel _model;

  static const double _barHeight = 62.0;

  /// Lo que tarda la curva en llegar a la sección nueva, sin importar la
  /// distancia.
  static const Duration _slideDuration = Duration(milliseconds: 350);

  /// Cada pantalla tiene su propia barra. La que navega deja anotada su
  /// sección, y la de la pantalla nueva desliza la curva desde ahí.
  static int? _pendingSlideFrom;

  late final int? _slideFrom;

  /// Trabajo en curso (ya avisó su llegada): habilita la sección "En curso".
  Map<String, dynamic>? _currentJob;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATENavbarModel());
    _slideFrom = _pendingSlideFrom;
    _pendingSlideFrom = null;
    _currentJob = AssociateCurrentJob.cached;
    AssociateCurrentJob.notifier.addListener(_onCurrentJob);
    _loadCurrentJob();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Si el pedido falla o se descarta (Ej: al abrir la app, mientras se
  /// restaura la sesión), se reintenta: "En curso" tiene que estar desde el
  /// principio, no recién al cambiar de pantalla.
  Future<void> _loadCurrentJob({int retries = 2}) async {
    final job = await AssociateCurrentJob.load();
    if (!mounted) return;
    safeSetState(() => _currentJob = job);
    if (!AssociateCurrentJob.isFresh && retries > 0) {
      _retry = Timer(const Duration(seconds: 2),
          () => _loadCurrentJob(retries: retries - 1));
    }
  }

  Timer? _retry;

  void _onCurrentJob() {
    if (mounted) safeSetState(() => _currentJob = AssociateCurrentJob.cached);
  }

  @override
  void dispose() {
    _retry?.cancel();
    AssociateCurrentJob.notifier.removeListener(_onCurrentJob);
    _model.maybeDispose();

    super.dispose();
  }

  List<_Tab> get _tabs {
    final job = _currentJob;
    return [
      _Tab(
        'Inicio',
        'assets/images/DH_icono-navbar-home.svg',
        [
          DHASSOCIATEEmpresaHomePageWidget.routeName,
          DHASSOCIATEHomePageWidget.routeName,
        ],
        // Vuelve al panel limpiando la pila, igual que la D del header.
        (context, extra) =>
            context.goNamed(associateHomeRouteName(), extra: extra),
      ),
      if (isHomeAssociateCompany())
        _Tab(
          'Cotizaciones',
          'assets/images/page-edit.svg',
          [
            DHASSOCIATECotizacionesWidget.routeName,
            DHASSOCIATECotizacionWidget.routeName,
            DHASSOCIATEPropuestaEnviadaWidget.routeName,
          ],
          (context, extra) => context
              .pushNamed(DHASSOCIATECotizacionesWidget.routeName, extra: extra),
          tinted: true,
        )
      else
        _Tab(
          'Trabajos',
          'assets/images/IconoDiagnosticos.svg',
          [
            DHASSOCIATEProximosTrabajosWidget.routeName,
            DHASSOCIATETuTrabajoWidget.routeName,
            DHASSOCIATETrabajoRealizadoWidget.routeName,
          ],
          (context, extra) => context.pushNamed(
              DHASSOCIATEProximosTrabajosWidget.routeName,
              extra: extra),
          tinted: true,
        ),
      // Acceso directo al trabajo que se está ejecutando.
      if (job != null)
        _Tab(
          'En curso',
          'assets/images/tools-white.svg',
          [
            DHASSOCIATETrabajoARealizarWidget.routeName,
            DHASSOCIATETrabajoFinalizadoWidget.routeName,
            DHASSOCIATEFueraDeAlcanceWidget.routeName,
          ],
          (context, extra) {
            DHASSOCIATETrabajoARealizarWidget.requestData = job;
            context.pushNamed(DHASSOCIATETrabajoARealizarWidget.routeName,
                queryParameters: associateRouteParams(request: job),
                extra: extra);
          },
          tinted: true,
        ),
      _Tab(
        'Servicios',
        'assets/images/IconoServiciosAsignados.svg',
        [DHASSOCIATEServiciosWidget.routeName],
        (context, extra) => context
            .pushNamed(DHASSOCIATEServiciosWidget.routeName, extra: extra),
        tinted: true,
      ),
    ];
  }

  int? _activeIndex(BuildContext context, List<_Tab> tabs) {
    String? route;
    try {
      route = GoRouterState.of(context).name;
    } catch (_) {
      return null;
    }
    final i = tabs.indexWhere((t) => t.routeNames.contains(route));
    return i < 0 ? null : i;
  }

  /// Entre secciones la pantalla cambia sin animación: lo único que se mueve
  /// es la curva. El inicio vacía la pila; el resto se apila.
  void _open(_Tab tab, int? from) {
    _pendingSlideFrom = from;
    tab.open(context, <String, dynamic>{
      kTransitionInfoKey: const TransitionInfo(
        hasTransition: true,
        duration: Duration.zero,
      ),
    });
  }

  Widget _item(_Tab tab, bool active, int? current) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => _open(tab, current),
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
                      : tab.tinted
                          ? const ColorFilter.mode(
                              Color(0xFF00444B), BlendMode.srcIn)
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

  Widget _indicator(double rowWidth, int count, int target) {
    final itemWidth = rowWidth / count;
    double centerOf(int i) => itemWidth * i + itemWidth / 2;
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: centerOf((_slideFrom ?? count) < count ? _slideFrom! : target),
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
    final tabs = _tabs;
    final current = _activeIndex(context, tabs);
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
                      for (var i = 0; i < tabs.length; i++)
                        _item(tabs[i], i == current, current),
                    ],
                  ),
                ),
                if (current != null)
                  _indicator(constraints.maxWidth, tabs.length, current),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
