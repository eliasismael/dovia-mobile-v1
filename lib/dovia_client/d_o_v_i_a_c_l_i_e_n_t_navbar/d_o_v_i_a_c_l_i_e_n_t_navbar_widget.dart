import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_navbar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_navbar_model.dart';

class DOVIACLIENTNavbarWidget extends StatefulWidget {
  const DOVIACLIENTNavbarWidget({
    super.key,
    this.activeTab,
  });

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
  static const double _barHeight = 70.0;
  static const double _totalHeight = 92.0;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTNavbarModel());

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
            SvgPicture.asset(
              asset,
              width: 24.0,
              height: 24.0,
              fit: BoxFit.contain,
              colorFilter: active ? _activeFilter(context) : null,
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

  /// Botón central: destaca por tamaño, color y por sobresalir de la barra.
  Widget _centerButton() {
    return InkWell(
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
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10.0,
                  color: Color(0x33007376),
                  offset: Offset(0.0, 4.0),
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

    return SizedBox(
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
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
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
                      onTap: () async {
                        context
                            .pushNamed(DOVIACLIENTMisVisitasWidget.routeName);
                      },
                    ),
                    // Hueco para el botón central, que va por encima.
                    const SizedBox(width: 72.0),
                    _navItem(
                      asset: 'assets/images/IconoMisOfertas.svg',
                      label: 'Ofertas',
                      routeName: DOVIACLIENTMisOfertasWidget.routeName,
                      onTap: () => _openRestricted(
                          DOVIACLIENTMisOfertasWidget.routeName),
                    ),
                    _navItem(
                      asset: 'assets/images/IconoCorazon.svg',
                      label: 'Favorito',
                      routeName: DOVIACLIENTMisFavoritosWidget.routeName,
                      onTap: () async {
                        context
                            .pushNamed(DOVIACLIENTMisFavoritosWidget.routeName);
                      },
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
    );
  }
}
