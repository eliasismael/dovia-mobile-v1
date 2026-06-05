import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/repositories/user_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_profile_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_profile_model.dart';

class OPERATIVELISTINGProfileWidget extends StatefulWidget {
  const OPERATIVELISTINGProfileWidget({super.key});

  static String routeName = 'OPERATIVE_LISTING_Profile';
  static String routePath = '/oPERATIVELISTINGProfile';

  @override
  State<OPERATIVELISTINGProfileWidget> createState() =>
      _OPERATIVELISTINGProfileWidgetState();
}

class _OPERATIVELISTINGProfileWidgetState
    extends State<OPERATIVELISTINGProfileWidget> {
  late OPERATIVELISTINGProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Sign-out: clear cached profile and session, then return to the landing
  /// screen.
  Future<void> _signOut() async {
    final router = GoRouter.of(context);
    context.read<UserRepository>().clear();
    router.prepareAuthEvent();
    await authManager.signOut();
    router.clearRedirectLocation();
    if (mounted) {
      context.goNamedAuth(QueEsDoviaWidget.routeName, mounted);
    }
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
                      model: _model.oPERATIVELISTINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGHeaderWidget(
                        titleText: 'Perfil',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 1.0,
                            child: custom_widgets.OperativeListingProfile(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              onSignOut: () async {
                                await _signOut();
                              },
                              onDeleteAccount: () async {
                                // No dedicated delete-account endpoint is
                                // available yet; process the operative baja by
                                // ending the session and returning to login.
                                await _signOut();
                              },
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
                      model: _model.oPERATIVELISTINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGNavbarWidget(),
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
