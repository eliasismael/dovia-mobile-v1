import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/agregar_favorito_a_carpeta_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/dovia_suupport_messages/dovia_suupport_messages_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_home_page_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_home_page_model.dart';

class DOVIACLIENTHomePageWidget extends StatefulWidget {
  const DOVIACLIENTHomePageWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_HomePage';
  static String routePath = '/dOVIACLIENTHomePage';

  @override
  State<DOVIACLIENTHomePageWidget> createState() =>
      _DOVIACLIENTHomePageWidgetState();
}

class _DOVIACLIENTHomePageWidgetState extends State<DOVIACLIENTHomePageWidget> {
  late DOVIACLIENTHomePageModel _model;
  Set<String> _favoritePropertyIds = <String>{};

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isHouseFavorite(dynamic eachHouseItem) {
    final propertyId = getJsonField(eachHouseItem, r'''$.id''').toString();
    final payloadFavorite = getJsonField(
              eachHouseItem,
              r'''$.isFavorite''',
            ) ==
            true ||
        getJsonField(
              eachHouseItem,
              r'''$.isFavorite''',
            ).toString().toLowerCase() ==
            'true' ||
        getJsonField(
              eachHouseItem,
              r'''$.isFavorite''',
            ).toString() ==
            '1';

    return _favoritePropertyIds.contains(propertyId) || payloadFavorite;
  }

  Future<void> _refreshFavoritePropertyIds() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;

    final favoriteIds = <String>{};

    final defaultFavoritesResponse =
        await DOVIAAPIFavoriteContextGroup.getDefaultFavoritesCall.call(
      authToken: token,
    );
    if (defaultFavoritesResponse.succeeded) {
      final defaultFavorites = getJsonField(
        defaultFavoritesResponse.jsonBody,
        r'''$.data''',
      ).toList();
      for (final item in defaultFavorites) {
        final id = getJsonField(item, r'''$.id''').toString();
        final propertyId = getJsonField(item, r'''$.propertyId''').toString();
        if (id.isNotEmpty && id != 'null') favoriteIds.add(id);
        if (propertyId.isNotEmpty && propertyId != 'null') {
          favoriteIds.add(propertyId);
        }
      }
    }

