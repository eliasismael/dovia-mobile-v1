import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_auth.dart';
import '/backend/api_requests/api_users.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/repositories/user_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_ajustes_model.dart';
export 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_ajustes_model.dart';

class LEGALASSOCIATEAjustesWidget extends StatefulWidget {
  const LEGALASSOCIATEAjustesWidget({super.key});

  static String routeName = 'LEGAL_ASSOCIATE_Ajustes';
  static String routePath = '/lEGALASSOCIATEAjustes';

  @override
  State<LEGALASSOCIATEAjustesWidget> createState() =>
      _LEGALASSOCIATEAjustesWidgetState();
}

class _LEGALASSOCIATEAjustesWidgetState
    extends State<LEGALASSOCIATEAjustesWidget> {
  late LEGALASSOCIATEAjustesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCIATEAjustesModel());

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
                        titleText: 'Ajustes',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 40.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            child: custom_widgets.OperativeListingProfile(
                              roleLabel: 'Dovia Legal Associate',
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              onTermsAndConditions: () async {},
                              onSupport: () async {},
                              onLogout: () async {
                                final router = GoRouter.of(context);
                                context.read<UserRepository>().clear();
                                await DOVIAAPIAuthContextGroup.logoutAllCall
                                    .call(
                                        idToken:
                                            authManager.authenticationToken);
                                router.prepareAuthEvent();
                                await authManager.signOut();
                                router.clearRedirectLocation();
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  context.goNamedAuth(
                                      SignInWidget.routeName, mounted);
                                }
                              },
                              onDeleteAccount: (reason) async {
                                await DOVIAAPIUserContextGroup
                                    .deactivateMyAccountCall
                                    .call(
                                  authToken: authManager.authenticationToken,
                                  reason: reason,
                                );
                              },
                              onSaveInfo: () async {},
                            ),
                          ),
                        ],
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
