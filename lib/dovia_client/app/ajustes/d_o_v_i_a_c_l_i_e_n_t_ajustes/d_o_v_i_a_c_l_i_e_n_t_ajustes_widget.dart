import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_users.dart';
import '/dovia_client/app/ajustes/opciones_de_notificaciones/opciones_de_notificaciones_widget.dart';
import '/dovia_client/app/ajustes/unsuscribe_modal_1/unsuscribe_modal1_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  /// Sign-out: clear session and navigate to the landing/login screen.
  Future<void> _signOut() async {
    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    GoRouter.of(context).clearRedirectLocation();
    if (context.mounted) {
      context.goNamedAuth(QueEsDoviaWidget.routeName, context.mounted);
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
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIASHAREDHeaderWidget(
                        title: 'Ajustes',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // ── Tab switcher ──────────────────────────
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 20.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              // Las pestañas se reparten el ancho de la barra.
                              // A lo que midieran sus etiquetas no entraban en
                              // un teléfono angosto y la fila desbordaba.
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: _buildTab(context,
                                        'Perfil y seguridad', 'perfil'),
                                  ),
                                  Expanded(
                                    child: _buildTab(context, 'Notificaciones',
                                        'notificaciones'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Content area ──────────────────────────
                          Builder(
                            builder: (context) {
                              if (_model.selectedSection == 'perfil') {
                                return SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  // Let AjustesScreen size itself naturally
                                  child: custom_widgets.AjustesScreen(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(24)),
                                            ),
                                            child:
                                                const UnsuscribeModal1Widget(),
                                          ),
                                        ),
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    onDeleteAccount: (reason) async {
                                      await DOVIAAPIUserContextGroup
                                          .deactivateMyAccountCall
                                          .call(
                                        authToken:
                                            authManager.authenticationToken,
                                        reason: reason,
                                      );
                                      await _signOut();
                                    },
                                    onSignOut: () async {
                                      await _signOut();
                                    },
                                  ),
                                );
                              } else {
                                return wrapWithModel(
                                  model: _model.opcionesDeNotificacionesModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: const OpcionesDeNotificacionesWidget(),
                                );
                              }
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
                            0.0, 0.0, 15.0, 100.0),
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

  Widget _buildTab(BuildContext context, String label, String section) {
    final isActive = _model.selectedSection == section;
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        _model.selectedSection = section;
        safeSetState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0x34007376)
              : FlutterFlowTheme.of(context).tertiary,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            // Red de seguridad para un tipo de letra agrandado por accesibilidad.
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: isActive
                      ? FlutterFlowTheme.of(context).primaryText
                      : FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
        ),
      ),
    );
  }
}
