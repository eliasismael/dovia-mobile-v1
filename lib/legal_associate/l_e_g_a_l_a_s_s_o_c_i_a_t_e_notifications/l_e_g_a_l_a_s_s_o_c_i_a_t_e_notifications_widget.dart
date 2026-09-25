import '/shared_components/notifications_inbox/notifications_inbox_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_notifications_model.dart';
export 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_notifications_model.dart';

class LEGALASSOCIATENotificationsWidget extends StatefulWidget {
  const LEGALASSOCIATENotificationsWidget({super.key});

  static String routeName = 'LEGAL_ASSOCIATE_Notifications';
  static String routePath = '/lEGALASSOCIATENotifications';

  @override
  State<LEGALASSOCIATENotificationsWidget> createState() =>
      _LEGALASSOCIATENotificationsWidgetState();
}

class _LEGALASSOCIATENotificationsWidgetState
    extends State<LEGALASSOCIATENotificationsWidget> {
  late LEGALASSOCIATENotificationsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCIATENotificationsModel());

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
                      model: _model.legalAssociateHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LegalAssociateHeaderWidget(
                        titleText: 'Notificaciones',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
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
                      model: _model.lEGALASSOCAITENavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LEGALASSOCAITENavbarWidget(),
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
