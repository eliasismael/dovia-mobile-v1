import '/flutter_flow/flutter_flow_theme.dart';
import '/auth/sign_out.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_users.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'l_i_s_t_i_n_g_h_q_profile_model.dart';
export 'l_i_s_t_i_n_g_h_q_profile_model.dart';

class LISTINGHQProfileWidget extends StatefulWidget {
  const LISTINGHQProfileWidget({super.key});

  static String routeName = 'LISTING_HQ_Profile';
  static String routePath = '/lISTINGHQProfile';

  @override
  State<LISTINGHQProfileWidget> createState() => _LISTINGHQProfileWidgetState();
}

class _LISTINGHQProfileWidgetState extends State<LISTINGHQProfileWidget> {
  late LISTINGHQProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQProfileModel());

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
                      model: _model.lISTINGHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQHeaderWidget(
                        titleText: 'Ajustes',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 8.0, 20.0, 120.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            child: custom_widgets.OperativeListingProfile(
                              roleLabel: 'Dovia Lister HQ',
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              onTermsAndConditions: () async {},
                              onSupport: () async {},
                              onLogout: () => signOutAndGoToLogin(context),
                              onDeleteAccount: (reason) async {
                                final res = await DOVIAAPIUserContextGroup
                                    .deactivateMyAccountCall
                                    .call(
                                  authToken: authManager.authenticationToken,
                                  reason: reason,
                                );
                                return res.succeeded;
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
                      model: _model.lISTINGHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQNavbarWidget(),
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
