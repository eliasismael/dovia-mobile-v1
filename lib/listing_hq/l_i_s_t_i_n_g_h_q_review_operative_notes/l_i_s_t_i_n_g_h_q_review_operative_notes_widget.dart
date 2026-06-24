import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import 'l_i_s_t_i_n_g_h_q_review_operative_notes_model.dart';
export 'l_i_s_t_i_n_g_h_q_review_operative_notes_model.dart';

class LISTINGHQReviewOperativeNotesWidget extends StatefulWidget {
  final String? visitId;

  const LISTINGHQReviewOperativeNotesWidget({super.key, this.visitId});

  static String routeName = 'LISTING_HQ_Review_Operative_Notes';
  static String routePath = '/listingHqReviewOperativeNotes';

  @override
  State<LISTINGHQReviewOperativeNotesWidget> createState() =>
      _LISTINGHQReviewOperativeNotesWidgetState();
}

class _LISTINGHQReviewOperativeNotesWidgetState
    extends State<LISTINGHQReviewOperativeNotesWidget> {
  late LISTINGHQReviewOperativeNotesModel _model;
  Future<Map<String, dynamic>?>? _visitDetailsFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQReviewOperativeNotesModel());

    if (widget.visitId != null && widget.visitId!.isNotEmpty) {
      _visitDetailsFuture = _fetchInitialData();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<Map<String, dynamic>?> _fetchInitialData() async {
    final token = currentAuthenticationToken ?? '';
    final detailRes = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: widget.visitId,
      authToken: token,
    );

    if (!detailRes.succeeded) return null;

    final data = (getJsonField(detailRes.jsonBody, r'$.data') as Map?) ??
        (detailRes.jsonBody is Map ? detailRes.jsonBody as Map : <String, dynamic>{});
    
    return Map<String, dynamic>.from(data);
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
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.lISTINGHQHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const LISTINGHQHeaderWidget(
                      titleText: 'Nombre de la Propiedad',
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: _visitDetailsFuture,
                      builder: (context, snapshot) {
                        if (widget.visitId != null && snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final data = snapshot.data;
                        final property = data?['property'] is Map ? data!['property'] as Map : null;
                        final owner = data?['ownerProfile'] is Map ? data!['ownerProfile'] as Map : (property?['owner'] is Map ? property!['owner'] as Map : null);
                        final lister = data?['lister'] is Map ? data!['lister'] as Map : null;
                        final report = data?['report'] is Map ? data!['report'] as Map : null;
                        final visit = data?['visit'] is Map ? data!['visit'] as Map : null;

                        final propertyName = property?['title']?.toString() ?? property?['name']?.toString() ?? 'Propiedad';
                        final operativeNote = report?['hqNote']?.toString() ?? visit?['infoHq']?.toString() ?? 'Sin notas adicionales.';
                        
                        final opFirstName = lister?['firstName']?.toString() ?? lister?['name']?.toString() ?? 'Operativo';
                        final opLastName = lister?['lastName']?.toString() ?? '';
                        
                        final ownFirstName = owner?['firstName']?.toString() ?? owner?['name']?.toString() ?? 'Propietario';
                        final ownLastName = owner?['lastName']?.toString() ?? '';

                        return custom_widgets.ListingHqReviewNotes(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          propertyName: propertyName,
                          operativeNote: operativeNote,
                          operativeName: opFirstName,
                          operativeLastName: opLastName,
                          ownerName: ownFirstName,
                          ownerLastName: ownLastName,
                          onChecklistPressed: () async {
                            // Navigate to checklist in edit mode
                            if (context.mounted) {
                              context.pushNamed('OPERATIVE_LISTING_Checklist_Form');
                            }
                          },
                          onReassignPressed: () async {
                            // Cancel current visit and navigate to reassignment
                            if (context.mounted) {
                              context.pushNamed('LISTING_HQ_PropiedadAsignada');
                            }
                          },
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 80), // Space for navbar
                ],
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
