import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_planes/d_h_c_l_i_e_n_t_planes_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_planes_page_model.dart';
export 'd_h_c_l_i_e_n_t_planes_page_model.dart';

class DHCLIENTPlanesPageWidget extends StatefulWidget {
  const DHCLIENTPlanesPageWidget({super.key});

  static String routeName = 'DH_CLIENT_PlanesPage';
  static String routePath = '/dHCLIENTPlanesPage';

  /// Pantalla a la que se vuelve al salir de Planes. La fija el flujo que trajo
  /// al cliente hasta acá (Ej: el paso de costo de una emergencia). Si es null
  /// se mantiene el destino histórico: el valor de la visita estándar.
  /// Mismo patrón que [DHCLIENTUbicacionWidget.pendingNextRoute].
  static String? pendingReturnRoute;

  @override
  State<DHCLIENTPlanesPageWidget> createState() =>
      _DHCLIENTPlanesPageWidgetState();
}

class _DHCLIENTPlanesPageWidgetState extends State<DHCLIENTPlanesPageWidget> {
  late DHCLIENTPlanesPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTPlanesPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    // Con esta pantalla fuera de la pila el "a dónde volver" ya no aplica: si
    // quedara seteado, un ingreso posterior a Planes desde otro flujo se
    // llevaría el destino viejo.
    DHCLIENTPlanesPageWidget.pendingReturnRoute = null;
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
        body: Stack(
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
                      showNotifications: true,
                      showSettings: true,
                      title: 'Planes',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 12.0, 20.0, 0.0),
                    child: wrapWithModel(
                      model: _model.dHCLIENTPlanesModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHCLIENTPlanesWidget(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 20.0, 20.0, 80.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        // El cliente omitió la contratación del plan. Si vino
                        // desde un flujo (Ej: el costo de una emergencia) se
                        // vuelve a esa pantalla, que quedó en la pila esperando
                        // el resultado: apilar una instancia nueva la dejaría
                        // sin saber que no hubo compra. Sin flujo previo se
                        // mantiene el destino histórico.
                        if (DHCLIENTPlanesPageWidget.pendingReturnRoute !=
                            null) {
                          context.safePop();
                          return;
                        }
                        context.pushNamed(
                            DHCLIENTValorVisitaPageWidget.routeName);
                      },
                      text: 'Omitir',
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 40.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
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
                    model: _model.dHCLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHCLIENTNavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
