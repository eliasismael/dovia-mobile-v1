import '/core/network_image_size.dart';
import 'dart:async';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/operative_listing/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar/o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_primera_visita_model.dart';
export 'o_p_e_r_a_t_i_v_e_l_i_s_t_i_n_g_primera_visita_model.dart';

class OPERATIVELISTINGPrimeraVisitaWidget extends StatefulWidget {
  const OPERATIVELISTINGPrimeraVisitaWidget({
    super.key,
    this.visitId = '',
    this.isPrimeraVisita = true,
    this.propertyName = '',
    this.isReadOnly = false,
  });

  final String visitId;
  final bool isPrimeraVisita;
  final String propertyName;
  final bool isReadOnly;

  static String routeName = 'OPERATIVE_LISTING_PrimeraVisita';
  static String routePath = '/oPERATIVELISTINGPrimeraVisita';

  @override
  State<OPERATIVELISTINGPrimeraVisitaWidget> createState() =>
      _OPERATIVELISTINGPrimeraVisitaWidgetState();
}

class _OPERATIVELISTINGPrimeraVisitaWidgetState
    extends State<OPERATIVELISTINGPrimeraVisitaWidget> {
  late OPERATIVELISTINGPrimeraVisitaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _primary = Color(0xFF007376);
  static const Color _dark = Color(0xFF00444B);

  // Loaded from API
  String _ownerName = '';
  String _ownerAvatarUrl = '';
  String _propertyType = '';
  String _address = '';
  String _description = '';
  double? _lat;
  double? _lng;
  bool _loading = true;
  bool _onMyWayLoading = false;
  bool _onMyWaySent = false;
  bool _arrivedLoading = false;
  bool _arrivedSent = false;
  String _visitDate = '';
  String _visitTime = '';
  String _visitUtc = '';

  /// Número de Dovia HQ para dudas del operative. Provisorio hasta que el
  /// backend lo informe.
  static const String _kHqPhone = '+502 2222 0000';

  /// El backend fija el fin de la visita una hora después del inicio.
  static const Duration _kVisitLength = Duration(hours: 1);

  /// Re-evalúa el horario sin tener que salir de la pantalla.
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPERATIVELISTINGPrimeraVisitaModel());
    _clock =
        Timer.periodic(const Duration(seconds: 30), (_) => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.visitId.isNotEmpty) {
        FFAppState().lastActiveVisitId = widget.visitId;
        _loadOverview();
      } else {
        safeSetState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadOverview() async {
    final res = await DOVIAAPIVisitContextGroup
        .getOperativeListerVisitOverviewCall
        .call(
      authToken: currentAuthenticationToken,
      visitId: widget.visitId,
    );

    if (!mounted) return;
    if (!res.succeeded) {
      safeSetState(() => _loading = false);
      return;
    }

    final data = getJsonField(res.jsonBody, r'$.data');
    if (data is! Map) {
      safeSetState(() => _loading = false);
      return;
    }

    final prop = data['property'];
    final owner = data['ownerProfile'];

    String ownerName = '';
    String ownerAvatarUrl = '';
    String propertyType = '';
    String address = '';
    String description = '';
    double? lat;
    double? lng;

    if (owner is Map) {
      ownerName = owner['fullName']?.toString() ?? '';
      ownerAvatarUrl = owner['avatar']?.toString() ?? '';
    }

    if (prop is Map) {
      final lt = prop['listingType'];
      propertyType = (lt is List && lt.isNotEmpty)
          ? lt[0].toString()
          : prop['propertyType']?.toString() ?? '';
      final locAddr = _deepMap(prop, ['location', 'address']);
      address = locAddr?['fullAddress']?.toString() ??
          locAddr?['street']?.toString() ??
          '';
      description = prop['description']?.toString() ?? '';
      final coords = _deepValue(prop, ['location', 'geo', 'coordinates']);
      if (coords is List && coords.length >= 2) {
        lng = (coords[0] as num?)?.toDouble();
        lat = (coords[1] as num?)?.toDouble();
      }
    }

    String visitDate = '';
    String visitTime = '';
    String visitUtc = '';
    // El overview anida el horario en `visit.confirmedTimeSlot`.
    final visitData = data['visit'];
    final slot = (visitData is Map ? visitData['confirmedTimeSlot'] : null) ??
        data['confirmedSlot'];
    if (slot is Map) {
      visitDate = slot['date']?.toString() ?? '';
      visitTime = slot['time']?.toString() ?? '';
      visitUtc = slot['utcTimestamp']?.toString() ?? '';
    }
    // Al volver a la pantalla, lo ya avisado sigue marcado.
    final report =
        visitData is Map ? visitData['operativeLocationReport'] : null;
    final journey = report is Map ? report['status']?.toString() ?? '' : '';

    safeSetState(() {
      _ownerName = ownerName;
      _ownerAvatarUrl = ownerAvatarUrl;
      _propertyType = propertyType;
      _address = address;
      _description = description;
      _lat = lat;
      _lng = lng;
      _visitDate = visitDate;
      _visitTime = visitTime;
      _visitUtc = visitUtc;
      if (journey == 'ON_MY_WAY' || journey == 'AT_LOCATION') {
        _onMyWaySent = true;
      }
      if (journey == 'AT_LOCATION') _arrivedSent = true;
      _loading = false;
    });
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

  Future<void> _onMyWay() async {
    if (_onMyWaySent || _onMyWayLoading) return;
    safeSetState(() => _onMyWayLoading = true);

    final res = await DOVIAAPIVisitContextGroup.operativeListerOnMyWayCall.call(
      authToken: currentAuthenticationToken,
      visitId: widget.visitId,
    );

    if (!mounted) return;
    safeSetState(() {
      _onMyWayLoading = false;
      if (res.succeeded) _onMyWaySent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.succeeded
              ? 'Notificación enviada. ¡En camino!'
              : 'Error al enviar la notificación',
        ),
      ),
    );
  }

  /// Inicio de la visita en hora local. Prefiere el instante UTC del backend.
  DateTime? get _visitStart {
    final utc = DateTime.tryParse(_visitUtc);
    if (utc != null) return utc.toLocal();
    if (_visitDate.isEmpty || _visitTime.isEmpty) return null;
    final d = DateTime.tryParse(_visitDate);
    final t = _visitTime.split(':');
    if (d == null || t.length < 2) return null;
    return DateTime(d.year, d.month, d.day, int.tryParse(t[0]) ?? 0,
        int.tryParse(t[1]) ?? 0);
  }

  /// El checklist solo se abre dentro del horario asignado a la visita.
  bool get _isChecklistEnabled {
    final start = _visitStart;
    if (start == null) return false;
    final now = DateTime.now();
    return !now.isBefore(start) && now.isBefore(start.add(_kVisitLength));
  }

  String get _checklistHint {
    final start = _visitStart;
    if (start == null) return 'La visita no tiene horario asignado.';
    final end = start.add(_kVisitLength);
    String hm(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (DateTime.now().isBefore(start)) {
      return 'El checklist se habilita a las ${hm(start)}.';
    }
    return 'El horario de la visita terminó a las ${hm(end)}.';
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

  Future<void> _arrived() async {
    if (_arrivedSent || _arrivedLoading) return;
    safeSetState(() => _arrivedLoading = true);

    // Llegar se registra con la ubicación real: el backend marca la visita
    // "en la ubicación" con estas coordenadas.
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

    if (!mounted) return;
    safeSetState(() {
      _arrivedLoading = false;
      if (res.succeeded) _arrivedSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.succeeded
              ? '¡Llegada notificada al propietario!'
              : 'Error al notificar la llegada',
        ),
      ),
    );
  }

  Future<void> _callPhone() async {
    final uri = Uri(scheme: 'tel', path: _kHqPhone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String get _title {
    if (widget.isPrimeraVisita) return 'Primera visita';
    final name = widget.propertyName.isNotEmpty
        ? widget.propertyName
        : _address.isNotEmpty
            ? _address
            : 'la propiedad';
    return 'Visita en $name';
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
                    // ── Header ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 42.0, 20.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Back + Logo
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.safePop(),
                                child: Container(
                                  width: 35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
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
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => context.pushNamed(
                                    OPERATIVELISTINGHomeWidget.routeName),
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
                            ],
                          ),
                          // Title
                          Expanded(
                            child: Text(
                              _title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ),
                          // Location icon — active only for Primera Visita
                          Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: widget.isPrimeraVisita
                                  ? _primary
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: SvgPicture.asset(
                                widget.isPrimeraVisita
                                    ? 'assets/images/WhitePosition.svg'
                                    : 'assets/images/position.svg',
                                width: 8.0,
                                height: 8.0,
                                fit: BoxFit.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Body ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // ── Owner info ──────────────────────────
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 0.0),
                                    child: Text(
                                      'Información del propietario',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.publicSans(
                                                fontWeight: FontWeight.w600),
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                            color: _dark,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 16.0, 0.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 70.0,
                                          height: 70.0,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle),
                                          clipBehavior: Clip.antiAlias,
                                          child: _ownerAvatarUrl.isNotEmpty
                                              ? Image.network(
                                                  _ownerAvatarUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _avatarPlaceholder(),
                                                  cacheWidth:
                                                      networkImageCacheWidth(
                                                          width: 70,
                                                          height: 70),
                                                )
                                              : _avatarPlaceholder(),
                                        ),
                                        const SizedBox(height: 12),
                                        // Owner name
                                        Text(
                                          _ownerName.isNotEmpty
                                              ? _ownerName
                                              : 'Sin nombre',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.publicSans(
                                                    fontWeight:
                                                        FontWeight.w600),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _dark,
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Hablar con Dovia HQ box
                                        GestureDetector(
                                          onTap: _callPhone,
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .accent1,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 20),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Hablar con Dovia HQ',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .publicSans(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                        color: _primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                          Icons.phone_outlined,
                                                          size: 18,
                                                          color: Color(
                                                              0xFF007376)),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        _kHqPhone,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodySmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .publicSans(),
                                                              color: _primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ── Property type ───────────────────────
                                if (_propertyType.isNotEmpty) ...[
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 20.0, 0.0, 0.0),
                                      child: Text(
                                        'Tipo de vivienda',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.w600),
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: _dark,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 6.0, 0.0, 0.0),
                                      child: Text(
                                        _propertyType,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],

                                // ── Address ──────────────────────────────
                                if (_address.isNotEmpty) ...[
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 16.0, 0.0, 0.0),
                                      child: Text(
                                        'Dirección',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.w600),
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: _dark,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 6.0, 0.0, 0.0),
                                      child: Text(
                                        _address,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],

                                // ── Description ──────────────────────────
                                if (_description.isNotEmpty &&
                                    _description != 'null') ...[
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 16.0, 0.0, 0.0),
                                      child: Text(
                                        'Descripción sobre la propiedad',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.w600),
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: _dark,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 6.0, 0.0, 0.0),
                                      child: Text(
                                        _description,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],

                                // ── Map ──────────────────────────────────
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 0.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 250.0,
                                    child: custom_widgets.InteractiveMap(
                                      width: double.infinity,
                                      height: 250.0,
                                      accessToken:
                                          FFAppConstants.MapboxAccessToken,
                                      startLat: _lat ?? 0.0,
                                      startLng: _lng ?? 0.0,
                                    ),
                                  ),
                                ),

                                if (!widget.isReadOnly) ...[
                                  // ── Hint text ────────────────────────────
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 16.0, 0.0, 0.0),
                                    child: Text(
                                      'Ya llegué al punto, enviar mi ubicación.',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.publicSans(),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                  ),

                                  // ── Bottom buttons ───────────────────────
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 0.0, 0.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: (_onMyWayLoading ||
                                                        _onMyWaySent)
                                                    ? null
                                                    : _onMyWay,
                                                text: _onMyWaySent
                                                    ? '¡En camino!'
                                                    : 'Enviar mi ubicación y notificar',
                                                showLoadingIndicator:
                                                    _onMyWayLoading,
                                                options: FFButtonOptions(
                                                  height: 44.0,
                                                  color: _onMyWaySent
                                                      ? const Color(0xFF007376)
                                                      : Colors.transparent,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .override(
                                                            font: GoogleFonts
                                                                .publicSans(),
                                                            color: _onMyWaySent
                                                                ? Colors.white
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                          ),
                                                  elevation: 0.0,
                                                  borderSide: BorderSide(
                                                    color: _onMyWaySent
                                                        ? const Color(
                                                            0xFF007376)
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: _isChecklistEnabled
                                                    ? () => context.pushNamed(
                                                        OPERATIVELISTINGChecklistWidget
                                                            .routeName)
                                                    : null,
                                                text: 'Checklist',
                                                options: FFButtonOptions(
                                                  height: 44.0,
                                                  color: _isChecklistEnabled
                                                      ? _primary
                                                      : const Color(0xFFB0BEC5),
                                                  disabledColor:
                                                      const Color(0xFFB0BEC5),
                                                  disabledTextColor:
                                                      Colors.white,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .override(
                                                            font: GoogleFonts
                                                                .publicSans(),
                                                            color: Colors.white,
                                                          ),
                                                  elevation: 0.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!_isChecklistEnabled && !_loading)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              _checklistHint,
                                              textAlign: TextAlign.center,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .publicSans(),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                      ),
                                            ),
                                          ),
                                        // "Notificar que llegué" — visible solo cuando el checklist está habilitado
                                        if (_isChecklistEnabled) ...[
                                          const SizedBox(height: 10),
                                          FFButtonWidget(
                                            onPressed: (_arrivedLoading ||
                                                    _arrivedSent)
                                                ? null
                                                : _arrived,
                                            text: _arrivedSent
                                                ? '¡Llegada notificada!'
                                                : 'Notificar que llegué',
                                            showLoadingIndicator:
                                                _arrivedLoading,
                                            options: FFButtonOptions(
                                              width: double.infinity,
                                              height: 44.0,
                                              color: _arrivedSent
                                                  ? const Color(0xFF007376)
                                                  : Colors.transparent,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .publicSans(),
                                                        color: _arrivedSent
                                                            ? Colors.white
                                                            : _primary,
                                                      ),
                                              elevation: 0.0,
                                              borderSide: BorderSide(
                                                color: _arrivedSent
                                                    ? const Color(0xFF007376)
                                                    : _primary,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
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
                      model: _model.oPERATIVELISTINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const OPERATIVELISTINGNavbarWidget(),
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

  Widget _avatarPlaceholder() => Container(
        color: const Color(0xFFEFEFEF),
        child: const Icon(Icons.person, color: Colors.grey, size: 36),
      );
}
