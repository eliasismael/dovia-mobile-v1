import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/custom_code/widgets/operative_listing_check_list.dart'
    as custom_checklist;
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_properties.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_form_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_checklist_form_model.dart';

class OPERATIVELISTINGChecklistFormWidget extends StatefulWidget {
  final String visitId;

  const OPERATIVELISTINGChecklistFormWidget({super.key, this.visitId = ''});

  static String routeName = 'OPERATIVE_LISTING_Checklist_Form';
  static String routePath = '/oPERATIVELISTINGChecklistForm';

  @override
  State<OPERATIVELISTINGChecklistFormWidget> createState() =>
      _OPERATIVELISTINGChecklistFormWidgetState();
}

class _OPERATIVELISTINGChecklistFormWidgetState
    extends State<OPERATIVELISTINGChecklistFormWidget> {
  late OPERATIVELISTINGChecklistFormModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _checklistKey =
      GlobalKey<custom_checklist.OperativeListingCheckListState>();
  bool _fetchingVisit = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGChecklistFormModel());
    // Antes del primer build: el borrador local se busca por esta visita.
    if (widget.visitId.isNotEmpty) {
      FFAppState().lastActiveVisitId = widget.visitId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadAddress();

      if (FFAppState().lastActiveVisitId.isEmpty) {
        setState(() => _fetchingVisit = true);
        final token = currentAuthenticationToken ?? '';
        final response =
            await DOVIAAPIVisitContextGroup.getOperativeListerVisitsCall.call(
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

  String _address = '';
  bool _submitting = false;

  /// Dirección de la propiedad para mostrarla en "Datos generales".
  Future<void> _loadAddress() async {
    final visitId = FFAppState().lastActiveVisitId;
    if (visitId.isEmpty) return;
    final res = await DOVIAAPIVisitContextGroup
        .getOperativeListerVisitOverviewCall
        .call(
      visitId: visitId,
      authToken: currentAuthenticationToken ?? '',
    );
    final addr = getJsonField(
        res.jsonBody, r'$.data.property.location.address.fullAddress');
    if (res.succeeded && addr != null) {
      safeSetState(() => _address = addr.toString());
    }
  }

  String _backendMessage(ApiCallResponse res) {
    final body = res.jsonBody;
    if (body is Map) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final m = (errors.first as Map)['message']?.toString();
        if (m != null && m.isNotEmpty) return m;
      }
      final m = body['message']?.toString();
      if (m != null && m.isNotEmpty) return m;
    }
    return 'HTTP ${res.statusCode}';
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Popup del diseño al terminar: tilde y aviso de que HQ lo revisa.
  Future<void> _showSubmittedPopup() {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 36),
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Se subió con éxito',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00444B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Esta información le llegará a Dovia HQ, donde te indicará si falta algo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007376),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ir al inicio',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF007376),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  /// Valida, guarda el relevamiento en la propiedad y cierra la visita.
  Future<void> _submit() async {
    final checklist = _checklistKey.currentState;
    if (_submitting || checklist == null || !checklist.validateForm()) return;
    safeSetState(() => _submitting = true);
    try {
      final token = currentAuthenticationToken ?? '';
      final visitId = FFAppState().lastActiveVisitId;

      final overview = await DOVIAAPIVisitContextGroup
          .getOperativeListerVisitOverviewCall
          .call(visitId: visitId, authToken: token);
      final propertyId =
          getJsonField(overview.jsonBody, r'$.data.property.id')?.toString();
      if (!overview.succeeded || propertyId == null || propertyId.isEmpty) {
        _snack('No se pudo obtener la propiedad: ${_backendMessage(overview)}');
        return;
      }

      final patch = await ApiManager.instance.makeApiCall(
        callName: 'PATCH Property Details',
        apiUrl:
            '${DOVIAAPIPropertyContextGroup.getBaseUrl()}/properties/$propertyId',
        callType: ApiCallType.PATCH,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        params: {},
        body: jsonEncode(checklist.getFormData()),
        bodyType: BodyType.JSON,
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: false,
        isStreamingApi: false,
        alwaysAllowBody: false,
      );
      if (!patch.succeeded) {
        debugPrint('[Checklist] PATCH ${patch.statusCode}: ${patch.bodyText}');
        _snack('No se pudo guardar el checklist: ${_backendMessage(patch)}');
        return;
      }

      // Cierra la visita: pasa a completada.
      final visited = await DOVIAAPIVisitContextGroup.markVisitedCall
          .call(visitId: visitId, authToken: token);
      if (!visited.succeeded) {
        debugPrint(
            '[Checklist] mark-visited ${visited.statusCode}: ${visited.bodyText}');
        _snack('El checklist se guardó, pero no se pudo cerrar la visita: '
            '${_backendMessage(visited)}');
        return;
      }

      await checklist.clearDraft();
      if (!mounted) return;
      await _showSubmittedPopup();
      if (mounted) context.goNamed('OPERATIVE_LISTING_Home');
    } finally {
      safeSetState(() => _submitting = false);
    }
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
                                child:
                                    Center(child: CircularProgressIndicator()),
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
                                  visitId: FFAppState().lastActiveVisitId,
                                  address: _address,
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
                                    text:
                                        _submitting ? 'Enviando...' : 'Enviar',
                                    onTap: _submit,
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
