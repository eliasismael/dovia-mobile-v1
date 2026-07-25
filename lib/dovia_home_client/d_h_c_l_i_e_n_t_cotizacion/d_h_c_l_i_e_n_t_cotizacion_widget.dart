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

/// Lugar del servicio elegido por el cliente.
enum _ServiceLocation { mainProperty, otherLocation }

class _DHCLIENTCotizacionWidgetState extends State<DHCLIENTCotizacionWidget> {
  late DHCLIENTCotizacionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Opción seleccionada en "Selecciona el lugar del servicio". Null = ninguna,
  /// por lo que el botón [Enviar] permanece inactivo.
  _ServiceLocation? _selectedLocation;

  /// Propiedad principal registrada del cliente (primera dirección de servicio).
  /// Da el nombre dinámico del primer botón; si no hay ninguna se usa 'Casa A'.
  Map<String, dynamic>? _mainAddress;
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCotizacionModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    // Rehabilita el botón [Enviar] en tiempo real según haya descripción.
    _model.textController!.addListener(_onDescriptionChanged);

    // El cliente volvió del flujo de "Otra ubicación" con una dirección que ya
    // pasó el Coverage Check: queda seleccionada al reconstruirse la pantalla.
    if (DHCLIENTCotizacionWidget.verifiedAddressId != null) {
      _selectedLocation = _ServiceLocation.otherLocation;
    }

    _loadMainAddress();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.textController?.removeListener(_onDescriptionChanged);
    _model.dispose();

