import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_offers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propuesta_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propuesta_model.dart';

class DOVIACLIENTMisPropiedadesPropuestaWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesPropuestaWidget({
    super.key,
    String? proposalType,
    this.offerId,
  }) : proposalType = proposalType ?? 'contado';

  /// contado, hipoteca, promesa, cash, mortgage, purchase_promise, etc.
  final String proposalType;

  /// ID de la oferta a mostrar (requerido para cargar datos reales)
  final String? offerId;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_Propuesta';
  static String routePath = '/dOVIACLIENTMisPropiedadesPropuesta';

  @override
  State<DOVIACLIENTMisPropiedadesPropuestaWidget> createState() =>
      _DOVIACLIENTMisPropiedadesPropuestaWidgetState();
}

class _DOVIACLIENTMisPropiedadesPropuestaWidgetState
    extends State<DOVIACLIENTMisPropiedadesPropuestaWidget> {
  late DOVIACLIENTMisPropiedadesPropuestaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ─── Colors ─────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF007376);
  static const Color _primaryDark = Color(0xFF00444B);
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _bannerGreen = Color(0xFF005F62);

  // ─── State ──────────────────────────────────────────────────────────────
  dynamic _offerData;
  bool _isLoading = true;
  bool _isActioning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => DOVIACLIENTMisPropiedadesPropuestaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadOffer();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ─── Data loading ────────────────────────────────────────────────────────

  Future<void> _loadOffer() async {
    if (widget.offerId == null || widget.offerId!.isEmpty) {
      safeSetState(() {
        _isLoading = false;
        _errorMessage = 'No se especificó el ID de la oferta.';
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
        _isLoading = false;
      });
      debugPrint('[OfferDetail] loaded: $_offerData');
    } else {
      safeSetState(() {
        _isLoading = false;
        _errorMessage =
            'Error al cargar la oferta (${res.statusCode}). Intenta de nuevo.';
      });
      debugPrint('[OfferDetail] error ${res.statusCode}: ${res.jsonBody}');
    }
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _acceptOffer() async {
    if (widget.offerId == null) return;
    safeSetState(() => _isActioning = true);
    final messenger = ScaffoldMessenger.of(context);

    final res = await DOVIAAPIOfferContextGroup.acceptOfferCall.call(
      offerId: widget.offerId,
      authToken: currentAuthenticationToken,
    );

    if (!mounted) return;
    safeSetState(() => _isActioning = false);

    if (res.succeeded) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('¡Oferta aceptada exitosamente!'),
          backgroundColor: _successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Reload to reflect new status
      await _loadOffer();
    } else {
      debugPrint('[AcceptOffer] error ${res.statusCode}: ${res.jsonBody}');
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              'Error al aceptar la oferta (${res.statusCode}). Intenta de nuevo.'),
          backgroundColor: _errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectOffer() async {
    if (widget.offerId == null) return;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rechazar oferta',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: _primaryDark)),
        content: Text(
          '¿Estás seguro de que deseas rechazar esta oferta? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: const Color(0xFF555555))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Rechazar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    safeSetState(() => _isActioning = true);
    final messenger = ScaffoldMessenger.of(context);

    final res = await DOVIAAPIOfferContextGroup.rejectOfferCall.call(
      offerId: widget.offerId,
      authToken: currentAuthenticationToken,
    );

    if (!mounted) return;
    safeSetState(() => _isActioning = false);

    if (res.succeeded) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Oferta rechazada.'),
          backgroundColor: Color(0xFF555555),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadOffer();
    } else {
      debugPrint('[RejectOffer] error ${res.statusCode}: ${res.jsonBody}');
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              'Error al rechazar la oferta (${res.statusCode}). Intenta de nuevo.'),
          backgroundColor: _errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _resolveField(List<String> paths) {
    if (_offerData == null) return '—';
    for (final p in paths) {
      final v = getJsonField(_offerData, p)?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return '—';
  }

  String _offerTypeLabel() {
    final raw = _resolveField([r'''$.offerType''']);
    switch (raw.toUpperCase()) {
      case 'SALE':
        return 'Compra';
      case 'RENT':
        return 'Renta';
      default:
        return raw;
    }
  }

  String _paymentMethodLabel() {
    final raw = _resolveField([
      r'''$.activeOfferData.paymentMethod''',
      r'''$.offerData.paymentMethod''',
      r'''$.paymentMethod''',
    ]);
    switch (raw.toLowerCase()) {
      case 'cash':
        return 'Contado';
      case 'mortgage':
        return 'Hipoteca';
      case 'purchase_promise':
        return 'Promesa de compra';
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  String _offerStatusLabel() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status''']);
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'SENT':
        return 'Enviada';
      case 'ACTIVE':
      case 'IN_NEGOTIATION':
        return 'En negociación';
      case 'ACCEPTED':
        return 'Aceptada';
      case 'REJECTED':
      case 'REJECTED_BY_OWNER':
        return 'Rechazada';
      case 'CANCELLED':
        return 'Cancelada';
      case 'EXPIRED':
        return 'Expirada';
      default:
        return raw;
    }
  }

  Color _statusColor() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status'''])
        .toUpperCase();
    if (raw.contains('ACCEPTED')) return _successGreen;
    if (raw.contains('REJECTED') || raw.contains('CANCELLED')) return _errorRed;
    if (raw == 'ACTIVE') return _primary;
    return const Color(0xFFED8B00); // orange for PENDING
  }

  bool _canAct() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status'''])
        .toUpperCase();
    // Can act on offers that are sent/pending/active/in_negotiation
    return raw == 'PENDING' || raw == 'ACTIVE' || raw == 'SENT' ||
        raw == 'IN_NEGOTIATION';
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  // ─── UI builders ─────────────────────────────────────────────────────────

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight
                    ? _primary
                    : FlutterFlowTheme.of(context).primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _primaryDark,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor().withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor().withOpacity(0.35)),
      ),
      child: Text(
        _offerStatusLabel(),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _statusColor(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: _errorRed, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: FlutterFlowTheme.of(context).primaryText),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  safeSetState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadOffer();
                },
                style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24))),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Reintentar',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    if (_offerData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No se encontraron datos de la oferta.',
            style: GoogleFonts.inter(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).secondaryText),
          ),
        ),
      );
    }

    // ── Extract offer fields ─────────────────────────────────────────────
    final offerType = _offerTypeLabel();
    final paymentMethod = _paymentMethodLabel();
    final currency = _resolveField([
      r'''$.activeOfferData.currency''',
      r'''$.offerData.currency''',
      r'''$.currency''',
    ]);
    final proposedAmount = _resolveField([
      r'''$.activeOfferData.proposedAmount''',
      r'''$.offerData.proposedAmount''',
      r'''$.proposedAmount''',
    ]);
    final considerations = _resolveField([
      r'''$.activeOfferData.considerations''',
      r'''$.offerData.considerations''',
      r'''$.considerations''',
    ]);
    final createdAt = _formatDate(
        getJsonField(_offerData, r'''$.createdAt''')?.toString());

    // Buyer/Tenant info — nested in activeOfferData
    final buyerName = _resolveField([
      r'''$.activeOfferData.buyerInfo.name''',
      r'''$.offerData.buyerInfo.name''',
      r'''$.buyerInfo.name''',
      r'''$.activeOfferData.tenantInfo.name''',
      r'''$.offerData.tenantInfo.name''',
    ]);
    final buyerType = _resolveField([
      r'''$.activeOfferData.buyerInfo.type''',
      r'''$.offerData.buyerInfo.type''',
      r'''$.buyerInfo.type''',
      r'''$.activeOfferData.tenantInfo.type''',
      r'''$.offerData.tenantInfo.type''',
    ]);

    // Mortgage-specific
    final bankName = _resolveField([
      r'''$.activeOfferData.bankName''',
      r'''$.offerData.bankName''',
      r'''$.bankName''',
    ]);
    final downPayment = _resolveField([
      r'''$.activeOfferData.downPaymentPercentage''',
      r'''$.offerData.downPaymentPercentage''',
      r'''$.downPaymentPercentage''',
    ]);
    final creditStatus = _resolveField([
      r'''$.activeOfferData.creditStatus''',
      r'''$.offerData.creditStatus''',
      r'''$.creditStatus''',
    ]);

    // Cash-specific
    final estimatedPaymentTime = _resolveField([
      r'''$.activeOfferData.estimatedPaymentTime''',
      r'''$.offerData.estimatedPaymentTime''',
      r'''$.estimatedPaymentTime''',
    ]);

    // Promise-specific
    final initialReserve = _resolveField([
      r'''$.activeOfferData.initialReserve''',
      r'''$.offerData.initialReserve''',
      r'''$.initialReserve''',
    ]);
    final promiseTimeMonths = _resolveField([
      r'''$.activeOfferData.promiseTimeMonths''',
      r'''$.offerData.promiseTimeMonths''',
      r'''$.promiseTimeMonths''',
    ]);

    // Rent-specific
    final contractStart = _formatDate(_resolveField([
      r'''$.activeOfferData.contractStartDate''',
      r'''$.offerData.contractStartDate''',
      r'''$.contractStartDate''',
    ]) == '—' ? null : _resolveField([
      r'''$.activeOfferData.contractStartDate''',
      r'''$.offerData.contractStartDate''',
    ]));
    final contractEnd = _formatDate(_resolveField([
      r'''$.activeOfferData.contractEndDate''',
      r'''$.offerData.contractEndDate''',
      r'''$.contractEndDate''',
    ]) == '—' ? null : _resolveField([
      r'''$.activeOfferData.contractEndDate''',
      r'''$.offerData.contractEndDate''',
    ]));
    final propertyUse = _resolveField([
      r'''$.activeOfferData.propertyUse''',
      r'''$.offerData.propertyUse''',
      r'''$.propertyUse''',
    ]);

    final rawPayment = _resolveField([
      r'''$.activeOfferData.paymentMethod''',
      r'''$.offerData.paymentMethod''',
      r'''$.paymentMethod''',
    ]).toLowerCase();
    final isMortgage = rawPayment == 'mortgage';
    final isCash = rawPayment == 'cash';
    final isPromise = rawPayment == 'purchase_promise';
    final isRent =
        _resolveField([r'''$.offerType''']).toUpperCase() == 'RENT';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Status header card ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bannerGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.handshake_outlined,
                  color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Propuesta recibida · $offerType',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recibida el $createdAt',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Economic proposal ────────────────────────────────────────────
        _sectionCard(
          title: '💰 Propuesta económica',
          child: Column(
            children: [
              _infoRow('Moneda', currency == '—' ? 'USD' : currency),
              _infoRow('Medio de pago', paymentMethod),
              _infoRow('Monto propuesto',
                  proposedAmount == '—' ? '—' : '\$$proposedAmount',
                  highlight: true),
              if (considerations != '—')
                _infoRow('Consideraciones', considerations),
              // Cash specific
              if (isCash && estimatedPaymentTime != '—')
                _infoRow('Tiempo estimado pago', '$estimatedPaymentTime días'),
              // Mortgage specific
              if (isMortgage && bankName != '—')
                _infoRow('Banco', bankName),
              if (isMortgage && downPayment != '—')
                _infoRow('Pago inicial', '$downPayment%'),
              if (isMortgage && creditStatus != '—')
                _infoRow('Estado del crédito', creditStatus),
              // Promise specific
              if (isPromise && initialReserve != '—')
                _infoRow('Reserva inicial', '\$$initialReserve'),
              if (isPromise && promiseTimeMonths != '—')
                _infoRow('Tiempo promesa', '$promiseTimeMonths meses'),
              // Rent specific
              if (isRent && contractStart != '—')
                _infoRow('Inicio contrato', contractStart),
              if (isRent && contractEnd != '—')
                _infoRow('Fin contrato', contractEnd),
              if (isRent && propertyUse != '—')
                _infoRow('Uso del inmueble', propertyUse),
            ],
          ),
        ),

        // ── Buyer info ──────────────────────────────────────────────────
        if (buyerName != '—')
          _sectionCard(
            title: isRent ? '👤 Información del arrendatario' : '👤 Información del comprador',
            child: Column(
              children: [
                _infoRow('Nombre', buyerName),
                if (buyerType != '—')
                  _infoRow('Tipo', buyerType == 'company' ? 'Empresa' : 'Persona natural'),
              ],
            ),
          ),

        // ── Action buttons ───────────────────────────────────────────────
        if (_canAct()) ...[
          const SizedBox(height: 8),
          if (_isActioning)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: _primary),
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text(
                  'Aceptar oferta',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _successGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 2,
                ),
                onPressed: _acceptOffer,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: Text(
                  'Rechazar oferta',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _errorRed,
                  side: const BorderSide(color: _errorRed, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: _rejectOffer,
              ),
            ),
          ],
        ] else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: _statusColor().withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _statusColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(_offerStatusLabel() == 'Aceptada'
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                    color: _statusColor(), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta oferta ha sido ${_offerStatusLabel().toLowerCase()}.',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _statusColor()),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
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
                        title: 'Detalle de propuesta',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 12.0, 20.0, 120.0),
                      child: _buildContent(),
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
