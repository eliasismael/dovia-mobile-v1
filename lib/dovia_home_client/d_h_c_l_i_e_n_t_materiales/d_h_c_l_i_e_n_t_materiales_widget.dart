import '/dovia_home_client/checkout_launcher.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_material_aprobado/d_h_c_l_i_e_n_t_material_aprobado_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/extra_materials_fields.dart';
import '/repositories/payments_repository.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/core/result.dart';
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
/// La pantalla sigue el estado de la solicitud
/// (`QUOTE_PENDING → QUOTE_SENT → PAYMENT_PENDING → PAID`, o `REJECTED`), porque
/// cada uno habilita una cosa distinta:
/// - `QUOTE_PENDING`: el asociado ya pidió el material pero DOVIA todavía no lo
///   cotizó. No hay nada que decidir.
/// - `QUOTE_SENT`: **el único estado con decisión del cliente.** Ya está el PDF
///   de la cotización, el detalle y el monto.
///   - [Rechazar] → `POST /dovia-home/service-requests/{id}/extra-materials/reject`
///     (el asociado evalúa si puede terminar el trabajo sin el material).
///   - [Pagar] → `POST /dovia-home/service-requests/{id}/extra-materials/accept`,
///     que **crea la orden y devuelve un checkout de Recurrente que hay que
///     abrir**. Aceptar no cobra: deja la solicitud en `PAYMENT_PENDING` hasta
///     que el webhook confirme el pago.
/// - `PAYMENT_PENDING`: hay una orden sin completar. Se reanuda con
///   `POST /payments/{paymentOrderId}/resume`; **no** se repite `accept`.
/// - `PAID` / `REJECTED`: terminales, sólo lectura.
///
/// Los campos se leen con [extra_materials_fields.dart], que es la única fuente
/// de verdad del contrato para esta pantalla y para el detalle del servicio.
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
  ///
  /// El estado sí se pisa siempre que llegue una solicitud: es el dato que
  /// decide qué acciones se ofrecen, y conservar el anterior dejaría botones
  /// vivos sobre una solicitud que ya avanzó.
  void _applyData(Map<String, dynamic>? data) {
    if (data != null) _serviceData = data;

    final materials = emLatestRequest(data);
    if (materials == null) return;

    _model.materialsStatus = emStatus(materials);
    _model.extraMaterialsId = emId(materials);
    _model.paymentOrderId = emPaymentOrderId(materials);

    final text = emRequestedMaterials(materials);
    if (text != null) _model.materialText = text;

    // Sólo hay monto, detalle y PDF a partir de QUOTE_SENT: antes `quote` es
    // null y estos tres quedan como estaban (null en la primera lectura).
    final price = emQuoteAmountLabel(materials);
    if (price != null) _model.estimatedPrice = price;

    final details = emQuoteDetails(materials);
    if (details != null) _model.quoteDetails = details;

    final documentUrl = emQuoteDocumentUrl(materials);
    if (documentUrl != null) _model.quoteDocumentUrl = documentUrl;

    final urls = emInstallationImageUrls(materials);
    if (urls.isNotEmpty) _model.imageUrls = urls;
  }

  Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String? _firstString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Estado de la decisión.
  //
  // Se resuelve contra el enum real de la solicitud de materiales. Mientras el
  // estatus no se leyó (null) se asume `QUOTE_PENDING`, que es el estado inicial
  // y el que menos supone: no habilita decidir ni da la solicitud por cerrada.
  // ---------------------------------------------------------------------------

  Map<String, dynamic> get _statusHolder => {
        'status': _model.materialsStatus ?? kExtraMaterialsQuotePending,
      };

  /// El cliente tiene la cotización sobre la mesa y le toca decidir. Es el único
  /// estado con botones.
  bool get _canDecide => emIsDecidable(_statusHolder);

  /// Aceptó y quedó una orden a medio pagar: lo que corresponde es retomar ese
  /// checkout, no volver a aceptar.
  bool get _awaitingPayment => emIsAwaitingPayment(_statusHolder);

  bool get _isRejected => emIsRejected(_statusHolder);

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

      // El rechazo finaliza el servicio; la solicitud queda REJECTED.
      safeSetState(() => _model.materialsStatus = kExtraMaterialsRejected);
      _showMessage('Rechazaste la compra. Le avisamos al asociado.');
      // Vuelve al estado del servicio en curso.
      Navigator.pop(context);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// El cliente acepta la cotización. Esto **no** cobra: crea una orden
  /// `EXTRA_MATERIALS` en GTQ y devuelve su checkout de Recurrente, que es lo
  /// que hay que abrir. La solicitud queda en `PAYMENT_PENDING` y sólo el
  /// webhook la lleva a `PAID` —por eso no se marca nada como pagado acá—.
  Future<void> _pagar() async {
    final serviceRequestId = _serviceRequestId;
    if (serviceRequestId == null) {
      _showMessage('No se encontró el servicio de esta solicitud.');
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final call = DOVIAAPIDoviaHomeContextGroup.acceptExtraMaterialsCall;
      final response = await call.call(
        serviceRequestId: serviceRequestId,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage('No se pudo aprobar el material. Intenta de nuevo.');
        return;
      }

      // Aceptada: a partir de acá la solicitud está esperando el pago, exista o
      // no checkout abierto. Guardarlo antes de abrir el navegador deja la
      // pantalla en el estado correcto aunque el cliente no complete el pago.
      safeSetState(() {
        _model.materialsStatus = kExtraMaterialsPaymentPending;
        _model.paymentOrderId = call.paymentOrderId(response.jsonBody);
      });

      final opened =
          await launchDoviaHomeCheckout(call.checkoutUrl(response.jsonBody));
      if (!mounted) return;

      if (!opened) {
        _showMessage(
          'Aprobaste el material, pero no pudimos abrir el pago. '
          'Vuelve a intentarlo desde aquí.',
        );
        return;
      }

      // El pop-up se cierra solo; al cerrarse, el cliente vuelve al estado de su
      // servicio y el pago sigue su curso en el navegador.
      await _showAprobadoPopup();
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// Retoma un checkout que quedó a medias (expirado, fallido o cancelado).
  ///
  /// Se reanuda la orden, **no** se repite `accept`: aceptar de nuevo una
  /// solicitud que ya está en `PAYMENT_PENDING` es un estado inválido. La
  /// reanudación crea una sucesora y reemplaza sólo el `paymentOrderId`; un
  /// éxito tardío de la orden anterior el backend lo ignora.
  Future<void> _reanudarPago() async {
    final paymentOrderId = _model.paymentOrderId;
    if (paymentOrderId == null || paymentOrderId.isEmpty) {
      // Sin la orden no hay nada que reanudar: se recarga para tomarla del
      // detalle en vez de crear un cobro nuevo por las dudas.
      _showMessage('No encontramos el pago pendiente. Actualizando…');
      await _loadRequest();
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final result = await context
          .read<PaymentsRepository>()
          .resumePayment(paymentOrderId: paymentOrderId);
      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          safeSetState(() => _model.paymentOrderId = data.id);
          final opened = await launchDoviaHomeCheckout(data.checkoutUrl);
          if (!mounted) return;
          if (!opened) {
            _showMessage('No pudimos abrir el pago. Intenta de nuevo.');
          }
        case Failure(:final message):
          _showMessage(message);
      }
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

  /// Abre el PDF de la cotización en el visor del sistema.
  Future<void> _openUrl(String? url) async {
    if (await launchDoviaHomeDocument(url)) return;
    if (!mounted) return;
    _showMessage('No se pudo abrir la cotización.');
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
                      showNotifications: true,
                      showSettings: true,
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
                          _readOnlyBox(_model.materialText,
                              hint: _materialHint),
                          const SizedBox(height: 18.0),
                          _sectionLabel('Precio cotizado'),
                          const SizedBox(height: 12.0),
                          _readOnlyBox(
                            _model.estimatedPrice,
                            hint: 'DOVIA todavía no cotizó estos materiales',
                          ),
                          if (_model.quoteDetails != null) ...[
                            const SizedBox(height: 18.0),
                            _sectionLabel('Detalle de la cotización'),
                            const SizedBox(height: 12.0),
                            _readOnlyBox(_model.quoteDetails, hint: ''),
                          ],
                          // El PDF es el documento sobre el que el cliente
                          // decide: se ofrece en cuanto DOVIA lo carga.
                          if (_model.quoteDocumentUrl != null) ...[
                            const SizedBox(height: 12.0),
                            _quoteDocumentLink(),
                          ],
                          const SizedBox(height: 18.0),
                          _sectionLabel(
                              'Fotografía de donde se usará el material'),
                          const SizedBox(height: 12.0),
                          _photosCard(),
                        ],
                        const SizedBox(height: 18.0),
                        _infoBanner(),
                        const SizedBox(height: 30.0),
                        _decisionArea(),
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

  /// Botón primario a ancho completo, con el mismo estilo que [Pagar].
  Widget _primaryAction(
          {required String text, required VoidCallback? onPressed}) =>
      FFButtonWidget(
        onPressed: onPressed,
        text: text,
        options: FFButtonOptions(
          width: double.infinity,
          height: 42.0,
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
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
      );

  /// Acceso al PDF de la cotización que cargó DOVIA.
  Widget _quoteDocumentLink() => Align(
        alignment: const AlignmentDirectional(-1.0, 0.0),
        child: InkWell(
          onTap: () => _openUrl(_model.quoteDocumentUrl),
          child: Text(
            'Ver cotización (PDF)',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 16.0,
                  letterSpacing: 0.32,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      );

  /// Qué se le ofrece al cliente según el estado de la solicitud. Cada estado
  /// habilita exactamente una cosa, y sólo `QUOTE_SENT` tiene decisión.
  Widget _decisionArea() {
    if (_canDecide) return _actions();
    if (_awaitingPayment) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _notice(
            'Aprobaste la compra y el pago quedó pendiente. Retómalo para que '
            'el asociado pueda comprar los materiales.',
          ),
          const SizedBox(height: 12.0),
          _primaryAction(
            text: _model.isSubmitting ? 'Abriendo…' : 'Continuar con el pago',
            onPressed: _model.isSubmitting ? null : _reanudarPago,
          ),
        ],
      );
    }
    return _notice(_settledMessage);
  }

  /// Texto de los estados sin acción por delante.
  String get _settledMessage {
    if (_isRejected) {
      return 'Rechazaste esta compra de materiales. El asociado ya fue notificado.';
    }
    if (emIsPaid(_statusHolder)) {
      return 'Pagaste los materiales: el asociado ya puede comprarlos para completar el trabajo.';
    }
    // QUOTE_PENDING: el asociado pidió el material y DOVIA todavía no lo cotizó.
    return 'DOVIA está preparando la cotización de estos materiales. Te avisamos apenas esté lista.';
  }

  Widget _notice(String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
      );
}
