// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
// import '/flutter_flow/custom_functions.dart'; // <--- ELIMINADO PARA QUE NO DE ERROR

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';

class SubscriptionPayment extends StatefulWidget {
  final double? width;
  final double? height;
  final Future<dynamic> Function() onActionPressed;
  final Future<dynamic> Function()? onSeeTerms;

  final String paypalLogo;
  final String applePayLogo;
  final String visaLogo;
  final String mastercardLogo;
  final String amexLogo;

  const SubscriptionPayment({
    Key? key,
    this.width,
    this.height,
    required this.onActionPressed,
    this.onSeeTerms,
    this.paypalLogo = 'assets/images/paypal_logo.png',
    this.applePayLogo = 'assets/images/apple_pay_logo.png',
    this.visaLogo = 'assets/images/visa_logo.png',
    this.mastercardLogo = 'assets/images/mastercard_logo.png',
    this.amexLogo = 'assets/images/amex_logo.png',
  }) : super(key: key);

  @override
  _SubscriptionPaymentState createState() => _SubscriptionPaymentState();
}

class _SubscriptionPaymentState extends State<SubscriptionPayment> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color darkTextColor = Color(0xFF004D4F);

  // ignore: unused_field
  static const Color pageBackgroundColor = Color(0xFFF8FAFB);

  int _selectedMethod = 0;
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlanCard(),
          const SizedBox(height: 24),

          // Payment Methods
          _buildPaymentMethods(),
          const SizedBox(height: 24),

          // Card Form
          if (_selectedMethod == 0) ...[
            _buildLabel("Número de tarjeta"),
            const SizedBox(height: 8),
            _buildCardNumberInput(),
            const SizedBox(height: 16),
            _buildLabel("Nombre y Apellido que aparece en la tarjeta"),
            const SizedBox(height: 8),
            _buildTextInput("Nombre y Apellido"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Expira"),
                      const SizedBox(height: 8),
                      _buildTextInput("MM / YY", centered: true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("CVC"),
                      const SizedBox(height: 8),
                      _buildTextInput("CVC", centered: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Additional Fields
          _buildLabel("Introduce tu correo electrónico"),
          const SizedBox(height: 8),
          _buildTextInput("Introduce tu correo electrónico"),
          const SizedBox(height: 16),

          _buildLabel("Introduce el NIT"),
          const SizedBox(height: 8),
          _buildTextInput("Introduce el NIT"),
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
                  onChanged: (v) => setState(() => _termsAccepted = v ?? false),
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
              onPressed: _termsAccepted
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
              child: const Text(
                "Acceder al plan",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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
      child: const Column(
        children: [
          Text(
            "DOVIA BASIC",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "\$30/mes",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Primer cobro: Hoy (DD/MM/AAAA)",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Row(
      children: [
        Expanded(child: _buildMethodCard(0, "Tarjeta", Icons.credit_card)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMethodCard(
            1,
            "PayPal",
            null,
            imagePath: widget.paypalLogo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMethodCard(
            2,
            "ApplePay",
            null,
            imagePath: widget.applePayLogo,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    int index,
    String label,
    IconData? icon, {
    String? imagePath,
  }) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null && imagePath.isNotEmpty)
              _buildResponsiveImage(imagePath, height: 24)
            else
              Icon(
                icon ?? Icons.help_outline,
                color: isSelected ? primaryColor : const Color(0xFF004D4F),
                size: 24,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
    );
  }

  Widget _buildTextInput(String hint, {bool centered = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: const TextStyle(color: darkTextColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCardNumberInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        style: const TextStyle(color: darkTextColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: "1234 1234 1234 1234",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCardAsset(widget.visaLogo),
                const SizedBox(width: 6),
                _buildCardAsset(widget.mastercardLogo),
                const SizedBox(width: 6),
                _buildCardAsset(widget.amexLogo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardAsset(String path) {
    if (path.isEmpty) return const SizedBox.shrink();
    return Container(
      width: 32,
      height: 20,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: _buildResponsiveImage(path),
    );
  }

  Widget _buildResponsiveImage(String path, {double? height}) {
    final bool isNetwork = path.startsWith('http');
    final bool isSvg = path.toLowerCase().endsWith('.svg');

    if (isSvg) {
      if (isNetwork) {
        return SvgPicture.network(
          path,
          height: height,
          fit: BoxFit.contain,
          placeholderBuilder: (BuildContext context) =>
              const Icon(Icons.refresh, size: 20, color: Colors.grey),
        );
      } else {
        return SvgPicture.asset(
          path,
          height: height,
          fit: BoxFit.contain,
          placeholderBuilder: (BuildContext context) =>
              const Icon(Icons.refresh, size: 20, color: Colors.grey),
        );
      }
    }

    if (isNetwork) {
      return Image.network(
        path,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 20, color: Colors.grey),
      );
    } else {
      return Image.asset(
        path,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
      );
    }
  }
}
