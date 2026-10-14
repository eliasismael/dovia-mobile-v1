import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared_components/navbar_item_indicator/navbar_item_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'l_i_s_t_i_n_g_h_q_navbar_model.dart';
import '/shared_components/notification_badge.dart';
export 'l_i_s_t_i_n_g_h_q_navbar_model.dart';

class LISTINGHQNavbarWidget extends StatefulWidget {
  const LISTINGHQNavbarWidget({super.key});

  @override
  State<LISTINGHQNavbarWidget> createState() => _LISTINGHQNavbarWidgetState();
}

class _LISTINGHQNavbarWidgetState extends State<LISTINGHQNavbarWidget> {
  late LISTINGHQNavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQNavbarModel());

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
              routeNames: [LISTINGHQHomeWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.goNamed(LISTINGHQHomeWidget.routeName);
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
              label: 'Propiedades',
              routeNames: [
                LISTINGHQPropiedadesWidget.routeName,
                LISTINGHQPropiedadWidget.routeName,
                LISTINGHQPropiedadAsignadaWidget.routeName,
                LISTINGHQPropiedadRechazadaWidget.routeName,
                LISTINGHQPropiedadArchivosPendientesWidget.routeName,
              ],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(LISTINGHQPropiedadesWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/IconoCasaLLave.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Documentos',
              routeNames: [
                LISTINGHQDocumentosWidget.routeName,
                LISTINGHQDocumentos2Widget.routeName,
                LISTINGHQDocumentos3Widget.routeName,
                LISTINGHQDocumentosPendientesWidget.routeName,
              ],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(LISTINGHQDocumentosWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/page.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Notificaciones',
              routeNames: [LISTINGHQNotificationsWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(LISTINGHQNotificationsWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: NotificationBadge(
                      child: SvgPicture.asset(
                    'assets/images/DH_icono-navbar-notificaciones.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.none,
                  )),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Ajustes',
              routeNames: [LISTINGHQProfileWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(LISTINGHQProfileWidget.routeName);
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
