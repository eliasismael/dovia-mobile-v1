import '/dovia_home_client/d_h_c_l_i_e_n_t_material_aprobado/d_h_c_l_i_e_n_t_material_aprobado_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'd_h_c_l_i_e_n_t_materiales_model.dart';
export 'd_h_c_l_i_e_n_t_materiales_model.dart';

/// Superficie de las cajas de solo lectura del diseño (#FAFAFA).
const Color _kReadOnlySurface = Color(0xFFFAFAFA);

/// Placeholder de foto del diseño cuando el asociado no cargó evidencia.
const Color _kPhotoPlaceholder = Color(0xFFD9D9D9);

/// Fondo del banner informativo (rgba(112,172,173,0.2) del diseño).
const Color _kInfoBanner = Color(0x3570ACAD);

/// Solicitud de materiales adicionales que el Home Associate cargó desde su
/// app, en **modo lectura** para el Cliente con un servicio en curso.
///
/// El cliente ve qué material se necesita, su precio de referencia y las fotos
/// de dónde se usará, y decide:
/// - [Rechazar] → `POST /dovia-home/service-requests/{id}/extra-materials/reject`
///   (el asociado evalúa si puede terminar el trabajo sin el material).
/// - [Pagar] → `POST /dovia-home/service-requests/{id}/extra-materials/accept`.
///   Es una **pre-autorización**: el cliente acepta el recargo futuro, que DOVIA
///   ejecuta recién después de validar la factura que suba el asociado. Por eso
///   no se abre ningún checkout aunque el endpoint devuelva una orden de pago.
///
/// Los datos se leen best-effort (el shape del backend es incierto) para que la
/// pantalla renderice siempre lo que el asociado sí envió.
class DHCLIENTMaterialesWidget extends StatefulWidget {
  const DHCLIENTMaterialesWidget({super.key, this.serviceRequestId});

  final String? serviceRequestId;

  static String routeName = 'DH_CLIENT_Materiales';
  static String routePath = '/dHCLIENTMateriales';

  /// Servicio en curso cuya solicitud de materiales se está revisando. Se
  /// inyecta antes de navegar, porque go_router navega sólo por nombre (misma
  /// convención que [DHCLIENTCasaAWidget.requestData]). Tiene prioridad el valor
  /// del constructor cuando la página se instancia directamente.
  static String? serviceRequestIdRef;

  /// Datos ya conocidos de la solicitud (los mismos que devuelve
  /// `GET /dovia-home/service-requests/{id}`). Cuando se inyectan, la pantalla
  /// pinta de entrada y refresca contra el backend si hay id.
  static Map<String, dynamic>? requestData;

  @override
  State<DHCLIENTMaterialesWidget> createState() =>
      _DHCLIENTMaterialesWidgetState();
}

