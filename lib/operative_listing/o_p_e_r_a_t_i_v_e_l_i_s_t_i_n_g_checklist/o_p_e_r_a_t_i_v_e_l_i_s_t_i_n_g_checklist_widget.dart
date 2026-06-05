import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/custom_code/widgets/operative_listing_check_list.dart' as custom_checklist;
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_properties.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_model.dart';

class OPERATIVELISTINGChecklistWidget extends StatefulWidget {
  const OPERATIVELISTINGChecklistWidget({super.key});

  static String routeName = 'OPERATIVE_LISTING_Checklist';
  static String routePath = '/oPERATIVELISTINGChecklist';

  @override
  State<OPERATIVELISTINGChecklistWidget> createState() =>
      _OPERATIVELISTINGChecklistWidgetState();
}

class _OPERATIVELISTINGChecklistWidgetState
    extends State<OPERATIVELISTINGChecklistWidget> {
  late OPERATIVELISTINGChecklistModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _checklistKey = GlobalKey<custom_checklist.OperativeListingCheckListState>();
  bool _fetchingVisit = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGChecklistModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().lastActiveVisitId.isEmpty) {
        setState(() => _fetchingVisit = true);
        final token = currentAuthenticationToken ?? '';
        final response = await DOVIAAPIVisitContextGroup.getOperativeListerVisitsCall.call(
          authToken: token,
          substatus: 'ASSIGNED',
          page: '1',
          limit: '1',
        );
        if (response.succeeded) {
          final data = getJsonField(response.jsonBody, r'$.data');
          if (data is List && data.isNotEmpty) {
            final firstVisit = data.first;
            if (firstVisit is Map && firstVisit['id'] != null) {
              FFAppState().lastActiveVisitId = firstVisit['id'].toString();
            }
          }
        }
        setState(() => _fetchingVisit = false);
      } else {
        safeSetState(() {});
      }
    });
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
                      model: _model.oPERATIVELISTINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGHeaderWidget(
                        titleText: 'Checklist',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 100.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            if (_fetchingVisit)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (FFAppState().lastActiveVisitId.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'No tienes ninguna visita activa asignada.',
                                    style: TextStyle(
                                      fontFamily: 'Public Sans',
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              )
                            else ...[
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                child: custom_widgets.OperativeListingCheckList(
                                  key: _checklistKey,
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  onAddServicio: () async {},
                                  onSave: () async {},
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).accent1,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Align(
                                    alignment:
                                        const AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 40.0, 20.0, 40.0),
                                      child: Text(
                                        'Antes de darle enviar, recuerda tomar las fotos en base a las áreas que indico que hay en la propiedad ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: wrapWithModel(
                                  model: _model.primaryButtonModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: PrimaryButtonWidget(
                                    text: 'Enviar',
                                    onTap: () async {
                                      if (_checklistKey.currentState?.validateForm() == true) {
                                        final token = currentAuthenticationToken ?? '';
                                        final visitId = FFAppState().lastActiveVisitId;
                                        
                                        // Show loading indicator
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Obteniendo información de la visita...')),
                                        );

                                        // 1. Fetch visit overview to get propertyId
                                        final overviewResponse = await DOVIAAPIVisitContextGroup.getOperativeListerVisitOverviewCall.call(
                                          visitId: visitId,
                                          authToken: token,
                                        );

                                        if (!overviewResponse.succeeded) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al obtener datos de la propiedad: ${overviewResponse.jsonBody}')),
                                            );
                                          }
                                          return;
                                        }

                                        final propData = getJsonField(overviewResponse.jsonBody, r'$.data.property');
                                        String? propertyId;
                                        if (propData is Map) {
                                          propertyId = propData['id']?.toString() ?? propData['_id']?.toString();
                                        }

                                        if (propertyId == null || propertyId.isEmpty) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('No se pudo identificar el ID de la propiedad.')),
                                            );
                                          }
                                          return;
                                        }

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Enviando datos de la propiedad...')),
                                          );
                                        }

                                        // 2. Call PATCH /properties/{propertyId} with checklist data
                                        final formData = _checklistKey.currentState!.getFormData();
                                        final patchResponse = await ApiManager.instance.makeApiCall(
                                          callName: 'PATCH Property Details',
                                          apiUrl: '${DOVIAAPIPropertyContextGroup.getBaseUrl()}/properties/$propertyId',
                                          callType: ApiCallType.PATCH,
                                          headers: {
                                            'Authorization': 'Bearer $token',
                                            'Content-Type': 'application/json',
                                          },
                                          params: {},
                                          body: jsonEncode(formData),
                                          bodyType: BodyType.JSON,
                                          returnBody: true,
                                          encodeBodyUtf8: false,
                                          decodeUtf8: false,
                                          cache: false,
                                          isStreamingApi: false,
                                          alwaysAllowBody: false,
                                        );

                                        if (!patchResponse.succeeded) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al actualizar propiedad: ${patchResponse.jsonBody}')),
                                            );
                                          }
                                          return;
                                        }

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Finalizando visita...')),
                                          );
                                        }

                                        // 3. Mark visit as completed
                                        final response = await DOVIAAPIVisitContextGroup.markVisitedCall.call(
                                          visitId: visitId,
                                          authToken: token,
                                        );

                                        if (response.succeeded) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('¡Visita completada con éxito!')),
                                            );
                                            context.goNamed('OPERATIVE_LISTING_Home');
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al enviar el reporte: ${response.jsonBody}')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                    wrapWithModel(
                      model: _model.oPERATIVELISTINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGNavbarWidget(),
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
