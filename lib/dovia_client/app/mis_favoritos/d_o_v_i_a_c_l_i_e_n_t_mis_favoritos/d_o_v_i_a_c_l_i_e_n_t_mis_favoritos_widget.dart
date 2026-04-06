import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/favorite_houses_card/favorite_houses_card_widget.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_model.dart';

class DOVIACLIENTMisFavoritosWidget extends StatefulWidget {
  const DOVIACLIENTMisFavoritosWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisFavoritos';
  static String routePath = '/dOVIACLIENTMisFavoritos';

  @override
  State<DOVIACLIENTMisFavoritosWidget> createState() =>
      _DOVIACLIENTMisFavoritosWidgetState();
}

class _DOVIACLIENTMisFavoritosWidgetState
    extends State<DOVIACLIENTMisFavoritosWidget> {
  late DOVIACLIENTMisFavoritosModel _model;
  bool _showAllDefaultFavorites = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisFavoritosModel());

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
                        title: 'Mis Favoritos',
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
                                0.0, 30.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Carpetas',
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
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      FFButtonWidget(
                                        onPressed: () {
                                          context.pushNamed(
                                              DOVIACLIENTMisFavoritosCarpetasWidget
                                                  .routeName);
                                        },
                                        text: 'Ver más',
                                        options: FFButtonOptions(
                                          height: 30.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 0.0, 20.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: Color(0x30007376),
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 0.0, 0.0, 0.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return GestureDetector(
                                                  onTap: () => FocusScope.of(
                                                          context)
                                                      .unfocus(),
                                                  child: Padding(
                                                    padding: MediaQuery
                                                        .viewInsetsOf(context),
                                                    child:
                                                        TusFavoritosCarpetasModalWidget(
                                                      isCreatingNewFolderPARAM:
                                                          true,
                                                      houseId: '',
                                                      propertyName: '',
                                                      propertyImage: '',
                                                      propertyIsFavorite: false,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).then((value) =>
                                                safeSetState(() {}));
                                          },
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              height: 180,
                              child: FutureBuilder<ApiCallResponse>(
                                future: DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall.call(
                                  authToken: currentAuthenticationToken,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final gridViewGetAllFavoriteFoldersResponse = snapshot.data!;
                                  final eachFolder = DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall.folders(
                                    gridViewGetAllFavoriteFoldersResponse.jsonBody,
                                  )?.toList() ?? [];

                                  if (eachFolder.isEmpty) {
                                    return const Center(child: Text("No tenés carpetas de favoritos todavía"));
                                  }

                                  return ListView.separated(
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: eachFolder.length,
                                    separatorBuilder: (context, _) => const SizedBox(width: 15),
                                    itemBuilder: (context, eachFolderIndex) {
                                      final eachFolderItem = eachFolder[eachFolderIndex];
                                      return InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                            DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget.routeName,
                                            queryParameters: {
                                              'folderName': serializeParam(
                                                getJsonField(eachFolderItem, r'''$.name''').toString(),
                                                ParamType.String,
                                              ),
                                              'folderId': serializeParam(
                                                getJsonField(eachFolderItem, r'''$.id''').toString(),
                                                ParamType.String,
                                              ),
                                            }.withoutNulls,
                                          ).then((_) => safeSetState(() {}));
                                        },
                                        child: SizedBox(
                                          width: 140,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15.0),
                                                  child: Container(
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    child: GridView(
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                      ),
                                                      children: [
                                                        Image.network('https://picsum.photos/seed/${eachFolderIndex}1/200/200', fit: BoxFit.cover),
                                                        Image.network('https://picsum.photos/seed/${eachFolderIndex}2/200/200', fit: BoxFit.cover),
                                                        Image.network('https://picsum.photos/seed/${eachFolderIndex}3/200/200', fit: BoxFit.cover),
                                                        Image.network('https://picsum.photos/seed/${eachFolderIndex}4/200/200', fit: BoxFit.cover),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                getJsonField(eachFolderItem, r'''$.name''').toString(),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 30.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Favoritos sin carpeta',
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
                                FFButtonWidget(
                                  onPressed: () {
                                    setState(() {
                                      _showAllDefaultFavorites =
                                          !_showAllDefaultFavorites;
                                    });
                                  },
                                  text: _showAllDefaultFavorites
                                      ? 'Ver menos'
                                      : 'Ver más',
                                  options: FFButtonOptions(
                                    height: 30.0,
                                    padding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 20.0, 0.0),
                                    iconPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                    color: Color(0x30007376),
                                    textStyle: FlutterFlowTheme.of(
                                            context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderRadius:
                                        BorderRadius.circular(24.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder<ApiCallResponse>(
                            future: DOVIAAPIFavoriteContextGroup
                                .getDefaultFavoritesCall
                                .call(
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final listViewGetDefaultFavoritesResponse =
                                  snapshot.data!;

                              return Builder(
                                builder: (context) {
                                  final favoriteHouse =
                                      DOVIAAPIFavoriteContextGroup
                                              .getDefaultFavoritesCall
                                              .data(
                                                listViewGetDefaultFavoritesResponse
                                                    .jsonBody,
                                              )
                                              ?.toList() ??
                                          [];

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: _showAllDefaultFavorites
                                        ? favoriteHouse.length
                                        : ((favoriteHouse.length > 3)
                                            ? 3
                                            : favoriteHouse.length),
                                    itemBuilder: (context, favoriteHouseIndex) {
                                      final favoriteHouseItem =
                                          favoriteHouse[favoriteHouseIndex];
                                      return Builder(
                                        builder: (context) => Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 20.0, 0.0, 0.0),
                                          child: FavoriteHousesCardWidget(
                                            key: Key(
                                                'Keyq7t_${favoriteHouseIndex}_of_${favoriteHouse.length}'),
                                            name: getJsonField(
                                              favoriteHouseItem,
                                              r'''$.name''',
                                            ).toString(),
                                            price: getJsonField(
                                              favoriteHouseItem,
                                              r'''$.price''',
                                            ).toString(),
                                            type: getJsonField(
                                              favoriteHouseItem,
                                              r'''$.listingType[0][0]''',
                                            ).toString(),
                                            onHertTap: () async {
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
                                                          TusFavoritosCarpetasModalWidget(
                                                        isCreatingNewFolderPARAM:
                                                            false,
                                                        houseId: getJsonField(
                                                          favoriteHouseItem,
                                                          r'''$.id''',
                                                        ).toString(),
                                                        propertyName:
                                                            getJsonField(
                                                          favoriteHouseItem,
                                                          r'''$.name''',
                                                        ).toString(),
                                                        propertyImage: '',
                                                        propertyIsFavorite:
                                                            true,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.primaryButtonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: PrimaryButtonWidget(
                                text: 'Crear carpeta',
                                onTap: () async {
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
                                          child:
                                              TusFavoritosCarpetasModalWidget(
                                            isCreatingNewFolderPARAM: true,
                                            houseId: '-',
                                            propertyName: '-',
                                            propertyImage: '',
                                            propertyIsFavorite: false,
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                              ),
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
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTMisFavoritosWidget.routeName,
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
