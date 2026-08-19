import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/repositories/payments_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';

import 'd_h_c_l_i_e_n_t_costo_emergencia_model.dart';
export 'd_h_c_l_i_e_n_t_costo_emergencia_model.dart';

/// Pasarela de cobro condicional del servicio de emergencia ("Costo fijo mínimo
/// del trabajo"). Según el estatus de la cuenta renderiza:
/// - Premium (suscripción activa): tarjeta de descuento (35% OFF).
/// - Free (sin suscripción): tarjeta de pago regular + upsell.
///
/// Al confirmar el pago se **omite la selección de fecha/hora** (bypass de
/// calendario): se lanza directamente el modal de éxito y se redirige al
/// Dashboard, donde la solicitud aparece en "Próximas visitas" con estatus
/// "Pendiente" e indicador de alta prioridad (Emergencia).
class DHCLIENTCostoEmergenciaWidget extends StatefulWidget {
  const DHCLIENTCostoEmergenciaWidget({super.key});

  static String routeName = 'DH_CLIENT_CostoEmergencia';
  static String routePath = '/dHCLIENTCostoEmergencia';

  /// Categoría de emergencia elegida en la pantalla de Emergencias. Es
  /// obligatoria: el backend resuelve con ella el servicio de emergencia
  /// activo, así que sin categoría no hay solicitud que crear.
  static String? categoryId;

  /// Descripción del problema capturada en la pantalla de Emergencias.
  static String? description;

  /// Fotos opcionales adjuntadas en la pantalla de Emergencias. Se suben a la
  /// solicitud (presign → PUT → confirm) una vez creada.
  static List<FFUploadedFile> photos = [];

  /// Moneda del cobro. Todo el catálogo de DOVIA Home está en quetzales.
  static const String currency = 'GTQ';

  /// Precio base del servicio de emergencia (sin descuento).
  static const String basePrice = 'Q600';

  /// Precio final con descuento de suscripción (Premium).
  static const String discountedPrice = 'Q390';

  /// Porcentaje de descuento del plan.
  static const String discountLabel = '35% OFF';

  /// Ahorro exacto para la píldora informativa (Premium).
  static const String savingsAmount = 'Q210';

  /// Precio estándar completo (Free, pago por uso).
  static const String regularPrice = 'Q449';

  @override
  State<DHCLIENTCostoEmergenciaWidget> createState() =>
      _DHCLIENTCostoEmergenciaWidgetState();
}

