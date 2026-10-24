import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/shared_components/floating_navbar_inset.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_navbar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_navbar_model.dart';

class DOVIACLIENTNavbarWidget extends StatefulWidget {
  const DOVIACLIENTNavbarWidget({
    super.key,
    this.activeTab,
    this.tutorialKeys,
  });

  /// Llaves opcionales por ítem ('propiedades', 'visitas', 'doviaHome',
  /// 'ofertas', 'favoritos') para que el tutorial pueda señalarlos.
  final Map<String, GlobalKey>? tutorialKeys;

  /// Pass the route name of the current page so the matching icon is highlighted.
  /// E.g. DOVIACLIENTMisVisitasWidget.routeName
  final String? activeTab;

  @override
  State<DOVIACLIENTNavbarWidget> createState() =>
      _DOVIACLIENTNavbarWidgetState();
}

class _DOVIACLIENTNavbarWidgetState extends State<DOVIACLIENTNavbarWidget> {
  late DOVIACLIENTNavbarModel _model;

  /// Alto total: la barra más lo que el botón central sobresale por arriba.
  static const double _barHeight = 62.0;
  static const double _totalHeight = 84.0;

  /// Hueco del botón central entre el segundo y el tercer ítem.
  static const double _centerGap = 72.0;

  /// Lo que tarda la curva en llegar a la sección nueva. Es fijo: si la
  /// sección está más lejos, la curva va más rápido.
  static const Duration _slideDuration = Duration(milliseconds: 350);

  /// Secciones con curva, en el orden en que aparecen en la barra.
  static final List<String> _tabRoutes = [
    DOVIACLIENTMisPropiedadesWidget.routeName,
    DOVIACLIENTMisVisitasWidget.routeName,
    DOVIACLIENTMisOfertasWidget.routeName,
    DOVIACLIENTMisFavoritosWidget.routeName,
  ];

  /// Cada pantalla tiene su propia navbar. La que navega deja anotada su
  /// sección, y la de la pantalla nueva desliza la curva desde ahí.
  static int? _pendingSlideFrom;

  /// Desde dónde arranca la curva de esta navbar.
  late final int? _slideFrom;

  int? get _activeIndex {
    final i = _tabRoutes.indexOf(widget.activeTab ?? '');
    return i < 0 ? null : i;
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTNavbarModel());
    _slideFrom = _pendingSlideFrom;
    _pendingSlideFrom = null;

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  ColorFilter? _activeFilter(BuildContext context) => ColorFilter.mode(
        FlutterFlowTheme.of(context).primary,
        BlendMode.srcIn,
      );

  bool _isActive(String routeName) => widget.activeTab == routeName;

