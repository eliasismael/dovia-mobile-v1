import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import '/app_state.dart';
import '/backend/api_requests/api_visits.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_model.dart';
export 'l_i_s_t_i_n_g_h_q_propiedad_model.dart';

class LISTINGHQPropiedadWidget extends StatefulWidget {
  final String? visitId;

  const LISTINGHQPropiedadWidget({super.key, this.visitId});

  static String routeName = 'LISTING_HQ_Propiedad';
  static String routePath = '/lISTINGHQPropiedad';

  @override
  State<LISTINGHQPropiedadWidget> createState() =>
      _LISTINGHQPropiedadWidgetState();
}

class _LISTINGHQPropiedadWidgetState extends State<LISTINGHQPropiedadWidget> {
  late LISTINGHQPropiedadModel _model;
  Future<Map<String, dynamic>?>? _visitDetailsFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQPropiedadModel());

    if (widget.visitId != null && widget.visitId!.isNotEmpty) {
      _visitDetailsFuture = _fetchInitialData();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<Map<String, dynamic>?> _fetchInitialData() async {
    final response = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: widget.visitId,
      authToken: FFAppState().authenticationToken,
    );
    if (response.succeeded) {
      return getJsonField(response.jsonBody, r'$.data') as Map<String, dynamic>?;
    }
    return null;
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
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.lISTINGHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQHeaderWidget(
                        titleText: 'Propiedad',
                      ),
                    ),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _visitDetailsFuture,
                      builder: (context, snapshot) {
                        if (widget.visitId != null && snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final initialData = snapshot.data;
                        
                        return Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: custom_widgets.ListingHQPropiedad(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        initialData: initialData,
                        onGuardar: () async {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Borrador guardado exitosamente.'),
                              backgroundColor: Color(0xFF007376),
                            ),
                          );
                        },
                        onPublicar: () async {
                          if (widget.visitId != null) {
                            final res = await DOVIAAPIVisitContextGroup.publishPropertyAfterVisitCall.call(
                              visitId: widget.visitId,
                              authToken: FFAppState().authenticationToken,
                            );
                            if (!res.succeeded) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al publicar la propiedad.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }
                          
                          if (!context.mounted) return;

                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: const AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(dialogContext).unfocus();
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  },
                                  child: const PopupExitoWidget(
                                    title: 'Se publicó con éxito',
                                    text: 'La información de la propiedad se ha publicado con éxito. Se le notificará al propietario.',
                                  ),
                                ),
                              );
                            },
                          );
                          if (context.mounted) {
                            context.goNamed('LISTING_HQ_Home');
                          }
                        },
                        onAddServicio: () async {},
                      ),
                    ),
                    );
                  },
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
                      model: _model.lISTINGHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQNavbarWidget(),
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
