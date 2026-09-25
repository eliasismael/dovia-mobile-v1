import '/dovia_home_client/checkout_launcher.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_agenda/d_h_c_l_i_e_n_t_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_instalacion/d_h_c_l_i_e_n_t_instalacion_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/proposal_fields.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/repositories/payments_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/premium_upsell_popup/premium_upsell_popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';

import 'd_h_c_l_i_e_n_t_cotizaciones_recibidas_model.dart';
export 'd_h_c_l_i_e_n_t_cotizaciones_recibidas_model.dart';

/// Propuestas que los proveedores enviaron al cliente.
///
/// Con una solicitud fijada muestra el historial de esa cotización
/// (`QuoteProposalResponseDto`); sin ella, el listado unificado
/// (`DoviaHomeUnifiedProposalDto`), que mezcla propuestas `QUOTE` y
/// `OUT_OF_SCOPE`. El cliente compara descripción, precio y PDF, marca una y la
/// acepta o la rechaza.
///
/// **La aceptación no es la misma para las dos familias** y por eso se ramifica
/// por `proposalType`: una `QUOTE` cierra el marketplace sin cobro y sigue al
/// agendamiento, mientras que una `OUT_OF_SCOPE` crea una orden y abre el
/// checkout de Recurrente.
///
/// El precio se muestra tal cual lo cotizó el proveedor. El contrato no expone
/// precio de lista ni descuento de plan, así que la pantalla no calcula
/// ninguno: en `OUT_OF_SCOPE` se cobra exactamente ese monto.
class DHCLIENTCotizacionesRecibidasWidget extends StatefulWidget {
  const DHCLIENTCotizacionesRecibidasWidget({super.key});

  static String routeName = 'DH_CLIENT_CotizacionesRecibidas';
  static String routePath = '/dHCLIENTCotizacionesRecibidas';

  /// Solicitud de cotización cuyas propuestas se muestran. Se inyecta desde el
  /// Dashboard antes de navegar, porque go_router navega sólo por nombre. Si es
  /// null se listan todas las propuestas recibidas por el cliente.
  static String? serviceRequestId;

  /// Hijo `OUT_OF_SCOPE` cuyas propuestas de trabajo extra se muestran.
  ///
  /// Va en un campo aparte de [serviceRequestId] porque, con el mismo tipo de
  /// dato, la ruta es otra: las propuestas de un trabajo fuera de alcance no
  /// salen de `/quote-proposals`. Debe ser el id del **hijo**, no el de la raíz
  /// ni el de la solicitud fuera de alcance —con cualquiera de esos dos el
  /// backend responde `DOVIA_HOME_SERVICE_REQUEST_NOT_FOUND`—.
  static String? outOfScopeServiceRequestId;

  @override
  State<DHCLIENTCotizacionesRecibidasWidget> createState() =>
      _DHCLIENTCotizacionesRecibidasWidgetState();
}

