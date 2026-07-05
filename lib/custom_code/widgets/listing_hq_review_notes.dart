// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:url_launcher/url_launcher.dart';

class ListingHqReviewNotes extends StatefulWidget {
  const ListingHqReviewNotes({
    super.key,
    this.width,
    this.height,
    this.propertyName,
    this.operativeNote,
    this.operativeName,
    this.operativeLastName,
    this.ownerName,
    this.ownerLastName,
    this.onChecklistPressed,
    this.onReassignPressed,
  });

  final double? width;
  final double? height;
  final String? propertyName;
  final String? operativeNote;
  final String? operativeName;
  final String? operativeLastName;
  final String? ownerName;
  final String? ownerLastName;
  final Future Function()? onChecklistPressed;
  final Future Function()? onReassignPressed;

  @override
  State<ListingHqReviewNotes> createState() => _ListingHqReviewNotesState();
}

class _ListingHqReviewNotesState extends State<ListingHqReviewNotes> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color borderColor = Color(0xFFE9EFF2);
  static const Color alertBg = Color(0x3370ACAD);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: const Color(0xFFFBFBFB), // Matches Figma background
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operative Note Section
          const Text(
            'Datos del Operative Listing',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 20,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nota de Operative:\n${widget.operativeNote ?? 'Sin notas adicionales.'}',
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 20,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Operative Contact Card
          _buildContactCard(
            name: widget.operativeName ?? 'Operativo',
            lastName: widget.operativeLastName ?? 'Asignado',
            role: 'Operative listing',
            icon: Icons.chat_bubble_outline,
            onTapIcon: () {
              // Open internal communication
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abriendo chat interno...')),
              );
            },
          ),
          const SizedBox(height: 32),

          // Owner Data Section
          const Text(
            'Datos del propietario:',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 20,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Owner Contact Card
          _buildContactCard(
            name: widget.ownerName ?? 'Propietario',
            lastName: widget.ownerLastName ?? 'Asignado',
            role: 'Propietario',
            icon: Icons.chat_bubble_outline,
            onTapIcon: () {
              // Open WhatsApp / external communication
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Abriendo comunicación con propietario...')),
              );
            },
          ),

          const Spacer(), // Push bottom buttons to the bottom

          // Resolution Actions Text
          const Text(
            'Finalizar proceso de checklist o solicitar una nueva visita, comunicarse con el propietario y coordinar',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 20,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),

          // Buttons Row
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _buildChecklistButton()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildReassignButton()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildChecklistButton(),
                  const SizedBox(height: 12),
                  _buildReassignButton(),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildChecklistButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: () async {
          if (widget.onChecklistPressed != null) {
            await widget.onChecklistPressed!();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Checklist',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildReassignButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: () async {
          if (widget.onReassignPressed != null) {
            await widget.onReassignPressed!();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Re asignar Operative Listing',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String name,
    required String lastName,
    required String role,
    required IconData icon,
    required VoidCallback onTapIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.5),
        border: Border.all(color: primaryColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Role Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x3370ACAD), // rgba(112, 172, 173, 0.2)
              borderRadius: BorderRadius.circular(65),
            ),
            child: Text(
              role,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Name and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 32), // Balance for icon
              Expanded(
                child: Text(
                  '$name $lastName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTapIcon,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline, // Equivalent to the multi-bubble
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
