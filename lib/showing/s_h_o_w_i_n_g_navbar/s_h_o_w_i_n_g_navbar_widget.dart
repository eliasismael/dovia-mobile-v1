import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared_components/navbar_item_indicator/navbar_item_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 's_h_o_w_i_n_g_navbar_model.dart';
export 's_h_o_w_i_n_g_navbar_model.dart';

class SHOWINGNavbarWidget extends StatefulWidget {
  const SHOWINGNavbarWidget({super.key});

  @override
  State<SHOWINGNavbarWidget> createState() => _SHOWINGNavbarWidgetState();
}

class _SHOWINGNavbarWidgetState extends State<SHOWINGNavbarWidget> {
  late SHOWINGNavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGNavbarModel());

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
              routeNames: [SHOWINGHomeWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.goNamed(SHOWINGHomeWidget.routeName);
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
              label: 'Agenda',
              routeNames: [SHOWINGAgendaWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(SHOWINGAgendaWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/repository.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Propiedades',
              routeNames: [SHOWINGPropiedadesAMostrarWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(SHOWINGPropiedadesAMostrarWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/home-temperature-in.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Registro',
              routeNames: [SHOWINGRegistroDeVisitaWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(SHOWINGRegistroDeVisitaWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SvgPicture.asset(
                    'assets/images/edit.svg',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
            NavbarItemIndicator(
              label: 'Ajustes',
              routeNames: [SHOWINGProfileWidget.routeName],
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(SHOWINGProfileWidget.routeName);
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
