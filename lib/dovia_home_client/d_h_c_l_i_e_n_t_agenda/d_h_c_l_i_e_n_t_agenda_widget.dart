import '/shared_components/status_bar_clip/status_bar_clip.dart';
import '/dovia_home_client/category_picker.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/service_catalog.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/cupertino.dart';
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/repositories/payments_repository.dart';

import 'd_h_c_l_i_e_n_t_agenda_model.dart';
export 'd_h_c_l_i_e_n_t_agenda_model.dart';

class DHCLIENTAgendaWidget extends StatefulWidget {
  const DHCLIENTAgendaWidget({super.key});

  static String routeName = 'DH_CLIENT_Agenda';
  static String routePath = '/dHCLIENTAgenda';

  /// Anticipación mínima (en horas) para agendar una visita: 36h para pago por
  /// uso sin plan, 24h para clientes con suscripción. Se recalcula en
  /// [_DHCLIENTAgendaWidgetState.initState] contra la suscripción actual, así
  /// que el valor de acá es sólo el default antes de esa resolución.
  static int minAdvanceHours = 36;

  /// Ruta a la que ir tras crear la solicitud, en vez del modal de éxito +
  /// Dashboard de siempre. La setea quien empuja esta pantalla.
  ///
  /// El wizard estándar (Instalación → Agenda → ValorVisita) la usa para
  /// derivar al cobro: el pago custom exige un `serviceId`, que recién existe
  /// después de este paso. El flujo de cotización aceptada no cobra acá y la
  /// deja en `null`, conservando el comportamiento de siempre (éxito +
  /// Dashboard).
  static String? nextRouteAfterSubmit;

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

  /// Alcance del servicio elegido: su `serviceId` y las categorías que se
  /// pueden pedir dentro de él. El POST exige las dos cosas, así que la
  /// pantalla no puede enviar nada hasta tenerlo resuelto.
  DoviaHomeServiceScope? _scope;
  bool _isLoadingScope = true;
  String? _selectedCategoryId;

  /// Solicitud ya creada en el backend. Si algo falla después del POST, el
  /// reintento la reutiliza en vez de crear otra.
  String? _createdRequestId;

  /// Copia de [DHCLIENTAgendaWidget.nextRouteAfterSubmit] tomada al entrar.
  String? _nextRouteAfterSubmit;

  /// Dirección, fecha y categoría con que se creó [_createdRequestId].
  String? _createdRequestKey;

