import '/shared_components/carousel_arrow/carousel_arrow_button.dart';
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
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_header_widget.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
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
    this.initialImageUrl,
  });

  final String? propertyId;
  final bool isReadOnly;

  /// Foto que ya tenía quien abre la ficha (Ej: el pin del mapa): se muestra
  /// de entrada mientras llega el resto, en vez de la imagen default.
  final String? initialImageUrl;

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

  /// Fotos agrupadas por ambiente, tal como las manda el backend.
  Map<String, List<String>> _imagesByRoom = {};
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

    final initialImage = widget.initialImageUrl?.trim() ?? '';
    if (initialImage.isNotEmpty) _carouselImages = [initialImage];
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
      final parsed =
          (listingTypeRaw as List?)?.map((e) => e.toString()).toList() ?? [];
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
      // La foto principal va primero en la galería.
      if (imagesObj is Map && imagesObj['principal'] is List) {
        final principal = (imagesObj['principal'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty);
        if (principal.isNotEmpty && !imagesList.contains(principal.last)) {
          imagesList.add(principal.last);
        }
      }
      final imagesByRoom = <String, List<String>>{};
      if (imagesObj is Map) {
        imagesObj.forEach((room, value) {
          if (value is! List) return;
          final urls = <String>[];
          for (final url in value) {
            final s = url?.toString() ?? '';
            if (s.isEmpty) continue;
            urls.add(s);
            if (!imagesList.contains(s)) imagesList.add(s);
          }
          if (urls.isNotEmpty) imagesByRoom[room.toString()] = urls;
        });
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
        _imagesByRoom = imagesByRoom;
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

  /// Las fotos que manda el backend para la propiedad. Cuando no hay
  /// ninguna se muestra la imagen que trae la app, para no dejar el hueco
  /// en blanco.
  List<Widget> _carouselItems() {
    // Mientras carga la ficha se muestra un fondo neutro: la imagen default
    // queda sólo para propiedades que de verdad no tienen fotos.
    if (_carouselImages.isEmpty && _propertyData == null) {
      return [_carouselLoadingItem()];
    }
    final urls = _carouselImages.isEmpty ? <String>[''] : _carouselImages;
    return urls.map(_carouselItem).toList();
  }

  Widget _carouselLoadingItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: double.infinity,
          height: 220.0,
          color: const Color(0xFFE9EEEE),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22.0,
            height: 22.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Color(0xFF007376),
            ),
          ),
        ),
      ),
    );
  }

  List<String> get _availabilityLabels {
    final types = _listingType.join(' ').toUpperCase();
    return [
      if (types.contains('SALE')) 'Venta',
      if (types.contains('RENT')) 'Renta',
    ];
  }

  String get _propertyTypeLabel {
    switch (_propertyType.toUpperCase()) {
      case 'HOUSE':
        return 'Casa';
      case 'APARTMENT':
        return 'Departamento';
      case 'PENTHOUSE':
        return 'Penthouse';
      case 'STUDIO':
        return 'Estudio';
      case 'FARM':
        return 'Finca';
      case 'LOT':
        return 'Terreno';
      default:
        return _propertyType.isEmpty
            ? ''
            : '${_propertyType[0]}${_propertyType.substring(1).toLowerCase()}';
    }
  }

  Widget _infoChip(
    String label,
    IconData icon, {
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: foreground),
          const SizedBox(width: 5.0),
          Text(
            label,
            style: GoogleFonts.publicSans(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  /// Dato destacado (precio o metros): valor arriba, etiqueta abajo.
  Widget _statBox(String value, String label) {
    return Container(
      height: 64.0,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent1,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.publicSans(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
          ),
          const SizedBox(height: 3.0),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// Desplegables de la ficha con esquinas redondeadas y sombra suave.
  Widget _roundedSection(Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x14000000),
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: child,
      ),
    );
  }

  Widget _carouselArrow(IconData icon, VoidCallback onTap) {
    return CarouselArrowButton(
      isLeft: icon == Icons.arrow_back_ios_new_rounded,
      onTap: onTap,
    );
  }

  Widget _carouselItem(String url) {
    Widget fallback() => Image.asset(
          'assets/images/casa_card_sobreMiVisita.png',
          fit: BoxFit.cover,
        );

    return GestureDetector(
      onTap: _showGallery,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: SizedBox(
            width: double.infinity,
            height: 220.0,
            child: url.isEmpty
                ? fallback()
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : Container(color: const Color(0xFFE9EEEE)),
                    errorBuilder: (_, __, ___) => fallback(),
                  ),
          ),
        ),
      ),
    );
  }

  /// Las mismas fotos del carrusel, agrupadas por ambiente. Se arman desde
  /// lo que ya se parseo para el carrusel: antes la galeria releia el JSON
  /// por otro camino y mostraba menos fotos que las de la ficha.
  Map<String, List<String>> _galleryCategories() {
    final categories = <String, List<String>>{};
    final inRooms = _imagesByRoom.values.expand((u) => u).toSet();
    final sueltas = _carouselImages.where((u) => !inRooms.contains(u)).toList();
    if (sueltas.isNotEmpty) categories['Principal'] = sueltas;
    _imagesByRoom.forEach((room, urls) {
      final label =
          room.isEmpty ? room : '${room[0].toUpperCase()}${room.substring(1)}';
      categories.putIfAbsent(label, () => []).addAll(urls);
    });
    return categories;
  }

  void _showGallery() async {
    _trackInteraction();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodasLasFotosWidget(
          extraCategories: _galleryCategories(),
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
        final status1 =
            getJsonField(item, r'''$.status''')?.toString().toUpperCase() ?? '';
        final status2 = getJsonField(item, r'''$.offerStatus''')
                ?.toString()
                .toUpperCase() ??
            '';
        final status3 = getJsonField(item, r'''$.processStatus''')
                ?.toString()
                .toUpperCase() ??
            '';

        final isCancelled = (status1 == 'CANCELLED' ||
            status2 == 'CANCELLED' ||
            status3 == 'CANCELLED');
        final isRejected = (status1 == 'REJECTED' ||
            status2 == 'REJECTED' ||
            status3 == 'REJECTED');

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
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ya tienes una oferta pendiente de aceptar o una contraoferta para este inmueble. Visualiza el estatus en la pantalla de Mis Ofertas.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                        context
                            .pushNamed(DOVIACLIENTMisOfertasWidget.routeName);
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
                        'Ir a Mis ofertas',
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

  /// En solo lectura, el Showing ve su propio header y navbar.
  bool get _isShowing => FFAppState().UserRole == 'SHOWING_AGENT';

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
                      if (widget.isReadOnly && _isShowing)
                        wrapWithModel(
                          model: _model.sHOWINGHeaderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: SHOWINGHeaderWidget(
                            title: _propertyName.isNotEmpty
                                ? _propertyName
                                : 'Propiedad',
                          ),
                        )
                      else if (widget.isReadOnly)
                        wrapWithModel(
                          model: _model.oPERATIVELISTINGHeaderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: OPERATIVELISTINGHeaderWidget(
                            titleText: _propertyName.isNotEmpty
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
                                            DOVIACLIENTHomePageWidget
                                                .routeName);
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
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
                              // El nombre puede ser largo: sin Expanded el titulo se sale de
                              // la pantalla en lugar de repartirse en dos lineas.
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28.0),
                                  child: RichText(
                                    textScaler:
                                        MediaQuery.of(context).textScaler,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _propertyName.isNotEmpty
                                              ? _propertyName
                                              : 'Propiedad',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 32.0, 0.0, 0.0),
                              // Carrusel a todo el ancho, con las flechas
                              // juntas debajo para no tapar las fotos.
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Las fotos llegan hasta los bordes de la
                                  // pantalla, sin el margen del contenido.
                                  SizedBox(
                                    height: 220.0,
                                    child: OverflowBox(
                                      minWidth:
                                          MediaQuery.sizeOf(context).width,
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width,
                                      child: CarouselSlider(
                                        items: _carouselItems(),
                                        carouselController:
                                            _model.carouselController ??=
                                                CarouselSliderController(),
                                        options: CarouselOptions(
                                          height: 220.0,
                                          initialPage: 0,
                                          viewportFraction: 0.92,
                                          disableCenter: false,
                                          enlargeCenterPage: false,
                                          enlargeFactor: 0.0,
                                          enableInfiniteScroll: false,
                                          scrollDirection: Axis.horizontal,
                                          autoPlay: false,
                                          onPageChanged: (index, _) => _model
                                              .carouselCurrentIndex = index,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _carouselArrow(
                                        Icons.arrow_back_ios_new_rounded,
                                        () => _model.carouselController
                                            ?.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      _carouselArrow(
                                        Icons.arrow_forward_ios_rounded,
                                        () =>
                                            _model.carouselController?.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        ),
                                      ),
                                    ],
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
                                                        color:
                                                            Color(0x33000000),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                } else {
                                                  final repo = context
                                                      .read<VisitsRepository>();
                                                  final hasPending = await repo
                                                      .hasActiveVisitForProperty(
                                                          widget.propertyId ??
                                                              '');

                                                  if (hasPending) {
                                                    // Show pending visit modal directly — skip the scheduling form
                                                    if (!context.mounted) return;
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
                                                              Colors
                                                                  .transparent,
                                                          child:
                                                              _PendingVisitDialog(
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
                                                    if (!context.mounted) return;
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
                                                                AgendarCitaWidget(
                                                              propertyId: widget
                                                                  .propertyId,
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
                            // Etiquetas (tipo de propiedad y para qué está
                            // disponible), dirección y descripción.
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 22.0, 0.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_propertyTypeLabel.isNotEmpty ||
                                      _availabilityLabels.isNotEmpty)
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: [
                                        if (_propertyTypeLabel.isNotEmpty)
                                          _infoChip(
                                            _propertyTypeLabel,
                                            Icons.home_work_outlined,
                                            background: const Color(0xFFECEFF1),
                                            foreground: const Color(0xFF455A64),
                                          ),
                                        ..._availabilityLabels.map(
                                          (label) => _infoChip(
                                            label,
                                            label == 'Venta'
                                                ? Icons.sell_outlined
                                                : Icons.key_outlined,
                                            background: const Color(0xFFDDEFEF),
                                            foreground:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (_address.isNotEmpty) ...[
                                    const SizedBox(height: 14.0),
                                    Text(
                                      _address,
                                      style: GoogleFonts.publicSans(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w700,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                  if (_description.isNotEmpty) ...[
                                    const SizedBox(height: 10.0),
                                    Text(
                                      _description,
                                      style: GoogleFonts.publicSans(
                                        fontSize: 14.0,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _statBox(
                                      _price.isNotEmpty ? 'Q$_price' : '—',
                                      'Precio más impuestos',
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: _statBox(
                                      _landArea.isNotEmpty
                                          ? '$_landArea m²'
                                          : '—',
                                      'Terreno',
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: _statBox(
                                      _constructionArea.isNotEmpty
                                          ? '$_constructionArea m²'
                                          : '—',
                                      'Construcción',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _roundedSection(wrapWithModel(
                                    model: _model.propiedadCaracteristicasModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PropiedadCaracteristicasWidget(
                                      bedrooms: _bedrooms,
                                      bathrooms: _bathrooms,
                                      halfBathrooms: _halfBathrooms,
                                      parkingSpots: _parkingSpots,
                                      floors: _floors,
                                    ),
                                  )),
                                  _roundedSection(wrapWithModel(
                                    model: _model.porpiedadesAmenidadesModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PorpiedadesAmenidadesWidget(
                                      amenities: _amenitiesData,
                                    ),
                                  )),
                                  _roundedSection(wrapWithModel(
                                    model: _model.propiedadesSobreElSectorModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PropiedadesSobreElSectorWidget(
                                      description: _sectorDescription,
                                      caminableRating: _caminableRating,
                                      comercialRating: _comercialRating,
                                      verdesRating: _verdesRating,
                                      lat: _lat,
                                      lng: _lng,
                                    ),
                                  )),
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
                    if (widget.isReadOnly && _isShowing)
                      wrapWithModel(
                        model: _model.sHOWINGNavbarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const SHOWINGNavbarWidget(),
                      )
                    else if (widget.isReadOnly)
                      wrapWithModel(
                        model: _model.oPERATIVELISTINGNavbarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const OPERATIVELISTINGNavbarWidget(),
                      )
                    else
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
