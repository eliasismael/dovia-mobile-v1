import '/dovia_home_client/d_h_c_l_i_e_n_t_agenda/d_h_c_l_i_e_n_t_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_instalacion/d_h_c_l_i_e_n_t_instalacion_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/repositories/payments_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';

import 'd_h_c_l_i_e_n_t_cotizaciones_recibidas_model.dart';
export 'd_h_c_l_i_e_n_t_cotizaciones_recibidas_model.dart';

/// Propuestas de trabajo a medida que la red de empresas proveedoras envió para
/// las solicitudes de cotización del cliente.
///
/// El cliente compara las cotizaciones (trabajo a realizar, tiempo estimado,
/// precio y garantía), marca una y con [Continuar] la acepta: la solicitud
/// avanza con ese proveedor.
class DHCLIENTCotizacionesRecibidasWidget extends StatefulWidget {
  const DHCLIENTCotizacionesRecibidasWidget({super.key});

  static String routeName = 'DH_CLIENT_CotizacionesRecibidas';
  static String routePath = '/dHCLIENTCotizacionesRecibidas';

  /// Solicitud de cotización cuyas propuestas se muestran. Se inyecta desde el
  /// Dashboard antes de navegar, porque go_router navega sólo por nombre. Si es
  /// null se listan todas las propuestas recibidas por el cliente.
  static String? serviceRequestId;

  /// Descuento del plan Dovia Home aplicado al costo del proyecto.
  static const double premiumDiscountRate = 0.35;

  /// Etiqueta del descuento en la tarjeta (misma que el resto del flujo).
  static const String premiumDiscountLabel = '35% OFF';

  @override
  State<DHCLIENTCotizacionesRecibidasWidget> createState() =>
      _DHCLIENTCotizacionesRecibidasWidgetState();
}

/// Precio ya resuelto para la tarjeta: lo que el cliente pagará y, cuando
/// aplica el beneficio Premium, el precio de lista que queda tachado.
class _ProposalPrice {
  const _ProposalPrice({required this.finalLabel, this.baseLabel});

  final String finalLabel;
  final String? baseLabel;

  bool get hasDiscount => baseLabel != null;
}

