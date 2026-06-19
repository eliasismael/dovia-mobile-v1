import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'l_i_s_t_i_n_g_h_q_review_operative_notes_model.dart';
export 'l_i_s_t_i_n_g_h_q_review_operative_notes_model.dart';

class LISTINGHQReviewOperativeNotesWidget extends StatefulWidget {
  const LISTINGHQReviewOperativeNotesWidget({super.key});

  static String routeName = 'LISTING_HQ_Review_Operative_Notes';
  static String routePath = '/listingHqReviewOperativeNotes';

  @override
  State<LISTINGHQReviewOperativeNotesWidget> createState() =>
      _LISTINGHQReviewOperativeNotesWidgetState();
}

class _LISTINGHQReviewOperativeNotesWidgetState extends State<LISTINGHQReviewOperativeNotesWidget> {
  late LISTINGHQReviewOperativeNotesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQReviewOperativeNotesModel());

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
                    child: custom_widgets.ListingHqReviewNotes(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      propertyName: 'Nombre de la Propiedad',
                      operativeNote: 'En el pasillo principal hay una mancha de humedad que el dueño menciona que fue reparada, pero aún se ve.',
                      operativeName: 'Juan',
                      operativeLastName: 'Pérez',
                      ownerName: 'Carlos',
                      ownerLastName: 'Ruiz',
                      onChecklistPressed: () async {
                        // Navigate to checklist
                        if (context.mounted) {
                          context.pushNamed('LISTING_HQ_Propiedad');
                        }
                      },
                      onReassignPressed: () async {
                        // Navigate to reassignment or open modal
                        if (context.mounted) {
                          context.pushNamed('LISTING_HQ_Propiedad_Asignada');
                        }
                      },
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
