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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operative Note Section
          const Text(
            'Información para HQ',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              widget.operativeNote ?? 'Sin notas adicionales.',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: textColor,
                height: 1.5,
              ),
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
                const SnackBar(content: Text('Abriendo comunicación con propietario...')),
              );
            },
          ),
          
          const Spacer(), // Push bottom buttons to the bottom

          // Resolution Actions
          const Text(
            'Finalizar proceso de checklist o solicitar una nueva visita...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Checklist Button
          SizedBox(
            width: double.infinity,
            height: 50,
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
          ),
          const SizedBox(height: 12),
          
          // Reassign Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                if (widget.onReassignPressed != null) {
                  await widget.onReassignPressed!();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Re asignar Operative Listing',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE9EFF2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${name.isNotEmpty ? name[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name $lastName',
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTapIcon,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE9EFF2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
