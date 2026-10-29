import '/auth/custom_auth/auth_util.dart';
import '/auth/sign_out.dart';
import '/backend/api_requests/api_users.dart';
import '/dovia_client/app/ajustes/unsuscribe_modal_1/unsuscribe_modal1_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_ajustes_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_ajustes_model.dart';

class DOVIACLIENTAjustesWidget extends StatefulWidget {
  const DOVIACLIENTAjustesWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_Ajustes';
  static String routePath = '/dOVIACLIENTAjustes';

  @override
  State<DOVIACLIENTAjustesWidget> createState() =>
      _DOVIACLIENTAjustesWidgetState();
}

class _DOVIACLIENTAjustesWidgetState extends State<DOVIACLIENTAjustesWidget> {
  late DOVIACLIENTAjustesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTAjustesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Cierra la sesión (también en el backend) y vuelve al login.
  Future<void> _signOut() => signOutAndGoToLogin(context);

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
          // Sin SafeArea abajo, como en el inicio: el contenido pasa
          // por debajo de la barra flotante hasta el borde de la pantalla.
          bottom: false,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                // Lo que ocupa el indicador de inicio (iPhone), que ya no
                // descuenta el SafeArea: el final queda sobre la barra.
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        showLogo: openedFromHome(context),
                        showSupport: false,
                        title: 'Ajustes',
                        showCurrency: false,
                        showMap: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // ── Content area ──────────────────────────
                          Builder(
                            builder: (context) {
                              return SizedBox(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                // Let AjustesScreen size itself naturally
                                child: custom_widgets.AjustesScreen(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: null,
                                  onCancelSubscription: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) => Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(24)),
                                          ),
                                          child: const UnsuscribeModal1Widget(),
                                        ),
                                      ),
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  onDeleteAccount: (reason) async {
                                    final res = await DOVIAAPIUserContextGroup
                                        .deactivateMyAccountCall
                                        .call(
                                      authToken:
                                          authManager.authenticationToken,
                                      reason: reason,
                                    );
                                    return res.succeeded;
                                  },
                                  onSignOut: () async {
                                    await _signOut();
                                  },
                                ),
                              );
                            },
                          ),
                        ]
                            .divide(const SizedBox(height: 0.0))
                            .addToStart(const SizedBox(height: 0.0))
                            .addToEnd(const SizedBox(height: 12.0)),
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
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 12.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTAjustesWidget.routeName,
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
