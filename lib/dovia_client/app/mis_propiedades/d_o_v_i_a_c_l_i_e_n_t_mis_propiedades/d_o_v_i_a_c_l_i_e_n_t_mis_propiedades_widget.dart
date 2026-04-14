import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/dovia_client/app/mis_favoritos/favorite_houses_card/favorite_houses_card_widget.dart';
import '/dovia_client/app/mis_propiedades/mis_propiedades_house_card/mis_propiedades_house_card_widget.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_model.dart';

class DOVIACLIENTMisPropiedadesWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisPropiedades';
  static String routePath = '/dOVIACLIENTMisPropiedades';

  @override
  State<DOVIACLIENTMisPropiedadesWidget> createState() =>
      _DOVIACLIENTMisPropiedadesWidgetState();
}

class _DOVIACLIENTMisPropiedadesWidgetState
    extends State<DOVIACLIENTMisPropiedadesWidget> {
  late DOVIACLIENTMisPropiedadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<ApiCallResponse> _fetchAllPending() async {
    final draftResult = await DOVIAAPIPropertyContextGroup.getMyPropertiesCall
        .call(status: 'DRAFT', authToken: currentAuthenticationToken);
    final inProcessResult = await DOVIAAPIPropertyContextGroup.getMyPropertiesCall
        .call(status: 'IN_PROCESS', authToken: currentAuthenticationToken);
    final pendingReviewResult = await DOVIAAPIPropertyContextGroup.getMyPropertiesCall
        .call(status: 'PENDING_REVIEW', authToken: currentAuthenticationToken);
    
    final drafts = DOVIAAPIPropertyContextGroup.getMyPropertiesCall.data(draftResult.jsonBody)?.where((e) => e != null).map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    final inProcess = DOVIAAPIPropertyContextGroup.getMyPropertiesCall.data(inProcessResult.jsonBody)?.where((e) => e != null).map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    final pendingReview = DOVIAAPIPropertyContextGroup.getMyPropertiesCall.data(pendingReviewResult.jsonBody)?.where((e) => e != null).map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    
    final combined = [...drafts, ...inProcess, ...pendingReview];

    return ApiCallResponse(
      {"data": combined},
      {},
      200,
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisPropiedadesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    // Empty state check: if user has no properties at all, redirect to ComoFunciona
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pubResult = await DOVIAAPIPropertyContextGroup.getMyPropertiesCall
          .call(status: 'PUBLISHED', authToken: currentAuthenticationToken);
      final pendingResponse = await _fetchAllPending();
      
      if (!mounted) return;

      final pubProps = DOVIAAPIPropertyContextGroup.getMyPropertiesCall.data(pubResult.jsonBody) ?? [];
      final pendProps = DOVIAAPIPropertyContextGroup.getMyPropertiesCall.data(pendingResponse.jsonBody) ?? [];

      if (pubProps.isEmpty && pendProps.isEmpty && pubResult.succeeded && pendingResponse.succeeded) {
        context.goNamed(DOVIACLIENTComoFuncionaWidget.routeName);
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
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIASHAREDHeaderWidget(
                        title: 'Mis Propiedades',
                        showMap: false,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
                      child: TextFormField(
                        controller: _model.searchController,
                        focusNode: _model.searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Búsqueda con IA...',
                          hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium,
                        onChanged: (_) => safeSetState(() {}),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 33.0, 0.0, 0.0),
                                  child: Text(
                                    'Mis Propiedades\nPublicadas',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 17.0,
                                          letterSpacing: 0.33,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(
                                      DOVIACLIENTMisPropiedadesAccionesARealizarWidget.routeName);
                                },
                                text: '+ Publicar más',
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: const Color(0x30007376),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: DOVIAAPIPropertyContextGroup
                                  .getMyPropertiesCall
                                  .call(
                                status: 'PUBLISHED',
                                authToken: currentAuthenticationToken,
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
                                final listViewGetMyPropertiesResponse =
                                    snapshot.data!;

                                return Builder(
                                  builder: (context) {
                                    final eachOwnProperty = DOVIAAPIPropertyContextGroup
                                            .getMyPropertiesCall
                                            .data(listViewGetMyPropertiesResponse.jsonBody)
                                            ?.toList() ?? [];
                                    
                                    final searchQuery = _model.searchController?.text.toLowerCase() ?? '';
                                    final filteredPublished = eachOwnProperty.where((item) {
                                      if (searchQuery.isEmpty) return true;
                                      final itemName = getJsonField(item, r'''$.name''')?.toString().toLowerCase() ?? '';
                                      return itemName.contains(searchQuery);
                                    }).toList();

                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: filteredPublished.length,
                                      itemBuilder:
                                          (context, eachOwnPropertyIndex) {
                                        final eachOwnPropertyItem =
                                            filteredPublished[
                                                eachOwnPropertyIndex];
                                        return SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: 250.0,
                                          child: GestureDetector(
                                            onTap: () {
                                              context.pushNamed(
                                                'DOVIA_CLIENT_MisPropiedades_PropiedadPublicada',
                                                pathParameters: {'propertyId': getJsonField(eachOwnPropertyItem, r'''$.id''').toString()},
                                              );
                                            },
                                            child: custom_widgets
                                                .DoviaClientHouseCard(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              height: 250.0,
                                              imageUrl:
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                                            isFavorite: getJsonField(
                                              eachOwnPropertyItem,
                                              r'''$.isFavorite''',
                                            ),
                                            onAddToFavorites: () async {
                                              if (FFAppState().UserRole !=
                                                  'VISITOR') {
                                                _model.apiResultj56 =
                                                    await DOVIAAPIFavoriteContextGroup
                                                        .addPropertyToFavoritesCall
                                                        .call(
                                                  authToken:
                                                      currentAuthenticationToken,
                                                  propertyId: getJsonField(
                                                          eachOwnPropertyItem,
                                                          r'''$.id''')
                                                      .toString(),
                                                );

                                                if ((_model.apiResultj56
                                                        ?.succeeded ??
                                                    true)) {
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    enableDrag: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Padding(
                                                          padding: MediaQuery
                                                              .viewInsetsOf(
                                                                  context),
                                                          child:
                                                              TusFavoritosCarpetasModalWidget(
                                                            isCreatingNewFolderPARAM:
                                                                false,
                                                            houseId: getJsonField(
                                                                    eachOwnPropertyItem,
                                                                    r'''$.id''')
                                                                .toString(),
                                                            propertyName: getJsonField(
                                                                    eachOwnPropertyItem,
                                                                    r'''$.name''')
                                                                .toString(),
                                                            propertyImage: '',
                                                            propertyIsFavorite:
                                                                false,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                } else {
                                                  await showDialog(
                                                    context: context,
                                                    builder:
                                                        (alertDialogContext) {
                                                      return AlertDialog(
                                                        title:
                                                            const Text('Error'),
                                                        content: Text((_model
                                                                .apiResultj56
                                                                ?.bodyText ??
                                                            '')),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    alertDialogContext),
                                                            child: const Text(
                                                                'Ok'),
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
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      alignment:
                                                          const AlignmentDirectional(
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
                                                            const VisitorRestrictionPopupWidget(),
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
                                                backgroundColor:
                                                    Colors.transparent,
                                                enableDrag: false,
                                                context: context,
                                                builder: (context) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          TusFavoritosCarpetasModalWidget(
                                                        isCreatingNewFolderPARAM:
                                                            false,
                                                        houseId: getJsonField(
                                                                eachOwnPropertyItem,
                                                                r'''$.id''')
                                                            .toString(),
                                                        propertyName: getJsonField(
                                                                eachOwnPropertyItem,
                                                                r'''$.name''')
                                                            .toString(),
                                                        propertyImage: '',
                                                        propertyIsFavorite:
                                                            true,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));
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
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 33.0, 0.0, 0.0),
                                  child: Text(
                                    'Propiedades aún no\npublicadas',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 17.0,
                                          letterSpacing: 0.33,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(
                                    DOVIACLIENTMisPropiedadesAccionesARealizarWidget
                                        .routeName,
                                  );
                                },
                                text: 'Ver estatus',
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: const Color(0x30007376),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: _fetchAllPending(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  );
                                }
                                final res = snapshot.data!;
                                final allProperties = res.jsonBody['data'] as List<dynamic>? ?? [];
                                
                                final searchQuery2 = _model.searchController?.text.toLowerCase() ?? '';
                                final filteredPending = allProperties.where((p) {
                                  final isPendingStatus = (getJsonField(p, r'''$.status''') as String?) != 'PUBLISHED';
                                  if (!isPendingStatus) return false;
                                  if (searchQuery2.isEmpty) return true;
                                  final name = getJsonField(p, r'''$.name''')?.toString().toLowerCase() ?? '';
                                  return name.contains(searchQuery2);
                                }).toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredPending.length,
                                  itemBuilder: (context, idx) {
                                    final p = filteredPending[idx];
                                    final status = getJsonField(p, r'''$.status''') as String? ?? '';
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          final visitIdFromApi = getJsonField(p, r'''$.operativeListerVisit.visitId''')?.toString();
                                          final hasVisit = visitIdFromApi != null || getJsonField(p, r'''$.lastVisitId''') != null;
                                          final finalVisitId = visitIdFromApi ?? getJsonField(p, r'''$.lastVisitId''')?.toString() ?? '';

                                          if (status == 'IN_PROCESS' || status == 'PENDING_REVIEW' || (status == 'DRAFT' && hasVisit)) {
                                            context.pushNamed(
                                              'DOVIA_CLIENT_MisPropiedades_Visita_1',
                                              queryParameters: {
                                                'visitId': serializeParam(finalVisitId, ParamType.String),
                                              },
                                            );
                                          } else if (status == 'DRAFT') {
                                            final listingTypeField = getJsonField(p, r'''$.listingType''');
                                            final listingTypeStr = listingTypeField?.toString() ?? '';
                                            PropertyPublicationType parsedType = PropertyPublicationType.SALE;
                                            String title = 'Vender';
                                            if (listingTypeStr.contains('SALE') && listingTypeStr.contains('RENT')) {
                                              parsedType = PropertyPublicationType.SALE_AND_RENT;
                                              title = 'Vender / Rentar';
                                            } else if (listingTypeStr.contains('RENT')) {
                                              parsedType = PropertyPublicationType.RENT;
                                              title = 'Rentar';
                                            }

                                            context.pushNamed(
                                              'DOVIA_CLIENT_MisPropiedades_VenderRentar',
                                              queryParameters: {
                                                'title': serializeParam(title, ParamType.String),
                                                'transactionType': serializeParam(parsedType, ParamType.Enum),
                                              },
                                            );
                                          }
                                        },
                                        child: MisPropiedadesHouseCardWidget(
                                          property: p,
                                        ),
                                      ),
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
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 100.0),
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
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTMisPropiedadesWidget.routeName,
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
