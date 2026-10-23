import '/domain/property_location.dart';
import '/shared_components/dovia_bottom_sheet/dovia_bottom_sheet.dart';
import '/shared_components/error_state/error_state_widget.dart';
import '/shared_components/favorite_folder_collage/favorite_folder_collage_widget.dart';
import '/domain/offer_json.dart' show firstPropertyPhotoUrl;
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
import '/shared_components/dovia_spinner.dart';
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

  /// Separa el spinner y el aviso de vacío del título de la sección, que
  /// quedaban pegados a él.
  static const _emptyStatePadding = EdgeInsets.only(top: 48.0, bottom: 24.0);

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

  /// Foto principal de la casa para el modal de carpetas de favoritos.
  String _modalImage(dynamic house) => house is Map
      ? firstPropertyPhotoUrl(Map<String, dynamic>.from(house)) ?? ''
      : '';

  /// "Ver más" como texto sin fondo, igual que en Mis Visitas y Mis Ofertas.
  Widget _verMasLink({required VoidCallback onTap, required String text}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primary,
              fontSize: 14.0,
            ),
      ),
    );
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
                        showLogo: true,
                        showSupport: false,
                        title: 'Mis Favoritos',
                        showCurrency: false,
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
                                    _verMasLink(
                                      onTap: () {
                                        context.pushNamed(
                                            DOVIACLIENTMisFavoritosCarpetasWidget
                                                .routeName);
                                      },
                                      text: 'Ver más',
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
                                    return const Center(child: DoviaSpinner());
                                  }
                                  final gridViewGetAllFavoriteFoldersResponse =
                                      snapshot.data!;
                                  // Sin conexión o con el servidor caído se avisa y se deja
                                  // reintentar, en vez de mostrar la lista vacía.
                                  if (isRetryableLoadError(
                                      gridViewGetAllFavoriteFoldersResponse)) {
                                    return ErrorStateWidget.fromResponse(
                                        gridViewGetAllFavoriteFoldersResponse,
                                        onRetry: () => safeSetState(() {}));
                                  }
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
                                        child: Text("Aún no tienes carpetas"));
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
                                                    child:
                                                        FavoriteFolderCollageWidget(
                                                      folderId: getJsonField(
                                                              eachFolderItem,
                                                              r'''$.id''')
                                                          .toString(),
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
                                0.0, 20.0, 0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.primaryButtonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: PrimaryButtonWidget(
                                text: 'Crear carpeta',
                                onTap: () {
                                  // Sin await: el botón no queda con spinner
                                  // mientras el modal está abierto.
                                  showDoviaBottomSheet(
                                    context,
                                    child:
                                        const TusFavoritosCarpetasModalWidget(
                                      isCreatingNewFolderPARAM: true,
                                      houseId: '-',
                                      propertyName: '-',
                                      propertyImage: '',
                                      propertyIsFavorite: false,
                                    ),
                                  ).then((value) => safeSetState(() {}));
                                  return Future.value();
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
                                _verMasLink(
                                  onTap: () {
                                    setState(() {
                                      _showAllDefaultFavorites =
                                          !_showAllDefaultFavorites;
                                    });
                                  },
                                  text: _showAllDefaultFavorites
                                      ? 'Ver menos'
                                      : 'Ver más',
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder<ApiCallResponse>(
                            future: DOVIAAPIFavoriteContextGroup
                                .getDefaultFavoritesCall
                                .call(
                              authToken: currentAuthenticationToken,
                              // El backend pagina de a 20 por defecto y "Ver
                              // más" sólo despliega lo ya traído: con más de
                              // 20 favoritos los siguientes no aparecían. 100
                              // es el máximo que aceptan los listados.
                              limit: '100',
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: _emptyStatePadding,
                                  child: Center(child: DoviaSpinner()),
                                );
                              }
                              final listViewGetDefaultFavoritesResponse =
                                  snapshot.data!;
                              // Sin conexión o con el servidor caído se avisa y se deja
                              // reintentar, en vez de mostrar la lista vacía.
                              if (isRetryableLoadError(
                                  listViewGetDefaultFavoritesResponse)) {
                                return ErrorStateWidget.fromResponse(
                                    listViewGetDefaultFavoritesResponse,
                                    onRetry: () => safeSetState(() {}));
                              }

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

                                  if (favoriteHouse.isEmpty) {
                                    return const Padding(
                                      padding: _emptyStatePadding,
                                      child: Center(
                                          child:
                                              Text('Aún no tienes favoritos')),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    // Crece dentro del scroll de la pantalla:
                                    // sin scroll propio, el gesto sobre una
                                    // tarjeta mueve la página.
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                              imageUrl: _houseImageUrl(
                                                  favoriteHouseItem),
                                              isFavorite: true,
                                              name: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.name''')
                                                  .toString(),
                                              type: getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.listingType''')
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
                                              location: propertyLocationLabel(
                                                  favoriteHouseItem),
                                              parkingSpots: castToType<int>(
                                                  getJsonField(
                                                      favoriteHouseItem,
                                                      r'''$.features.general.parkingSpots''')),
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
                                                          propertyImage:
                                                              _modalImage(
                                                                  favoriteHouseItem),
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
                            0.0, 0.0, 15.0, 12.0),
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
