import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_navbar_model.dart';
export 'd_h_c_l_i_e_n_t_navbar_model.dart';

class DHCLIENTNavbarWidget extends StatefulWidget {
  const DHCLIENTNavbarWidget({super.key});

  @override
  State<DHCLIENTNavbarWidget> createState() => _DHCLIENTNavbarWidgetState();
}

class _DHCLIENTNavbarWidgetState extends State<DHCLIENTNavbarWidget> {
  late DHCLIENTNavbarModel _model;

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
    _model = createModel(context, () => DHCLIENTNavbarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Widget _navItem({
    required String asset,
    required String label,
    required Future<void> Function() onTap,
  }) {
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
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.publicSans(),
                    color: const Color(0xFF00444B),
                    fontSize: 10.0,
                    letterSpacing: 0.0,
                  ),
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
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8.0,
                    color: Color(0x33000000),
                    offset: Offset(0.0, 2.0),
                  )
                ],
                borderRadius: BorderRadius.circular(30.0),
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
                      onTap: () async {
                        context.pushNamed(
                            DOVIACLIENTMisPropiedadesWidget.routeName);
                      },
                    ),
                    _navItem(
                      asset: 'assets/images/IconoCalendario.svg',
                      label: 'Visitas',
                      onTap: () async {
                        context
                            .pushNamed(DOVIACLIENTMisVisitasWidget.routeName);
                      },
                    ),
                    // Hueco para el botón central, que va por encima.
                    const SizedBox(width: 72.0),
                    _navItem(
                      asset: 'assets/images/DH_icono-navbar-notificaciones.svg',
                      label: 'Avisos',
                      onTap: () async {
                        context.pushNamed(
                            DOVIACLIENTNotificacionesWidget.routeName);
                      },
                    ),
                    _navItem(
                      asset: 'assets/images/DH_icono-navbar-ajustes.svg',
                      label: 'Ajustes',
                      onTap: () async {
                        context.pushNamed(DOVIACLIENTAjustesWidget.routeName);
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
