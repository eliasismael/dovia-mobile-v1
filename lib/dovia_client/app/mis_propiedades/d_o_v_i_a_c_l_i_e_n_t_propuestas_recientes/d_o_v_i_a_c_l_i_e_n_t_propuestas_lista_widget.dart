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
import 'propuesta_reciente_card_widget.dart';
import 'propuestas_filter_bar_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propuestas_lista_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_propuestas_lista_model.dart';

/// Listado completo de un carril de propuestas recibidas: el destino del
/// "Ver más" de Ofertas, Contraoferta y Oferta aceptada.
///
/// Cada carril trae sus propias pestañas de filtrado (Activas/Rechazadas,
/// Enviada/Rechazada y Proceso Legal/Finalizadas/Calificadas), definidas en
/// [OwnerProposalLaneX.filters].
class DOVIACLIENTPropuestasListaWidget extends StatefulWidget {
  const DOVIACLIENTPropuestasListaWidget({super.key, this.lane});

  /// Slug del carril: `ofertas`, `contraoferta` u `aceptada`.
  final String? lane;

  static String routeName = 'DOVIA_CLIENT_PropuestasLista';
  static String routePath = '/dOVIACLIENTPropuestasLista';

  @override
  State<DOVIACLIENTPropuestasListaWidget> createState() =>
      _DOVIACLIENTPropuestasListaWidgetState();
}

class _DOVIACLIENTPropuestasListaWidgetState
    extends State<DOVIACLIENTPropuestasListaWidget> {
  late DOVIACLIENTPropuestasListaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final OwnerProposalLane _lane;
  late OwnerProposalFilter _selectedFilter;

  OwnerProposalsBoard _board = const OwnerProposalsBoard.empty();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTPropuestasListaModel());

    _lane = OwnerProposalLaneX.fromSlug(widget.lane);
    _selectedFilter = _lane.filters.first;

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
    final result =
        await context.read<OffersRepository>().loadProposalsOnMyProperties();
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
          // Sin SafeArea abajo, como en el inicio: el contenido pasa
          // por debajo de la barra flotante hasta el borde de la pantalla.
          bottom: false,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                // Lo que ocupa el indicador de inicio (iPhone), que ya no
                // descuenta el SafeArea: el final queda sobre la barra.
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        showLogo: openedFromHome(context),
                        showSupport: false,
                        title: _lane.listTitle,
                        showMap: false,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 8.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          PropuestasFilterBarWidget(
                            filters: _lane.filters,
                            selected: _selectedFilter,
                            onSelected: (filter) =>
                                safeSetState(() => _selectedFilter = filter),
                          ),
                          const SizedBox(height: 20.0),
                          _buildBody(),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60.0),
        child: Center(
          child: DoviaSpinner(),
        ),
      );
    }

    if (_errorMessage != null) {
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

    final proposals = _board.byFilter(_selectedFilter);
    if (proposals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Text(
          _selectedFilter.emptyMessage,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      );
    }

    return _grid(proposals);
  }

  /// Grilla del diseño: tantas tarjetas por fila como quepan, una sola columna
  /// cuando la pantalla es angosta.
  Widget _grid(List<OwnerProposal> proposals) {
    const spacing = 16.0;
    const preferredCardWidth = 253.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final columns = available < preferredCardWidth * 2 + spacing
            ? 1
            : (available + spacing) ~/ (preferredCardWidth + spacing);
        final cardWidth = (available - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: proposals
              .map((proposal) => PropuestaRecienteCardWidget(
                    proposal: proposal,
                    width: cardWidth,
                    hasUnreadUpdate: hasUnreadOwnerProposalUpdate(proposal),
                    onOpen: () => _openProposal(proposal),
                  ))
              .toList(),
        );
      },
    );
  }

  Future<void> _openProposal(OwnerProposal proposal) async {
    await openOwnerProposal(context, proposal);
    if (!mounted) return;
    await _loadProposals();
  }
}
