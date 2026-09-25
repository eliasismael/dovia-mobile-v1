import '/shared_components/favorite_folder_collage/favorite_folder_collage_widget.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpeta_creada_modal/tus_favoritos_carpeta_creada_modal_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tus_favoritos_carpetas_modal_model.dart';
export 'tus_favoritos_carpetas_modal_model.dart';

class TusFavoritosCarpetasModalWidget extends StatefulWidget {
  const TusFavoritosCarpetasModalWidget({
    super.key,
    required this.isCreatingNewFolderPARAM,
    required this.houseId,
    required this.propertyName,
    this.propertyImage,
    required this.propertyIsFavorite,
  });

  final bool? isCreatingNewFolderPARAM;
  final String? houseId;
  final String? propertyName;
  final String? propertyImage;
  final bool? propertyIsFavorite;

  @override
  State<TusFavoritosCarpetasModalWidget> createState() =>
      _TusFavoritosCarpetasModalWidgetState();
}

class _TusFavoritosCarpetasModalWidgetState
    extends State<TusFavoritosCarpetasModalWidget> {
  late TusFavoritosCarpetasModalModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TusFavoritosCarpetasModalModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Si la casa sigue en favoritos. Se cambia desde el corazón de arriba sin
  /// cerrar el modal, así se puede volver a agregar ahí mismo; la pantalla de
  /// atrás recién la saca de la lista al cerrarlo, cuando vuelve a cargar.
  late bool _isFavorite = widget.propertyIsFavorite ?? true;
  final _foldersScroll = ScrollController();
  bool _togglingFavorite = false;

  bool get _hasProperty {
    final id = widget.houseId?.trim() ?? '';
    return id.isNotEmpty && id != '-';
  }

  Widget _propertyPhoto({required double width, required double height}) {
    const fallback = 'assets/images/casa_card_sobreMiVisita.png';
    final url = widget.propertyImage?.trim() ?? '';
    if (url.isEmpty) {
      return Image.asset(fallback,
          width: width, height: height, fit: BoxFit.cover);
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(fallback,
          width: width, height: height, fit: BoxFit.cover),
    );
  }

  // Carpeta que se está guardando/quitando: muestra un spinner en su botón.
  String? _busyFolderId;
  bool _creatingFolder = false;

  /// Se tocó Guardar sin nombre: el campo se muestra en error.
  bool _nameMissing = false;

  static const Color _aqua = Color(0xFF007376);

  Widget _folderToggle({required bool checked, required bool busy}) {
    return Container(
      width: 34.0,
      height: 34.0,
      decoration: BoxDecoration(
        color: checked ? _aqua : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _aqua, width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: busy
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: checked ? Colors.white : _aqua,
              ),
            )
          : Icon(
              checked ? Icons.check_rounded : Icons.add_rounded,
              size: 20,
              color: checked ? Colors.white : _aqua,
            ),
    );
  }

  Future<void> _showFolderNotice(String title, String message) {
    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.folder_copy_outlined,
                    color: Color(0xFFE08A00), size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00444B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _aqua,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _folderNameExists(String name) async {
    final res = await DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall
        .call(authToken: currentAuthenticationToken);
    final names = DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall
            .folderName(res.jsonBody) ??
        const <String>[];
    final wanted = name.trim().toLowerCase();
    return names.any((n) => n.trim().toLowerCase() == wanted);
  }

  Future<void> _toggleFavorite() async {
    final propertyId = widget.houseId;
    if (_togglingFavorite || propertyId == null || propertyId.isEmpty) return;
    _togglingFavorite = true;
    final wasFavorite = _isFavorite;
    safeSetState(() => _isFavorite = !wasFavorite);
    final res = wasFavorite
        ? await DOVIAAPIFavoriteContextGroup.removePropertyFromFavoritesCall
            .call(
            propertyId: propertyId,
            authToken: currentAuthenticationToken,
          )
        : await DOVIAAPIFavoriteContextGroup.addPropertyToFavoritesCall.call(
            propertyId: propertyId,
            authToken: currentAuthenticationToken,
          );
    _togglingFavorite = false;
    if (!mounted) return;
    if (!res.succeeded) {
      safeSetState(() => _isFavorite = wasFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasFavorite
              ? 'No se pudo quitar de favoritos.'
              : 'No se pudo agregar a favoritos.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _foldersScroll.dispose();
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        // Recibe una casa que miuestra rriba, abajo las carpetas, en el mas selecciona a que carpetas agregarlas
        FutureBuilder<ApiCallResponse>(
      future: DOVIAAPIFavoriteContextGroup.checkIfPropertyIsFavoritedCall.call(
        propertyId: widget.houseId,
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
        final containerCheckIfPropertyIsFavoritedResponse = snapshot.data!;

        return Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          // La lista de carpetas ocupa media pantalla; crear una carpeta
          // desde cero mide sólo lo que ocupa el formulario.
          height: widget.isCreatingNewFolderPARAM == true ||
                  _model.isCreatingNewFolder
              ? null
              : MediaQuery.sizeOf(context).height * 0.5,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(
                  0.0,
                  2.0,
                ),
              )
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0),
              topLeft: Radius.circular(32.0),
              topRight: Radius.circular(32.0),
            ),
          ),
          // El contenido termina sobre los botones de Android, no detrás.
          child: SafeArea(
            top: false,
            child: Builder(
              builder: (context) {
                if (widget.isCreatingNewFolderPARAM != true &&
                    !_model.isCreatingNewFolder) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 20.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 10.0, 20.0, 20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 10.0, 0.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: _propertyPhoto(
                                          width: 96.0,
                                          height: 72.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Text(
                                            valueOrDefault<String>(
                                              widget.propertyName,
                                              '[propertyName]',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
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
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              )),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: _toggleFavorite,
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: _isFavorite
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : null,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: SvgPicture.asset(
                                      _isFavorite
                                          ? 'assets/images/whiteHeart.svg'
                                          : 'assets/images/plus.svg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Solo la lista de carpetas se desplaza; lo de arriba queda fijo.
                        Expanded(
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDEDED),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            20.0, 20.0, 20.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Carpetas ',
                                          style: FlutterFlowTheme.of(context)
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
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () async {
                                            _model.isCreatingNewFolder = true;
                                            safeSetState(() {});
                                          },
                                          text: 'Nueva carpeta',
                                          options: FFButtonOptions(
                                            height: 30.0,
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: const Color(0xFF1CA9A9),
                                            textStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts.publicSans(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 20.0, 0.0, 0.0),
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
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          final listViewGetAllFavoriteFoldersResponse =
                                              snapshot.data!;

                                          return Builder(
                                            builder: (context) {
                                              final eachFolder =
                                                  DOVIAAPIFavoriteContextGroup
                                                          .getAllFavoriteFoldersCall
                                                          .folders(
                                                            listViewGetAllFavoriteFoldersResponse
                                                                .jsonBody,
                                                          )
                                                          ?.toList() ??
                                                      [];

                                              // La barra lateral siempre visible
                                              // avisa que hay más carpetas abajo.
                                              return Scrollbar(
                                                controller: _foldersScroll,
                                                thumbVisibility: true,
                                                child: ListView.builder(
                                                  controller: _foldersScroll,
                                                  padding: EdgeInsets.zero,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: eachFolder.length,
                                                  itemBuilder: (context,
                                                      eachFolderIndex) {
                                                    final eachFolderItem =
                                                        eachFolder[
                                                            eachFolderIndex];
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(20.0,
                                                              20.0, 20.0, 0.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          10.0,
                                                                          0.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          96.0,
                                                                      height:
                                                                          72.0,
                                                                      child:
                                                                          FavoriteFolderCollageWidget(
                                                                        folderId:
                                                                            getJsonField(eachFolderItem, r'''$.id''').toString(),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          const AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                      child:
                                                                          Text(
                                                                        getJsonField(
                                                                          eachFolderItem,
                                                                          r'''$.name''',
                                                                        ).toString(),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.inter(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                              ],
                                                            ),
                                                          )),
                                                          Builder(
                                                            builder: (context) {
                                                              if ((DOVIAAPIFavoriteContextGroup
                                                                      .checkIfPropertyIsFavoritedCall
                                                                      .foledersStoredIn(
                                                                containerCheckIfPropertyIsFavoritedResponse
                                                                    .jsonBody,
                                                              )!)
                                                                  .toList()
                                                                  .contains(
                                                                      getJsonField(
                                                                    eachFolderItem,
                                                                    r'''$.id''',
                                                                  ).toString())) {
                                                                // Ya esta en la
                                                                // carpeta: el mismo
                                                                // control la saca.
                                                                return InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    if (_busyFolderId !=
                                                                        null) {
                                                                      return;
                                                                    }
                                                                    safeSetState(() =>
                                                                        _busyFolderId =
                                                                            getJsonField(
                                                                          eachFolderItem,
                                                                          r'''$.id''',
                                                                        ).toString());
                                                                    final removeResult =
                                                                        await DOVIAAPIFavoriteContextGroup
                                                                            .removeFavoriteFromFolderCall
                                                                            .call(
                                                                      authToken:
                                                                          currentAuthenticationToken,
                                                                      folderId:
                                                                          getJsonField(
                                                                        eachFolderItem,
                                                                        r'''$.id''',
                                                                      ).toString(),
                                                                      propertyId:
                                                                          widget
                                                                              .houseId,
                                                                    );

                                                                    _busyFolderId =
                                                                        null;
                                                                    FavoriteFolderCollageWidget
                                                                        .invalidate();
                                                                    if (!removeResult
                                                                        .succeeded) {
                                                                      await showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (alertDialogContext) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                const Text('error'),
                                                                            content:
                                                                                Text((removeResult.jsonBody ?? '').toString()),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () => Navigator.pop(alertDialogContext),
                                                                                child: const Text('Ok'),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    }

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      _folderToggle(
                                                                    checked:
                                                                        true,
                                                                    busy: _busyFolderId ==
                                                                        getJsonField(
                                                                          eachFolderItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                  ),
                                                                );
                                                              } else {
                                                                return InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    if (_busyFolderId !=
                                                                        null) {
                                                                      return;
                                                                    }
                                                                    safeSetState(() =>
                                                                        _busyFolderId =
                                                                            getJsonField(
                                                                          eachFolderItem,
                                                                          r'''$.id''',
                                                                        ).toString());
                                                                    _model.apiResultvbr =
                                                                        await DOVIAAPIFavoriteContextGroup
                                                                            .addPropertyToFavoritesCall
                                                                            .call(
                                                                      authToken:
                                                                          currentAuthenticationToken,
                                                                      folderId:
                                                                          getJsonField(
                                                                        eachFolderItem,
                                                                        r'''$.id''',
                                                                      ).toString(),
                                                                      propertyId:
                                                                          widget
                                                                              .houseId,
                                                                    );

                                                                    _busyFolderId =
                                                                        null;
                                                                    FavoriteFolderCollageWidget
                                                                        .invalidate();
                                                                    if ((_model
                                                                            .apiResultvbr
                                                                            ?.succeeded ??
                                                                        true)) {
                                                                      _isFavorite =
                                                                          true;
                                                                      // Sin aviso: el ícono de la carpeta ya muestra que quedó guardada.
                                                                    } else {
                                                                      await showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (alertDialogContext) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                const Text('error'),
                                                                            content:
                                                                                Text((_model.apiResultvbr?.jsonBody ?? '').toString()),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () => Navigator.pop(alertDialogContext),
                                                                                child: const Text('Ok'),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    }

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      _folderToggle(
                                                                    checked:
                                                                        false,
                                                                    busy: _busyFolderId ==
                                                                        getJsonField(
                                                                          eachFolderItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
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
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 20.0, 20.0, 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                  // Abierto sólo para crear: Cancelar cierra.
                                  if (widget.isCreatingNewFolderPARAM == true) {
                                    Navigator.pop(context);
                                    return;
                                  }
                                  _model.isCreatingNewFolder = false;
                                  safeSetState(() {});
                                },
                                child: Text(
                                  'Cancelar',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                              Builder(
                                builder: (context) => InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    if (_creatingFolder) return;
                                    final folderName =
                                        _model.textController.text.trim();
                                    if (folderName.isEmpty) {
                                      // Sin pop-up: el campo se marca en rojo.
                                      safeSetState(() => _nameMissing = true);
                                      return;
                                    }
                                    safeSetState(() => _creatingFolder = true);
                                    if (await _folderNameExists(folderName)) {
                                      safeSetState(
                                          () => _creatingFolder = false);
                                      await _showFolderNotice(
                                          'Ya tenés esa carpeta',
                                          'Ya existe una carpeta llamada "$folderName". Elegí otro nombre.');
                                      return;
                                    }
                                    _model.apiResult3ce =
                                        await DOVIAAPIFavoriteContextGroup
                                            .createFavoriteFolderCall
                                            .call(
                                      folderName: folderName,
                                      authToken: currentAuthenticationToken,
                                    );
                                    _creatingFolder = false;

                                    if ((_model.apiResult3ce?.succeeded ??
                                        true)) {
                                      final newFolderId = getJsonField(
                                        _model.apiResult3ce?.jsonBody,
                                        r'''$.data.id''',
                                      ).toString();

                                      final bool addedToFolder =
                                          widget.houseId != null &&
                                              widget.houseId!.isNotEmpty;
                                      if (addedToFolder) {
                                        await DOVIAAPIFavoriteContextGroup
                                            .addPropertyToFavoritesCall
                                            .call(
                                          authToken: currentAuthenticationToken,
                                          folderId: newFolderId,
                                          propertyId: widget.houseId,
                                        );
                                      }

                                      await showDialog(
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            alignment:
                                                const AlignmentDirectional(
                                                        0.0, 0.0)
                                                    .resolve(Directionality.of(
                                                        context)),
                                            child: SizedBox(
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  0.5,
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.9,
                                              child:
                                                  TusFavoritosCarpetaCreadaModalWidget(
                                                      folderName: _model
                                                          .textController.text),
                                            ),
                                          );
                                        },
                                      );

                                      if (widget.isCreatingNewFolderPARAM ==
                                              true ||
                                          addedToFolder) {
                                        Navigator.pop(context);
                                      } else {
                                        _model.isCreatingNewFolder = false;
                                        _model.textController?.clear();
                                        safeSetState(() {});
                                      }
                                    } else {
                                      final body =
                                          (_model.apiResult3ce?.jsonBody ?? '')
                                              .toString()
                                              .toLowerCase();
                                      final duplicated =
                                          _model.apiResult3ce?.statusCode ==
                                                  409 ||
                                              body.contains('exist') ||
                                              body.contains('duplic');
                                      await _showFolderNotice(
                                        duplicated
                                            ? 'Ya tenés esa carpeta'
                                            : 'No se pudo crear la carpeta',
                                        duplicated
                                            ? 'Ya existe una carpeta llamada "$folderName". Elegí otro nombre.'
                                            : 'Probá de nuevo en unos segundos.',
                                      );
                                    }

                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _aqua,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: _creatingFolder
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Text(
                                            'Guardar',
                                            style: TextStyle(
                                              fontFamily: 'Public Sans',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Text(
                              'Nueva carpeta',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          // Sin casa (crear carpeta desde Favoritos) no
                          // hay foto que mostrar.
                          if (_hasProperty)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: _propertyPhoto(
                                  width: 187.0,
                                  height: 110.0,
                                ),
                              ),
                            ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                'Nombre de la carpeta',
                                style: GoogleFonts.inter(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 8.0, 0.0, 0.0),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                child: TextFormField(
                                  controller: _model.textController,
                                  focusNode: _model.textFieldFocusNode,
                                  autofocus: false,
                                  enabled: true,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Escribe el nombre de la carpeta',
                                    errorText: _nameMissing
                                        ? 'Escribí un nombre para la carpeta'
                                        : null,
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 13.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF2F4F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14.0, vertical: 14.0),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                                  onChanged: (_) {
                                    if (_nameMissing) {
                                      safeSetState(() => _nameMissing = false);
                                    }
                                  },
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  enableInteractiveSelection: true,
                                  validator: _model.textControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
