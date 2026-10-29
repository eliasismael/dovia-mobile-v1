import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';

import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import '/shared_components/header_navigation.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';

import 'd_o_v_i_a_c_l_i_e_n_t_como_funciona_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_como_funciona_model.dart';

class DOVIACLIENTComoFuncionaWidget extends StatefulWidget {
  const DOVIACLIENTComoFuncionaWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_ComoFunciona';
  static String routePath = '/dOVIACLIENTComoFunciona';

  @override
  State<DOVIACLIENTComoFuncionaWidget> createState() =>
      _DOVIACLIENTComoFuncionaWidgetState();
}

class _DOVIACLIENTComoFuncionaWidgetState
    extends State<DOVIACLIENTComoFuncionaWidget> {
  late DOVIACLIENTComoFuncionaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTComoFuncionaModel());

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
                    DOVIASHAREDHeaderWidget(
                      title: 'Mis propiedades',
                      showLogo: openedFromHome(context),
                      hideActions: true,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: custom_widgets.HowItWorksWidget(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                onAccept: () async {
                                  context.pushNamed(
                                      DOVIACLIENTMisPropiedadesAccionesARealizarWidget
                                          .routeName);
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
