import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/repositories/index.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import 'd_h_c_l_i_e_n_t_fuera_de_alcance_model.dart';
export 'd_h_c_l_i_e_n_t_fuera_de_alcance_model.dart';

/// Diagnóstico de un trabajo que el asociado catalogó como fuera de alcance.
///
/// El cliente lee lo que el asociado cargó desde su app (descripción y fotos) y
/// decide: autorizar que la red de proveedores cotice el trabajo
/// (`POST /out-of-scope-requests/{id}/authorize`, sólo con plan activo) o
/// cerrarlo sin cotizar (`POST /out-of-scope-requests/{id}/close`), quedando el
/// diagnóstico guardado en su historial.
class DHCLIENTFueraDeAlcanceWidget extends StatefulWidget {
  const DHCLIENTFueraDeAlcanceWidget({super.key, this.requestId});

  final String? requestId;

  static String routeName = 'DH_CLIENT_FueraDeAlcance';
  static String routePath = '/dHCLIENTFueraDeAlcance';

  /// Solicitud fuera de alcance que se está revisando. Se inyecta antes de
  /// navegar, porque go_router navega sólo por nombre (misma convención que
  /// [DHCLIENTCotizacionesRecibidasWidget.serviceRequestId]). Tiene prioridad
  /// el valor del constructor cuando la página se instancia directamente.
  ///
  /// **Se consume al abrir la pantalla** (ver `initState`): el valor queda
  /// amarrado a esa instancia y el campo vuelve a null. Es un estático
  /// compartido y esta pantalla tiene más de una entrada —[DHCLIENTUbicacionWidget]
  /// la usa para avisar que una dirección quedó fuera de la zona de cobertura,
  /// sin ninguna solicitud detrás—, así que sin limpiarlo la segunda entrada
  /// heredaría el diagnóstico de la primera y sus botones actuarían sobre una
  /// solicitud que el cliente no está mirando.
  static String? outOfScopeRequestId;

  @override
  State<DHCLIENTFueraDeAlcanceWidget> createState() =>
      _DHCLIENTFueraDeAlcanceWidgetState();
}

