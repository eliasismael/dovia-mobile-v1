import '/domain/property_location.dart';
import '/dovia_client/app/mis_propiedades/deal_in_progress_badge.dart';
import '/shared_components/app_tutorial/app_tutorial.dart';
import '/shared_components/error_state/error_state_widget.dart';
import '/domain/offer_json.dart' show firstPropertyPhotoUrl;
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/core/result.dart';
import '/domain/owner_proposal_models.dart';
import '/repositories/offers_repository.dart';
import '/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_propuestas_recientes/owner_proposal_navigation.dart';
import '/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_propuestas_recientes/propuesta_reciente_card_widget.dart';
import '/dovia_client/app/mis_propiedades/mis_propiedades_house_card/mis_propiedades_house_card_widget.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_model.dart';

class DOVIACLIENTMisPropiedadesWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisPropiedades';
  static String routePath = '/dOVIACLIENTMisPropiedades';

  @override
  State<DOVIACLIENTMisPropiedadesWidget> createState() =>
      _DOVIACLIENTMisPropiedadesWidgetState();
}

class _DOVIACLIENTMisPropiedadesWidgetState
    extends State<DOVIACLIENTMisPropiedadesWidget> {
  late DOVIACLIENTMisPropiedadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Propuestas recibidas sobre las propiedades del usuario, ya repartidas en
  /// los tres carriles (Ofertas / Contraoferta / Oferta aceptada).
  OwnerProposalsBoard _proposalsBoard = const OwnerProposalsBoard.empty();
  bool _isLoadingProposals = true;

  /// Publicadas que se ven antes de tocar "Ver más".
  static const int _publishedPreviewCount = 3;
  bool _showAllPublished = false;

  /// Vendidas y rentadas, para "Operaciones cerradas".
  Future<ApiCallResponse> _fetchClosed() async {
    final results = await Future.wait([
      for (final status in ['SOLD', 'RENTED'])
        DOVIAAPIPropertyContextGroup.getMyPropertiesCall
            .call(status: status, authToken: currentAuthenticationToken),
    ]);
    final combined = [
      for (final r in results)
        ...?DOVIAAPIPropertyContextGroup.getMyPropertiesCall
            .data(r.jsonBody)
            ?.where((e) => e != null)
            .map((e) => Map<String, dynamic>.from(e)),
    ];
    return ApiCallResponse({"data": combined}, {}, 200);
  }

  Future<ApiCallResponse> _fetchAllPending() async {
    final draftResult = await DOVIAAPIPropertyContextGroup.getMyPropertiesCall
        .call(status: 'DRAFT', authToken: currentAuthenticationToken);
    final inProcessResult = await DOVIAAPIPropertyContextGroup
        .getMyPropertiesCall
        .call(status: 'IN_PROCESS', authToken: currentAuthenticationToken);
    final pendingReviewResult = await DOVIAAPIPropertyContextGroup
        .getMyPropertiesCall
        .call(status: 'PENDING_REVIEW', authToken: currentAuthenticationToken);
    // Include ARCHIVED (paused) properties so the owner can see & reactivate them
    final archivedResult = await DOVIAAPIPropertyContextGroup
        .getMyPropertiesCall
        .call(status: 'ARCHIVED', authToken: currentAuthenticationToken);

    final drafts = DOVIAAPIPropertyContextGroup.getMyPropertiesCall
            .data(draftResult.jsonBody)
            ?.where((e) => e != null)
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
    final inProcess = DOVIAAPIPropertyContextGroup.getMyPropertiesCall
            .data(inProcessResult.jsonBody)
            ?.where((e) => e != null)
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
    final pendingReview = DOVIAAPIPropertyContextGroup.getMyPropertiesCall
            .data(pendingReviewResult.jsonBody)
            ?.where((e) => e != null)
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
    final archived = DOVIAAPIPropertyContextGroup.getMyPropertiesCall
            .data(archivedResult.jsonBody)
            ?.where((e) => e != null)
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];

    final combined = [...drafts, ...inProcess, ...pendingReview, ...archived];

    return ApiCallResponse(
      {"data": combined},
      {},
      200,
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisPropiedadesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProposals());

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowIntro());
  }

  static const _introTutorialId = 'client_my_properties_intro';

  /// La primera vez que el cliente entra a Mis propiedades se le muestra cómo
  /// funciona publicar, una sola vez, como el tutorial de bienvenida. Antes se
  /// decidía después de tres consultas a la API: podía saltar con el usuario
  /// ya en otra pestaña, y volvía cada vez que no tenía propiedades.
  Future<void> _maybeShowIntro() async {
    final userId = currentUserUid;
    if (userId.isEmpty) return;
    if (await AppTutorial.isDone(_introTutorialId, userId)) return;
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    await AppTutorial.markDone(_introTutorialId, userId);
    if (!mounted) return;
    context.pushNamed(DOVIACLIENTComoFuncionaWidget.routeName);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Foto principal de la casa para el modal de carpetas de favoritos.
  String _modalImage(dynamic house) => house is Map
      ? firstPropertyPhotoUrl(Map<String, dynamic>.from(house)) ?? ''
      : '';

  /// Aviso de sección vacía, en gris como el de propuestas recientes.
  Widget _emptyText(String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 33.0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                fontSize: 17.0,
                letterSpacing: 0.33,
                fontWeight: FontWeight.w600,
                lineHeight: 1.3,
              ),
        ),
      ),
    );
  }

  /// Acción principal de la pantalla: va sola, ancha y debajo de las
  /// propiedades publicadas, en vez de un botón chico junto al título.
  Widget _publishButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 24.0),
      child: FFButtonWidget(
        onPressed: () async {
          context.pushNamed(
              DOVIACLIENTMisPropiedadesAccionesARealizarWidget.routeName);
        },
        text: 'Publicar propiedad',
        options: FFButtonOptions(
          width: double.infinity,
          height: 46.0,
          color: FlutterFlowTheme.of(context).primary,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: Colors.white,
                fontSize: 15.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
          elevation: 0.0,
          borderRadius: BorderRadius.circular(24.0),
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
                        title: 'Mis Propiedades',
                        showMap: false,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _propuestasRecientesSection(),
                          _sectionTitle('Mis propiedades publicadas'),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: DOVIAAPIPropertyContextGroup
                                  .getMyPropertiesCall
                                  .call(
                                status: 'PUBLISHED',
                                authToken: currentAuthenticationToken,
                              ),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: DoviaSpinner(),
                                  );
                                }
                                final listViewGetMyPropertiesResponse =
                                    snapshot.data!;
                                // Sin conexión o con el servidor caído se avisa y se deja
                                // reintentar, en vez de mostrar la lista vacía.
                                if (isRetryableLoadError(
                                    listViewGetMyPropertiesResponse)) {
                                  return ErrorStateWidget.fromResponse(
                                      listViewGetMyPropertiesResponse,
                                      onRetry: () => safeSetState(() {}));
                                }

                                return Builder(
                                  builder: (context) {
                                    final eachOwnProperty =
                                        DOVIAAPIPropertyContextGroup
                                                .getMyPropertiesCall
                                                .data(
                                                    listViewGetMyPropertiesResponse
                                                        .jsonBody)
                                                ?.toList() ??
                                            [];

                                    final searchQuery = _model
                                            .searchController?.text
                                            .toLowerCase() ??
                                        '';
                                    final filteredPublished =
                                        eachOwnProperty.where((item) {
                                      if (searchQuery.isEmpty) return true;
                                      final itemName =
                                          getJsonField(item, r'''$.name''')
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              '';
                                      return itemName.contains(searchQuery);
                                    }).toList();

                                    if (filteredPublished.isEmpty) {
                                      return _emptyText(searchQuery.isEmpty
                                          ? 'Todavía no tienes propiedades publicadas.'
                                          : 'Ninguna propiedad publicada coincide con tu búsqueda.');
                                    }

                                    return Column(
                                      children: [
                                        ListView.separated(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          // La lista crece dentro del scroll
                                          // de la pantalla: sin scroll propio
                                          // para que el gesto sobre las cards
                                          // mueva la página.
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          itemCount: _showAllPublished
                                              ? filteredPublished.length
                                              : filteredPublished.length.clamp(
                                                  0, _publishedPreviewCount),
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 16.0),
                                          itemBuilder:
                                              (context, eachOwnPropertyIndex) {
                                            final eachOwnPropertyItem =
                                                filteredPublished[
                                                    eachOwnPropertyIndex];
                                            return SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  context
                                                      .pushNamed(
                                                        'DOVIA_CLIENT_MisPropiedades_PropiedadPublicada',
                                                        queryParameters: {
                                                          'propertyId':
                                                              serializeParam(
                                                            getJsonField(
                                                                    eachOwnPropertyItem,
                                                                    r'''$.id''')
                                                                .toString(),
                                                            ParamType.String,
                                                          ),
                                                          'propertyStatus':
                                                              serializeParam(
                                                            'PUBLISHED',
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      )
                                                      .then((_) =>
                                                          safeSetState(() {}));
                                                },
                                                child: Stack(
                                                  children: [
                                                    custom_widgets
                                                        .DoviaClientHouseCard(
                                                      showFavorite: false,
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          1.0,
                                                      height: 0.0,
                                                      imageUrl: getJsonField(
                                                                  eachOwnPropertyItem,
                                                                  r'''$.photos[0].url''')
                                                              ?.toString() ??
                                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                                                      name: getJsonField(
                                                              eachOwnPropertyItem,
                                                              r'''$.name''')
                                                          ?.toString(),
                                                      type: getJsonField(
                                                          eachOwnPropertyItem,
                                                          r'''$.listingType'''),
                                                      price:
                                                          '${getJsonField(eachOwnPropertyItem, r'''$.price''') ?? getJsonField(eachOwnPropertyItem, r'''$.saleInfo.salePrice''') ?? getJsonField(eachOwnPropertyItem, r'''$.rentInfo.monthlyRent''') ?? getJsonField(eachOwnPropertyItem, r'''$.offerOptions[0].price''') ?? 0}',
                                                      landArea: castToType<
                                                              double>(
                                                          getJsonField(
                                                              eachOwnPropertyItem,
                                                              r'''$.features.general.landArea''')),
                                                      constructionArea: castToType<
                                                              int>(
                                                          getJsonField(
                                                              eachOwnPropertyItem,
                                                              r'''$.features.general.constructionArea''')),
                                                      bedrooms: castToType<int>(
                                                          getJsonField(
                                                              eachOwnPropertyItem,
                                                              r'''$.features.general.bedrooms''')),
                                                      bathrooms: castToType<
                                                              int>(
                                                          getJsonField(
                                                              eachOwnPropertyItem,
                                                              r'''$.features.general.bathrooms''')),
                                                      location:
                                                          propertyLocationLabel(
                                                              eachOwnPropertyItem),
                                                      parkingSpots: castToType<
                                                              int>(
                                                          getJsonField(
                                                              eachOwnPropertyItem,
                                                              r'''$.features.general.parkingSpots''')),
                                                      isFavorite: getJsonField(
                                                        eachOwnPropertyItem,
                                                        r'''$.isFavorite''',
                                                      ),
                                                      onAddToFavorites:
                                                          () async {
                                                        if (FFAppState()
                                                                .UserRole !=
                                                            'VISITOR') {
                                                          _model.apiResultj56 =
                                                              await DOVIAAPIFavoriteContextGroup
                                                                  .addPropertyToFavoritesCall
                                                                  .call(
                                                            authToken:
                                                                currentAuthenticationToken,
                                                            propertyId: getJsonField(
                                                                    eachOwnPropertyItem,
                                                                    r'''$.id''')
                                                                .toString(),
                                                          );

                                                          if ((_model
                                                                  .apiResultj56
                                                                  ?.succeeded ??
                                                              true)) {
                                                            if (!context
                                                                .mounted)
                                                              return;
                                                            await showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              enableDrag: false,
                                                              context: context,
                                                              builder:
                                                                  (context) {
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
                                                                  child:
                                                                      Padding(
                                                                    padding: MediaQuery
                                                                        .viewInsetsOf(
                                                                            context),
                                                                    child:
                                                                        TusFavoritosCarpetasModalWidget(
                                                                      isCreatingNewFolderPARAM:
                                                                          false,
                                                                      houseId: getJsonField(
                                                                              eachOwnPropertyItem,
                                                                              r'''$.id''')
                                                                          .toString(),
                                                                      propertyName: getJsonField(
                                                                              eachOwnPropertyItem,
                                                                              r'''$.name''')
                                                                          .toString(),
                                                                      propertyImage:
                                                                          _modalImage(
                                                                              eachOwnPropertyItem),
                                                                      propertyIsFavorite:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ).then((value) =>
                                                                safeSetState(
                                                                    () {}));
                                                          } else {
                                                            if (!context
                                                                .mounted)
                                                              return;
                                                            await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (alertDialogContext) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Error'),
                                                                  content: Text((_model
                                                                          .apiResultj56
                                                                          ?.bodyText ??
                                                                      '')),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(alertDialogContext),
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
                                                            builder:
                                                                (dialogContext) {
                                                              return Dialog(
                                                                elevation: 0,
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                alignment: const AlignmentDirectional(
                                                                        0.0,
                                                                        0.0)
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
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
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
                                                                          eachOwnPropertyItem,
                                                                          r'''$.id''')
                                                                      .toString(),
                                                                  propertyName: getJsonField(
                                                                          eachOwnPropertyItem,
                                                                          r'''$.name''')
                                                                      .toString(),
                                                                  propertyImage:
                                                                      _modalImage(
                                                                          eachOwnPropertyItem),
                                                                  propertyIsFavorite:
                                                                      true,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                        safeSetState(() {});
                                                      },
                                                    ),
                                                    // Publicada con un trato
                                                    // aceptado aún sin finalizar.
                                                    Positioned(
                                                      top: 12.0,
                                                      right: 12.0,
                                                      child:
                                                          DealInProgressBadge(
                                                        propertyId: getJsonField(
                                                                    eachOwnPropertyItem,
                                                                    r'''$.id''')
                                                                ?.toString() ??
                                                            '',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        if (filteredPublished.length >
                                            _publishedPreviewCount)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0),
                                            child: FFButtonWidget(
                                              onPressed: () => safeSetState(
                                                  () => _showAllPublished =
                                                      !_showAllPublished),
                                              text: _showAllPublished
                                                  ? 'Ver menos'
                                                  : 'Ver más',
                                              options: FFButtonOptions(
                                                height: 36.0,
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        24.0, 0.0, 24.0, 0.0),
                                                color: const Color(0xFFCCE3E4),
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .publicSans(),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                elevation: 0.0,
                                                borderRadius:
                                                    BorderRadius.circular(99.0),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          _publishButton(),
                          _sectionTitle(
                              'Propiedades aún no publicadas o pausadas'),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: _fetchAllPending(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: DoviaSpinner(),
                                  );
                                }
                                final res = snapshot.data!;
                                final allProperties =
                                    res.jsonBody['data'] as List<dynamic>? ??
                                        [];

                                final searchQuery2 = _model
                                        .searchController?.text
                                        .toLowerCase() ??
                                    '';
                                final filteredPending =
                                    allProperties.where((p) {
                                  final st = getJsonField(p, r'''$.status''')
                                      as String?;
                                  // Vendidas/rentadas van a "Operaciones
                                  // cerradas", no a pendientes.
                                  final isPendingStatus = st != 'PUBLISHED' &&
                                      st != 'SOLD' &&
                                      st != 'RENTED';
                                  if (!isPendingStatus) return false;
                                  if (searchQuery2.isEmpty) return true;
                                  final name = getJsonField(p, r'''$.name''')
                                          ?.toString()
                                          .toLowerCase() ??
                                      '';
                                  return name.contains(searchQuery2);
                                }).toList();

                                if (filteredPending.isEmpty) {
                                  return _emptyText(searchQuery2.isEmpty
                                      ? 'No tienes propiedades pendientes de publicar.'
                                      : 'Ninguna propiedad pendiente coincide con tu búsqueda.');
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredPending.length,
                                  itemBuilder: (context, idx) {
                                    final p = filteredPending[idx];
                                    final status =
                                        getJsonField(p, r'''$.status''')
                                                as String? ??
                                            '';
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          final visitIdFromApi = getJsonField(p,
                                                  r'''$.operativeListerVisit.visitId''')
                                              ?.toString();
                                          final hasVisit = visitIdFromApi !=
                                                  null ||
                                              getJsonField(p,
                                                      r'''$.lastVisitId''') !=
                                                  null;
                                          final finalVisitId = visitIdFromApi ??
                                              getJsonField(
                                                      p, r'''$.lastVisitId''')
                                                  ?.toString() ??
                                              '';

                                          if (status == 'ARCHIVED') {
                                            // Paused: go to property dashboard to reactivate
                                            context
                                                .pushNamed(
                                                  'DOVIA_CLIENT_MisPropiedades_PropiedadPublicada',
                                                  queryParameters: {
                                                    'propertyId':
                                                        serializeParam(
                                                      getJsonField(
                                                              p, r'''$.id''')
                                                          .toString(),
                                                      ParamType.String,
                                                    ),
                                                    'propertyStatus':
                                                        serializeParam(
                                                      'ARCHIVED',
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                )
                                                .then(
                                                    (_) => safeSetState(() {}));
                                          } else if (status == 'IN_PROCESS' ||
                                              status == 'PENDING_REVIEW' ||
                                              (status == 'DRAFT' && hasVisit)) {
                                            context.pushNamed(
                                              'DOVIA_CLIENT_MisPropiedades_Visita_1',
                                              queryParameters: {
                                                'visitId': serializeParam(
                                                    finalVisitId,
                                                    ParamType.String),
                                              },
                                            );
                                          } else if (status == 'DRAFT') {
                                            // El borrador solo existe una vez enviado el formulario, así que
                                            // lo que falta es agendar la visita del operativo.
                                            context.pushNamed(
                                              DOVIACLIENTMisPropiedadesAgendarVisitaWidget
                                                  .routeName,
                                              queryParameters: {
                                                'propertyId': serializeParam(
                                                  getJsonField(p, r'''$.id''')
                                                      .toString(),
                                                  ParamType.String,
                                                ),
                                              }.withoutNulls,
                                            );
                                          }
                                        },
                                        child: MisPropiedadesHouseCardWidget(
                                          property: p,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          // Operaciones cerradas: el trámite legal terminó y
                          // el backend marcó la propiedad como vendida o
                          // rentada. Sólo aparece si hay alguna.
                          FutureBuilder<ApiCallResponse>(
                            future: _fetchClosed(),
                            builder: (context, snapshot) {
                              final all = snapshot.data?.jsonBody['data']
                                      as List<dynamic>? ??
                                  const [];
                              final closed = all.where((p) {
                                final st =
                                    getJsonField(p, r'''$.status''') as String?;
                                return st == 'SOLD' || st == 'RENTED';
                              }).toList();
                              if (closed.isEmpty)
                                return const SizedBox.shrink();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 33.0, 0.0, 20.0),
                                    child: Text(
                                      'Operaciones cerradas',
                                      style: GoogleFonts.publicSans(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.33,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                  ),
                                  for (final p in closed)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: MisPropiedadesHouseCardWidget(
                                          property: p),
                                    ),
                                ],
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
                        activeTab: DOVIACLIENTMisPropiedadesWidget.routeName,
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

  // ── Propuestas Recientes ──────────────────────────────────────────────────

  Future<void> _loadProposals() async {
    final result =
        await context.read<OffersRepository>().loadProposalsOnMyProperties();
    if (!mounted) return;
    safeSetState(() {
      _isLoadingProposals = false;
      if (result case Success(:final data)) {
        _proposalsBoard = data;
      }
    });
  }

  /// Carrusel superior con las propuestas recibidas más recientes.
  ///
  /// El punto rojo del encabezado se enciende cuando hay ofertas nuevas,
  /// contraofertas sin leer o avances del proceso legal que el propietario
  /// todavía no abrió.
  Widget _propuestasRecientesSection() {
    final proposals = _proposalsBoard.recent();
    final hasUnread = proposals.any(hasUnreadOwnerProposalUpdate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 33.0, 0.0, 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Propuestas Recientes',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600),
                          fontSize: 17.0,
                          letterSpacing: 0.33,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.3,
                        ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(width: 8.0),
                    Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDA0010),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              // "Ver más" como texto, igual que en las otras pantallas.
              InkWell(
                onTap: () async {
                  await context.pushNamed(
                      DOVIACLIENTPropuestasRecientesWidget.routeName);
                  if (!mounted) return;
                  await _loadProposals();
                },
                child: Text(
                  'Ver más',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font:
                            GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 14.0,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoadingProposals)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: DoviaSpinner()),
          )
        else if (proposals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Todavía no has recibido propuestas.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          )
        else
          SizedBox(
            height: 260.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: proposals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (context, index) {
                final proposal = proposals[index];
                return PropuestaRecienteCardWidget(
                  proposal: proposal,
                  hasUnreadUpdate: hasUnreadOwnerProposalUpdate(proposal),
                  onOpen: () async {
                    await openOwnerProposal(context, proposal);
                    if (!mounted) return;
                    await _loadProposals();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
