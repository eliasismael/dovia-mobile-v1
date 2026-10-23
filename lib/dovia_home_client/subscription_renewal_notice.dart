/// Aviso de plan vencido, compartido por las pantallas de Dovia Home donde el
/// beneficio del plan importa (Dashboard, Cotización, Valor de la visita).
///
/// El cliente sigue siendo suscriptor —el estado es `ACTIVE`/`PAST_DUE`/
/// `CANCEL_SCHEDULED`— pero el período ya terminó y el backend no le aplica
/// los beneficios hasta que se renueve. No se le muestra la versión "sin plan":
/// se le explica que tiene que reactivarlo.
library;

import '/core/result.dart';
import '/dovia_home_client/checkout_launcher.dart';
import '/repositories/payments_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/shared_components/dovia_spinner.dart';

class SubscriptionRenewalNotice extends StatefulWidget {
  const SubscriptionRenewalNotice({super.key, this.message});

  /// Qué beneficio queda en pausa en esta pantalla. Si no se pasa, el texto
  /// general.
  final String? message;

  @override
  State<SubscriptionRenewalNotice> createState() =>
      _SubscriptionRenewalNoticeState();
}

class _SubscriptionRenewalNoticeState extends State<SubscriptionRenewalNotice> {
  static const _amber = Color(0xFFF57E00);
  static const _amberText = Color(0xFF8A4B0B);

  bool _opening = false;

  /// Con la suscripción todavía en `ACTIVE` el backend no deja comprar otro
  /// plan; la renovación pasa por actualizar el método de pago para que
  /// Recurrente vuelva a cobrar el período.
  Future<void> _reactivate() async {
    final payments = context.read<PaymentsRepository>();
    setState(() => _opening = true);
    final result = await payments.createSetupCheckout();
    if (!mounted) return;
    final order = result.dataOrNull;
    if (order == null) {
      setState(() => _opening = false);
      // El detalle técnico del backend no le sirve al cliente.
      debugPrint('Reactivar plan: ${result.errorOrNull}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'No pudimos reactivar tu plan desde la app. Escríbenos por el '
          'chat de soporte y te ayudamos a renovarlo.',
        ),
      ));
      return;
    }
    await launchDoviaHomeCheckout(order.checkoutUrl);
    if (!mounted) return;
    await payments.loadCurrentSubscription(forceRefresh: true);
    if (mounted) setState(() => _opening = false);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final periodEnd =
        context.watch<PaymentsRepository>().currentSubscription?.periodEnd;
    final ended = periodEnd == null ? '' : ' el ${_formatDate(periodEnd)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFFFDDB8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.autorenew_rounded, color: _amber, size: 22.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Reactiva tu plan Dovia Home',
                  style: GoogleFonts.publicSans(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: _amberText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.message ??
                'Tu período terminó$ended. Mientras no lo renueves, tus '
                    'beneficios (cotizaciones, descuentos y atención '
                    'prioritaria) quedan en pausa.',
            style: GoogleFonts.publicSans(
              fontSize: 14.0,
              height: 1.35,
              color: _amberText,
            ),
          ),
          const SizedBox(height: 14.0),
          SizedBox(
            width: double.infinity,
            height: 42.0,
            child: ElevatedButton(
              onPressed: _opening ? null : _reactivate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007376),
                disabledBackgroundColor: const Color(0x80007376),
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: _opening
                  ? const DoviaSpinner(small: true, color: Colors.white)
                  : Text(
                      'Reactivar plan',
                      style: GoogleFonts.publicSans(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
