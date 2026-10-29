import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita2_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita2_model.dart';

class DOVIACLIENTMisPropiedadesVisita2Widget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesVisita2Widget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_Visita_2';
  static String routePath = '/dOVIACLIENTMisPropiedadesVisita2';

  @override
  State<DOVIACLIENTMisPropiedadesVisita2Widget> createState() =>
      _DOVIACLIENTMisPropiedadesVisita2WidgetState();
}

class _DOVIACLIENTMisPropiedadesVisita2WidgetState
    extends State<DOVIACLIENTMisPropiedadesVisita2Widget> {
  late DOVIACLIENTMisPropiedadesVisita2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => DOVIACLIENTMisPropiedadesVisita2Model());

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
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        showLogo: openedFromHome(context),
                        showSupport: false,
                        showMap: false,
                        showCurrency: false,
                        title: 'Visita',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            child: custom_widgets.ProcessState(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 250.0,
                              currentStep: 3,
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Revisión final antes de publicar tu propiedad:\n\n ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'DOVIA HQ está verificando toda la información enviada por tu asociado para asegurarnos de que tu publicación sea precisa, profesional y lista para recibir compradores reales.\n\n',
                                      style: TextStyle(),
                                    ),
                                    const TextSpan(
                                      text: 'Durante esta etapa revisamos:\n\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          '-  Datos generales de la propiedad\n-  Documentos cargados (ID, certificación, etc.)\n-  Material comercial (fotos, recorrido virtual, descripción)\n-  Precio y detalles relevantes para la publicación\n\n',
                                      style: TextStyle(),
                                    ),
                                    const TextSpan(
                                      text:
                                          'Si encontramos algún dato que necesite corregirse, te lo notificaremos aquí para que puedas actualizarlo fácilmente.\n\nEn caso de cambios en tus documentos o autorización, generaremos una nueva versión digital para tu firma.\n\nEn caso de cambios en tus documentos o autorización, generaremos una nueva versión digital para tu firma.\n',
                                      style: TextStyle(),
                                    ),
                                    const TextSpan(
                                      text:
                                          '\n¿Tienes dudas o necesitas corregir algo?\n\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'Escríbenos directamente desde este apartado y un miembro de DOVIA HQ te ayudará de inmediato.',
                                      style: TextStyle(),
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
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
