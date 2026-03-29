import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/agregar_favorito_a_carpeta_widget.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_ver_mas_propiedades_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_ver_mas_propiedades_model.dart';

class DOVIACLIENTVerMasPropiedadesWidget extends StatefulWidget {
  const DOVIACLIENTVerMasPropiedadesWidget({
    super.key,
    required this.title,
  });

  final String? title;

  static String routeName = 'DOVIA_CLIENT_VerMasPropiedades';
  static String routePath = '/dOVIACLIENTVerMasPropiedades';

  @override
  State<DOVIACLIENTVerMasPropiedadesWidget> createState() =>
      _DOVIACLIENTVerMasPropiedadesWidgetState();
}

class _DOVIACLIENTVerMasPropiedadesWidgetState
    extends State<DOVIACLIENTVerMasPropiedadesWidget> {
  late DOVIACLIENTVerMasPropiedadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTVerMasPropiedadesModel());

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
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        title: widget!.title!,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: DOVIAAPIPropertyContextGroup
                                  .listPropertiesCall
                                  .call(
                                limit: '5',
                              ),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final listViewListPropertiesResponse =
                                    snapshot.data!;

                                return Builder(
                                  builder: (context) {
                                    final eachHouse = getJsonField(
                                      listViewListPropertiesResponse.jsonBody,
                                      r'''$.data''',
                                    ).toList();

                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: eachHouse.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(height: 20.0),
                                      itemBuilder: (context, eachHouseIndex) {
                                        final eachHouseItem =
                                            eachHouse[eachHouseIndex];
                                        return Builder(
                                          builder: (context) => InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                DOVIACLIENTPropiedadSeleccionadaNewWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'propertyId': serializeParam(
                                                    getJsonField(
                                                      eachHouseItem,
                                                      r'''$.id''',
                                                    ).toString(),
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            onLongPress: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return Dialog(
                                                    elevation: 0,
                                                    insetPadding:
                                                        EdgeInsets.zero,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    alignment:
                                                        AlignmentDirectional(
                                                                0.0, 0.0)
                                                            .resolve(
                                                                Directionality.of(
                                                                    context)),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(
                                                                dialogContext)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child:
                                                          AgregarFavoritoACarpetaWidget(
                                                        houseId: getJsonField(
                                                          eachHouseItem,
                                                          r'''$.id''',
                                                        ).toString(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: custom_widgets
                                                .DoviaClientHouseCard(
                                              width: 210.0,
                                              height: 0.0,
                                              imageUrl:
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                                              isFavorite: getJsonField(
                                                eachHouseItem,
                                                r'''$.isFavorite''',
                                              ),
                                              name: getJsonField(
                                                eachHouseItem,
                                                r'''$.name''',
                                              ).toString(),
                                              type: getJsonField(
                                                eachHouseItem,
                                                r'''$.listingType[0]''',
                                              ).toString(),
                                              price: getJsonField(
                                                eachHouseItem,
                                                r'''$.price''',
                                              ).toString(),
                                              onAddToFavorites: () async {
                                                if (FFAppState().UserRole != 'VISITOR') {
                                                  _model.apiResult9li =
                                                      await DOVIAAPIFavoriteContextGroup
                                                          .addPropertyToFavoritesCall
                                                          .call(
                                                    propertyId: getJsonField(
                                                      eachHouseItem,
                                                      r'''$.id''',
                                                    ).toString(),
                                                    authToken:
                                                        currentAuthenticationToken,
                                                  );

                                                  if ((_model.apiResult9li?.succeeded ?? true)) {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor: Colors.transparent,
                                                      enableDrag: false,
                                                      context: context,
                                                      builder: (context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(context).unfocus();
                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                          },
                                                          child: Padding(
                                                            padding: MediaQuery.viewInsetsOf(context),
                                                            child: TusFavoritosCarpetasModalWidget(
                                                              isCreatingNewFolderPARAM: false,
                                                              houseId: getJsonField(eachHouseItem, r'''$.id''').toString(),
                                                              propertyName: getJsonField(eachHouseItem, r'''$.name''').toString(),
                                                              propertyImage: '',
                                                              propertyIsFavorite: false,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) => safeSetState(() {}));
                                                  } else {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (alertDialogContext) {
                                                        return AlertDialog(
                                                          title: Text('Error'),
                                                          content: Text((_model.apiResult9li?.bodyText ?? '')),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(alertDialogContext),
                                                              child: Text('Ok'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                } else {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return Dialog(
                                                        elevation: 0,
                                                        insetPadding: EdgeInsets.zero,
                                                        backgroundColor: Colors.transparent,
                                                        alignment: AlignmentDirectional(0.0, 0.0)
                                                            .resolve(Directionality.of(context)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(dialogContext).unfocus();
                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                          },
                                                          child: VisitorRestrictionPopupWidget(),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                                safeSetState(() {});
                                              },
                                              onRemoveFromFavorites: () async {
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor: Colors.transparent,
                                                    enableDrag: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(context).unfocus();
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                        },
                                                        child: Padding(
                                                          padding: MediaQuery.viewInsetsOf(context),
                                                          child: TusFavoritosCarpetasModalWidget(
                                                            isCreatingNewFolderPARAM: false,
                                                            houseId: getJsonField(eachHouseItem, r'''$.id''').toString(),
                                                            propertyName: getJsonField(eachHouseItem, r'''$.name''').toString(),
                                                            propertyImage: '',
                                                            propertyIsFavorite: true,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) => safeSetState(() {}));
                                                safeSetState(() {});
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
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
