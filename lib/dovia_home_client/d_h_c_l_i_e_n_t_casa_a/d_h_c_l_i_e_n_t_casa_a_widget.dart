import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/service_request_fields.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proveedor_card/d_h_c_l_i_e_n_t_proveedor_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'd_h_c_l_i_e_n_t_casa_a_model.dart';
export 'd_h_c_l_i_e_n_t_casa_a_model.dart';

/// Pantalla de confirmación de la visita del Home Associate (Cliente).
///
/// Muestra en **modo solo lectura** los datos operativos que el cliente cargó,
/// el banner de ahorro (condicional), los requisitos del asociado y la tarjeta
/// de seguridad del profesional asignado. El botón inferior [Aceptar] confirma
/// la visita; una vez confirmada ([alreadyConfirmed] = true) el botón
/// desaparece y la pantalla queda como consulta.
///
/// Abierta desde el listado de "Próximas visitas" ([readOnly] = true) la
/// pantalla es estrictamente un registro de consulta: nunca muestra [Aceptar].
class DHCLIENTCasaAWidget extends StatefulWidget {
  const DHCLIENTCasaAWidget({super.key});

  static String routeName = 'DH_CLIENT_CasaA';
  static String routePath = '/dHCLIENTCasaA';

  /// Datos de la solicitud de servicio a mostrar. Se inyecta desde el Dashboard
  /// antes de navegar (mismo patrón que [DHCLIENTInstalacionWidget.serviceTitle]),
  /// porque go_router navega solo por nombre. Si es null se muestran los
  /// placeholders del diseño.
  static Map<String, dynamic>? requestData;

  /// Si la visita ya fue confirmada por el cliente. Cuando es true se oculta el
  /// botón [Aceptar] y la pantalla queda en modo consulta.
  static bool alreadyConfirmed = false;

  /// Modo consulta estricto: la pantalla se abrió desde un listado de registro
  /// (Ej: "Próximas visitas"), no desde el flujo de confirmación. Oculta el
  /// botón [Aceptar] sin importar el estatus de la solicitud.
  ///
  /// Cada origen debe setearlo antes de navegar (el Dashboard lo pone en false
  /// porque desde ahí sí se confirma la visita).
  static bool readOnly = false;

  /// Nombre de la propiedad mostrado en la cabecera (Ej: "Casa A").
  static String houseName = 'Casa A';

  @override
  State<DHCLIENTCasaAWidget> createState() => _DHCLIENTCasaAWidgetState();
}