  /// Fotos (por índice) ya confirmadas en [_createdRequestId], para que un
  /// reintento suba solo las que faltan.
  final Set<int> _uploadedPhotoIndexes = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTAgendaModel());

    // Se toma una sola vez al entrar: si el cliente vuelve del cobro y reenvía,
    // tiene que volver a pasar por el pago. Se limpia la estática para que no
    // se filtre al flujo de cotización, que no la setea.
    _nextRouteAfterSubmit = DHCLIENTAgendaWidget.nextRouteAfterSubmit;
    DHCLIENTAgendaWidget.nextRouteAfterSubmit = null;

    _loadAddresses();
    _loadScope();
    _resolveMinAdvanceHours();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// 36h de anticipación para pago por uso, 24h con suscripción activa. Se
  /// resuelve acá (y no la fija quien empuja la pantalla) porque es la misma
  /// regla en los dos caminos que llegan a Agenda: el wizard estándar y la
  /// aceptación de una cotización.
  Future<void> _resolveMinAdvanceHours() async {
    final payments = context.read<PaymentsRepository>();
    await payments.loadCurrentSubscription();
    if (!mounted) return;
    safeSetState(() {
      DHCLIENTAgendaWidget.minAdvanceHours =
          payments.hasActiveSubscription && !payments.subscriptionNeedsRenewal
              ? 24
              : 36;
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Enviar exige tipo de trabajo, fecha, hora y lugar del servicio (los cuatro
  /// van en el POST).
  bool get _canContinue =>
      _selectedCategoryId != null &&
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
  // Tipo de trabajo (categoría del servicio).
  // ---------------------------------------------------------------------------

  /// Categorías del servicio elegido en el Dashboard. Sin esto no hay
  /// `categoryId` que mandar, y el backend rechaza la solicitud.
  Future<void> _loadScope() async {
    final scope = await loadDoviaHomeServiceScope(
      serviceTitle: DHCLIENTInstalacionWidget.serviceTitle,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    safeSetState(() {
      _scope = scope;
      _isLoadingScope = false;
      // La categoría se elige en el levantamiento del trabajo, que es donde
      // el cliente ve qué incluye y qué lleva el técnico. Acá sólo se
      // recoge; la fila queda para corregirla sin volver atrás.
      _selectedCategoryId ??= DHCLIENTInstalacionWidget.selectedCategoryId;
      // Con una sola categoría no tiene sentido preguntar.
      final categories = scope?.categories ?? const [];
      if (categories.length == 1) _selectedCategoryId = categories.first.id;
      if (scope?.categoryById(_selectedCategoryId) == null) {
        _selectedCategoryId = null;
      }
    });
  }

  String? get _selectedCategoryLabel =>
      _scope?.categoryById(_selectedCategoryId)?.name;

  /// Etiqueta de la fila: distingue el catálogo cargando del servicio que no
  /// se pudo resolver, porque ahí no hay nada que elegir y el envío va a
  /// fallar hasta que se recargue.
  String get _categoryRowLabel {
    if (_isLoadingScope) return 'Cargando tipos de trabajo...';
    if (_scope == null) return 'No se pudo cargar el tipo de trabajo';
    return _selectedCategoryLabel ?? 'Selecciona el tipo de trabajo';
  }

  Future<void> _pickCategory() async {
    if (_isLoadingScope) return;
    // El servicio no se resolvió (Ej: se entró directo a la ruta o falló la
    // red): se reintenta acá en vez de dejar la fila muerta.
    if (_scope == null) {
      safeSetState(() => _isLoadingScope = true);
      await _loadScope();
      if (!mounted || _scope == null) return;
    }

    final category = await pickDoviaHomeCategory(
      context: context,
      title: 'Tipo de trabajo',
      categories: _scope?.categories ?? const [],
      selectedId: _selectedCategoryId,
      emptyMessage: 'Este servicio todavía no tiene tipos de trabajo '
          'disponibles.',
    );
    if (category == null || !mounted) return;
    safeSetState(() => _selectedCategoryId = category.id);
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
    // La ruta pendiente se consume al registrar la dirección; si el cliente
    // canceló queda seteada, así que se limpia siempre al volver para que no
    // desvíe una entrada posterior a Ubicación.
    DHCLIENTUbicacionWidget.pendingNextRoute = null;
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

  /// Índices (en [DHCLIENTInstalacionWidget.photos]) de las fotos que todavía
  /// no quedaron confirmadas en el backend. Las que no tienen bytes no se
  /// pueden subir y no cuentan.
  List<int> get _pendingPhotoIndexes {
    final photos = DHCLIENTInstalacionWidget.photos;
    return [
      for (var i = 0; i < photos.length; i++)
        if (photos[i].bytes != null && !_uploadedPhotoIndexes.contains(i)) i,
    ];
  }

  /// Sube las fotos pendientes con el flujo presign → PUT → confirm y devuelve
  /// cuántas quedaron sin subir. Nunca lanza: la solicitud ya existe, así que
  /// un fallo de fotos no la anula, pero el llamador tiene que enterarse.
  Future<int> _uploadPendingPhotos(String serviceRequestId) async {
    final photos = DHCLIENTInstalacionWidget.photos;
    final pending = _pendingPhotoIndexes;
    if (pending.isEmpty) return 0;

    try {
      final token = currentAuthenticationToken ?? '';
      final uploads = <Map<String, dynamic>>[
        for (final i in pending)
          {
            'clientUploadId': 'upload_$i',
            'contentType': 'image/jpeg',
            'fileName': photos[i].name ?? 'foto_$i.jpg',
          },
      ];

      final presignRes = await DOVIAAPIDoviaHomeContextGroup
          .presignServiceRequestImagesCall
          .call(
        serviceRequestId: serviceRequestId,
        uploads: uploads,
        authToken: token,
      );
      if (!presignRes.succeeded) return pending.length;

      final items = DOVIAAPIDoviaHomeContextGroup
          .presignServiceRequestImagesCall
          .items(presignRes.jsonBody);
      if (items == null || items.isEmpty) return pending.length;

      final storageKeys = <String>[];
      final putIndexes = <int>[];
      for (final item in items) {
        if (item is! Map) continue;
        final clientUploadId = item['clientUploadId']?.toString() ?? '';
        final uploadUrl = item['uploadUrl']?.toString();
        final storageKey = item['storageKey']?.toString();
        final index =
            int.tryParse(clientUploadId.replaceAll('upload_', '')) ?? -1;
        if (uploadUrl == null ||
            storageKey == null ||
            !pending.contains(index)) {
          continue;
        }

        try {
          final putRes = await http.put(
            Uri.parse(uploadUrl),
            headers: {'Content-Type': 'image/jpeg'},
            body: photos[index].bytes,
          );
          if (putRes.statusCode >= 200 && putRes.statusCode < 300) {
            storageKeys.add(storageKey);
            putIndexes.add(index);
          }
        } catch (e) {
          debugPrint('[Agenda] PUT de la foto $index falló: $e');
        }
      }

      if (storageKeys.isNotEmpty) {
        final confirmRes = await DOVIAAPIDoviaHomeContextGroup
            .confirmServiceRequestImagesCall
            .call(
          serviceRequestId: serviceRequestId,
          storageKeys: storageKeys,
          authToken: token,
        );
        // Sin confirm el backend no las asocia: siguen pendientes y el
        // reintento las vuelve a presignar.
        if (confirmRes.succeeded) _uploadedPhotoIndexes.addAll(putIndexes);
      }
    } catch (e) {
      debugPrint('[Agenda] No se pudieron subir las fotos: $e');
    }
    return _pendingPhotoIndexes.length;
  }

  /// Sube las fotos y, si alguna falla, deja reintentar solo esas o seguir sin
  /// ellas. El aviso no se puede cerrar sin elegir: la solicitud ya existe con
  /// la fecha y la dirección de ahora, así que no hay que volver al formulario.
  Future<void> _uploadPhotosWithRetry(String serviceRequestId) async {
    while (true) {
      final failed = await _uploadPendingPhotos(serviceRequestId);
      if (failed == 0 || !mounted) return;

      final total = _uploadedPhotoIndexes.length + failed;
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Faltan fotos'),
            content: Text(failed == 1
                ? 'Tu solicitud ya se creó, pero 1 de $total fotos no se pudo subir.'
                : 'Tu solicitud ya se creó, pero $failed de $total fotos no se pudieron subir.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Continuar sin ellas'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
      if (retry != true) return;
    }
  }

  /// Devuelve la solicitud a usar: la ya creada si el cliente no cambió
  /// dirección, fecha ni categoría (así un reintento no la duplica), o una
  /// nueva. `null` si no se pudo crear (el aviso ya se mostró).
  Future<String?> _ensureServiceRequest(
      String addressId, DateTime scheduledAt) async {
    final scope = _scope;
    final categoryId = _selectedCategoryId;
    if (scope == null || categoryId == null) {
      _showSnack(
          'No se pudo identificar el servicio en el catálogo. Intenta de nuevo.');
      return null;
    }

    final key = '$addressId|${scheduledAt.toIso8601String()}|$categoryId';
    if (_createdRequestId != null && _createdRequestKey == key) {
      return _createdRequestId;
    }

    // El endpoint rechaza strings vacíos: si se llegó hasta aquí sin
    // levantamiento (Ej: entrando directo a la ruta) se manda el servicio.
    final description = DHCLIENTInstalacionWidget.description.trim().isNotEmpty
        ? DHCLIENTInstalacionWidget.description.trim()
        : 'Solicitud de ${DHCLIENTInstalacionWidget.serviceTitle}';

    final response =
        await DOVIAAPIDoviaHomeContextGroup.createServiceRequestCall.call(
      serviceId: scope.serviceId,
      categoryId: categoryId,
      description: description,
      scheduledAt: scheduledAt.toUtc().toIso8601String(),
      addressId: addressId,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!response.succeeded) {
      // La categoría dejó de pertenecer al servicio (el catálogo cambió
      // mientras el cliente completaba el formulario): se recarga la lista y
      // se le pide que elija de nuevo, porque reenviar lo mismo vuelve a
      // fallar.
      if (doviaHomeErrorCode(response) ==
          kDoviaHomeServiceCategoryNotFoundCode) {
        safeSetState(() {
          _selectedCategoryId = null;
          _isLoadingScope = true;
        });
        await _loadScope();
        _showSnack(
            'El tipo de trabajo que elegiste ya no está disponible. Elige otro.');
        return null;
      }
      _showSnack(doviaHomeErrorMessage(response) ??
          'No se pudo enviar la solicitud. Intenta de nuevo.');
      return null;
    }

    final id = DOVIAAPIDoviaHomeContextGroup.createServiceRequestCall
        .id(response.jsonBody);
    if (id == null || id.isEmpty) {
      debugPrint('[Agenda] POST service-requests sin id: ${response.bodyText}');
      _showSnack('No se pudo confirmar la solicitud. Intenta de nuevo.');
      return null;
    }

    // Es otra solicitud: las fotos subidas a la anterior no cuentan.
    _createdRequestId = id;
    _createdRequestKey = key;
    _uploadedPhotoIndexes.clear();
    return id;
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
    final earliest = DateTime.now()
        .add(Duration(hours: DHCLIENTAgendaWidget.minAdvanceHours));
    if (scheduledAt.isBefore(earliest)) {
      _showSnack(
          'La visita debe agendarse con al menos ${DHCLIENTAgendaWidget.minAdvanceHours} hs de anticipación.');
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final serviceRequestId =
          await _ensureServiceRequest(addressId, scheduledAt);
      if (serviceRequestId == null) return;

      await _uploadPhotosWithRetry(serviceRequestId);
      if (!mounted) return;

      // El wizard estándar deriva al cobro: la solicitud existe pero todavía
      // no está pagada, así que ni se anuncia en el Dashboard ni se muestra el
      // modal de éxito. Eso pasa recién cuando ValorVisita confirma el pago.
      final nextRoute = _nextRouteAfterSubmit;
      if (nextRoute != null) {
        DHCLIENTValorVisitaPageWidget.serviceRequestId = serviceRequestId;
        if (!mounted) return;
        context.pushNamed(nextRoute);
        return;
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
      DHCLIENTInstalacionWidget.discardSavedDraft();

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
    final firstDate = DateTime.now()
        .add(Duration(hours: DHCLIENTAgendaWidget.minAdvanceHours));
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
  }) =>
      DoviaHomeSelectorRow(label: label, expanded: expanded, onTap: onTap);

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
            StatusBarClip(
                child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: DOVIASHAREDHeaderWidget(
                      showLogo: openedFromHome(context),
                      showSupport: false,
                      topPadding: 58.0,
                      showNotifications: true,
                      showSettings: true,
                      title: 'Agenda',
                      showCurrency: false,
                      showMap: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 150.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Selecciona fecha y hora para tu servicio',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                            // 24 h es la regla de suscriptor (ver
                            // `_resolveMinAdvanceHours`); el plan se nombra
                            // según la que aplica.
                            'Agenda disponible con ${DHCLIENTAgendaWidget.minAdvanceHours} hs de anticipación para ${DHCLIENTAgendaWidget.minAdvanceHours <= 24 ? 'DOVIA Home Premium' : 'DOVIA BASIC'}.',
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
                                // Tipo de trabajo: el backend exige un
                                // `categoryId` que pertenezca al servicio.
                                _buildSelectorRow(
                                  label: _categoryRowLabel,
                                  expanded: false,
                                  onTap: _pickCategory,
                                ),
                                const SizedBox(height: 13.0),
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
                              0.0, 28.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            // Crea la solicitud en el backend: sin esto la red
                            // de Home Associates nunca la ve.
                            onPressed: _canContinue ? _submit : null,
                            text:
                                _model.isSubmitting ? 'Enviando...' : 'Enviar',
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
            )),
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
    // El fondo blanco llega hasta abajo y el contenido termina sobre los
    // botones de Android.
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.0, 16.0, 20.0, 20.0 + MediaQuery.viewPaddingOf(context).bottom),
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
    );
  }
}
