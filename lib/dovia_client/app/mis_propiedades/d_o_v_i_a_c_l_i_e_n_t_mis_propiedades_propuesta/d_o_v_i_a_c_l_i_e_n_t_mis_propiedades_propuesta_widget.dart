import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_offers.dart';
import '../d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_contraofertar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_contraofertar_widget.dart';
import '../d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_acuerdo/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_acuerdo_widget.dart';
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

  final String proposalType;
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

  static const Color _primary = Color(0xFF007376);
  static const Color _primaryDark = Color(0xFF00444B);
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const double _doviaCommission = 0.035;

  dynamic _offerData;
  bool _isLoading = true;
  bool _isActioning = false;
  String? _errorMessage;
  bool _isEconomicDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTMisPropiedadesPropuestaModel());
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

  Future<void> _loadOffer() async {
    if (widget.offerId == null || widget.offerId!.isEmpty) {
      safeSetState(() { _isLoading = false; _errorMessage = 'No se especificó el ID de la oferta.'; });
      return;
    }
    final res = await DOVIAAPIOfferContextGroup.getOfferByIDCall.call(
      offerId: widget.offerId, authToken: currentAuthenticationToken,
    );
    if (!mounted) return;
    if (res.succeeded) {
      safeSetState(() {
        _offerData = getJsonField(res.jsonBody, r'''$.data''') ??
            getJsonField(res.jsonBody, r'''$.offer''') ?? res.jsonBody;
        _isLoading = false;
      });
      debugPrint('[OfferDetail] loaded: $_offerData');
    } else {
      safeSetState(() { _isLoading = false; _errorMessage = 'Error al cargar (${res.statusCode}).'; });
    }
  }

  Future<void> _acceptOffer() async {
    if (widget.offerId == null) return;
    safeSetState(() => _isActioning = true);
    final messenger = ScaffoldMessenger.of(context);
    final res = await DOVIAAPIOfferContextGroup.acceptOfferCall.call(
      offerId: widget.offerId, authToken: currentAuthenticationToken,
    );
    if (!mounted) return;
    safeSetState(() => _isActioning = false);
    if (res.succeeded) {
      messenger.showSnackBar(SnackBar(
        content: const Text('¡Oferta aceptada exitosamente!'),
        backgroundColor: _successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      await _loadOffer();
      if (mounted) {
        context.pushNamed(
          DOVIACLIENTMisPropiedadesAcuerdoWidget.routeName,
          queryParameters: {
            'offerId': serializeParam(widget.offerId, ParamType.String),
            'paymentMethod': serializeParam(
                getJsonField(_offerData, r'''$.paymentMethod''') ??
                    getJsonField(_offerData, r'''$.offerData.paymentMethod'''),
                ParamType.String),
            'proposedAmount': serializeParam(
                _resolveAmount()?.toString(), ParamType.String),
          }.withoutNulls,
        );
      }
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text('Error al aceptar (${res.statusCode}).'),
        backgroundColor: _errorRed, behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _rejectOffer() async {
    if (widget.offerId == null) return;
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Por qué rechazas la oferta?',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryDark)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDFDFDF)),
                ),
                child: TextField(
                  controller: reasonCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Escribe el motivo aquí...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF888888), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: GoogleFonts.inter(fontSize: 14, color: _primaryDark),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancelar', style: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _errorRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (reasonCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx, true);
                      },
                      child: Text('Confirmar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) { reasonCtrl.dispose(); return; }
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();

    safeSetState(() => _isActioning = true);
    final messenger = ScaffoldMessenger.of(context);
    final res = await DOVIAAPIOfferContextGroup.rejectOfferCall.call(
      offerId: widget.offerId, authToken: currentAuthenticationToken, reason: reason,
    );
    if (!mounted) return;
    safeSetState(() => _isActioning = false);
    if (res.succeeded) {
      if (!mounted) return;
      safeSetState(() => _isActioning = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Oferta rechazada.'),
        backgroundColor: Color(0xFF555555),
        behavior: SnackBarBehavior.floating,
      ));
      // Volver al dashboard para que se recargue
      context.pop();
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text('Error al rechazar (${res.statusCode}).'),
        backgroundColor: _errorRed, behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _resolveField(List<String> paths) {
    if (_offerData == null) return '—';
    for (final p in paths) {
      final v = getJsonField(_offerData, p)?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return '—';
  }

  num? _resolveAmount() {
    final raw = getJsonField(_offerData, r'''$.activeOfferData.proposedAmount''') ??
        getJsonField(_offerData, r'''$.offerData.proposedAmount''') ??
        getJsonField(_offerData, r'''$.proposedAmount''');
    if (raw == null) return null;
    return raw is num ? raw : num.tryParse(raw.toString());
  }

  String _offerTypeLabel() {
    final raw = _resolveField([r'''$.offerType''']);
    switch (raw.toUpperCase()) {
      case 'SALE': return 'Venta';
      case 'RENT': return 'Renta';
      default: return raw;
    }
  }

  String _paymentMethodLabel() {
    final raw = _resolveField([r'''$.activeOfferData.paymentMethod''', r'''$.offerData.paymentMethod''', r'''$.paymentMethod''']);
    switch (raw.toLowerCase()) {
      case 'cash': return 'Contado';
      case 'mortgage': return 'Hipoteca';
      case 'purchase_promise': return 'Promesa de compra';
      default: return raw.replaceAll('_', ' ');
    }
  }

  String _offerStatusLabel() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status''']);
    switch (raw.toUpperCase()) {
      case 'PENDING': return 'Pendiente';
      case 'SENT': return 'Enviada';
      case 'ACTIVE': case 'IN_NEGOTIATION': return 'En negociación';
      case 'ACCEPTED': return 'Aceptada';
      case 'REJECTED': case 'REJECTED_BY_OWNER': return 'Rechazada';
      case 'CANCELLED': return 'Cancelada';
      default: return raw;
    }
  }

  Color _statusColor() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status''']).toUpperCase();
    if (raw.contains('ACCEPTED')) return _successGreen;
    if (raw.contains('REJECTED') || raw.contains('CANCELLED')) return _errorRed;
    if (raw == 'SENT' || raw == 'PENDING') return const Color(0xFFED8B00);
    return _primary;
  }

  bool _canAct() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status''']).toUpperCase();
    return raw == 'PENDING' || raw == 'ACTIVE' || raw == 'SENT' || raw == 'IN_NEGOTIATION';
  }

  bool _isRejectedByOwner() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status''']).toUpperCase();
    return raw == 'REJECTED' || raw == 'REJECTED_BY_OWNER';
  }

  bool _isCounterOfferSent() {
    final raw = _resolveField([r'''$.offerStatus''', r'''$.status''']).toUpperCase();
    return raw == 'COUNTER_OFFERED' || raw == 'COUNTER_OFFER_SENT' || raw == 'COUNTERED';
  }

  num? _resolveCounterOfferAmount() {
    final raw = getJsonField(_offerData, r'''$.counterOfferData.proposedAmount''') ??
        getJsonField(_offerData, r'''$.counterOffer.proposedAmount''') ??
        getJsonField(_offerData, r'''$.activeCounterOffer.proposedAmount''') ??
        getJsonField(_offerData, r'''$.counterOfferAmount''');
    if (raw == null) return null;
    return raw is num ? raw : num.tryParse(raw.toString());
  }

  String _resolveCounterOfferCurrency() {
    return getJsonField(_offerData, r'''$.counterOfferData.currency''')?.toString() ??
        getJsonField(_offerData, r'''$.counterOffer.currency''')?.toString() ??
        _resolveField([r'''$.activeOfferData.currency''', r'''$.currency''']);
  }

  String? _rejectionReason() {
    final v = getJsonField(_offerData, r'''$.rejectionReason''') ??
        getJsonField(_offerData, r'''$.ownerRejectionReason''') ??
        getJsonField(_offerData, r'''$.rejectReason''') ??
        getJsonField(_offerData, r'''$.reason''');
    final s = v?.toString().trim();
    return (s != null && s.isNotEmpty) ? s : null;
  }

  String _formatAmount(num? val) {
    if (val == null) return '—';
    if (val.truncateToDouble() == val) {
      return val.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    }
    return val.toStringAsFixed(2);
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              wrapWithModel(model: _model.cornerGradientBackgroundModel, updateCallback: () => safeSetState(() {}), child: const CornerGradientBackgroundWidget()),
              Column(
                children: [
                  wrapWithModel(model: _model.dOVIASHAREDHeaderModel, updateCallback: () => safeSetState(() {}), child: const DOVIASHAREDHeaderWidget(title: 'Propuesta', hideActions: true, showMap: false, showCurrency: false, showLogo: false)),
                  Expanded(child: _buildBody()),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: wrapWithModel(model: _model.dOVIACLIENTNavbarModel, updateCallback: () => safeSetState(() {}), child: const DOVIACLIENTNavbarWidget()),
              ),
              const Align(alignment: Alignment.bottomRight, child: Padding(padding: EdgeInsets.only(right: 16, bottom: 80), child: FixedDoviaIconWidget())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_errorMessage != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, color: _errorRed, size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: _primaryDark)),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
            onPressed: () { safeSetState(() { _isLoading = true; _errorMessage = null; }); _loadOffer(); },
            child: Text('Reintentar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ]),
      ));
    }

    final amount = _resolveAmount();
    final commission = amount != null ? amount * _doviaCommission : null;
    final totalToReceive = amount != null && commission != null ? amount - commission : null;
    final currency = _resolveField([r'''$.activeOfferData.currency''', r'''$.offerData.currency''', r'''$.currency''']);
    final currencySymbol = currency == 'USD' ? 'USD ' : '';
    final additionalRequest = _resolveField([r'''$.activeOfferData.considerations''', r'''$.offerData.considerations''', r'''$.considerations''']);
    final bankName = _resolveField([r'''$.activeOfferData.bankName''', r'''$.offerData.bankName''', r'''$.bankName''']);
    final downPayment = _resolveField([r'''$.activeOfferData.downPaymentPercentage''', r'''$.offerData.downPaymentPercentage''', r'''$.downPaymentPercentage''', r'''$.activeOfferData.downPayment''', r'''$.offerData.downPayment''', r'''$.downPayment''']);
    final reservationAmount = _resolveField([r'''$.activeOfferData.initialReserve''', r'''$.activeOfferData.reservationAmount''', r'''$.initialReserve''', r'''$.reservationAmount''']);
    final finalPayment = _resolveField([r'''$.activeOfferData.finalPayment''', r'''$.offerData.finalPayment''', r'''$.finalPayment''']);
    final promiseTime = _resolveField([r'''$.activeOfferData.promiseTimeMonths''', r'''$.activeOfferData.promiseTime''', r'''$.promiseTimeMonths''', r'''$.promiseTime''']);
    final canAct = _canAct();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status badge ──────────────────────────────────────────────────
          Text('Propuesta · ${_offerTypeLabel()}',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: _primaryDark)),
          const SizedBox(height: 20),

          // ── Método de pago (read-only) ────────────────────────────────────
          _fieldLabel('Método de pago'),
          const SizedBox(height: 8),
          _readOnlyField(_paymentMethodLabel()),
          const SizedBox(height: 20),

          if (_paymentMethodLabel() == 'Hipoteca') ...[
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Banco'),
                const SizedBox(height: 8),
                _readOnlyField(bankName == '—' ? 'No especificado' : bankName),
              ])),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Enganche'),
                const SizedBox(height: 8),
                _readOnlyField(downPayment == '—' ? 'No especificado' : '$downPayment%'),
              ])),
            ]),
            const SizedBox(height: 20),
          ] else if (_paymentMethodLabel() == 'Promesa de compra') ...[
            _fieldLabel('Reserva'),
            const SizedBox(height: 4),
            Text('La comisión Dovia se paga al recibir la reserva', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF888888))),
            const SizedBox(height: 8),
            _readOnlyField(reservationAmount == '—' ? 'No especificado' : '$currencySymbol${_formatAmount(num.tryParse(reservationAmount))}'),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Pago final'),
                const SizedBox(height: 8),
                _readOnlyField(finalPayment == '—' ? 'No especificado' : '$currencySymbol${_formatAmount(num.tryParse(finalPayment))}'),
              ])),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Tiempo de promesa'),
                const SizedBox(height: 8),
                _readOnlyField(promiseTime == '—' ? 'No especificado' : '$promiseTime meses'),
              ])),
            ]),
            const SizedBox(height: 20),
          ],

          // ── Propuesta económica (dropdown) ────────────────────────────────
          _fieldLabel('Propuesta económica'),
          const SizedBox(height: 8),
          _economicDropdown(amount, commission, totalToReceive, currencySymbol),
          const SizedBox(height: 20),

          // ── Solicitud adicional (read-only) ───────────────────────────────
          _fieldLabel('Solicitud adicional'),
          const SizedBox(height: 8),
          _readOnlyTextArea(additionalRequest == '—' ? 'Sin solicitudes adicionales' : additionalRequest),
          const SizedBox(height: 32),

          // ── Action buttons / counter-offer state ─────────────────────────
          if (_isCounterOfferSent()) _counterOfferSentCard(amount, currencySymbol)
          else if (canAct) _actionButtons()
          else _statusMessage(),

          // ── Rejection reason (only when owner rejected) ───────────────────
          if (_isRejectedByOwner()) ...[
            const SizedBox(height: 24),
            _rejectionReasonSection(),
          ],
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: GoogleFonts.inter(fontSize: 16, color: _primaryDark, fontWeight: FontWeight.w400));

  Widget _readOnlyField(String value) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(10)),
    child: Text(value, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF888888))),
  );

  Widget _readOnlyTextArea(String value) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 80),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(10)),
    child: Text(value, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF888888))),
  );

  Widget _economicDropdown(num? amount, num? commission, num? total, String currencySymbol) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDFDFDF)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header row (always visible)
          InkWell(
            onTap: () => safeSetState(() => _isEconomicDropdownOpen = !_isEconomicDropdownOpen),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                border: _isEconomicDropdownOpen ? const Border(bottom: BorderSide(color: Color(0xFFDFDFDF))) : null,
              ),
              child: Row(children: [
                Expanded(child: Text(
                  'Propuesta económica: $currencySymbol${_formatAmount(amount)}',
                  style: GoogleFonts.inter(fontSize: 15, color: _primaryDark),
                )),
                AnimatedRotation(
                  turns: _isEconomicDropdownOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary, size: 22),
                ),
              ]),
            ),
          ),
          // Expandable rows
          if (_isEconomicDropdownOpen) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFDFDFDF)))),
              child: Row(children: [
                Expanded(child: Text('Comisión Dovia (3.5%)', style: GoogleFonts.inter(fontSize: 15, color: _primaryDark))),
                Text('$currencySymbol${_formatAmount(commission)}', style: GoogleFonts.inter(fontSize: 15, color: _errorRed, fontWeight: FontWeight.w600)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF70ACAD).withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Row(children: [
                Expanded(child: Text('Total a recibir', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _primaryDark))),
                Text('$currencySymbol${_formatAmount(total)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _primary)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButtons() {
    final bankName = _resolveField([r'''$.activeOfferData.bankName''', r'''$.offerData.bankName''', r'''$.bankName''']);
    final downPayment = _resolveField([r'''$.activeOfferData.downPaymentPercentage''', r'''$.offerData.downPaymentPercentage''', r'''$.downPaymentPercentage''', r'''$.activeOfferData.downPayment''', r'''$.offerData.downPayment''', r'''$.downPayment''']);
    final reservationAmount = _resolveField([r'''$.activeOfferData.initialReserve''', r'''$.activeOfferData.reservationAmount''', r'''$.initialReserve''']);
    final finalPayment = _resolveField([r'''$.activeOfferData.finalPayment''', r'''$.offerData.finalPayment''', r'''$.finalPayment''']);
    final promiseTime = _resolveField([r'''$.activeOfferData.promiseTimeMonths''', r'''$.activeOfferData.promiseTime''', r'''$.promiseTimeMonths''']);

    return Column(children: [
      Row(children: [
        // Rechazar
        Expanded(child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: _isActioning ? null : _rejectOffer,
          child: Text('Rechazar', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _primary)),
        )),
        const SizedBox(width: 10),
        // Contraoferta
        Expanded(child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: _isActioning ? null : () {
            context.pushNamed(
              DOVIACLIENTMisPropiedadesContraofertarWidget.routeName,
              queryParameters: {
                'offerId': serializeParam(widget.offerId, ParamType.String),
                'proposalType': serializeParam(widget.proposalType, ParamType.String),
                'initialAmount': serializeParam(_resolveAmount()?.toString(), ParamType.String),
                'currency': serializeParam(_resolveField([r'''$.activeOfferData.currency''', r'''$.currency''']), ParamType.String),
                'paymentMethod': serializeParam(_resolveField([r'''$.activeOfferData.paymentMethod''', r'''$.paymentMethod''']), ParamType.String),
                'considerations': serializeParam(_resolveField([r'''$.activeOfferData.considerations''', r'''$.considerations''']), ParamType.String),
                'bankName': serializeParam(bankName == '—' ? null : bankName, ParamType.String),
                'downPayment': serializeParam(downPayment == '—' ? null : downPayment, ParamType.String),
                'initialReserve': serializeParam(reservationAmount == '—' ? null : reservationAmount, ParamType.String),
                'finalPayment': serializeParam(finalPayment == '—' ? null : finalPayment, ParamType.String),
                'promiseTimeMonths': serializeParam(promiseTime == '—' ? null : promiseTime, ParamType.String),
              }.withoutNulls,
            );
          },
          child: Text('Contraoferta', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _primary)),
        )),
        const SizedBox(width: 10),
        // Aceptar
        Expanded(child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: _isActioning ? null : _acceptOffer,
          child: _isActioning
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Aceptar', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        )),
      ]),
    ]);
  }

  Widget _counterOfferSentCard(num? originalAmount, String currencySymbol) {
    final counterAmount = _resolveCounterOfferAmount();
    final counterCurrency = _resolveCounterOfferCurrency();
    final counterCurrencySymbol = counterCurrency == 'USD' ? 'USD ' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle_outline_rounded, color: _primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Ya enviaste una contraoferta al comprador.',
              style: GoogleFonts.inter(fontSize: 14, color: _primary, fontWeight: FontWeight.w500),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        // Summary card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDFDFDF)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Expanded(child: Text('Oferta recibida',
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF666666)))),
                  Text(
                    '$currencySymbol${_formatAmount(originalAmount)}',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _primaryDark),
                  ),
                ]),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Expanded(child: Text('Tu contraoferta',
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF666666)))),
                  Text(
                    counterAmount != null
                        ? '$counterCurrencySymbol${_formatAmount(counterAmount)}'
                        : '—',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _primary),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rejectionReasonSection() {
    final reason = _rejectionReason();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Por qué rechazaste esta oferta?',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _primaryDark),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            reason ?? 'Sin motivo especificado',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF888888)),
          ),
        ),
      ],
    );
  }

  Widget _statusMessage() {
    final statusLabel = _offerStatusLabel();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor().withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor().withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline_rounded, color: _statusColor(), size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text('Esta oferta está $statusLabel y ya no puede ser modificada.',
            style: GoogleFonts.inter(fontSize: 14, color: _statusColor()))),
      ]),
    );
  }
}


