import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_c_l_i_e_n_t_cotizacion_model.dart';
export 'd_h_c_l_i_e_n_t_cotizacion_model.dart';

/// Levantamiento de un requerimiento complejo para que la red de proveedores
/// DOVIA lo evalúe y devuelva propuestas a medida (exclusivo Premium).
///
/// El cliente describe el trabajo (obligatorio), adjunta fotos (opcional pero
/// recomendado) y elige el lugar del servicio: su propiedad principal o una
/// **Otra ubicación**, que dispara la validación de cobertura (Coverage Check)
/// en [DHCLIENTUbicacionWidget] antes de permitir la solicitud.
///
/// Al enviar, la solicitud queda en estatus "Pendiente de Cotización" y se
/// distribuye a las empresas proveedoras; el cliente vuelve al Dashboard.
class DHCLIENTCotizacionWidget extends StatefulWidget {
  const DHCLIENTCotizacionWidget({super.key});

  static String routeName = 'DH_CLIENT_Cotizacion';
  static String routePath = '/dHCLIENTCotizacion';

  /// Estatus con el que la solicitud aparece en el Dashboard tras enviarse.
  static const String pendingQuoteStatus = 'Pendiente de Cotización';

  /// Dirección devuelta por el flujo de "Otra ubicación" ([DHCLIENTUbicacionWidget])
  /// una vez que pasó el Coverage Check. Se usan campos estáticos porque
  /// go_router navega sólo por nombre (mismo patrón que
  /// [DHCLIENTUbicacionWidget.pendingNextRoute]).
  static String? verifiedAddressId;

  /// Etiqueta de la dirección verificada para mostrar en el botón de selección.
  static String? verifiedAddressLabel;

  @override
  State<DHCLIENTCotizacionWidget> createState() =>
      _DHCLIENTCotizacionWidgetState();
}

class _DHCLIENTCotizacionWidgetState extends State<DHCLIENTCotizacionWidget> {
  late DHCLIENTCotizacionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Direcciones de servicio registradas del cliente. Cada una es un botón de
  /// selección; tocarlas **sólo** elige el lugar del servicio.
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoadingAddresses = true;

  /// `addressId` elegido. Null = ninguno, por lo que [Enviar] queda inactivo.
  String? _selectedAddressId;

  /// Dirección recién dada de alta en esta sesión. Se conserva como respaldo por
  /// si el listado del backend todavía no la refleja, para que el cliente no vea
  /// desaparecer la ubicación que acaba de agregar.
  Map<String, dynamic>? _justAddedAddress;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCotizacionModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    // Rehabilita el botón [Enviar] en tiempo real según haya descripción.
    _model.textController!.addListener(_onDescriptionChanged);

    _loadAddresses();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.textController?.removeListener(_onDescriptionChanged);
    _model.dispose();

