import '/domain/client_offer_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de una oferta que el usuario envió sobre una propiedad ajena.
///
/// Se usa en los tres carriles de "Mis Ofertas" y en sus listados completos.
/// Las acciones dependen del carril donde se renderiza, no sólo del estado de
/// la oferta, porque el carril "Ofertas realizadas" es el pipeline general y
/// lleva ofertas de cualquier etapa:
/// - realizadas → [Ver tu oferta] + [Cancelar oferta]
/// - contraoferta → [Ver contraoferta]
/// - aceptada → barra de progreso + [Ver proceso legal] / [Calificar]
class MiOfertaCardWidget extends StatelessWidget {
  const MiOfertaCardWidget({
    super.key,
    required this.offer,
    required this.lane,
    required this.onOpen,
    this.onCancel,
    this.hasUnreadUpdate = false,
    this.width = 260.0,
  });

  final ClientOffer offer;

  /// Carril en el que se está mostrando la tarjeta.
  final ClientOfferLane lane;

  final VoidCallback onOpen;

  /// Abre el modal de retiro. Sin este callback no se dibuja el botón.
  final VoidCallback? onCancel;

  /// Enciende el punto rojo: el dueño contraofertó y el usuario no lo abrió.
  final bool hasUnreadUpdate;

  final double width;

  static const Color _aqua = Color(0xFF007376);
  static const Color _aquaSoft = Color(0xFFCCE3E4);
  static const Color _aquaDim = Color(0x80007376);
  static const Color _aquaBorder = Color(0xFF3B8F92);
  static const Color _text = Color(0xFF00444B);
  static const Color _badgeRed = Color(0xFFDA0010);
  static const Color _terminalRed = Color(0xFFE44444);

  /// La barra de progreso acompaña a todo lo que ya está en manos de Legal HQ,
  /// también cuando la tarjeta se ve desde "Ofertas realizadas".
  bool get _showsProgress => offer.lane == ClientOfferLane.aceptada;

  /// El botón de retirar sólo aparece en el pipeline general, y sólo mientras
  /// la oferta siga en juego: una vez aceptada o cerrada no hay nada que
  /// retirar, y el endpoint lo rechazaría.
  bool get _showsCancel =>
      lane == ClientOfferLane.realizadas &&
      offer.isCancellable &&
      onCancel != null;

  String get _actionLabel {
    switch (lane) {
      case ClientOfferLane.contraoferta:
        return 'Ver contraoferta';
      case ClientOfferLane.aceptada:
        return offer.isLegalProcessFinished ? 'Calificar' : 'Ver proceso legal';
      case ClientOfferLane.realizadas:
        return 'Ver tu oferta';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  offer.propertyName,
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
                  style: GoogleFonts.publicSans(fontSize: 12.0, color: _aqua),
                ),
                if (_showsProgress) ...[
                  const SizedBox(height: 10.0),
                  _progressBar(),
                ] else if (offer.isTerminal) ...[
                  const SizedBox(height: 8.0),
                  _terminalChip(),
                ],
                const SizedBox(height: 10.0),
                _openButton(),
                if (_showsCancel) ...[
                  const SizedBox(height: 10.0),
                  _cancelButton(),
                ],
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
        child: offer.propertyImageUrl.isNotEmpty
            ? Image.network(
                offer.propertyImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
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
    final type = offer.offerType == 'RENT' ? 'Renta' : 'Compra';
    final amount = offer.proposedAmount;
    if (amount == null) return type;
    final formatted = amount.truncateToDouble() == amount
        ? amount
            .toInt()
            .toString()
            .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')
        : amount.toStringAsFixed(2);
    return '$type · ${offer.currency} $formatted';
  }

  /// Barra segmentada de 5 pasos del proceso legal, la misma trazabilidad que
  /// ve el propietario en su carril de ofertas aceptadas.
  Widget _progressBar() {
    const totalSteps = 5;
    final filled = offer.legalProgressSteps.clamp(0, totalSteps);
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
                  color: index < filled ? _aqua : _aquaDim,
                  border: index == 0
                      ? null
                      : const Border(
                          left: BorderSide(color: _aquaBorder, width: 1)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _terminalChip() {
    return Container(
      height: 21.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x1FE44444),
        borderRadius: BorderRadius.circular(99.0),
      ),
      child: Text(
        _terminalLabel(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.publicSans(fontSize: 12.0, color: _terminalRed),
      ),
    );
  }

  String _terminalLabel() {
    if (offer.offerStatus.contains('EXPIRED')) return 'Expirada';
    if (offer.offerStatus.contains('WITHDRAWN')) return 'Retirada';
    if (offer.offerStatus.contains('CANCEL')) return 'Cancelada';
    if (offer.offerStatus == 'REJECTED_BY_CLIENT') return 'Retirada';
    return 'Rechazada';
  }

  Widget _openButton() {
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

  Widget _cancelButton() {
    return InkWell(
      onTap: onCancel,
      borderRadius: BorderRadius.circular(25.0),
      child: Container(
        width: double.infinity,
        height: 33.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: _aqua),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Text(
          'Cancelar oferta',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.publicSans(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: _aqua,
          ),
        ),
      ),
    );
  }
}
