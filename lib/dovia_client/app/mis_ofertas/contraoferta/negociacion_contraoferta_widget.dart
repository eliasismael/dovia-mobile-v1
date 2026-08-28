import '/core/result.dart';
import '/domain/client_offer_detail.dart';
import '/domain/counter_offer_view.dart';
import '/repositories/offers_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Las dos propuestas enfrentadas: la que el cliente envió, congelada arriba
/// como referencia, y la que el propietario devolvió, abajo.
///
/// El trilema define el rumbo de la negociación. [Rechazar] no rechaza de una:
/// despliega el motivo obligatorio al pie, con los tres botones todavía a la
/// vista para poder cambiar de idea. [Contraoferta] tampoco navega a otro
/// lado: abre los campos de abajo para reescribir los montos y devolver la
/// pelota.
class NegociacionContraofertaWidget extends StatefulWidget {
  const NegociacionContraofertaWidget({
    super.key,
    required this.offerId,
    required this.view,
    this.onResolved,
  });

  final String offerId;
  final CounterOfferView view;

  /// Se llama cuando la negociación se movió, para que la pantalla recargue.
  final VoidCallback? onResolved;

  @override
  State<NegociacionContraofertaWidget> createState() =>
      _NegociacionContraofertaWidgetState();
}

class _NegociacionContraofertaWidgetState
    extends State<NegociacionContraofertaWidget> {
  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _mineBg = Color(0xFFD9D7D7);
  static const Color _theirsBg = Color(0xFFFAFAFA);
  static const Color _fieldText = Color(0xFF888888);
  static const Color _destructive = Color(0xFFE44444);
  static const Color _currencyPill = Color(0xFF70ACAD);

  final TextEditingController _rejectReasonCtrl = TextEditingController();
  final Map<CounterOfferInput, TextEditingController> _inputs = {};

  bool _isRejecting = false;
  bool _isCountering = false;
  bool _isActioning = false;

  @override
  void dispose() {
    _rejectReasonCtrl.dispose();
    for (final controller in _inputs.values) {
      controller.dispose();
    }
    super.dispose();
  }

  OffersRepository get _repository => context.read<OffersRepository>();

  void _startCountering() {
    final initial = widget.view.initialInputs;
    for (final entry in initial.entries) {
      _inputs[entry.key] = TextEditingController(text: entry.value);
    }
    safeSet(() => _isCountering = true);
  }

  void _cancelCountering() {
    for (final controller in _inputs.values) {
      controller.dispose();
    }
    _inputs.clear();
    safeSet(() => _isCountering = false);
  }

  void safeSet(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  Future<void> _accept() async {
    safeSet(() => _isActioning = true);
    final result = await _repository.acceptOfferAsClient(widget.offerId);
    if (!mounted) return;
    safeSet(() => _isActioning = false);
    _handle(result, '¡Aceptaste la oferta! Empieza el proceso legal.');
  }

  Future<void> _confirmReject() async {
    final reason = _rejectReasonCtrl.text.trim();
    if (reason.isEmpty) return;

    safeSet(() => _isActioning = true);
    final result = await _repository.withdrawMyOffer(
      offerId: widget.offerId,
      reason: reason,
    );
    if (!mounted) return;
    safeSet(() => _isActioning = false);
    _handle(result, 'Rechazaste la oferta y avisamos al propietario.');
  }

  Future<void> _sendCounterOffer() async {
    final data = <String, dynamic>{
      'paymentMethod': widget.view.paymentMethodApiValue,
      'currency': widget.view.currency == 'Quetzales'
          ? 'GTQ'
          : widget.view.currency,
    };

    for (final entry in _inputs.entries) {
      final raw = entry.value.text.trim();
      if (raw.isEmpty) continue;
      data[entry.key.apiKey] =
          entry.key.isNumeric ? num.tryParse(raw) ?? raw : raw;
    }

    safeSet(() => _isActioning = true);
    final result = await _repository.createCounterOffer(
      offerId: widget.offerId,
      counterOfferData: data,
    );
    if (!mounted) return;
    safeSet(() => _isActioning = false);
    _handle(result, 'Enviamos tu contraoferta al propietario.');
  }

  void _handle(Result<bool> result, String success) {
    switch (result) {
      case Success():
        _toast(success);
        widget.onResolved?.call();
        break;
      case Failure(:final message):
        _toast(message, isError: true);
        break;
    }
  }

  void _toast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? _destructive : const Color(0xFF555555),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Tu propuesta'),
        const SizedBox(height: 18),
        ..._readOnlyRows(widget.view.mine, _mineBg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _aqua)),
          ),
          child: _sectionTitle('Propuesta del propietario'),
        ),
        if (!widget.view.hasCounterOffer)
          _waitingCard()
        else ...[
          _currencyChips(),
          ..._theirsRows(),
          const SizedBox(height: 4),
          _trilemma(),
          if (_isCountering) ...[
            const SizedBox(height: 18),
            _counterOfferActions(),
          ],
          if (_isRejecting) ...[
            const SizedBox(height: 18),
            _rejectReasonBox(),
          ],
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) => Center(
        child: Text(
          title,
          style: GoogleFonts.publicSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _text,
          ),
        ),
      );

  List<Widget> _readOnlyRows(List<OfferDetailField> fields, Color background) {
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final next = i + 1 < fields.length ? fields[i + 1] : null;
      if (field.half && next != null && next.half) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _readOnlyField(field, background)),
            const SizedBox(width: 17),
            Expanded(child: _readOnlyField(next, background)),
          ],
        ));
        i++;
        continue;
      }
      rows.add(_readOnlyField(field, background));
    }
    return rows;
  }

  Widget _readOnlyField(OfferDetailField field, Color background) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(field.label),
        const SizedBox(height: 12),
        if (field.kind == OfferDetailFieldKind.currency)
          // En "Tu propuesta" la moneda elegida va como una sola píldora
          // llena: no hay nada que elegir, ya se eligió.
          Container(
            width: double.infinity,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _currencyPill,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              field.value,
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: field.kind == OfferDetailFieldKind.textArea ? 104 : 42,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: field.kind == OfferDetailFieldKind.textArea
                  ? Alignment.topLeft
                  : Alignment.centerLeft,
              child: Text(
                field.value,
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  letterSpacing: 0.28,
                  color: _fieldText,
                ),
              ),
            ),
          ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.publicSans(
          fontSize: 14,
          letterSpacing: 0.28,
          color: _text,
        ),
      );

  /// La moneda de la contraoferta se muestra pero no se cambia: el DTO la
  /// hereda de la negociación en curso.
  Widget _currencyChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Moneda de pago'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _currencyChip('USD')),
            const SizedBox(width: 17),
            Expanded(child: _currencyChip('Quetzales')),
          ],
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _currencyChip(String label) {
    final isSelected = widget.view.currency == label;
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? _aqua : Colors.white,
        border: Border.all(color: _aqua),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        label,
        style: GoogleFonts.publicSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : _aqua,
        ),
      ),
    );
  }

  List<Widget> _theirsRows() {
    final rows = <Widget>[];
    final items = widget.view.theirs;
    for (var i = 0; i < items.length; i++) {
      final row = items[i];
      final next = i + 1 < items.length ? items[i + 1] : null;
      if (row.field.half && next != null && next.field.half) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _theirsField(row)),
            const SizedBox(width: 17),
            Expanded(child: _theirsField(next)),
          ],
        ));
        i++;
        continue;
      }
      rows.add(_theirsField(row));
    }
    return rows;
  }

  Widget _theirsField(CounterOfferRow row) {
    final controller = _inputs[row.input];
    if (!_isCountering || controller == null) {
      return _readOnlyField(row.field, _theirsBg);
    }

    final isTextArea = row.field.kind == OfferDetailFieldKind.textArea;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(row.field.label),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: isTextArea ? 104 : 42,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _aqua),
          ),
          child: TextField(
            controller: controller,
            maxLines: isTextArea ? null : 1,
            expands: isTextArea,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: row.input!.isNumeric
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            inputFormatters: row.input!.isNumeric
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            style: GoogleFonts.publicSans(fontSize: 14, color: _text),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _waitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDFDFDF)),
      ),
      child: Column(
        children: [
          const Icon(Icons.hourglass_empty_rounded, color: _aqua, size: 28),
          const SizedBox(height: 8),
          Text(
            'Esperando respuesta del propietario...',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
                fontSize: 14, color: const Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  /// Los tres botones en fila, como el diseño. Siguen visibles mientras se
  /// escribe el motivo del rechazo o se arma la contraoferta.
  Widget _trilemma() {
    return Row(
      children: [
        Expanded(
          child: _outlineButton(
            'Rechazar',
            onPressed: _isActioning || _isCountering
                ? null
                : () => safeSet(() => _isRejecting = !_isRejecting),
          ),
        ),
        const SizedBox(width: 17),
        Expanded(
          child: _outlineButton(
            'Contraoferta',
            onPressed: _isActioning || _isRejecting
                ? null
                : (_isCountering ? _cancelCountering : _startCountering),
          ),
        ),
        const SizedBox(width: 17),
        Expanded(
          child: SizedBox(
            height: 42,
            child: FilledButton(
              onPressed:
                  _isActioning || _isRejecting || _isCountering ? null : _accept,
              style: FilledButton.styleFrom(
                backgroundColor: _aqua,
                disabledBackgroundColor: _aqua.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isActioning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      'Aceptar',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _outlineButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _aqua),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _aqua,
          ),
        ),
      ),
    );
  }

  Widget _counterOfferActions() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: FilledButton(
        onPressed: _isActioning ? null : _sendCounterOffer,
        style: FilledButton.styleFrom(
          backgroundColor: _aqua,
          disabledBackgroundColor: _aqua.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          'Enviar oferta',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// El motivo es obligatorio: lo lee el propietario y cierra la negociación,
  /// así que confirmar espera a que haya algo escrito.
  Widget _rejectReasonBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('¿Por qué rechazaste la oferta?'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 104,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: _theirsBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDFDFDF)),
          ),
          child: TextField(
            controller: _rejectReasonCtrl,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            onChanged: (_) => safeSet(() {}),
            decoration: InputDecoration(
              hintText: 'Escribe aquí...',
              hintStyle:
                  GoogleFonts.publicSans(fontSize: 14, color: _fieldText),
              border: InputBorder.none,
              isDense: true,
            ),
            style: GoogleFonts.publicSans(fontSize: 14, color: _text),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _outlineButton(
                'Cancelar',
                onPressed: _isActioning
                    ? null
                    : () => safeSet(() {
                          _isRejecting = false;
                          _rejectReasonCtrl.clear();
                        }),
              ),
            ),
            const SizedBox(width: 17),
            Expanded(
              child: SizedBox(
                height: 42,
                child: FilledButton(
                  onPressed:
                      _isActioning || _rejectReasonCtrl.text.trim().isEmpty
                          ? null
                          : _confirmReject,
                  style: FilledButton.styleFrom(
                    backgroundColor: _destructive,
                    disabledBackgroundColor: _destructive.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Confirmar rechazo',
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
