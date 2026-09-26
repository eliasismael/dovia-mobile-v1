import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared_components/navbar_item_indicator/navbar_item_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_model.dart';
export 'l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_model.dart';

class LEGALASSOCAITENavbarWidget extends StatefulWidget {
  const LEGALASSOCAITENavbarWidget({super.key});

  @override
  State<LEGALASSOCAITENavbarWidget> createState() =>
      _LEGALASSOCAITENavbarWidgetState();
}

class _LEGALASSOCAITENavbarWidgetState
    extends State<LEGALASSOCAITENavbarWidget> {
  late LEGALASSOCAITENavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCAITENavbarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: 62.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            NavbarItemIndicator(
              label: 'Inicio',
              routeNames: [LegalAssociateHomeWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.goNamed(LegalAssociateHomeWidget.routeName);
                },
                child: SvgPicture.asset(
                  'assets/images/DH_icono-navbar-home.svg',
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Procesos',
              // El detalle de un trámite también cuenta como Procesos.
              routeNames: [
                LEGALASSOCIATEProcesosWidget.routeName,
                LEGALASSOCIATEProcesos2Widget.routeName,
              ],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(LEGALASSOCIATEProcesosWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/apple-wallet.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Notificaciones',
              routeNames: [LEGALASSOCIATENotificationsWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context
                      .pushNamed(LEGALASSOCIATENotificationsWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SvgPicture.asset(
                    'assets/images/DH_icono-navbar-notificaciones.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Ajustes',
              routeNames: [LEGALASSOCIATEAjustesWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(LEGALASSOCIATEAjustesWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SvgPicture.asset(
                    'assets/images/DH_icono-navbar-ajustes.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
