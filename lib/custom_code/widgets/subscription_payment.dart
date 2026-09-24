// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import '/flutter_flow/custom_functions.dart'; // <--- ELIMINADO PARA QUE NO DE ERROR

import 'package:flutter/gestures.dart';

/// Resumen del plan y confirmación antes de ir a pagar.
///
/// **No recolecta datos de pago.** El cobro ocurre en el checkout hospedado de
/// Recurrente, que es también el que pide tarjeta, correo y NIT: replicar esos
/// campos acá obligaría a la app a manipular datos de tarjeta, que es
/// justamente lo que el checkout hospedado existe para evitar. Por eso la
/// pantalla se limita a mostrar qué se contrata, pedir la aceptación de los
/// términos y disparar la apertura del checkout.
class SubscriptionPayment extends StatefulWidget {
  final double? width;
  final double? height;

  /// Nombre del plan, tal como lo devuelve `GET /subscriptions/plans`.
  final String planName;

  /// Monto ya formateado (Ej: `Q299.99`).
  final String planPrice;

  /// Sufijo del monto (Ej: ` /mes`).
  final String planPeriod;

  /// Abre el checkout. La pantalla que lo pasa es la que crea la orden.
  final Future<dynamic> Function() onActionPressed;
  final Future<dynamic> Function()? onSeeTerms;

  /// Hay una operación en curso: el botón se bloquea para no crear dos órdenes
  /// con un doble tap.
  final bool isBusy;

  const SubscriptionPayment({
    super.key,
    this.width,
    this.height,
    required this.planName,
    required this.planPrice,
    required this.planPeriod,
    required this.onActionPressed,
    this.onSeeTerms,
    this.isBusy = false,
  });

  @override
  State<SubscriptionPayment> createState() => _SubscriptionPaymentState();
}

class _SubscriptionPaymentState extends State<SubscriptionPayment> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color darkTextColor = Color(0xFF004D4F);

  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final canContinue = _termsAccepted && !widget.isBusy;

    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlanCard(),
          const SizedBox(height: 24),

          // Qué va a pasar al continuar. Se dice explícitamente porque el
          // cobro lo procesa Recurrente y el cliente tiene que esperarlo.
          const Text(
            'Abriremos el pago seguro de Recurrente para completar la '
            'compra, sin salir de la app.',
            style: TextStyle(
              color: darkTextColor,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // --- SECCIÓN CHECKBOX Y TÉRMINOS ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _termsAccepted,
                  activeColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: const BorderSide(color: primaryColor, width: 1.5),
                  onChanged: widget.isBusy
                      ? null
                      : (v) => setState(() => _termsAccepted = v ?? false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: RichText(
                    text: TextSpan(
                      text: "Acepto ",
                      style: const TextStyle(
                        color: darkTextColor,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: "Términos y Condiciones",
                          style: const TextStyle(
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (widget.onSeeTerms != null) {
                                await widget.onSeeTerms!();
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- BOTÓN DE ACCIÓN ---
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: canContinue
                  ? () async {
                      await widget.onActionPressed();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: widget.isBusy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Acceder al plan",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.planName.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.planPrice}${widget.planPeriod}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Primer cobro hoy. Se renueva automáticamente.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
