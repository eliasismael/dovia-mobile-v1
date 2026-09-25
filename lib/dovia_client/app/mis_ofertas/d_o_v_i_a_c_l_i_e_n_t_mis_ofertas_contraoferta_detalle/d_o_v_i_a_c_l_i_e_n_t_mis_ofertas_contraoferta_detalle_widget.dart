import '/core/amount_input_formatter.dart';
import '/core/result.dart';
import '/domain/client_counter_offer_detail.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/repositories/offers_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_contraoferta_detalle_model.dart';

export 'd_o_v_i_a_c_l_i_e_n_t_mis_ofertas_contraoferta_detalle_model.dart';

typedef CounterOfferAction = Future<Result<bool>> Function();
typedef RejectCounterOfferAction = Future<Result<bool>> Function(String reason);
typedef SendCounterOfferAction = Future<Result<bool>> Function(
  Map<String, dynamic> data,
);

class DOVIACLIENTMisOfertasContraofertaDetalleWidget extends StatefulWidget {
  const DOVIACLIENTMisOfertasContraofertaDetalleWidget({
    super.key,
    this.offerId,
  });

  final String? offerId;

  static String routeName = 'DOVIA_CLIENT_MisOfertasContraofertaDetalle';
  static String routePath = '/dOVIACLIENTMisOfertasContraofertaDetalle';

  @override
  State<DOVIACLIENTMisOfertasContraofertaDetalleWidget> createState() =>
      _DOVIACLIENTMisOfertasContraofertaDetalleWidgetState();
}