    super.dispose();
  }

  void _onDescriptionChanged() => safeSetState(() {});

  /// Trae las direcciones de servicio registradas del cliente, que son las
  /// opciones seleccionables del lugar del servicio.
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

    // La dirección recién agregada se conserva si el listado aún no la trae.
    final justAdded = _justAddedAddress;
    if (justAdded != null &&
        !addresses.any((a) => _addressId(a) == _addressId(justAdded))) {
      addresses.add(justAdded);
    }

    safeSetState(() {
      _addresses = addresses;
      _isLoadingAddresses = false;
      // Si la dirección elegida ya no existe se limpia la selección.
      if (_selectedAddressId != null &&
          !addresses.any((a) => _addressId(a) == _selectedAddressId)) {
        _selectedAddressId = null;
      }
    });
  }

  String? _str(dynamic value) =>
      (value is String && value.trim().isNotEmpty) ? value.trim() : null;

  String? _addressId(Map<String, dynamic> address) =>
      _str(address['id']) ?? _str(address['addressId']);

  /// Etiqueta visible de una dirección. El backend no garantiza una clave única
  /// para el alias, así que se prueban las habituales y se cae a la dirección.
  String _addressLabel(Map<String, dynamic> address) =>
      _str(address['name']) ??
      _str(address['label']) ??
      _str(address['nickname']) ??
      _str(address['alias']) ??
      _str(address['address']) ??
      _str(address['fullAddress']) ??
      'Ubicación registrada';

  bool get _hasDescription =>
      (_model.textController?.text.trim().isNotEmpty) ?? false;

  /// Regla del botón [Enviar]: inactivo hasta que haya descripción **y** un
  /// lugar de servicio seleccionado (las fotos son opcionales).
  bool get _canSubmit =>
      _hasDescription && _selectedAddressId != null && !_model.isSubmitting;

  /// Elige el lugar del servicio. No navega: los botones de las propiedades son
  /// sólo de selección.
  void _selectAddress(String addressId) {
    safeSetState(() => _selectedAddressId = addressId);
  }

  /// Acción permanente "Otra ubicación": lleva al alta de dirección, que valida
  /// que esté dentro de la zona de servicio de DOVIA (Coverage Check). Al volver
  /// se recarga el listado y la nueva dirección queda seleccionada.
  Future<void> _addOtherLocation() async {
    DHCLIENTUbicacionWidget.pendingNextRoute =
        DHCLIENTCotizacionWidget.routeName;
    await context.pushNamed(DHCLIENTUbicacionWidget.routeName);
    if (!mounted) return;

    final verifiedId = DHCLIENTCotizacionWidget.verifiedAddressId;
    final verifiedLabel = DHCLIENTCotizacionWidget.verifiedAddressLabel;
    DHCLIENTCotizacionWidget.verifiedAddressId = null;
    DHCLIENTCotizacionWidget.verifiedAddressLabel = null;

    // Si el cliente canceló no hay dirección verificada y la selección previa se
    // mantiene intacta.
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

  Future<void> _pickPhotos() async {
    // Selector nativo: Cámara / Galería.
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
      pickerFontFamily: 'Public Sans',
    );
    if (selectedMedia == null ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }
    safeSetState(() => _model.isPhotoUploading = true);
    try {
      final files = selectedMedia
          .map((m) => FFUploadedFile(
                name: m.storagePath.split('/').last,
                bytes: m.bytes,
                height: m.dimensions?.height,
                width: m.dimensions?.width,
                blurHash: m.blurHash,
                originalFilename: m.originalFilename,
              ))
          .toList();
      safeSetState(() => _model.uploadedPhotos.addAll(files));
    } finally {
      safeSetState(() => _model.isPhotoUploading = false);
    }
  }

  /// Sube la evidencia a S3 con el flujo presign → PUT → confirm. Es best-effort:
  /// la solicitud ya existe, así que un fallo de fotos no invalida la cotización.
  Future<void> _uploadPhotos(String serviceRequestId) async {
    final photos = _model.uploadedPhotos;
    if (photos.isEmpty) return;

    final uploads = <Map<String, dynamic>>[];
    for (var i = 0; i < photos.length; i++) {
      uploads.add({
        'clientUploadId': 'upload_$i',
        'contentType': 'image/jpeg',
        'fileName': photos[i].name ?? 'foto_$i.jpg',
      });
    }

    final presignRes =
        await DOVIAAPIDoviaHomeContextGroup.presignServiceRequestImagesCall.call(
      serviceRequestId: serviceRequestId,
      uploads: uploads,
      authToken: currentAuthenticationToken ?? '',
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
      authToken: currentAuthenticationToken ?? '',
    );
  }

  /// Crea la solicitud de cotización: queda en "Pendiente de Cotización" y se
  /// distribuye a la red de empresas proveedoras. Luego redirige al Dashboard.
  Future<void> _submit() async {
    final addressId = _selectedAddressId;
    if (addressId == null) return;

    safeSetState(() => _model.isSubmitting = true);
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.createQuoteServiceRequestCall.call(
        description: _model.textController!.text.trim(),
        addressId: addressId,
        authToken: currentAuthenticationToken ?? '',
      );

      if (!response.succeeded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No se pudo enviar la solicitud de cotización. Intenta de nuevo.'),
            ),
          );
        }
        return;
      }

      final serviceRequestId = DOVIAAPIDoviaHomeContextGroup
          .createQuoteServiceRequestCall
          .id(response.jsonBody);
      if (serviceRequestId != null && serviceRequestId.isNotEmpty) {
        await _uploadPhotos(serviceRequestId);
      }

      if (!mounted) return;

      // La solicitud recién creada se refleja en "Próximas visitas" del
      // Dashboard con el estatus de cotización pendiente.
      DHCLIENTHomepageWidget.upcomingVisits.insert(
        0,
        const ScheduledVisit(
          service: 'Solicitud de cotización',
          date: 'En evaluación',
          time: 'proveedores DOVIA',
          status: DHCLIENTCotizacionWidget.pendingQuoteStatus,
        ),
      );

      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
            child: DHCLIENTExitoProgramarAgendaWidget(
              message:
                  'Enviamos tu requerimiento a la red de proveedores DOVIA. Recibirás las propuestas en la plataforma.',
            ),
          );
        },
      );
      if (mounted) {
        context.goNamed(DHCLIENTHomepageWidget.routeName);
      }
    } finally {
      if (mounted) {
        safeSetState(() => _model.isSubmitting = false);
      }
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
                  // Cabecera con el título y el ícono de Chat habilitado.
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      title: 'Cotización',
                      showMap: false,
                      showCurrency: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Cuéntanos que necesitas'),
                        const SizedBox(height: 12.0),
                        _descriptionField(),
                        const SizedBox(height: 18.0),
                        _sectionLabel('Agregar fotos'),
                        const SizedBox(height: 10.0),
                        Text(
                          'Las imágenes nos ayudan a asignarte el técnico adecuado y darte un mejor servicio.',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.publicSans(),
                                    color: const Color(0xFF00444B),
                                    fontSize: 14.0,
                                    letterSpacing: 0.28,
                                  ),
                        ),
                        const SizedBox(height: 12.0),
                        _photoDropZone(),
                        if (_model.uploadedPhotos.isNotEmpty)
                          _buildPhotoThumbnails(),
                        const SizedBox(height: 24.0),
                        _locationSelector(),
                        const SizedBox(height: 30.0),
                        _submitButton(),
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

  // ---------------------------------------------------------------------------
  // Formulario de requerimientos.
  // ---------------------------------------------------------------------------

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: const Color(0xFF00444B),
            fontSize: 16.0,
            letterSpacing: 0.32,
          ),
    );
  }

  /// Descripción del requerimiento: campo de texto libre obligatorio.
  Widget _descriptionField() {
    return TextFormField(
      controller: _model.textController,
      focusNode: _model.textFieldFocusNode,
      autofocus: false,
      obscureText: false,
      minLines: 3,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        isDense: true,
        hintText:
            'Describe el problema o el trabajo que deseas realizar. Mientras más claro, mejor podemos ayudarte',
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.publicSans(),
              color: const Color(0x80888888),
              fontSize: 16.0,
              letterSpacing: 0.32,
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
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsetsDirectional.fromSTEB(15.0, 20.0, 15.0, 20.0),
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: const Color(0xFF00444B),
            fontSize: 16.0,
            letterSpacing: 0.32,
          ),
      textAlign: TextAlign.start,
      cursorColor: FlutterFlowTheme.of(context).primaryText,
      validator: _model.textControllerValidator.asValidator(context),
    );
  }

  /// Zona de carga multimedia. Al tapear abre el selector nativo (Cámara/Galería).
  /// El asset ya trae la caja completa (fondo + ícono), igual que en el resto
  /// de la app (subir_archivo, reportar_problema, materiales, etc.).
  Widget _photoDropZone() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      onTap: _model.isPhotoUploading ? null : _pickPhotos,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: SvgPicture.asset(
              'assets/images/AddMediaImage.svg',
              width: double.infinity,
              height: 104.0,
              fit: BoxFit.cover,
            ),
          ),
          if (_model.isPhotoUploading)
            const SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Color(0xFF007376),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnails() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: List.generate(_model.uploadedPhotos.length, (index) {
          final photo = _model.uploadedPhotos[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: photo.bytes != null
                    ? Image.memory(
                        photo.bytes!,
                        width: 90.0,
                        height: 90.0,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 90.0,
                        height: 90.0,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
              ),
              Positioned(
                top: 4.0,
                right: 4.0,
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () =>
                      safeSetState(() => _model.uploadedPhotos.removeAt(index)),
                  child: Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: const BoxDecoration(
                      color: Color(0xCC000000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Selector de ubicación (regla de cobertura).
  // ---------------------------------------------------------------------------

  Widget _locationSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el lugar del servicio',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: const Color(0xFF00444B),
                fontSize: 17.0,
                letterSpacing: 0.34,
                lineHeight: 1.29,
              ),
        ),
        const SizedBox(height: 12.0),
        if (_isLoadingAddresses)
          _locationOption(label: 'Cargando…', selected: false, onTap: null)
        else ...[
          // Una opción por propiedad registrada: tocarlas sólo selecciona.
          for (final address in _addresses)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
              child: _locationOption(
                label: _addressLabel(address),
                selected: _selectedAddressId == _addressId(address),
                onTap: () => _selectAddress(_addressId(address)!),
              ),
            ),
          if (_addresses.isEmpty)
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
              child: Text(
                'Todavía no tienes una ubicación registrada. Agrega una para verificar su cobertura.',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.publicSans(),
                      color: const Color(0xFF6A6A6A),
                      fontSize: 12.0,
                      lineHeight: 1.3,
                    ),
              ),
            ),
        ],
        // Acción permanente: siempre disponible para dar de alta otra ubicación,
        // sin importar cuántas propiedades ya tenga el cliente.
        _addLocationButton(),
      ],
    );
  }

  /// Botón de selección tipo radio button visual (borde aqua; relleno al elegir).
  Widget _locationOption({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 42.0),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF007376) : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: enabled ? const Color(0xFF007376) : const Color(0xFFDFDFDF),
            width: 1.5,
          ),
        ),
        padding:
            const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: selected
                    ? Colors.white
                    : (enabled
                        ? const Color(0xFF007376)
                        : const Color(0xFF6A6A6A)),
                fontSize: 14.0,
              ),
        ),
      ),
    );
  }

  /// Acción "Otra ubicación": no es una opción seleccionable, sino el acceso al
  /// alta de una dirección nueva. Se diferencia visualmente con el ícono [+] y
  /// un borde tenue para que no se confunda con los botones de las propiedades.
  Widget _addLocationButton() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(25.0),
      onTap: () async => _addOtherLocation(),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 42.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: const Color(0xFFDFDFDF), width: 1.5),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Color(0xFF007376), size: 18.0),
            const SizedBox(width: 8.0),
            Text(
              'Otra ubicación',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    color: const Color(0xFF007376),
                    fontSize: 14.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón inferior [Enviar]: inactivo hasta que haya descripción y ubicación.
  Widget _submitButton() {
    return FFButtonWidget(
      onPressed: _canSubmit ? () async => _submit() : null,
      text: _model.isSubmitting ? 'Enviando…' : 'Enviar',
      options: FFButtonOptions(
        width: double.infinity,
        height: 50.0,
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: const Color(0xFF007376),
        disabledColor: const Color(0xFFDFDFDF),
        disabledTextColor: const Color(0xFF6A6A6A),
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: Colors.white,
              fontSize: 17.0,
              letterSpacing: 0.34,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(100.0),
      ),
    );
  }
}
