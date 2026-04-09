import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'elegir_rol_asociado_model.dart';
export 'elegir_rol_asociado_model.dart';

class ElegirRolAsociadoWidget extends StatefulWidget {
  const ElegirRolAsociadoWidget({super.key});

  static String routeName = 'ElegirRolAsociado';
  static String routePath = '/elegirRolAsociado';

  @override
  State<ElegirRolAsociadoWidget> createState() =>
      _ElegirRolAsociadoWidgetState();
}

class _ElegirRolAsociadoWidgetState extends State<ElegirRolAsociadoWidget> {
  late ElegirRolAsociadoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ElegirRolAsociadoModel());

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 0.0),
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: const BoxDecoration(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0.0),
                            child: SvgPicture.asset(
                              'assets/images/D-verde.svg',
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 0.0),
                        child: custom_widgets.DoviaAssociateDropdownWidget(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          onShowingAssociateTap: () async {
                            final result = await DOVIAAPIAuthContextGroup.selectRoleCall.call(
                              role: 'SHOWING_AGENT',
                              authToken: currentAuthenticationToken,
                            );
                            if (result.succeeded) {
                              FFAppState().UserRole = 'SHOWING_AGENT';
                              if (context.mounted) context.pushNamed(FormAssociateWidget.routeName);
                            }
                          },
                          onListerAssociateTap: () async {
                            final result = await DOVIAAPIAuthContextGroup.selectRoleCall.call(
                              role: 'OPERATIVE_LISTER',
                              authToken: currentAuthenticationToken,
                            );
                            if (result.succeeded) {
                              FFAppState().UserRole = 'OPERATIVE_LISTER';
                              if (context.mounted) context.pushNamed(FormAssociateWidget.routeName);
                            }
                          },
                          onHomeAssociateTap: () async {
                            final result = await DOVIAAPIAuthContextGroup.selectRoleCall.call(
                              role: 'HOME_ASSOCIATE',
                              authToken: currentAuthenticationToken,
                            );
                            if (result.succeeded) {
                              FFAppState().UserRole = 'HOME_ASSOCIATE';
                              if (context.mounted) context.pushNamed(FormAssociateWidget.routeName);
                            }
                          },
                          onLegalAssociateTap: () async {
                            final result = await DOVIAAPIAuthContextGroup.selectRoleCall.call(
                              role: 'LEGAL_ASSOCIATE',
                              authToken: currentAuthenticationToken,
                            );
                            if (result.succeeded) {
                              FFAppState().UserRole = 'LEGAL_ASSOCIATE';
                              if (context.mounted) context.pushNamed(FormAssociateWidget.routeName);
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: wrapWithModel(
                            model: _model.secondaryButtonModel,
                            updateCallback: () => safeSetState(() {}),
                            child: SecondaryButtonWidget(
                              text: 'Volver',
                              onTap: () async {
                                context.pushNamed(Datos3NewWidget.routeName);
                              },
                            ),
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
      ),
    );
  }
}