class _DHCLIENTCotizacionesRecibidasWidgetState
    extends State<DHCLIENTCotizacionesRecibidasWidget> {
  late DHCLIENTCotizacionesRecibidasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<ApiCallResponse> _proposalsFuture;

  /// Solicitud fijada al abrir la pantalla. Se captura en [initState] para que
  /// el parseo de la respuesta no cambie si el campo estático se limpia.
  String? _requestId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTCotizacionesRecibidasModel());

    final token = currentAuthenticationToken ?? '';
    _requestId = DHCLIENTCotizacionesRecibidasWidget.serviceRequestId;
    // Con una solicitud concreta se piden sus propuestas; sin ella se listan
    // todas las recibidas por el cliente.
    _proposalsFuture = _hasRequestId
        ? DOVIAAPIDoviaHomeContextGroup.listQuoteProposalsCall.call(
            serviceRequestId: _requestId,
            authToken: token,
            limit: 20,
          )
        : DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall.call(
            authToken: token,
            limit: 20,
          );

    // El estatus de suscripción decide si la tarjeta refleja el descuento
    // Premium sobre el costo del proyecto (queda cacheado en el repo).
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

  bool get _hasRequestId => (_requestId?.isNotEmpty) ?? false;

  // ---------------------------------------------------------------------------
  // Extracción best-effort de los campos de la propuesta: el shape del backend
  // aún no está fijo, por eso cada getter prueba varias claves y cae a '-' para
  // que la tarjeta renderice siempre.
  // ---------------------------------------------------------------------------

  String? _str(dynamic value) =>
      (value is String && value.trim().isNotEmpty) ? value.trim() : null;

  String? _firstValue(List<dynamic> candidates) {
    for (final candidate in candidates) {
      final value = _str(candidate);
      if (value != null) return value;
      if (candidate is num) return candidate.toString();
    }
    return null;
  }

  Map? _asMap(dynamic value) => value is Map ? value : null;

  String _proposalId(Map<String, dynamic> proposal) =>
      _firstValue([proposal['id'], proposal['proposalId']]) ?? '';

  /// Solicitud a la que pertenece la propuesta: la fijada al abrir la pantalla
  /// o, si se listaron todas, la que venga en el propio objeto.
  String? _requestIdOf(Map<String, dynamic> proposal) {
    if (_hasRequestId) return _requestId;
    return _firstValue([
      proposal['serviceRequestId'],
      _asMap(proposal['serviceRequest'])?['id'],
    ]);
  }

  String _workDescription(Map<String, dynamic> proposal) =>
      _firstValue([
        proposal['workDescription'],
        proposal['description'],
        proposal['scopeOfWork'],
        _asMap(proposal['serviceRequest'])?['description'],
      ]) ??
      '-';

  String _estimatedTime(Map<String, dynamic> proposal) =>
      _firstValue([
        proposal['estimatedTime'],
        proposal['estimatedDuration'],
        proposal['duration'],
      ]) ??
      '-';

  /// Monto numérico de la primera clave que traiga un número usable. Tolera que
  /// el backend mande el precio como texto ("Q1,200.00").
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

  /// El backend ya descontó el beneficio del plan sobre el precio enviado, así
  /// que la pantalla no debe volver a aplicarlo.
  bool _discountAlreadyApplied(Map<String, dynamic> proposal) =>
      proposal['premiumDiscountApplied'] == true ||
      proposal['discountApplied'] == true;

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

  /// Costo final del proyecto. Si al cliente le corresponde el descuento del
  /// 35% por su plan Dovia Home, la tarjeta muestra el precio de lista tachado
  /// y el monto real a pagar.
  _ProposalPrice _price(Map<String, dynamic> proposal, bool isPremium) {
    final currency = _firstValue([proposal['currency']]) ?? 'GTQ';

    // `totalAmount` es el campo con el que la empresa proveedora envía el costo
    // del proyecto (POST .../quote-proposals, multipart file + totalAmount).
    final listPriceKeys = [
      proposal['totalAmount'],
      proposal['price'],
      proposal['amount'],
      proposal['totalPrice'],
      proposal['total'],
    ];
    // Precio final cuando el backend ya calculó el beneficio del plan.
    final discounted = _amount([
      proposal['finalPrice'],
      proposal['discountedPrice'],
      proposal['priceWithDiscount'],
      proposal['premiumPrice'],
    ]);
    final listed = _amount(listPriceKeys);

    if (listed == null && discounted == null) {
      // Sin monto interpretable se respeta el texto tal cual llegó.
      return _ProposalPrice(finalLabel: _firstValue(listPriceKeys) ?? '-');
    }

    if (discounted != null && listed != null && discounted < listed) {
      return _ProposalPrice(
        finalLabel: _formatAmount(discounted, currency),
        baseLabel: _formatAmount(listed, currency),
      );
    }

    final amount = discounted ?? listed!;
    if (isPremium && discounted == null && !_discountAlreadyApplied(proposal)) {
      return _ProposalPrice(
        finalLabel: _formatAmount(
          amount *
              (1 - DHCLIENTCotizacionesRecibidasWidget.premiumDiscountRate),
          currency,
        ),
        baseLabel: _formatAmount(amount, currency),
      );
    }
    return _ProposalPrice(finalLabel: _formatAmount(amount, currency));
  }

  /// Nombre del servicio con el que la solicitud queda registrada al agendar.
  String _serviceTitle(Map<String, dynamic> proposal) =>
      _firstValue([
        _asMap(proposal['serviceRequest'])?['title'],
        _asMap(proposal['serviceRequest'])?['serviceName'],
        proposal['serviceName'],
      ]) ??
      'Trabajo cotizado';

  String _warranty(Map<String, dynamic> proposal) =>
      _firstValue([
        proposal['warranty'],
        proposal['warrantyDescription'],
        proposal['guarantee'],
      ]) ??
      '-';

  /// Nombre de la cotización: se rotulan por orden de llegada siguiendo el
  /// diseño ("Cotización A", "Cotización B", …).
  String _proposalTitle(int index) =>
      'Cotización ${String.fromCharCode(65 + index)}';

  /// Empresa proveedora que envió la propuesta. Se muestra debajo del rótulo
  /// sólo cuando el backend la informa.
  String? _providerName(Map<String, dynamic> proposal) => _firstValue([
        _asMap(proposal['company'])?['name'],
        proposal['companyName'],
        _asMap(proposal['provider'])?['name'],
      ]);

  /// Normaliza el listado según el endpoint usado. Los listados de la API
  /// pueden venir como `data: [...]` o paginados como `data: { items: [...] }`,
  /// así que se desenvuelve el sobre antes de mapear.
  List<Map<String, dynamic>> _extractProposals(ApiCallResponse response) {
    final raw = _hasRequestId
        ? DOVIAAPIDoviaHomeContextGroup.listQuoteProposalsCall
            .proposalsList(response.jsonBody)
        : DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall
            .proposalsList(response.jsonBody);

    final items = <dynamic>[];
    for (final entry in raw ?? const []) {
      final page = _asMap(entry);
      final paged = page == null
          ? null
          : (page['items'] ?? page['results'] ?? page['data']);
      if (paged is List) {
        items.addAll(paged);
      } else {
        items.add(entry);
      }
    }

    return items
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Selección única (radio button): marcar una cotización desmarca la
  /// anterior. Volver a tapear la marcada la deja marcada.
  void _selectProposal(String proposalId) {
    if (_model.selectedProposalId == proposalId) return;
    safeSetState(() => _model.selectedProposalId = proposalId);
  }

  /// Acepta la propuesta marcada. Al confirmarse, la solicitud avanza con esa
  /// empresa proveedora y el cliente pasa al agendamiento/pago, donde el
  /// proyecto se cristaliza con fecha y hora.
  Future<void> _acceptSelected(
    List<Map<String, dynamic>> proposals,
    bool isPremium,
  ) async {
    final proposalId = _model.selectedProposalId;
    if (proposalId == null) return;

    final index = proposals.indexWhere((p) => _proposalId(p) == proposalId);
    if (index < 0) return;
    final accepted = proposals[index];

    final requestId = _requestIdOf(accepted);
    if (requestId == null || requestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No se pudo identificar la solicitud de la cotización.'),
        ),
      );
      return;
    }

    safeSetState(() => _model.isAccepting = true);
    try {
      final response =
          await DOVIAAPIDoviaHomeContextGroup.acceptQuoteProposalCall.call(
        serviceRequestId: requestId,
        proposalId: proposalId,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No se pudo aceptar la cotización. Intenta de nuevo.'),
          ),
        );
        return;
      }

      // Propuesta aceptada: el proyecto se cristaliza con esa empresa en el
      // paso de agendamiento (el cobro va contra el plan del cliente Premium).
      DHCLIENTCotizacionesRecibidasWidget.serviceRequestId = null;
      DHCLIENTInstalacionWidget.serviceTitle = _serviceTitle(accepted);
      // Anticipación mínima para agendar: 24h con plan, 36h sin él.
      DHCLIENTAgendaWidget.minAdvanceHours = isPremium ? 24 : 36;
      context.pushNamed(DHCLIENTAgendaWidget.routeName);
    } finally {
      if (mounted) {
        safeSetState(() => _model.isAccepting = false);
      }
    }
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
                      title: 'Cotizaciones Recibidas',
                      showMap: false,
                      showCurrency: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 120.0),
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
                          return _emptyState(response.succeeded);
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compara las propuestas y elige la que prefieras.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.publicSans(),
                                    color: const Color(0xFF00444B),
                                    fontSize: 14.0,
                                    letterSpacing: 0.28,
                                  ),
                            ),
                            const SizedBox(height: 16.0),
                            ...List.generate(
                              proposals.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _proposalCard(
                                    proposals[index], index, isPremium),
                              ),
                            ),
                            const SizedBox(height: 18.0),
                            _continueButton(proposals, isPremium),
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

  /// Tarjeta de una cotización recibida con su radio button de selección.
  Widget _proposalCard(
      Map<String, dynamic> proposal, int index, bool isPremium) {
    final id = _proposalId(proposal);
    final selected = id.isNotEmpty && _model.selectedProposalId == id;
    final providerName = _providerName(proposal);

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
                      _proposalTitle(index),
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
                    _proposalField(
                        'Trabajo a realizar:', _workDescription(proposal)),
                    _proposalField('Tiempo estimado del trabajo:',
                        _estimatedTime(proposal)),
                    _priceField(_price(proposal, isPremium)),
                    _proposalField('Garantía:', _warranty(proposal)),
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

  Widget _proposalField(String label, String value) {
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

  /// Precio del proyecto. Con el beneficio Premium se muestra el precio de
  /// lista tachado, el monto real a pagar y la etiqueta del descuento.
  Widget _priceField(_ProposalPrice price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Precio:',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.publicSans(),
                  color: const Color(0xFF007376),
                  fontSize: 12.0,
                ),
          ),
          if (price.hasDiscount)
            Text(
              price.baseLabel!,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.publicSans(),
                    color: const Color(0xFF6A7282),
                    fontSize: 12.0,
                    decoration: TextDecoration.lineThrough,
                  ),
            ),
          Text(
            price.finalLabel,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.publicSans(
                    fontWeight:
                        price.hasDiscount ? FontWeight.w700 : FontWeight.normal,
                  ),
                  color: const Color(0xFF007376),
                  fontSize: price.hasDiscount ? 14.0 : 12.0,
                  lineHeight: 1.3,
                ),
          ),
          if (price.hasDiscount)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCCE3E4),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                padding:
                    const EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DHCLIENTCotizacionesRecibidasWidget.premiumDiscountLabel,
                      style: GoogleFonts.publicSans(
                        color: const Color(0xFF007376),
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'DOVIA PREMIUM',
                      style: GoogleFonts.publicSans(
                        color: const Color(0xFF6A7282),
                        fontWeight: FontWeight.w600,
                        fontSize: 9.0,
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

  /// [Continuar]: inactivo hasta que el cliente marque una cotización.
  Widget _continueButton(List<Map<String, dynamic>> proposals, bool isPremium) {
    final enabled = _model.selectedProposalId != null && !_model.isAccepting;
    return FFButtonWidget(
      onPressed:
          enabled ? () async => _acceptSelected(proposals, isPremium) : null,
      text: _model.isAccepting ? 'Aceptando…' : 'Continuar',
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
