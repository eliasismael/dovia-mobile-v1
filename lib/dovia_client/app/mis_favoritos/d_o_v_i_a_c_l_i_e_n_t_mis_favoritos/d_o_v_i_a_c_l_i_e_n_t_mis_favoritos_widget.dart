import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/domain/offer_json.dart';
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

  /// El favorito trae su propio id; el de la propiedad viaja en `propertyId`
  /// y es el que espera el detalle. Algunas respuestas solo mandan `id`, asi
  /// que sirve de respaldo.
  String _propertyIdOf(dynamic item) {
    final propertyId =
        getJsonField(item, r'''$.propertyId''')?.toString() ?? '';
    if (propertyId.isNotEmpty && propertyId != 'null') {
      return propertyId;
    }
    return getJsonField(item, r'''$.id''').toString();
  }

  /// Foto principal que manda el backend para la propiedad. Cuando no viene
  /// ninguna, la tarjeta se queda con su imagen por defecto.
  String _houseImageUrl(dynamic house) {
    if (house is! Map) {
      return '';
    }
    return firstPropertyPhotoUrl(Map<String, dynamic>.from(house)) ?? '';
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
                        title: 'Mis Favoritos',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 30.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
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
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(20.0, 0.0, 20.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: const Color(0x30007376),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
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
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              8.0, 0.0, 0.0, 0.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () =>
                                                    FocusScope.of(context)
                                                        .unfocus(),
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      const TusFavoritosCarpetasModalWidget(
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
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Container(
                                          width: 30.0,
                                          height: 30.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
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
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              height: 180,
                              child: FutureBuilder<ApiCallResponse>(
                                future: DOVIAAPIFavoriteContextGroup
                                    .getAllFavoriteFoldersCall
                                    .call(
                                  authToken: currentAuthenticationToken,
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final gridViewGetAllFavoriteFoldersResponse =
                                      snapshot.data!;
                                  final eachFolder =
                                      DOVIAAPIFavoriteContextGroup
                                              .getAllFavoriteFoldersCall
                                              .folders(
                                                gridViewGetAllFavoriteFoldersResponse
                                                    .jsonBody,
                                              )
                                              ?.toList() ??
                                          [];

                                  if (eachFolder.isEmpty) {
                                    return const Center(
                                        child: Text(
                                            "No tenés carpetas de favoritos todavía"));
                                  }

                                  return ListView.separated(
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: eachFolder.length,
                                    separatorBuilder: (context, _) =>
                                        const SizedBox(width: 15),
                                    itemBuilder: (context, eachFolderIndex) {
                                      final eachFolderItem =
                                          eachFolder[eachFolderIndex];
                                      return InkWell(
                                        onTap: () {
                                          context
                                              .pushNamed(
                                                DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'folderName': serializeParam(
                                                    getJsonField(eachFolderItem,
                                                            r'''$.name''')
                                                        .toString(),
                                                    ParamType.String,
                                                  ),
                                                  'folderId': serializeParam(
                                                    getJsonField(eachFolderItem,
                                                            r'''$.id''')
                                                        .toString(),
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              )
                                              .then((_) => safeSetState(() {}));
                                        },
                                        child: SizedBox(
                                          width: 140,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Container(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    child: GridView(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                      ),
                                                      children: [
                                                        Image.network(
                                                            'https://picsum.photos/seed/${eachFolderIndex}1/200/200',
                                                            fit: BoxFit.cover),
                                                        Image.network(
                                                            'https://picsum.photos/seed/${eachFolderIndex}2/200/200',
                                                            fit: BoxFit.cover),
                                                        Image.network(
                                                            'https://picsum.photos/seed/${eachFolderIndex}3/200/200',
                                                            fit: BoxFit.cover),
                                                        Image.network(
                                                            'https://picsum.photos/seed/${eachFolderIndex}4/200/200',
                                                            fit: BoxFit.cover),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                getJsonField(eachFolderItem,
                                                        r'''$.name''')
                                                    .toString(),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600),
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
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 30.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
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
                                        const EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 20.0, 0.0),
                                    iconPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                    color: const Color(0x30007376),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
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
                                    borderRadius: BorderRadius.circular(24.0),
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
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                          child: InkWell(
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
                                                    _propertyIdOf(
                                                        favoriteHouseItem),
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            child: custom_widgets
                                                .DoviaClientHouseCard(
                                              key: Key(
                                                  'Keyq7t_${favoriteHouseIndex}_of_${favoriteHouse.length}'),
                                              width: double.infinity,
                                              height: 0.0,
                                              imageUrl:
                                                  _houseImageUrl(favoriteHouseItem),
                                              isFavorite: true,
                                              name: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.name''')
                                                  .toString(),
                                              type: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.listingType[0]''')
                                                  .toString(),
                                              price: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.price''')
                                                  .toString(),
                                              propertyType: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.propertyType''')
                                                  ?.toString(),
                                              hasDiscount: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.hasDiscount''') ==
                                                  true,
                                              originalPrice: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.originalPrice''')
                                                  ?.toString(),
                                              constructionArea: castToType<int>(
                                                  getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.features.general.constructionArea''')),
                                              landArea: castToType<double>(
                                                  getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.features.general.landArea''')),
                                              bedrooms: castToType<int>(
                                                  getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.features.general.bedrooms''')),
                                              bathrooms: castToType<int>(
                                                  getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.features.general.bathrooms''')),
                                              propertyId: _propertyIdOf(
                                                  favoriteHouseItem),
                                              authToken:
                                                  currentAuthenticationToken,
                                              onRemoveFromFavorites: () async {
                                                // El modal de carpetas se
                                                // presenta desde abajo, como en
                                                // el resto de la app.
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
                                                          houseId: _propertyIdOf(
                                                              favoriteHouseItem),
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
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                            ),
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
                            padding: const EdgeInsetsDirectional.fromSTEB(
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
                                              const TusFavoritosCarpetasModalWidget(
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