  /// Las secciones que el visitante no puede abrir muestran el aviso de
  /// registro en lugar de navegar.
  Future<void> _openRestricted(String routeName) async {
    if (FFAppState().UserRole != 'VISITOR') {
      final isTab = _tabRoutes.contains(routeName);
      _pendingSlideFrom = isTab ? _activeIndex : null;
      // Entre secciones la pantalla cambia sin animación: lo único que se
      // mueve es la curva, como en una barra de pestañas fija.
      context.pushNamed(
        routeName,
        extra: isTab
            ? <String, dynamic>{
                kTransitionInfoKey: const TransitionInfo(
                  hasTransition: true,
                  duration: Duration.zero,
                ),
              }
            : null,
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const VisitorRestrictionPopupWidget(),
        );
      },
    );
  }

  Widget _navItem({
    required String asset,
    required String label,
    required String routeName,
    required Future<void> Function() onTap,
    double iconSize = 24.0,
    Key? itemKey,
  }) {
    final active = _isActive(routeName);
    return Expanded(
      child: InkWell(
        key: itemKey,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Caja fija de 24 para que los textos queden alineados aunque
            // el ícono sea más chico.
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Center(
                child: SvgPicture.asset(
                  asset,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  colorFilter: active ? _activeFilter(context) : null,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.publicSans(
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                    color: const Color(0xFF00444B),
                    fontSize: 10.0,
                    letterSpacing: 0.0,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            const SizedBox(height: 3.0),
            // Hueco para la curva de la sección abierta, que se dibuja
            // aparte (ver _activeIndicator) para poder deslizarse.
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  /// La curva que marca la sección abierta. Es una sola para toda la barra:
  /// al cambiar de sección se desliza desde la anterior, y si no se viene de
  /// otra sección aparece directamente en su lugar.
  Widget _activeIndicator(double rowWidth) {
    final target = _activeIndex;
    if (target == null) return const SizedBox.shrink();
    final itemWidth = (rowWidth - _centerGap) / _tabRoutes.length;
    double centerOf(int i) =>
        itemWidth * i + itemWidth / 2 + (i >= 2 ? _centerGap : 0.0);
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

  /// Botón central: destaca por tamaño, color y por sobresalir de la barra.
  Widget _centerButton() {
    return InkWell(
      key: widget.tutorialKeys?['doviaHome'],
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await _openRestricted(DHCLIENTHomepageWidget.routeName);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            // Degradé y sombra más marcada: se distingue del
            // resto de la barra en vez de ser un círculo verde plano.
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A8A8D), Color(0xFF00444B)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 14.0,
                  color: Color(0x5500444B),
                  offset: Offset(0.0, 5.0),
                )
              ],
            ),
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: SvgPicture.asset(
              'assets/images/tools-white.svg',
              width: 26.0,
              height: 26.0,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Dovia Home',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: const Color(0xFF00444B),
                  fontSize: 10.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Como en Dovia Home: en el inicio, que no usa SafeArea abajo, la barra
    // flota sobre el contenido (ver FloatingNavbarInset).
    return FloatingNavbarInset(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: _totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Container(
                width: double.infinity,
                height: _barHeight,
                // Separada de los bordes: flota, y sus esquinas no quedan
                // junto a las de la pantalla, que tienen otra curva.
                margin: const EdgeInsets.symmetric(
                    horizontal: kFloatingNavbarSideMargin),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(kFloatingNavbarRadius),
                  boxShadow: kFloatingNavbarShadow,
                ),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                  // Los ítems van pegados abajo: la curva del activo marca el
                  // borde inferior de la barra.
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      children: [
                        Positioned.fill(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _navItem(
                                asset: 'assets/images/IconoCasaLLave.svg',
                                label: 'Propiedades',
                                itemKey: widget.tutorialKeys?['propiedades'],
                                routeName:
                                    DOVIACLIENTMisPropiedadesWidget.routeName,
                                onTap: () => _openRestricted(
                                    DOVIACLIENTMisPropiedadesWidget.routeName),
                              ),
                              _navItem(
                                asset: 'assets/images/IconoCalendario.svg',
                                label: 'Visitas',
                                itemKey: widget.tutorialKeys?['visitas'],
                                routeName:
                                    DOVIACLIENTMisVisitasWidget.routeName,
                                // El invitado ve el aviso de registro en vez de entrar.
                                onTap: () => _openRestricted(
                                    DOVIACLIENTMisVisitasWidget.routeName),
                              ),
                              // Hueco para el botón central, que va por encima.
                              const SizedBox(width: _centerGap),
                              _navItem(
                                asset:
                                    'assets/images/IconoOfertasNegociacion.svg',
                                label: 'Ofertas',
                                itemKey: widget.tutorialKeys?['ofertas'],
                                routeName:
                                    DOVIACLIENTMisOfertasWidget.routeName,
                                onTap: () => _openRestricted(
                                    DOVIACLIENTMisOfertasWidget.routeName),
                              ),
                              _navItem(
                                asset: 'assets/images/IconoCorazon.svg',
                                label: 'Favoritos',
                                itemKey: widget.tutorialKeys?['favoritos'],
                                iconSize: 20.0,
                                routeName:
                                    DOVIACLIENTMisFavoritosWidget.routeName,
                                // El invitado ve el aviso de registro en vez de entrar.
                                onTap: () => _openRestricted(
                                    DOVIACLIENTMisFavoritosWidget.routeName),
                              ),
                            ],
                          ),
                        ),
                        _activeIndicator(constraints.maxWidth),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, -1.0),
              child: _centerButton(),
            ),
          ],
        ),
      ),
    );
  }
}
