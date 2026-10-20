import '/core/network_image_size.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_report_popup/s_h_o_w_i_n_g_report_popup_widget.dart';
import '/showing/s_h_o_w_i_n_g_to_navegation_app/s_h_o_w_i_n_g_to_navegation_app_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 's_h_o_w_i_n_g_propiedad_a_mostrar_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_properties.dart';
import '/index.dart';
export 's_h_o_w_i_n_g_propiedad_a_mostrar_model.dart';

class SHOWINGPropiedadAMostrarWidget extends StatefulWidget {
  const SHOWINGPropiedadAMostrarWidget({
    super.key,
    this.visitId,
  });

  final String? visitId;

  static String routeName = 'SHOWING_PropiedadAMostrar';
  static String routePath = '/sHOWINGPropiedadAMostrar';

  @override
  State<SHOWINGPropiedadAMostrarWidget> createState() =>
      _SHOWINGPropiedadAMostrarWidgetState();
}

class _SHOWINGPropiedadAMostrarWidgetState
    extends State<SHOWINGPropiedadAMostrarWidget> {
  late SHOWINGPropiedadAMostrarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = true;
  String? _loadError;

  // Loaded from API
  String _propertyName = '';
  String _propertyType = '';
  String _address = '';
  String _instructions = '';
  String _propertyImage = '';
  double? _lat;
  double? _lng;
  String _visitDate = '';
  String _visitTime = '';
  String? _propertyId;
  String _price = '';

  // Property details
  String _landArea = '0';
  String _constructionArea = '0';
  int _bedrooms = 0;
  int _bathrooms = 0;

  // Owner details
  String _ownerName = '';
  String _ownerAvatarUrl = '';
  String _ownerPhone = '';
  String _ownerAge = '';
  String _ownerGender = '';
  String _ownerNationality = '';

  // Client details
  String _clientName = '';
  String _clientAvatarUrl = '';
  String _clientPhone = '';
  String _clientAge = '';
  String _clientGender = '';
  String _clientNationality = '';

  bool _arrivedLoading = false;
  bool _arrivedSent = false;
  bool _routeLoading = false;
  bool _onMyWayRetried = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGPropiedadAMostrarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.visitId != null && widget.visitId!.isNotEmpty) {
        _loadOverview();
      } else {
        safeSetState(() => _loading = false);
      }
    });
  }

  Future<void> _loadOverview() async {
    final res =
        await DOVIAAPIVisitContextGroup.getShowingVisitOverviewCall.call(
      authToken: currentAuthenticationToken,
      visitId: widget.visitId,
    );

    if (!mounted) return;
    if (!res.succeeded) {
      safeSetState(() {
        _loading = false;
        _loadError = 'No se pudo cargar la información de la visita.';
      });
      return;
    }

    final data = getJsonField(res.jsonBody, r'$.data');
    if (data is! Map) {
      safeSetState(() {
        _loading = false;
        _loadError = 'Información de la visita no válida.';
      });
      return;
    }

    final prop = data['property'];
    final owner = data['ownerProfile'];
    // El backend manda al interesado como `requester`.
    final client = data['requester'] ?? data['clientProfile'] ?? data['client'];

    String propertyName = '';
    String propertyType = '';
    String address = '';
    String instructions = '';
    String propertyImage = '';
    double? lat;
    double? lng;
    String price = '';
    String landArea = '0';
    String constructionArea = '0';
    int bedrooms = 0;
    int bathrooms = 0;

    if (prop is Map) {
      propertyName =
          prop['name']?.toString() ?? prop['title']?.toString() ?? '';
      final lt = prop['listingType'];
      propertyType = (lt is List && lt.isNotEmpty)
          ? lt[0].toString()
          : prop['propertyType']?.toString() ?? '';
      final locAddr = _deepMap(prop, ['location', 'address']);
      address = locAddr?['fullAddress']?.toString() ??
          locAddr?['street']?.toString() ??
          '';
      propertyImage = prop['image']?.toString() ?? '';
      final coords = _deepValue(prop, ['location', 'geo', 'coordinates']);
      if (coords is List && coords.length >= 2) {
        lng = (coords[0] as num?)?.toDouble();
        lat = (coords[1] as num?)?.toDouble();
      }

      final priceVal = prop['price'] ?? prop['saleInfo']?['salePrice'];
      price = priceVal?.toString() ?? '';

      final general = prop['features']?['general'] as Map?;
      if (general != null) {
        bedrooms = (general['bedrooms'] as num?)?.toInt() ?? 0;
        bathrooms = (general['bathrooms'] as num?)?.toInt() ?? 0;
        constructionArea = general['constructionArea']?.toString() ?? '0';
        landArea = general['landArea']?.toString() ?? '0';
      }
    }

    // Owner details
    String ownerName = '';
    String ownerAvatarUrl = '';
    String ownerPhone = '';
    String ownerAge = '';
    String ownerGender = '';
    String ownerNationality = '';

    if (owner is Map) {
      ownerName = owner['fullName']?.toString() ?? '';
      ownerAvatarUrl = owner['avatar']?.toString() ?? '';
      final phone = owner['phone'];
      if (phone is Map) {
        final cc = phone['countryCode']?.toString() ?? '';
        final num = phone['number']?.toString() ?? '';
        ownerPhone = '$cc $num'.trim();
      }
      ownerAge = owner['age']?.toString() ?? '';
      ownerGender = _genderLabel(owner['gender']);
      ownerNationality = owner['nationality']?.toString() ?? '';
    }

    // Client details
    String clientName = '';
    String clientAvatarUrl = '';
    String clientPhone = '';
    String clientAge = '';
    String clientGender = '';
    String clientNationality = '';

    if (client is Map) {
      clientName = client['fullName']?.toString() ?? '';
      clientAvatarUrl = client['avatar']?.toString() ?? '';
      final phone = client['phone'];
      if (phone is Map) {
        final cc = phone['countryCode']?.toString() ?? '';
        final num = phone['number']?.toString() ?? '';
        clientPhone = '$cc $num'.trim();
      }
      clientAge = client['age']?.toString() ?? '';
      clientGender = _genderLabel(client['gender']);
      clientNationality = client['nationality']?.toString() ?? '';
    }

    // Instructions
    final visitMap = data['visit'] is Map ? data['visit'] as Map : {};
    instructions = data['visit']?['instructions']?.toString() ??
        data['instructions']?.toString() ??
        '';

    // Date and time
    String visitDate = '';
    String visitTime = '';
    final slot = data['confirmedTimeSlot'] ??
        data['confirmedSlot'] ??
        visitMap['confirmedTimeSlot'] ??
        visitMap['confirmedSlot'];
    if (slot is Map) {
      visitDate = slot['date']?.toString() ?? '';
      visitTime = slot['time']?.toString() ?? '';
    }

    final propertyId = prop?['id']?.toString() ??
        prop?['_id']?.toString() ??
        data['propertyId']?.toString();

    if (propertyId != null && propertyId.isNotEmpty) {
      final propRes = await DOVIAAPIPropertyContextGroup.getPropertyByIDCall
          .call(propertyId: propertyId);
      if (propRes.succeeded) {
        final d = getJsonField(propRes.jsonBody, r'$.data.data') ??
            getJsonField(propRes.jsonBody, r'$.data');
        if (d is Map) {
          if (propertyName.isEmpty)
            propertyName =
                d['name']?.toString() ?? d['title']?.toString() ?? '';
          if (propertyImage.isEmpty)
            propertyImage = d['image']?.toString() ?? '';

          final locAddr = _deepMap(d, ['location', 'address']);
          if (address.isEmpty) {
            address = locAddr?['fullAddress']?.toString() ??
                locAddr?['street']?.toString() ??
                '';
          }
          final coords = _deepValue(d, ['location', 'geo', 'coordinates']);
          if (coords is List && coords.length >= 2) {
            lng = (coords[0] as num?)?.toDouble() ?? lng;
            lat = (coords[1] as num?)?.toDouble() ?? lat;
          }
          final general = d['features']?['general'] as Map?;
          if (general != null) {
            bedrooms = (general['bedrooms'] as num?)?.toInt() ?? bedrooms;
            bathrooms = (general['bathrooms'] as num?)?.toInt() ?? bathrooms;
            constructionArea =
                general['constructionArea']?.toString() ?? constructionArea;
            landArea = general['landArea']?.toString() ?? landArea;
          }
          final lt = d['listingType'];
          if (propertyType.isEmpty) {
            propertyType = (lt is List && lt.isNotEmpty)
                ? lt[0].toString()
                : d['propertyType']?.toString() ?? '';
          }
        }
      }
    }

    safeSetState(() {
      _propertyName = propertyName;
      _propertyType = propertyType;
      _address = address;
      _instructions = instructions;
      _propertyImage = propertyImage;
      _lat = lat;
      _lng = lng;
      _price = price;
      _landArea = landArea;
      _constructionArea = constructionArea;
      _bedrooms = bedrooms;
      _bathrooms = bathrooms;

      _ownerName = ownerName;
      _ownerAvatarUrl = ownerAvatarUrl;
      _ownerPhone = ownerPhone;
      _ownerAge = ownerAge;
      _ownerGender = ownerGender;
      _ownerNationality = ownerNationality;

      _clientName = clientName;
      _clientAvatarUrl = clientAvatarUrl;
      _clientPhone = clientPhone;
      _clientAge = clientAge;
      _clientGender = clientGender;
      _clientNationality = clientNationality;

      _visitDate = visitDate;
      _visitTime = visitTime;
      _propertyId = propertyId;

      _loading = false;
    });

    // Ruta iniciada en este celular pero el backend no lo sabe (sin datos de
    // contacto): se marca "en camino" una vez y se vuelve a cargar.
    if (_routeStarted && ownerName.isEmpty && !_onMyWayRetried) {
      _onMyWayRetried = true;
      final res =
          await DOVIAAPIVisitContextGroup.operativeListerOnMyWayCall.call(
        authToken: currentAuthenticationToken,
        visitId: widget.visitId,
      );
      debugPrint(
          '[ShowingVisita] on-my-way ${res.statusCode}: ${res.bodyText}');
      if (res.succeeded && mounted) await _loadOverview();
    }
  }

  String _genderLabel(dynamic g) {
    switch (g?.toString().toUpperCase()) {
      case 'MALE':
      case 'M':
        return 'Masculino';
      case 'FEMALE':
      case 'F':
        return 'Femenino';
      case null:
      case '':
        return '';
      default:
        return 'Otro';
    }
  }

  Map<String, dynamic>? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur as Map<String, dynamic> : null;
  }

  dynamic _deepValue(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur;
  }

  /// True once the agent has started the route for this visit ("en camino").
  /// Read live from persisted app state so it survives navigation/reentry.
  /// Guarded so a stale app-state singleton (dev hot-reload) can't crash build.
  bool get _routeStarted {
    final id = widget.visitId;
    if (id == null || id.isEmpty) return false;
    try {
      return FFAppState().routeStartedVisits.contains(id);
    } catch (_) {
      return false;
    }
  }

  bool get _isPrivacyGated {
    // Starting the route unlocks the private info regardless of the time window.
    if (_routeStarted) return false;
    if (_visitDate.isEmpty || _visitTime.isEmpty) return true;
    try {
      final d = _visitDate.split('-');
      final t = _visitTime.split(':');
      if (d.length < 3 || t.length < 2) return true;
      final visitDt = DateTime(
        int.parse(d[0]),
        int.parse(d[1]),
        int.parse(d[2]),
        int.parse(t[0]),
        int.parse(t[1]),
      );
      final difference = visitDt.difference(DateTime.now()).inMinutes;
      return difference > 120;
    } catch (_) {
      return true;
    }
  }

  Future<void> _startRoute() async {
    if (_routeLoading) return;
    if (widget.visitId == null || widget.visitId!.isEmpty) return;

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No hay coordenadas disponibles para esta propiedad.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const SHOWINGToNavegationAppWidget(),
        );
      },
    );
    if (confirm != true) return;

    safeSetState(() => _routeLoading = true);

    if (!_routeStarted) {
      try {
        FFAppState().addToRouteStartedVisits(widget.visitId!);
      } catch (_) {}
    }
    // "En camino" solo marca el trayecto (no cambia el estado de la visita)
    // y hace que el overview revele propietario y cliente. Si ya estaba
    // marcado, el backend responde error y se ignora.
    final onMyWay =
        await DOVIAAPIVisitContextGroup.operativeListerOnMyWayCall.call(
      authToken: currentAuthenticationToken,
      visitId: widget.visitId,
    );
    if (!onMyWay.succeeded) {
      debugPrint('[ShowingVisita] on-my-way ${onMyWay.statusCode}: '
          '${onMyWay.bodyText}');
    }
    _loadOverview();

    // Abre la app de navegación con las coordenadas de la casa. Sin
    // canLaunchUrl: en Android 11+ devuelve false sin <queries>.
    final uri = isiOS
        ? Uri.parse('https://maps.apple.com/?daddr=$_lat,$_lng')
        : Uri.parse('https://www.google.com/maps/dir/?api=1'
            '&destination=$_lat,$_lng');
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el mapa')),
      );
    }

    if (!mounted) return;
    safeSetState(() => _routeLoading = false);
  }

  Future<void> _onReport() async {
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const SHOWINGReportPopupWidget(),
        );
      },
    );
    if (message == null || message.trim().isEmpty) return;

    final res = await DOVIAAPIVisitContextGroup.showingReportProblemCall.call(
      authToken: currentAuthenticationToken,
      visitId: widget.visitId,
      message: message.trim(),
    );
    if (!mounted) return;

    if (res.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reporte enviado. La visita se volvió a publicar para otro asesor.',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      if (mounted) {
        context.pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el reporte.')),
      );
    }
  }

  /// Pide permiso y toma la posición actual; null si no se pudo.
  Future<Position?> _currentPosition() async {
    void msg(String t) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
      }
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      msg('Activá la ubicación del dispositivo para notificar tu llegada.');
      return null;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      msg('Necesitamos permiso de ubicación para notificar tu llegada.');
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      msg('No pudimos obtener tu ubicación. Intentá de nuevo.');
      return null;
    }
  }

  /// Envía la ubicación real del Showing: el backend marca la visita
  /// "en la ubicación" y avisa a propietario y cliente.
  Future<void> _notifyArrival() async {
    if (_arrivedLoading || _arrivedSent) return;
    safeSetState(() => _arrivedLoading = true);
    final pos = await _currentPosition();
    if (pos == null) {
      safeSetState(() => _arrivedLoading = false);
      return;
    }
    final res = await DOVIAAPIVisitContextGroup.updateVisitLocationCall.call(
      authToken: currentAuthenticationToken,
      visitId: widget.visitId,
      lat: pos.latitude,
      lng: pos.longitude,
    );
    if (!res.succeeded) {
      debugPrint('[ShowingVisita] location ${res.statusCode}: ${res.bodyText}');
    }
    if (!mounted) return;
    safeSetState(() {
      _arrivedLoading = false;
      if (res.succeeded) _arrivedSent = true;
    });
    final backendMsg = getJsonField(res.jsonBody, r'$.message')?.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.succeeded
              ? '¡Llegada notificada!'
              : (backendMsg != null && backendMsg.isNotEmpty
                  ? backendMsg
                  : 'Error al notificar la llegada'),
        ),
        backgroundColor: res.succeeded ? const Color(0xFF007376) : Colors.red,
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty || priceStr == 'null') return '';
    final numVal = double.tryParse(priceStr);
    if (numVal == null) return priceStr;
    final parts = numVal.toStringAsFixed(0).split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String Function(Match) matchFunc = (Match match) => '${match[1]},';
    final formatted = parts[0].replaceAllMapped(reg, matchFunc);
    return 'Q $formatted';
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
                      model: _model.sHOWINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGHeaderWidget(
                        title: 'Propiedad a\nmostrar',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF007376),
                                  ),
                                ),
                              ),
                            )
                          : _loadError != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 40.0),
                                  child: Center(
                                    child: Text(
                                      _loadError!,
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(),
                                            color: Colors.red,
                                          ),
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 20.0, 0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(
                                                    -1.0, 0.0),
                                            child: Text(
                                              'Propiedad',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                            ),
                                          ),
                                          FFButtonWidget(
                                            onPressed: () {
                                              if (_propertyId != null &&
                                                  _propertyId!.isNotEmpty) {
                                                context.pushNamed(
                                                  DOVIACLIENTPropiedadSeleccionadaNewWidget
                                                      .routeName,
                                                  queryParameters: {
                                                    'propertyId':
                                                        serializeParam(
                                                            _propertyId,
                                                            ParamType.String),
                                                    'isReadOnly':
                                                        serializeParam(true,
                                                            ParamType.bool),
                                                  }.withoutNulls,
                                                );
                                              }
                                            },
                                            icon: Icon(
                                              Icons.remove_red_eye_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 15.0,
                                            ),
                                            text: 'Ver más',
                                            options: FFButtonOptions(
                                              height: 30.0,
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .accent1,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    font:
                                                        GoogleFonts.publicSans(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 20.0, 0.0, 0.0),
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(10.0, 10.0, 10.0, 10.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                height: 150.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  child: _propertyImage
                                                          .isNotEmpty
                                                      ? Image.network(
                                                          _propertyImage,
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (_, __, ___) =>
                                                                  Image.asset(
                                                            'assets/images/casa_card_sobreMiVisita.png',
                                                            width: 200.0,
                                                            height: 200.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          cacheWidth:
                                                              networkImageCacheWidth(
                                                                  width: 200.0,
                                                                  height:
                                                                      200.0),
                                                        )
                                                      : Image.asset(
                                                          'assets/images/casa_card_sobreMiVisita.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 20.0, 0.0, 0.0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          1.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                  child: IntrinsicWidth(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  -1.0, 0.0),
                                                          child: RichText(
                                                            textScaler:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .textScaler,
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      '$_propertyName\n',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '$_propertyType\n',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${_formatPrice(_price)}\n',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium,
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${_landArea} m² Terreno | ${_constructionArea} m² Const\n${_bedrooms} Hab | ${_bathrooms} Baños\n',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall,
                                                                )
                                                              ],
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .publicSans(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.5,
                                                                  ),
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
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        _address.isNotEmpty
                                            ? _address
                                            : 'Sin dirección',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
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
                                    ),
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Text(
                                          _instructions.isNotEmpty
                                              ? _instructions
                                              : 'Sin instrucciones de ingreso',
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
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
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
                                      ),
                                    ),
                                    if (_isPrivacyGated)
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFFE8F5F5), // Light green background
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(
                                                12.0, 12.0, 12.0, 12.0),
                                            child: Text(
                                              'Se mostrará la información más detallada al iniciar ruta o 2 horas antes de la cita.',
                                              textAlign: TextAlign.center,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 14.0,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 20.0, 0.0, 0.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 180.0,
                                          // Mapa fijo con la casa marcada; sin coordenadas, un aviso.
                                          child: _lat != null && _lng != null
                                              ? custom_widgets.InteractiveMap(
                                                  key: ValueKey('$_lat,$_lng'),
                                                  width: double.infinity,
                                                  height: 180.0,
                                                  accessToken: FFAppConstants
                                                      .MapboxAccessToken,
                                                  startLat: _lat!,
                                                  startLng: _lng!,
                                                  readOnly: true,
                                                )
                                              : Container(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .accent1,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'La propiedad no tiene ubicación cargada',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    if (!_routeStarted)
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: FFButtonWidget(
                                          onPressed: _routeLoading
                                              ? null
                                              : _startRoute,
                                          text: _routeLoading
                                              ? 'Iniciando...'
                                              : 'Iniciar ruta',
                                          icon: const Icon(
                                            Icons.navigation_outlined,
                                            size: 18.0,
                                          ),
                                          options: FFButtonOptions(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            height: 48.0,
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            textStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  font: GoogleFonts.publicSans(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ),
                                      ),
                                    if (!_isPrivacyGated)
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.42,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(10.0, 10.0,
                                                          10.0, 10.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: _ownerAvatarUrl
                                                                .isNotEmpty
                                                            ? Image.network(
                                                                _ownerAvatarUrl,
                                                                width: 120.0,
                                                                height: 120.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (_,
                                                                        __,
                                                                        ___) =>
                                                                    Image.asset(
                                                                  'assets/images/nahid_photo.png',
                                                                  width: 120.0,
                                                                  height: 120.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                cacheWidth:
                                                                    networkImageCacheWidth(
                                                                        width:
                                                                            120.0,
                                                                        height:
                                                                            120.0),
                                                              )
                                                            : Image.asset(
                                                                'assets/images/nahid_photo.png',
                                                                width: 120.0,
                                                                height: 120.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                12.0, 0.0, 0.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .accent1,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24.0),
                                                          ),
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      10.0,
                                                                      4.0,
                                                                      10.0,
                                                                      4.0),
                                                              child: Text(
                                                                'Información de propietario',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .publicSans(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      fontSize:
                                                                          12.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
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
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                12.0, 0.0, 0.0),
                                                        child: Text(
                                                          _ownerName.isNotEmpty
                                                              ? _ownerName
                                                              : 'Sin nombre',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Edad: ${_ownerAge.isNotEmpty ? _ownerAge : "—"}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Sexo: ${_ownerGender.isNotEmpty ? _ownerGender : "—"}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Nacionalidad: ${_ownerNationality.isNotEmpty ? _ownerNationality : "—"}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: InkWell(
                                                            onTap: _ownerPhone
                                                                    .isNotEmpty
                                                                ? () => _callPhone(
                                                                    _ownerPhone)
                                                                : null,
                                                            child: Text(
                                                              'Teléfono: ${_ownerPhone.isNotEmpty ? _ownerPhone : "—"}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(),
                                                                    color: _ownerPhone.isNotEmpty
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primary
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.42,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(10.0, 10.0,
                                                          10.0, 10.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: _clientAvatarUrl
                                                                .isNotEmpty
                                                            ? Image.network(
                                                                _clientAvatarUrl,
                                                                width: 120.0,
                                                                height: 120.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder: (_,
                                                                        __,
                                                                        ___) =>
                                                                    Image.asset(
                                                                  'assets/images/nahid_photo.png',
                                                                  width: 120.0,
                                                                  height: 120.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                cacheWidth:
                                                                    networkImageCacheWidth(
                                                                        width:
                                                                            120.0,
                                                                        height:
                                                                            120.0),
                                                              )
                                                            : Image.asset(
                                                                'assets/images/nahid_photo.png',
                                                                width: 120.0,
                                                                height: 120.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                12.0, 0.0, 0.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .accent1,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24.0),
                                                          ),
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      10.0,
                                                                      4.0,
                                                                      10.0,
                                                                      4.0),
                                                              child: Text(
                                                                'Información del cliente',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .publicSans(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      fontSize:
                                                                          12.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
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
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                12.0, 0.0, 0.0),
                                                        child: Text(
                                                          _clientName.isNotEmpty
                                                              ? _clientName
                                                              : 'Sin nombre',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Edad: ${_clientAge.isNotEmpty ? _clientAge : "—"}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Sexo: ${_clientGender.isNotEmpty ? _clientGender : "—"}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Nacionalidad: ${_clientNationality.isNotEmpty ? _clientNationality : "—"}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  4.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: InkWell(
                                                            onTap: _clientPhone
                                                                    .isNotEmpty
                                                                ? () => _callPhone(
                                                                    _clientPhone)
                                                                : null,
                                                            child: Text(
                                                              'Teléfono: ${_clientPhone.isNotEmpty ? _clientPhone : "—"}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(),
                                                                    color: _clientPhone.isNotEmpty
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primary
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (!_isPrivacyGated)
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: wrapWithModel(
                                          model: _model.primaryButtonModel,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: PrimaryButtonWidget(
                                            text: _arrivedSent
                                                ? '¡Llegada notificada!'
                                                : (_arrivedLoading
                                                    ? 'Enviando...'
                                                    : 'Enviar mi ubicación y notificar'),
                                            onTap: _notifyArrival,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 16.0, 0.0, 20.0),
                                      child: FFButtonWidget(
                                        onPressed: _onReport,
                                        text: 'Tuve un problema',
                                        options: FFButtonOptions(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: 48.0,
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                          color: Colors.transparent,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                color: const Color(0xFFC90A0A),
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                              ),
                                          elevation: 0.0,
                                          borderSide: const BorderSide(
                                            color: Color(0xFFC90A0A),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                      ),
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
