import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/favorite_houses_card/favorite_houses_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
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
                              widget!.folderName,
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
                          folderId: widget!.folderId,
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
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 20.0, 0.0, 0.0),
                                    child: FavoriteHousesCardWidget(
                                      key: Key(
                                          'Key76k_${eachFavoriteInFolderIndex}_of_${eachFavoriteInFolder.length}'),
                                      name: getJsonField(
                                        eachFavoriteInFolderItem,
                                        r'''$.name''',
                                      ).toString(),
                                      price: getJsonField(
                                        eachFavoriteInFolderItem,
                                        r'''$.price''',
                                      ).toString(),
                                      type: getJsonField(
                                        eachFavoriteInFolderItem,
                                        r'''$.listingType[0][0]''',
                                      ).toString(),
                                      onHertTap: () async {
                                        final confirmDelete = await showDialog<bool>(
                                                      context: context,
                                                      builder: (alertDialogContext) {
                                                        return Dialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          elevation: 0,
                                                          backgroundColor: Colors.transparent,
                                                          child: Container(
                                                            padding: EdgeInsets.all(24),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                Icon(Icons.warning_rounded, color: Colors.amber, size: 60),
                                                                SizedBox(height: 16.0),
                                                                Text(
                                                                  "¿Estás seguro que querés sacar de favoritos este inmueble?",
                                                                  textAlign: TextAlign.center,
                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    font: GoogleFonts.inter(),
                                                                    fontSize: 16.0,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 24.0),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    TextButton(
                                                                      onPressed: () => Navigator.of(alertDialogContext).pop(false),
                                                                      child: Text(
                                                                        "Cancelar",
                                                                        style: TextStyle(color: Colors.grey, fontSize: 16),
                                                                      ),
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed: () => Navigator.of(alertDialogContext).pop(true),
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor: Colors.amber,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                      ),
                                                                      child: Text(
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
                                                    ) ?? false;
                                        
                                        if (confirmDelete) {
                                          await DOVIAAPIFavoriteContextGroup.removePropertyFromFavoritesCall.call(
                                            propertyId: getJsonField(eachFavoriteInFolderItem, r'''$.id''').toString(),
                                            authToken: currentAuthenticationToken,
                                          );
                                          safeSetState((){});
                                        }
                                      },
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
