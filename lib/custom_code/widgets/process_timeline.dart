// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_fonts/google_fonts.dart';

class ProcessTimeline extends StatelessWidget {
  const ProcessTimeline({super.key});

  static const Color colorPrimary = Color(0xFF00444B);
  static const Color colorPrimaryLight = Color(0x3300444B);
  static const Color colorGrey = Color(0xFFA8AABC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Estado de tu proceso',
            style: GoogleFonts.publicSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(
                stepIndex: 1,
                title: "Negociación",
                status: "En Proceso",
                isActive: true,
                isLast: false,
              ),
              _buildStep(
                stepIndex: 2,
                title: "Estructuración\nde acuerdo",
                status: "Pendiente",
                isActive: false,
                isLast: false,
              ),
              _buildStep(
                stepIndex: 3,
                title: "Firma de\ncontrato",
                status: "Pendiente",
                isActive: false,
                isLast: false,
              ),
              _buildStep(
                stepIndex: 4,
                title: "Finalizar\nproceso",
                status: "Pendiente",
                isActive: false,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int stepIndex,
    required String title,
    required String status,
    required bool isActive,
    required bool isLast,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? colorPrimary : colorGrey,
                    width: isActive ? 1.5 : 2.0,
                  ),
                ),
                child: isActive
                    ? Center(
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5F9EA0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 2,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorPrimary.withOpacity(0.5)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: isActive
                        ? FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.3,
                            child: Container(color: colorPrimary),
                          )
                        : null,
                  ),
                )
              else
                const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'PASO $stepIndex',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorGrey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: Text(
              title,
              style: GoogleFonts.publicSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF002A30),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? colorPrimaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isActive ? null : Border.all(color: colorGrey),
            ),
            child: Text(
              status,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? colorPrimary : colorGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
