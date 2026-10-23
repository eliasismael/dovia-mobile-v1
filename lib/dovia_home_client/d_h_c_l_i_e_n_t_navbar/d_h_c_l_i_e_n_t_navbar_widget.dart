import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/shared_components/floating_navbar_inset.dart';
import 'd_h_c_l_i_e_n_t_navbar_model.dart';
export 'd_h_c_l_i_e_n_t_navbar_model.dart';

/// La misma barra que el resto de la app. Lo único propio de Dovia Home es el
/// botón del medio, que acá es el camino de vuelta al Dovia de siempre.
class DHCLIENTNavbarWidget extends StatefulWidget {
  const DHCLIENTNavbarWidget({
    super.key,
    this.activeTab,
  });

  /// Pass the route name of the current page so the matching icon is highlighted.
  /// E.g. DOVIACLIENTMisVisitasWidget.routeName
  final String? activeTab;

  @override
  State<DHCLIENTNavbarWidget> createState() => _DHCLIENTNavbarWidgetState();
}

class _DHCLIENTNavbarWidgetState extends State<DHCLIENTNavbarWidget> {
  late DHCLIENTNavbarModel _model;

  /// Alto total: la barra más lo que el botón central sobresale por arriba.
  // Mismo alto que la barra de Dovia común.
  static const double _barHeight = 62.0;
  static const double _totalHeight = 84.0;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTNavbarModel());

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
      context.pushNamed(routeName);
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
  }) {
    final active = _isActive(routeName);
    return Expanded(
      child: InkWell(
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
            // La curva del diseño marca la seccion abierta. El hueco se
            // reserva siempre para que las etiquetas no se muevan.
            SizedBox(
              height: 8.0,
              child: active
                  ? SvgPicture.asset(
                      'assets/images/navbar-active-indicator.svg',
                      width: 44.0,
                      height: 8.0,
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Dentro de Dovia Home el botón central es el camino de vuelta a Dovia.
  Widget _centerButton() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        context.pushNamed(DOVIACLIENTHomePageWidget.routeName);
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
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 28.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Dovia',
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

    // Las pantallas de Dovia Home no usan SafeArea abajo: la barra flota sobre
    // el contenido (ver FloatingNavbarInset).
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
                  boxShadow: kFloatingNavbarShadow,
                  borderRadius: BorderRadius.circular(kFloatingNavbarRadius),
                ),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _navItem(
                        asset: 'assets/images/IconoCasaLLave.svg',
                        label: 'Propiedades',
                        routeName: DOVIACLIENTMisPropiedadesWidget.routeName,
                        onTap: () => _openRestricted(
                            DOVIACLIENTMisPropiedadesWidget.routeName),
                      ),
                      _navItem(
                        asset: 'assets/images/IconoCalendario.svg',
                        label: 'Visitas',
                        routeName: DOVIACLIENTMisVisitasWidget.routeName,
                        // El invitado ve el aviso de registro en vez de entrar.
                        onTap: () => _openRestricted(
                            DOVIACLIENTMisVisitasWidget.routeName),
                      ),
                      // Hueco para el botón central, que va por encima.
                      const SizedBox(width: 72.0),
                      _navItem(
                        asset: 'assets/images/IconoOfertasNegociacion.svg',
                        label: 'Ofertas',
                        routeName: DOVIACLIENTMisOfertasWidget.routeName,
                        onTap: () => _openRestricted(
                            DOVIACLIENTMisOfertasWidget.routeName),
                      ),
                      _navItem(
                        asset: 'assets/images/IconoCorazon.svg',
                        label: 'Favoritos',
                        iconSize: 20.0,
                        routeName: DOVIACLIENTMisFavoritosWidget.routeName,
                        // El invitado ve el aviso de registro en vez de entrar.
                        onTap: () => _openRestricted(
                            DOVIACLIENTMisFavoritosWidget.routeName),
                      ),
                    ],
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
