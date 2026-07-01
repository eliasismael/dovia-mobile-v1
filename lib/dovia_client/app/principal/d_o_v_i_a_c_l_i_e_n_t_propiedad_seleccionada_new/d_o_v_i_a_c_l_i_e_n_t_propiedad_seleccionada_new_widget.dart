import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/principal/todas_las_fotos/todas_las_fotos_widget.dart';
import '/dovia_client/app/principal/agendar_cita/agendar_cita_widget.dart';
import '/components/porpiedades_amenidades_widget.dart';
import '/components/propiedad_caracteristicas_widget.dart';
import '/components/propiedades_sobre_el_sector_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/custom_auth/auth_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/repositories/visits_repository.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_new_model.dart';
import 'recorrido_360_modal.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_new_model.dart';

class DOVIACLIENTPropiedadSeleccionadaNewWidget extends StatefulWidget {
  const DOVIACLIENTPropiedadSeleccionadaNewWidget({
    super.key,
    required this.propertyId,
    this.isReadOnly = false,
  });

  final String? propertyId;
  final bool isReadOnly;

  static String routeName = 'DOVIA_CLIENT_PropiedadSeleccionadaNew';
  static String routePath = '/propiedad';

  @override
  State<DOVIACLIENTPropiedadSeleccionadaNewWidget> createState() =>
      _DOVIACLIENTPropiedadSeleccionadaNewWidgetState();
}

