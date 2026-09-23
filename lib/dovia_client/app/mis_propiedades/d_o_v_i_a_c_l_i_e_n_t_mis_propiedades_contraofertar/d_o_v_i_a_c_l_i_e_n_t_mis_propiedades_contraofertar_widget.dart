import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/repositories/offers_repository.dart';
import '/core/amount_input_formatter.dart';
import '/core/result.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_contraofertar_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_contraofertar_model.dart';

class DOVIACLIENTMisPropiedadesContraofertarWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesContraofertarWidget({
    super.key,
    String? proposalType,
    this.offerId,
    this.initialAmount,
    this.currency,
    this.paymentMethod,
    this.considerations,
    this.bankName,
    this.downPayment,
    this.initialReserve,
    this.finalPayment,
    this.promiseTimeMonths,
  }) : proposalType = proposalType ?? 'contado';

  final String proposalType;
  final String? offerId;
  final String? initialAmount;
  final String? currency;
  final String? paymentMethod;
  final String? considerations;
  final String? bankName;
  final String? downPayment;
  final String? initialReserve;
  final String? finalPayment;
  final String? promiseTimeMonths;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_Contraofertar';
  static String routePath = '/dOVIACLIENTMisPropiedadesContraofertar';

  @override
  State<DOVIACLIENTMisPropiedadesContraofertarWidget> createState() =>
      _DOVIACLIENTMisPropiedadesContraofertarWidgetState();
}

