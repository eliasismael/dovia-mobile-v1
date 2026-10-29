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
import '../client_offer_navigation.dart';
import '../mi_oferta_card_widget.dart';
import '../d_o_v_i_a_c_l_i_e_n_t_mis_ofertas_lista/d_o_v_i_a_c_l_i_e_n_t_mis_ofertas_lista_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_model.dart';
import '/shared_components/dovia_spinner.dart';
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
                      child: const DOVIASHAREDHeaderWidget(
                        showLogo: true,
                        showSupport: false,
                        title: 'Mis Ofertas',
                        showMap: false,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 24.0, 20.0, 100.0),
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

    // Si hay alguna oferta aceptada, ese carril va primero: es lo más
    // importante que tiene en curso el usuario.
    final lanes = _board.inLane(ClientOfferLane.aceptada).isNotEmpty
        ? const [
            ClientOfferLane.aceptada,
            ClientOfferLane.realizadas,
            ClientOfferLane.contraoferta,
          ]
        : const [
            ClientOfferLane.realizadas,
            ClientOfferLane.contraoferta,
            ClientOfferLane.aceptada,
          ];
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        for (var i = 0; i < lanes.length; i++)
          i == 0 ? _lane(lanes[i], topPadding: 8.0) : _lane(lanes[i]),
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
          // Sin alto fijo: el carril mide lo que la tarjeta más alta, así no
          // queda un hueco hasta el carril siguiente. Son pocas tarjetas por
          // carril, por eso alcanza con una fila en vez de un ListView.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < offers.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12.0),
                  MiOfertaCardWidget(
                    offer: offers[i],
                    lane: lane,
                    hasUnreadUpdate: lane == ClientOfferLane.contraoferta &&
                        offers[i].awaitsClientResponse &&
                        hasUnreadClientOfferUpdate(offers[i]),
                    onOpen: () => _openOffer(offers[i]),
                  ),
                ],
              ],
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

  /// "Ver más" del carril: texto sin fondo, igual que en Mis Visitas.
  Widget _verMasPill(ClientOfferLane lane) {
    return InkWell(
      onTap: () => _openLaneList(lane),
      child: Text(
        'Ver más',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primary,
              fontSize: 14.0,
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
