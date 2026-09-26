import '/backend/api_requests/api_dovia_home.dart';
import '/auth/custom_auth/auth_util.dart';
import '/dovia_home_associate/associate_nav.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_client/checkout_launcher.dart';
import '/dovia_home_client/proposal_fields.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_propuesta_enviada_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_propuesta_enviada_model.dart';

/// Vista de **sólo lectura** de una propuesta que el cliente **rechazó**.
///
/// Es el [Ver trabajo] de "Cotizaciones rechazadas" del historial. Las
/// enviadas y las aprobadas ya no pasan por acá: [DHASSOCIATECotizacionWidget]
/// se volvió dinámica y las muestra en su Estado 2/3, con banner y (aprobada)
/// el botón de datos del cliente. Una rechazada no tiene ningún estado
/// dinámico que seguir —ya se decidió—, así que se queda en esta vista fija.
///
/// No hay nada que operar acá y por eso no ofrece ninguna acción. Lo que sí
/// hace falta es poder releer **qué se ofreció** —monto y PDF— antes de
/// llamar al cliente o de armar una versión nueva.
///
/// Todo sale de la propuesta que ya trajo el listado
/// (`GET /dovia-home/associate/proposals`): el contrato no expone un detalle por
/// propuesta para el proveedor, así que la pantalla no vuelve a la red y no
/// puede quedar "cargando" contra un endpoint que no existe.
///
/// Tras un rechazo la oportunidad vuelve a "Cotizaciones activas" —el contrato
/// versiona las propuestas—, así que la pantalla lo dice en vez de ofrecer un
/// reenvío desde acá: la versión nueva se manda desde la oportunidad, que es
/// donde están el requerimiento y las fotos del cliente.
class DHASSOCIATEPropuestaEnviadaWidget extends StatefulWidget {
  const DHASSOCIATEPropuestaEnviadaWidget({
    super.key,
    this.routeId,
    this.routeProposalId,
  });

  /// Id del trabajo que viene en la ruta (`?id=`). Manda sobre el campo
  /// estático cuando no coinciden: ver [associateRouteParams].
  final String? routeId;

  /// Id de la propuesta que viene en la ruta (`?proposalId=`).
  final String? routeProposalId;

  static String routeName = 'DH_ASSOCIATE_PropuestaEnviada';
  static String routePath = '/dHASSOCIATEPropuestaEnviada';

  /// Propuesta a leer. Se inyecta antes de navegar, como el resto de las
  /// pantallas del asociado: go_router navega sólo por nombre.
  static Map<String, dynamic>? proposalData;

  /// Solicitud que cotiza esa propuesta, si sigue en el marketplace. Es de donde
  /// salen la fecha y la zona del trabajo, que el sobre de la propuesta no trae.
  static Map<String, dynamic>? requestData;

  @override
  State<DHASSOCIATEPropuestaEnviadaWidget> createState() =>
      _DHASSOCIATEPropuestaEnviadaWidgetState();
}

