import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'form_associate_model.dart';
export 'form_associate_model.dart';

class FormAssociateWidget extends StatefulWidget {
  const FormAssociateWidget({super.key});

  static String routeName = 'FormAssociate';
  static String routePath = '/formAssociate';

  @override
  State<FormAssociateWidget> createState() => _FormAssociateWidgetState();
}

class _FormAssociateWidgetState extends State<FormAssociateWidget> {
  late FormAssociateModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormAssociateModel());

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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 40.0, 20.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.8,
                        child: custom_widgets.DoviaAssociateFormWidget(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 0.8,
                          roleBadgeText: 'Dovia Showing Associate',
                          onEnviar: () async {
                            context
                                .pushNamed(DOVIACLIENTHomePageWidget.routeName);
                          },
                          onMapPointSelected: (latitude, longitude) async {},
                          mapWidget: () => DrawMapComponentWidget(
                            onPointSelected: (latitude, longitude) async {},
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
      ),
    );
  }
}
