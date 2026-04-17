import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_metrics.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_offers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propiedad_publicada_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propiedad_publicada_model.dart';

class DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget(
      {super.key, this.propertyId});

  final String? propertyId;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_PropiedadPublicada';
  static String routePath = '/dOVIACLIENTMisPropiedadesPropiedadPublicada';

  @override
  State<DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget> createState() =>
      _DOVIACLIENTMisPropiedadesPropiedadPublicadaWidgetState();
}

class _DOVIACLIENTMisPropiedadesPropiedadPublicadaWidgetState
    extends State<DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget> {
  late DOVIACLIENTMisPropiedadesPropiedadPublicadaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Metrics
  int _views = 0;
  int _interactions = 0;
  int _visits = 0;
  int _offers = 0;

  // Visit lists
  List<dynamic> _pendingVisits = [];
  List<dynamic> _confirmedVisits = [];
  List<dynamic> _activeOffers = [];
  bool _isLoadingVisits = true;
  bool _isLoadingOffers = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesPropiedadPublicadaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _loadMetrics();
    _loadOwnerVisits();
    _loadPropertyOffers();
  }

  Future<void> _loadMetrics() async {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) return;

    final res = await DOVIAAPIMetricsContextGroup.getPropertyStatisticsCall.call(
      propertyId: widget.propertyId,
      bearerAuth: currentAuthenticationToken,
    );

    if (res.succeeded && mounted) {
      safeSetState(() {
        _views = getJsonField(res.jsonBody, r'''$.data.views''') ?? 0;
        _interactions =
            getJsonField(res.jsonBody, r'''$.data.interactions''') ?? 0;
        _visits = getJsonField(res.jsonBody, r'''$.data.visits''') ?? 0;
        _offers = getJsonField(res.jsonBody, r'''$.data.offers''') ?? 0;
      });
    }
  }

  Future<void> _loadOwnerVisits() async {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) {
      safeSetState(() => _isLoadingVisits = false);
      return;
    }
    final res =
        await DOVIAAPIVisitContextGroup.getOwnerPropertyVisitsCall.call(
      propertyId: widget.propertyId,
      authToken: currentAuthenticationToken,
    );

    if (mounted) {
      if (res.succeeded) {
        final raw = getJsonField(res.jsonBody, r'''$.data''');
        final List<dynamic> all = raw is List
            ? raw
            : (getJsonField(res.jsonBody, r'''$.data.items''') as List? ?? []);

        final now = DateTime.now();

        final pending = <dynamic>[];
        final confirmed = <dynamic>[];

        for (final v in all) {
          final statusRaw =
              (getJsonField(v, r'''$.status''') ?? '').toString().toUpperCase();
          final subStatusRaw =
              (getJsonField(v, r'''$.substatus''') ?? '').toString().toUpperCase();

          // Filter out cancelled / completed
          if (statusRaw == 'CANCELLED' || statusRaw == 'COMPLETED') continue;

          // Try to get the scheduled date
          final scheduledDateStr =
              getJsonField(v, r'''$.scheduledDate''')?.toString() ??
              getJsonField(v, r'''$.confirmedSlot.date''')?.toString() ??
              '';

          DateTime? scheduledDate;
          if (scheduledDateStr.isNotEmpty) {
            scheduledDate = DateTime.tryParse(scheduledDateStr);
          }

          // Skip past visits (only if we have a date)
          if (scheduledDate != null && scheduledDate.isBefore(now)) continue;

          if (subStatusRaw.contains('PENDING') ||
              statusRaw.contains('PENDING') ||
              subStatusRaw.contains('AWAITING_OWNER')) {
            pending.add(v);
          } else if (statusRaw.contains('CONFIRMED') ||
              statusRaw.contains('SCHEDULED') ||
              subStatusRaw.contains('CONFIRMED')) {
            confirmed.add(v);
          } else {
            // Default: treat as pending confirmation if future
            pending.add(v);
          }
        }

        safeSetState(() {
          _pendingVisits = pending;
          _confirmedVisits = confirmed;
          _isLoadingVisits = false;
        });
      } else {
        safeSetState(() => _isLoadingVisits = false);
      }
    }
  }

  Future<void> _loadPropertyOffers() async {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) {
      safeSetState(() => _isLoadingOffers = false);
      return;
    }
    final res =
        await DOVIAAPIOfferContextGroup.listOffersByPropertyCall.call(
      propertyId: widget.propertyId,
      offerStatus: 'ACTIVE',
    );

    if (mounted) {
      if (res.succeeded) {
        final raw = getJsonField(res.jsonBody, r'''$.data''');
        final List<dynamic> all = raw is List
            ? raw
            : (getJsonField(res.jsonBody, r'''$.data.items''') as List? ?? []);

        // Keep only active (not rejected / cancelled)
        final active = all.where((o) {
          final status =
              (getJsonField(o, r'''$.offerStatus''') ?? '').toString().toUpperCase();
          return status != 'REJECTED' &&
              status != 'CANCELLED' &&
              status != 'REJECTED_BY_OWNER';
        }).toList();

        safeSetState(() {
          _activeOffers = active;
          _isLoadingOffers = false;
        });
      } else {
        safeSetState(() => _isLoadingOffers = false);
      }
    }
  }

  String _formatDate(dynamic visitJson) {
    final raw = getJsonField(visitJson, r'''$.scheduledDate''')?.toString() ??
        getJsonField(visitJson, r'''$.confirmedSlot.date''')?.toString() ??
        getJsonField(visitJson, r'''$.proposedTimeSlots[0].date''')?.toString() ??
        '';
    if (raw.isEmpty) return 'Fecha por confirmar';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatOfferDate(dynamic offerJson) {
    final raw = getJsonField(offerJson, r'''$.createdAt''')?.toString() ?? '';
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────

  Widget _metricCard(
      BuildContext context, String label, int value, String iconAsset) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SvgPicture.asset(iconAsset, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: FlutterFlowTheme.of(context).primaryText,
        ),
      ),
    );
  }

  Widget _visitCard(
    BuildContext context,
    dynamic visitJson, {
    required String statusLabel,
    required VoidCallback onViewTap,
  }) {
    final date = _formatDate(visitJson);
    final buyerName =
        getJsonField(visitJson, r'''$.buyer.name''')?.toString() ??
        getJsonField(visitJson, r'''$.requester.name''')?.toString() ??
        'Visitante';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  buyerName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_red_eye_outlined,
                color: FlutterFlowTheme.of(context).primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerCard(BuildContext context, dynamic offerJson) {
    final offerType = getJsonField(offerJson, r'''$.offerType''')?.toString() ?? '';
    final paymentMethod =
        getJsonField(offerJson, r'''$.offerData.paymentMethod''')?.toString() ??
        '';
    final proposedAmount =
        getJsonField(offerJson, r'''$.offerData.proposedAmount''') ?? 0;
    final dateLabel = _formatOfferDate(offerJson);
    final offerId = getJsonField(offerJson, r'''$.id''')?.toString() ?? '';

    String typeLabel = offerType == 'RENT' ? 'Renta' : 'Compra';
    if (paymentMethod.isNotEmpty) {
      final pm = paymentMethod.replaceAll('_', ' ');
      typeLabel += ' · $pm';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Propuesta recibida',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  typeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$$proposedAmount',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                if (dateLabel.isNotEmpty)
                  Text(
                    dateLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (offerId.isNotEmpty) {
                context.pushNamed(
                  DOVIACLIENTMisPropiedadesPropuestaWidget.routeName,
                  queryParameters: {
                    'proposalType': serializeParam(
                        offerType.toLowerCase(), ParamType.String),
                    'offerId':
                        serializeParam(offerId, ParamType.String),
                  }.withoutNulls,
                );
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_red_eye_outlined,
                color: FlutterFlowTheme.of(context).primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
      ),
    );
  }

  void _showPausaModal() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Pausar propiedad',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Al pausar la propiedad, se ocultará del mapa y búsquedas temporalmente. Podrás reactivarla cuando quieras.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF007376)),
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: llamar API de cambio de estado a PAUSED
            },
            child: const Text('Pausar'),
          ),
        ],
      ),
    );
  }

  void _showNoDisponibleModal() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Dar de baja la propiedad?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Esta acción eliminará la propiedad del mapa, favoritos y cancelará todas las operaciones activas. Esta acción es definitiva.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: llamar API de cambio de estado a INACTIVE
            },
            child: const Text('Dar de baja'),
          ),
        ],
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
                      child: const DOVIASHAREDHeaderWidget(
                          showMap: false,
                          showCurrency: false,
                          title: 'Propiedad\npublicada'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── 1. PANEL DE MÉTRICAS ──────────────────────────
                          const SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _metricCard(
                                context,
                                'Vieron tu propiedad',
                                _views,
                                'assets/images/IconoProximosTrabajos.svg',
                              ),
                              _metricCard(
                                context,
                                'Interactuaron',
                                _interactions,
                                'assets/images/IconoProximosTrabajos.svg',
                              ),
                              _metricCard(
                                context,
                                'Visitas a tu propiedad',
                                _visits,
                                'assets/images/IconoProximosTrabajos.svg',
                              ),
                              _metricCard(
                                context,
                                'Propuestas a tu propiedad',
                                _offers,
                                'assets/images/IconoProximosTrabajos.svg',
                              ),
                            ],
                          ),

                          // ── 2A. CONFIRMA PRÓXIMAS VISITAS ─────────────────
                          _sectionTitle(context, 'Confirma próximas visitas'),
                          if (_isLoadingVisits)
                            const Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            ))
                          else if (_pendingVisits.isEmpty)
                            _emptyState(context,
                                'No hay visitas pendientes de confirmación.')
                          else
                            ..._pendingVisits.map((v) {
                              final visitId =
                                  getJsonField(v, r'''$.id''')?.toString() ??
                                      '';
                              return _visitCard(
                                context,
                                v,
                                statusLabel: 'Pendiente de confirmación',
                                onViewTap: () {
                                  context.pushNamed(
                                    DOVIACLIENTSobreMiVisitaWidget.routeName,
                                    queryParameters: {
                                      'propertyId': serializeParam(
                                          widget.propertyId, ParamType.String),
                                      'visitId': serializeParam(
                                          visitId, ParamType.String),
                                    }.withoutNulls,
                                  );
                                },
                              );
                            }),

                          // ── 2B. VISITAS CONFIRMADAS ───────────────────────
                          _sectionTitle(context, 'Visitas confirmadas'),
                          if (_isLoadingVisits)
                            const SizedBox()
                          else if (_confirmedVisits.isEmpty)
                            _emptyState(
                                context, 'No hay visitas confirmadas próximas.')
                          else
                            ..._confirmedVisits.map((v) {
                              final visitId =
                                  getJsonField(v, r'''$.id''')?.toString() ??
                                      '';
                              return _visitCard(
                                context,
                                v,
                                statusLabel: 'Visita confirmada',
                                onViewTap: () {
                                  context.pushNamed(
                                    DOVIACLIENTSobreMiVisitaWidget.routeName,
                                    queryParameters: {
                                      'propertyId': serializeParam(
                                          widget.propertyId, ParamType.String),
                                      'visitId': serializeParam(
                                          visitId, ParamType.String),
                                    }.withoutNulls,
                                  );
                                },
                              );
                            }),

                          // ── 2C. PROPUESTAS ────────────────────────────────
                          _sectionTitle(context, 'Propuestas'),
                          if (_isLoadingOffers)
                            const Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            ))
                          else if (_activeOffers.isEmpty)
                            _emptyState(
                                context, 'No hay propuestas activas por ahora.')
                          else
                            ..._activeOffers
                                .map((o) => _offerCard(context, o)),

                          // ── 3. BOTONES DE ACCIÓN ──────────────────────────
                          const SizedBox(height: 32),

                          // Editar — ancho completo
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                              ),
                              onPressed: () {
                                context.pushNamed(
                                  DOVIACLIENTMisPropiedadesVenderRentarWidget
                                      .routeName,
                                  queryParameters: {
                                    'propertyId': serializeParam(
                                        widget.propertyId, ParamType.String),
                                  }.withoutNulls,
                                );
                              },
                              child: Text(
                                'Editar información de tu propiedad',
                                style: GoogleFonts.inter(
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Pausa + No disponible — mitad de ancho c/u
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24)),
                                    ),
                                    onPressed: _showPausaModal,
                                    child: Text(
                                      'Propiedad en pausa',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFD32F2F), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24)),
                                    ),
                                    onPressed: _showNoDisponibleModal,
                                    child: Text(
                                      'No disponible',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFD32F2F),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed Dovia Icon + Navbar
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
