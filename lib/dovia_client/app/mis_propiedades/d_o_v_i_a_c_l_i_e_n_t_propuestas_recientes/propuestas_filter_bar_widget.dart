import '/domain/owner_proposal_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barra de pestañas que filtra dentro de un carril de propuestas.
///
/// Es el control segmentado del diseño: pista gris con las opciones repartidas
/// en partes iguales y la seleccionada resaltada en blanco.
class PropuestasFilterBarWidget extends StatelessWidget {
  const PropuestasFilterBarWidget({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<OwnerProposalFilter> filters;
  final OwnerProposalFilter selected;
  final ValueChanged<OwnerProposalFilter> onSelected;

  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _trackBg = Color(0xFFF3F4F6);
  static const Color _idleText = Color(0xFF4A5565);
  static const Color _selectedText = Color(0xFF00444B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Container(
        height: 44.0,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: _trackBg,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          children: [
            for (var i = 0; i < filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 8.0),
              Expanded(child: _segment(filters[i])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _segment(OwnerProposalFilter filter) {
    final isSelected = filter == selected;
    return InkWell(
      onTap: () => onSelected(filter),
      borderRadius: BorderRadius.circular(100.0),
      child: Container(
        height: 36.0,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Text(
          filter.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.publicSans(
            fontSize: 14.0,
            height: 20 / 14,
            letterSpacing: -0.15,
            fontWeight: FontWeight.w500,
            color: isSelected ? _selectedText : _idleText,
          ),
        ),
      ),
    );
  }
}
