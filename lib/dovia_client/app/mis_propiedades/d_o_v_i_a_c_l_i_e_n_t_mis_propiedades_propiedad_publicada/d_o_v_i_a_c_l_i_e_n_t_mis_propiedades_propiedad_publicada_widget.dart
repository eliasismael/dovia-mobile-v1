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
import '/backend/api_requests/api_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propiedad_publicada_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propiedad_publicada_model.dart';

class DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget(
      {super.key, this.propertyId, this.propertyStatus});

  final String? propertyId;
  /// Status passed from the list screen (GET /properties/{id} doesn't return status)
  final String? propertyStatus;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_PropiedadPublicada';
  static String routePath = '/dOVIACLIENTMisPropiedadesPropiedadPublicada';

  @override
  State<DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget> createState() =>
      _DOVIACLIENTMisPropiedadesPropiedadPublicadaWidgetState();
}

class _DOVIACLIENTMisPropiedadesPropiedadPublicadaWidgetState
    extends State<DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget>
    with TickerProviderStateMixin {
  late DOVIACLIENTMisPropiedadesPropiedadPublicadaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ─── Colors ───────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF007376);
  static const Color _primaryDark = Color(0xFF00444B);
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _bannerGreen = Color(0xFF005F62);

  // ─── Metrics ──────────────────────────────────────────────────────────────
  int _views = 0;
  int _interactions = 0;
  int _visits = 0;
  int _offers = 0;

  // ─── Visit / offer lists ───────────────────────────────────────────────────
  List<dynamic> _pendingVisits = [];
  List<dynamic> _confirmedVisits = [];
  List<dynamic> _activeOffers = [];
  bool _isLoadingVisits = true;
  bool _isLoadingOffers = true;

  // ─── Property data ─────────────────────────────────────────────────────────
  dynamic _propertyData;
  // Pre-initialized from nav param since GET /properties/{id} omits 'status'
  late String _propertyStatus;
  bool _isLoadingProperty = true;

  // ─── Accordion state ──────────────────────────────────────────────────────
  bool _internalInfoExpanded = false;
  bool _documentsExpanded = false;

  // ─── Animation controllers for accordions ─────────────────────────────────
  late AnimationController _internalInfoController;
  late AnimationController _documentsController;
  late Animation<double> _internalInfoAnimation;
  late Animation<double> _documentsAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize status from nav param immediately — API response omits 'status'
    _propertyStatus = widget.propertyStatus ?? '';
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesPropiedadPublicadaModel());

    _internalInfoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _documentsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _internalInfoAnimation = CurvedAnimation(
      parent: _internalInfoController,
      curve: Curves.easeInOut,
    );
    _documentsAnimation = CurvedAnimation(
      parent: _documentsController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _loadPropertyData();
    _loadMetrics();
    _loadOwnerVisits();
    _loadPropertyOffers();
  }

  @override
  void dispose() {
    _internalInfoController.dispose();
    _documentsController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ─── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadPropertyData() async {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) {
      safeSetState(() => _isLoadingProperty = false);
      return;
    }
    final res = await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
      propertyId: widget.propertyId,
    );
    if (res.succeeded && mounted) {
      safeSetState(() {
        _propertyData = getJsonField(res.jsonBody, r'''$.data.data''') ??
            getJsonField(res.jsonBody, r'''$.data''');
        // Only update status if the API response actually contains it;
        // otherwise keep the value passed via navigation param.
        final apiStatus =
            getJsonField(_propertyData, r'''$.status''')?.toString() ??
            getJsonField(res.jsonBody, r'''$.data.data.status''')?.toString() ??
            getJsonField(res.jsonBody, r'''$.data.status''')?.toString();
        if (apiStatus != null && apiStatus.isNotEmpty) {
          _propertyStatus = apiStatus;
        }
        debugPrint('[PropertyDashboard] status=$_propertyStatus id=${widget.propertyId}');
        _isLoadingProperty = false;
      });
    } else if (mounted) {
      safeSetState(() => _isLoadingProperty = false);
    }
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
          final subStatusRaw = (getJsonField(v, r'''$.substatus''') ?? '')
              .toString()
              .toUpperCase();

          if (statusRaw == 'CANCELLED' || statusRaw == 'COMPLETED') continue;

          final scheduledDateStr =
              getJsonField(v, r'''$.scheduledDate''')?.toString() ??
              getJsonField(v, r'''$.confirmedSlot.date''')?.toString() ??
              '';

          DateTime? scheduledDate;
          if (scheduledDateStr.isNotEmpty) {
            scheduledDate = DateTime.tryParse(scheduledDateStr);
          }

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

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _propName() {
    if (_propertyData == null) return '';
    return getJsonField(_propertyData, r'''$.name''')?.toString() ??
        getJsonField(_propertyData, r'''$.address''')?.toString() ??
        '';
  }

  List<String> _listingType() {
    if (_propertyData == null) return [];
    final raw = getJsonField(_propertyData, r'''$.listingType''');
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
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

  // ─── Modal: Editar precio y condiciones ───────────────────────────────────

  void _showEditModal() {
    final listing = _listingType();
    final bool hasSaleInit = listing.contains('SALE');
    final bool hasRentInit = listing.contains('RENT');

    // Pre-load current values
    final saleInfo = _propertyData != null
        ? getJsonField(_propertyData, r'''$.saleInfo''')
        : null;
    final rentInfo = _propertyData != null
        ? getJsonField(_propertyData, r'''$.rentInfo''')
        : null;

    final precioVentaCtrl = TextEditingController(
        text: saleInfo != null
            ? (getJsonField(saleInfo, r'''$.salePrice''') ?? '').toString()
            : '');
    // cantidadRecibirCtrl not needed – amountToReceive is computed server-side
    final mantenimientoCtrl = TextEditingController(
        text: saleInfo != null
            ? (getJsonField(saleInfo, r'''$.maintenanceFee''') ?? '').toString()
            : '');
    final impuestoCtrl = TextEditingController(
        text: saleInfo != null
            ? (getJsonField(saleInfo, r'''$.singlePropertyTax''') ?? '').toString()
            : '');
    final precioRentaCtrl = TextEditingController(
        text: rentInfo != null
            ? (getJsonField(rentInfo, r'''$.monthlyRent''') ?? '').toString()
            : '');
    final tiempoMinimoCtrl = TextEditingController(
        text: rentInfo != null
            ? (getJsonField(rentInfo, r'''$.rentalConditions.minimumTime''') ??
                    '')
                .toString()
            : '');
    final otrosCtrl = TextEditingController(
        text: rentInfo != null
            ? (getJsonField(rentInfo, r'''$.rentalConditions.others''') ?? '')
                .toString()
            : '');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => _EditPriceModal(
        primaryColor: _primary,
        primaryDarkColor: _primaryDark,
        hasSaleInit: hasSaleInit,
        hasRentInit: hasRentInit,
        precioVentaCtrl: precioVentaCtrl,
        // cantidadRecibirCtrl omitted — amounts are auto-calculated
        mantenimientoCtrl: mantenimientoCtrl,
        impuestoCtrl: impuestoCtrl,
        precioRentaCtrl: precioRentaCtrl,
        tiempoMinimoCtrl: tiempoMinimoCtrl,
        otrosCtrl: otrosCtrl,
        onSave: (hasSale, hasRent) async {
          final newListing = <String>[
            if (hasSale) 'SALE',
            if (hasRent) 'RENT',
          ];
          // Capture messenger before async gap
          final messenger = ScaffoldMessenger.of(context);

          final res = await DOVIAAPIPropertyContextGroup.updatePropertyCall.call(
            propertyId: widget.propertyId,
            authToken: currentAuthenticationToken,
            listingType: newListing,
            salePrice: hasSale && precioVentaCtrl.text.isNotEmpty
                ? double.tryParse(precioVentaCtrl.text)
                : null,
            // amountToReceive is NOT sent — computed server-side from salePrice
            maintenanceFee: hasSale && mantenimientoCtrl.text.isNotEmpty
                ? double.tryParse(mantenimientoCtrl.text)
                : null,
            singlePropertyTax: hasSale && impuestoCtrl.text.isNotEmpty
                ? double.tryParse(impuestoCtrl.text)
                : null,
            monthlyRent: hasRent && precioRentaCtrl.text.isNotEmpty
                ? double.tryParse(precioRentaCtrl.text)
                : null,
            minimumTimeRent: hasRent && tiempoMinimoCtrl.text.isNotEmpty
                ? int.tryParse(tiempoMinimoCtrl.text)
                : null,
            othersRent: hasRent ? otrosCtrl.text : null,
          );

          if (res.succeeded) {
            await _loadPropertyData();
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Precio actualizado correctamente'),
                backgroundColor: _primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else {
            // Log the response for debugging
            debugPrint('[UpdateProperty] Error: statusCode=${res.statusCode}, body=${res.jsonBody}');
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Error al guardar los datos'),
                backgroundColor: _errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showPausaModal() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close-pausa',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 240),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => _PausaModal(
        primaryColor: _primary,
        onConfirm: (String? motivo) async {
          final messenger = ScaffoldMessenger.of(context);
          final res = await DOVIAAPIPropertyContextGroup
              .changePropertyStatusCall
              .call(
            propertyId: widget.propertyId,
            authToken: currentAuthenticationToken,
            status: 'ARCHIVED',
            note: motivo,
          );
          if (!mounted) return;
          if (res.succeeded) {
            _propertyStatus = 'ARCHIVED'; // Update immediately
            await _loadPropertyData();
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Propiedad pausada correctamente'),
                backgroundColor: _primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else {
            debugPrint(
                '[PausarPropiedad] Error: statusCode=${res.statusCode}, body=${res.jsonBody}');
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Error al pausar la propiedad'),
                backgroundColor: _errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _reactivarPropiedad() async {
    final messenger = ScaffoldMessenger.of(context);
    final res = await DOVIAAPIPropertyContextGroup.changePropertyStatusCall.call(
      propertyId: widget.propertyId,
      authToken: currentAuthenticationToken,
      status: 'PUBLISHED',
    );
    if (!mounted) return;
    if (res.succeeded) {
      _propertyStatus = 'PUBLISHED'; // Update immediately
      await _loadPropertyData();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('¡Propiedad reactivada correctamente!'),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      debugPrint(
          '[ReactivarPropiedad] Error: statusCode=${res.statusCode}, body=${res.jsonBody}');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Error al reactivar la propiedad'),
          backgroundColor: _errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showNoDisponibleModal() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close-no-disponible',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => _NoDisponibleModal(
        primaryColor: _primary,
        errorColor: _errorRed,
        propertyName: _propName(),
        onConfirm: (String? reason) async {
          final messenger = ScaffoldMessenger.of(context);
          final nav = Navigator.of(context);

          final res = await DOVIAAPIPropertyContextGroup
              .changePropertyStatusCall
              .call(
            propertyId: widget.propertyId,
            authToken: currentAuthenticationToken,
            status: 'DELETED',
            note: reason,
          );

          if (!mounted) return;

          if (res.succeeded) {
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Propiedad marcada como no disponible'),
                backgroundColor: _errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            // Pop back to "Mis Propiedades" list
            nav.pop();
          } else {
            debugPrint(
                '[ChangePropertyStatus] Error: statusCode=${res.statusCode}, body=${res.jsonBody}');
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Error al dar de baja la propiedad'),
                backgroundColor: Color(0xFFD32F2F),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  // ─── UI helpers ────────────────────────────────────────────────────────────

  Widget _metricCard(BuildContext context, String label, int value) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 6),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _primaryDark,
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
                Text(statusLabel,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText)),
                const SizedBox(height: 4),
                Text(buyerName,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: FlutterFlowTheme.of(context).secondaryText)),
                const SizedBox(height: 4),
                Text(date,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _primary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove_red_eye_outlined,
                  color: _primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerCard(BuildContext context, dynamic offerJson) {
    final offerType = getJsonField(offerJson, r'''$.offerType''')?.toString() ?? '';
    final paymentMethod =
        getJsonField(offerJson, r'''$.offerData.paymentMethod''')?.toString() ?? '';
    final proposedAmount =
        getJsonField(offerJson, r'''$.offerData.proposedAmount''') ?? 0;
    final dateLabel = _formatOfferDate(offerJson);
    final offerId = getJsonField(offerJson, r'''$.id''')?.toString() ?? '';

    String typeLabel = offerType == 'RENT' ? 'Renta' : 'Compra';
    if (paymentMethod.isNotEmpty) {
      typeLabel += ' · ${paymentMethod.replaceAll('_', ' ')}';
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
                Text('Propuesta recibida',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText)),
                const SizedBox(height: 4),
                Text(typeLabel,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: FlutterFlowTheme.of(context).secondaryText)),
                const SizedBox(height: 4),
                Text('\$$proposedAmount',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _primary)),
                if (dateLabel.isNotEmpty)
                  Text(dateLabel,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: FlutterFlowTheme.of(context).secondaryText)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (offerId.isNotEmpty) {
                context.pushNamed(
                  DOVIACLIENTMisPropiedadesPropuestaWidget.routeName,
                  queryParameters: {
                    'proposalType':
                        serializeParam(offerType.toLowerCase(), ParamType.String),
                    'offerId': serializeParam(offerId, ParamType.String),
                  }.withoutNulls,
                );
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove_red_eye_outlined,
                  color: _primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
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

  // ─── Public info card (always visible + pencil icon) ───────────────────────
  Widget _publicInfoCard() {
    if (_isLoadingProperty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: _primary)));
    }

    final name = _propName();
    final address =
        getJsonField(_propertyData, r'''$.location.address.fullAddress''')
            ?.toString() ??
        getJsonField(_propertyData, r'''$.address''')?.toString() ??
        '—';
    final listing = _listingType();
    final hasSale = listing.contains('SALE');
    final hasRent = listing.contains('RENT');

    final saleInfo = _propertyData != null
        ? getJsonField(_propertyData, r'''$.saleInfo''')
        : null;
    final rentInfo = _propertyData != null
        ? getJsonField(_propertyData, r'''$.rentInfo''')
        : null;

    final salePrice = saleInfo != null
        ? (getJsonField(saleInfo, r'''$.salePrice''') ?? 0)
        : 0;
    final amountToReceive = saleInfo != null
        ? (getJsonField(saleInfo, r'''$.amountToReceive''') ?? 0)
        : 0;
    final maintenanceFee = saleInfo != null
        ? (getJsonField(saleInfo, r'''$.maintenanceFee''') ?? 0)
        : 0;
    final singlePropertyTax = saleInfo != null
        ? (getJsonField(saleInfo, r'''$.singlePropertyTax''') ?? 0)
        : 0;
    final monthlyRent = rentInfo != null
        ? (getJsonField(rentInfo, r'''$.monthlyRent''') ?? 0)
        : 0;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 50, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property name + type chips
              Row(
                children: [
                  const Icon(Icons.home_rounded, color: _primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name.isNotEmpty ? name : 'Mi propiedad',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Color(0xFF888888), size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Listing type chips
              Wrap(
                spacing: 8,
                children: [
                  if (hasSale)
                    _chip('Venta', Icons.sell_rounded),
                  if (hasRent)
                    _chip('Renta', Icons.key_rounded),
                ],
              ),
              const SizedBox(height: 16),
              // Price summary
              if (hasSale) ...[
                _priceRow('Precio de venta', '\$$salePrice'),
                _priceRow('Cantidad a recibir', '\$$amountToReceive',
                    small: true),
                _priceRow('Mantenimiento', '\$$maintenanceFee', small: true),
                _priceRow('Imp. único inmuebles', '\$$singlePropertyTax',
                    small: true),
              ],
              if (hasRent)
                _priceRow('Renta mensual', '\$$monthlyRent'),
            ],
          ),
        ),
        // ── Pencil icon ───────────────────────────────────────────────────────
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _showEditModal,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _primary.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.edit_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primary, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool small = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: small ? 12 : 14,
                  color: small
                      ? const Color(0xFF888888)
                      : FlutterFlowTheme.of(context).primaryText,
                  fontWeight: small ? FontWeight.w400 : FontWeight.w600)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: small ? 12 : 14,
                  color: small ? const Color(0xFF888888) : _primary,
                  fontWeight: small ? FontWeight.w400 : FontWeight.w700)),
        ],
      ),
    );
  }

  // ─── Accordion: Información Interna Dovia ─────────────────────────────────
  Widget _internalInfoAccordion() {
    // Extract internal info fields from property data
    final infoClient = _propertyData != null
        ? getJsonField(_propertyData, r'''$.infoClient''')
        : null;
    final infoLister = _propertyData != null
        ? getJsonField(_propertyData, r'''$.infoLister''')
        : null;
    final infoHQ = _propertyData != null
        ? getJsonField(_propertyData, r'''$.infoHQ''')
        : null;

    return _accordionSection(
      title: 'Información Interna Dovia',
      isExpanded: _internalInfoExpanded,
      animation: _internalInfoAnimation,
      onToggle: () {
        safeSetState(() {
          _internalInfoExpanded = !_internalInfoExpanded;
          if (_internalInfoExpanded) {
            _internalInfoController.forward();
          } else {
            _internalInfoController.reverse();
          }
        });
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (infoClient != null) ...[
            _internalFieldGroup(
              'Del propietario',
              [
                _fieldItem('Instrucciones de ingreso',
                    getJsonField(infoClient, r'''$.accessInstructions''')?.toString()),
                _fieldItem('Consideraciones arquitectónicas',
                    getJsonField(infoClient, r'''$.architecturalConsiderations''')?.toString()),
                _fieldItem('Características importantes',
                    getJsonField(infoClient, r'''$.importantFeatures''')?.toString()),
                _fieldItem('Nota de acceso',
                    getJsonField(infoClient, r'''$.accessNotes''')?.toString()),
              ],
            ),
          ],
          if (infoLister != null) ...[
            const SizedBox(height: 12),
            _internalFieldGroup(
              'Del Lister',
              [
                _fieldItem('Notas del lister',
                    getJsonField(infoLister, r'''$.notes''')?.toString()),
                _fieldItem('Consideraciones de visita',
                    getJsonField(infoLister, r'''$.visitConsiderations''')?.toString()),
              ],
            ),
          ],
          if (infoHQ != null) ...[
            const SizedBox(height: 12),
            _internalFieldGroup(
              'De HQ / Fotógrafo',
              [
                _fieldItem('Consideraciones de muestra',
                    getJsonField(infoHQ, r'''$.showingConsiderations''')?.toString()),
                _fieldItem('Notas internas',
                    getJsonField(infoHQ, r'''$.internalNotes''')?.toString()),
              ],
            ),
          ],
          if (infoClient == null && infoLister == null && infoHQ == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No hay información interna disponible por el momento.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF888888)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _internalFieldGroup(String groupTitle, List<Widget> fields) {
    final nonEmpty = fields.where((w) => w is! SizedBox).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groupTitle,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        ...nonEmpty,
      ],
    );
  }

  Widget _fieldItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 13, color: FlutterFlowTheme.of(context).secondaryText),
          ),
        ],
      ),
    );
  }

  // ─── Accordion: Documentos Internos ──────────────────────────────────────
  Widget _documentsAccordion() {
    final docs = _propertyData != null
        ? getJsonField(_propertyData, r'''$.documents''')
        : null;

    List<dynamic> docList = [];
    if (docs is List) {
      docList = docs;
    } else if (docs is Map) {
      // If documents is a map with named keys, convert to list
      docs.forEach((k, v) {
        if (v is String && v.isNotEmpty) {
          docList.add({'type': k, 'url': v});
        } else if (v is Map) {
          docList.add({...v as Map<String, dynamic>, 'type': k});
        }
      });
    }

    // Also check for top-level document URLs
    final certUrl = getJsonField(_propertyData, r'''$.certificationUrl''')?.toString();
    final receiptUrl = getJsonField(_propertyData, r'''$.receiptUrl''')?.toString();
    final contractUrl = getJsonField(_propertyData, r'''$.contractUrl''')?.toString();
    if (certUrl?.isNotEmpty == true && docList.where((d) => d['type'] == 'certification').isEmpty) {
      docList.add({'type': 'property-certification', 'url': certUrl, 'label': 'Certificación'});
    }
    if (receiptUrl?.isNotEmpty == true) {
      docList.add({'type': 'receipt', 'url': receiptUrl, 'label': 'Recibo'});
    }
    if (contractUrl?.isNotEmpty == true) {
      docList.add({'type': 'contract', 'url': contractUrl, 'label': 'Contrato'});
    }

    return _accordionSection(
      title: 'Documentos internos de DOVIA',
      isExpanded: _documentsExpanded,
      animation: _documentsAnimation,
      onToggle: () {
        safeSetState(() {
          _documentsExpanded = !_documentsExpanded;
          if (_documentsExpanded) {
            _documentsController.forward();
          } else {
            _documentsController.reverse();
          }
        });
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (docList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No hay documentos disponibles por el momento.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF888888)),
              ),
            )
          else
            ...docList.map((doc) => _documentRow(doc)),
        ],
      ),
    );
  }

  Widget _documentRow(dynamic doc) {
    final type = (doc['type'] ?? '').toString();
    final url = (doc['url'] ?? '').toString();
    final label = (doc['label'] ?? _labelForDocType(type)).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description_outlined, color: _primary, size: 20),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText),
        ),
        subtitle: Text(
          _extensionLabel(url),
          style: GoogleFonts.inter(
              fontSize: 11, color: const Color(0xFF888888)),
        ),
        trailing: url.isNotEmpty
            ? TextButton(
                onPressed: () => _openDocument(url, label),
                style: TextButton.styleFrom(
                  foregroundColor: _primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text('Ver más',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              )
            : null,
      ),
    );
  }

  String _labelForDocType(String type) {
    const labels = {
      'property-certification': 'Certificación',
      'owner-document': 'Documento del propietario',
      'certification': 'Certificación',
      'receipt': 'Recibo',
      'contract': 'Contrato',
    };
    return labels[type] ?? type;
  }

  String _extensionLabel(String url) {
    if (url.isEmpty) return 'Sin archivo';
    if (url.toLowerCase().endsWith('.pdf')) return 'PDF';
    if (url.toLowerCase().contains('.jpg') ||
        url.toLowerCase().contains('.jpeg') ||
        url.toLowerCase().contains('.png')) return 'Imagen';
    return 'Documento';
  }

  void _openDocument(String url, String label) {
    // Open URL in a viewer dialog (read-only, no upload/edit/delete buttons)
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: _bannerGreen,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.open_in_new_rounded,
                      color: _primary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'El documento se abrirá en el visor del dispositivo.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: FlutterFlowTheme.of(ctx).primaryText),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Abrir documento'),
                      style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24))),
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Open URL natively
                        // ignore: deprecated_member_use
                        // launchUrl(Uri.parse(url));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Accordion generic builder ─────────────────────────────────────────────
  Widget _accordionSection({
    required String title,
    required bool isExpanded,
    required Animation<double> animation,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: _primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _primaryDark),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _primary, size: 24),
                  ),
                ],
              ),
            ),
          ),
          // Animated content
          SizeTransition(
            sizeFactor: animation,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final propName = _propName();

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
                          showMap: false,
                          showCurrency: false,
                          title: propName.isNotEmpty
                              ? 'Información de $propName'
                              : 'Propiedad publicada'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── BANNER "Tu propiedad ya está publicada" ────────
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _bannerGreen,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tu propiedad ya está publicada',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── MÉTRICAS ──────────────────────────────────────
                          const SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _metricCard(context, 'Vieron tu propiedad', _views),
                              _metricCard(context, 'Interactuaron', _interactions),
                              _metricCard(context, 'Visitas', _visits),
                              _metricCard(context, 'Propuestas', _offers),
                            ],
                          ),

                          // ── INFORMACIÓN PÚBLICA (siempre visible) ─────────
                          const SizedBox(height: 24),
                          Text(
                            'Información pública',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF888888),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _publicInfoCard(),

                          // ── INFORMACIÓN INTERNA (acordeón) ────────────────
                          const SizedBox(height: 16),
                          _internalInfoAccordion(),

                          // ── DOCUMENTOS INTERNOS (acordeón) ────────────────
                          _documentsAccordion(),

                          // ── VISITAS PENDIENTES ─────────────────────────────
                          _sectionTitle('Confirma próximas visitas'),
                          if (_isLoadingVisits)
                            const Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child:
                                  CircularProgressIndicator(color: _primary),
                            ))
                          else if (_pendingVisits.isEmpty)
                            _emptyState(
                                'No hay visitas pendientes de confirmación.')
                          else
                            ..._pendingVisits.map((v) {
                              final visitId =
                                  getJsonField(v, r'''$.id''')?.toString() ??
                                      '';
                              return _visitCard(context, v,
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
                              });
                            }),

                          // ── VISITAS CONFIRMADAS ────────────────────────────
                          _sectionTitle('Visitas confirmadas'),
                          if (_isLoadingVisits)
                            const SizedBox()
                          else if (_confirmedVisits.isEmpty)
                            _emptyState('No hay visitas confirmadas próximas.')
                          else
                            ..._confirmedVisits.map((v) {
                              final visitId =
                                  getJsonField(v, r'''$.id''')?.toString() ??
                                      '';
                              return _visitCard(context, v,
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
                              });
                            }),

                          // ── PROPUESTAS ─────────────────────────────────────
                          _sectionTitle('Propuestas'),
                          if (_isLoadingOffers)
                            const Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child:
                                  CircularProgressIndicator(color: _primary),
                            ))
                          else if (_activeOffers.isEmpty)
                            _emptyState('No hay propuestas activas por ahora.')
                          else
                            ..._activeOffers
                                .map((o) => _offerCard(context, o)),

                          // ── BOTONES DE ACCIÓN ──────────────────────────────
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: _primary, width: 1.5),
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
                                'Editar información completa de tu propiedad',
                                style: GoogleFonts.inter(
                                  color: _primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ── Pausa / No disponible / Reactivar ────────────
                          Builder(builder: (context) {
                            // Read from the dedicated reactive state variable
                            final isPaused = _propertyStatus == 'ARCHIVED';

                            if (isPaused) {
                              // ── Property is paused: show banner + Reactivar
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE85D75)
                                          .withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE85D75),
                                          width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.pause_circle_outline_rounded,
                                            color: Color(0xFFE85D75),
                                            size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Esta propiedad está pausada y no se muestra en el mapa ni en búsquedas.',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFFE85D75),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 48,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                      ),
                                      onPressed: _reactivarPropiedad,
                                      child: Text(
                                        'Activar propiedad',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            // ── Active property: Pausa + No disponible ────
                            return Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: _primary, width: 1.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                      ),
                                      onPressed: _showPausaModal,
                                      child: Text(
                                        'Propiedad en pausa',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          color: _primary,
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
                                            color: _errorRed, width: 1.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                      ),
                                      onPressed: _showNoDisponibleModal,
                                      child: Text(
                                        'No disponible',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          color: _errorRed,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Fixed Dovia Icon + Navbar ──────────────────────────────────
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

// ──────────────────────────────────────────────────────────────────────────────
// Modal separado: Editar precio y condiciones
// ──────────────────────────────────────────────────────────────────────────────

class _EditPriceModal extends StatefulWidget {
  final Color primaryColor;
  final Color primaryDarkColor;
  final bool hasSaleInit;
  final bool hasRentInit;
  final TextEditingController precioVentaCtrl;
  // cantidadRecibirCtrl removed — amountToReceive is computed server-side
  final TextEditingController mantenimientoCtrl;
  final TextEditingController impuestoCtrl;
  final TextEditingController precioRentaCtrl;
  final TextEditingController tiempoMinimoCtrl;
  final TextEditingController otrosCtrl;
  final Future<void> Function(bool hasSale, bool hasRent) onSave;

  const _EditPriceModal({
    required this.primaryColor,
    required this.primaryDarkColor,
    required this.hasSaleInit,
    required this.hasRentInit,
    required this.precioVentaCtrl,
    required this.mantenimientoCtrl,
    required this.impuestoCtrl,
    required this.precioRentaCtrl,
    required this.tiempoMinimoCtrl,
    required this.otrosCtrl,
    required this.onSave,
  });

  @override
  State<_EditPriceModal> createState() => _EditPriceModalState();
}

class _EditPriceModalState extends State<_EditPriceModal> {
  late bool _hasSale;
  late bool _hasRent;
  bool _isSaving = false;

  // ── Validation ─────────────────────────────────────────────────────────────
  // Map of fieldKey -> error message. Empty string / null = no error.
  final Map<String, String?> _fieldErrors = {};

  bool _validate() {
    final errors = <String, String?>{};

    if (!_hasSale && !_hasRent) {
      // Edge case: nothing selected — shouldn't reach save but guard anyway
      return false;
    }
    if (_hasSale && widget.precioVentaCtrl.text.trim().isEmpty) {
      errors['salePrice'] = 'El precio de venta es requerido';
    }
    if (_hasRent && widget.precioRentaCtrl.text.trim().isEmpty) {
      errors['monthlyRent'] = 'El precio de renta mensual es requerido';
    }

    setState(() => _fieldErrors
      ..clear()
      ..addAll(errors));
    return errors.isEmpty;
  }

  void _clearError(String fieldKey) {
    if (_fieldErrors.containsKey(fieldKey) &&
        _fieldErrors[fieldKey] != null) {
      setState(() => _fieldErrors[fieldKey] = null);
    }
  }

  // ── Auto-calculated amountToReceive ────────────────────────────────────────
  String _amountToReceiveDisplay = '';

  void _updateAmountToReceive() {
    final raw = widget.precioVentaCtrl.text.trim();
    final price = double.tryParse(raw);
    if (price != null && price > 0) {
      final amount = price * 0.965;
      setState(() {
        _amountToReceiveDisplay = '\$${amount.toStringAsFixed(2)}';
      });
    } else {
      setState(() => _amountToReceiveDisplay = '');
    }
    // Also clear the salePrice error as soon as the user types
    _clearError('salePrice');
  }

  @override
  void initState() {
    super.initState();
    _hasSale = widget.hasSaleInit;
    _hasRent = widget.hasRentInit;
    _updateAmountToReceive();
    widget.precioVentaCtrl.addListener(_updateAmountToReceive);
    // Rent price listener to clear its error on edit
    widget.precioRentaCtrl.addListener(() => _clearError('monthlyRent'));
  }

  @override
  void dispose() {
    widget.precioVentaCtrl.removeListener(_updateAmountToReceive);
    super.dispose();
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool isNumeric = true,
    String? fieldKey,   // optional: key into _fieldErrors for validation
  }) {
    final hasError =
        fieldKey != null && (_fieldErrors[fieldKey]?.isNotEmpty == true);
    final errorText = hasError ? _fieldErrors[fieldKey] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? const Color(0xFFD32F2F) : widget.primaryDarkColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
              : null,
          onChanged: fieldKey != null
              ? (_) => _clearError(fieldKey)
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFFAAAAAA)),
            isDense: true,
            filled: true,
            fillColor:
                hasError ? const Color(0xFFFFF0F0) : const Color(0xFFF5F5F5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFD32F2F), width: 1.5)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFD32F2F), width: 1.5)
                  : BorderSide(color: widget.primaryColor, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 14),
        ),
        // Error message
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 13, color: Color(0xFFD32F2F)),
                const SizedBox(width: 4),
                Text(
                  errorText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFD32F2F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: errorText != null ? 10 : 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Editar precio y condiciones',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: widget.primaryDarkColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: Color(0xFF555555)),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué te gustaría hacer?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.primaryDarkColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Puedes seleccionar ambas',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: widget.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // ── Venta / Renta toggle buttons ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _toggleButton(
                          label: 'Venta',
                          selected: _hasSale,
                          onTap: () => setState(() {
                            _hasSale = !_hasSale;
                            // Clear sale error when deselecting
                            if (!_hasSale) _fieldErrors.remove('salePrice');
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _toggleButton(
                          label: 'Renta',
                          selected: _hasRent,
                          onTap: () => setState(() {
                            _hasRent = !_hasRent;
                            // Clear rent error when deselecting
                            if (!_hasRent) _fieldErrors.remove('monthlyRent');
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Sale fields ───────────────────────────────────────────
                if (_hasSale)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dividerLabel('Datos de Venta'),
                          _inputField(
                            label:
                                'Precio de venta (incluyendo comisión Dovia 3.5%)',
                            controller: widget.precioVentaCtrl,
                            hint: 'Ej: 250000',
                            fieldKey: 'salePrice',
                          ),
                          // Cantidad a recibir: read-only, auto-calculated
                          if (_amountToReceiveDisplay.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF8F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: widget.primaryColor
                                          .withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Cantidad a recibir (calculado)',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: widget.primaryColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      _amountToReceiveDisplay,
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: widget.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(
                                  label: 'Mantenimiento',
                                  controller: widget.mantenimientoCtrl,
                                  hint: 'Ej: 500',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _inputField(
                                  label: 'Imp. único inmuebles',
                                  controller: widget.impuestoCtrl,
                                  hint: 'Ej: 200',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Rent fields (dynamic expansion) ──────────────────────
                if (_hasRent)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dividerLabel('Datos de Renta'),
                          _inputField(
                            label:
                                'Precio de renta mensual (incluyendo IVA y mantenimiento)',
                            controller: widget.precioRentaCtrl,
                            hint: 'Ej: 1500',
                            fieldKey: 'monthlyRent',
                          ),
                          Text(
                            'Comisión Dovia: 1 renta',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: const Color(0xFF888888)),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Condiciones de renta',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.primaryDarkColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(
                                  label: 'Tiempo mínimo (meses)',
                                  controller: widget.tiempoMinimoCtrl,
                                  hint: 'Ej: 12',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _inputField(
                                  label: 'Otros',
                                  controller: widget.otrosCtrl,
                                  hint: 'Ej: mascotas',
                                  isNumeric: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Buttons: Cancelar / Guardar ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: widget.primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed:
                              _isSaving ? null : () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                                color: widget.primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  if (!_hasSale && !_hasRent) return;
                                  // Validate required fields before saving
                                  if (!_validate()) return;
                                  setState(() => _isSaving = true);
                                  await widget.onSave(_hasSale, _hasRent);
                                  if (mounted) Navigator.pop(context);
                                },
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  'Aceptar',
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          color: selected ? widget.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: widget.primaryColor,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : widget.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _dividerLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
              child: Divider(
                  color: widget.primaryColor.withOpacity(0.2), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
              child: Divider(
                  color: widget.primaryColor.withOpacity(0.2), thickness: 1)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Modal: Propiedad No Disponible (baja definitiva)
// ──────────────────────────────────────────────────────────────────────────────

class _NoDisponibleModal extends StatefulWidget {
  final Color primaryColor;
  final Color errorColor;
  final String propertyName;
  /// Called with the optional reason text when the user taps [No disponible].
  /// The caller is responsible for the API call and navigation.
  final Future<void> Function(String? reason) onConfirm;

  const _NoDisponibleModal({
    required this.primaryColor,
    required this.errorColor,
    required this.propertyName,
    required this.onConfirm,
  });

  @override
  State<_NoDisponibleModal> createState() => _NoDisponibleModalState();
}

class _NoDisponibleModalState extends State<_NoDisponibleModal> {
  final TextEditingController _motivoCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    final reason = _motivoCtrl.text.trim().isEmpty ? null : _motivoCtrl.text.trim();
    // Close the modal first — then the caller shows snackbar / pops the page
    if (mounted) Navigator.of(context).pop();
    await widget.onConfirm(reason);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Critical warning header ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: widget.errorColor,
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Estás seguro de poner la propiedad no disponible?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explanatory text
                Text(
                  'Al marcar la propiedad como no disponible:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                _bulletPoint('Se retirará del mapa y de las búsquedas.'),
                _bulletPoint('Se eliminará de los favoritos de todos los usuarios.'),
                _bulletPoint('Se cancelarán las visitas y propuestas activas.'),
                _bulletPoint('Se notificará a los equipos internos de DOVIA.'),
                const SizedBox(height: 4),
                Text(
                  'Esta acción es definitiva.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.errorColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Motivo (optional textarea)
                Text(
                  'Motivo (opcional)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _motivoCtrl,
                  maxLines: 4,
                  maxLength: 500,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Ej: La propiedad ya fue vendida de forma privada…',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFFAAAAAA)),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: widget.errorColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    counterStyle: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFFAAAAAA)),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Buttons ────────────────────────────────────────────────
                Row(
                  children: [
                    // Cancelar
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFCCCCCC), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                          ),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // No disponible
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleConfirm,
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.errorColor,
                            disabledBackgroundColor:
                                widget.errorColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'No disponible',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: widget.errorColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF555555), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Modal: Pausar Publicación (diseño Figma 2471:95378)
// ──────────────────────────────────────────────────────────────────────────────

class _PausaModal extends StatefulWidget {
  final Color primaryColor;
  /// Called with the optional motivo when the user taps [Pausar Propiedad].
  final Future<void> Function(String? motivo) onConfirm;

  const _PausaModal({
    required this.primaryColor,
    required this.onConfirm,
  });

  @override
  State<_PausaModal> createState() => _PausaModalState();
}

class _PausaModalState extends State<_PausaModal> {
  final TextEditingController _motivoCtrl = TextEditingController();
  bool _isLoading = false;

  static const Color _pink = Color(0xFFE85D75);

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    final motivo =
        _motivoCtrl.text.trim().isEmpty ? null : _motivoCtrl.text.trim();
    if (mounted) Navigator.of(context).pop();
    await widget.onConfirm(motivo);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Close button (top-right) ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  // Title
                  child: Text(
                    '¿Quieres pausar la publicacion de la propiedad?',
                    style: GoogleFonts.publicSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00444B),
                      height: 1.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Opacity(
                    opacity: 0.7,
                    child: Icon(Icons.close,
                        size: 16,
                        color: Colors.black.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Subtitle ─────────────────────────────────────────────────
            Text(
              'No se mostrara la propiedad hasta que lo vuelvas activar.',
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00444B),
              ),
            ),
            const SizedBox(height: 8),

            // ── Textarea ─────────────────────────────────────────────────
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.transparent),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA1A1A1).withOpacity(0.13),
                    blurRadius: 0,
                    spreadRadius: 0.775,
                  ),
                ],
              ),
              child: TextField(
                controller: _motivoCtrl,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style:
                    GoogleFonts.publicSans(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText:
                      'Describe por qué se quieres pausar la publicacion de la propiedad...',
                  hintStyle: GoogleFonts.publicSans(
                    fontSize: 14,
                    color: const Color(0xFF717182),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Buttons ───────────────────────────────────────────────────
            Row(
              children: [
                // Cancelar — outlined teal
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: widget.primaryColor, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.publicSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Pausar Propiedad — pink filled
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: _pink,
                        disabledBackgroundColor: _pink.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Pausar Propiedad',
                              style: GoogleFonts.publicSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
