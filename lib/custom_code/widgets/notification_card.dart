// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class NotificationCard extends StatelessWidget {
  // Parámetros de texto
  final String label;
  final String timeAgo;
  final String title;
  final String description;
  final String footerDate;
  final double? width;
  final double? height;
  const NotificationCard({
    super.key,
    this.width,
    this.height,
    this.label = 'XXX',
    this.timeAgo = '3 MIN AGO',
    this.title = 'Título del trabajo',
    this.description =
        'La empresa no ha llenado las preguntas y le falta finalizarlas.',
    this.footerDate = '10/04/2025 - Hora XX',
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF007376);
    const Color darkTextColor = Color(0xFF004D4F);
    const Color backgroundColor = Color(0xFFF8FAFB);
    const Color mutedColor = Color(0xFF9AA6AC);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                timeAgo.toUpperCase(),
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Description Body
          Text(
            description,
            style: const TextStyle(
              color: darkTextColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Footer Date
          Text(
            footerDate,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
