import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_notificaciones_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_notificaciones_model.dart';

class DOVIACLIENTNotificacionesWidget extends StatefulWidget {
  const DOVIACLIENTNotificacionesWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_Notificaciones';
  static String routePath = '/dOVIACLIENTNotificaciones';

  @override
  State<DOVIACLIENTNotificacionesWidget> createState() =>
      _DOVIACLIENTNotificacionesWidgetState();
}

class _DOVIACLIENTNotificacionesWidgetState
    extends State<DOVIACLIENTNotificacionesWidget> {
  late DOVIACLIENTNotificacionesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTNotificacionesModel());

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
                child: CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        title: 'Notificaciones',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: 130.0,
                            child: custom_widgets.NotificationCard(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 130.0,
                              label: 'asdas',
                              timeAgo: 'asdasd',
                              title: 'asdsad',
                              description: 'asdsadasdasdasdasdasdasdasdsad',
                              footerDate: 'asdasdasdas',
                            ),
                          ),
                          Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: 130.0,
                            child: custom_widgets.NotificationCard(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 130.0,
                              label: 'asdas',
                              timeAgo: 'asdasd',
                              title: 'asdsad',
                              description: 'asdsadasdasdasdasdasdasdasdsad',
                              footerDate: 'asdasdasdas',
                            ),
                          ),
                          Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: 130.0,
                            child: custom_widgets.NotificationCard(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 130.0,
                              label: 'asdas',
                              timeAgo: 'asdasd',
                              title: 'asdsad',
                              description: 'asdsadasdasdasdasdasdasdasdsad',
                              footerDate: 'asdasdasdas',
                            ),
                          ),
                        ]
                            .divide(SizedBox(height: 12.0))
                            .addToStart(SizedBox(height: 12.0))
                            .addToEnd(SizedBox(height: 12.0)),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 100.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIACLIENTNavbarWidget(),
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
