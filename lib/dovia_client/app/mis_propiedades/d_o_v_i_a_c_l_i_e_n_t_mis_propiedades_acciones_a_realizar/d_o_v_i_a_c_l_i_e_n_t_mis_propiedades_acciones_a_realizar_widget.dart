import '/backend/schema/enums/enums.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import '/index.dart';
import '/shared_components/header_navigation.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_acciones_a_realizar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_acciones_a_realizar_model.dart';

class DOVIACLIENTMisPropiedadesAccionesARealizarWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesAccionesARealizarWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_AccionesARealizar';
  static String routePath = '/dOVIACLIENTMisPropiedadesAccionesARealizar';

  @override
  State<DOVIACLIENTMisPropiedadesAccionesARealizarWidget> createState() =>
      _DOVIACLIENTMisPropiedadesAccionesARealizarWidgetState();
}

class _DOVIACLIENTMisPropiedadesAccionesARealizarWidgetState
    extends State<DOVIACLIENTMisPropiedadesAccionesARealizarWidget> {
  late DOVIACLIENTMisPropiedadesAccionesARealizarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesAccionesARealizarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _model.isSaleSelected || _model.isRentSelected;

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
                    DOVIASHAREDHeaderWidget(
                      title: 'Acciones a realizar',
                      showLogo: openedFromHome(context),
                      hideActions: true,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                '¿Qué te gustaría hacer?',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 8.0, 0.0, 0.0),
                              child: Text(
                                'Puedes seleccionar ambas',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                if (_model.isSaleSelected) {
                                  return wrapWithModel(
                                    model: _model.primaryButtonModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PrimaryButtonWidget(
                                      text: 'Venta',
                                      onTap: () async {
                                        _model.isSaleSelected = false;
                                        safeSetState(() {});
                                      },
                                    ),
                                  );
                                } else {
                                  return wrapWithModel(
                                    model: _model.secondaryButtonModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SecondaryButtonWidget(
                                      text: 'Venta',
                                      onTap: () async {
                                        _model.isSaleSelected = true;
                                        safeSetState(() {});
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                if (_model.isRentSelected) {
                                  return wrapWithModel(
                                    model: _model.primaryButtonModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PrimaryButtonWidget(
                                      text: 'Renta',
                                      onTap: () async {
                                        _model.isRentSelected = false;
                                        safeSetState(() {});
                                      },
                                    ),
                                  );
                                } else {
                                  return wrapWithModel(
                                    model: _model.secondaryButtonModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SecondaryButtonWidget(
                                      text: 'Renta',
                                      onTap: () async {
                                        _model.isRentSelected = true;
                                        safeSetState(() {});
                                      },
                                    ),
                                  );
                                }
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
                    const Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 12.0),
                        child: FixedDoviaIconWidget(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 20.0),
                      child: IgnorePointer(
                        ignoring: !canProceed,
                        child: Opacity(
                          opacity: canProceed ? 1.0 : 0.4,
                          child: wrapWithModel(
                            model: _model.primaryButtonModel3,
                            updateCallback: () => safeSetState(() {}),
                            child: PrimaryButtonWidget(
                              text: 'Continuar',
                              onTap: () async {
                                context.pushNamed(
                                  DOVIACLIENTMisPropiedadesVenderRentarWidget
                                      .routeName,
                                  queryParameters: {
                                    'title': serializeParam(
                                      () {
                                        if (_model.isSaleSelected &&
                                            _model.isRentSelected) {
                                          return 'Venta y renta';
                                        } else if (_model.isSaleSelected) {
                                          return 'Venta';
                                        } else {
                                          return 'Renta';
                                        }
                                      }(),
                                      ParamType.String,
                                    ),
                                    'transactionType': serializeParam(
                                      () {
                                        if (_model.isSaleSelected &&
                                            _model.isRentSelected) {
                                          return PropertyPublicationType
                                              .SALE_AND_RENT;
                                        } else if (_model.isSaleSelected) {
                                          return PropertyPublicationType.SALE;
                                        } else {
                                          return PropertyPublicationType.RENT;
                                        }
                                      }(),
                                      ParamType.Enum,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
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
