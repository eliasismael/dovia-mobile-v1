import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_ofertar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_ofertar_model.dart';

class DOVIACLIENTOfertarWidget extends StatefulWidget {
  const DOVIACLIENTOfertarWidget({
    super.key,
    required this.propertyId,
  });

  final String? propertyId;

  static String routeName = 'DOVIA_CLIENT_Ofertar';
  static String routePath = '/dOVIACLIENTOfertar';

  @override
  State<DOVIACLIENTOfertarWidget> createState() =>
      _DOVIACLIENTOfertarWidgetState();
}

class _DOVIACLIENTOfertarWidgetState extends State<DOVIACLIENTOfertarWidget> {
  late DOVIACLIENTOfertarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTOfertarModel());

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
                        title: 'Ofertar',
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
                                0.0, 40.0, 0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.secondaryButtonModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: SecondaryButtonWidget(
                                text: 'Renta',
                                onTap: () async {
                                  context.pushNamed(
                                    DOVIACLIENTOfertaRentaWidget.routeName,
                                    queryParameters: {
                                      'propertyId': serializeParam(
                                        widget!.propertyId,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.secondaryButtonModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: SecondaryButtonWidget(
                                text: 'Compra',
                                onTap: () async {
                                  context.pushNamed(
                                    DOVIACLIENTOfertaCompraWidget.routeName,
                                    queryParameters: {
                                      'propertyId': serializeParam(
                                        widget!.propertyId,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
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
