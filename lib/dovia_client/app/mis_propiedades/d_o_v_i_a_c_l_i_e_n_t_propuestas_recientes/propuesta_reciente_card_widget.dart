import '/core/network_image_size.dart';
import '/domain/owner_proposal_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de una propuesta recibida sobre una propiedad del usuario.
///
/// Se usa tanto en el carrusel "Propuestas Recientes" del panel de Mis
/// Propiedades como en los tres carriles de la pantalla del mismo nombre.
///
/// A diferencia de la tarjeta del comprador, aquí NO existe "Cancelar oferta":
/// el propietario sólo dispone de la acción de apertura ([Ver oferta],
/// [Ver contraoferta], [Ver proceso legal] o [Calificar]), y resuelve el
/// trilema dentro del detalle.
class PropuestaRecienteCardWidget extends StatelessWidget {
  const PropuestaRecienteCardWidget({
    super.key,
    required this.proposal,
    required this.onOpen,
    this.hasUnreadUpdate = false,
    this.width = 260.0,
  });

  final OwnerProposal proposal;
  final VoidCallback onOpen;

  /// Enciende el punto rojo: oferta nueva, contraoferta sin leer o avance del
  /// proceso legal que el propietario todavía no abrió.
  final bool hasUnreadUpdate;

  final double width;

  static const Color _aqua = Color(0xFF007376);
  static const Color _aquaSoft = Color(0xFFCCE3E4);
  static const Color _text = Color(0xFF00444B);
  static const Color _badgeRed = Color(0xFFDA0010);
  static const Color _overdueRed = Color(0xFFE44444);
  static const Color _warningAmber = Color(0xFFF57E00);
  static const Color _warningAmberBg = Color(0xFFFFDBBC);

  /// Etiqueta de la única acción disponible en la tarjeta.
  String get _actionLabel {
    switch (proposal.lane) {
      case OwnerProposalLane.aceptada:
        return proposal.isLegalProcessFinished
            ? 'Calificar'
            : 'Ver proceso legal';
      case OwnerProposalLane.contraoferta:
        return proposal.awaitsOwnerResponse ? 'Ver contraoferta' : 'Ver oferta';
      case OwnerProposalLane.ofertas:
        return 'Ver oferta';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = proposal.lane == OwnerProposalLane.aceptada;

    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(11.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11.0),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _image(),
                const SizedBox(height: 10.0),
                Text(
                  proposal.propertyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.publicSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  _subtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.publicSans(
                    fontSize: 12.0,
                    color: _aqua,
                  ),
                ),
                if (isAccepted) ...[
                  const SizedBox(height: 10.0),
                  _progressBar(),
                ] else ...[
                  const SizedBox(height: 8.0),
                  _slaChip(),
                ],
                const SizedBox(height: 10.0),
                _actionButton(),
              ],
            ),
          ),
          if (hasUnreadUpdate)
            Positioned(
              top: -4.0,
              right: -4.0,
              child: Container(
                width: 18.0,
                height: 18.0,
                decoration: const BoxDecoration(
                  color: _badgeRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11.0),
      child: SizedBox(
        height: 120.0,
        width: double.infinity,
        child: proposal.propertyImageUrl.isNotEmpty
            ? Image.network(
                proposal.propertyImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
                cacheWidth: networkImageCacheWidth(),
              )
            : _placeholderImage(),
      ),
    );
  }

  Widget _placeholderImage() => Image.asset(
        'assets/images/casa_card_sobreMiVisita.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEFEFEF)),
      );

  String _subtitle() {
    final type = proposal.offerType == 'RENT' ? 'Renta' : 'Compra';
    final amount = proposal.proposedAmount;
    if (amount == null) return type;
    final formatted = amount.truncateToDouble() == amount
        ? amount
            .toInt()
            .toString()
            .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')
        : amount.toStringAsFixed(2);
    return '$type · ${proposal.currency} $formatted';
  }

  /// Barra segmentada de 5 pasos del proceso legal (mismo comportamiento que
  /// ve el comprador en su carril de "Oferta aceptada").
  Widget _progressBar() {
    const totalSteps = 4;
    final filled = proposal.legalProgressSteps.clamp(0, totalSteps);
    return ClipRRect(
      borderRadius: BorderRadius.circular(100.0),
      child: SizedBox(
        height: 13.0,
        child: Row(
          children: List.generate(totalSteps, (index) {
            return Expanded(
              child: Container(
                height: 13.0,
                decoration: BoxDecoration(
                  color: index < filled ? _aqua : const Color(0x80007376),
                  border: index == 0
                      ? null
                      : const Border(
                          left: BorderSide(color: Color(0xFF3B8F92), width: 1)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Plazo de respuesta del propietario (SLA de 7 días), o el estado final de
  /// la negociación cuando ya no admite respuesta.
  Widget _slaChip() {
    if (proposal.isTerminal) return _chip(_terminalLabel(), _overdueRed);

    if (!proposal.awaitsOwnerResponse) return const SizedBox(height: 21.0);

    final daysLeft = proposal.daysLeftToRespond;
    if (daysLeft == null) return const SizedBox(height: 21.0);

    if (proposal.isResponseOverdue) return _chip('Plazo vencido', _overdueRed);

    final label = daysLeft <= 0
        ? 'Último día para responder'
        : 'Te ${daysLeft == 1 ? "queda" : "quedan"} $daysLeft ${daysLeft == 1 ? "día" : "días"}';
    return _chip(label, _warningAmber);
  }

  String _terminalLabel() {
    if (proposal.offerStatus.contains('EXPIRED')) return 'Expirada';
    if (proposal.offerStatus.contains('CANCEL')) return 'Cancelada';
    if (proposal.offerStatus.contains('WITHDRAWN')) return 'Retirada';
    return 'Rechazada';
  }

  Widget _chip(String label, Color color) {
    final isAmber = color == _warningAmber;
    return Container(
      height: 21.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isAmber ? _warningAmberBg : const Color(0x1FE44444),
        borderRadius: BorderRadius.circular(99.0),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.publicSans(fontSize: 12.0, color: color),
      ),
    );
  }

  Widget _actionButton() {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(99.0),
      child: Container(
        width: double.infinity,
        height: 30.0,
        decoration: BoxDecoration(
          color: _aquaSoft,
          borderRadius: BorderRadius.circular(99.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.remove_red_eye_outlined, color: _aqua, size: 18.0),
            const SizedBox(width: 5.0),
            Flexible(
              child: Text(
                _actionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.publicSans(fontSize: 14.0, color: _aqua),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