class _DHCLIENTFueraDeAlcanceWidgetState
    extends State<DHCLIENTFueraDeAlcanceWidget> {
  late DHCLIENTFueraDeAlcanceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Solicitud que revisa **esta** instancia, resuelta una sola vez al abrir.
  ///
  /// Se fija acá y no se vuelve a leer el estático: si se consultara en cada
  /// uso, una entrada posterior por otro camino podría cambiarlo por debajo
  /// mientras la pantalla sigue en pantalla.
  String? _resolvedRequestId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTFueraDeAlcanceModel());

    // Se toma el valor inyectado y se limpia el estático en el acto: a partir
    // de acá, quien abra la pantalla sin inyectar nada obtiene "sin solicitud"
    // —el estado vacío correcto— y no el diagnóstico de la visita anterior.
    for (final candidate in [
      widget.requestId,
      DHCLIENTFueraDeAlcanceWidget.outOfScopeRequestId,
    ]) {
      if (candidate != null && candidate.isNotEmpty) {
        _resolvedRequestId = candidate;
        break;
      }
    }
    DHCLIENTFueraDeAlcanceWidget.outOfScopeRequestId = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // El estatus de suscripción decide si "Sí quiero que me coticen" autoriza
      // o muestra el bloqueo de Premium. Se resuelve al entrar (queda cacheado
      // en el repo) para que un cliente que sí paga no vea el upsell por llegar
      // acá antes de que el estado estuviera cargado.
      context.read<PaymentsRepository>().loadCurrentSubscription();
      _loadDiagnosisData();
    });
  }

  /// Solicitud a consultar, resuelta al abrir la pantalla. Null cuando se llegó
  /// sin inyectar ninguna —Ej: el aviso de dirección fuera de cobertura—, y ahí
  /// la pantalla se queda en estado vacío en vez de operar sobre otra.
  String? get _requestId => _resolvedRequestId;

  Future<void> _loadDiagnosisData() async {
    final requestId = _requestId;
    if (requestId == null) {
      // Sin solicitud asociada no hay diagnóstico que leer: la pantalla queda
      // en estado vacío en lugar de mostrar contenido inventado.
      return;
    }

    safeSetState(() {
      _model.isLoadingDiagnosis = true;
      _model.diagnosisLoadFailed = false;
    });
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.getOutOfScopeRequestCall.call(
        requestId: requestId,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        safeSetState(() => _model.diagnosisLoadFailed = true);
        return;
      }

      final data = _asMap(getJsonField(response.jsonBody, r'''$.data''')) ??
          _asMap(response.jsonBody);
      safeSetState(() {
        _model.diagnosisText = _diagnosisTextOf(data);
        _model.diagnosisImagesUrls = _imageUrlsOf(data);
        _model.requestStatus = _statusOf(data);
        // El hijo que crea la autorización es contra quien se consultan las
        // propuestas: la solicitud fuera de alcance no las expone. Null hasta
        // que el cliente autoriza, así que no se pisa lo ya conocido con vacío.
        final childId = data?['childServiceRequestId'];
        if (childId is String && childId.trim().isNotEmpty) {
          _model.childServiceRequestId = childId.trim();
        }
      });
    } catch (_) {
      if (mounted) safeSetState(() => _model.diagnosisLoadFailed = true);
    } finally {
      if (mounted) safeSetState(() => _model.isLoadingDiagnosis = false);
    }
  }

  /// Texto a mostrar cuando no hay diagnóstico que renderizar. Null cuando sí
  /// lo hay y debe mostrarse `_model.diagnosisText`.
  String? get _diagnosisPlaceholder {
    if (_model.diagnosisLoadFailed) {
      return 'No pudimos cargar el diagnóstico. Intenta de nuevo más tarde.';
    }
    final text = _model.diagnosisText;
    if (text == null || text.isEmpty) {
      return 'El asociado no dejó un detalle escrito del diagnóstico.';
    }
    return null;
  }

  String? _statusOf(Map<String, dynamic>? data) {
    final value = data?['status'];
    return value is String && value.trim().isNotEmpty
        ? value.trim().toUpperCase()
        : null;
  }

  /// `CLIENT_APPROVAL_PENDING` es el único estatus en el que la solicitud sigue
  /// esperando la decisión del cliente; desde `QUOTING` en adelante
  /// (`PAYMENT_PENDING`, `PAID`, `COMPLETED`) ya fue autorizada, y `CLOSED` es
  /// la que el cliente finalizó sin cotizar. Fuera del estatus pendiente la
  /// pantalla queda como consulta del historial, sin volver a ofrecer los dos
  /// botones. Mientras el estatus no se leyó (null) se asume pendiente, para no
  /// bloquear al cliente por una lectura fallida.
  bool get _decisionTaken =>
      _model.requestStatus != null &&
      _model.requestStatus != 'CLIENT_APPROVAL_PENDING';

  bool get _isClosed => _model.requestStatus == 'CLOSED';

  bool get _isAuthorized => _decisionTaken && !_isClosed;

  /// Hay propuestas que consultar: la solicitud se autorizó y el backend ya
  /// entregó el hijo contra el que se piden.
  bool get _canSeeProposals =>
      _isAuthorized && (_model.childServiceRequestId?.isNotEmpty ?? false);

  /// Lleva a comparar las propuestas del trabajo extra. Reusa la pantalla de
  /// cotizaciones recibidas, que ya sabe aceptar y rechazar las dos familias de
  /// propuesta; se le inyecta el hijo por el campo específico de fuera de
  /// alcance porque la ruta del listado no es la de cotizaciones.
  Widget _viewProposalsButton() => FFButtonWidget(
        onPressed: () {
          DHCLIENTCotizacionesRecibidasWidget.outOfScopeServiceRequestId =
              _model.childServiceRequestId;
          context.pushNamed(DHCLIENTCotizacionesRecibidasWidget.routeName);
        },
        text: 'Ver propuestas recibidas',
        options: FFButtonOptions(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 42.0,
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          iconPadding:
              const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          color: FlutterFlowTheme.of(context).primary,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: Colors.white,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
          elevation: 0.0,
          borderRadius: BorderRadius.circular(25.0),
        ),
      );

  Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  String? _diagnosisTextOf(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in ['description', 'diagnosis', 'notes', 'detail']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// Fotos que el asociado subió al catalogar el trabajo. `OutOfScopeRequestDto`
  /// las expone en `images` como `[{ url, storageKey }]`; los otros nombres se
  /// toleran por si el payload llega aplanado a URLs sueltas.
  List<String> _imageUrlsOf(Map<String, dynamic>? data) {
    if (data == null) return [];
    for (final key in [
      'images',
      'imageUrls',
      'requestImageUrls',
      'photos',
      'media'
    ]) {
      final value = data[key];
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
    for (final key in [
      'url',
      'imageUrl',
      'signedUrl',
      'downloadUrl',
      'publicUrl'
    ]) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// El cliente no quiere cotizaciones: se cierra la solicitud para que el
  /// diagnóstico quede guardado en su historial y se vuelve atrás.
  Future<void> _finalizarSinCotizar() async {
    final requestId = _requestId;
    safeSetState(() => _model.isSubmitting = true);
    try {
      if (requestId != null) {
        final response =
            await DOVIAAPIDoviaHomeContextGroup.closeOutOfScopeRequestCall.call(
          requestId: requestId,
          authToken: currentAuthenticationToken ?? '',
        );
        if (!mounted) return;

        if (!response.succeeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('No se pudo finalizar la solicitud. Intenta de nuevo.'),
            ),
          );
          return;
        }
        safeSetState(() {
          _model.requestStatus = DOVIAAPIDoviaHomeContextGroup
                  .closeOutOfScopeRequestCall
                  .status(response.jsonBody) ??
              'CLOSED';
        });
      }
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// El cliente quiere cotizaciones: función exclusiva del plan Dovia Premium.
  /// Autorizada la solicitud, el backend la mueve a QUOTING y el trabajo pasa a
  /// figurar entre las cotizaciones del cliente.
  Future<void> _solicitarCotizacion() async {
    final payments = context.read<PaymentsRepository>();
    // `hasActiveSubscription` es false mientras el estado no se resolvió: si
    // todavía no cargó se consulta antes de decidir, para no bloquear con el
    // upsell a un cliente que sí tiene plan activo.
    if (!payments.subscriptionLoaded) {
      safeSetState(() => _model.isSubmitting = true);
      await payments.loadCurrentSubscription();
      if (!mounted) return;
      safeSetState(() => _model.isSubmitting = false);
    }

    if (!payments.hasActiveSubscription) {
      await showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: PremiumUpsellPopupWidget(),
          );
        },
      );
      return;
    }

    final requestId = _requestId;
    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró la solicitud fuera de alcance.'),
        ),
      );
      return;
    }

    safeSetState(() => _model.isSubmitting = true);
    try {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .authorizeOutOfScopeRequestCall
          .call(
        requestId: requestId,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Hubo un error al procesar tu solicitud. Intenta de nuevo.'),
          ),
        );
        return;
      }

      // El backend crea la solicitud hija en OUT_OF_SCOPE_QUOTING: es la que
      // recibirá las propuestas de la red y la que el cliente verá en sus
      // cotizaciones. La operación es idempotente, así que reintentar devuelve
      // siempre la misma hija.
      final authorizeCall =
          DOVIAAPIDoviaHomeContextGroup.authorizeOutOfScopeRequestCall;
      safeSetState(() {
        _model.requestStatus =
            authorizeCall.status(response.jsonBody) ?? 'QUOTING';
        // La respuesta devuelve el hijo en `serviceRequestId`: es el que hay que
        // usar para consultar sus propuestas.
        _model.childServiceRequestId =
            authorizeCall.serviceRequestId(response.jsonBody) ??
                _model.childServiceRequestId;
      });

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: PopupExitoWidget(
              title: 'Se solicitó la cotización con éxito',
              text: 'Visualiza la publicación en el perfil de DOVIA home',
              onContinue: () {
                Navigator.pop(dialogContext);
                if (mounted) Navigator.pop(context);
              },
              continueText: 'Cerrar',
            ),
          );
        },
      );
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
                      showNotifications: true,
                      showSettings: true,
                      title: 'Fuera de alcance',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 100.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            decoration: BoxDecoration(
                              color: const Color(0x3570ACAD),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 16.0),
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '\nLos detalles de este diagnóstico serán enviados a nuestra red de asociados especializados.\n\nEn base a la información proporcionada, ellos prepararán propuestas personalizadas para tu caso.\n\nRecibirás varias opciones y podrás comparar, elegir y autorizar la que prefieras, todo desde la app.',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
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
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(),
                          child: Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 19.0, 0.0, 0.0),
                                  child: Text(
                                    'Diagnóstico enviado',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 0.0, 0.0),
                                    child: _model.isLoadingDiagnosis
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(
                                                _diagnosisPlaceholder ??
                                                    _model.diagnosisText!,
                                                style: _diagnosisPlaceholder ==
                                                        null
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!_model.isLoadingDiagnosis &&
                            _model.diagnosisImagesUrls.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      30.0, 10.0, 30.0, 30.0),
                                  child: Wrap(
                                    spacing: 12.0,
                                    runSpacing: 12.0,
                                    alignment: WrapAlignment.start,
                                    children: _model.diagnosisImagesUrls
                                        .map((url) => ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                url,
                                                width: 90.0,
                                                height: 90.0,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  width: 90.0,
                                                  height: 90.0,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                  child: Icon(
                                                    Icons.broken_image_outlined,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_decisionTaken) ...[
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Text(
                              _isAuthorized
                                  ? 'Ya solicitaste la cotización: la red de asociados está preparando sus propuestas.'
                                  : 'Finalizaste esta solicitud sin pedir cotizaciones.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          // Autorizada la solicitud, las propuestas llegan
                          // contra el hijo que creó la autorización. Sin ese id
                          // no hay a qué apuntar, así que el acceso sólo
                          // aparece cuando el backend ya lo entregó.
                          if (_canSeeProposals)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: _viewProposalsButton(),
                            ),
                        ] else ...[
                          FFButtonWidget(
                            onPressed: _model.isSubmitting
                                ? null
                                : _finalizarSinCotizar,
                            text: 'No quiero que me coticen, finalizar',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 42.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.publicSans(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Text(
                              'Ningún trabajo fuera de Dovia Home tiene garantía',
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
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 30.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: _model.isSubmitting
                                    ? null
                                    : _solicitarCotizacion,
                                text: 'Sí quiero que me coticen',
                                options: FFButtonOptions(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 42.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),
                          ),
                        ],
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
