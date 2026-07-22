import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
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

  /// Nombre de la propiedad mostrado en la cabecera (Ej: "Casa A").
  static String houseName = 'Casa A';

  @override
  State<DHCLIENTCasaAWidget> createState() => _DHCLIENTCasaAWidgetState();
}

class _DHCLIENTCasaAWidgetState extends State<DHCLIENTCasaAWidget> {
  late DHCLIENTCasaAModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCasaAModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Extracción best-effort de los datos de la solicitud. El shape del backend
  // aún es incierto para varios campos, por eso cada getter prueba varias claves
  // y cae a un fallback vacío para que la pantalla renderice siempre.
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? get _data => DHCLIENTCasaAWidget.requestData;

  Map? get _address => _data?['address'] is Map ? _data!['address'] as Map : null;

  Map? get _associate {
    final a =
        _data?['associate'] ?? _data?['assignedAssociate'] ?? _data?['homeAssociate'];
    return a is Map ? a : null;
  }

  String? _firstString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  String get _exactAddress =>
      _firstString([
        _address?['exactAddress'],
        _address?['fullAddress'],
        _address?['line1'],
        _address?['address'],
        _data?['exactAddress'],
        _data?['addressLine'],
      ]) ??
      '';

  String get _arrivalInstructions =>
      _firstString([
        _address?['arrivalInstructions'],
        _data?['arrivalInstructions'],
        _address?['howToArrive'],
      ]) ??
      '';

  String get _entryInstructions =>
      _firstString([
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
    final imgs = _data?['images'];
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

  /// Monto ahorrado por el cliente (suscripción / descuento). null si no aplica.
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
    final used = _data?['usedIncludedService'] ?? _data?['includedServiceUsed'];
    final discount = _data?['discountApplied'] ?? _data?['hasDiscount'];
    return used == true || discount == true;
  }

  String get _associateName {
    final direct = _firstString([_associate?['fullName'], _associate?['name']]);
    if (direct != null) return direct;
    final first = _firstString([_associate?['firstName']]) ?? '';
    final last = _firstString([_associate?['lastName']]) ?? '';
    return '$first $last'.trim();
  }

  String get _associateAge {
    final a = _associate?['age'];
    if (a is num) return a.toString();
    return _firstString([_associate?['age']]) ?? '';
  }

  String get _associateAvatar =>
      _firstString([
        _associate?['avatarUrl'],
        _associate?['photoUrl'],
        _associate?['profileImageUrl'],
        _associate?['imageUrl'],
      ]) ??
      '';

  String get _associatePhone =>
      _firstString([
        _associate?['phoneNumber'],
        _associate?['phone'],
        _associate?['mobile'],
        _data?['associatePhone'],
      ]) ??
      '';

  String get _associateAbout =>
      _firstString([_associate?['about'], _associate?['bio']]) ?? '';

  String get _associateId =>
      _firstString([
        _associate?['id'],
        _associate?['associateId'],
        _associate?['userId'],
      ]) ??
      '';

  String get _associateIdDoc =>
      _firstString([
        _associate?['idDocumentUrl'],
        _associate?['documentUrl'],
        _associate?['idUrl'],
      ]) ??
      '';

  String get _requestId =>
      _firstString([_data?['id'], _data?['serviceRequestId']]) ?? '';

  String get _status => _firstString([_data?['status']]) ?? '';

  /// Regla de renderizado del asociado: la tarjeta del profesional solo se
  /// muestra cuando alguien ya tomó el trabajo (solicitud "Programada"/asignada
  /// o con datos del asociado). Si nadie lo ha tomado ("Pendiente") se oculta y
  /// se muestra el placeholder "Buscando al profesional ideal...".
  bool get _associateAssigned {
    if (_associate != null &&
        (_associateName.trim().isNotEmpty || _associateId.isNotEmpty)) {
      return true;
    }
    // Enum backend: PENDING (nadie lo tomó) → sin asociado; TAKEN/IN_PROGRESS/
    // FINISHED → alguien tomó el trabajo.
    const assignedStatuses = {'TAKEN', 'IN_PROGRESS', 'FINISHED'};
    return assignedStatuses.contains(_status.toUpperCase());
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
    final id = _requestId;
    if (id.isNotEmpty) {
      // TODO: reemplazar por la confirmación real en el backend cuando exista el
      // endpoint (hoy no hay "cliente confirma la visita"). Se marca client-side
      // para reflejar el cambio de estatus a "Programada" en el Dashboard.
      DHCLIENTHomepageWidget.confirmedVisitIds.add(id);
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
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
            _savingsAmount != null
                ? 'Ahorraste:\n\$${_savingsAmount!} que no pagas por tener suscripción'
                : 'Ahorraste:\n\$ (Precio de servicio que no paga por tener suscripción)',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0.0,
                  lineHeight: 1.2,
                ),
          ),
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
    final showAceptar = !DHCLIENTCasaAWidget.alreadyConfirmed;

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
                            // Regla de renderizado del asociado: si nadie tomó
                            // el trabajo ("Pendiente") se oculta la tarjeta del
                            // profesional y se muestra un placeholder de
                            // búsqueda.
                            child: _associateAssigned
                                ? wrapWithModel(
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
                                  )
                                : _searchingAssociatePlaceholder(),
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
