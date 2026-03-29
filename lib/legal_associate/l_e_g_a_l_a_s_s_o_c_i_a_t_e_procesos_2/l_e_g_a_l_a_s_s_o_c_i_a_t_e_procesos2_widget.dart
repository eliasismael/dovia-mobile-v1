import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/legal_associate/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar/l_e_g_a_l_a_s_s_o_c_a_i_t_e_navbar_widget.dart';
import '/legal_associate/legal_associate_header/legal_associate_header_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/interactive_map_component/interactive_map_component_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos2_model.dart';
export 'l_e_g_a_l_a_s_s_o_c_i_a_t_e_procesos2_model.dart';

class LEGALASSOCIATEProcesos2Widget extends StatefulWidget {
  const LEGALASSOCIATEProcesos2Widget({super.key});

  static String routeName = 'LEGAL_ASSOCIATE_Procesos_2';
  static String routePath = '/lEGALASSOCIATEProcesos2';

  @override
  State<LEGALASSOCIATEProcesos2Widget> createState() =>
      _LEGALASSOCIATEProcesos2WidgetState();
}

class _LEGALASSOCIATEProcesos2WidgetState
    extends State<LEGALASSOCIATEProcesos2Widget> {
  late LEGALASSOCIATEProcesos2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LEGALASSOCIATEProcesos2Model());

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
                      model: _model.legalAssociateHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LegalAssociateHeaderWidget(
                        titleText: 'Proceso X',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 1.0,
                            child: custom_widgets.DetalleProcesoWidget(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              step: 4,
                              devolucion: '',
                              propietarioData: UserCardDataStruct(
                                roleLabel: 'Información del propietario',
                                nombre: 'Juan Perez',
                                sexo: 'Masculino',
                                nacionalidad: 'Guatemalteco',
                                edad: '37',
                                telefono: '123456789',
                                imageUrl:
                                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/gmx1iv9z0qdf/nahid_photo.png',
                              ),
                              clienteData: UserCardDataStruct(
                                roleLabel: 'Información del cliente',
                                nombre: 'Pablo Lopez',
                                sexo: 'Masculino',
                                nacionalidad: 'Colombiano',
                                edad: '45',
                                telefono: '987654321',
                                imageUrl:
                                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/gmx1iv9z0qdf/nahid_photo.png',
                              ),
                              onSubirDocumento: () async {},
                              onDescargarDocumento: () async {},
                              onSubirContrato: () async {},
                              onVerUbicacion: () async {},
                              onCancelarReunion: () async {},
                              onReagendarReunion: () async {},
                              onDescargarInformacion: () async {},
                              onVisualizarDocumento: () async {},
                              onVolverACargarDocumento: () async {},
                              onFinalizarProceso: () async {},
                              onVerContratoSubido: () async {},
                              onContinuar: () async {},
                              mapWidget: () => InteractiveMapComponentWidget(),
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
                      model: _model.lEGALASSOCAITENavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LEGALASSOCAITENavbarWidget(),
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
