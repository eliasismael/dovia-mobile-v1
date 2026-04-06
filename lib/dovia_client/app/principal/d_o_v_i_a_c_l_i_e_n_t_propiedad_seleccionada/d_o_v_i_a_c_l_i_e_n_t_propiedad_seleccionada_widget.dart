import '/dovia_client/app/principal/todas_las_fotos/todas_las_fotos_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/backend/api_requests/api_properties.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_model.dart';

class DOVIACLIENTPropiedadSeleccionadaWidget extends StatefulWidget {
  const DOVIACLIENTPropiedadSeleccionadaWidget({
    super.key,
    required this.propertyId,
  });

  final String? propertyId;

  static String routeName = 'DOVIA_CLIENT_PropiedadSeleccionada';
  static String routePath = '/dOVIACLIENTPropiedadSeleccionada';

  @override
  State<DOVIACLIENTPropiedadSeleccionadaWidget> createState() =>
      _DOVIACLIENTPropiedadSeleccionadaWidgetState();
}

class _DOVIACLIENTPropiedadSeleccionadaWidgetState
    extends State<DOVIACLIENTPropiedadSeleccionadaWidget> {
  late DOVIACLIENTPropiedadSeleccionadaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _propertyName = '';

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => DOVIACLIENTPropiedadSeleccionadaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      if (widget.propertyId != null && widget.propertyId!.isNotEmpty) {
        final response = await DOVIAAPIPropertyContextGroup.getPropertyByIDCall
            .call(propertyId: widget.propertyId);
        if (response.succeeded && mounted) {
          final name = getJsonField(response.jsonBody, r'''$.data.name''')
              ?.toString();
          if (name != null && name.isNotEmpty) {
            safeSetState(() => _propertyName = name);
          }
        }
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
                child: CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        title: _propertyName.isNotEmpty
                            ? _propertyName
                            : 'Propiedad',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 1.0,
                            child: custom_widgets.PropertySelectionWidget(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              latitude: -36.0,
                              longitude: -34.0,
                              mapZoom: 5,
                              staticMapImagePath: '\"\"',
                              onAgendarCita: () async {
                                context.pushNamed(
                                  DOVIACLIENTMisPropiedadesAgendarVisitaWidget
                                      .routeName,
                                  queryParameters: {
                                    'propertyId': serializeParam(
                                      '',
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              onOfertar: () async {
                                context.pushNamed(
                                  DOVIACLIENTOfertarWidget.routeName,
                                  queryParameters: {
                                    'propertyId': serializeParam(
                                      widget!.propertyId,
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              onSeeAllImages: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: Container(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.9,
                                          child: TodasLasFotosWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
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
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 100.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIACLIENTNavbarWidget(),
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
