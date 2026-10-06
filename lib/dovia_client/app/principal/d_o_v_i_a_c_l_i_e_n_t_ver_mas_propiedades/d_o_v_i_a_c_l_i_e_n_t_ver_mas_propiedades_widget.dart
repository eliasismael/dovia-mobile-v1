import '/domain/property_owner.dart';
import '/shared_components/error_state/error_state_widget.dart';
import '/domain/offer_json.dart' show firstPropertyPhotoUrl;
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/agregar_favorito_a_carpeta_widget.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/domain/offer_json.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_ver_mas_propiedades_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_ver_mas_propiedades_model.dart';

class DOVIACLIENTVerMasPropiedadesWidget extends StatefulWidget {
  const DOVIACLIENTVerMasPropiedadesWidget({
    super.key,
    required this.title,
    this.listingFilter,
  });

  final String? title;

  /// 'comprar', 'rentar' o vacío: el mismo filtro que tenía el home.
  final String? listingFilter;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await loadOwnPropertyIds();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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

  bool _matchesListingFilter(dynamic house) {
    final selected = widget.listingFilter ?? '';
    if (selected.isEmpty) return true;
    final wanted = selected == 'rentar' ? 'RENT' : 'SALE';
    final listingType = getJsonField(house, r'''$.listingType''');
    if (listingType is List) {
      return listingType
          .any((type) => type.toString().toUpperCase().contains(wanted));
    }
    return listingType.toString().toUpperCase().contains(wanted);
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
                      child: DOVIASHAREDHeaderWidget(
                        title: widget.title!,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12.0, 0.0, 12.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: DOVIAAPIPropertyContextGroup
                                  .listPropertiesCall
                                  .call(
                                // La misma consulta que los carruseles del
                                // home: acá se ven todas de una, hacia abajo.
                                limit: '40',
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
                                final listViewListPropertiesResponse =
                                    snapshot.data!;
                                // Sin conexión o con el servidor caído se avisa y se deja
                                // reintentar, en vez de mostrar la lista vacía.
                                if (isRetryableLoadError(listViewListPropertiesResponse)) {
                                  return ErrorStateWidget.fromResponse(listViewListPropertiesResponse,
                                      onRetry: () => safeSetState(() {}));
                                }

                                return Builder(
                                  builder: (context) {
                                    final eachHouse = getJsonField(
                                      listViewListPropertiesResponse.jsonBody,
                                      r'''$.data''',
                                    )
                                        .toList()
                                        .where((h) => !isOwnProperty(h))
                                        .where(_matchesListingFilter)
                                        .toList();

                                    // Dos tarjetas por fila.
                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: (eachHouse.length + 1) ~/ 2,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 16.0),
                                      itemBuilder: (context, rowIndex) {
                                        Widget cell(int eachHouseIndex) {
                                          final eachHouseItem =
                                              eachHouse[eachHouseIndex];
                                          return Builder(
                                            builder: (context) => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(
                                                  DOVIACLIENTPropiedadSeleccionadaNewWidget
                                                      .routeName,
                                                  queryParameters: {
                                                    'propertyId':
                                                        serializeParam(
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
                                                width: double.infinity,
                                                height: 0.0,
                                                compact: true,
                                                imageUrl: _houseImageUrl(
                                                    eachHouseItem),
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
                                                  r'''$.listingType''',
                                                ).toString(),
                                                price: getJsonField(
                                                  eachHouseItem,
                                                  r'''$.price''',
                                                ).toString(),
                                                constructionArea: castToType<
                                                        int>(
                                                    getJsonField(eachHouseItem,
                                                        r'''$.features.general.constructionArea''')),
                                                landArea: castToType<double>(
                                                    getJsonField(eachHouseItem,
                                                        r'''$.features.general.landArea''')),
                                                bedrooms: castToType<int>(
                                                    getJsonField(eachHouseItem,
                                                        r'''$.features.general.bedrooms''')),
                                                bathrooms: castToType<int>(
                                                    getJsonField(eachHouseItem,
                                                        r'''$.features.general.bathrooms''')),
                                                onAddToFavorites: () async {
                                                  if (FFAppState().UserRole !=
                                                      'VISITOR') {
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

                                                    if ((_model.apiResult9li
                                                            ?.succeeded ??
                                                        true)) {
                                                      if (!context.mounted) return;
                                                      await showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        enableDrag: false,
                                                        context: context,
                                                        builder: (context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      context)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
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
                                                                        eachHouseItem,
                                                                        r'''$.id''')
                                                                    .toString(),
                                                                propertyName: getJsonField(
                                                                        eachHouseItem,
                                                                        r'''$.name''')
                                                                    .toString(),
                                                                propertyImage:
                                                                    _modalImage(
                                                                        eachHouseItem),
                                                                propertyIsFavorite:
                                                                    false,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) =>
                                                          safeSetState(() {}));
                                                    } else {
                                                      if (!context.mounted) return;
                                                      await showDialog(
                                                        context: context,
                                                        builder:
                                                            (alertDialogContext) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Error'),
                                                            content: Text((_model
                                                                    .apiResult9li
                                                                    ?.bodyText ??
                                                                '')),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        alertDialogContext),
                                                                child:
                                                                    const Text(
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
                                                              Colors
                                                                  .transparent,
                                                          alignment: const AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      dialogContext)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
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
                                                onRemoveFromFavorites:
                                                    () async {
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
                                                                    eachHouseItem,
                                                                    r'''$.id''')
                                                                .toString(),
                                                            propertyName: getJsonField(
                                                                    eachHouseItem,
                                                                    r'''$.name''')
                                                                .toString(),
                                                            propertyImage:
                                                                _modalImage(
                                                                    eachHouseItem),
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
                                        }

                                        final first = rowIndex * 2;
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: cell(first)),
                                            const SizedBox(width: 10.0),
                                            Expanded(
                                              child:
                                                  first + 1 < eachHouse.length
                                                      ? cell(first + 1)
                                                      : const SizedBox(),
                                            ),
                                          ],
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
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
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
