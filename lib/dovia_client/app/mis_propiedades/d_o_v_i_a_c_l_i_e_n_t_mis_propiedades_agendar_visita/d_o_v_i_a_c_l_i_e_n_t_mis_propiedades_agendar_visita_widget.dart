import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_agendar_visita_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_agendar_visita_model.dart';

class DOVIACLIENTMisPropiedadesAgendarVisitaWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesAgendarVisitaWidget({
    super.key,
    this.propertyId,
  });

  final String? propertyId;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_AgendarVisita';
  static String routePath = '/dOVIACLIENTMisPropiedadesAgendarVisita';

  @override
  State<DOVIACLIENTMisPropiedadesAgendarVisitaWidget> createState() =>
      _DOVIACLIENTMisPropiedadesAgendarVisitaWidgetState();
}

class _DOVIACLIENTMisPropiedadesAgendarVisitaWidgetState
    extends State<DOVIACLIENTMisPropiedadesAgendarVisitaWidget> {
  late DOVIACLIENTMisPropiedadesAgendarVisitaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesAgendarVisitaModel());

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
                        title: 'Agendar visita',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              child: custom_widgets
                                  .DoviaClientMisPropiedadesAgendarVisita(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: MediaQuery.sizeOf(context).height * 1.0,
                                onContinue: () async {
                                  _model.apiResCreateVisitRequest =
                                      await DOVIAAPIVisitContextGroup
                                          .createVisitRequestCall
                                          .call(
                                    propertyId: widget!.propertyId,
                                    authToken: currentAuthenticationToken,
                                    dateOne: _model.dateOne,
                                    hourOne: _model.hourOne,
                                    dateTwo: _model.dateTwo,
                                    hourTwo: _model.hourTwo,
                                    dateThree: _model.dateThree,
                                    hourThree: _model.hourThee,
                                  );

                                  if ((_model.apiResCreateVisitRequest
                                          ?.succeeded ??
                                      true)) {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return AlertDialog(
                                          title: Text('ok'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return AlertDialog(
                                          title: Text('err'),
                                          content: Text((_model
                                                      .apiResCreateVisitRequest
                                                      ?.jsonBody ??
                                                  '')
                                              .toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }

                                  safeSetState(() {});
                                },
                                onDateOne: (dateOne) async {
                                  _model.dateOne = dateOne;
                                  safeSetState(() {});
                                },
                                onHourOne: (hourOne) async {
                                  _model.hourOne = hourOne;
                                  safeSetState(() {});
                                },
                                onDateTwo: (dateTwo) async {
                                  _model.dateTwo = dateTwo;
                                  safeSetState(() {});
                                },
                                onHourTwo: (hourTwo) async {
                                  _model.hourTwo = hourTwo;
                                  safeSetState(() {});
                                },
                                onDateThree: (dateThree) async {
                                  _model.dateThree = dateThree;
                                  safeSetState(() {});
                                },
                                onHourThree: (hourThree) async {
                                  _model.hourThee = hourThree;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
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
