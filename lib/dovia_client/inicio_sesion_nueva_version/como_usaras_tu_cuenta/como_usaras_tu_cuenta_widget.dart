import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/user_type_card/user_type_card_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'como_usaras_tu_cuenta_model.dart';
export 'como_usaras_tu_cuenta_model.dart';

class ComoUsarasTuCuentaWidget extends StatefulWidget {
  const ComoUsarasTuCuentaWidget({super.key});

  static String routeName = 'ComoUsarasTuCuenta';
  static String routePath = '/comoUsarasTuCuenta';

  @override
  State<ComoUsarasTuCuentaWidget> createState() =>
      _ComoUsarasTuCuentaWidgetState();
}

class _ComoUsarasTuCuentaWidgetState extends State<ComoUsarasTuCuentaWidget> {
  late ComoUsarasTuCuentaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ComoUsarasTuCuentaModel());

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
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        '¿Qué quieres hacer en DOVIA?',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.publicSans(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 22.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(ElegirRolAsociadoWidget.routeName);
                      },
                      child: wrapWithModel(
                        model: _model.userTypeCardModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: const UserTypeCardWidget(
                          userType: UserType.asociado,
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.apiResultcnl =
                            await DOVIAAPIAuthContextGroup.selectRoleCall.call(
                          role: 'CLIENT',
                          authToken: currentAuthenticationToken,
                        );

                        if ((_model.apiResultcnl?.succeeded ?? false)) {
                          context.pushNamed(Datos3NewWidget.routeName);
                        } else {
                          await showDialog(
                            context: context,
                            builder: (alertDialogContext) {
                              return AlertDialog(
                                title: const Text('ERROR'),
                                content: Text(
                                    (_model.apiResultcnl?.jsonBody ?? '')
                                        .toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext),
                                    child: const Text('Ok'),
                                  ),
                                ],
                              );
                            },
                          );
                        }

                        safeSetState(() {});
                      },
                      child: wrapWithModel(
                        model: _model.userTypeCardModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: const UserTypeCardWidget(
                          userType: UserType.usuario,
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 20.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
