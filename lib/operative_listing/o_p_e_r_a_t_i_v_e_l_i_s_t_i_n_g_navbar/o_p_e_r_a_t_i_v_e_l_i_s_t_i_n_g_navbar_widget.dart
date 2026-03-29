import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_model.dart';

class OPERATIVELISTINGNavbarWidget extends StatefulWidget {
  const OPERATIVELISTINGNavbarWidget({super.key});

  @override
  State<OPERATIVELISTINGNavbarWidget> createState() =>
      _OPERATIVELISTINGNavbarWidgetState();
}

class _OPERATIVELISTINGNavbarWidgetState
    extends State<OPERATIVELISTINGNavbarWidget> {
  late OPERATIVELISTINGNavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGNavbarModel());

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
      height: 69.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
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
        padding: EdgeInsetsDirectional.fromSTEB(25.0, 22.0, 25.0, 22.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(OPERATIVELISTINGAgendaWidget.routeName);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: SvgPicture.asset(
                  'assets/images/IconoCalendario.svg',
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(OPERATIVELISTINGChecklistWidget.routeName);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: SvgPicture.asset(
                  'assets/images/clipboard-check.svg',
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context
                    .pushNamed(OPERATIVELISTINGNotificationsWidget.routeName);
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
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(OPERATIVELISTINGProfileWidget.routeName);
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
          ],
        ),
      ),
    );
  }
}
