import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'agregar_favorito_a_carpeta_model.dart';
export 'agregar_favorito_a_carpeta_model.dart';

class AgregarFavoritoACarpetaWidget extends StatefulWidget {
  const AgregarFavoritoACarpetaWidget({
    super.key,
    required this.houseId,
  });

  final String? houseId;

  @override
  State<AgregarFavoritoACarpetaWidget> createState() =>
      _AgregarFavoritoACarpetaWidgetState();
}

class _AgregarFavoritoACarpetaWidgetState
    extends State<AgregarFavoritoACarpetaWidget> {
  late AgregarFavoritoACarpetaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgregarFavoritoACarpetaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Elige a qué carpeta agregar la pripiedad',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: FutureBuilder<ApiCallResponse>(
                future:
                    DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall.call(
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
                  final listViewGetAllFavoriteFoldersResponse = snapshot.data!;

                  return Builder(
                    builder: (context) {
                      final eachFolder =
                          DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall
                                  .folders(
                                    listViewGetAllFavoriteFoldersResponse
                                        .jsonBody,
                                  )
                                  ?.toList() ??
                              [];

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          20.0,
                        ),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: eachFolder.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.0),
                        itemBuilder: (context, eachFolderIndex) {
                          final eachFolderItem = eachFolder[eachFolderIndex];
                          return Builder(
                            builder: (context) => wrapWithModel(
                              model: _model.primaryButtonModels.getModel(
                                getJsonField(
                                  eachFolderItem,
                                  r'''$.id''',
                                ).toString(),
                                eachFolderIndex,
                              ),
                              updateCallback: () => safeSetState(() {}),
                              child: PrimaryButtonWidget(
                                key: Key(
                                  'Keyq15_${getJsonField(
                                    eachFolderItem,
                                    r'''$.id''',
                                  ).toString()}',
                                ),
                                text: getJsonField(
                                  eachFolderItem,
                                  r'''$.name''',
                                ).toString(),
                                onTap: () async {
                                  _model.apiResultv19 =
                                      await DOVIAAPIFavoriteContextGroup
                                          .addPropertyToFavoritesCall
                                          .call(
                                    authToken: currentAuthenticationToken,
                                    propertyId: widget!.houseId,
                                    folderId: getJsonField(
                                      eachFolderItem,
                                      r'''$.id''',
                                    ).toString(),
                                  );

                                  if ((_model.apiResultv19?.succeeded ??
                                      true)) {
                                    await showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                          alignment: AlignmentDirectional(
                                                  0.0, 0.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          child: Container(
                                            height: 400.0,
                                            width: 80.0,
                                            child: PopupExitoWidget(
                                              title: 'Se agregó con éxito',
                                              text:
                                                  'La propiedad se agregó con éxito a la carpeta ${getJsonField(
                                                eachFolderItem,
                                                r'''$.name''',
                                              ).toString()}',
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return AlertDialog(
                                          title: Text('error'),
                                          content: Text(
                                              (_model.apiResultv19?.jsonBody ??
                                                      '')
                                                  .toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }

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
            wrapWithModel(
              model: _model.secondaryButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: SecondaryButtonWidget(
                text: 'Cancelar',
                onTap: () async {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
