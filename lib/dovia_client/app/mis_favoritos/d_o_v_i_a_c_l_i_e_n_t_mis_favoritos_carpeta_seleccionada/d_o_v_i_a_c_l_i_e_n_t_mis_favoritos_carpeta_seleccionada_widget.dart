import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/domain/offer_json.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_carpeta_seleccionada_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_carpeta_seleccionada_model.dart';

class DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget extends StatefulWidget {
  const DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget({
    super.key,
    required this.folderName,
    required this.folderId,
  });

  /// title for the page
  final String? folderName;

  final String? folderId;

  static String routeName = 'DOVIA_CLIENT_MisFavoritos_CarpetaSeleccionada';
  static String routePath = '/dOVIACLIENTMisFavoritosCarpetaSeleccionada';

  @override
  State<DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget> createState() =>
      _DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidgetState();
}

class _DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidgetState
    extends State<DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget> {
  late DOVIACLIENTMisFavoritosCarpetaSeleccionadaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisFavoritosCarpetaSeleccionadaModel());

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
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    20.0, 20.0, 20.0, 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.safePop();
                            },
                            child: Container(
                              width: 35.0,
                              height: 35.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: SvgPicture.asset(
                                  'assets/images/IconoVolverAtras.svg',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.none,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            valueOrDefault<String>(
                              widget.folderName,
                              'Casas en esta carpeta',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                  DOVIACLIENTMisFavoritosWidget.routeName);
                            },
                            child: Container(
                              width: 35.0,
                              height: 35.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: SvgPicture.asset(
                                  'assets/images/plus.svg',
                                  width: 24.0,
                                  height: 24.0,
                                  fit: BoxFit.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<ApiCallResponse>(
                        future: DOVIAAPIFavoriteContextGroup
                            .getFavoritesInFolderCall
                            .call(
                          authToken: currentAuthenticationToken,
                          folderId: widget.folderId,
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
                          final listViewGetFavoritesInFolderResponse =
                              snapshot.data!;

                          return Builder(
                            builder: (context) {
                              final eachFavoriteInFolder = getJsonField(
                                listViewGetFavoritesInFolderResponse.jsonBody,
                                r'''$.data.favorites''',
                              ).toList();

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: eachFavoriteInFolder.length,
                                itemBuilder:
                                    (context, eachFavoriteInFolderIndex) {
                                  final eachFavoriteInFolderItem =
                                      eachFavoriteInFolder[
                                          eachFavoriteInFolderIndex];
                                  return Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 0.0),
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
                                                  eachFavoriteInFolderItem),
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child:
                                          custom_widgets.DoviaClientHouseCard(
                                        key: Key(
                                            'Key76k_${eachFavoriteInFolderIndex}_of_${eachFavoriteInFolder.length}'),
                                        width: double.infinity,
                                        height: 0.0,
                                        imageUrl:
                                            _houseImageUrl(eachFavoriteInFolderItem),
                                        isFavorite: true,
                                        name: getJsonField(
                                                eachFavoriteInFolderItem,
                                                r'''$.name''')
                                            .toString(),
                                        type: getJsonField(
                                                eachFavoriteInFolderItem,
                                                r'''$.listingType''')
                                            .toString(),
                                        price: getJsonField(
                                                eachFavoriteInFolderItem,
                                                r'''$.price''')
                                            .toString(),
                                        propertyType: getJsonField(
                                                eachFavoriteInFolderItem,
                                                r'''$.propertyType''')
                                            ?.toString(),
                                        hasDiscount: getJsonField(
                                                eachFavoriteInFolderItem,
                                                r'''$.hasDiscount''') ==
                                            true,
                                        originalPrice: getJsonField(
                                                eachFavoriteInFolderItem,
                                                r'''$.originalPrice''')
                                            ?.toString(),
                                        constructionArea: castToType<int>(
                                            getJsonField(
                                                eachFavoriteInFolderItem,
                                                r'''$.features.general.constructionArea''')),
                                        landArea: castToType<double>(getJsonField(
                                            eachFavoriteInFolderItem,
                                            r'''$.features.general.landArea''')),
                                        bedrooms: castToType<int>(getJsonField(
                                            eachFavoriteInFolderItem,
                                            r'''$.features.general.bedrooms''')),
                                        bathrooms: castToType<int>(getJsonField(
                                            eachFavoriteInFolderItem,
                                            r'''$.features.general.bathrooms''')),
                                        propertyId: _propertyIdOf(
                                            eachFavoriteInFolderItem),
                                        authToken: currentAuthenticationToken,
                                        onRemoveFromFavorites: () async {
                                          final confirmDelete =
                                              await showDialog<bool>(
                                                    context: context,
                                                    builder:
                                                        (alertDialogContext) {
                                                      return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        elevation: 0,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(24),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              const Icon(
                                                                  Icons
                                                                      .warning_rounded,
                                                                  color: Colors
                                                                      .amber,
                                                                  size: 60),
                                                              const SizedBox(
                                                                  height: 16.0),
                                                              Text(
                                                                "¿Estás seguro que querés sacar de favoritos este inmueble?",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(),
                                                                      fontSize:
                                                                          16.0,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 24.0),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(alertDialogContext)
                                                                            .pop(false),
                                                                    child:
                                                                        const Text(
                                                                      "Cancelar",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(alertDialogContext)
                                                                            .pop(true),
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .amber,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                      "Aceptar",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ) ??
                                                  false;

                                          if (confirmDelete) {
                                            await DOVIAAPIFavoriteContextGroup
                                                .removeFavoriteFromFolderCall
                                                .call(
                                              folderId: widget.folderId,
                                              propertyId: getJsonField(
                                                      eachFavoriteInFolderItem,
                                                      r'''$.propertyId''')
                                                  .toString(),
                                              authToken:
                                                  currentAuthenticationToken,
                                            );
                                            safeSetState(() {});
                                          }
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
                    ],
                  ),
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
