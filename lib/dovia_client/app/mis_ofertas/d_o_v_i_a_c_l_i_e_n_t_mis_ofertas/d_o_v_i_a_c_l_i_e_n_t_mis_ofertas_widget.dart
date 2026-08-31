import '/core/result.dart';
import '/domain/client_offer_models.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/repositories/offers_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../cancelar_oferta_modal_widget.dart';
import '../client_offer_navigation.dart';
import '../mi_oferta_card_widget.dart';
import '../d_o_v_i_a_c_l_i_e_n_t_mis_ofertas_lista/d_o_v_i_a_c_l_i_e_n_t_mis_ofertas_lista_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_model.dart';

/// Panel centralizado de las ofertas que el usuario envió como cliente.
///
/// Tres carriles: "Ofertas realizadas" (el pipeline general, con todas las
/// ofertas en cualquier estado), "Contraoferta" (las que el dueño devolvió con
/// otro precio) y "Oferta aceptadas" (las que llegaron al cierre legal).
class DOVIACLIENTMisOfertasWidget extends StatefulWidget {
  const DOVIACLIENTMisOfertasWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisOfertas';
  static String routePath = '/dOVIACLIENTMisOfertas';

  @override
  State<DOVIACLIENTMisOfertasWidget> createState() =>
      _DOVIACLIENTMisOfertasWidgetState();
}

class _DOVIACLIENTMisOfertasWidgetState
    extends State<DOVIACLIENTMisOfertasWidget> {
  late DOVIACLIENTMisOfertasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  ClientOffersBoard _board = const ClientOffersBoard.empty();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisOfertasModel());

    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

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
                      child: const DOVIASHAREDHeaderWidget(
                        title: 'Mis Ofertas',
                        showMap: false,
                        showCurrency: false,
                        showLogo: false,
                      ),
                    ),
                    _searchField(),
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

  /// Barra de búsqueda de la cabecera del diseño. Filtra por el nombre del
  /// inmueble sobre las ofertas ya cargadas.
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

  List<ClientOffer> _visible(ClientOfferLane lane) {
    final query = (_model.searchController?.text ?? '').trim().toLowerCase();
    final offers = _board.recentIn(lane);
    if (query.isEmpty) return offers;
    return offers
        .where((o) => o.propertyName.toLowerCase().contains(query))
        .toList();
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _lane(ClientOfferLane.realizadas, topPadding: 8.0),
        _lane(ClientOfferLane.contraoferta),
        _lane(ClientOfferLane.aceptada),
      ],
    );
  }

  Widget _lane(ClientOfferLane lane, {double topPadding = 32.0}) {
    final offers = _visible(lane);
    // El punto rojo sólo se enciende donde hay novedad que revisar: una
    // contraoferta del dueño que el usuario todavía no abrió.
    final hasUnread = lane == ClientOfferLane.contraoferta &&
        _board.hasPendingCounterOffers(hasUnreadClientOfferUpdate);

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
        if (offers.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              lane.emptyMessage,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          )
        else
          SizedBox(
            height: lane == ClientOfferLane.realizadas ? 300.0 : 260.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (context, index) {
                final offer = offers[index];
                return MiOfertaCardWidget(
                  offer: offer,
                  lane: lane,
                  hasUnreadUpdate: lane == ClientOfferLane.contraoferta &&
                      offer.awaitsClientResponse &&
                      hasUnreadClientOfferUpdate(offer),
                  onOpen: () => _openOffer(offer),
                  onCancel: () => _cancelOffer(offer),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _openOffer(ClientOffer offer) async {
    await openClientOffer(context, offer);
    if (!mounted) return;
    await _loadOffers();
  }

  Future<void> _cancelOffer(ClientOffer offer) async {
    final reason = await showCancelarOfertaModal(context);
    if (reason == null || !mounted) return;

    final result = await context
        .read<OffersRepository>()
        .withdrawMyOffer(offerId: offer.offerId, reason: reason);
    if (!mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Retiramos tu oferta.'),
          backgroundColor: Color(0xFF555555),
          behavior: SnackBarBehavior.floating,
        ));
        await _loadOffers();
        break;
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFE85D75),
          behavior: SnackBarBehavior.floating,
        ));
        break;
    }
  }

  /// "Ver más" del carril, en la píldora del diseño.
  Widget _verMasPill(ClientOfferLane lane) {
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

  Future<void> _openLaneList(ClientOfferLane lane) async {
    await context.pushNamed(
      DOVIACLIENTMisOfertasListaWidget.routeName,
      queryParameters: {
        'lane': serializeParam(lane.slug, ParamType.String),
      }.withoutNulls,
    );
    if (!mounted) return;
    await _loadOffers();
  }
}
