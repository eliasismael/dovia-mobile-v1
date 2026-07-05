import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_carpetas_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_favoritos_carpetas_model.dart';

class DOVIACLIENTMisFavoritosCarpetasWidget extends StatefulWidget {
  const DOVIACLIENTMisFavoritosCarpetasWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisFavoritos_Carpetas';
  static String routePath = '/dOVIACLIENTMisFavoritosCarpetas';

  @override
  State<DOVIACLIENTMisFavoritosCarpetasWidget> createState() =>
      _DOVIACLIENTMisFavoritosCarpetasWidgetState();
}

class _DOVIACLIENTMisFavoritosCarpetasWidgetState
    extends State<DOVIACLIENTMisFavoritosCarpetasWidget> {
  late DOVIACLIENTMisFavoritosCarpetasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisFavoritosCarpetasModel());

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
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
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
                            'Carpetas',
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
                                      padding: MediaQuery.viewInsetsOf(context),
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 0.0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          decoration: const BoxDecoration(),
                          child: FutureBuilder<ApiCallResponse>(
                            future: DOVIAAPIFavoriteContextGroup
                                .getAllFavoriteFoldersCall
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
                              final gridViewGetAllFavoriteFoldersResponse =
                                  snapshot.data!;

                              return Builder(
                                builder: (context) {
                                  final eachFolder =
                                      DOVIAAPIFavoriteContextGroup
                                              .getAllFavoriteFoldersCall
                                              .folders(
                                                gridViewGetAllFavoriteFoldersResponse
                                                    .jsonBody,
                                              )
                                              ?.toList() ??
                                          [];

                                  return GridView.builder(
                                    padding: EdgeInsets.zero,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10.0,
                                      mainAxisSpacing: 10.0,
                                      childAspectRatio: 0.8,
                                    ),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: eachFolder.length,
                                    itemBuilder: (context, eachFolderIndex) {
                                      final eachFolderItem =
                                          eachFolder[eachFolderIndex];
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                            DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget
                                                .routeName,
                                            queryParameters: {
                                              'folderName': serializeParam(
                                                getJsonField(
                                                  eachFolderItem,
                                                  r'''$.name''',
                                                ).toString(),
                                                ParamType.String,
                                              ),
                                              'folderId': serializeParam(
                                                getJsonField(
                                                  eachFolderItem,
                                                  r'''$.id''',
                                                ).toString(),
                                                ParamType.String,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Stack(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      1.0, -1.0),
                                              children: [
                                                Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          1.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                  child: GridView(
                                                    padding: EdgeInsets.zero,
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      crossAxisSpacing: 0.0,
                                                      mainAxisSpacing: 0.0,
                                                      childAspectRatio: 1.0,
                                                    ),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          'https://picsum.photos/seed/408/600',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          'https://picsum.photos/seed/40/600',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          'https://picsum.photos/seed/117/600',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          'https://picsum.photos/seed/595/600',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 5.0, 5.0, 0.0),
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      final confirmDelete =
                                                          await showDialog<
                                                                  bool>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (alertDialogContext) {
                                                                  return Dialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    elevation:
                                                                        0,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child:
                                                                        Container(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          24),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .rectangle,
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: <Widget>[
                                                                          const Icon(
                                                                              Icons.warning_rounded,
                                                                              color: Colors.redAccent,
                                                                              size: 60),
                                                                          const SizedBox(
                                                                              height: 16.0),
                                                                          Text(
                                                                            "Estás seguro que querés borrar esta carpeta. Se borrarán todos tus inmuebles guardados en ella",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.inter(),
                                                                                  fontSize: 16.0,
                                                                                ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 24.0),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              TextButton(
                                                                                onPressed: () => Navigator.of(alertDialogContext).pop(false),
                                                                                child: const Text(
                                                                                  "Cancelar",
                                                                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                                                                ),
                                                                              ),
                                                                              ElevatedButton(
                                                                                onPressed: () => Navigator.of(alertDialogContext).pop(true),
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.redAccent,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                ),
                                                                                child: const Text(
                                                                                  "Aceptar",
                                                                                  style: TextStyle(color: Colors.white, fontSize: 16),
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
                                                        final deleteResponse =
                                                            await DOVIAAPIFavoriteContextGroup
                                                                .deleteFavoriteFolderCall
                                                                .call(
                                                          folderId: getJsonField(
                                                                  eachFolderItem,
                                                                  r'''$.id''')
                                                              .toString(),
                                                          authToken:
                                                              currentAuthenticationToken,
                                                        );
                                                        if (deleteResponse
                                                            .succeeded) {
                                                          safeSetState(() {});
                                                        } else {
                                                          await showDialog(
                                                            context: context,
                                                            builder:
                                                                (alertDialogContext) {
                                                              return AlertDialog(
                                                                title:
                                                                    const Text(
                                                                        'Error'),
                                                                content: const Text(
                                                                    'No se pudo borrar la carpeta. Intentá nuevamente.'),
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
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 30.0,
                                                      height: 30.0,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        size: 20.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              getJsonField(
                                                eachFolderItem,
                                                r'''$.name''',
                                              ).toString(),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
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
