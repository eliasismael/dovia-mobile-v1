import '/dovia_client/app/principal/todas_las_fotos/todas_las_fotos_widget.dart';
import '/dovia_client/app/principal/agendar_cita/agendar_cita_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/repositories/visits_repository.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/backend/api_requests/api_properties.dart';
import '/backend/api_requests/api_offers.dart';
import '/auth/custom_auth/auth_util.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_model.dart';

class DOVIACLIENTPropiedadSeleccionadaWidget extends StatefulWidget {
  const DOVIACLIENTPropiedadSeleccionadaWidget({
    super.key,
    required this.propertyId,
  });

  final String? propertyId;

  static String routeName = 'DOVIA_CLIENT_PropiedadSeleccionada';
  static String routePath = '/dOVIACLIENTPropiedadSeleccionada';

  @override
  State<DOVIACLIENTPropiedadSeleccionadaWidget> createState() =>
      _DOVIACLIENTPropiedadSeleccionadaWidgetState();
}

class _DOVIACLIENTPropiedadSeleccionadaWidgetState
    extends State<DOVIACLIENTPropiedadSeleccionadaWidget> {
  late DOVIACLIENTPropiedadSeleccionadaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _propertyName = '';
  List<String> _listingType = [];

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => DOVIACLIENTPropiedadSeleccionadaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      if (widget.propertyId != null && widget.propertyId!.isNotEmpty) {
        final response = await DOVIAAPIPropertyContextGroup.getPropertyByIDCall
            .call(propertyId: widget.propertyId);
        if (response.succeeded && mounted) {
          final name =
              getJsonField(response.jsonBody, r'''$.data.name''')?.toString();
          if (name != null && name.isNotEmpty) {
            safeSetState(() => _propertyName = name);
          }
          final listingTypeRaw =
              getJsonField(response.jsonBody, r'''$.data.listingType''');
          if (listingTypeRaw != null && mounted) {
            final parsed =
                (listingTypeRaw as List?)?.map((e) => e.toString()).toList() ??
                    [];
            safeSetState(() => _listingType = parsed);
          }
        }
      }
    });
  }

  Future<void> _handleAgendarCita() async {
    if (!mounted) return;

    if (FFAppState().UserRole == 'VISITOR') {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(dialogContext).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: const VisitorRestrictionPopupWidget(),
          ),
        ),
      );
      return;
    }

    final repo = context.read<VisitsRepository>();
    final hasPending =
        await repo.hasActiveVisitForProperty(widget.propertyId ?? '');

    if (!mounted) return;

    if (hasPending) {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black54,
        builder: (dialogContext) => Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: _PendingVisitDialog(
            onViewVisits: () {
              Navigator.of(dialogContext).pop();
              context.pushNamed(DOVIACLIENTMisVisitasWidget.routeName);
            },
            onDismiss: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(dialogContext).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: AgendarCitaWidget(
              propertyId: widget.propertyId,
              hasPendingVisit: false,
              onNavigateToVisits: () {
                Navigator.of(dialogContext).pop();
                context.pushNamed(DOVIACLIENTMisVisitasWidget.routeName);
              },
            ),
          ),
        ),
      );
    }
  }

  Future<void> _handleOfertar() async {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) return;

    if (FFAppState().UserRole == 'VISITOR') {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(dialogContext).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: const VisitorRestrictionPopupWidget(),
          ),
        ),
      );
      return;
    }

    // Check for active offers on this property for the current user
    final offersResponse =
        await DOVIAAPIOfferContextGroup.listMyOffersCall.call(
      authToken: currentAuthenticationToken,
    );

    if (!mounted) return;

    if (offersResponse.succeeded) {
      final items =
          getJsonField(offersResponse.jsonBody, r'''$.data.items''') as List? ??
              [];
      final hasActiveOffer = items.any((item) {
        final propertyId =
            getJsonField(item, r'''$.property.id''')?.toString() ?? '';
        final status =
            getJsonField(item, r'''$.status''')?.toString().toUpperCase() ?? '';
        return propertyId == widget.propertyId &&
            status != 'CANCELLED' &&
            status != 'REJECTED';
      });

      if (hasActiveOffer) {
        _showActiveOfferModal();
        return;
      }
    }

    // No active offer — route based on listingType
    final hasSale = _listingType.contains('SALE');
    final hasRent = _listingType.contains('RENT');

    if (hasSale && hasRent) {
      // Mixed property — show selection screen
      context.pushNamed(
        DOVIACLIENTOfertarWidget.routeName,
        queryParameters: {
          'propertyId': serializeParam(widget.propertyId, ParamType.String),
        }.withoutNulls,
      );
    } else if (hasSale) {
      context.pushNamed(
        DOVIACLIENTOfertaCompraWidget.routeName,
        queryParameters: {
          'propertyId': serializeParam(widget.propertyId, ParamType.String),
        }.withoutNulls,
      );
    } else {
      // RENT only (or unknown)
      context.pushNamed(
        DOVIACLIENTOfertaRentaWidget.routeName,
        queryParameters: {
          'propertyId': serializeParam(widget.propertyId, ParamType.String),
        }.withoutNulls,
      );
    }
  }

  void _showActiveOfferModal() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ya tienes una oferta en curso',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ya tienes una oferta pendiente de aceptar o una contraoferta para este inmueble. Visualiza el estatus en la pantalla de Mis Ofertas.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: FlutterFlowTheme.of(context).primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancelar',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context
                            .pushNamed(DOVIACLIENTMisOfertasWidget.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Ir a Mis ofertas',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                      child: DOVIASHAREDHeaderWidget(
                        title: _propertyName.isNotEmpty
                            ? _propertyName
                            : 'Propiedad',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 1.0,
                            child: custom_widgets.PropertySelectionWidget(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              latitude: -36.0,
                              longitude: -34.0,
                              mapZoom: 5,
                              staticMapImagePath: '\"\"',
                              onAgendarCita: _handleAgendarCita,
                              onOfertar: _handleOfertar,
                              onSeeAllImages: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.9,
                                          child: const TodasLasFotosWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
                            ),
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

class _PendingVisitDialog extends StatelessWidget {
  final VoidCallback onViewVisits;
  final VoidCallback onDismiss;

  const _PendingVisitDialog({
    required this.onViewVisits,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF007376),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ya tienes una visita en proceso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00444B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ya solicitaste o tienes confirmada una cita para esta propiedad. Puedes revisar el estado en tu sección de visitas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onViewVisits,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007376),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ver mis visitas',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onDismiss,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF007376),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Volver a la propiedad',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