class _DHASSOCIATEPropuestaEnviadaWidgetState
    extends State<DHASSOCIATEPropuestaEnviadaWidget> {
  late DHASSOCIATEPropuestaEnviadaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEPropuestaEnviadaModel());

    _model.proposal = DHASSOCIATEPropuestaEnviadaWidget.proposalData;
    _model.request = resolveRouteRequest(
        DHASSOCIATEPropuestaEnviadaWidget.requestData, widget.routeId);
    DHASSOCIATEPropuestaEnviadaWidget.proposalData = null;
    DHASSOCIATEPropuestaEnviadaWidget.requestData = null;
    _loadFromRoute();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Abierta desde la ruta sin datos inyectados: pide la propuesta y el
  /// requerimiento que le faltan.
  Future<void> _loadFromRoute() async {
    final token = currentAuthenticationToken ?? '';
    final propId = widget.routeProposalId ?? '';
    final current = _model.proposal;
    if (propId.isNotEmpty &&
        (current == null || proposalId(current) != propId)) {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .getCompanyQuoteProposalCall
          .call(proposalId: propId, authToken: token);
      final data = response.succeeded
          ? getJsonField(response.jsonBody, r'''$.data''')
          : null;
      if (!mounted) return;
      if (data is Map) {
        safeSetState(() => _model.proposal = Map<String, dynamic>.from(data));
      }
    }
    final request = _model.request;
    if (isRouteStub(request)) {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .getCompanyQuoteServiceRequestCall
          .call(serviceRequestId: asrId(request!), authToken: token);
      final data = response.succeeded
          ? getJsonField(response.jsonBody, r'''$.data''')
          : null;
      if (!mounted) return;
      if (data is Map) {
        safeSetState(() => _model.request = Map<String, dynamic>.from(data));
      }
    }
  }

  bool get _isRejected =>
      _model.proposal != null &&
      proposalStatus(_model.proposal!) == kProposalRejected;

  Future<void> _openDocument(String url) async {
    if (await launchDoviaHomeDocument(url)) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No pudimos abrir tu presupuesto.')),
    );
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  Widget _label(String text) => Align(
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

  Widget _infoBox(String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 12.0,
                letterSpacing: 0.0,
                lineHeight: 1.4,
              ),
        ),
      );

  /// Qué trabajo se cotizó. Con la solicitud a la vista se agregan fecha y zona;
  /// sin ella queda el título que ya venía resuelto en el listado y se dice por
  /// qué no hay más: la cotización se cerró, no es que la app perdió el dato.
  Widget _buildWorkSummary() {
    final proposal = _model.proposal;
    if (proposal == null) {
      return _infoBox('No encontramos la propuesta. Vuelve a "Cotizaciones" y '
          'ábrela de nuevo.');
    }

    final request = _model.request;
    if (request == null) {
      final description = proposalDescription(proposal);
      return _infoBox(
        '${description ?? 'Cotización enviada'}\n'
        'Esta cotización ya no está publicada, así que no podemos mostrar la '
        'fecha ni la zona del trabajo.',
      );
    }

    return _infoBox(
      '${asrServiceName(request)}\n'
      '${asrLongDate(request)} · ${asrTimeLabel(request)}\n'
      '${asrZoneLabel(request)}',
    );
  }

  /// Estado de la propuesta, con la versión cuando el contrato la trae: tras un
  /// rechazo la empresa manda otra, y saber cuál se está leyendo es la única
  /// forma de no confundir dos presupuestos del mismo trabajo.
  Widget _buildStatus() {
    final proposal = _model.proposal;
    if (proposal == null) return _infoBox('Sin estado.');

    final version = proposalVersion(proposal);
    final versionLabel = version == null ? '' : '\nVersión $version';

    if (_isRejected) {
      return _infoBox(
        'Rechazada. El cliente no eligió este presupuesto. Si la cotización '
        'sigue abierta, vuelve a aparecer en "Cotizaciones activas" y puedes '
        'enviar una versión nueva desde ahí.$versionLabel',
      );
    }

    return _infoBox(
      'Enviada. El cliente la está comparando con las de otras empresas; '
      'cuando decida te avisamos.$versionLabel',
    );
  }

  Widget _buildAmount() {
    final proposal = _model.proposal;
    final amount = proposal == null ? null : proposalAmountLabel(proposal);
    return _infoBox(amount ??
        'Tu propuesta no registró un monto. El detalle está en el PDF que '
            'enviaste.');
  }

  /// El PDF es la propuesta en sí: el monto es sólo su resumen.
  Widget _buildDocument() {
    final proposal = _model.proposal;
    final url = proposal == null ? null : proposalDocumentUrl(proposal);

    if (url == null) {
      return _infoBox('No encontramos el PDF de esta propuesta.');
    }

    final name = proposalOriginalFileName(proposal!) ?? 'Ver presupuesto (PDF)';

    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () => _openDocument(url),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/page-edit.svg',
              width: 24.0,
              height: 24.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
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
        body: SafeArea(
          top: true,
          child: Stack(
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
                      model: _model.dHASSOCIATEHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATEHeaderWidget(
                        tittleText: 'Tu propuesta',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 35.0, 20.0, 140.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Trabajo cotizado'),
                          const SizedBox(height: 12.0),
                          _buildWorkSummary(),
                          const SizedBox(height: 21.0),
                          _label('Estado'),
                          const SizedBox(height: 12.0),
                          _buildStatus(),
                          const SizedBox(height: 21.0),
                          _label('Monto que enviaste'),
                          const SizedBox(height: 12.0),
                          _buildAmount(),
                          const SizedBox(height: 21.0),
                          _label('Presupuesto en PDF'),
                          const SizedBox(height: 12.0),
                          _buildDocument(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 5.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dHASSOCIATENavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATENavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
