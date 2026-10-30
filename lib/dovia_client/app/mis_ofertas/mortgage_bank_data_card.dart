import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_offers.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/dovia_spinner.dart';

/// `true` cuando la oferta de hipoteca ya fue aceptada y todavía espera los
/// datos del banco del comprador.
///
/// El backend crea el expediente que trabaja Legal HQ recién con
/// `POST /offers/{id}/bank-agent-data`, y solo lo acepta con la oferta en
/// `ACCEPTED` / `AWAITING_LEGAL_REVIEW`. Si ya hay expediente o datos del banco,
/// no hay nada que pedir.
bool offerNeedsBankData(Map offer) {
  final hasProcess = (offer['legalProcessId']?.toString() ?? '').isNotEmpty ||
      offer['legalProcess'] is Map;
  if (hasProcess || offer['bankAgentData'] is Map) return false;
  final offerStatus = offer['offerStatus']?.toString().toUpperCase();
  final processStatus = offer['processStatus']?.toString().toUpperCase();
  return offerStatus == 'ACCEPTED' && processStatus == 'AWAITING_LEGAL_REVIEW';
}

/// Formulario del comprador con hipoteca: banco, agencia y, si los tiene, los
/// datos del ejecutivo que lleva su crédito. Al enviarlo, la operación pasa a
/// la bandeja de Legal HQ.
class MortgageBankDataCard extends StatefulWidget {
  const MortgageBankDataCard({
    super.key,
    required this.offerId,
    this.initialBankName = '',
  });

  final String offerId;

  /// Banco que el comprador declaró en la oferta.
  final String initialBankName;

  @override
  State<MortgageBankDataCard> createState() => _MortgageBankDataCardState();
}

class _MortgageBankDataCardState extends State<MortgageBankDataCard> {
  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _fieldBg = Color(0xFFEBEAE3);

  static final RegExp _phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,20}$');
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bankName =
      TextEditingController(text: widget.initialBankName);
  final _bankAddress = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    for (final c in [
      _bankName,
      _bankAddress,
      _firstName,
      _lastName,
      _phone,
      _email,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x2670ACAD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _sent ? _buildSent() : _buildForm(),
    );
  }

  Widget _buildSent() {
    return const Text(
      'Recibimos los datos de tu banco. DOVIA Legal HQ ya tiene tu expediente '
      'y te avisará de cada avance.',
      style: TextStyle(fontSize: 14, color: _textDark, height: 1.4),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Datos de tu banco',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Con estos datos DOVIA abre tu expediente y empieza la gestión con '
            'el banco.',
            style: TextStyle(fontSize: 14, color: _textDark, height: 1.4),
          ),
          const SizedBox(height: 14),
          _field(_bankName, 'Banco', required: true),
          _field(_bankAddress, 'Dirección de la agencia', required: true),
          const SizedBox(height: 6),
          const Text(
            'Ejecutivo del banco (opcional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          _field(_firstName, 'Nombre'),
          _field(_lastName, 'Apellido'),
          _field(
            _phone,
            'Teléfono',
            keyboardType: TextInputType.phone,
            validator: (v) => v.isEmpty || _phoneRegex.hasMatch(v)
                ? null
                : 'Usá un teléfono válido (ej: +502 1234-5678)',
          ),
          _field(
            _email,
            'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v.isEmpty || _emailRegex.hasMatch(v)
                ? null
                : 'Usá un email válido',
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _aqua,
                disabledBackgroundColor: _aqua.withValues(alpha: 0.35),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _sending
                  ? const DoviaSpinner(small: true, color: Colors.white)
                  : const Text(
                      'Enviar a DOVIA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String value)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: _textDark),
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: _fieldBg,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (raw) {
          final value = raw?.trim() ?? '';
          if (required && value.isEmpty) return 'Completá este dato';
          return validator?.call(value);
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() => _sending = true);
    final res = await DOVIAAPIOfferContextGroup.submitBankAgentDataCall.call(
      offerId: widget.offerId,
      authToken: currentAuthenticationToken,
      bankName: _bankName.text,
      bankAddress: _bankAddress.text,
      firstName: _firstName.text,
      lastName: _lastName.text,
      phone: _phone.text,
      email: _email.text,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = res.succeeded;
    });
    if (!res.succeeded) {
      final message = getJsonField(res.jsonBody, r'$.message')?.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message?.isNotEmpty == true
            ? message!
            : 'No se pudieron enviar los datos del banco'),
      ));
    }
  }
}
