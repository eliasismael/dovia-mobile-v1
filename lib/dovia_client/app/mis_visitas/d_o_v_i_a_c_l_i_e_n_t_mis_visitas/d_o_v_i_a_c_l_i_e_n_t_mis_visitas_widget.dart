import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/api_requests/api_offers.dart';
import '/backend/api_requests/api_manager.dart';
import '/auth/custom_auth/auth_util.dart';
import 'package:intl/intl.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_visitas_model.dart';

class DOVIACLIENTMisVisitasWidget extends StatefulWidget {
  const DOVIACLIENTMisVisitasWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_MisVisitas';
  static String routePath = '/dOVIACLIENTMisVisitas';

  @override
  State<DOVIACLIENTMisVisitasWidget> createState() =>
      _DOVIACLIENTMisVisitasWidgetState();
}

class _DOVIACLIENTMisVisitasWidgetState
    extends State<DOVIACLIENTMisVisitasWidget> {
  late DOVIACLIENTMisVisitasModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisVisitasModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIASHAREDHeaderWidget(
                        title: 'Mis visitas',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 53.0, 0.0, 0.0),
                              child: Text(
                                'Tus próximas vistas',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 17.0,
                                      letterSpacing: 0.33,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      lineHeight: 1.3,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 15.0, 0.0, 0.0),
                            child: Text(
                              'No tienes visitas próximas.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                'Tus visitas anteriores',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 17.0,
                                      letterSpacing: 0.33,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      lineHeight: 1.3,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Text(
                              'No tienes visitas anteriores.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 53.0, 0.0, 0.0),
                              child: Text(
                                'Tus ofertas',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 17.0,
                                      letterSpacing: 0.33,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      lineHeight: 1.3,
                                    ),
                              ),
                            ),
                          ),
                          FutureBuilder<ApiCallResponse>(
                            future: DOVIAAPIOfferContextGroup.listMyOffersCall.call(
                              authToken: currentAuthenticationToken,
                              limit: '10',
                              page: '1',
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final res = snapshot.data!;
                              if (!res.succeeded) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                  child: Text('Error cargando ofertas.', style: TextStyle(color: Colors.red)),
                                );
                              }
                              final data = getJsonField(res.jsonBody, r'''$.data.items''') ?? getJsonField(res.jsonBody, r'''$.data''') ?? [];
                              final offers = data is List ? data : (data is Map && data['items'] != null ? data['items'] as List : [data]);
                              if (offers.isEmpty || (offers.length == 1 && offers[0] == null)) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                  child: Text(
                                    'No tienes ofertas activas.',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                        ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: offers.length,
                                itemBuilder: (context, index) {
                                  final offer = offers[index];
                                  final offerId = offer['id'] ?? offer['_id'] ?? offer['offerId'] ?? '';
                                  final amountRaw = offer['offerData']?['proposedAmount'] ?? offer['proposedAmount'] ?? offer['amount'];
                                  final double amountDouble = amountRaw is num ? amountRaw.toDouble() : double.tryParse(amountRaw?.toString() ?? '') ?? 0.0;
                                  final amountStr = NumberFormat.currency(symbol: '', decimalDigits: 0).format(amountDouble);
                                  final currency = offer['offerData']?['currency']?.toString() ?? offer['currency']?.toString() ?? 'USD';
                                  final paymentMethod = offer['offerData']?['paymentMethod']?.toString() ?? offer['paymentMethod']?.toString() ?? '';
                                  final processStatus = offer['processStatus']?.toString() ?? '';
                                  final offerStatus = offer['offerStatus']?.toString() ?? offer['status']?.toString() ?? 'pending';
                                  final status = processStatus.isNotEmpty ? processStatus : offerStatus;
                                  
                                  final property = offer['property'] ?? offer['propertyId'];
                                  final propertyName = property is Map ? (property['title'] ?? property['name'] ?? 'Propiedad') : 'Propiedad';

                                  return Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                    child: InkWell(
                                      onTap: () {
                                        context.pushNamed(
                                          'DOVIA_CLIENT_MisVisitas_TuPropuesta',
                                          queryParameters: {
                                            'offerId': offerId,
                                            'paymentMethod': paymentMethod,
                                            'propuestaState': status,
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    propertyName,
                                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                      font: GoogleFonts.publicSans(fontWeight: FontWeight.bold),
                                                      fontSize: 16.0,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    status.toUpperCase(),
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 10.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.local_offer_outlined, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Oferta: $currency \$ $amountStr',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.publicSans(fontWeight: FontWeight.w500),
                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTMisVisitasWidget.routeName,
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
}