class _DHCLIENTMaterialesWidgetState extends State<DHCLIENTMaterialesWidget> {
  late DHCLIENTMaterialesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Último detalle del servicio conocido. Además de la solicitud de materiales
  /// trae al asociado asignado, que es con quien el cliente consulta desde el
  /// ícono de chat.
  Map<String, dynamic>? _serviceData;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTMaterialesModel());

    // Lo ya inyectado se pinta sin esperar al backend; el fetch sólo refresca.
    _applyData(DHCLIENTMaterialesWidget.requestData);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRequest());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Lectura de la solicitud.
  // ---------------------------------------------------------------------------

  /// Servicio a consultar: el del constructor si la página se instanció
  /// directamente, si no el inyectado antes de navegar.
  String? get _serviceRequestId {
    for (final candidate in [
      widget.serviceRequestId,
      DHCLIENTMaterialesWidget.serviceRequestIdRef,
    ]) {
      if (candidate != null && candidate.isNotEmpty) return candidate;
    }
    return null;
  }

  Future<void> _loadRequest() async {
    final serviceRequestId = _serviceRequestId;
    if (serviceRequestId == null) {
      // Sin servicio asociado no hay solicitud que leer: la pantalla se queda
      // con lo inyectado en lugar de mostrar contenido inventado.
      if (mounted) safeSetState(() {});
      return;
    }

    safeSetState(() {
      _model.isLoading = true;
      _model.loadFailed = false;
    });
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.getServiceRequestCall.call(
        serviceRequestId: serviceRequestId,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        safeSetState(() => _model.loadFailed = true);
        return;
      }

      final data = _asMap(getJsonField(response.jsonBody, r'''$.data''')) ??
          _asMap(response.jsonBody);
      safeSetState(() => _applyData(data));
    } catch (_) {
      if (mounted) safeSetState(() => _model.loadFailed = true);
    } finally {
      if (mounted) safeSetState(() => _model.isLoading = false);
    }
  }

  /// Vuelca sobre el modelo la solicitud de materiales contenida en el detalle
  /// del servicio. No pisa lo ya cargado con vacíos: si una lectura posterior
  /// no trae un campo, se conserva el anterior.
  void _applyData(Map<String, dynamic>? data) {
    if (data != null) _serviceData = data;

    final materials = _extraMaterialsOf(data);
    if (materials == null) return;

    final text = _firstString([
      materials['requestedMaterials'],
      materials['materials'],
      materials['description'],
      materials['details'],
      materials['notes'],
    ]);
    if (text != null) _model.materialText = text;

    final price = _formattedPrice(materials);
    if (price != null) _model.estimatedPrice = price;

    final urls = _imageUrlsOf(materials);
    if (urls.isNotEmpty) _model.imageUrls = urls;

    final status = _firstString([
      materials['materialsStatus'],
      materials['status'],
      materials['subStatus'],
    ]);
    if (status != null) _model.materialsStatus = status.toUpperCase();
  }

  Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  /// Bloque de materiales extra dentro del detalle del servicio. El backend lo
  /// puede anidar bajo varias claves y, cuando manda un historial, la vigente es
  /// la última. Si el Map recibido ya es la solicitud en sí (Ej: lo inyectó la
  /// notificación), se usa tal cual.
  Map<String, dynamic>? _extraMaterialsOf(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in [
      'extraMaterials',
      'extraMaterialsRequest',
      'extraMaterialsRequests',
      'materialsRequest',
      'materials',
    ]) {
      final value = data[key];
      final map = _asMap(value);
      if (map != null) return map;
      if (value is List && value.isNotEmpty) {
        final last = _asMap(value.last);
        if (last != null) return last;
      }
    }
    // Fallback: el propio Map es la solicitud de materiales.
    return data.containsKey('requestedMaterials') ? data : null;
  }

  String? _firstString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  /// Monto numérico de la primera clave usable. Tolera que el backend mande el
  /// precio como texto ("Q1,200.00").
  num? _amount(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is num) return candidate;
      if (candidate is String) {
        final cleaned =
            candidate.replaceAll(RegExp(r'[^0-9.\-]'), '').replaceAll(',', '');
        final parsed = num.tryParse(cleaned);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  /// Precio de referencia con su moneda. Los materiales extra se cotizan en GTQ
  /// (ver `AdminQuoteExtraMaterialsCall`), así que es el default.
  String? _formattedPrice(Map<String, dynamic> materials) {
    final amount = _amount([
      materials['estimatedAmount'],
      materials['estimatedPrice'],
      materials['estimatedCost'],
      materials['totalAmount'],
      materials['amount'],
      materials['price'],
    ]);
    if (amount == null) return null;
    final currency = _firstString([materials['currency']]) ?? 'GTQ';
    return _formatAmount(amount, currency);
  }

  String _formatAmount(num amount, String currency) {
    final rounded = (amount * 100).round() / 100;
    final fixed = rounded.toStringAsFixed(2);
    final parts = fixed.split('.');
    final grouped = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    final body = parts[1] == '00' ? grouped : '$grouped.${parts[1]}';
    return currency.toUpperCase() == 'GTQ' ? 'Q$body' : '$currency $body';
  }

  /// Fotos que el asociado subió al pedir el material. El backend las devuelve
  /// en `images` (mismo nombre con el que confirma la subida); se aceptan tanto
  /// URLs sueltas como items con la URL anidada.
  List<String> _imageUrlsOf(Map<String, dynamic> materials) {
    for (final key in ['images', 'imageUrls', 'photos', 'media']) {
      final value = materials[key];
      if (value is! List) continue;
      final urls = value.map(_imageUrlOf).whereType<String>().toList();
      if (urls.isNotEmpty) return urls;
    }
    return [];
  }

  String? _imageUrlOf(dynamic item) {
    if (item is String) return item.trim().isEmpty ? null : item.trim();
    final map = _asMap(item);
    if (map == null) return null;
    return _firstString([
      map['url'],
      map['imageUrl'],
      map['signedUrl'],
      map['downloadUrl'],
      map['publicUrl'],
    ]);
  }

  // ---------------------------------------------------------------------------
  // Estado de la decisión.
  // ---------------------------------------------------------------------------

  /// Estatus en los que la solicitud sigue esperando al cliente. Cualquier otro
  /// (aceptada, rechazada, pagada) deja la pantalla como consulta, sin volver a
  /// ofrecer los botones. Mientras el estatus no se leyó (null) se asume
  /// pendiente, para no bloquear al cliente por una lectura fallida.
  static const Set<String> _pendingStatuses = {
    'PENDING',
    'REQUESTED',
    'CLIENT_APPROVAL_PENDING',
    'QUOTED',
    'AWAITING_CLIENT',
  };

  bool get _decisionTaken =>
      _model.materialsStatus != null &&
      !_pendingStatuses.contains(_model.materialsStatus);

  bool get _isRejected => (_model.materialsStatus ?? '').contains('REJECT');

  // ---------------------------------------------------------------------------
  // Acciones.
  // ---------------------------------------------------------------------------

  /// El cliente deniega la compra. El backend notifica al asociado para que
  /// evalúe si puede terminar el trabajo sin el material o si debe finalizar el
  /// servicio de forma incompleta.
  Future<void> _rechazar() async {
    final serviceRequestId = _serviceRequestId;
    if (serviceRequestId == null) {
      _showMessage('No se encontró el servicio de esta solicitud.');
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.rejectExtraMaterialsCall.call(
        serviceRequestId: serviceRequestId,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage('No se pudo rechazar la compra. Intenta de nuevo.');
        return;
      }

      safeSetState(() => _model.materialsStatus = 'REJECTED');
      _showMessage('Rechazaste la compra. Le avisamos al asociado.');
      // Vuelve al estado del servicio en curso.
      Navigator.pop(context);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// El cliente pre-autoriza la compra: acepta el recargo futuro a su método de
  /// pago, que se ejecuta cuando DOVIA valide la factura del asociado.
  Future<void> _pagar() async {
    final serviceRequestId = _serviceRequestId;
    if (serviceRequestId == null) {
      _showMessage('No se encontró el servicio de esta solicitud.');
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.acceptExtraMaterialsCall.call(
        serviceRequestId: serviceRequestId,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage('No se pudo aprobar el material. Intenta de nuevo.');
        return;
      }

      safeSetState(() => _model.materialsStatus = 'ACCEPTED');

      // El pop-up se cierra solo; al cerrarse, el asociado ya tiene luz verde
      // para ir a comprar y el cliente vuelve al estado de su servicio.
      await _showAprobadoPopup();
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// Pop-up central de confirmación, que se cierra solo a los 2.5s.
  Future<void> _showAprobadoPopup() async {
    var closed = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (closed || !dialogContext.mounted) return;
          closed = true;
          Navigator.of(dialogContext).pop();
        });
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          alignment: Alignment.center,
          // El pop-up es un Stack con un Align adentro (el check). Con alto
          // acotado ese Align se estira a todo el alto disponible y la tarjeta
          // queda pegada arriba; el Column min lo deja sin acotar para que el
          // Stack mida lo que mide la tarjeta y quede centrada en pantalla.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [DHCLIENTMaterialAprobadoWidget()],
          ),
        );
      },
    );
    closed = true;
  }

  /// Teléfono del asociado asignado al servicio, para las consultas rápidas del
  /// cliente mientras el trabajo está en curso.
  String? get _associatePhone {
    final associate = _asMap(_serviceData?['associate'] ??
        _serviceData?['assignedAssociate'] ??
        _serviceData?['homeAssociate']);
    return _firstString([
      associate?['phoneNumber'],
      associate?['phone'],
      associate?['mobile'],
      _serviceData?['associatePhone'],
    ]);
  }

  /// Consulta rápida al asociado que está en la casa. El canal de contacto de la
  /// app es WhatsApp (igual que en la tarjeta del profesional); sin teléfono
  /// conocido cae al soporte de DOVIA en vez de dejar el ícono muerto.
  Future<void> _contactAssociate() async {
    final phone = _associatePhone;
    if (phone != null) {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri.parse('https://wa.me/$cleanPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
      if (!mounted) return;
      _showMessage('No se pudo abrir WhatsApp');
      return;
    }

    if (!mounted) return;
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: const DoviaSupportWidget(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Abre una foto de la evidencia en pantalla completa (pinch para acercar,
  /// tap para cerrar).
  void _openPhoto(String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    size: 100.0,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(dialogContext).padding.top + 10.0,
              right: 20.0,
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 24.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI.
  // ---------------------------------------------------------------------------

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
                  // El ícono de chat queda habilitado para que el cliente pueda
                  // consultarle al asociado que está en su casa.
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: DOVIASHAREDHeaderWidget(
                      title: 'Materiales',
                      showMap: false,
                      showCurrency: false,
                      onChatTap: _contactAssociate,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 13.0, 20.0, 120.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _screenTitle(),
                        const SizedBox(height: 18.0),
                        if (_model.isLoading && _model.materialText == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          _sectionLabel('Material'),
                          const SizedBox(height: 12.0),
                          _readOnlyBox(_model.materialText, hint: _materialHint),
                          const SizedBox(height: 18.0),
                          _sectionLabel('Precio estimado'),
                          const SizedBox(height: 12.0),
                          _readOnlyBox(
                            _model.estimatedPrice,
                            hint: 'Sin precio de referencia',
                          ),
                          const SizedBox(height: 18.0),
                          _sectionLabel(
                              'Fotografía de donde se usará el material'),
                          const SizedBox(height: 12.0),
                          _photosCard(),
                        ],
                        const SizedBox(height: 18.0),
                        _infoBanner(),
                        const SizedBox(height: 30.0),
                        if (_decisionTaken) _decisionTakenNotice() else _actions(),
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

  /// Placeholder del campo Material: distingue "no se pudo leer" de "el asociado
  /// no escribió nada", para que el cliente no crea que la solicitud vino vacía.
  String get _materialHint => _model.loadFailed
      ? 'No pudimos cargar la solicitud. Intenta de nuevo más tarde.'
      : 'El asociado no detalló el material.';

  Widget _screenTitle() => Align(
        alignment: const AlignmentDirectional(-1.0, 0.0),
        child: Text(
          'Materiales necesarios para completar el trabajo',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                fontSize: 17.0,
                letterSpacing: 0.34,
                fontWeight: FontWeight.w600,
                lineHeight: 1.3,
              ),
        ),
      );

  Widget _sectionLabel(String text) => Align(
        alignment: const AlignmentDirectional(-1.0, 0.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 16.0,
                letterSpacing: 0.32,
              ),
        ),
      );

  /// Campo bloqueado (solo lectura): el cliente consulta lo que cargó el
  /// asociado, no lo edita. Reemplaza al TextFormField del diseño.
  Widget _readOnlyBox(String? value, {required String hint}) {
    final hasValue = value != null && value.isNotEmpty;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 42.0),
      decoration: BoxDecoration(
        color: _kReadOnlySurface,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
      alignment: const AlignmentDirectional(-1.0, 0.0),
      child: Text(
        hasValue ? value : hint,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              fontSize: 16.0,
              letterSpacing: 0.32,
              color: hasValue
                  ? FlutterFlowTheme.of(context).primaryText
                  : FlutterFlowTheme.of(context).secondaryText,
            ),
      ),
    );
  }

  /// Tira horizontal de miniaturas dentro de la caja gris del diseño. En mobile
  /// se scrollea en vez de repartir las 5 fotos a lo ancho.
  Widget _photosCard() {
    final urls = _model.imageUrls;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kReadOnlySurface,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        height: 100.0,
        child: urls.isEmpty
            ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                itemBuilder: (_, __) => _photoPlaceholder(),
              )
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                itemBuilder: (context, i) => InkWell(
                  onTap: () => _openPhoto(urls[i]),
                  borderRadius: BorderRadius.circular(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      urls[i],
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _photoPlaceholder(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _photoPlaceholder() => Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: _kPhotoPlaceholder,
          borderRadius: BorderRadius.circular(8.0),
        ),
      );

  /// Aviso legal y operativo: setea la expectativa de cobro antes de decidir.
  /// Las tres reglas van como líneas separadas (igual que el diseño) en vez de
  /// un único bloque de texto, para que el salto entre reglas no se confunda
  /// con el wrap de una regla larga en pantallas angostas.
  Widget _infoBanner() => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kInfoBanner,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bannerRule(
              'Para completar el trabajo, necesitamos adquirir materiales adicionales.',
            ),
            const SizedBox(height: 10.0),
            _bannerRule(
              'El precio mostrado es una referencia; el monto final dependerá del costo real en tienda.',
            ),
            const SizedBox(height: 10.0),
            _bannerRule(
              'El asociado comprará los materiales, cargará la factura y — tras verificación — se aplicará el cobro correspondiente a tu cuenta.',
            ),
          ],
        ),
      );

  Widget _bannerRule(String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              fontSize: 16.0,
              letterSpacing: 0.0,
              lineHeight: 1.3,
            ),
      );

  /// [Rechazar] outline + [Pagar] primario, del mismo ancho.
  Widget _actions() {
    final busy = _model.isSubmitting;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FFButtonWidget(
            onPressed: busy ? null : _rechazar,
            text: 'Rechazar',
            options: FFButtonOptions(
              height: 42.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
              iconPadding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).secondaryBackground,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              elevation: 0.0,
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: FFButtonWidget(
            onPressed: busy ? null : _pagar,
            text: 'Pagar',
            options: FFButtonOptions(
              height: 42.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
              iconPadding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                    color: Colors.white,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              elevation: 0.0,
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ],
    );
  }

  /// Con la decisión ya tomada la pantalla queda como consulta, sin volver a
  /// ofrecer los botones.
  Widget _decisionTakenNotice() => Text(
        _isRejected
            ? 'Rechazaste esta compra de materiales. El asociado ya fue notificado.'
            : 'Aprobaste el material extra: el asociado ya puede comprarlo para completar el trabajo.',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
      );
}
