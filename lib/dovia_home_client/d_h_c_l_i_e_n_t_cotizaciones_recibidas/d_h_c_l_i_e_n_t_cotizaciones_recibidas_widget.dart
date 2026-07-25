import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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

  String _price(Map<String, dynamic> proposal) {
    final amount = _firstValue([
      proposal['price'],
      proposal['amount'],
      proposal['totalPrice'],
      proposal['total'],
    ]);
    if (amount == null) return '-';
    // Si el backend ya envía el monto formateado no se le agrega la moneda.
    if (amount.contains(RegExp(r'[A-Za-z$]'))) return amount;
    final currency = _firstValue([proposal['currency']]) ?? 'GTQ';
    return '$currency $amount';
  }

  String _warranty(Map<String, dynamic> proposal) =>
      _firstValue([
        proposal['warranty'],
        proposal['warrantyDescription'],
        proposal['guarantee'],
      ]) ??
      '-';

  /// Nombre de la cotización. Si el backend no manda título ni proveedor se usa
  /// el esquema del diseño ("Cotización A", "Cotización B", …).
  String _proposalTitle(Map<String, dynamic> proposal, int index) =>
      _firstValue([
        proposal['title'],
        _asMap(proposal['company'])?['name'],
        proposal['companyName'],
      ]) ??
      'Cotización ${String.fromCharCode(65 + index)}';

  /// Normaliza el listado según el endpoint usado.
  List<Map<String, dynamic>> _extractProposals(ApiCallResponse response) {
    final raw = _hasRequestId
        ? DOVIAAPIDoviaHomeContextGroup.listQuoteProposalsCall
            .proposalsList(response.jsonBody)
        : DOVIAAPIDoviaHomeContextGroup.listClientProposalsCall
            .proposalsList(response.jsonBody);
    return (raw ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  void _toggleProposal(String proposalId) {
    safeSetState(() {
      // Selección única: volver a tapear la marcada la deselecciona.
      _model.selectedProposalId =
          _model.selectedProposalId == proposalId ? null : proposalId;
    });
  }

  /// Acepta la propuesta marcada. Al confirmarse, la solicitud avanza con ese
  /// proveedor y el cliente vuelve al Dashboard.
  Future<void> _acceptSelected(List<Map<String, dynamic>> proposals) async {
    final proposalId = _model.selectedProposalId;
    if (proposalId == null) return;

    final match = proposals.where((p) => _proposalId(p) == proposalId).toList();
    if (match.isEmpty) return;

    final requestId = _requestIdOf(match.first);
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

      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
            child: DHCLIENTExitoProgramarAgendaWidget(
              message:
                  'Aceptaste la cotización. Coordinaremos el trabajo con el proveedor y te avisaremos por la plataforma.',
            ),
          );
        },
      );
      if (mounted) {
        DHCLIENTCotizacionesRecibidasWidget.serviceRequestId = null;
        context.goNamed(DHCLIENTHomepageWidget.routeName);
      }
    } finally {
      if (mounted) {
        safeSetState(() => _model.isAccepting = false);
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
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      title: 'Cotizaciones\nrecibidas',
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
                                child: _proposalCard(proposals[index], index),
                              ),
                            ),
                            const SizedBox(height: 18.0),
                            _continueButton(proposals),
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

  /// Tarjeta de una cotización recibida con su checkbox de selección.
  Widget _proposalCard(Map<String, dynamic> proposal, int index) {
    final id = _proposalId(proposal);
    final selected = id.isNotEmpty && _model.selectedProposalId == id;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: id.isEmpty ? null : () => _toggleProposal(id),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: selected ? const Color(0xFF007376) : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 20.0, 12.0, 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _checkbox(selected),
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
                  const SizedBox(height: 8.0),
                  _proposalField(
                      'Trabajo a realizar:', _workDescription(proposal)),
                  _proposalField(
                      'Tiempo estimado del trabajo:', _estimatedTime(proposal)),
                  _proposalField('Precio:', _price(proposal)),
                  _proposalField('Garantía:', _warranty(proposal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Checkbox cuadrado con borde aqua del diseño.
  Widget _checkbox(bool selected) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF007376) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFF007376), width: 1.5),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 16.0)
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

  /// [Continuar]: inactivo hasta que el cliente marque una cotización.
  Widget _continueButton(List<Map<String, dynamic>> proposals) {
    final enabled = _model.selectedProposalId != null && !_model.isAccepting;
    return FFButtonWidget(
      onPressed: enabled ? () async => _acceptSelected(proposals) : null,
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