class _DHCLIENTCotizacionesRecibidasWidgetState
    extends State<DHCLIENTCotizacionesRecibidasWidget> {
  late DHCLIENTCotizacionesRecibidasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<ApiCallResponse> _proposalsFuture;

  /// Solicitud fijada al abrir la pantalla. Se captura en [initState] para que
  /// el parseo de la respuesta no cambie si el campo estático se limpia.
  String? _requestId;

  /// Si [_requestId] es un hijo `OUT_OF_SCOPE` en vez de una cotización. Decide
  /// qué listado se pide: son dos rutas distintas sobre el mismo path param.
  bool _outOfScope = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCotizacionesRecibidasModel());

    // Los dos estáticos se consumen al abrir: quedan amarrados a esta instancia
    // y se limpian, para que una entrada posterior no herede la solicitud de la
    // anterior.
    final outOfScopeId =
        DHCLIENTCotizacionesRecibidasWidget.outOfScopeServiceRequestId;
    _outOfScope = outOfScopeId != null && outOfScopeId.isNotEmpty;
    _requestId = _outOfScope
        ? outOfScopeId
        : DHCLIENTCotizacionesRecibidasWidget.serviceRequestId;
    DHCLIENTCotizacionesRecibidasWidget.outOfScopeServiceRequestId = null;

    _proposalsFuture = _buildProposalsFuture();

    // El estatus de suscripción decide si la tarjeta refleja el descuento
    // Premium sobre el costo del proyecto (queda cacheado en el repo).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsRepository>().loadCurrentSubscription();
      safeSetState(() {});
    });
  }

  /// Pide el listado que corresponde:
  /// - hijo `OUT_OF_SCOPE` → sus propuestas de trabajo extra;
  /// - cotización concreta → su historial de propuestas;
  /// - sin solicitud → el listado unificado de todo lo recibido.
  Future<ApiCallResponse> _buildProposalsFuture() {
    final token = currentAuthenticationToken ?? '';
    if (_outOfScope) {
      return DOVIAAPIDoviaHomeContextGroup.listClientOutOfScopeProposalsCall
          .call(
        serviceRequestId: _requestId,
        authToken: token,
        limit: 20,
      );
    }
    if (_hasRequestId) {
      return DOVIAAPIDoviaHomeContextGroup.listQuoteProposalsCall.call(
        serviceRequestId: _requestId,
        authToken: token,
        limit: 20,
      );
    }
    return DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall.call(
      authToken: token,
      limit: 20,
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  bool get _hasRequestId => (_requestId?.isNotEmpty) ?? false;

  // ---------------------------------------------------------------------------
  // Campos de la propuesta. Se leen con `proposal_fields.dart`, que cubre los
  // dos contratos que consume esta pantalla (`DoviaHomeUnifiedProposalDto` y
  // `QuoteProposalResponseDto`).
  // ---------------------------------------------------------------------------

  /// Solicitud a la que pertenece la propuesta: la fijada al abrir la pantalla
  /// o, si se listaron todas, la que venga en el propio objeto.
  ///
  /// En una propuesta `OUT_OF_SCOPE` este id es el del **hijo** creado al
  /// autorizar el trabajo extra, no el de la raíz.
  String? _requestIdOf(Map<String, dynamic> proposal) =>
      _hasRequestId ? _requestId : proposalServiceRequestId(proposal);

  /// Costo del proyecto tal cual lo cotizó el proveedor.
  ///
  /// No se aplica ningún descuento acá: el contrato no expone precio de lista ni
  /// beneficio de plan, y en `OUT_OF_SCOPE` el checkout cobra exactamente
  /// `totalAmount`. Calcular un descuento del lado del cliente mostraría un
  /// número que no es el que se va a cobrar.
  String _priceLabel(Map<String, dynamic> proposal) =>
      proposalAmountLabel(proposal) ?? '-';

  /// Nombre del servicio con el que la solicitud queda registrada al agendar.
  /// El contrato de propuestas no trae el nombre del servicio, así que se usa la
  /// descripción del trabajo cuando existe.
  String _serviceTitle(Map<String, dynamic> proposal) =>
      proposalDescription(proposal) ?? 'Trabajo cotizado';

  /// Nombre de la cotización: se rotulan por orden de llegada siguiendo el
  /// diseño ("Cotización A", "Cotización B", …). Cuando el proveedor mandó más
  /// de una versión se aclara cuál es, porque el listado las devuelve todas.
  String _proposalTitle(Map<String, dynamic> proposal, int index) {
    final label = 'Cotización ${String.fromCharCode(65 + index)}';
    final version = proposalVersion(proposal);
    return (version == null || version <= 1) ? label : '$label · v$version';
  }

  /// Extrae el listado según el endpoint usado. Los tres son paginados y ponen
  /// el arreglo directamente en `data`; la metadata va aparte, en
  /// `meta.pagination`.
  List<Map<String, dynamic>> _extractProposals(ApiCallResponse response) {
    final List? raw;
    if (_outOfScope) {
      raw = DOVIAAPIDoviaHomeContextGroup.listClientOutOfScopeProposalsCall
          .proposalsList(response.jsonBody);
    } else if (_hasRequestId) {
      raw = DOVIAAPIDoviaHomeContextGroup.listQuoteProposalsCall
          .proposalsList(response.jsonBody);
    } else {
      raw = DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall
          .proposalsList(response.jsonBody);
    }

    return (raw ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Selección única (radio button): marcar una cotización desmarca la
  /// anterior. Volver a tapear la marcada la deja marcada.
  void _selectProposal(String id) {
    if (_model.selectedProposalId == id) return;
    safeSetState(() => _model.selectedProposalId = id);
  }

  /// Propuesta actualmente marcada, o null si no hay ninguna.
  Map<String, dynamic>? _selected(List<Map<String, dynamic>> proposals) {
    final id = _model.selectedProposalId;
    if (id == null) return null;
    for (final proposal in proposals) {
      if (proposalId(proposal) == id) return proposal;
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Acepta la propuesta marcada.
  ///
  /// Las dos familias de propuesta terminan en rutas distintas y con
  /// consecuencias distintas, así que se ramifica por `proposalType`:
  /// - `QUOTE`: la aceptación es terminal y **no cobra** por la plataforma. La
  ///   solicitud pasa a `TAKEN` con la empresa asignada y el cliente sigue al
  ///   agendamiento.
  /// - `OUT_OF_SCOPE`: la aceptación también es terminal y tampoco cobra. Es la
  ///   autorización de negocio: el hijo pasa a `TAKEN` con el proveedor
  ///   asignado y su `payment` queda en `NOT_REQUIRED`. Sí exige plan vigente,
  ///   así que sin suscripción se ofrece el plan en vez de mandar una llamada
  ///   que el backend va a rechazar.
  Future<void> _acceptSelected(
    List<Map<String, dynamic>> proposals,
    bool isPremium,
  ) async {
    final accepted = _selected(proposals);
    if (accepted == null) return;

    if (proposalIsOutOfScope(accepted) && !isPremium) {
      await showDialog(
        context: context,
        builder: (_) => const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: PremiumUpsellPopupWidget(),
        ),
      );
      return;
    }

    safeSetState(() => _model.isAccepting = true);
    try {
      if (proposalIsOutOfScope(accepted)) {
        await _acceptOutOfScope(accepted);
      } else {
        await _acceptQuote(accepted);
      }
    } finally {
      if (mounted) {
        safeSetState(() => _model.isAccepting = false);
      }
    }
  }

  Future<void> _acceptQuote(Map<String, dynamic> accepted) async {
    final requestId = _requestIdOf(accepted);
    if (requestId == null || requestId.isEmpty) {
      _showError('No se pudo identificar la solicitud de la cotización.');
      return;
    }

    final response =
        await DOVIAAPIDoviaHomeContextGroup.acceptQuoteProposalCall.call(
      serviceRequestId: requestId,
      proposalId: proposalId(accepted),
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    if (!response.succeeded) {
      _showError('No se pudo aceptar la cotización. Intenta de nuevo.');
      return;
    }

    // Propuesta aceptada: la solicitud queda TAKEN con esa empresa y el cliente
    // sigue al agendamiento. Este flujo no abre ningún cobro. La anticipación
    // mínima (24h con plan, 36h sin él) la resuelve Agenda por su cuenta.
    DHCLIENTCotizacionesRecibidasWidget.serviceRequestId = null;
    DHCLIENTInstalacionWidget.serviceTitle = _serviceTitle(accepted);
    context.pushNamed(DHCLIENTAgendaWidget.routeName);
  }

  /// Acepta una propuesta de trabajo fuera de alcance. La ruta va por
  /// `proposalId` solamente: el hijo sobre el que se aplica ya está amarrado a
  /// la propuesta del lado del backend.
  /// Acepta una propuesta de trabajo fuera de alcance.
  ///
  /// Aceptar reserva el trabajo en el acto: la transacción desactiva a las
  /// competidoras, pasa el hijo a `TAKEN` con el proveedor asignado y deja su
  /// `payment` en `NOT_REQUIRED`. No hay cobro por la plataforma —la respuesta
  /// no trae `payment`, `paymentOrderId` ni `checkoutUrl`—, así que tampoco hay
  /// checkout que abrir.
  Future<void> _acceptOutOfScope(Map<String, dynamic> accepted) async {
    final response =
        await DOVIAAPIDoviaHomeContextGroup.acceptOutOfScopeProposalCall.call(
      proposalId: proposalId(accepted),
      authToken: currentAuthenticationToken ?? '',
    );
    if (!mounted) return;

    if (!response.succeeded) {
      _showError('No se pudo aceptar la propuesta. Intenta de nuevo.');
      return;
    }

    _showError('Aceptaste la propuesta. El proveedor queda asignado al '
        'trabajo.');
    Navigator.pop(context);
  }

  /// Rechaza la propuesta marcada. No cierra la solicitud: el proveedor puede
  /// enviar una versión posterior y las demás propuestas siguen disponibles.
  Future<void> _rejectSelected(List<Map<String, dynamic>> proposals) async {
    final rejected = _selected(proposals);
    if (rejected == null) return;

    safeSetState(() => _model.isAccepting = true);
    try {
      final ApiCallResponse response;
      if (proposalIsOutOfScope(rejected)) {
        response = await DOVIAAPIDoviaHomeContextGroup
            .rejectOutOfScopeProposalCall
            .call(
          proposalId: proposalId(rejected),
          authToken: currentAuthenticationToken ?? '',
        );
      } else {
        final requestId = _requestIdOf(rejected);
        if (requestId == null || requestId.isEmpty) {
          _showError('No se pudo identificar la solicitud de la cotización.');
          return;
        }
        response =
            await DOVIAAPIDoviaHomeContextGroup.rejectQuoteProposalCall.call(
          serviceRequestId: requestId,
          proposalId: proposalId(rejected),
          authToken: currentAuthenticationToken ?? '',
        );
      }
      if (!mounted) return;

      if (!response.succeeded) {
        _showError('No se pudo rechazar la propuesta. Intenta de nuevo.');
        return;
      }

      _showError('Rechazaste la propuesta. Le avisamos al proveedor.');
      safeSetState(() => _model.selectedProposalId = null);
      _reloadProposals();
    } finally {
      if (mounted) {
        safeSetState(() => _model.isAccepting = false);
      }
    }
  }

  /// Vuelve a pedir el listado: tras un rechazo cambia el estado de la versión y
  /// puede aparecer una nueva.
  void _reloadProposals() {
    safeSetState(() => _proposalsFuture = _buildProposalsFuture());
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PaymentsRepository>().hasActiveSubscription;

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
                      title: 'Cotizaciones Recibidas',
                      showMap: false,
                      showCurrency: false,
                    ),
                  ),
                  // El padding horizontal lo pone cada bloque: el carrusel de
                  // tarjetas sangra hasta el borde para que se vea que sigue
                  // scrolleando.
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 24.0, 0.0, 120.0),
                    child: FutureBuilder<ApiCallResponse>(
                      future: _proposalsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final response = snapshot.data!;
                        final proposals = response.succeeded
                            ? _extractProposals(response)
                            : <Map<String, dynamic>>[];

                        if (proposals.isEmpty) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _emptyState(response.succeeded),
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                proposals.length == 1
                                    ? 'Revisa la propuesta y continúa si te sirve.'
                                    : 'Desliza para comparar las propuestas y elige la que prefieras.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(),
                                      color: const Color(0xFF00444B),
                                      fontSize: 14.0,
                                      letterSpacing: 0.28,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            _proposalsCarousel(proposals, isPremium),
                            const SizedBox(height: 18.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: _continueButton(proposals, isPremium),
                            ),
                          ],
                        );
                      },
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

  Widget _emptyState(bool succeeded) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Center(
        child: Text(
          succeeded
              ? 'Todavía no recibiste cotizaciones. Te avisaremos cuando los proveedores envíen sus propuestas.'
              : 'No pudimos cargar tus cotizaciones. Intenta de nuevo más tarde.',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: const Color(0xFF6A6A6A),
                fontSize: 14.0,
                lineHeight: 1.4,
              ),
        ),
      ),
    );
  }

  /// Tarjetas de propuestas en scroll horizontal, como en el diseño (una fila
  /// de cotizaciones a comparar) adaptado a mobile: en pantalla angosta entran
  /// de a una y la siguiente asoma para que se note que hay más.
  ///
  /// [IntrinsicHeight] las iguala a la más alta, que es lo que hace comparables
  /// campo contra campo dos propuestas con textos de distinto largo.
  Widget _proposalsCarousel(
      List<Map<String, dynamic>> proposals, bool isPremium) {
    const horizontalPadding = 20.0;
    const gap = 12.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Con una sola propuesta no hay nada que deslizar: ocupa el ancho completo.
    final cardWidth = proposals.length == 1
        ? screenWidth - horizontalPadding * 2
        : (screenWidth * 0.78).clamp(240.0, 340.0).toDouble();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < proposals.length; i++)
              Padding(
                padding: EdgeInsets.only(
                    right: i == proposals.length - 1 ? 0.0 : gap),
                child: SizedBox(
                  width: cardWidth,
                  child: _proposalCard(proposals[i], i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de una cotización recibida con su radio button de selección.
  Widget _proposalCard(Map<String, dynamic> proposal, int index) {
    final id = proposalId(proposal);
    final selected = id.isNotEmpty && _model.selectedProposalId == id;
    final providerName = proposalProviderName(proposal);
    final description = proposalDescription(proposal);
    final documentUrl = proposalDocumentUrl(proposal);

    return Semantics(
      // Grupo de selección única: sólo una cotización puede quedar marcada.
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: id.isEmpty ? null : () => _selectProposal(id),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color:
                  selected ? const Color(0xFF007376) : const Color(0xFFE5E7EB),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 20.0, 12.0, 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _radioButton(selected),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _proposalTitle(proposal, index),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.publicSans(
                                fontWeight: FontWeight.w600),
                            color: const Color(0xFF00444B),
                            fontSize: 14.0,
                          ),
                    ),
                    if (providerName != null)
                      Text(
                        providerName,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.publicSans(),
                              color: const Color(0xFF6A7282),
                              fontSize: 12.0,
                            ),
                      ),
                    const SizedBox(height: 8.0),
                    // El alcance se acota a 4 líneas: con descripciones largas
                    // las tarjetas dejaban de ser comparables de un vistazo. El
                    // historial por servicio no trae descripción; ahí el PDF es
                    // todo el detalle que hay.
                    if (description != null)
                      _proposalField(
                        'Trabajo a realizar:',
                        description,
                        maxLines: 4,
                      ),
                    _priceField(_priceLabel(proposal)),
                    // El PDF es la propuesta en sí: sin abrirlo el cliente no
                    // tiene sobre qué decidir.
                    if (documentUrl != null) _documentLink(documentUrl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Radio button de selección única, con el círculo aqua del diseño.
  Widget _radioButton(bool selected) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF007376),
          width: selected ? 2.0 : 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF007376),
                ),
              ),
            )
          : null,
    );
  }

  Widget _proposalField(String label, String value, {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF007376),
                  fontSize: 12.0,
                ),
          ),
          Text(
            value,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF007376),
                  fontSize: 12.0,
                  lineHeight: 1.3,
                ),
          ),
        ],
      ),
    );
  }

  /// Precio del proyecto, tal cual lo cotizó el proveedor.
  Widget _priceField(String label) => _proposalField('Precio:', label);

  /// Acceso al PDF de la propuesta.
  Widget _documentLink(String url) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: () => _openDocument(url),
          child: Text(
            'Ver propuesta (PDF)',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: const Color(0xFF007376),
                  fontSize: 12.0,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      );

  Future<void> _openDocument(String url) async {
    if (await launchDoviaHomeDocument(url)) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir la propuesta.')),
    );
  }

  /// [Continuar]: inactivo hasta que el cliente marque una cotización.
  ///
  /// Debajo se ofrece rechazarla, que es la otra mitad de la decisión del
  /// contrato: rechazar no cierra la solicitud, deja esa versión fuera y habilita
  /// al proveedor a mandar otra.
  Widget _continueButton(List<Map<String, dynamic>> proposals, bool isPremium) {
    final selected = _selected(proposals);
    // Sólo una propuesta viva admite decisión: una ya aceptada o rechazada se
    // sigue mostrando en el historial, pero no se vuelve a operar.
    final actionable = selected != null &&
        proposalIsActionable(selected) &&
        !_model.isAccepting;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FFButtonWidget(
          onPressed: actionable
              ? () async => _acceptSelected(proposals, isPremium)
              : null,
          text: _model.isAccepting ? 'Aceptando…' : 'Continuar',
          options: FFButtonOptions(
            width: double.infinity,
            height: 50.0,
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
            iconPadding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
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
        ),
        const SizedBox(height: 12.0),
        FFButtonWidget(
          onPressed: actionable ? () async => _rejectSelected(proposals) : null,
          text: 'Rechazar propuesta',
          options: FFButtonOptions(
            width: double.infinity,
            height: 50.0,
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
            iconPadding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: Colors.transparent,
            disabledColor: Colors.transparent,
            disabledTextColor: const Color(0xFF6A6A6A),
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: const Color(0xFF007376),
                  fontSize: 17.0,
                  letterSpacing: 0.34,
                ),
            elevation: 0.0,
            borderSide: const BorderSide(color: Color(0xFF007376), width: 1.0),
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
      ],
    );
  }
}
