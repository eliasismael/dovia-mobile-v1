import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/repositories/payments_repository.dart';

import 'd_h_c_l_i_e_n_t_ubicacion_model.dart';
export 'd_h_c_l_i_e_n_t_ubicacion_model.dart';

/// Página donde se selecciona en el mapa la ubicacion de la propiedad a
/// cubrir
///
/// Es el paso de **Coverage Check**: la zona elegida se valida contra las zonas
/// operables de DOVIA (`GET /dovia-home/workable-zones`) antes de registrar la
/// dirección. Si la zona no está cubierta se deriva a
/// [DHCLIENTFueraDeAlcanceWidget] y no se crea la dirección.
class DHCLIENTUbicacionWidget extends StatefulWidget {
  const DHCLIENTUbicacionWidget({super.key});

  static String routeName = 'DH_CLIENT_Ubicacion';
  static String routePath = '/dHCLIENTUbicacion';

  static String? pendingNextRoute;

  @override
  State<DHCLIENTUbicacionWidget> createState() =>
      _DHCLIENTUbicacionWidgetState();
}

class _DHCLIENTUbicacionWidgetState extends State<DHCLIENTUbicacionWidget> {
  late DHCLIENTUbicacionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isGeocoding = false;
  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];

  /// Zonas con cobertura operativa de DOVIA. Son el criterio del Coverage
  /// Check. Si el endpoint falla, el desplegable se alimenta de
  /// [_fallbackZones] para que el cliente pueda ir completando el formulario,
  /// pero la validación **no** se da por buena: [_verifyCoverageAndSave]
  /// reintenta el endpoint y sin zonas autorizadas no deja registrar.
  List<String> _workableZones = [];
  bool _zonesLoaded = false;

  /// Si [_workableZones] viene del backend. Sólo entonces el Coverage Check del
  /// front es una verificación real.
  bool get _zonesAreAuthoritative => _workableZones.isNotEmpty;

  /// Direcciones de servicio ya registradas ("Ubicaciones anteriores").
  List<Map<String, dynamic>> _previousAddresses = [];

  /// Registro de la dirección en curso (bloquea el botón [Aceptar]).
  bool _isSaving = false;

  static const List<String> _fallbackZones = [
    'Zona 1',
    'Zona 2',
    'Zona 3',
    'Zona 4',
    'Zona 5',
    'Zona 6',
    'Zona 7',
    'Zona 8',
    'Zona 9',
    'Zona 10',
    'Zona 11',
    'Zona 12',
    'Zona 13',
    'Zona 14',
    'Zona 15',
    'Zona 16',
    'Zona 17',
    'Zona 18',
    'Zona 19',
    'Zona 21',
    'Zona 24',
    'Zona 25',
  ];

  String? _str(dynamic value) =>
      (value is String && value.trim().isNotEmpty) ? value.trim() : null;

  /// Zonas ofrecidas en el desplegable: las del backend si llegaron, si no el
  /// listado de respaldo.
  List<String> get _zoneOptions =>
      _workableZones.isNotEmpty ? _workableZones : _fallbackZones;

  /// Zonas operables tal como las devuelve el endpoint, que puede mandar
  /// strings o objetos `{ name/zone/label/code }`.
  List<String> _zonesFrom(dynamic jsonBody) {
    final raw = DOVIAAPIDoviaHomeContextGroup.listWorkableZonesCall
            .zonesList(jsonBody) ??
        [];
    final zones = <String>[];
    for (final zone in raw) {
      final name = zone is Map
          ? (_str(zone['name']) ??
              _str(zone['zone']) ??
              _str(zone['label']) ??
              _str(zone['code']))
          : _str(zone);
      if (name != null && !zones.contains(name)) {
        zones.add(name);
      }
    }
    return zones;
  }

  /// Reintenta traer las zonas operables. Se usa antes de validar cuando la
  /// carga inicial falló: sin zonas del backend no hay Coverage Check posible.
  Future<bool> _refreshWorkableZones() async {
    final response = await DOVIAAPIDoviaHomeContextGroup.listWorkableZonesCall
        .call(authToken: currentAuthenticationToken ?? '');
    if (!mounted) return false;

    final zones = response.succeeded ? _zonesFrom(response.jsonBody) : <String>[];
    if (zones.isNotEmpty) {
      safeSetState(() => _workableZones = zones);
    }
    return zones.isNotEmpty;
  }

  /// Carga zonas operables y direcciones previas del cliente en paralelo.
  Future<void> _loadCoverageData() async {
    final token = currentAuthenticationToken ?? '';
    final results = await Future.wait([
      DOVIAAPIDoviaHomeContextGroup.listWorkableZonesCall.call(authToken: token),
      DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall
          .call(authToken: token),
    ]);
    if (!mounted) return;

    final zonesRes = results[0];
    final addressesRes = results[1];

    final zones = zonesRes.succeeded ? _zonesFrom(zonesRes.jsonBody) : <String>[];

    final addresses = <Map<String, dynamic>>[];
    if (addressesRes.succeeded) {
      final raw = DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall
              .addressesList(addressesRes.jsonBody) ??
          [];
      for (final address in raw.whereType<Map>()) {
        addresses.add(Map<String, dynamic>.from(address));
      }
    }

    safeSetState(() {
      _workableZones = zones;
      _zonesLoaded = true;
      _previousAddresses = addresses;
    });
  }

  /// Etiqueta visible de una dirección previa en el desplegable.
  String _addressLabel(Map<String, dynamic> address) {
    final name = _str(address['name']) ??
        _str(address['label']) ??
        _str(address['nickname']) ??
        _str(address['alias']);
    final street = _str(address['address']) ?? _str(address['fullAddress']);
    if (name != null && street != null) return '$name · $street';
    return name ?? street ?? 'Ubicación registrada';
  }

  String? _addressId(Map<String, dynamic> address) =>
      _str(address['id']) ?? _str(address['addressId']);

  /// Direcciones previas que tienen id (las únicas seleccionables).
  List<Map<String, dynamic>> get _selectablePreviousAddresses =>
      _previousAddresses.where((a) => _addressId(a) != null).toList();

  /// El cliente eligió una ubicación ya registrada: no hace falta Coverage Check
  /// porque su cobertura se validó al darla de alta. Se devuelve directamente al
  /// flujo que pidió la ubicación.
  void _onPreviousAddressSelected(String? addressId) {
    safeSetState(() => _model.previousAddressValue = addressId);
    if (addressId == null) return;

    final match = _selectablePreviousAddresses
        .where((a) => _addressId(a) == addressId)
        .toList();
    if (match.isEmpty) return;

    _returnWithAddress(addressId, _addressLabel(match.first));
  }

  /// ¿La zona elegida está dentro del área de servicio de DOVIA? Se compara
  /// siempre contra las zonas del backend; llamar a este método sin ellas no
  /// tiene sentido, por eso [_verifyCoverageAndSave] las asegura antes.
  bool _isZoneCovered(String zone) => _workableZones
      .any((z) => z.toLowerCase().trim() == zone.toLowerCase().trim());

  /// Coverage Check + alta de la dirección. Sólo cuando la zona está cubierta y
  /// el backend acepta la dirección se continúa al flujo pendiente.
  Future<void> _verifyCoverageAndSave() async {
    final zone = _model.dropDownValue;
    final street = (_model.textController1?.text ?? '').trim();
    final altura = (_model.alturaController?.text ?? '').trim();
    final lat = _model.selectedLat;
    final lng = _model.selectedLng;
    if (zone == null || street.isEmpty || lat == null || lng == null) return;

    safeSetState(() => _isSaving = true);
    try {
      // Sin las zonas del backend no se puede afirmar que haya cobertura: se
      // reintenta y, si sigue sin haberlas, no se registra la dirección en vez
      // de dejarla pasar a ciegas.
      if (!_zonesAreAuthoritative && !await _refreshWorkableZones()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No pudimos verificar la cobertura ahora mismo. Revisa tu conexión e intenta de nuevo.'),
          ),
        );
        return;
      }
      if (!mounted) return;

      // Regla de cobertura: fuera del área de servicio no se permite la
      // solicitud.
      if (!_isZoneCovered(zone)) {
        context.pushNamed(DHCLIENTFueraDeAlcanceWidget.routeName);
        return;
      }

      final fullAddress =
          altura.isNotEmpty ? '$street $altura, $zone' : '$street, $zone';
      final instructions = (_model.textController2?.text ?? '').trim();

      final response =
          await DOVIAAPIDoviaHomeContextGroup.createServiceAddressCall.call(
        address: fullAddress,
        latitude: lat,
        longitude: lng,
        zone: zone,
        accessInstructions: instructions.isEmpty ? null : instructions,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        // El backend rechaza las direcciones fuera de cobertura: se deriva a la
        // pantalla de fuera de alcance en ese caso y se avisa en el resto.
        if (response.statusCode == 422 || response.statusCode == 409) {
          context.pushNamed(DHCLIENTFueraDeAlcanceWidget.routeName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('No se pudo registrar la ubicación. Intenta de nuevo.'),
            ),
          );
        }
        return;
      }

      final addressId = DOVIAAPIDoviaHomeContextGroup.createServiceAddressCall
          .id(response.jsonBody);
      _returnWithAddress(addressId, fullAddress);
    } finally {
      if (mounted) {
        safeSetState(() => _isSaving = false);
      }
    }
  }

  /// Publica la dirección verificada para el flujo que pidió la ubicación y
  /// continúa la navegación pendiente.
  void _returnWithAddress(String? addressId, String label) {
    final nextRoute = DHCLIENTUbicacionWidget.pendingNextRoute;
    DHCLIENTUbicacionWidget.pendingNextRoute = null;

    if (nextRoute == DHCLIENTCotizacionWidget.routeName) {
      DHCLIENTCotizacionWidget.verifiedAddressId = addressId;
      DHCLIENTCotizacionWidget.verifiedAddressLabel = label;
      // Vuelve al formulario de cotización que quedó en la pila con la
      // ubicación ya validada.
      context.safePop();
      return;
    }

    if (nextRoute == DHCLIENTAgendaWidget.routeName) {
      DHCLIENTAgendaWidget.verifiedAddressId = addressId;
      DHCLIENTAgendaWidget.verifiedAddressLabel = label;
      // Vuelve a la Agenda, que quedó en la pila esperando el lugar del
      // servicio para poder crear la solicitud.
      context.safePop();
      return;
    }

    if (nextRoute != null) {
      context.pushNamed(nextRoute);
    } else {
      context.pushNamed(DHCLIENTHomepageWidget.routeName);
    }
  }

  /// Builds the search query combining street, street number and zone.
  /// Street + number go in a single token ("6a Avenida 1234") so Mapbox
  /// resolves the exact house instead of just the street center.
  String _buildQuery(String street) {
    final altura = (_model.alturaController?.text ?? '').trim();
    final zone = _model.dropDownValue;
    final streetLine = altura.isNotEmpty ? '$street $altura' : street;
    return [
      streetLine,
      if (zone != null && zone.isNotEmpty) zone,
      'Guatemala',
    ].join(', ');
  }

  /// Debounced autocomplete lookup while the user types the street.
  void _onStreetChanged(String value) {
    safeSetState(() {});
    _debounce?.cancel();
    if (value.trim().length < 3) {
      safeSetState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchSuggestions(value.trim());
    });
  }

  /// Queries Mapbox Geocoding with autocomplete for street suggestions.
  Future<void> _fetchSuggestions(String street) async {
    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${Uri.encodeComponent(_buildQuery(street))}.json'
        '?access_token=${FFAppConstants.MapboxAccessToken}'
        '&country=gt&autocomplete=true&limit=5&language=es'
        '&types=address,street,poi',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = (data['features'] as List<dynamic>? ?? []);
      if (!mounted) return;
      safeSetState(() {
        _suggestions = features.map((f) {
          final center = f['center'] as List<dynamic>;
          return {
            'name': (f['place_name'] ?? f['text'] ?? '').toString(),
            'lng': (center[0] as num).toDouble(),
            'lat': (center[1] as num).toDouble(),
          };
        }).toList();
      });
    } catch (_) {
      // Ignore autocomplete errors silently; manual search still works.
    }
  }

  /// Applies a chosen suggestion: fills the field and moves the map.
  void _selectSuggestion(Map<String, dynamic> suggestion) {
    FocusScope.of(context).unfocus();
    _debounce?.cancel();
    _model.textController1?.text = (suggestion['name'] as String);
    safeSetState(() {
      _suggestions = [];
      _model.selectedLat = suggestion['lat'] as double;
      _model.selectedLng = suggestion['lng'] as double;
    });
  }

  /// Looks up the typed address with Mapbox Geocoding and moves the map
  /// marker to the matching coordinates (manual search / enter).
  Future<void> _geocodeAddress() async {
    final street = (_model.textController1?.text ?? '').trim();
    if (street.isEmpty || _isGeocoding) {
      return;
    }

    FocusScope.of(context).unfocus();
    _debounce?.cancel();
    safeSetState(() {
      _isGeocoding = true;
      _suggestions = [];
    });

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${Uri.encodeComponent(_buildQuery(street))}.json'
        '?access_token=${FFAppConstants.MapboxAccessToken}'
        '&country=gt&limit=1&language=es',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final center = features.first['center'] as List<dynamic>;
          // Mapbox returns [longitude, latitude].
          final lng = (center[0] as num).toDouble();
          final lat = (center[1] as num).toDouble();
          safeSetState(() {
            _model.selectedLat = lat;
            _model.selectedLng = lng;
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontró esa dirección en el mapa.'),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo buscar la dirección. Intenta de nuevo.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al buscar la dirección.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isGeocoding = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTUbicacionModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.alturaController ??= TextEditingController();
    _model.alturaFocusNode ??= FocusNode();

    _loadCoverageData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Asegura el estado de suscripción (cacheado en el repo) para decidir si
      // corresponde el upsell de Premium.
      context.read<PaymentsRepository>().loadCurrentSubscription();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _model.dispose();

    super.dispose();
  }

  InputDecoration _addressFieldDecoration(String hintText) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.inter(),
            letterSpacing: 0.0,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      filled: true,
      fillColor: FlutterFlowTheme.of(context).alternate,
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 21.0, 16.0, 21.0),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(),
            letterSpacing: 0.0,
          ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: 52.0,
      height: 52.0,
      decoration: BoxDecoration(
        color: const Color(0xFF007376),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: _isGeocoding
          ? const Padding(
              padding: EdgeInsets.all(15.0),
              child: SizedBox(
                width: 22.0,
                height: 22.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: 'Ubicar en el mapa',
              onPressed: _geocodeAddress,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El upsell de Premium sólo aplica a clientes sin suscripción activa; el
    // Cliente Premium ve la pantalla limpia, como el diseño. Mientras el estado
    // no esté resuelto no se muestra, para no ofrecerle Premium a quien ya paga.
    final payments = context.watch<PaymentsRepository>();
    final showPremiumUpsell =
        payments.subscriptionLoaded && !payments.hasActiveSubscription;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
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
                      title: 'Dovia Home',
                      showMap: false,
                      showCurrency: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 23.0, 20.0, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Upsell sólo para clientes sin suscripción.
                          if (showPremiumUpsell)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF007376),
                                borderRadius: BorderRadius.circular(24.0),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 12.0,
                                    color: Color(0x33007376),
                                    offset: Offset(0.0, 8.0),
                                  )
                                ],
                              ),
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20.0, 15.0, 20.0, 15.0),
                              child: Text(
                                '¡Al contratar Premium en DOVIA Home podrás tener beneficios únicos!',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: Colors.white,
                                      fontSize: 17.0,
                                    ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, showPremiumUpsell ? 25.0 : 0.0, 0.0, 0.0),
                            child: Text(
                              'Selecciona la ubicación de tu propiedad con cobertura',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(
                                      color: const Color(0xFF00444B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    fontSize: 24.0,
                                    lineHeight: 1.36,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 14.0, 0.0, 0.0),
                            child: Text(
                              'Podrás cambiar la ubicación de tu propiedad antes de la renovación de plan mensual',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(
                                      color: const Color(0xFF00444B),
                                      fontWeight: FontWeight.normal,
                                    ),
                                    fontSize: 16.0,
                                  ),
                            ),
                          ),
                          // Ubicaciones ya registradas: atajo que evita repetir
                          // el Coverage Check de una dirección ya validada.
                          if (_selectablePreviousAddresses.isNotEmpty) ...[
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Text(
                                  'Ubicaciones anteriores:',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(),
                                        color: const Color(0xFF00444B),
                                        fontSize: 16.0,
                                        letterSpacing: 0.32,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: FlutterFlowDropDown<String>(
                                controller:
                                    _model.previousAddressValueController ??=
                                        FormFieldController<String>(null),
                                options: _selectablePreviousAddresses
                                    .map((a) => _addressId(a)!)
                                    .toList(),
                                optionLabels: _selectablePreviousAddresses
                                    .map(_addressLabel)
                                    .toList(),
                                onChanged: _onPreviousAddressSelected,
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 50.0,
                                textStyle:
                                    FlutterFlowTheme.of(context).bodyMedium,
                                hintText:
                                    'Selecciona ubicación agregada anteriormente',
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF191919),
                                  size: 24.0,
                                ),
                                fillColor: Colors.white,
                                elevation: 2.0,
                                borderColor: const Color(0xFFDFDFDF),
                                borderWidth: 0.0,
                                borderRadius: 10.0,
                                margin: const EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 12.0, 0.0),
                                hidesUnderline: true,
                                isSearchable: false,
                                isMultiSelect: false,
                                maxHeight: 300.0,
                              ),
                            ),
                          ],
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 25.0, 0.0, 0.0),
                              child: Text(
                                'Agregue una nueva ubicación y verifique su cobertura',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: const Color(0xFF00444B),
                                      fontSize: 17.0,
                                      letterSpacing: 0.34,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                'Zona donde se encuentre el inmueble',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        color: const Color(0xFF00444B),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      fontSize: 16.0,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: FlutterFlowDropDown<String>(
                              controller: _model.dropDownValueController ??=
                                  FormFieldController<String>(null),
                              // Sólo zonas con cobertura operativa de DOVIA.
                              options: _zoneOptions,
                              onChanged: (val) => safeSetState(
                                  () => _model.dropDownValue = val),
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 50.0,
                              textStyle:
                                  FlutterFlowTheme.of(context).bodyMedium,
                              hintText:
                                  'Selecciona zona donde se encuentra el inmueble',
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF191919),
                                size: 24.0,
                              ),
                              fillColor: Colors.white,
                              elevation: 2.0,
                              borderColor: const Color(0xFFDFDFDF),
                              borderWidth: 0.0,
                              borderRadius: 10.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              hidesUnderline: true,
                              isSearchable: false,
                              isMultiSelect: false,
                              maxHeight: 300.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _fieldLabel('Calle'),
                                ),
                                const SizedBox(width: 8.0),
                                SizedBox(
                                  width: 90.0,
                                  child: _fieldLabel('Altura'),
                                ),
                                const SizedBox(width: 8.0),
                                const SizedBox(width: 52.0),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _model.textController1,
                                    focusNode: _model.textFieldFocusNode1,
                                    autofocus: false,
                                    enabled: true,
                                    obscureText: false,
                                    decoration: _addressFieldDecoration(
                                        'Ej: 6a Avenida'),
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    enableInteractiveSelection: true,
                                    textInputAction: TextInputAction.search,
                                    onChanged: _onStreetChanged,
                                    onFieldSubmitted: (_) => _geocodeAddress(),
                                    validator: _model.textController1Validator
                                        .asValidator(context),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                SizedBox(
                                  width: 90.0,
                                  child: TextFormField(
                                    controller: _model.alturaController,
                                    focusNode: _model.alturaFocusNode,
                                    autofocus: false,
                                    enabled: true,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.search,
                                    decoration: _addressFieldDecoration('1234'),
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    onChanged: (_) => safeSetState(() {}),
                                    onFieldSubmitted: (_) => _geocodeAddress(),
                                    validator: _model.alturaControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                _buildSearchButton(),
                              ],
                            ),
                          ),
                          if (_suggestions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 6.0, 0.0, 0.0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: const Color(0xFFDFDFDF),
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _suggestions.map((suggestion) {
                                    return InkWell(
                                      onTap: () => _selectSuggestion(suggestion),
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                12.0, 12.0, 12.0, 12.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              color: Color(0xFF007376),
                                              size: 18.0,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        8.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  suggestion['name'] as String,
                                                  style:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .publicSans(),
                                                            color: const Color(
                                                                0xFF00444B),
                                                            fontSize: 14.0,
                                                          ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 14.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 300.0,
                              child: custom_widgets.InteractiveMap(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 300.0,
                                accessToken: FFAppConstants.MapboxAccessToken,
                                startLat: _model.selectedLat ?? 14.634915,
                                startLng: _model.selectedLng ?? -90.506882,
                                onLocationSelected: (lat, lng) async {
                                  safeSetState(() {
                                    _model.selectedLat = lat;
                                    _model.selectedLng = lng;
                                  });
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF007376),
                                  size: 16.0,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            6.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      'Puedes ajustar el punto tocando la ubicación exacta en el mapa.',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.publicSans(),
                                            color: const Color(0xFF6A6A6A),
                                            fontSize: 12.0,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: Text(
                                'Ingresa las instrucciones, para cuando llegue un asociado',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.28,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              child: TextFormField(
                                controller: _model.textController2,
                                focusNode: _model.textFieldFocusNode2,
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
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Ingresa las instrucciones',
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
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  filled: true,
                                  fillColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          16.0, 50.0, 0.0, 50.0),
                                ),
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
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model.textController2Validator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 90.0),
                            child: FFButtonWidget(
                              // Valida cobertura y registra la dirección antes
                              // de continuar el flujo que pidió la ubicación.
                              // La altura no se exige: hay direcciones sin
                              // número, y el punto exacto ya sale del mapa.
                              onPressed: (!_zonesLoaded ||
                                      _isSaving ||
                                      _model.dropDownValue == null ||
                                      (_model.textController1?.text ?? '')
                                          .trim()
                                          .isEmpty ||
                                      _model.selectedLat == null ||
                                      _model.selectedLng == null)
                                  ? null
                                  : () async => _verifyCoverageAndSave(),
                              text: _isSaving
                                  ? 'Verificando cobertura…'
                                  : 'Aceptar',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 42.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                disabledColor: const Color(0xFFDFDFDF),
                                disabledTextColor: const Color(0xFF6A6A6A),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(25.0),
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
                          0.0, 0.0, 15.0, 100.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.dHCLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHCLIENTNavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
