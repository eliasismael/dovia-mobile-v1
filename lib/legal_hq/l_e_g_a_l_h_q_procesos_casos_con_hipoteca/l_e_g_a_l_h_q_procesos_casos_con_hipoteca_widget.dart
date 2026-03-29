import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/legal_hq/l_e_g_a_l_h_q_navbar/l_e_g_a_l_h_q_navbar_widget.dart';
import '/legal_hq/legal_h_q_header/legal_h_q_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'l_e_g_a_l_h_q_procesos_casos_con_hipoteca_model.dart';
export 'l_e_g_a_l_h_q_procesos_casos_con_hipoteca_model.dart';

class LEGALHQProcesosCasosConHipotecaWidget extends StatefulWidget {
  const LEGALHQProcesosCasosConHipotecaWidget({super.key});

  static String routeName = 'LEGAL_HQ_Procesos_CasosConHipoteca';
  static String routePath = '/lEGALHQProcesosCasosConHipoteca';

  @override
  State<LEGALHQProcesosCasosConHipotecaWidget> createState() =>
      _LEGALHQProcesosCasosConHipotecaWidgetState();
}

class _LEGALHQProcesosCasosConHipotecaWidgetState
    extends State<LEGALHQProcesosCasosConHipotecaWidget> {
  late LEGALHQProcesosCasosConHipotecaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALHQProcesosCasosConHipotecaModel());

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
                      model: _model.legalHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LegalHQHeaderWidget(
                        text: 'Home',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 40.0, 20.0, 100.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              child: custom_widgets.CasosConHipotecaWidget(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: MediaQuery.sizeOf(context).height * 1.0,
                                step: 3,
                                onActualizarEstado: () async {},
                                onFinalizarProceso: () async {},
                              ),
                            ),
                          ],
                        ),
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
                      model: _model.lEGALHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LEGALHQNavbarWidget(),
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
