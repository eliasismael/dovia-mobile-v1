import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_c_l_i_e_n_t_agenda_model.dart';
export 'd_h_c_l_i_e_n_t_agenda_model.dart';

class DHCLIENTAgendaWidget extends StatefulWidget {
  const DHCLIENTAgendaWidget({super.key});

  static String routeName = 'DH_CLIENT_Agenda';
  static String routePath = '/dHCLIENTAgenda';

  /// Anticipación mínima (en horas) para agendar una visita: 36h para pago por
  /// uso sin plan, 24h para clientes con suscripción. Lo fija el paso previo
  /// (valor de la visita) según cómo se pagó el servicio.
  static int minAdvanceHours = 36;

  /// Dirección devuelta por el flujo de "Otra ubicación"
  /// ([DHCLIENTUbicacionWidget]) una vez que pasó el Coverage Check. Mismo
  /// patrón que [DHCLIENTCotizacionWidget.verifiedAddressId].
  static String? verifiedAddressId;
  static String? verifiedAddressLabel;

  @override
  State<DHCLIENTAgendaWidget> createState() => _DHCLIENTAgendaWidgetState();
}

class _DHCLIENTAgendaWidgetState extends State<DHCLIENTAgendaWidget> {
  late DHCLIENTAgendaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _timeSlots = [
    '6:00 - 7:00',
    '7:00 - 8:00',
    '8:00 - 9:00',
    '9:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
  ];
  static const List<String> _periods = ['AM', 'PM'];

  static const List<String> _monthsEs = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  /// Direcciones de servicio registradas del cliente. El POST de la solicitud
  /// exige un `addressId`, así que el lugar del servicio se elige aquí.
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoadingAddresses = true;
  String? _selectedAddressId;

