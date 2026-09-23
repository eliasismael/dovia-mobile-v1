import '/backend/api_requests/api_calls.dart';
import '/components/porpiedades_amenidades_widget.dart';
import '/components/propiedad_caracteristicas_widget.dart';
import '/components/propiedades_sobre_el_sector_widget.dart';
import '/dovia_client/app/principal/todas_las_fotos/todas_las_fotos_widget.dart';
import '/dovia_client/app/principal/d_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_new/recorrido_360_modal.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import 'dart:ui';
import '/auth/custom_auth/auth_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 's_h_o_w_i_n_g_propiedad_detalle_model.dart';
export 's_h_o_w_i_n_g_propiedad_detalle_model.dart';

class SHOWINGPropiedadDetalleWidget extends StatefulWidget {
  const SHOWINGPropiedadDetalleWidget({
    super.key,
    required this.propertyId,
  });

  final String? propertyId;

  static String routeName = 'SHOWING_PropiedadDetalle';
  static String routePath = '/sHOWINGPropiedadDetalle';

  @override
  State<SHOWINGPropiedadDetalleWidget> createState() =>
      _SHOWINGPropiedadDetalleWidgetState();
}

class _SHOWINGPropiedadDetalleWidgetState
    extends State<SHOWINGPropiedadDetalleWidget> {
  late SHOWINGPropiedadDetalleModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  ApiCallResponse? _propertyData;
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
    _model = createModel(context, () => SHOWINGPropiedadDetalleModel());

    _loadPropertyData();
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
      final d = (getJsonField(response.jsonBody, r'''$.data.data''') ??
          getJsonField(response.jsonBody, r'''$.data''')) as Map?;

      final nameRaw = d?['name'] ?? d?['title'];
      final general = d?['features']?['general'] as Map?;
      final locationAddr = d?['location']?['address'] as Map?;
      final descRaw = d?['description']?['raw'] ?? d?['description'];
      final priceVal = d?['price'] ?? d?['saleInfo']?['salePrice'];

      safeSetState(() {
        _propertyData = response;
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
        _propertyCode = d?['code']?.toString() ??
            d?['internalCode']?.toString() ??
            d?['folio']?.toString() ??
            '';
        if (_propertyCode.isEmpty && widget.propertyId != null) {
          _propertyCode = widget.propertyId!.length > 5
              ? widget.propertyId!
                  .substring(widget.propertyId!.length - 5)
                  .toUpperCase()
              : widget.propertyId!.toUpperCase();
        }

        final loc = d?['location'] as Map?;
        final geo = loc?['geo'] as Map?;
        final coords = geo?['coordinates'] as List?;
        _lng = coords != null && coords.isNotEmpty
            ? (coords[0] as num).toDouble()
            : -90.5;
        _lat = coords != null && coords.length >= 2
            ? (coords[1] as num).toDouble()
            : 14.3;

        _amenitiesData =
            (d?['features']?['amenities'] as Map?)?.cast<String, dynamic>();

        final hood = d?['features']?['neighborhood'] as Map?;
        _sectorDescription = hood?['description']?.toString() ??
            loc?['neighborhoodDescription']?.toString() ??
            '';

        double parseRating(dynamic v) {
          if (v == null) return 5.0;
          return (v is num ? v : double.tryParse(v.toString()) ?? 5.0)
              .toDouble();
        }

        _caminableRating = parseRating(hood?['walkable']);
        _comercialRating = parseRating(hood?['commerceAndServices']);
        _verdesRating = parseRating(hood?['greenAreas']);
      });

      final createdBy = getJsonField(
                  response.jsonBody, r'''$.data.data.createdBy''')
              ?.toString() ??
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
    final createdBy =
        getJsonField(_propertyData?.jsonBody, r'''$.data.data.createdBy''')
                ?.toString() ??
            getJsonField(_propertyData?.jsonBody, r'''$.data.createdBy''')
                ?.toString();
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
    final url =
        DOVIAAPIPropertyContextGroup.getPropertyByIDCall.video360Url(body);
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
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.sHOWINGHeaderModel,
                        updateCallback: () => safeSetState(() {}),
                        child: SHOWINGHeaderWidget(
                          title: _propertyName.isNotEmpty
                              ? _propertyName
                              : 'Propiedad a\nmostrar',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 100.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Código + descargar / compartir
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_propertyCode.isNotEmpty)
                                    Text(
                                      'Código $_propertyCode',
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
                                            fontSize: 14.0,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
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
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
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
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
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
                            // Carrusel de fotos
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
                                        duration:
                                            const Duration(milliseconds: 300),
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
                                        duration:
                                            const Duration(milliseconds: 300),
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
                            // Botones 360° / galería / planos
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                                        color:
                                                            Color(0x33000000),
                                                        offset:
                                                            Offset(0.0, 2.0),
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
                                                  offset: Offset(0.0, 2.0),
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
                                                  offset: Offset(0.0, 2.0),
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
                                ],
                              ),
                            ),
                            // Info de la propiedad
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
                                          text: _propertyType.isNotEmpty
                                              ? '${_propertyType[0]}${_propertyType.substring(1).toLowerCase()}\n'
                                              : '',
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
                                          text: _address.isNotEmpty
                                              ? '$_address\n'
                                              : '',
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
                            // Precio + metros
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
                                            _price.isNotEmpty
                                                ? 'Q$_price'
                                                : '—',
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
                                            _landArea.isNotEmpty
                                                ? _landArea
                                                : '—',
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
                                            _constructionArea.isNotEmpty
                                                ? _constructionArea
                                                : '—',
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
                                                ),
                                          ),
                                          Text(
                                            'M2 de construcción',
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
                                                ),
                                          ),
                                        ].divide(const SizedBox(height: 5.0)),
                                      ),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                            ),
                            // Componentes compartidos
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
                      model: _model.sHOWINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGNavbarWidget(),
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
