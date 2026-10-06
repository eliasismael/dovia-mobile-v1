import '/auth/custom_auth/auth_util.dart';
import '/auth/sign_out.dart';
import '/backend/api_requests/api_users.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 's_h_o_w_i_n_g_profile_model.dart';
export 's_h_o_w_i_n_g_profile_model.dart';

class SHOWINGProfileWidget extends StatefulWidget {
  const SHOWINGProfileWidget({super.key});

  static String routeName = 'SHOWING_Profile';
  static String routePath = '/sHOWINGProfile';

  @override
  State<SHOWINGProfileWidget> createState() => _SHOWINGProfileWidgetState();
}

class _SHOWINGProfileWidgetState extends State<SHOWINGProfileWidget> {
  late SHOWINGProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGProfileModel());

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
                      model: _model.sHOWINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGHeaderWidget(
                        title: 'Profile',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            child: custom_widgets.OperativeListingProfile(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              roleLabel: 'Dovia Showing Associate',
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
                      model: _model.sHOWINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGNavbarWidget(),
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