  /// Dirección recién dada de alta en esta sesión, por si el listado del backend
  /// todavía no la refleja (mismo resguardo que en la pantalla de cotización).
  Map<String, dynamic>? _justAddedAddress;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTAgendaModel());

    _loadAddresses();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Enviar exige fecha, hora y lugar del servicio (los tres van en el POST).
  bool get _canContinue =>
      _model.selectedDate != null &&
      _model.timeChosen &&
      _selectedAddressId != null &&
      !_model.isSubmitting;

  String get _selectedTimeLabel =>
      '${_timeSlots[_model.selectedSlotIndex]} ${_periods[_model.selectedPeriodIndex]}';

  String _formatDate(DateTime d) =>
      '${d.day} ${_monthsEs[d.month - 1]} ${d.year}';

  /// Fecha y hora reales de la visita: la franja elegida ("7:00 - 8:00 AM") se
  /// convierte a la hora de inicio en formato 24h para armar el `scheduledAt`.
  DateTime _scheduledDateTime(DateTime date) {
    final start = _timeSlots[_model.selectedSlotIndex].split('-').first.trim();
    final parts = start.split(':');
    var hour = int.tryParse(parts.first) ?? 8;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final isPm = _periods[_model.selectedPeriodIndex] == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // ---------------------------------------------------------------------------
  // Lugar del servicio.
  // ---------------------------------------------------------------------------

  String? _str(dynamic value) =>
      (value is String && value.trim().isNotEmpty) ? value.trim() : null;

  String? _addressId(Map<String, dynamic> address) =>
      _str(address['id']) ?? _str(address['addressId']);

  String _addressLabel(Map<String, dynamic> address) =>
      _str(address['name']) ??
      _str(address['label']) ??
      _str(address['nickname']) ??
      _str(address['alias']) ??
      _str(address['address']) ??
      _str(address['fullAddress']) ??
      'Ubicación registrada';

  String? get _selectedAddressLabel {
    final id = _selectedAddressId;
    if (id == null) return null;
    for (final address in _addresses) {
      if (_addressId(address) == id) return _addressLabel(address);
    }
    return null;
  }

  Future<void> _loadAddresses() async {
    final response =
        await DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall.call(
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    final addresses = <Map<String, dynamic>>[];
    if (response.succeeded) {
      final raw = DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall
              .addressesList(response.jsonBody) ??
          [];
      for (final address in raw.whereType<Map>()) {
        final typed = Map<String, dynamic>.from(address);
        if (_addressId(typed) != null) addresses.add(typed);
      }
    }

    final justAdded = _justAddedAddress;
    if (justAdded != null &&
        !addresses.any((a) => _addressId(a) == _addressId(justAdded))) {
      addresses.add(justAdded);
    }

    safeSetState(() {
      _addresses = addresses;
      _isLoadingAddresses = false;
      // Con una sola dirección registrada no tiene sentido preguntar.
      if (_selectedAddressId == null && addresses.length == 1) {
        _selectedAddressId = _addressId(addresses.first);
      }
      if (_selectedAddressId != null &&
          !addresses.any((a) => _addressId(a) == _selectedAddressId)) {
        _selectedAddressId = null;
      }
    });
  }

  /// Alta de una dirección nueva: pasa por el Coverage Check de
  /// [DHCLIENTUbicacionWidget] y al volver queda seleccionada.
  Future<void> _addOtherLocation() async {
    DHCLIENTUbicacionWidget.pendingNextRoute = DHCLIENTAgendaWidget.routeName;
    await context.pushNamed(DHCLIENTUbicacionWidget.routeName);
    if (!mounted) return;

    final verifiedId = DHCLIENTAgendaWidget.verifiedAddressId;
    final verifiedLabel = DHCLIENTAgendaWidget.verifiedAddressLabel;
    DHCLIENTAgendaWidget.verifiedAddressId = null;
    DHCLIENTAgendaWidget.verifiedAddressLabel = null;

    // Si el cliente canceló, la selección previa queda intacta.
    if (verifiedId == null) return;

    safeSetState(() {
      _justAddedAddress = {
        'id': verifiedId,
        'address': verifiedLabel ?? 'Ubicación agregada',
      };
      _selectedAddressId = verifiedId;
    });
    await _loadAddresses();
  }

  Future<void> _pickAddress() async {
    if (_isLoadingAddresses) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _AddressPickerSheet(
        addresses: _addresses,
        selectedId: _selectedAddressId,
        labelOf: _addressLabel,
        idOf: _addressId,
        onSelect: (id) {
          Navigator.of(sheetContext).pop();
          safeSetState(() => _selectedAddressId = id);
        },
        onAddOther: () {
          Navigator.of(sheetContext).pop();
          _addOtherLocation();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Envío de la solicitud.
  // ---------------------------------------------------------------------------

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Motivo del rechazo que devolvió el backend (Ej: "serviceId invalido"). Sin
  /// esto un 400 se ve igual que un problema de red y no hay forma de saber qué
  /// campo falló.
  String? _apiErrorMessage(dynamic body) {
    if (body is Map) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
      if (message is List && message.isNotEmpty) return message.join(', ');
    }
    return null;
  }

  /// Normaliza para comparar nombres de servicio sin depender de mayúsculas ni
  /// acentos ("Albañilería" vs "albanileria").
  String _normalize(String value) {
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    var result = value.toLowerCase().trim();
    accents.forEach((from, to) => result = result.replaceAll(from, to));
    return result.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Resuelve el `serviceId` del catálogo a partir de la categoría elegida en el
  /// Dashboard (que hoy es solo un título). Se compara por nombre normalizado y,
  /// si no hay coincidencia exacta, por contención en cualquier sentido.
  Future<String?> _resolveServiceId(String token) async {
    final response =
        await DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall.call(
      authToken: token,
    );
    if (!response.succeeded) return null;

    final services = DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall
            .servicesList(response.jsonBody) ??
        [];
    final target = _normalize(DHCLIENTInstalacionWidget.serviceTitle);

    String? partialMatch;
    for (final service in services.whereType<Map>()) {
      // Un servicio dado de baja no se puede solicitar: el POST lo rechazaría.
      if (service['active'] == false) continue;

      final id = _str(service['id']) ?? _str(service['serviceId']);
      // El catálogo etiqueta los servicios con `label` (Ej: "Plomería") y los
      // identifica con `code` (Ej: "PLOMERIA"); `name`/`title` no existen en la
      // respuesta y leer sólo esos dejaba el id sin resolver, así que la
      // solicitud moría antes del POST con "No se pudo identificar el servicio".
      final name = _str(service['label']) ??
          _str(service['name']) ??
          _str(service['title']) ??
          _str(service['code']);
      if (id == null || name == null) continue;

      final normalized = _normalize(name);
      if (normalized == target) return id;
      if (partialMatch == null &&
          (normalized.contains(target) || target.contains(normalized))) {
        partialMatch = id;
      }
    }
    return partialMatch;
  }

  /// Sube las fotos del levantamiento con el flujo presign → PUT → confirm. Es
  /// best-effort: la solicitud ya existe, así que un fallo de fotos no la anula.
  Future<void> _uploadPhotos(String serviceRequestId, String token) async {
    final photos = DHCLIENTInstalacionWidget.photos;
    if (photos.isEmpty) return;

    final uploads = <Map<String, dynamic>>[
      for (var i = 0; i < photos.length; i++)
        {
          'clientUploadId': 'upload_$i',
          'contentType': 'image/jpeg',
          'fileName': photos[i].name ?? 'foto_$i.jpg',
        },
    ];

    final presignRes =
        await DOVIAAPIDoviaHomeContextGroup.presignServiceRequestImagesCall.call(
      serviceRequestId: serviceRequestId,
      uploads: uploads,
      authToken: token,
    );
    if (!presignRes.succeeded) return;

    final items = DOVIAAPIDoviaHomeContextGroup.presignServiceRequestImagesCall
        .items(presignRes.jsonBody);
    if (items == null || items.isEmpty) return;

    final storageKeys = <String>[];
    for (final item in items) {
      if (item is! Map) continue;
      final clientUploadId = item['clientUploadId']?.toString() ?? '';
      final uploadUrl = item['uploadUrl']?.toString();
      final storageKey = item['storageKey']?.toString();
      final index =
          int.tryParse(clientUploadId.replaceAll('upload_', '')) ?? -1;
      if (uploadUrl == null || index < 0 || index >= photos.length) continue;

      final bytes = photos[index].bytes;
      if (bytes == null) continue;

      final putRes = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: bytes,
      );
      if (putRes.statusCode >= 200 &&
          putRes.statusCode < 300 &&
          storageKey != null) {
        storageKeys.add(storageKey);
      }
    }

    if (storageKeys.isEmpty) return;
    await DOVIAAPIDoviaHomeContextGroup.confirmServiceRequestImagesCall.call(
      serviceRequestId: serviceRequestId,
      storageKeys: storageKeys,
      authToken: token,
    );
  }

  /// Crea la solicitud en el backend (`POST /dovia-home/service-requests`) para
  /// que la red de Home Associates pueda tomarla, sube las fotos y recién ahí
  /// muestra el modal de éxito y vuelve al Dashboard.
  Future<void> _submit() async {
    final addressId = _selectedAddressId;
    final date = _model.selectedDate;
    if (addressId == null || date == null) return;

    final scheduledAt = _scheduledDateTime(date);
    // El selector de fecha respeta la anticipación mínima, pero la franja
    // horaria puede quedar por debajo (Ej: el primer día hábil a las 6:00 AM).
    final earliest =
        DateTime.now().add(Duration(hours: DHCLIENTAgendaWidget.minAdvanceHours));
    if (scheduledAt.isBefore(earliest)) {
      _showSnack(
          'La visita debe agendarse con al menos ${DHCLIENTAgendaWidget.minAdvanceHours} hs de anticipación.');
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final token = currentAuthenticationToken ?? '';

      final serviceId = await _resolveServiceId(token);
      if (serviceId == null) {
        _showSnack(
            'No se pudo identificar el servicio en el catálogo. Intenta de nuevo.');
        return;
      }

      // El endpoint rechaza strings vacíos: si se llegó hasta aquí sin
      // levantamiento (Ej: entrando directo a la ruta) se manda el servicio.
      final description = DHCLIENTInstalacionWidget.description.trim().isNotEmpty
          ? DHCLIENTInstalacionWidget.description.trim()
          : 'Solicitud de ${DHCLIENTInstalacionWidget.serviceTitle}';

      final response =
          await DOVIAAPIDoviaHomeContextGroup.createServiceRequestCall.call(
        serviceId: serviceId,
        description: description,
        scheduledAt: scheduledAt.toUtc().toIso8601String(),
        addressId: addressId,
        authToken: token,
      );
      if (!response.succeeded) {
        _showSnack(_apiErrorMessage(response.jsonBody) ??
            'No se pudo enviar la solicitud. Intenta de nuevo.');
        return;
      }

      final serviceRequestId = DOVIAAPIDoviaHomeContextGroup
          .createServiceRequestCall
          .id(response.jsonBody);
      if (serviceRequestId != null && serviceRequestId.isNotEmpty) {
        await _uploadPhotos(serviceRequestId, token);
      }

      // La solicitud ya existe en el backend: se pinta de inmediato en el
      // Dashboard con su id para que el listado no la duplique cuando el GET
      // la devuelva.
      DHCLIENTHomepageWidget.upcomingVisits.insert(
        0,
        ScheduledVisit(
          id: serviceRequestId,
          service: DHCLIENTInstalacionWidget.serviceTitle,
          date: _formatDate(date),
          time: _selectedTimeLabel,
          scheduledAt: scheduledAt,
        ),
      );
      DHCLIENTInstalacionWidget.resetDraft();

      if (!mounted) return;
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
            child: DHCLIENTExitoProgramarAgendaWidget(),
          );
        },
      );

      // Al cerrarse el modal (auto o al tapear fuera) redirige al Dashboard.
      if (mounted) {
        context.goNamed(DHCLIENTHomepageWidget.routeName);
      }
    } finally {
      if (mounted) {
        safeSetState(() => _model.isSubmitting = false);
      }
    }
  }

  Future<void> _pickDate() async {
    // Respeta la anticipación mínima (36h sin plan / 24h con suscripción).
    final firstDate =
        DateTime.now().add(Duration(hours: DHCLIENTAgendaWidget.minAdvanceHours));
    final picked = await showDatePicker(
      context: context,
      initialDate: _model.selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: FlutterFlowTheme.of(context).primary,
            onPrimary: Colors.white,
            onSurface: const Color(0xFF00444B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      safeSetState(() => _model.selectedDate = picked);
    }
  }

  Widget _buildSelectorRow({
    required String label,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              blurRadius: 7.0,
              color: Color(0x21000000),
              offset: Offset(0.0, 0.0),
            )
          ],
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(18.0, 0.0, 12.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: const Color(0xFF00444B),
                      fontSize: 16.0,
                    ),
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.chevron_right_rounded,
              color: const Color(0xFF00444B),
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWheel() {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 13.0, 0.0, 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14.0,
            color: Color(0x21000000),
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: SizedBox(
        height: 142.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: _model.selectedSlotIndex),
                itemExtent: 40.0,
                diameterRatio: 1.3,
                selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                  background: Color(0x00000000),
                ),
                onSelectedItemChanged: (index) => safeSetState(() {
                  _model.selectedSlotIndex = index;
                  _model.timeChosen = true;
                }),
                children: _timeSlots
                    .map((s) => Center(
                          child: Text(
                            s,
                            style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: const Color(0xFF454545),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              width: 70.0,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: _model.selectedPeriodIndex),
                itemExtent: 40.0,
                diameterRatio: 1.3,
                selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                  background: Color(0x00000000),
                ),
                onSelectedItemChanged: (index) => safeSetState(() {
                  _model.selectedPeriodIndex = index;
                  _model.timeChosen = true;
                }),
                children: _periods
                    .map((p) => Center(
                          child: Text(
                            p,
                            style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: const Color(0xFF454545),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
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
                      title: 'Agenda',
                      showCurrency: false,
                      showMap: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 100.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Selecciona fecha y hora para tu servicio',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w600),
                                color: const Color(0xFF00444B),
                                fontSize: 17.0,
                                letterSpacing: 0.3,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 6.0, 0.0, 0.0),
                          child: Text(
                            'Agenda disponible con ${DHCLIENTAgendaWidget.minAdvanceHours} hs de anticipación para DOVIA BASIC.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 13.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.4,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Lugar del servicio: el backend exige un
                                // `addressId` para crear la solicitud.
                                _buildSelectorRow(
                                  label: _isLoadingAddresses
                                      ? 'Cargando ubicaciones...'
                                      : (_selectedAddressLabel ??
                                          'Selecciona la ubicación'),
                                  expanded: false,
                                  onTap: _pickAddress,
                                ),
                                const SizedBox(height: 13.0),
                                _buildSelectorRow(
                                  label: _model.selectedDate == null
                                      ? 'Selecciona la fecha'
                                      : _formatDate(_model.selectedDate!),
                                  expanded: false,
                                  onTap: _pickDate,
                                ),
                                const SizedBox(height: 13.0),
                                _buildSelectorRow(
                                  label: _model.timeChosen
                                      ? _selectedTimeLabel
                                      : 'Selecciona la hora',
                                  expanded: _model.timeExpanded,
                                  onTap: () => safeSetState(() {
                                    _model.timeExpanded = !_model.timeExpanded;
                                    if (_model.timeExpanded) {
                                      _model.timeChosen = true;
                                    }
                                  }),
                                ),
                                if (_model.timeExpanded) _buildTimeWheel(),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 40.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            // Crea la solicitud en el backend: sin esto la red
                            // de Home Associates nunca la ve.
                            onPressed: _canContinue ? _submit : null,
                            text: _model.isSubmitting ? 'Enviando...' : 'Enviar',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              disabledColor: const Color(0xFFDFDFDF),
                              disabledTextColor: const Color(0xFF6A6A6A),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    letterSpacing: 0.34,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(100.0),
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

/// Selector del lugar del servicio. Lista las direcciones registradas del
/// cliente y ofrece dar de alta una nueva, que pasa por el Coverage Check.
class _AddressPickerSheet extends StatelessWidget {
  const _AddressPickerSheet({
    required this.addresses,
    required this.selectedId,
    required this.labelOf,
    required this.idOf,
    required this.onSelect,
    required this.onAddOther,
  });

  final List<Map<String, dynamic>> addresses;
  final String? selectedId;
  final String Function(Map<String, dynamic>) labelOf;
  final String? Function(Map<String, dynamic>) idOf;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddOther;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFDFDF),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Lugar del servicio',
              style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w600,
                fontSize: 17.0,
                color: const Color(0xFF00444B),
              ),
            ),
            const SizedBox(height: 12.0),
            if (addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Todavía no tienes ubicaciones registradas.',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final id = idOf(address);
                    final selected = id != null && id == selectedId;
                    return InkWell(
                      onTap: id == null ? null : () => onSelect(id),
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0x3670ACAD)
                              : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: selected
                                ? FlutterFlowTheme.of(context).primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                labelOf(address),
                                style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.0,
                                  color: const Color(0xFF00444B),
                                ),
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check_circle,
                                size: 20.0,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12.0),
            InkWell(
              onTap: onAddOther,
              borderRadius: BorderRadius.circular(10.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_location_alt_outlined,
                      size: 20.0,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Otra ubicación',
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
