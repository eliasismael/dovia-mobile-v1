import '/shared_components/notifications_inbox/notifications_inbox_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'l_e_g_a_l_h_q_notificaciones_model.dart';
export 'l_e_g_a_l_h_q_notificaciones_model.dart';

class LEGALHQNotificacionesWidget extends StatefulWidget {
  const LEGALHQNotificacionesWidget({super.key});

  static String routeName = 'LEGAL_HQ_Notificaciones';
  static String routePath = '/lEGALHQNotificaciones';

  @override
  State<LEGALHQNotificacionesWidget> createState() =>
      _LEGALHQNotificacionesWidgetState();
}

class _LEGALHQNotificacionesWidgetState
    extends State<LEGALHQNotificacionesWidget> {
  late LEGALHQNotificacionesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALHQNotificacionesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.legalHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LegalHQHeaderWidget(
                        text: 'Notificaciones',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 120.0),
                      child: NotificationsInboxWidget(),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    wrapWithModel(
                      model: _model.lEGALHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LEGALHQNavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
