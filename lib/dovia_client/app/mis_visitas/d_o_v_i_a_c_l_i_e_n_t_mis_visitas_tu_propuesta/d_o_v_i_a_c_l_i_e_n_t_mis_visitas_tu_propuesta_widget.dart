import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import '/backend/api_requests/api_offers.dart';
import '/auth/custom_auth/auth_util.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_tu_propuesta_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_tu_propuesta_model.dart';

class DOVIACLIENTMisVisitasTuPropuestaWidget extends StatefulWidget {
  const DOVIACLIENTMisVisitasTuPropuestaWidget({
    super.key,
    this.propuestaState,
    this.paymentMethod,
    this.offerId,
    this.ratedRoles,
  });

  final String? propuestaState;
  final String? paymentMethod;
  final String? offerId;

  /// Roles legales ya calificados, separados por coma: sus tarjetas se
  /// muestran como archivo, sin calificar ni reportar.
  final String? ratedRoles;

  static String routeName = 'DOVIA_CLIENT_MisVisitas_TuPropuesta';
  static String routePath = '/dOVIACLIENTMisVisitasTuPropuesta';

  @override
  State<DOVIACLIENTMisVisitasTuPropuestaWidget> createState() =>
      _DOVIACLIENTMisVisitasTuPropuestaWidgetState();
}

class _DOVIACLIENTMisVisitasTuPropuestaWidgetState
    extends State<DOVIACLIENTMisVisitasTuPropuestaWidget> {
  late DOVIACLIENTMisVisitasTuPropuestaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  dynamic _offerData;
  bool _isLoadingOffer = true;

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => DOVIACLIENTMisVisitasTuPropuestaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadOffer();
    });
  }

  Future<void> _loadOffer() async {
    if (widget.offerId == null || widget.offerId!.isEmpty) {
      safeSetState(() {
        _isLoadingOffer = false;
      });
      return;
    }
    final res = await DOVIAAPIOfferContextGroup.getOfferByIDCall.call(
      offerId: widget.offerId,
      authToken: currentAuthenticationToken,
    );
    if (!mounted) return;
    if (res.succeeded) {
      safeSetState(() {
        _offerData = getJsonField(res.jsonBody, r'''$.data''') ??
            getJsonField(res.jsonBody, r'''$.offer''') ??
            res.jsonBody;
        _isLoadingOffer = false;
      });
    } else {
      safeSetState(() {
        _isLoadingOffer = false;
      });
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
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              // El header queda fijo y la propuesta ocupa el resto: ella misma
              // hace scroll y deja lugar para la navbar, sin espacio de más.
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      title: 'Tu propuesta',
                      showMap: false,
                      showCurrency: false,
                      showLogo: false,
                      hideActions: true,
                    ),
                  ),
                  Expanded(
                    child: custom_widgets.ProposalScreen(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: double.infinity,
                      state: widget.propuestaState ?? 'pending',
                      paymentMethod: widget.paymentMethod ?? '',
                      offerData: _offerData,
                      ratedRoles: widget.ratedRoles ?? '',
                    ),
                  ),
                ],
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
}