class _DOVIACLIENTMisOfertasContraofertaDetalleWidgetState
    extends State<DOVIACLIENTMisOfertasContraofertaDetalleWidget> {
  late DOVIACLIENTMisOfertasContraofertaDetalleModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ClientCounterOfferDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(
      context,
      () => DOVIACLIENTMisOfertasContraofertaDetalleModel(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await context
        .read<OffersRepository>()
        .loadClientCounterOfferDetail(widget.offerId ?? '');
    if (!mounted) return;
    safeSetState(() {
      _isLoading = false;
      switch (result) {
        case Success(:final data):
          _detail = data;
          _errorMessage = null;
        case Failure(:final message):
          _detail = null;
          _errorMessage = message;
      }
    });
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
                child: const CornerGradientBackgroundWidget(),
              ),
              Column(
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      title: 'Contraoferta',
                      showCurrency: false,
                      showLogo: false,
                    ),
                  ),
                  Expanded(child: _body()),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: wrapWithModel(
                  model: _model.dOVIACLIENTNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const DOVIACLIENTNavbarWidget(),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 82.0),
                  child: wrapWithModel(
                    model: _model.fixedDoviaIconModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const FixedDoviaIconWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12.0),
              TextButton(
                onPressed: () {
                  safeSetState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _load();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    final repository = context.read<OffersRepository>();
    return ClientCounterOfferContent(
      detail: detail,
      onAccept: () => repository.acceptClientCounterOffer(detail.offerId),
      onReject: (reason) => repository.rejectClientCounterOffer(
        offerId: detail.offerId,
        reason: reason,
      ),
      onSendCounterOffer: (data) => repository.createCounterOffer(
        offerId: detail.offerId,
        counterOfferData: data,
      ),
      onResolved: () => context.safePop(),
    );
  }
}

/// Una celda de la grilla de una propuesta: a media línea o a lo ancho.
class _TermSlot {
  const _TermSlot({required this.half, required this.child});

  final bool half;
  final Widget child;
}

class ClientCounterOfferContent extends StatefulWidget {
  const ClientCounterOfferContent({
    super.key,
    required this.detail,
    required this.onAccept,
    required this.onReject,
    required this.onSendCounterOffer,
    this.onResolved,
  });

  final ClientCounterOfferDetail detail;
  final CounterOfferAction onAccept;
  final RejectCounterOfferAction onReject;
  final SendCounterOfferAction onSendCounterOffer;
  final VoidCallback? onResolved;

  @override
  State<ClientCounterOfferContent> createState() =>
      _ClientCounterOfferContentState();
}

class _ClientCounterOfferContentState extends State<ClientCounterOfferContent> {
  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _disabled = Color(0xFFD9D7D7);
  static const Color _surface = Color(0xFFFAFAFA);
  static const Color _destructive = Color(0xFFE44444);

  final Map<CounterOfferFieldKey, TextEditingController> _controllers = {};

  /// Campos que son montos: se escriben con separadores de miles.
  static const _moneyKeys = {
    CounterOfferFieldKey.proposedAmount,
    CounterOfferFieldKey.initialReserve,
    CounterOfferFieldKey.finalPayment,
  };
  static bool _isMoney(CounterOfferFieldKey key) => _moneyKeys.contains(key);

  final _rejectReasonController = TextEditingController();
  bool _isCounterEditing = false;
  bool _showRejectReason = false;
  bool _isSubmitting = false;
  String? _validationMessage;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.detail.ownerTerms.currency;
    for (final field in widget.detail.ownerTerms.fields) {
      if (!field.editable) continue;
      _controllers[field.key] = TextEditingController(
          text: _isMoney(field.key)
              ? formatAmountText(field.value)
              : field.value);
    }
    _rejectReasonController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _rejectReasonController
      ..removeListener(_refresh)
      ..dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20.0, 26.0, 20.0, 150.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _processStepper(),
              const SizedBox(height: 28.0),
              _termsSection(
                title: 'Tu propuesta',
                terms: widget.detail.originalTerms,
                readOnly: true,
                background: _disabled,
              ),
              const SizedBox(height: 18.0),
              const Divider(color: _aqua, thickness: 1.0),
              const SizedBox(height: 12.0),
              _termsSection(
                title: 'Propuesta del propietario',
                terms: widget.detail.ownerTerms,
                readOnly: !_isCounterEditing,
                background: _surface,
                useControllers: true,
              ),
              if (_validationMessage != null) ...[
                Text(
                  _validationMessage!,
                  style: GoogleFonts.publicSans(
                    color: _destructive,
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
              if (widget.detail.canResolve) _resolutionActions(),
              if (_showRejectReason) _rejectReason(),
              if (widget.detail.isRejected) _rejectionBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _processStepper() {
    const labels = [
      ('PASO 1', 'Negociación'),
      ('PASO 2', 'Estructuración\nde acuerdo'),
      ('PASO 3', 'Firma de\ncontrato'),
      ('PASO 4', 'Finaliza\nproceso'),
    ];
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18.0,
            offset: Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de tu proceso',
            style: GoogleFonts.publicSans(fontSize: 14.0, color: _text),
          ),
          const SizedBox(height: 18.0),
          Row(
            children: [
              for (var index = 0; index < labels.length; index++) ...[
                Expanded(
                    child: _step(labels[index].$1, labels[index].$2, index)),
                if (index < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2.0,
                      color: index == 0
                          ? const Color(0xFF70ACAD)
                          : const Color(0xFFD5D5D5),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _step(String step, String label, int index) {
    final active = index == 0;
    return Column(
      children: [
        Container(
          width: 23.0,
          height: 23.0,
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: active ? const Color(0xFF70ACAD) : const Color(0xFFD5D5D5),
              width: 2.0,
            ),
          ),
          child: active
              ? const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF70ACAD),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4.0),
        Text(step, style: GoogleFonts.publicSans(fontSize: 7.0, color: _text)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.publicSans(
            fontSize: 9.0,
            fontWeight: FontWeight.w600,
            color: _text,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFD9EEEE) : Colors.transparent,
            border: active ? null : Border.all(color: const Color(0xFFD5D5D5)),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            active ? 'En Proceso' : 'Pendiente',
            style: GoogleFonts.publicSans(
              fontSize: 7.0,
              color: active ? _aqua : const Color(0xFF9A9A9A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _termsSection({
    required String title,
    required CounterOfferTerms terms,
    required bool readOnly,
    required Color background,
    bool useControllers = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.publicSans(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: _text,
          ),
        ),
        const SizedBox(height: 18.0),
        _rows(_slots(
          terms,
          readOnly: readOnly,
          background: background,
          useControllers: useControllers,
        )),
      ],
    );
  }

  /// Los bloques de una propuesta en el orden del diseño.
  ///
  /// La moneda no es un campo del backend pero ocupa una celda más de la
  /// grilla: encabeza la propuesta del propietario —ahí se elige— y en la
  /// propia acompaña al último dato antes de la solicitud adicional, que
  /// siempre cierra a lo ancho.
  List<_TermSlot> _slots(
    CounterOfferTerms terms, {
    required bool readOnly,
    required Color background,
    required bool useControllers,
  }) {
    final considerations = terms.fields
        .where((field) => field.key == CounterOfferFieldKey.considerations);
    final rest = terms.fields
        .where((field) => field.key != CounterOfferFieldKey.considerations);
    final currency = _currencySelector(
      terms.currency,
      editable: !readOnly && useControllers,
    );

    return [
      if (useControllers) _TermSlot(half: false, child: currency),
      for (final field in rest)
        _TermSlot(
          half: field.half,
          child: _field(field, readOnly, background, useControllers),
        ),
      if (!useControllers) _TermSlot(half: true, child: currency),
      for (final field in considerations)
        _TermSlot(
          half: false,
          child: _field(field, readOnly, background, useControllers),
        ),
    ];
  }

  /// Empareja los bloques a media línea, uno debajo del otro en pantallas
  /// angostas.
  Widget _rows(List<_TermSlot> slots) {
    final rows = <Widget>[];
    var index = 0;
    while (index < slots.length) {
      final slot = slots[index];
      final next = index + 1 < slots.length ? slots[index + 1] : null;
      if (slot.half && next?.half == true) {
        rows.add(
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 620.0) {
                return Column(children: [slot.child, next!.child]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: slot.child),
                  const SizedBox(width: 17.0),
                  Expanded(child: next!.child),
                ],
              );
            },
          ),
        );
        index += 2;
      } else {
        rows.add(slot.child);
        index++;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget _field(
    CounterOfferField field,
    bool readOnly,
    Color background,
    bool useControllers,
  ) {
    final controller = useControllers ? _controllers[field.key] : null;
    final displayed =
        field.value.isEmpty ? '—' : '${field.value}${field.suffix}';
    final locked = readOnly || !field.editable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: GoogleFonts.publicSans(color: _text)),
          const SizedBox(height: 8.0),
          if (locked || controller == null)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight:
                    field.kind == CounterOfferFieldKind.textArea ? 92.0 : 42.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                displayed,
                style: GoogleFonts.publicSans(
                  color: const Color(0xFF888888),
                  fontSize: 14.0,
                ),
              ),
            )
          else
            TextFormField(
              key: ValueKey('counter-${field.key.name}'),
              controller: controller,
              maxLines: field.kind == CounterOfferFieldKind.textArea ? 4 : 1,
              keyboardType: field.kind == CounterOfferFieldKind.number
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : null,
              inputFormatters: _isMoney(field.key)
                  ? [AmountInputFormatter()]
                  : field.kind == CounterOfferFieldKind.number
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                      : null,
              decoration: InputDecoration(
                prefixText: _isMoney(field.key)
                    ? '${currencySymbol(_selectedCurrency)} '
                    : null,
                filled: true,
                fillColor: Colors.white,
                suffixText: field.suffix.trim().isEmpty ? null : field.suffix,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Color(0xFFB5D6D7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: _aqua),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _currencySelector(String currency, {required bool editable}) {
    final selected = editable ? _selectedCurrency : currency;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Moneda de pago', style: GoogleFonts.publicSans(color: _text)),
          const SizedBox(height: 8.0),
          if (editable)
            Row(
              children: [
                Expanded(child: _currencyPill('USD', selected, true)),
                const SizedBox(width: 10.0),
                Expanded(child: _currencyPill('GTQ', selected, true)),
              ],
            )
          else
            _currencyPill(selected, selected, false),
        ],
      ),
    );
  }

  Widget _currencyPill(String value, String selected, bool editable) {
    final isSelected = value == selected;
    return InkWell(
      onTap: editable ? () => setState(() => _selectedCurrency = value) : null,
      borderRadius: BorderRadius.circular(25.0),
      child: Container(
        height: 39.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isSelected && !editable ? const Color(0xFF70ACAD) : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: _aqua),
        ),
        child: Text(
          value == 'GTQ' ? 'Quetzales' : 'USD',
          style: GoogleFonts.publicSans(
            color: isSelected && !editable ? Colors.white : _aqua,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _resolutionActions() {
    final actions = [
      _outlineButton('Rechazar', _startReject, const ValueKey('reject-offer')),
      _outlineButton(
        _isCounterEditing ? 'Enviar contraoferta' : 'Contraoferta',
        _isCounterEditing ? _sendCounterOffer : _startCounterOffer,
        const ValueKey('counter-offer'),
      ),
      _primaryButton('Aceptar', _accept, const ValueKey('accept-offer')),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620.0) {
          return Column(
            children: actions
                .map((button) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: button,
                    ))
                .toList(),
          );
        }
        return Row(
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              Expanded(child: actions[index]),
              if (index < actions.length - 1) const SizedBox(width: 12.0),
            ],
          ],
        );
      },
    );
  }

  Widget _outlineButton(String text, VoidCallback action, Key key) {
    return SizedBox(
      height: 40.0,
      child: OutlinedButton(
        key: key,
        onPressed: _isSubmitting ? null : action,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _aqua),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.publicSans(
            color: _aqua,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback action, Key key) {
    return SizedBox(
      height: 40.0,
      child: ElevatedButton(
        key: key,
        onPressed: _isSubmitting ? null : action,
        style: ElevatedButton.styleFrom(
          backgroundColor: _aqua,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 17.0,
                height: 17.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              )
            : Text(text, style: GoogleFonts.publicSans(color: Colors.white)),
      ),
    );
  }

  Widget _rejectReason() {
    final hasReason = _rejectReasonController.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Por qué rechazas la oferta?',
            style: GoogleFonts.publicSans(color: _text),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            key: const ValueKey('rejection-reason'),
            controller: _rejectReasonController,
            minLines: 4,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Escribe aquí...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            height: 40.0,
            child: ElevatedButton(
              key: const ValueKey('confirm-rejection'),
              onPressed: !_isSubmitting && hasReason ? _reject : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _destructive,
                disabledBackgroundColor: const Color(0x66E44444),
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: Text(
                'Confirmar rechazo',
                style: GoogleFonts.publicSans(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rejectionBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 18.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0x66E44444)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Negociación rechazada:',
            style: GoogleFonts.publicSans(
              color: _destructive,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            widget.detail.rejectionReason.isEmpty
                ? 'No se proporcionó un motivo.'
                : widget.detail.rejectionReason,
            style: GoogleFonts.publicSans(color: _text),
          ),
        ],
      ),
    );
  }

  void _startReject() {
    setState(() {
      _showRejectReason = true;
      _isCounterEditing = false;
      _validationMessage = null;
    });
  }

  void _startCounterOffer() {
    setState(() {
      _isCounterEditing = true;
      _showRejectReason = false;
      _validationMessage = null;
    });
  }

  Future<void> _accept() async {
    await _run(widget.onAccept, 'Contraoferta aceptada.');
  }

  Future<void> _reject() async {
    final reason = _rejectReasonController.text.trim();
    if (reason.isEmpty) return;
    await _run(() => widget.onReject(reason), 'Oferta rechazada.');
  }

  Future<void> _sendCounterOffer() async {
    final values = <CounterOfferFieldKey, String>{
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
    final requiredAmount = _controllers[CounterOfferFieldKey.proposedAmount];
    if (requiredAmount != null &&
        num.tryParse(requiredAmount.text.replaceAll(',', '')) == null) {
      setState(
          () => _validationMessage = 'Ingresa una propuesta económica válida.');
      return;
    }
    final payload = widget.detail.ownerTerms.toCounterOfferPayload(
      values,
      selectedCurrency: _selectedCurrency,
    );
    await _run(
      () => widget.onSendCounterOffer(payload),
      'Contraoferta enviada.',
    );
  }

  Future<void> _run(CounterOfferAction action, String successMessage) async {
    setState(() {
      _isSubmitting = true;
      _validationMessage = null;
    });
    final result = await action();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        widget.onResolved?.call();
      case Failure(:final message):
        setState(() => _validationMessage = message);
    }
  }
}
