// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneInputWidget extends StatefulWidget {
  const PhoneInputWidget({
    super.key,
    this.width,
    this.height,
    this.initialCountryCode,
    this.onPhoneUpdate,
  });

  final double? width;
  final double? height;
  final String? initialCountryCode;
  final Future Function(String phoneNumber)? onPhoneUpdate;

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 80.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta superior idéntica a tu imagen
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Teléfono ',
                  style: TextStyle(
                    color: Color(0xFF004D40), // Tono oscuro (Teal) de la imagen
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          // Campo de teléfono sin bordes
          IntlPhoneField(
            decoration: const InputDecoration(
              hintText: '123456789',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              counterText: '', // Oculta el contador de caracteres nativo
              contentPadding: EdgeInsets.zero,
            ),
            initialCountryCode: widget.initialCountryCode ?? 'PE',
            showDropdownIcon:
                false, // Mantiene el diseño minimalista de tu imagen
            flagsButtonPadding: const EdgeInsets.only(right: 8),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black, // Color del texto cuando el usuario escribe
            ),
            onChanged: (phone) {
              // Dispara la acción en FF y envía el número completo (ej: +51123456789)
              if (widget.onPhoneUpdate != null) {
                widget.onPhoneUpdate!(phone.completeNumber);
              }
            },
          ),
        ],
      ),
    );
  }
}