    super.dispose();
  }

  void _onDescriptionChanged() => safeSetState(() {});

  /// Trae las direcciones de servicio del cliente para nombrar dinámicamente la
  /// propiedad principal (Ej: "Casa A") y poder enviar su `addressId`.
  Future<void> _loadMainAddress() async {
    final response =
        await DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall.call(
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    Map<String, dynamic>? main;
    if (response.succeeded) {
      final addresses = DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall
              .addressesList(response.jsonBody) ??
          [];
      final typed = addresses.whereType<Map>().toList();
      if (typed.isNotEmpty) {
        main = Map<String, dynamic>.from(typed.first);
      }
    }
    safeSetState(() {
      _mainAddress = main;
      _isLoadingAddresses = false;
    });
  }

  String? _str(dynamic value) =>
      (value is String && value.trim().isNotEmpty) ? value.trim() : null;

  /// Nombre visible de la propiedad principal. El backend no garantiza una
  /// clave única para el alias, así que se prueban las habituales y se cae a la
  /// dirección; si no hay nada se usa el placeholder del diseño.
  String get _mainPropertyLabel =>
      _str(_mainAddress?['name']) ??
      _str(_mainAddress?['label']) ??
      _str(_mainAddress?['nickname']) ??
      _str(_mainAddress?['alias']) ??
      _str(_mainAddress?['address']) ??
      'Casa A';

  String? get _mainPropertyId =>
      _str(_mainAddress?['id']) ?? _str(_mainAddress?['addressId']);

  /// Etiqueta del botón "Otra ubicación": una vez verificada la cobertura pasa a
  /// mostrar la dirección elegida.
  String get _otherLocationLabel =>
      DHCLIENTCotizacionWidget.verifiedAddressLabel ?? 'Otra ubicación';

  /// `addressId` que se enviará al backend según la opción seleccionada.
  String? get _selectedAddressId {
    switch (_selectedLocation) {
      case _ServiceLocation.mainProperty:
        return _mainPropertyId;
      case _ServiceLocation.otherLocation:
        return DHCLIENTCotizacionWidget.verifiedAddressId;
      case null:
        return null;
    }
  }

  bool get _hasDescription =>
      (_model.textController?.text.trim().isNotEmpty) ?? false;

  /// Regla del botón [Enviar]: inactivo hasta que haya descripción **y** un
  /// lugar de servicio seleccionado (las fotos son opcionales).
  bool get _canSubmit =>
      _hasDescription &&
      _selectedLocation != null &&
      _selectedAddressId != null &&
      !_model.isSubmitting;

  /// Selecciona la propiedad principal registrada.
  void _selectMainProperty() {
    safeSetState(() => _selectedLocation = _ServiceLocation.mainProperty);
  }

  /// "Otra ubicación": dispara el Coverage Check. Se envía al cliente a la
  /// pantalla de ubicación, que valida que la nueva dirección esté dentro de la
  /// zona de servicio de DOVIA y recién entonces la deja disponible aquí.
  void _selectOtherLocation() {
    safeSetState(() => _selectedLocation = _ServiceLocation.otherLocation);
    DHCLIENTUbicacionWidget.pendingNextRoute =
        DHCLIENTCotizacionWidget.routeName;
    // Al volver se refresca para reflejar la dirección ya verificada (o dejar el
    // botón [Enviar] inactivo si el cliente canceló).
    context
        .pushNamed(DHCLIENTUbicacionWidget.routeName)
        .then((_) => safeSetState(() {}));
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

      // Limpia la dirección verificada para no arrastrarla a la próxima
      // solicitud.
      DHCLIENTCotizacionWidget.verifiedAddressId = null;
      DHCLIENTCotizacionWidget.verifiedAddressLabel = null;

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

  /// Zona de carga multimedia. Borde punteado + ícono + texto guía para que se
  /// distinga como una zona tocable, no un campo vacío. Al tapear abre el
  /// selector nativo (Cámara/Galería).
  Widget _photoDropZone() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      onTap: _model.isPhotoUploading ? null : _pickPhotos,
      child: CustomPaint(
        painter: const _DashedBorderPainter(
          color: Color(0xFF007376),
          borderRadius: 10.0,
        ),
        child: Container(
          width: double.infinity,
          height: 110.0,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: _model.isPhotoUploading
              ? const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Color(0xFF007376),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCCE3E4),
                        shape: BoxShape.circle,
                      ),
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: SvgPicture.asset(
                        'assets/images/AddMediaImage.svg',
                        width: 18.0,
                        height: 18.0,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF007376), BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Toca para agregar fotos',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.publicSans(
                                fontWeight: FontWeight.w600),
                            color: const Color(0xFF007376),
                            fontSize: 13.0,
                          ),
                    ),
                  ],
                ),
        ),
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
        _locationOption(
          label: _isLoadingAddresses ? 'Cargando…' : _mainPropertyLabel,
          selected: _selectedLocation == _ServiceLocation.mainProperty,
          onTap: (_isLoadingAddresses || _mainPropertyId == null)
              ? null
              : _selectMainProperty,
        ),
        const SizedBox(height: 20.0),
        _locationOption(
          label: _otherLocationLabel,
          selected: _selectedLocation == _ServiceLocation.otherLocation,
          onTap: _selectOtherLocation,
        ),
        // Sin propiedad registrada la única vía es "Otra ubicación", que valida
        // cobertura antes de habilitar el envío.
        if (!_isLoadingAddresses && _mainPropertyId == null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
            child: Text(
              'Todavía no tienes una propiedad registrada. Agrega una ubicación para verificar su cobertura.',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.publicSans(),
                    color: const Color(0xFF6A6A6A),
                    fontSize: 12.0,
                    lineHeight: 1.3,
                  ),
            ),
          ),
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
        height: 42.0,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF007376) : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: enabled ? const Color(0xFF007376) : const Color(0xFFDFDFDF),
            width: 1.5,
          ),
        ),
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

/// Borde punteado para marcar visualmente una zona de carga (drop zone), ya
/// que un borde sólido del mismo color de fondo la deja indistinguible de un
/// campo vacío.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final double borderRadius;
  final double strokeWidth = 1.5;
  final double dashWidth = 6.0;
  final double dashGap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashGap != dashGap;
}
