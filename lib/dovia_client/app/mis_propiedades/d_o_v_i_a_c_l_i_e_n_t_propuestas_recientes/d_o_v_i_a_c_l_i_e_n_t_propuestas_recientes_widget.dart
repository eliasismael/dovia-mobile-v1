import '/core/result.dart';
import '/domain/owner_proposal_models.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/repositories/offers_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/header_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'owner_proposal_navigation.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propuestas_lista_widget.dart';
import 'propuesta_reciente_card_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propuestas_recientes_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_propuestas_recientes_model.dart';

/// Listado de propuestas recibidas sobre las propiedades del usuario.
///
/// Es la vista espejo de la del comprador: los mismos tres carriles lógicos
/// (Ofertas, Contraoferta y Oferta aceptada) pero desde el lado del dueño. Por
/// eso las tarjetas no exponen "Cancelar oferta": el propietario sólo entra al
/// detalle y allí resuelve con [Aceptar] / [Rechazar] / [Contraoferta].
class DOVIACLIENTPropuestasRecientesWidget extends StatefulWidget {
  const DOVIACLIENTPropuestasRecientesWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_PropuestasRecientes';
  static String routePath = '/dOVIACLIENTPropuestasRecientes';

  @override
  State<DOVIACLIENTPropuestasRecientesWidget> createState() =>
      _DOVIACLIENTPropuestasRecientesWidgetState();
}

class _DOVIACLIENTPropuestasRecientesWidgetState
    extends State<DOVIACLIENTPropuestasRecientesWidget> {
  late DOVIACLIENTPropuestasRecientesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  OffersRepository get _offersRepository => context.read<OffersRepository>();

  OwnerProposalsBoard _board = const OwnerProposalsBoard.empty();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTPropuestasRecientesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadProposals();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadProposals() async {
    final result = await _offersRepository.loadProposalsOnMyProperties();
    if (!mounted) return;
    safeSetState(() {
      _isLoading = false;
      switch (result) {
        case Success(:final data):
          _board = data;
          _errorMessage = null;
          break;
        case Failure(:final message):
          _errorMessage = message;
          break;
      }
    });
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
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        showLogo: openedFromHome(context),
                        showSupport: false,
                        title: 'Propuestas Recientes',
                        showMap: false,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: _buildBody(),
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
                            0.0, 0.0, 15.0, 12.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
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

  Widget _buildBody() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      // Cuenta sin verificar: reintentar no sirve hasta que un administrador
      // la verifique, así que solo se avisa.
      final pendingVerification =
          _errorMessage!.toLowerCase().contains('pendiente de verificaci');
      if (pendingVerification) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Text(
            'Tu cuenta está pendiente de verificación.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14.0,
                color: FlutterFlowTheme.of(context).secondaryText),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: FlutterFlowTheme.of(context).secondaryText),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                safeSetState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadProposals();
              },
              child: Text(
                'Reintentar',
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _lane(OwnerProposalLane.ofertas,
            emptyMessage: 'No has recibido nuevas ofertas.', topPadding: 24.0),
        _lane(OwnerProposalLane.contraoferta,
            emptyMessage: 'No tienes negociaciones con contraoferta.'),
        _lane(OwnerProposalLane.aceptada,
            emptyMessage: 'Todavía no tienes ofertas aceptadas.'),
      ],
    );
  }

  Widget _lane(
    OwnerProposalLane lane, {
    required String emptyMessage,
    double topPadding = 32.0,
  }) {
    final proposals = _board.activeIn(lane);
    final hasUnread = proposals.any(hasUnreadOwnerProposalUpdate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, topPadding, 0.0, 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lane.laneTitle,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600),
                          fontSize: 17.0,
                          letterSpacing: 0.33,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.3,
                        ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(width: 8.0),
                    Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDA0010),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              _verMasPill(lane),
            ],
          ),
        ),
        if (proposals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              emptyMessage,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          )
        else
          SizedBox(
            height: 260.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: proposals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (context, index) {
                final proposal = proposals[index];
                return PropuestaRecienteCardWidget(
                  proposal: proposal,
                  hasUnreadUpdate: hasUnreadOwnerProposalUpdate(proposal),
                  onOpen: () => _openProposal(proposal),
                );
              },
            ),
          ),
      ],
    );
  }

  /// "Ver más" del carril: la misma píldora que abre el carrusel del panel de
  /// Mis Propiedades.
  Widget _verMasPill(OwnerProposalLane lane) {
    return InkWell(
      onTap: () => _openLaneList(lane),
      borderRadius: BorderRadius.circular(99.0),
      child: Container(
        height: 30.0,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFFCCE3E4),
          borderRadius: BorderRadius.circular(99.0),
        ),
        child: Text(
          'Ver más',
          style: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.publicSans(),
                color: FlutterFlowTheme.of(context).primary,
                fontSize: 14.0,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }

  Future<void> _openProposal(OwnerProposal proposal) async {
    await openOwnerProposal(context, proposal);
    if (!mounted) return;
    await _loadProposals();
  }

  /// "Ver más" abre el listado completo del carril, con sus pestañas de
  /// filtrado (activas / rechazadas / proceso legal, según el carril).
  Future<void> _openLaneList(OwnerProposalLane lane) async {
    await context.pushNamed(
      DOVIACLIENTPropuestasListaWidget.routeName,
      queryParameters: {
        'lane': serializeParam(lane.slug, ParamType.String),
      }.withoutNulls,
    );
    if (!mounted) return;
    await _loadProposals();
  }
}