class _DHCLIENTCasaAWidgetState extends State<DHCLIENTCasaAWidget> {
  late DHCLIENTCasaAModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Solicitud a renderizar. Nace con el resumen que inyecta la pantalla que
  /// navegó hasta acá y se completa con el detalle real en [_loadDetail].
  Map<String, dynamic>? _serviceData;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCasaAModel());

    // Lo ya inyectado se pinta sin esperar al backend; el fetch sólo completa.
    _serviceData = DHCLIENTCasaAWidget.requestData;

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  String? get _serviceRequestId {
    final raw = DHCLIENTCasaAWidget.requestData;
    final id = (raw?['id'] ?? raw?['serviceRequestId'])?.toString().trim();
    return (id == null || id.isEmpty) ? null : id;
  }

  /// El listado devuelve un resumen: dirección, instrucciones, fotos y datos del
  /// asociado sólo vienen en el detalle. Se mergea sobre el resumen para no
  /// perder los campos que el listado sí traía (mismo patrón que
  /// `d_h_c_l_i_e_n_t_trabajo_finalizado`). Si falla, se queda con el resumen.
  Future<void> _loadDetail() async {
    final id = _serviceRequestId;
    if (id == null) {
      safeSetState(() {});
      return;
    }
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.getServiceRequestCall.call(
        serviceRequestId: id,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted || !response.succeeded) return;
      final raw =
          getJsonField(response.jsonBody, r'''$.data''') ?? response.jsonBody;
      if (raw is! Map) return;
      safeSetState(() {
        _serviceData = {...?_serviceData, ...Map<String, dynamic>.from(raw)};
      });
    } catch (_) {
      // Sin detalle se renderiza el resumen inyectado.
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Extracción de los datos de la solicitud, contra el contrato de
  // `GET /dovia-home/service-requests/{id}`. Los getters conservan claves
  // alternativas como respaldo (el listado manda un resumen más pobre), pero la
  // primera candidata de cada uno es siempre el campo real del contrato.
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? get _data => _serviceData;

  Map? get _address => _data?['address'] is Map ? _data!['address'] as Map : null;

  /// Asignación del trabajo: `{ userId, assignedAt }`. **No trae el perfil**;
  /// los datos del profesional viven en [_associateProfile].
  Map? get _associate {
    final a =
        _data?['associate'] ?? _data?['assignedAssociate'] ?? _data?['homeAssociate'];
    return a is Map ? a : null;
  }

  /// Perfil del Home Associate asignado (`associateProfile`): nombre, edad,
  /// avatar, teléfono y documento de identidad.
  Map? get _associateProfile {
    final p = _data?['associateProfile'] ?? _data?['associateDetail'];
    return p is Map ? p : null;
  }

  String? _firstString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  String get _exactAddress =>
      _firstString([
        _address?['address'],
        _address?['exactAddress'],
        _address?['fullAddress'],
        _address?['line1'],
        _data?['exactAddress'],
        _data?['addressLine'],
      ]) ??
      '';

  /// El contrato actual **no** distingue las instrucciones para llegar de las
  /// de ingreso: `address` solo trae `accessInstructions`, que se muestra en
  /// [_entryInstructions]. Este campo queda vacío hasta que el backend lo
  /// separe.
  /// TODO: mapear cuando exista el campo de instrucciones de llegada.
  String get _arrivalInstructions =>
      _firstString([
        _address?['arrivalInstructions'],
        _data?['arrivalInstructions'],
        _address?['howToArrive'],
      ]) ??
      '';

  String get _entryInstructions =>
      _firstString([
        _address?['accessInstructions'],
        _address?['entryInstructions'],
        _data?['entryInstructions'],
        _address?['howToEnter'],
      ]) ??
      '';

  String get _workDescription => _firstString([_data?['description']]) ?? '';

  String get _mustHaveReady =>
      _firstString([
        _data?['associateNotes'],
        _data?['requirements'],
        _data?['preparationNotes'],
        _data?['clientPreparation'],
      ]) ??
      '';

  DateTime? get _scheduledAt {
    final apt = _data?['appointment'];
    final raw = _firstString([
      apt is Map ? apt['scheduledAt'] : null,
      _data?['scheduledAt'],
    ]);
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  List<String> get _imageUrls {
    // El contrato entrega `requestImageUrls` (lista de strings). `images` se
    // conserva por si el resumen del listado usa esa forma.
    final imgs = _data?['requestImageUrls'] ?? _data?['images'];
    if (imgs is! List) return [];
    final urls = <String>[];
    for (final it in imgs) {
      if (it is String && it.trim().isNotEmpty) {
        urls.add(it.trim());
      } else if (it is Map) {
        final u = _firstString(
            [it['url'], it['signedUrl'], it['downloadUrl'], it['storageKey']]);
        if (u != null) urls.add(u);
      }
    }
    return urls;
  }

  /// Plan con el que se tarificó la solicitud (`price.plan`). `SUBSCRIBED`
  /// significa que el cliente pagó el precio de suscriptor.
  String get _pricePlan {
    final price = _data?['price'];
    return _firstString([price is Map ? price['plan'] : null])?.toUpperCase() ??
        '';
  }

  /// Monto ahorrado por el cliente (suscripción / descuento). null si no aplica.
  ///
  /// El contrato solo trae la fila de precio ya aplicada (`price.price`), no el
  /// precio regular contra el que compararla, así que hoy esto casi siempre es
  /// null y el banner sale sin cifra.
  /// TODO: usar `savings` cuando el backend lo exponga.
  String? get _savingsAmount {
    final payment = _data?['payment'];
    final raw = _data?['savings'] ??
        _data?['savingsAmount'] ??
        _data?['discountAmount'] ??
        (payment is Map ? payment['savings'] : null);
    if (raw is num) return raw > 0 ? raw.toStringAsFixed(2) : null;
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  /// Regla de negocio: el banner verde solo se muestra si el cliente usó su
  /// servicio incluido o el descuento del 35%. Si pagó precio regular se oculta.
  /// Sin datos (modo demo) se muestra el banner del diseño.
  bool get _hasSavings {
    if (_data == null) return true;
    if (_savingsAmount != null) return true;
    if (_pricePlan == 'SUBSCRIBED') return true;
    final used = _data?['usedIncludedService'] ?? _data?['includedServiceUsed'];
    final discount = _data?['discountApplied'] ?? _data?['hasDiscount'];
    return used == true || discount == true;
  }

  String get _associateName {
    final direct = _firstString([
      _associateProfile?['fullName'],
      _associateProfile?['name'],
      _associate?['fullName'],
      _associate?['name'],
    ]);
    if (direct != null) return direct;
    final first =
        _firstString([_associateProfile?['firstName'], _associate?['firstName']]) ??
            '';
    final last =
        _firstString([_associateProfile?['lastName'], _associate?['lastName']]) ??
            '';
    return '$first $last'.trim();
  }

  String get _associateAge {
    final a = _associateProfile?['age'] ?? _associate?['age'];
    if (a is num) return a.toString();
    return _firstString([a]) ?? '';
  }

  String get _associateAvatar =>
      _firstString([
        _associateProfile?['avatar'],
        _associateProfile?['avatarUrl'],
        _associate?['avatarUrl'],
        _associate?['photoUrl'],
        _associate?['profileImageUrl'],
        _associate?['imageUrl'],
      ]) ??
      '';

  /// El perfil entrega el teléfono partido (`{ countryCode, number }`); el
  /// resumen del listado a veces lo manda plano.
  String get _associatePhone {
    final phone = _associateProfile?['phone'] ?? _associate?['phone'];
    if (phone is Map) {
      final code = _firstString([phone['countryCode']]) ?? '';
      final number = _firstString([phone['number']]) ?? '';
      final composed = '$code$number'.trim();
      if (composed.isNotEmpty) return composed;
    }
    return _firstString([
          phone,
          _associateProfile?['phoneNumber'],
          _associate?['phoneNumber'],
          _associate?['mobile'],
          _data?['associatePhone'],
        ]) ??
        '';
  }

  /// Biografía del asociado. El contrato aún no la expone, así que hoy siempre
  /// llega vacía y el enlace "Sobre mi" avisa que no hay información.
  /// TODO: mapear cuando `associateProfile` incluya la bio.
  String get _associateAbout =>
      _firstString([
        _associateProfile?['about'],
        _associateProfile?['bio'],
        _associate?['about'],
        _associate?['bio'],
      ]) ??
      '';

  String get _associateId =>
      _firstString([
        _associate?['userId'],
        _associateProfile?['id'],
        _associate?['id'],
        _associate?['associateId'],
      ]) ??
      '';

  String get _associateIdDoc =>
      _firstString([
        _associateProfile?['identificationDocumentUrl'],
        _associate?['idDocumentUrl'],
        _associate?['documentUrl'],
        _associate?['idUrl'],
      ]) ??
      '';

  String get _requestId =>
      _firstString([_data?['id'], _data?['serviceRequestId']]) ?? '';

  String get _status => _firstString([_data?['status']]) ?? '';

  /// Solicitud de materiales adicionales que el asociado envió desde su app y
  /// que sigue esperando la decisión del cliente. Mientras exista, el detalle
  /// del servicio ofrece el acceso directo a la pantalla de revisión.
  Map<String, dynamic>? get _pendingExtraMaterials {
    final raw = _data?['extraMaterials'] ??
        _data?['extraMaterialsRequest'] ??
        _data?['extraMaterialsRequests'] ??
        _data?['materialsRequest'];
    final Map<String, dynamic>? materials = raw is Map
        ? Map<String, dynamic>.from(raw)
        : (raw is List && raw.isNotEmpty && raw.last is Map
            ? Map<String, dynamic>.from(raw.last as Map)
            : null);
    if (materials == null) return null;

    final status =
        _firstString([materials['materialsStatus'], materials['status']])
            ?.toUpperCase();
    // Sin estatus legible se asume pendiente, para no ocultarle al cliente una
    // solicitud que el asociado sí envió.
    const decided = {
      'ACCEPTED',
      'APPROVED',
      'PAID',
      'REJECTED',
      'CANCELLED',
      'COMPLETED',
    };
    return decided.contains(status) ? null : materials;
  }

  /// Hay una persona concreta que mostrar en la tarjeta de seguridad. Cuando el
  /// proveedor es una empresa el contrato no entrega `associateProfile`, así que
  /// no hay foto, edad ni documento que renderizar.
  bool get _hasAssociatePersonProfile =>
      _associateProfile != null && _associateName.trim().isNotEmpty;

  /// Regla de renderizado del asociado: la tarjeta del profesional solo se
  /// muestra cuando alguien ya tomó el trabajo (solicitud "Programada"/asignada
  /// o con datos del asociado). Si nadie lo ha tomado ("Pendiente") se oculta y
  /// se muestra el placeholder "Buscando al profesional ideal...".
  bool get _associateAssigned {
    // `associate.assignedAt` es la señal explícita del contrato.
    if (_firstString([_associate?['assignedAt']]) != null) return true;
    if ((_associate != null || _associateProfile != null) &&
        (_associateName.trim().isNotEmpty || _associateId.isNotEmpty)) {
      return true;
    }
    // Enum backend: PENDING (nadie lo tomó) → sin asociado; TAKEN/IN_PROGRESS/
    // FINISHED → alguien tomó el trabajo.
    const assignedStatuses = {'TAKEN', 'IN_PROGRESS', 'FINISHED'};
    return assignedStatuses.contains(_status.toUpperCase());
  }

  String get _requestType =>
      (_firstString([_data?['requestType']]) ?? 'SERVICE').toUpperCase();

  /// Hay algo que confirmar solo cuando un Home Associate ya tomó el trabajo
  /// (TAKEN). Con la solicitud aún "Pendiente" nadie la tomó, así que no hay
  /// visita que aceptar. Sin datos (ruta directa / modo diseño) se muestra el
  /// botón para no romper el mockup.
  ///
  /// Las cotizaciones y los trabajos fuera de alcance quedan fuera: ahí el
  /// cliente ya aprobó al proveedor al aceptar la propuesta
  /// ([kConfirmableRequestTypes]).
  bool get _awaitsConfirmation {
    if (_data == null) return true;
    if (_status.toUpperCase() != 'TAKEN') return false;
    return kConfirmableRequestTypes.contains(_requestType);
  }

  // ---------------------------------------------------------------------------
  // Contacto con el asociado (cabecera).
  // ---------------------------------------------------------------------------

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openChat() async {
    final phone = _associatePhone;
    if (phone.isEmpty) {
      _showSnack('Chat no disponible');
      return;
    }
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('No se pudo abrir el chat');
    }
  }

  Future<void> _callAssociate() async {
    final phone = _associatePhone;
    if (phone.isEmpty) {
      _showSnack('Teléfono no disponible');
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      _showSnack('No se pudo iniciar la llamada');
    }
  }

  /// Confirma la visita: marca la solicitud como confirmada (client-side),
  /// muestra el modal de éxito y regresa al Dashboard.
  Future<void> _confirmVisit() async {
    final id = _requestId.isNotEmpty ? _requestId : (_serviceRequestId ?? '');
    // TODO: reemplazar por la confirmación real en el backend cuando exista el
    // endpoint (hoy no hay "cliente confirma la visita"). Se marca client-side
    // para reflejar el cambio de estatus a "Programada" en el Dashboard.
    DHCLIENTHomepageWidget.markVisitConfirmed(id);

    // Pop-up central (no bottom sheet): el diseño lo pide sobre la pantalla.
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: DHCLIENTExitoProgramarAgendaWidget(
            houseName: DHCLIENTCasaAWidget.houseName,
            message:
                'Programaste con éxito tu servicio para la ${DHCLIENTCasaAWidget.houseName}.',
          ),
        );
      },
    );

    if (!mounted) return;
    context.safePop();
  }

  // ---------------------------------------------------------------------------
  // UI helpers.
  // ---------------------------------------------------------------------------

  TextStyle get _labelStyle =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(),
            fontSize: 16.0,
            letterSpacing: 0.0,
          );

  Widget _sectionLabel(String text) => Text(text, style: _labelStyle);

  /// Caja de solo lectura (campo bloqueado). Muestra [value] o [hint] si vacío.
  Widget _readOnlyBox(String value, {String hint = 'xxxx'}) {
    final hasValue = value.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        hasValue ? value : hint,
        textAlign: TextAlign.center,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              fontSize: 15.0,
              letterSpacing: 0.0,
              color: hasValue
                  ? FlutterFlowTheme.of(context).primaryText
                  : FlutterFlowTheme.of(context).secondaryText,
            ),
      ),
    );
  }

  Widget _labeledSection(String label, Widget field) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 19.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(label),
            const SizedBox(height: 12.0),
            field,
          ],
        ),
      );

  Widget _dateField() {
    final d = _scheduledAt;
    final dd = d != null ? DateFormat('dd').format(d) : '';
    final mm = d != null ? DateFormat('MM').format(d) : '';
    final yyyy = d != null ? DateFormat('yyyy').format(d) : '';
    return Row(
      children: [
        Expanded(child: _readOnlyBox(dd, hint: 'DD')),
        const SizedBox(width: 8.0),
        Expanded(child: _readOnlyBox(mm, hint: 'MM')),
        const SizedBox(width: 8.0),
        Expanded(child: _readOnlyBox(yyyy, hint: 'AAAA')),
      ],
    );
  }

  Widget _photoPlaceholder() => Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8.0),
        ),
      );

  Widget _photosRow() {
    final urls = _imageUrls;
    // Con datos reales y sin fotos se dice que no hay: los cuadros grises del
    // diseño son del mockup y aquí harían parecer que hay adjuntos.
    if (urls.isEmpty && _data != null) {
      return Text(
        'Sin fotos adjuntas',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              fontSize: 14.0,
              letterSpacing: 0.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
      );
    }
    final count = urls.isEmpty ? 5 : urls.length;
    return SizedBox(
      height: 60.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 10.0),
        itemBuilder: (context, i) {
          if (urls.isEmpty) return _photoPlaceholder();
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              urls[i],
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _photoPlaceholder(),
            ),
          );
        },
      ),
    );
  }

  /// Acceso a la revisión de los materiales adicionales que pidió el asociado.
  /// El cliente decide ahí si autoriza la compra; al volver se refresca el
  /// detalle para reflejar la decisión.
  void _openMateriales() {
    DHCLIENTMaterialesWidget.serviceRequestIdRef = _requestId;
    DHCLIENTMaterialesWidget.requestData = _data;
    context
        .pushNamed(DHCLIENTMaterialesWidget.routeName)
        .then((_) => safeSetState(() {}));
  }

  Widget _extraMaterialsBanner() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
        child: InkWell(
          onTap: _openMateriales,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0x3670ACAD),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    'El asociado necesita materiales adicionales.\nRevisa la solicitud para que pueda continuar.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          lineHeight: 1.3,
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _savingsBanner() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0x3670ACAD),
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Text(
            // Sin monto (el contrato no expone el ahorro ni el precio regular)
            // se afirma el beneficio sin inventar una cifra; el literal del
            // mockup "$ (Precio de servicio...)" parecería un error en
            // producción.
            _savingsAmount != null
                ? 'Ahorraste:\n\$${_savingsAmount!} que no pagas por tener suscripción'
                : 'Ahorraste el precio de este servicio por tener tu suscripción.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0.0,
                  lineHeight: 1.2,
                ),
          ),
        ),
      );

  /// Trabajo ya asignado pero sin perfil de persona que mostrar: pasa cuando el
  /// proveedor es una empresa (cotización / fuera de alcance), donde el
  /// contrato no entrega foto, edad ni documento.
  ///
  /// No se reutiliza [_searchingAssociatePlaceholder] porque diría que se está
  /// buscando a alguien cuando el trabajo ya tiene dueño.
  Widget _assignedProviderPlaceholder() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 48.0,
              color: FlutterFlowTheme.of(context).primary,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Proveedor asignado',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Te compartiremos los datos del profesional que realizará el '
              'trabajo antes de la visita.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );

  /// Estado vacío del asociado cuando la solicitud sigue "Pendiente" (nadie ha
  /// tomado el trabajo). Reemplaza a la tarjeta del profesional.
  Widget _searchingAssociatePlaceholder() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 48.0,
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Buscando al profesional ideal...',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    letterSpacing: 0.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 42.0, 20.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                color: FlutterFlowTheme.of(context).alternate,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                DHCLIENTCasaAWidget.houseName,
                maxLines: 2,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          _headerIconButton(Icons.chat_bubble_outline, _openChat),
          const SizedBox(width: 8.0),
          _headerIconButton(Icons.phone_outlined, _callAssociate),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onTap) => InkWell(
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
          ),
          child: Icon(
            icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 20.0,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // El botón inferior solo existe en el flujo de confirmación: nunca en modo
    // consulta, nunca si ya se confirmó y nunca si todavía nadie tomó el
    // trabajo.
    final showAceptar = !DHCLIENTCasaAWidget.readOnly &&
        !DHCLIENTCasaAWidget.alreadyConfirmed &&
        _awaitsConfirmation;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        bottomNavigationBar: showAceptar
            ? SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 12.0),
                  child: FFButtonWidget(
                    onPressed: _confirmVisit,
                    text: 'Aceptar',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 43.0,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: GoogleFonts.publicSans(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              )
            : null,
        body: Stack(
          children: [
            wrapWithModel(
              model: _model.cornerGradientBackgroundModel,
              updateCallback: () => safeSetState(() {}),
              child: const CornerGradientBackgroundWidget(),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Acción pendiente del cliente: va primero para que
                          // no quede tapada por el detalle de la visita.
                          if (_pendingExtraMaterials != null)
                            _extraMaterialsBanner(),
                          _labeledSection(
                              'Dirección exacta', _readOnlyBox(_exactAddress)),
                          _labeledSection('Fecha', _dateField()),
                          _labeledSection('Instrucciones para llegar',
                              _readOnlyBox(_arrivalInstructions)),
                          _labeledSection('Instrucciones para ingresar',
                              _readOnlyBox(_entryInstructions)),
                          _labeledSection(
                            'Trabajos consistentes en:',
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_workDescription.isNotEmpty) ...[
                                  Text(
                                    'Descripción:\n$_workDescription',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  const SizedBox(height: 12.0),
                                ],
                                _photosRow(),
                              ],
                            ),
                          ),
                          if (_hasSavings) _savingsBanner(),
                          _labeledSection(
                              'Debe tener listo:', _readOnlyBox(_mustHaveReady)),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 21.0, 0.0, 0.0),
                            // Regla de renderizado del asociado: con perfil de
                            // persona va la tarjeta de seguridad; asignado sin
                            // perfil (proveedor empresa) va el aviso de
                            // proveedor asignado; y si nadie tomó el trabajo
                            // ("Pendiente"), el placeholder de búsqueda.
                            child: !_hasAssociatePersonProfile
                                ? (_associateAssigned
                                    ? _assignedProviderPlaceholder()
                                    : _searchingAssociatePlaceholder())
                                : wrapWithModel(
                                    model: _model.dHCLIENTProveedorCardModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: DHCLIENTProveedorCardWidget(
                                      isAssigned: true,
                                      roleLabel: 'Dovia Home Associate',
                                      fullName: _associateName.isNotEmpty
                                          ? _associateName
                                          : 'Nombre Apellido',
                                      age: _associateAge,
                                      avatarUrl: _associateAvatar,
                                      phoneNumber: _associatePhone,
                                      advisorId: _associateId,
                                      about: _associateAbout,
                                      showDownloadId: true,
                                      idDocumentUrl: _associateIdDoc,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