class _DOVIACLIENTMisPropiedadesContraofertarWidgetState
    extends State<DOVIACLIENTMisPropiedadesContraofertarWidget> {
  late DOVIACLIENTMisPropiedadesContraofertarModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _primary = Color(0xFF007376);
  static const Color _primaryDark = Color(0xFF00444B);
  static const Color _errorRed = Color(0xFFD32F2F);

  // Form state
  late String _selectedCurrency;
  final _amountCtrl = TextEditingController();
  final _considerationsCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _downPaymentCtrl = TextEditingController();
  final _reservationCtrl = TextEditingController();
  final _finalPaymentCtrl = TextEditingController();
  final _promiseTimeCtrl = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesContraofertarModel());
    _selectedCurrency = widget.currency ?? 'USD';
    if (widget.initialAmount != null && widget.initialAmount != '—') {
      _amountCtrl.text = formatAmountText(widget.initialAmount!);
    }
    if (widget.considerations != null && widget.considerations != '—') {
      _considerationsCtrl.text = widget.considerations!;
    }
    if (widget.bankName != null && widget.bankName != '—') {
      _bankCtrl.text = widget.bankName!;
    }
    if (widget.downPayment != null && widget.downPayment != '—') {
      _downPaymentCtrl.text = widget.downPayment!;
    }
    if (widget.initialReserve != null && widget.initialReserve != '—') {
      _reservationCtrl.text = formatAmountText(widget.initialReserve!);
    }
    if (widget.finalPayment != null && widget.finalPayment != '—') {
      _finalPaymentCtrl.text = formatAmountText(widget.finalPayment!);
    }
    if (widget.promiseTimeMonths != null && widget.promiseTimeMonths != '—') {
      _promiseTimeCtrl.text = widget.promiseTimeMonths!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _considerationsCtrl.dispose();
    _bankCtrl.dispose();
    _downPaymentCtrl.dispose();
    _reservationCtrl.dispose();
    _finalPaymentCtrl.dispose();
    _promiseTimeCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  String _paymentMethodLabel(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'cash':
        return 'Contado';
      case 'mortgage':
        return 'Hipoteca';
      case 'purchase_promise':
        return 'Promesa de compra';
      default:
        return (raw ?? '').replaceAll('_', ' ');
    }
  }

  Future<void> _sendCounteroffer() async {
    final amountText = _amountCtrl.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor ingresa un monto para la contraoferta.'),
        backgroundColor: _errorRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final amount = num.tryParse(amountText.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ingresa un monto válido.'),
        backgroundColor: _errorRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    if (widget.offerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error: No se encontró el ID de la oferta.'),
        backgroundColor: _errorRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    safeSetState(() => _isSending = true);

    final repo = context.read<OffersRepository>();

    // Construct the counterOfferData map
    final counterOfferData = {
      'paymentMethod': widget.paymentMethod ?? 'cash',
      'proposedAmount': amount,
      'currency': _selectedCurrency,
      'considerations': _considerationsCtrl.text.trim(),
      if ((widget.paymentMethod ?? '').toLowerCase() == 'mortgage' ||
          (widget.paymentMethod ?? '').toLowerCase() == 'hipoteca') ...{
        'bankName': _bankCtrl.text.trim(),
        'downPaymentPercentage':
            num.tryParse(_downPaymentCtrl.text.trim()) ?? 0,
      },
      if ((widget.paymentMethod ?? '').toLowerCase() == 'purchase_promise' ||
          (widget.paymentMethod ?? '').toLowerCase() == 'promesa') ...{
        'initialReserve':
            num.tryParse(_reservationCtrl.text.trim().replaceAll(',', '')) ?? 0,
        'promiseTimeMonths': num.tryParse(_promiseTimeCtrl.text.trim()) ?? 0,
      }
    };

    final result = await repo.createCounterOffer(
      offerId: widget.offerId!,
      counterOfferData: counterOfferData,
    );

    if (!mounted) return;
    safeSetState(() => _isSending = false);

    switch (result) {
      case Success():
        safeSetState(() => _sent = true);
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $message'),
          backgroundColor: _errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                  child: const CornerGradientBackgroundWidget()),
              Column(
                children: [
                  wrapWithModel(
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIASHAREDHeaderWidget(
                          title: 'Contraoferta',
                          hideActions: true,
                          showMap: false,
                          showCurrency: false,
                          showLogo: false)),
                  Expanded(child: _buildBody()),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: wrapWithModel(
                    model: _model.dOVIACLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIACLIENTNavbarWidget()),
              ),
              const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                      padding: EdgeInsets.only(right: 16, bottom: 80),
                      child: FixedDoviaIconWidget())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sentConfirmation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: _primary, size: 44),
            ),
            const SizedBox(height: 24),
            Text(
              'Contraoferta enviada',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tu contraoferta fue enviada al comprador. Te notificaremos cuando responda.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF666666), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => context.pop(),
                child: Text('Volver',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_sent) return _sentConfirmation();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BLOQUE SUPERIOR: Oferta inicial (solo lectura) ─────────────────
          Text('Oferta inicial',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _primary)),
          const SizedBox(height: 14),
          // Fila 1: Método de pago + Propuesta económica
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _fieldLabel('Método de pago'),
                  const SizedBox(height: 8),
                  _readOnlyField(_paymentMethodLabel(widget.paymentMethod),
                      grayed: true),
                ])),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _fieldLabel('Propuesta económica'),
                  const SizedBox(height: 8),
                  _readOnlyField(
                    widget.initialAmount != null && widget.initialAmount != '—'
                        ? '${widget.currency ?? 'USD'} ${widget.initialAmount}'
                        : '—',
                    grayed: true,
                  ),
                ])),
          ]),
          if (_paymentMethodLabel(widget.paymentMethod) == 'Hipoteca') ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Banco'),
                    const SizedBox(height: 8),
                    _readOnlyField(
                        widget.bankName == null || widget.bankName == '—'
                            ? 'No especificado'
                            : widget.bankName!,
                        grayed: true),
                  ])),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Enganche'),
                    const SizedBox(height: 8),
                    _readOnlyField(
                        widget.downPayment == null || widget.downPayment == '—'
                            ? 'No especificado'
                            : '${widget.downPayment}%',
                        grayed: true),
                  ])),
            ]),
          ] else if (_paymentMethodLabel(widget.paymentMethod) ==
              'Promesa de compra') ...[
            const SizedBox(height: 14),
            _fieldLabel('Reserva'),
            const SizedBox(height: 4),
            Text('La comisión Dovia se paga al recibir la reserva',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF888888))),
            const SizedBox(height: 8),
            _readOnlyField(
                widget.initialReserve == null || widget.initialReserve == '—'
                    ? 'No especificado'
                    : '${widget.currency ?? 'USD'} ${widget.initialReserve}',
                grayed: true),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Pago final'),
                    const SizedBox(height: 8),
                    _readOnlyField(
                        widget.finalPayment == null ||
                                widget.finalPayment == '—'
                            ? 'No especificado'
                            : '${widget.currency ?? 'USD'} ${widget.finalPayment}',
                        grayed: true),
                  ])),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Tiempo de promesa'),
                    const SizedBox(height: 8),
                    _readOnlyField(
                        widget.promiseTimeMonths == null ||
                                widget.promiseTimeMonths == '—'
                            ? 'No especificado'
                            : '${widget.promiseTimeMonths} meses',
                        grayed: true),
                  ])),
            ]),
          ],
          // Fila 2: Moneda de pago (siempre visible)
          const SizedBox(height: 14),
          _fieldLabel('Moneda de pago'),
          const SizedBox(height: 8),
          _readOnlyField(widget.currency ?? 'USD', grayed: true),
          // Fila 3: Solicitud adicional (siempre visible)
          const SizedBox(height: 14),
          _fieldLabel('Solicitud adicional'),
          const SizedBox(height: 8),
          _readOnlyTextArea(
            (widget.considerations == null ||
                    widget.considerations == '—' ||
                    widget.considerations!.isEmpty)
                ? 'Sin solicitudes adicionales'
                : widget.considerations!,
            grayed: true,
          ),

          // ── SEPARADOR ──────────────────────────────────────────────────────
          const SizedBox(height: 24),
          const Divider(color: _primary, thickness: 1),
          const SizedBox(height: 24),

          // ── BLOQUE INFERIOR: Contraoferta editable ─────────────────────────
          Text('Tu propuesta',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryDark)),
          const SizedBox(height: 14),

          // Método de pago (bloqueado, mismo que el original)
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _fieldLabel('Método de pago'),
                  const SizedBox(height: 8),
                  _readOnlyField(_paymentMethodLabel(widget.paymentMethod)),
                ])),
          ]),
          const SizedBox(height: 16),

          // Moneda de pago (selector USD / Quetzales)
          _fieldLabel('Moneda de pago'),
          const SizedBox(height: 10),
          Row(children: [
            _currencyButton('USD'),
            const SizedBox(width: 12),
            _currencyButton('GTQ'),
          ]),
          const SizedBox(height: 16),

          // Propuesta económica (editable)
          _fieldLabel('Propuesta económica'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDFDFDF)),
            ),
            child: TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                AmountInputFormatter()
              ],
              decoration: InputDecoration(
                hintText: 'Ej. 150,000',
                hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF888888), fontSize: 15),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                prefixText: '${currencySymbol(_selectedCurrency)} ',
                prefixStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color: _primaryDark,
                    fontWeight: FontWeight.w500),
              ),
              style: GoogleFonts.inter(fontSize: 15, color: _primaryDark),
            ),
          ),
          const SizedBox(height: 16),

          if (_paymentMethodLabel(widget.paymentMethod) == 'Hipoteca') ...[
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Banco'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDFDFDF))),
                      child: TextField(
                        controller: _bankCtrl,
                        decoration: InputDecoration(
                          hintText: 'Ej. Banco Industrial',
                          hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF888888), fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 13),
                        ),
                        style: GoogleFonts.inter(
                            fontSize: 15, color: _primaryDark),
                      ),
                    ),
                  ])),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Enganche (%)'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDFDFDF))),
                      child: TextField(
                        controller: _downPaymentCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: 'Ej. 20',
                          hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF888888), fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 13),
                        ),
                        style: GoogleFonts.inter(
                            fontSize: 15, color: _primaryDark),
                      ),
                    ),
                  ])),
            ]),
            const SizedBox(height: 16),
          ] else if (_paymentMethodLabel(widget.paymentMethod) ==
              'Promesa de compra') ...[
            _fieldLabel('Reserva'),
            const SizedBox(height: 4),
            Text('La comisión Dovia se paga al recibir la reserva',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF888888))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDFDFDF))),
              child: TextField(
                controller: _reservationCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  AmountInputFormatter()
                ],
                decoration: InputDecoration(
                  hintText: 'Ej. 10,000',
                  hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF888888), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                  prefixText: '${currencySymbol(_selectedCurrency)} ',
                  prefixStyle: GoogleFonts.inter(
                      fontSize: 15,
                      color: _primaryDark,
                      fontWeight: FontWeight.w500),
                ),
                style: GoogleFonts.inter(fontSize: 15, color: _primaryDark),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Pago final'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDFDFDF))),
                      child: TextField(
                        controller: _finalPaymentCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          AmountInputFormatter()
                        ],
                        decoration: InputDecoration(
                          hintText: 'Ej. 140,000',
                          hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF888888), fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 13),
                          prefixText: '${currencySymbol(_selectedCurrency)} ',
                          prefixStyle: GoogleFonts.inter(
                              fontSize: 15,
                              color: _primaryDark,
                              fontWeight: FontWeight.w500),
                        ),
                        style: GoogleFonts.inter(
                            fontSize: 15, color: _primaryDark),
                      ),
                    ),
                  ])),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _fieldLabel('Tiempo de promesa (meses)'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDFDFDF))),
                      child: TextField(
                        controller: _promiseTimeCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: 'Ej. 6',
                          hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF888888), fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 13),
                        ),
                        style: GoogleFonts.inter(
                            fontSize: 15, color: _primaryDark),
                      ),
                    ),
                  ])),
            ]),
            const SizedBox(height: 16),
          ],

          // Solicitud adicional (editable)
          _fieldLabel('Solicitud adicional'),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDFDFDF)),
            ),
            child: TextField(
              controller: _considerationsCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escribe tus condiciones adicionales...',
                hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF888888), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(15),
              ),
              style: GoogleFonts.inter(fontSize: 14, color: _primaryDark),
            ),
          ),
          const SizedBox(height: 32),

          // ── Botón Aceptar y enviar ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isSending ? null : _sendCounteroffer,
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Enviar oferta',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 16, color: _primaryDark, fontWeight: FontWeight.w400));

  Widget _readOnlyField(String value, {bool grayed = false}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: grayed ? const Color(0xFFD9D7D7) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(value,
            style: GoogleFonts.inter(
                fontSize: 15, color: const Color(0xFF888888))),
      );

  Widget _readOnlyTextArea(String value, {bool grayed = false}) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: grayed ? const Color(0xFFD9D7D7) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(value,
            style: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFF888888))),
      );

  Widget _currencyButton(String currency) {
    final isSelected = _selectedCurrency == currency;
    return Expanded(
      child: GestureDetector(
        onTap: () => safeSetState(() => _selectedCurrency = currency),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isSelected ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _primary),
          ),
          alignment: Alignment.center,
          child: Text(
            currency == 'GTQ' ? 'Quetzales' : 'USD',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : _primary,
            ),
          ),
        ),
      ),
    );
  }
}
