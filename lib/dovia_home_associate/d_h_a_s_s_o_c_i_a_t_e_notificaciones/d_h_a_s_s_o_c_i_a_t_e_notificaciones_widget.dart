import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_notification_card/d_h_a_s_s_o_c_i_a_t_e_notification_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'd_h_a_s_s_o_c_i_a_t_e_notificaciones_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_notificaciones_model.dart';

class DHASSOCIATENotificacionesWidget extends StatefulWidget {
  const DHASSOCIATENotificacionesWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_Notificaciones';
  static String routePath = '/dHASSOCIATENotificaciones';

  @override
  State<DHASSOCIATENotificacionesWidget> createState() =>
      _DHASSOCIATENotificacionesWidgetState();
}

class _DHASSOCIATENotificacionesWidgetState
    extends State<DHASSOCIATENotificacionesWidget> {
  late DHASSOCIATENotificacionesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATENotificacionesModel());

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
                      model: _model.dHASSOCIATEHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATEHeaderWidget(
                        tittleText: 'Notificaciones',
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20.0, 35.0, 20.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 10.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    wrapWithModel(
                                      model: _model
                                          .dHASSOCIATENotificationCardModel1,
                                      updateCallback: () => safeSetState(() {}),
                                      child:
                                          const DHASSOCIATENotificationCardWidget(),
                                    ),
                                    wrapWithModel(
                                      model: _model
                                          .dHASSOCIATENotificationCardModel2,
                                      updateCallback: () => safeSetState(() {}),
                                      child:
                                          const DHASSOCIATENotificationCardWidget(),
                                    ),
                                    wrapWithModel(
                                      model: _model
                                          .dHASSOCIATENotificationCardModel3,
                                      updateCallback: () => safeSetState(() {}),
                                      child:
                                          const DHASSOCIATENotificationCardWidget(),
                                    ),
                                    wrapWithModel(
                                      model: _model
                                          .dHASSOCIATENotificationCardModel4,
                                      updateCallback: () => safeSetState(() {}),
                                      child:
                                          const DHASSOCIATENotificationCardWidget(),
                                    ),
                                  ]
                                      .divide(const SizedBox(height: 10.0))
                                      .addToStart(const SizedBox(height: 10.0))
                                      .addToEnd(const SizedBox(height: 10.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 5.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 1.0),
                      child: wrapWithModel(
                        model: _model.dHASSOCIATENavbarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const DHASSOCIATENavbarWidget(),
                      ),
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