class _DOVIACLIENTPropiedadSeleccionadaNewWidgetState
    extends State<DOVIACLIENTPropiedadSeleccionadaNewWidget> {
  late DOVIACLIENTPropiedadSeleccionadaNewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  ApiCallResponse? _propertyData;
  List<String> _listingType = [];
  String _propertyName = '';
  String _propertyType = '';
  String _address = '';
  String _description = '';
  String _price = '';
  String _landArea = '';
  String _constructionArea = '';
  int _bedrooms = 0;
  int _bathrooms = 0;
  int _halfBathrooms = 0;
  int _parkingSpots = 0;
  int _floors = 0;
  String _propertyCode = '';
  List<String> _carouselImages = [];
  Map<String, dynamic>? _amenitiesData;
  double _lat = 14.3;
  double _lng = -90.5;
  String _sectorDescription = '';
  double _caminableRating = 5.0;
  double _comercialRating = 5.0;
  double _verdesRating = 5.0;

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => DOVIACLIENTPropiedadSeleccionadaNewModel());

    _loadPropertyData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitsRepository>().loadMyVisits();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _loadPropertyData() async {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) return;
    final response =
        await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
      propertyId: widget.propertyId,
    );
    if (mounted) {
      final listingTypeRaw =
          getJsonField(response.jsonBody, r'''$.data.data.listingType''') ??
          getJsonField(response.jsonBody, r'''$.data.listingType''');
      final parsed = (listingTypeRaw as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final d = (getJsonField(response.jsonBody, r'''$.data.data''') ??
                 getJsonField(response.jsonBody, r'''$.data''')) as Map?;

      final nameRaw = d?['name'] ?? d?['title'];
      final general = d?['features']?['general'] as Map?;
      final locationAddr = d?['location']?['address'] as Map?;
      final descRaw = d?['description']?['raw'] ?? d?['description'];
      final priceVal = d?['price'] ?? d?['saleInfo']?['salePrice'];

      // Flatten all room image arrays into a single ordered list
      final imagesObj = d?['images'];
      final imagesList = <String>[];
      final mainImg = d?['image']?.toString() ?? '';
      if (mainImg.isNotEmpty) imagesList.add(mainImg);
      if (imagesObj is Map) {
        for (final v in imagesObj.values) {
          if (v is List) {
            for (final url in v) {
              final s = url?.toString() ?? '';
              if (s.isNotEmpty && !imagesList.contains(s)) imagesList.add(s);
            }
          }
        }
      }

      safeSetState(() {
        _propertyData = response;
        _listingType = parsed;
        _propertyName = nameRaw?.toString() ?? '';
        _propertyType = d?['propertyType']?.toString() ?? '';
        _address = locationAddr?['fullAddress']?.toString() ?? '';
        _description = descRaw?.toString() ?? '';
        _price = priceVal?.toString() ?? '';
        _landArea = general?['landArea']?.toString() ?? '';
        _constructionArea = general?['constructionArea']?.toString() ?? '';
        _bedrooms = (general?['bedrooms'] as num?)?.toInt() ?? 0;
        _bathrooms = (general?['bathrooms'] as num?)?.toInt() ?? 0;
        _halfBathrooms = (general?['halfBathrooms'] as num?)?.toInt() ?? 0;
        _parkingSpots = (general?['parkingSpots'] as num?)?.toInt() ?? 0;
        _floors = (general?['floors'] as num?)?.toInt() ?? 0;
        _carouselImages = imagesList;
        _propertyCode = d?['code']?.toString() ?? d?['internalCode']?.toString() ?? d?['folio']?.toString() ?? '';
        if (_propertyCode.isEmpty && widget.propertyId != null) {
          _propertyCode = widget.propertyId!.length > 5 
              ? widget.propertyId!.substring(widget.propertyId!.length - 5).toUpperCase() 
              : widget.propertyId!.toUpperCase();
        }

        final loc = d?['location'] as Map?;
        final geo = loc?['geo'] as Map?;
        final coords = geo?['coordinates'] as List?;
        _lng = coords != null && coords.isNotEmpty ? (coords[0] as num).toDouble() : -90.5;
        _lat = coords != null && coords.length >= 2 ? (coords[1] as num).toDouble() : 14.3;

        _amenitiesData = (d?['features']?['amenities'] as Map?)?.cast<String, dynamic>();

        final hood = d?['features']?['neighborhood'] as Map?;
        _sectorDescription = hood?['description']?.toString() ?? loc?['neighborhoodDescription']?.toString() ?? '';
        
        double parseRating(dynamic v) {
          if (v == null) return 5.0;
          return (v is num ? v : double.tryParse(v.toString()) ?? 5.0).toDouble();
        }

        _caminableRating = parseRating(hood?['walkable']);
        _comercialRating = parseRating(hood?['commerceAndServices']);
        _verdesRating = parseRating(hood?['greenAreas']);
      });

      final createdBy = getJsonField(response.jsonBody, r'''$.data.data.createdBy''')?.toString() ?? 
                        getJsonField(response.jsonBody, r'''$.data.createdBy''')?.toString();
      
      if (createdBy != currentUserUid) {
        DOVIAAPIMetricsContextGroup.trackPropertyViewCall.call(
          propertyId: widget.propertyId,
          bearerAuth: currentAuthenticationToken,
        );
      }
    }
  }

  void _trackInteraction() {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) return;
    final createdBy = getJsonField(_propertyData?.jsonBody, r'''$.data.data.createdBy''')?.toString() ?? 
                      getJsonField(_propertyData?.jsonBody, r'''$.data.createdBy''')?.toString();
    if (createdBy != currentUserUid) {
      DOVIAAPIMetricsContextGroup.trackPropertyInteractionCall.call(
        propertyId: widget.propertyId,
        bearerAuth: currentAuthenticationToken,
      );
    }
  }

  void _showGallery() async {
    _trackInteraction();
    final api = DOVIAAPIPropertyContextGroup.getPropertyByIDCall;
    final body = _propertyData?.jsonBody;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodasLasFotosWidget(
          habitacionImages: body != null ? api.imgHabitacion(body) : null,
          cocinaImages: body != null ? api.imgCocina(body) : null,
          terrazaImages: body != null ? api.imgTerraza(body) : null,
        ),
      ),
    );
  }

  void _showPlanos() async {
    _trackInteraction();
    final api = DOVIAAPIPropertyContextGroup.getPropertyByIDCall;
    final body = _propertyData?.jsonBody;
    final planos = body != null ? api.imgPlanos(body) : null;

    if (planos == null || planos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay planos disponibles para esta propiedad.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodasLasFotosWidget(
          extraCategories: {'Planos': planos},
        ),
      ),
    );
  }

  bool get _has360Url {
    final body = _propertyData?.jsonBody;
    if (body == null) return false;
    final url = DOVIAAPIPropertyContextGroup.getPropertyByIDCall.video360Url(body);
    return url != null && url.isNotEmpty;
  }

  void _show360() async {
    _trackInteraction();
    final api = DOVIAAPIPropertyContextGroup.getPropertyByIDCall;
    final body = _propertyData?.jsonBody;
    final url = body != null ? api.video360Url(body) : null;

    if (url != null && url.isNotEmpty) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Cerrar',
        barrierColor: Colors.black.withOpacity(0.7),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Recorrido360Modal(url: url),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: anim1,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
          );
        },
      );
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'El recorrido 360° no está disponible para esta propiedad.')),
      );
    }
  }

  Future<void> _handleOfertar() async {
    _trackInteraction();
    if (widget.propertyId == null || widget.propertyId!.isEmpty) return;

    if (FFAppState().UserRole == 'VISITOR') {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
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
        ),
      );
      return;
    }

    final offersResponse =
        await DOVIAAPIOfferContextGroup.listMyOffersCall.call(
      authToken: currentAuthenticationToken,
    );

    if (!mounted) return;

    // Dynamic routing based on property listingType
    final listingTypeStr = _listingType.toString().toUpperCase();
    final hasSale = listingTypeStr.contains('SALE');
    final hasRent = listingTypeStr.contains('RENT');

    if (offersResponse.succeeded) {
      List items = [];
      final body = offersResponse.jsonBody;
      if (body is List) {
        items = body;
      } else {
        items = getJsonField(body, r'''$.data.items''') as List? ??
                getJsonField(body, r'''$.data''') as List? ??
                getJsonField(body, r'''$.items''') as List? ?? 
                [];
      }
      
      final activeOffers = items.where((item) {
        final status1 = getJsonField(item, r'''$.status''')?.toString().toUpperCase() ?? '';
        final status2 = getJsonField(item, r'''$.offerStatus''')?.toString().toUpperCase() ?? '';
        final status3 = getJsonField(item, r'''$.processStatus''')?.toString().toUpperCase() ?? '';
        
        final isCancelled = (status1 == 'CANCELLED' || status2 == 'CANCELLED' || status3 == 'CANCELLED');
        final isRejected = (status1 == 'REJECTED' || status2 == 'REJECTED' || status3 == 'REJECTED');

        final itemStr = item.toString();
        final wid = widget.propertyId ?? 'UNKNOWN_ID';
        final propIdMatch = itemStr.contains(wid);

        return propIdMatch && !isCancelled && !isRejected;
      }).toList();

      bool blockOffers = false;
      if (hasSale && hasRent) {
         if (activeOffers.length >= 2) blockOffers = true;
      } else {
         if (activeOffers.isNotEmpty) blockOffers = true;
      }

      if (blockOffers) {
        _showActiveOfferModal();
        return;
      }
    }

    if (!mounted) return;

    if (hasSale && hasRent) {
      // Mixed property — show selection screen
      context.pushNamed(
        DOVIACLIENTOfertarWidget.routeName,
        queryParameters: {
          'propertyId': serializeParam(widget.propertyId, ParamType.String),
        }.withoutNulls,
      );
    } else if (hasSale) {
      // SALE only — go directly to unified form in compra mode
      context.pushNamed(
        DOVIACLIENTOfertaCompraWidget.routeName,
        queryParameters: {
          'propertyId': serializeParam(widget.propertyId, ParamType.String),
          'offerType': serializeParam('compra', ParamType.String),
        }.withoutNulls,
      );
    } else {
      // RENT only (or unknown) — go directly to unified form in renta mode
      context.pushNamed(
        DOVIACLIENTOfertaCompraWidget.routeName,
        queryParameters: {
          'propertyId': serializeParam(widget.propertyId, ParamType.String),
          'offerType': serializeParam('renta', ParamType.String),
        }.withoutNulls,
      );
    }
  }

  void _showActiveOfferModal() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ya tienes una oferta en curso',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontStyle,
                      ),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ya tienes una oferta en pendiente de acetar o una contraoferta para este inmueble. Visualiza el estatus en la pantalla de Mis Visitas.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: FlutterFlowTheme.of(context).primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancelar',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.pushNamed(DOVIACLIENTMisVisitasWidget.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Ir a Mis visitas',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (widget.isReadOnly)
                        wrapWithModel(
                          model: _model.sHOWINGHeaderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: SHOWINGHeaderWidget(
                            title: _propertyName.isNotEmpty
                                ? _propertyName
                                : 'Propiedades a mostrar',
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 42.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: const BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                              .alternate,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: SvgPicture.asset(
                                            'assets/images/IconoVolverAtras.svg',
                                            width: 200.0,
                                            height: 200.0,
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
                                            DOVIACLIENTHomePageWidget.routeName);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(0.0),
                                        child: SvgPicture.asset(
                                          'assets/images/D-verde.svg',
                                          width: 28.0,
                                          height: 36.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ].divide(const SizedBox(width: 8.0)),
                                ),
                              ),
                              RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: _propertyName.isNotEmpty ? _propertyName : 'Propiedad',
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
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
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
                                    ].divide(const SizedBox(width: 8.0)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 100.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            if (widget.isReadOnly)
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (_propertyCode.isNotEmpty)
                                      Text(
                                        'Código $_propertyCode',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          fontSize: 14.0,
                                          color: FlutterFlowTheme.of(context).primary,
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                    Container(
                                      width: 32.0,
                                      height: 32.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF7F7F7),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10.0,
                                            color: Color(0x33000000),
                                            offset: Offset(0.0, 2.0),
                                          )
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        onTap: _trackInteraction,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: SvgPicture.asset(
                                              'assets/images/download.svg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Container(
                                      width: 32.0,
                                      height: 32.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF7F7F7),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10.0,
                                            color: Color(0x33000000),
                                            offset: Offset(0.0, 2.0),
                                          )
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        onTap: _trackInteraction,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: SvgPicture.asset(
                                              'assets/images/share-android.svg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 40.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      await _model.carouselController
                                          ?.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                                    child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: SvgPicture.asset(
                                          'assets/images/page-left.svg',
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 320.0,
                                    height: 160.0,
                                    child: CarouselSlider(
                                      items: [
                                        GestureDetector(
                                          onTap: _showGallery,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: Container(
                                              width: 212.0,
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  1.6,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/casa_card_sobreMiVisita.png',
                                                  width: 100.0,
                                                  height: 100.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _showGallery,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: Container(
                                              width: 212.0,
                                              height: 160.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                child: Image.network(
                                                  'https://picsum.photos/seed/146/600',
                                                  width: 212.0,
                                                  height: 160.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _showGallery,
                                          child: Container(
                                            width: 212.0,
                                            height: 160.0,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              child: Image.network(
                                                'https://picsum.photos/seed/119/600',
                                                width: 212.0,
                                                height: 160.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      carouselController:
                                          _model.carouselController ??=
                                              CarouselSliderController(),
                                      options: CarouselOptions(
                                        initialPage: 0,
                                        viewportFraction: 0.7,
                                        disableCenter: false,
                                        enlargeCenterPage: false,
                                        enlargeFactor: 0.0,
                                        enableInfiniteScroll: false,
                                        scrollDirection: Axis.horizontal,
                                        autoPlay: false,
                                        onPageChanged: (index, _) =>
                                            _model.carouselCurrentIndex = index,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      await _model.carouselController?.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                                    child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: SvgPicture.asset(
                                          'assets/images/page-right.svg',
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        InkWell(
                                           splashColor: Colors.transparent,
                                           focusColor: Colors.transparent,
                                           hoverColor: Colors.transparent,
                                           highlightColor: Colors.transparent,
                                           onTap: _has360Url ? _show360 : null,
                                           child: Container(
                                             width: 40.0,
                                             height: 40.0,
                                             decoration: BoxDecoration(
                                               color: _has360Url
                                                   ? const Color(0xFFF7F7F7)
                                                   : const Color(0xFFE0E0E0),
                                               boxShadow: _has360Url
                                                   ? const [
                                                       BoxShadow(
                                                         blurRadius: 10.0,
                                                         color: Color(0x33000000),
                                                         offset: Offset(
                                                           0.0,
                                                           2.0,
                                                         ),
                                                       )
                                                     ]
                                                   : null,
                                               shape: BoxShape.circle,
                                             ),
                                             child: ClipRRect(
                                               borderRadius:
                                                   BorderRadius.circular(8.0),
                                               child: Opacity(
                                                 opacity: _has360Url ? 1.0 : 0.4,
                                                 child: SvgPicture.asset(
                                                   'assets/images/360-view.svg',
                                                   width: 200.0,
                                                   height: 200.0,
                                                   fit: BoxFit.none,
                                                 ),
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
                                            _showGallery();
                                          },
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF7F7F7),
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10.0,
                                                  color: Color(0x33000000),
                                                  offset: Offset(
                                                    0.0,
                                                    2.0,
                                                  ),
                                                )
                                              ],
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: SvgPicture.asset(
                                                'assets/images/media-image-list.svg',
                                                width: 200.0,
                                                height: 200.0,
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
                                          onTap: _showPlanos,
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF7F7F7),
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10.0,
                                                  color: Color(0x33000000),
                                                  offset: Offset(
                                                    0.0,
                                                    2.0,
                                                  ),
                                                )
                                              ],
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: SvgPicture.asset(
                                                'assets/images/ruler_combine.svg',
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 8.0)),
                                    ),
                                  ),
                                  if (!widget.isReadOnly)
                                    Container(
                                      decoration: const BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF7F7F7),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 10.0,
                                                color: Color(0x33000000),
                                                offset: Offset(
                                                  0.0,
                                                  2.0,
                                                ),
                                              )
                                            ],
                                            shape: BoxShape.circle,
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              _trackInteraction();
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: SvgPicture.asset(
                                                'assets/images/download.svg',
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF7F7F7),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 10.0,
                                                color: Color(0x33000000),
                                                offset: Offset(
                                                  0.0,
                                                  2.0,
                                                ),
                                              )
                                            ],
                                            shape: BoxShape.circle,
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              _trackInteraction();
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: SvgPicture.asset(
                                                'assets/images/share-android.svg',
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!widget.isReadOnly)
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 22.0, 0.0, 0.0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
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
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      10.0, 10.0, 10.0, 10.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                            _model.ventaORenta = 'venta';
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 144.0,
                                            height: 44.0,
                                            decoration: BoxDecoration(
                                              color: _model.ventaORenta ==
                                                      'venta'
                                                  ? FlutterFlowTheme.of(context)
                                                      .accent1
                                                  : FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                            ),
                                            child: Align(
                                              alignment: const AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Text(
                                                'Venta',
                                                style: FlutterFlowTheme.of(
                                                        context)
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
                                                                  .ventaORenta ==
                                                              'venta'
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
                                            _model.ventaORenta = 'renta';
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 144.0,
                                            height: 44.0,
                                            decoration: BoxDecoration(
                                              color: _model.ventaORenta ==
                                                      'renta'
                                                  ? FlutterFlowTheme.of(context)
                                                      .accent1
                                                  : FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                            ),
                                            child: Align(
                                              alignment: const AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Text(
                                                'Renta',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(
                                                        context)
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
                                                                  .ventaORenta ==
                                                              'renta'
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
                                          ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 20.0)),
                                  ),
                                ),
                              ),
                            ),
                            if (!widget.isReadOnly)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(),
                                      child: Builder(
                                        builder: (context) => wrapWithModel(
                                          model: _model.primaryButtonModel,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: PrimaryButtonWidget(
                                            text: 'Agendar cita',
                                            onTap: () async {
                                              if (FFAppState().UserRole ==
                                                  'VISITOR') {
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
                                                            const VisitorRestrictionPopupWidget(),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                final repo = context
                                                    .read<VisitsRepository>();
                                                final hasPending = await repo
                                                    .hasActiveVisitForProperty(
                                                        widget.propertyId ?? '');

                                                if (hasPending) {
                                                  // Show pending visit modal directly — skip the scheduling form
                                                  await showDialog(
                                                    context: context,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.5),
                                                    builder: (dialogContext) {
                                                      return Dialog(
                                                        elevation: 0,
                                                        insetPadding:
                                                            EdgeInsets.zero,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        child: _PendingVisitDialog(
                                                          onViewVisits: () {
                                                            Navigator.of(
                                                                    dialogContext)
                                                                .pop();
                                                            context.pushNamed(
                                                                DOVIACLIENTMisVisitasWidget
                                                                    .routeName);
                                                          },
                                                          onDismiss: () =>
                                                              Navigator.of(
                                                                      dialogContext)
                                                                  .pop(),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  // No pending visit — open the scheduling form
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
                                                              AgendarCitaWidget(
                                                            propertyId:
                                                                widget.propertyId,
                                                            hasPendingVisit:
                                                                false,
                                                            onNavigateToVisits:
                                                                () {
                                                              context.pushNamed(
                                                                  DOVIACLIENTMisVisitasWidget
                                                                      .routeName);
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(),
                                      child: Builder(
                                        builder: (context) => wrapWithModel(
                                          model: _model.secondaryButtonModel,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: SecondaryButtonWidget(
                                            text: 'Ofertar',
                                            onTap: _handleOfertar,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Container(
                                  decoration: const BoxDecoration(),
                                  child: RichText(
                                    textScaler:
                                        MediaQuery.of(context).textScaler,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _propertyType.isNotEmpty ? '${_propertyType[0]}${_propertyType.substring(1).toLowerCase()}\n' : '',
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
                                        TextSpan(
                                          text: _address.isNotEmpty ? '$_address\n' : '',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        TextSpan(
                                          text: '',
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
                                        TextSpan(
                                          text: _description,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        )
                                      ],
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.publicSans(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.3,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.5,
                                      height: 44.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .accent1,
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _price.isNotEmpty ? '\$$_price' : '—',
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
                                                  fontSize: 10.0,
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
                                          Text(
                                            'Precio más impuestos',
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
                                                  fontSize: 10.0,
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
                                        ].divide(const SizedBox(height: 5.0)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.5,
                                      height: 44.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .accent1,
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _landArea.isNotEmpty ? _landArea : '—',
                                            style: FlutterFlowTheme.of(context)
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
                                                  fontSize: 10.0,
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
                                          Text(
                                            'M2 de terreno',
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
                                                  fontSize: 10.0,
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
                                        ].divide(const SizedBox(height: 5.0)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.5,
                                      height: 44.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .accent1,
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _constructionArea.isNotEmpty ? _constructionArea : '—',
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
                                                  fontSize: 10.0,
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
                                          Text(
                                            'M2 de construcciónc',
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
                                                  fontSize: 10.0,
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
                                        ].divide(const SizedBox(height: 5.0)),
                                      ),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(),
                                    child: wrapWithModel(
                                      model:
                                          _model.propiedadCaracteristicasModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: PropiedadCaracteristicasWidget(
                                        bedrooms: _bedrooms,
                                        bathrooms: _bathrooms,
                                        halfBathrooms: _halfBathrooms,
                                        parkingSpots: _parkingSpots,
                                        floors: _floors,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: wrapWithModel(
                                      model: _model.porpiedadesAmenidadesModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: PorpiedadesAmenidadesWidget(
                                        amenities: _amenitiesData,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: wrapWithModel(
                                      model:
                                          _model.propiedadesSobreElSectorModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: PropiedadesSobreElSectorWidget(
                                        description: _sectorDescription,
                                        caminableRating: _caminableRating,
                                        comercialRating: _comercialRating,
                                        verdesRating: _verdesRating,
                                        lat: _lat,
                                        lng: _lng,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
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

/// Modal shown when the user already has a pending or approved visit for this property.
class _PendingVisitDialog extends StatelessWidget {
  final VoidCallback onViewVisits;
  final VoidCallback onDismiss;

  const _PendingVisitDialog({
    required this.onViewVisits,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF007376),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ya tienes una visita en proceso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00444B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ya solicitaste o tienes confirmada una cita para esta propiedad. Puedes revisar el estado en tu sección de visitas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onViewVisits,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007376),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ver mis visitas',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onDismiss,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF007376),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Volver a la propiedad',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
