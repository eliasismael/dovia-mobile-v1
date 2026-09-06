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
import '/domain/offer_json.dart';
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

  /// Foto principal que manda el backend para la propiedad. El listado de
  /// propiedades hoy no incluye ninguna, y ahi la tarjeta se queda con su
  /// imagen por defecto.
  String _houseImageUrl(dynamic house) {
    if (house is! Map) {
      return '';
    }
    return firstPropertyPhotoUrl(Map<String, dynamic>.from(house)) ?? '';
  }

  /// Cuantas tarjetas muestra cada carrusel del Home.
  static const int _carouselSize = 5;

  /// Pagina que esta viendo cada carrusel, por clave.
  final Map<String, int> _carouselPages = <String, int>{};

  /// Los botones Comprar y Rentar filtran los carruseles por tipo de
  /// operacion. Sin ninguno seleccionado se muestran todas las propiedades.
  List<dynamic> _filterByListingType(List<dynamic> houses) {
    final selected = _model.comprarORentar;
    if (selected.isEmpty) {
      return houses;
    }

    final wanted = selected == 'rentar' ? 'RENT' : 'SALE';
    return houses.where((house) {
      final listingType = getJsonField(house, r'''$.listingType''');
      if (listingType is List) {
        return listingType
            .any((type) => type.toString().toUpperCase().contains(wanted));
      }
      return listingType.toString().toUpperCase().contains(wanted);
    }).toList();
  }

  /// El bloque de propiedades que le toca mostrar al carrusel.
  List<dynamic> _carouselPage(String carouselKey, List<dynamic> houses) {
    final start = (_carouselPages[carouselKey] ?? 0) * _carouselSize;
    if (start >= houses.length) {
      return houses.take(_carouselSize).toList();
    }
    return houses.skip(start).take(_carouselSize).toList();
  }

  void _moveCarousel(String carouselKey, int step) {
    final page = (_carouselPages[carouselKey] ?? 0) + step;
    _carouselPages[carouselKey] = page < 0 ? 0 : page;
    safeSetState(() {});
  }

  /// Flecha discreta dentro de un circulo claro.
  Widget _carouselArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 6.0,
              color: Color(0x26000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        child: Icon(
          icon,
          color: FlutterFlowTheme.of(context).primaryText,
          size: 20.0,
        ),
      ),
    );
  }

  /// Las flechas van superpuestas al carrusel para no robarle ancho a la
  /// pantalla. La de volver solo aparece cuando hay algo atras.
  Widget _withCarouselArrows({
    required String carouselKey,
    required int total,
    required Widget child,
  }) {
    final page = _carouselPages[carouselKey] ?? 0;
    final hasPrevious = page > 0;
    final hasNext = (page + 1) * _carouselSize < total;

    return Stack(
      children: [
        // La clave cambia con la pagina para que el carrusel vuelva a
        // arrancar desde la izquierda al avanzar o retroceder.
        KeyedSubtree(
          key: ValueKey('$carouselKey-$page'),
          child: child,
        ),
        if (hasPrevious)
          Positioned.fill(
            child: Align(
              alignment: const AlignmentDirectional(-1.0, 0.0),
              child: _carouselArrow(
                icon: Icons.chevron_left,
                onTap: () => _moveCarousel(carouselKey, -1),
              ),
            ),
          ),
        if (hasNext)
          Positioned.fill(
            child: Align(
              alignment: const AlignmentDirectional(1.0, 0.0),
              child: _carouselArrow(
                icon: Icons.chevron_right,
                onTap: () => _moveCarousel(carouselKey, 1),
              ),
            ),
          ),
      ],
    );
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

  Future<void> _handleRestrictedAction(Function() action) async {
    if (FFAppState().UserRole == 'VISITOR') {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: const AlignmentDirectional(0.0, 0.0)
                .resolve(Directionality.of(context)),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(dialogContext).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: const VisitorRestrictionPopupWidget(),
            ),
          );
        },
      );
    } else {
      action();
    }
  }

  /// Boton redondo de la cabecera. El mapa del hero usa el mismo aspecto.
  Widget _headerAction({
    required String asset,
    required Future<void> Function() onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8.0,
              color: Color(0x1A000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: SvgPicture.asset(
          asset,
          width: 22.0,
          height: 22.0,
          fit: BoxFit.contain,
        ),
      ),
    );
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
                  children: [
                    // Para quien todavía no tiene cuenta, la invitación a
                    // sumarse como asociado.
                    if (FFAppState().UserRole == 'VISITOR')
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 16.0, 20.0, 8.0),
                        child: Row(
                          children: [
                            const Spacer(),
                            FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed('CreateAccount');
                              },
                              text: 'Conviértete en Asociado',
                              options: FFButtonOptions(
                                height: 36.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: Colors.transparent,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        color: const Color(0xFF007376),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      fontSize: 14.0,
                                    ),
                                elevation: 0.0,
                                borderSide: const BorderSide(
                                  color: Color(0xFF007376),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Cabecera clara del diseño: el logotipo a la izquierda y
                    // los accesos rápidos a la derecha, ajustes incluido.
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 8.0, 20.0, 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/images/dovia-wordmark.svg',
                            width: 120.0,
                            height: 28.0,
                            fit: BoxFit.contain,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (FFAppState().UserRole != 'VISITOR') ...[
                                _headerAction(
                                  asset:
                                      'assets/images/IconoDoviaHomeClienteMensajes.svg',
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
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child:
                                                const DoviaSuupportMessagesWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                ),
                                _headerAction(
                                  asset:
                                      'assets/images/DH_icono-navbar-notificaciones.svg',
                                  onTap: () async {
                                    context.pushNamed(
                                        DOVIACLIENTNotificacionesWidget
                                            .routeName);
                                  },
                                ),
                              ],
                              // Ajustes dejó la barra de abajo y vive acá.
                              _headerAction(
                                asset:
                                    'assets/images/DH_icono-navbar-ajustes.svg',
                                onTap: () async {
                                  await _handleRestrictedAction(() {
                                    context.pushNamed(
                                        DOVIACLIENTAjustesWidget.routeName);
                                  });
                                },
                              ),
                            ].divide(const SizedBox(width: 8.0)),
                          ),
                        ],
                      ),
                    ),
                    // Hero del diseño: la foto con el titular arriba y, al pie
                    // y superpuestos, la búsqueda, la moneda y el mapa.
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 8.0, 20.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child: AspectRatio(
                          aspectRatio: 1.05,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/HomeBannerFamilia.jpg',
                                fit: BoxFit.cover,
                                alignment: const Alignment(0.0, 0.2),
                              ),
                              // Aclara la parte de arriba para que el titular
                              // se lea sobre la foto.
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xF2FFFFFF),
                                      Color(0x00FFFFFF)
                                    ],
                                    stops: [0.0, 0.55],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0.0, 1.0),
                                  ),
                                ),
                              ),
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, -1.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 22.0, 20.0, 0.0),
                                  child: Text.rich(
                                    const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Tu próximo hogar,\n',
                                          style: TextStyle(
                                              color: Color(0xFF0F172A)),
                                        ),
                                        TextSpan(
                                          text: 'sin complicaciones.',
                                          style: TextStyle(
                                              color: Color(0xFF065A5A)),
                                        ),
                                      ],
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(
                                              fontWeight: FontWeight.bold),
                                          fontSize: 26.0,
                                          letterSpacing: -0.5,
                                          fontWeight: FontWeight.bold,
                                          lineHeight: 1.25,
                                        ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(0.0, 1.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      12.0, 0.0, 12.0, 14.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 42.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 12.0,
                                                color: Color(0x1A000000),
                                                offset: Offset(0.0, 4.0),
                                              )
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: _model.textController,
                                            focusNode:
                                                _model.textFieldFocusNode,
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 10.0, 12.0, 10.0),
                                              hintText: 'Búsqueda con IA',
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .publicSans(),
                                                        fontSize: 13.0,
                                                        letterSpacing: 0.2,
                                                      ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(25.0)),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(25.0)),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              prefixIcon: const Icon(
                                                Icons.search_rounded,
                                                size: 20.0,
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font:
                                                      GoogleFonts.publicSans(),
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.2,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      FlutterFlowDropDown<String>(
                                        controller: _model
                                                .dropDownValueController ??=
                                            FormFieldController<String>(null),
                                        options: const ['USD', 'GTQ'],
                                        onChanged: (val) => safeSetState(
                                            () => _model.dropDownValue = val),
                                        width: 86.0,
                                        height: 42.0,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.publicSans(),
                                              color: const Color(0xFF00444B),
                                              fontSize: 13.0,
                                              letterSpacing: 0.2,
                                            ),
                                        hintText: 'USD',
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        elevation: 2.0,
                                        borderColor: Colors.transparent,
                                        borderWidth: 0.0,
                                        borderRadius: 67.0,
                                        margin: const EdgeInsetsDirectional
                                            .fromSTEB(12.0, 0.0, 8.0, 0.0),
                                        hidesUnderline: true,
                                        isOverButton: false,
                                        isSearchable: false,
                                        isMultiSelect: false,
                                      ),
                                      const SizedBox(width: 8.0),
                                      _headerAction(
                                        asset:
                                            'assets/images/IconoDoviaHomeClienteMapa.svg',
                                        onTap: () async {
                                          context.pushNamed(
                                              MapWidgetPageTestWidget
                                                  .routeName);
                                        },
                                      ),
                                    ],
                                  ),
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
                                    _handleRestrictedAction(() {
                                      _model.comprarORentar =
                                          _model.comprarORentar == 'comprar'
                                              ? ''
                                              : 'comprar';
                                      _carouselPages.clear();
                                      safeSetState(() {});
                                    });
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
                                    _handleRestrictedAction(() {
                                      _model.comprarORentar =
                                          _model.comprarORentar == 'rentar'
                                              ? ''
                                              : 'rentar';
                                      _carouselPages.clear();
                                      safeSetState(() {});
                                    });
                                  },
                                  child: Container(
                                    width: 144.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      color: _model.comprarORentar == 'rentar'
                                          ? const Color(0x32007376)
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
                                                  color:
                                                      _model.comprarORentar ==
                                                              'rentar'
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText
                                                          : FlutterFlowTheme.of(
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
                                  _handleRestrictedAction(() {
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
                                  });
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
                                  final allHouses =
                                      _filterByListingType(getJsonField(
                                    rowListPropertiesResponse.jsonBody,
                                    r'''$.data''',
                                  ).toList());
                                  final eachHouse =
                                      _carouselPage('loNuevo', allHouses);

                                  return _withCarouselArrows(
                                    carouselKey: 'loNuevo',
                                    total: allHouses.length,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: List.generate(
                                            eachHouse.length, (eachHouseIndex) {
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
                                                imageUrl: _houseImageUrl(
                                                    eachHouseItem),
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
                                                propertyType: getJsonField(
                                                        eachHouseItem,
                                                        r'''$.propertyType''')
                                                    ?.toString(),
                                                hasDiscount: getJsonField(
                                                            eachHouseItem,
                                                            r'''$.hasDiscount''') ==
                                                        true ||
                                                    getJsonField(eachHouseItem,
                                                                r'''$.hasDiscount''')
                                                            .toString() ==
                                                        'true',
                                                originalPrice: getJsonField(
                                                        eachHouseItem,
                                                        r'''$.originalPrice''')
                                                    ?.toString(),
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
                                                                propertyImage:
                                                                    '',
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

                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          );
                                        }).divide(const SizedBox(width: 16.0)),
                                      ),
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
                                'Proyectos Nuevos',
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
                                  _handleRestrictedAction(() async {
                                    await launchURL(
                                        'https://dovia.app/desarrollos');
                                  });
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return Builder(
                                  builder: (context) => InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      _handleRestrictedAction(() async {
                                        await launchURL(
                                            'https://dovia.app/desarrollos');
                                      });
                                    },
                                    child: custom_widgets.DoviaClientHouseCard(
                                      width: 210.0,
                                      height: 0.0,
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1600596542815-27b88e57e62f?q=80&w=800&auto=format&fit=crop',
                                      name: 'Desarrollo Especial',
                                      type: 'Preventa',
                                      price: '\$ 1,000,000',
                                      propertyType: 'Edificio',
                                    ),
                                  ),
                                );
                              }).divide(const SizedBox(width: 16.0)),
                            ),
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
                                  _handleRestrictedAction(() {
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
                                  });
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
                                  final allHouses =
                                      _filterByListingType(getJsonField(
                                    rowListPropertiesResponse.jsonBody,
                                    r'''$.data''',
                                  ).toList());
                                  final eachHouse =
                                      _carouselPage('recomendado', allHouses);

                                  return _withCarouselArrows(
                                    carouselKey: 'recomendado',
                                    total: allHouses.length,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: List.generate(
                                            eachHouse.length, (eachHouseIndex) {
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
                                                imageUrl: _houseImageUrl(
                                                    eachHouseItem),
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
                                                propertyType: getJsonField(
                                                        eachHouseItem,
                                                        r'''$.propertyType''')
                                                    ?.toString(),
                                                hasDiscount: getJsonField(
                                                            eachHouseItem,
                                                            r'''$.hasDiscount''') ==
                                                        true ||
                                                    getJsonField(eachHouseItem,
                                                                r'''$.hasDiscount''')
                                                            .toString() ==
                                                        'true',
                                                originalPrice: getJsonField(
                                                        eachHouseItem,
                                                        r'''$.originalPrice''')
                                                    ?.toString(),
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
                                                                propertyImage:
                                                                    '',
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

                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          );
                                        }).divide(const SizedBox(width: 16.0)),
                                      ),
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
                                  _handleRestrictedAction(() {
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
                                  });
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
                                  final allHouses =
                                      _filterByListingType(getJsonField(
                                    rowListPropertiesResponse.jsonBody,
                                    r'''$.data''',
                                  ).toList());
                                  final eachHouse = _carouselPage(
                                      'vistoRecientemente', allHouses);

                                  return _withCarouselArrows(
                                    carouselKey: 'vistoRecientemente',
                                    total: allHouses.length,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: List.generate(
                                            eachHouse.length, (eachHouseIndex) {
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
                                                imageUrl: _houseImageUrl(
                                                    eachHouseItem),
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
                                                propertyType: getJsonField(
                                                        eachHouseItem,
                                                        r'''$.propertyType''')
                                                    ?.toString(),
                                                hasDiscount: getJsonField(
                                                            eachHouseItem,
                                                            r'''$.hasDiscount''') ==
                                                        true ||
                                                    getJsonField(eachHouseItem,
                                                                r'''$.hasDiscount''')
                                                            .toString() ==
                                                        'true',
                                                originalPrice: getJsonField(
                                                        eachHouseItem,
                                                        r'''$.originalPrice''')
                                                    ?.toString(),
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

                                                    final addFavoriteResponse =
                                                        _model
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
                                                                propertyImage:
                                                                    '',
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
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Aire al pie para que la ultima fila no quede debajo
                    // de la barra de navegacion, que va flotando encima.
                    const SizedBox(height: 110.0),
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
