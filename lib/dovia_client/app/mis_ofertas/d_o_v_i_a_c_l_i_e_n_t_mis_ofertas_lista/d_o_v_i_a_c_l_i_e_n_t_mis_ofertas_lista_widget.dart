import '/core/result.dart';
import '/domain/client_offer_models.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/repositories/offers_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/segmented_filter_bar/segmented_filter_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../client_offer_navigation.dart';
import '../mi_oferta_card_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_lista_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_lista_model.dart';

/// Listado completo de un carril de "Mis Ofertas": el destino del "Ver más"
/// de Ofertas realizadas, Contraoferta y Oferta aceptadas.
///
/// Muestra todos los inmuebles de esa categoría en grilla, con las mismas
/// acciones que la tarjeta del carrusel.
///
/// Los carriles que el diseño segmenta traen su propio menú de pestañas
/// ([ClientOfferLaneX.filters]): dos en "Ofertas realizadas" (Enviado /
/// Rechazada) y tres en "Ofertas aceptadas" (Proceso Legal / Finalizadas /
/// Calificadas), que siguen el cierre del trato.
class DOVIACLIENTMisOfertasListaWidget extends StatefulWidget {
  const DOVIACLIENTMisOfertasListaWidget({super.key, this.lane});

  /// Slug del carril: `realizadas`, `contraoferta` o `aceptada`.
  final String? lane;

  static String routeName = 'DOVIA_CLIENT_MisOfertasLista';
  static String routePath = '/dOVIACLIENTMisOfertasLista';

  @override
  State<DOVIACLIENTMisOfertasListaWidget> createState() =>
      _DOVIACLIENTMisOfertasListaWidgetState();
}

class _DOVIACLIENTMisOfertasListaWidgetState
    extends State<DOVIACLIENTMisOfertasListaWidget> {
  late DOVIACLIENTMisOfertasListaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final ClientOfferLane _lane;
  late ClientOfferFilter? _selectedFilter;

  ClientOffersBoard _board = const ClientOffersBoard.empty();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisOfertasListaModel());

    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    _lane = ClientOfferLaneX.fromSlug(widget.lane);
    _selectedFilter = _lane.filters.isEmpty ? null : _lane.filters.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadOffers();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    final result = await context.read<OffersRepository>().loadMyOffers();
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
                        title: _lane.listTitle,
                        showMap: false,
                        showCurrency: false,
                        showLogo: false,
                      ),
                    ),
                    if (_selectedFilter == null) _searchField(),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (_selectedFilter != null) ...[
                            SegmentedFilterBarWidget(
                              labels: _lane.filters
                                  .map((filter) => filter.label)
                                  .toList(),
                              selectedIndex:
                                  _lane.filters.indexOf(_selectedFilter!),
                              onSelected: (index) => safeSetState(
                                  () => _selectedFilter = _lane.filters[index]),
                            ),
                            const SizedBox(height: 20.0),
                          ],
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
                            0.0, 0.0, 15.0, 100.0),
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
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTMisOfertasWidget.routeName,
                      ),
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

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
      child: TextFormField(
        controller: _model.searchController,
        focusNode: _model.searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Búsqueda con IA',
          hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium,
        onChanged: (_) => safeSetState(() {}),
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
                _loadOffers();
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

    final query = (_model.searchController?.text ?? '').trim().toLowerCase();
    final inTab = _selectedFilter == null
        ? _board.inLane(_lane)
        : _board.byFilter(_selectedFilter!);
    final offers = query.isEmpty
        ? inTab
        : inTab
            .where((o) => o.propertyName.toLowerCase().contains(query))
            .toList();

    if (offers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Text(
          query.isEmpty
              ? (_selectedFilter?.emptyMessage ?? _lane.emptyMessage)
              : 'Ninguna oferta coincide con tu búsqueda.',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
      );
    }

    return _grid(offers);
  }

  /// Grilla del diseño: tantas tarjetas por fila como quepan, una sola columna
  /// cuando la pantalla es angosta.
  Widget _grid(List<ClientOffer> offers) {
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
          children: offers
              .map((offer) => MiOfertaCardWidget(
                    offer: offer,
                    lane: _lane,
                    width: cardWidth,
                    hasUnreadUpdate: _lane == ClientOfferLane.contraoferta &&
                        offer.awaitsClientResponse &&
                        hasUnreadClientOfferUpdate(offer),
                    tapToOpen: true,
                    showActions: false,
                    onOpen: () => _openOffer(offer),
                  ))
              .toList(),
        );
      },
    );
  }

  Future<void> _openOffer(ClientOffer offer) async {
    await openClientOffer(context, offer);
    if (!mounted) return;
    await _loadOffers();
  }

}