    final foldersResponse =
        await DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall.call(
      authToken: token,
    );
    if (foldersResponse.succeeded) {
      final folders = DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall
              .folders(foldersResponse.jsonBody)
              ?.toList() ??
          [];
      for (final folder in folders) {
        final folderId = getJsonField(folder, r'''$.id''').toString();
        if (folderId.isEmpty || folderId == 'null') continue;

        final folderFavoritesResponse =
            await DOVIAAPIFavoriteContextGroup.getFavoritesInFolderCall.call(
          authToken: token,
          folderId: folderId,
        );
        if (!folderFavoritesResponse.succeeded) continue;

        final folderFavorites = getJsonField(
          folderFavoritesResponse.jsonBody,
          r'''$.data.favorites''',
        ).toList();
        for (final item in folderFavorites) {
          final id = getJsonField(item, r'''$.id''').toString();
          final propertyId = getJsonField(item, r'''$.propertyId''').toString();
          if (id.isNotEmpty && id != 'null') favoriteIds.add(id);
          if (propertyId.isNotEmpty && propertyId != 'null') {
            favoriteIds.add(propertyId);
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _favoritePropertyIds = favoriteIds;
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTHomePageModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await _refreshFavoritePropertyIds();
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
                    Align(
                      alignment: const AlignmentDirectional(0.0, -1.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 200.0,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF007376), Color(0xFF70ACAD)],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(48.0),
                            bottomRight: Radius.circular(48.0),
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                          ),
                          shape: BoxShape.rectangle,
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 30.0, 20.0, 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
                                    child: SvgPicture.asset(
                                      'assets/images/D-blanca.svg',
                                      width: 28.0,
                                      height: 36.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 8.0, 0.0, 0.0),
                                        child: FlutterFlowDropDown<String>(
                                          controller: _model
                                                  .dropDownValueController ??=
                                              FormFieldController<String>(null),
                                          options: const ['USD', 'GTQ'],
                                          onChanged: (val) => safeSetState(
                                              () => _model.dropDownValue = val),
                                          width: 90.0,
                                          height: 30.0,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.publicSans(
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
                                          hintText: 'USD',
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 24.0,
                                          ),
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          elevation: 2.0,
                                          borderColor: Colors.transparent,
                                          borderWidth: 0.0,
                                          borderRadius: 67.0,
                                          margin: const EdgeInsetsDirectional
                                              .fromSTEB(12.0, 0.0, 12.0, 0.0),
                                          hidesUnderline: true,
                                          isOverButton: false,
                                          isSearchable: false,
                                          isMultiSelect: false,
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                              MapWidgetPageTestWidget
                                                  .routeName);
                                        },
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: SvgPicture.asset(
                                              'assets/images/IconoDoviaHomeClienteMapa.svg',
                                              width: 8.0,
                                              height: 8.0,
                                              fit: BoxFit.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                              DOVIACLIENTNotificacionesWidget
                                                  .routeName);
                                        },
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: SvgPicture.asset(
                                              'assets/images/DH_icono-navbar-notificaciones.svg',
                                              width: 24.0,
                                              height: 24.0,
                                              fit: BoxFit.none,
                                            ),
                                          ),
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
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child:
                                                      const DoviaSuupportMessagesWidget(),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: SvgPicture.asset(
                                              'assets/images/IconoDoviaHomeClienteMensajes.svg',
                                              width: 8.0,
                                              height: 8.0,
                                              fit: BoxFit.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 8.0)),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 30.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: 200.0,
                                        child: TextFormField(
                                          controller: _model.textController,
                                          focusNode: _model.textFieldFocusNode,
                                          autofocus: false,
                                          enabled: true,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                            hintText: 'Búsqueda con IA',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(25.0),
                                                bottomRight:
                                                    Radius.circular(25.0),
                                                topLeft: Radius.circular(25.0),
                                                topRight: Radius.circular(25.0),
                                              ),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(25.0),
                                                bottomRight:
                                                    Radius.circular(25.0),
                                                topLeft: Radius.circular(25.0),
                                                topRight: Radius.circular(25.0),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(25.0),
                                                bottomRight:
                                                    Radius.circular(25.0),
                                                topLeft: Radius.circular(25.0),
                                                topRight: Radius.circular(25.0),
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(25.0),
                                                bottomRight:
                                                    Radius.circular(25.0),
                                                topLeft: Radius.circular(25.0),
                                                topRight: Radius.circular(25.0),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            prefixIcon: const Icon(
                                              Icons.search_rounded,
                                              size: 24.0,
                                            ),
                                          ),
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
                                          maxLines: null,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          enableInteractiveSelection: true,
                                          validator: _model
                                              .textControllerValidator
                                              .asValidator(context),
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
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 22.0, 0.0, 0.0),
                      child: Container(
                        decoration: const BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              10.0, 10.0, 10.0, 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 10.0, 0.0, 10.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    _model.comprarORentar = 'comprar';
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    width: 144.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      color: _model.comprarORentar == 'comprar'
                                          ? const Color(0x32007376)
                                          : FlutterFlowTheme.of(context)
                                              .tertiary,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 0.0, 20.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: SvgPicture.asset(
                                              'assets/images/cart-alt.svg',
                                              width: 20.0,
                                              height: 20.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(
                                                    0.0, 0.0),
                                            child: Text(
                                              'Comprar',
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
                                                        color: _model
                                                                    .comprarORentar ==
                                                                'comprar'
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                        fontSize: 14.0,
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
                                        ].divide(const SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 10.0, 0.0, 10.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    _model.comprarORentar = 'rentar';
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    width: 144.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      color: _model.comprarORentar == 'rentar'
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context)
                                              .tertiary,
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                          child: SvgPicture.asset(
                                            'assets/images/page-edit.svg',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              0.0, 0.0),
                                          child: Text(
                                            'Rentar',
                                            textAlign: TextAlign.center,
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 14.0,
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
                                      ].divide(const SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lo nuevo',
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
                              FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(
                                    DOVIACLIENTVerMasPropiedadesWidget
                                        .routeName,
                                    queryParameters: {
                                      'title': serializeParam(
                                        'Lo nuevo',
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                text: 'Ver mas',
                                options: FFButtonOptions(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).accent1,
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
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 0.0),
                          child: FutureBuilder<ApiCallResponse>(
                            future: DOVIAAPIPropertyContextGroup
                                .listPropertiesCall
                                .call(
                              limit: '5',
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
                              final rowListPropertiesResponse = snapshot.data!;

                              return Builder(
                                builder: (context) {
                                  final eachHouse = getJsonField(
                                    rowListPropertiesResponse.jsonBody,
                                    r'''$.data''',
                                  ).toList();

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: List.generate(eachHouse.length,
                                          (eachHouseIndex) {
                                        final eachHouseItem =
                                            eachHouse[eachHouseIndex];
                                        return Builder(
                                          builder: (context) => InkWell(
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
                                              width: 210.0,
                                              height: 0.0,
                                              imageUrl:
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                                              isFavorite: _isHouseFavorite(
                                                  eachHouseItem),
                                              name: getJsonField(
                                                eachHouseItem,
                                                r'''$.name''',
                                              ).toString(),
                                              type: getJsonField(
                                                eachHouseItem,
                                                r'''$.listingType[0]''',
                                              ).toString(),
                                              price: getJsonField(
                                                eachHouseItem,
                                                r'''$.price''',
                                              ).toString(),
                                              propertyId: getJsonField(
                                                eachHouseItem,
                                                r'''$.id''',
                                              ).toString(),
                                              authToken:
                                                  currentAuthenticationToken,
                                              onAddToFavorites: () async {
                                                if (FFAppState().UserRole !=
                                                    'VISITOR') {
                                                  _model.addFavoriteNew =
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

                                                  final addFavoriteResponse =
                                                      _model.addFavoriteNew;
                                                  final isAlreadyFavorite =
                                                      (addFavoriteResponse
                                                                  ?.statusCode ==
                                                              409) ||
                                                          (addFavoriteResponse
                                                                      ?.jsonBody ??
                                                                  '')
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                  'already');

                                                  if ((addFavoriteResponse
                                                              ?.succeeded ??
                                                          false) ||
                                                      isAlreadyFavorite) {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
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
                                                              houseId:
                                                                  getJsonField(
                                                                eachHouseItem,
                                                                r'''$.id''',
                                                              ).toString(),
                                                              propertyName:
                                                                  getJsonField(
                                                                eachHouseItem,
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
                                                  } else {
                                                    await showDialog(
                                                      context: context,
                                                      builder:
                                                          (alertDialogContext) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Error'),
                                                          content: Text(
                                                              (addFavoriteResponse
                                                                          ?.jsonBody ??
                                                                      '')
                                                                  .toString()),
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
                                                            r'''$.id''',
                                                          ).toString(),
                                                          propertyName:
                                                              getJsonField(
                                                            eachHouseItem,
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

                                                safeSetState(() {});
                                              },
                                            ),
                                          ),
                                        );
                                      }).divide(const SizedBox(width: 16.0)),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recomendado',
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
                              FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(
                                    DOVIACLIENTVerMasPropiedadesWidget
                                        .routeName,
                                    queryParameters: {
                                      'title': serializeParam(
                                        'Recomendado',
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                text: 'Ver mas',
                                options: FFButtonOptions(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).accent1,
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
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 0.0),
                          child: FutureBuilder<ApiCallResponse>(
                            future: DOVIAAPIPropertyContextGroup
                                .listPropertiesCall
                                .call(
                              limit: '5',
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
                              final rowListPropertiesResponse = snapshot.data!;

                              return Builder(
                                builder: (context) {
                                  final eachHouse = getJsonField(
                                    rowListPropertiesResponse.jsonBody,
                                    r'''$.data''',
                                  ).toList();

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: List.generate(eachHouse.length,
                                          (eachHouseIndex) {
                                        final eachHouseItem =
                                            eachHouse[eachHouseIndex];
                                        return Builder(
                                          builder: (context) => InkWell(
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
                                              width: 210.0,
                                              height: 0.0,
                                              imageUrl:
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                                              isFavorite: _isHouseFavorite(
                                                  eachHouseItem),
                                              name: getJsonField(
                                                eachHouseItem,
                                                r'''$.name''',
                                              ).toString(),
                                              type: getJsonField(
                                                eachHouseItem,
                                                r'''$.listingType[0]''',
                                              ).toString(),
                                              price: getJsonField(
                                                eachHouseItem,
                                                r'''$.price''',
                                              ).toString(),
                                              propertyId: getJsonField(
                                                eachHouseItem,
                                                r'''$.id''',
                                              ).toString(),
                                              authToken:
                                                  currentAuthenticationToken,
                                              onAddToFavorites: () async {
                                                if (FFAppState().UserRole !=
                                                    'VISITOR') {
                                                  _model.addFvoriteRecommended =
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

                                                  final addFavoriteResponse =
                                                      _model
                                                          .addFvoriteRecommended;
                                                  final isAlreadyFavorite =
                                                      (addFavoriteResponse
                                                                  ?.statusCode ==
                                                              409) ||
                                                          (addFavoriteResponse
                                                                      ?.jsonBody ??
                                                                  '')
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                  'already');

                                                  if ((addFavoriteResponse
                                                              ?.succeeded ??
                                                          false) ||
                                                      isAlreadyFavorite) {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
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
                                                              houseId:
                                                                  getJsonField(
                                                                eachHouseItem,
                                                                r'''$.id''',
                                                              ).toString(),
                                                              propertyName:
                                                                  getJsonField(
                                                                eachHouseItem,
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
                                                  } else {
                                                    await showDialog(
                                                      context: context,
                                                      builder:
                                                          (alertDialogContext) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Error'),
                                                          content: Text(
                                                              (addFavoriteResponse
                                                                          ?.jsonBody ??
                                                                      '')
                                                                  .toString()),
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
                                                            r'''$.id''',
                                                          ).toString(),
                                                          propertyName:
                                                              getJsonField(
                                                            eachHouseItem,
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

                                                safeSetState(() {});
                                              },
                                            ),
                                          ),
                                        );
                                      }).divide(const SizedBox(width: 16.0)),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Visto recientemente',
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
                              FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(
                                    DOVIACLIENTVerMasPropiedadesWidget
                                        .routeName,
                                    queryParameters: {
                                      'title': serializeParam(
                                        'Visto recientemente',
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                text: 'Ver mas',
                                options: FFButtonOptions(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).accent1,
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
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 0.0),
                          child: FutureBuilder<ApiCallResponse>(
                            future: DOVIAAPIPropertyContextGroup
                                .listPropertiesCall
                                .call(
                              limit: '5',
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
                              final rowListPropertiesResponse = snapshot.data!;

                              return Builder(
                                builder: (context) {
                                  final eachHouse = getJsonField(
                                    rowListPropertiesResponse.jsonBody,
                                    r'''$.data''',
                                  ).toList();

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: List.generate(eachHouse.length,
                                          (eachHouseIndex) {
                                        final eachHouseItem =
                                            eachHouse[eachHouseIndex];
                                        return Builder(
                                          builder: (context) => InkWell(
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
                                              width: 210.0,
                                              height: 0.0,
                                              imageUrl:
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                                              isFavorite: _isHouseFavorite(
                                                  eachHouseItem),
                                              name: getJsonField(
                                                eachHouseItem,
                                                r'''$.name''',
                                              ).toString(),
                                              type: getJsonField(
                                                eachHouseItem,
                                                r'''$.listingType[0]''',
                                              ).toString(),
                                              price: getJsonField(
                                                eachHouseItem,
                                                r'''$.price''',
                                              ).toString(),
                                              propertyId: getJsonField(
                                                eachHouseItem,
                                                r'''$.id''',
                                              ).toString(),
                                              authToken:
                                                  currentAuthenticationToken,
                                              onAddToFavorites: () async {
                                                if (FFAppState().UserRole !=
                                                    'VISITOR') {
                                                  _model.addFavoriteViewedRecently =
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

                                                  final addFavoriteResponse = _model
                                                      .addFavoriteViewedRecently;
                                                  final isAlreadyFavorite =
                                                      (addFavoriteResponse
                                                                  ?.statusCode ==
                                                              409) ||
                                                          (addFavoriteResponse
                                                                      ?.jsonBody ??
                                                                  '')
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                  'already');

                                                  if ((addFavoriteResponse
                                                              ?.succeeded ??
                                                          false) ||
                                                      isAlreadyFavorite) {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
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
                                                              houseId:
                                                                  getJsonField(
                                                                eachHouseItem,
                                                                r'''$.id''',
                                                              ).toString(),
                                                              propertyName:
                                                                  getJsonField(
                                                                eachHouseItem,
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
                                                  } else {
                                                    await showDialog(
                                                      context: context,
                                                      builder:
                                                          (alertDialogContext) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Error'),
                                                          content: Text(
                                                              (addFavoriteResponse
                                                                          ?.jsonBody ??
                                                                      '')
                                                                  .toString()),
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
                                      }).divide(const SizedBox(width: 16.0)),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTHomePageWidget.routeName,
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