class _DHCLIENTCostoEmergenciaWidgetState
    extends State<DHCLIENTCostoEmergenciaWidget> {
  late DHCLIENTCostoEmergenciaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Cómo se pagó (sólo aplica al escenario Free): null = sin pagar,
  /// 'direct' = pago por uso. Sólo se setea contra una respuesta de cobro
  /// exitosa: nunca se anticipa un pago que todavía no ocurrió.
  ///
  /// El caso "se suscribió" no vive acá: al volver de Planes se re-consulta la
  /// suscripción y, si quedó activa, la pantalla pasa al escenario Premium, que
  /// ya habilita [Siguiente] por sí solo.
  String? _paidMethod;

  bool get _isPaid => _paidMethod != null;

  /// Id de la solicitud de emergencia creada en el backend. Se crea una sola
  /// vez (al cobrar) y se reutiliza para adjuntar fotos y confirmar el pago.
  String? _serviceRequestId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCostoEmergenciaModel());

    // Asegura el estado de suscripción cargado (cacheado en el repo).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsRepository>().loadCurrentSubscription();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Crea la solicitud de emergencia (`POST /dovia-home/service-requests/
  /// emergencies`) con la descripción levantada en la pantalla anterior y la
  /// dirección de servicio del cliente, y le adjunta las fotos. Idempotente:
  /// si ya se creó en este paso devuelve el mismo id.
  Future<String?> _ensureServiceRequest() async {
    if (_serviceRequestId != null) return _serviceRequestId;

    final categoryId = DHCLIENTCostoEmergenciaWidget.categoryId;
    if (categoryId == null || categoryId.isEmpty) {
      _showError('Elige el tipo de emergencia para continuar.');
      return null;
    }

    final token = currentAuthenticationToken ?? '';
    final addressId = await _resolveAddressId(token);
    if (addressId == null) {
      _showError(
          'No encontramos una ubicación registrada para enviarte el técnico.');
      return null;
    }

    final response =
        await DOVIAAPIDoviaHomeContextGroup.createEmergencyServiceRequestCall
            .call(
      categoryId: categoryId,
      description: DHCLIENTCostoEmergenciaWidget.description ?? '',
      addressId: addressId,
      authToken: token,
    );
    if (!response.succeeded) {
      _showError(doviaHomeErrorMessage(response) ??
          'No se pudo registrar la emergencia. Intenta de nuevo.');
      return null;
    }

    final id = DOVIAAPIDoviaHomeContextGroup.createEmergencyServiceRequestCall
        .id(response.jsonBody);
    if (id == null || id.isEmpty) {
      _showError('No se pudo registrar la emergencia. Intenta de nuevo.');
      return null;
    }

    _serviceRequestId = id;
    await _uploadPhotos(id, token);
    return id;
  }

  /// Dirección de servicio a la que se envía el técnico: la que el cliente
  /// validó en el paso de Ubicación al entrar al flujo. El levantamiento de la
  /// emergencia no vuelve a pedirla (es urgente).
  ///
  /// Sólo si no hay ninguna verificada (Ej: se llegó acá sin pasar por
  /// Ubicación) se cae a la primera dirección registrada del cliente.
  Future<String?> _resolveAddressId(String token) async {
    final verified = DHCLIENTUbicacionWidget.lastVerifiedAddressId;
    if (verified != null && verified.trim().isNotEmpty) return verified.trim();

    final response =
        await DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall.call(
      authToken: token,
    );
    if (!response.succeeded) return null;

    final raw = DOVIAAPIDoviaHomeContextGroup.listServiceAddressesCall
            .addressesList(response.jsonBody) ??
        [];
    for (final address in raw.whereType<Map>()) {
      final id = (address['id'] ?? address['addressId'])?.toString();
      if (id != null && id.trim().isNotEmpty) return id.trim();
    }
    return null;
  }

  /// Sube las fotos de la emergencia a S3 (presign → PUT → confirm). Es
  /// best-effort: la solicitud ya existe, un fallo de fotos no la invalida.
  Future<void> _uploadPhotos(String serviceRequestId, String token) async {
    final photos = DHCLIENTCostoEmergenciaWidget.photos;
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

  /// Cobra la solicitud (`POST /service-requests/{id}/payment/confirm`).
  /// - Premium: se cobra el precio con descuento a la tarjeta guardada.
  /// - Free: se cobra el monto total al contratar.
  Future<bool> _chargeRequest() async {
    final serviceRequestId = await _ensureServiceRequest();
    if (serviceRequestId == null) return false;

    final response =
        await DOVIAAPIDoviaHomeContextGroup.confirmServiceRequestPaymentCall
            .call(
      serviceRequestId: serviceRequestId,
      currency: DHCLIENTCostoEmergenciaWidget.currency,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!response.succeeded) {
      _showError('No se pudo procesar el cobro. Intenta de nuevo.');
      return false;
    }
    return true;
  }

  /// Escenario Free — [Contratar]: cobra el monto total. Sólo al confirmarse el
  /// cobro se desbloquea el botón inferior [Siguiente].
  Future<void> _payDirect() async {
    if (_isPaid || _model.isSubmitting) return;
    safeSetState(() => _model.isSubmitting = true);
    try {
      final charged = await _chargeRequest();
      if (!mounted || !charged) return;
      safeSetState(() => _paidMethod = 'direct');
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// Escenario Free — [Subscribirse]: abre el flujo de adquisición del plan
  /// DOVIA Home. Al volver se re-consulta la suscripción contra el backend: si
  /// quedó activa, la pantalla pasa al escenario Premium (tarjeta de descuento)
  /// y [Siguiente] se habilita. Si el cliente omitió la compra, no pasa nada:
  /// el paso sigue bloqueado hasta que pague.
  Future<void> _goToSubscription() async {
    if (_isPaid || _model.isSubmitting) return;
    // Sin esto, "Omitir" en Planes deriva al flujo de visita estándar (con paso
    // de calendario), que es justo el que la emergencia debe saltear.
    DHCLIENTPlanesPageWidget.pendingReturnRoute =
        DHCLIENTCostoEmergenciaWidget.routeName;
    await context.pushNamed(DHCLIENTPlanesPageWidget.routeName);
    if (!mounted) return;
    DHCLIENTPlanesPageWidget.pendingReturnRoute = null;

    await context
        .read<PaymentsRepository>()
        .loadCurrentSubscription(forceRefresh: true);
    if (mounted) safeSetState(() {});
  }

  /// Confirma la solicitud de emergencia. **Omite el calendario**: no hay paso
  /// de selección de fecha y hora. Cobra si todavía no se cobró (Premium),
  /// registra la solicitud en "Próximas visitas" con alta prioridad, lanza el
  /// modal de éxito y redirige al Dashboard.
  Future<void> _confirmAndSchedule() async {
    if (_model.isSubmitting) return;
    safeSetState(() => _model.isSubmitting = true);
    try {
      // Sólo [Contratar] cobra por adelantado; en el resto de los casos
      // (Premium, o Free que acaba de suscribirse) el cobro se procesa acá
      // contra la tarjeta guardada, al precio que resuelve el backend.
      final charged = _paidMethod == 'direct' ? true : await _chargeRequest();
      if (!mounted || !charged) return;

      DHCLIENTHomepageWidget.upcomingVisits.insert(
        0,
        ScheduledVisit(
          id: _serviceRequestId,
          service: 'Servicio de emergencia',
          date: 'Atención prioritaria',
          time: 'respuesta < 18h',
          status: 'Pendiente',
          isEmergency: true,
        ),
      );
      DHCLIENTCostoEmergenciaWidget.categoryId = null;
      DHCLIENTCostoEmergenciaWidget.description = null;
      DHCLIENTCostoEmergenciaWidget.photos = [];
      // El flujo terminó: la dirección verificada no debe quedar pegada a una
      // emergencia futura que se levante sin pasar por Ubicación.
      DHCLIENTUbicacionWidget.lastVerifiedAddressId = null;
      DHCLIENTUbicacionWidget.lastVerifiedAddressLabel = null;

      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
            child: DHCLIENTExitoProgramarAgendaWidget(
              message: 'Programaste con éxito tu servicio para la Casa',
            ),
          );
        },
      );
      // Al cerrarse el modal (auto o al tapear fuera) redirige al Dashboard.
      if (mounted) {
        context.goNamed(DHCLIENTHomepageWidget.routeName);
      }
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // `hasActiveSubscription` es false mientras el estado no se resolvió:
    // hasta saberlo no se renderiza ninguna de las dos tarjetas, para no
    // mostrarle el upsell de Premium a un cliente que sí paga.
    final payments = context.watch<PaymentsRepository>();
    final premiumResolved = payments.subscriptionLoaded;
    final isPremium = payments.hasActiveSubscription;

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
                      title: 'Costo fijo mínimo\ndel trabajo',
                      hideActions: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 0.0),
                    child: !premiumResolved
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : isPremium
                            ? _premiumCard()
                            : _freeCard(),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 30.0, 20.0, 110.0),
                    child: _nextButton(
                      isPremium: isPremium,
                      premiumResolved: premiumResolved,
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
  // Escenario A: Premium (tarjeta de descuento).
  // ---------------------------------------------------------------------------

  Widget _premiumCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 10.0),
          )
        ],
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Precio del servicio',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 17.0,
                  letterSpacing: -0.34,
                ),
          ),
          const SizedBox(height: 8.0),
          // Precio base tachado.
          _priceLine(
            DHCLIENTCostoEmergenciaWidget.basePrice,
            '/el día',
            struck: true,
          ),
          const SizedBox(height: 18.0),
          // Etiqueta central de descuento.
          _premiumPill(
            leading: Text(
              DHCLIENTCostoEmergenciaWidget.discountLabel,
              style: GoogleFonts.publicSans(
                color: const Color(0xFF007376),
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
              ),
            ),
            trailing: 'DOVIA PREMIUM',
          ),
          const SizedBox(height: 18.0),
          // Precio final a cobrar.
          _priceLine(
            DHCLIENTCostoEmergenciaWidget.discountedPrice,
            '/el día',
          ),
          const SizedBox(height: 18.0),
          // Píldora informativa del ahorro exacto.
          _premiumPill(
            leading: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'AHORRO DEL SERVICIO  ',
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF6A7282),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.0,
                    ),
                  ),
                  TextSpan(
                    text: DHCLIENTCostoEmergenciaWidget.savingsAmount,
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF007376),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            trailing: 'DOVIA PREMIUM',
          ),
        ],
      ),
    );
  }

  Widget _premiumPill({required Widget leading, required String trailing}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFCCE3E4),
        borderRadius: BorderRadius.circular(100.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: leading),
          Text(
            trailing,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF6A7282),
              fontWeight: FontWeight.w600,
              fontSize: 9.0,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Escenario B: Free (pago regular + upsell).
  // ---------------------------------------------------------------------------

  Widget _freeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 10.0),
          )
        ],
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Precio del servicio',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 17.0,
                  letterSpacing: -0.34,
                ),
          ),
          const SizedBox(height: 8.0),
          _priceLine(DHCLIENTCostoEmergenciaWidget.regularPrice, '/el día'),
          const SizedBox(height: 20.0),
          _softButton(
            'Contratar',
            paid: _paidMethod == 'direct',
            onTap: _payDirect,
          ),
          const SizedBox(height: 20.0),
          Text(
            'Si te suscribes a Dovia Home,\nse te cobrará con descuento:',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF00444B),
                  fontSize: 17.0,
                  letterSpacing: -0.34,
                  lineHeight: 1.4,
                ),
          ),
          const SizedBox(height: 12.0),
          _priceLine(DHCLIENTCostoEmergenciaWidget.discountedPrice, '/el día'),
          const SizedBox(height: 20.0),
          // Nunca queda en estado "Pagado": si la contratación prospera, la
          // pantalla pasa al escenario Premium y esta tarjeta deja de verse.
          _softButton(
            'Subscribirse',
            onTap: _goToSubscription,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers compartidos.
  // ---------------------------------------------------------------------------

  Widget _priceLine(String amount, String period, {bool struck = false}) {
    return RichText(
      textAlign: TextAlign.center,
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        children: [
          TextSpan(
            text: amount,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF007376),
              fontSize: struck ? 28.0 : 39.0,
              letterSpacing: 0.4,
              decoration: struck ? TextDecoration.lineThrough : null,
              decorationColor: const Color(0xFF007376),
            ),
          ),
          TextSpan(
            text: period,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF6A7282),
              fontSize: 15.0,
              letterSpacing: -0.16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _softButton(
    String text, {
    required VoidCallback onTap,
    bool paid = false,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: (paid || _model.isSubmitting) ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52.0,
        decoration: BoxDecoration(
          color: paid ? const Color(0xFF007376) : const Color(0xFFCCE3E4),
          borderRadius: BorderRadius.circular(100.0),
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (paid)
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                child: Icon(Icons.check_circle, color: Colors.white, size: 20.0),
              ),
            Text(
              paid ? 'Pagado' : text,
              style: GoogleFonts.publicSans(
                color: paid ? Colors.white : const Color(0xFF007376),
                fontWeight: paid ? FontWeight.w600 : FontWeight.normal,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón inferior [Siguiente].
  /// - Premium: siempre habilitado (cobra a la tarjeta guardada).
  /// - Free: bloqueado hasta que el usuario complete el pago (contratando
  ///   directo o suscribiéndose).
  /// - Mientras no se sepa si es Premium: bloqueado, para no dejar avanzar
  ///   sobre un escenario todavía sin resolver.
  Widget _nextButton({required bool isPremium, required bool premiumResolved}) {
    final enabled =
        premiumResolved && (isPremium || _isPaid) && !_model.isSubmitting;
    return FFButtonWidget(
      onPressed: enabled ? () async => _confirmAndSchedule() : null,
      text: 'Siguiente',
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
