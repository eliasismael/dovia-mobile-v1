import '/domain/legal_closure_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de un profesional legal en el cierre del trato.
///
/// Las acciones dependen de si el trámite ya se calificó: mientras está en
/// "Finalizadas" lleva [Calificar] y el badge [Reportar problema]; una vez
/// calificado la tarjeta queda limpia y sólo informa quién acompañó el trato,
/// que es lo que muestra la pestaña "Calificadas".
class LegalProfessionalCardWidget extends StatelessWidget {
  const LegalProfessionalCardWidget({
    super.key,
    required this.professional,
    this.onRate,
    this.onReport,
    this.onCall,
    this.onEmail,
  });

  final LegalProfessional professional;

  /// Sin estos callbacks los controles no se dibujan: es como la tarjeta se
  /// vacía en "Calificadas".
  final VoidCallback? onRate;
  final VoidCallback? onReport;

  final VoidCallback? onCall;
  final VoidCallback? onEmail;

  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _chipBg = Color(0xFFDDE9E9);
  static const Color _border = Color(0xFFB8D4D5);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 8),
                  _avatar(),
                  const SizedBox(height: 8),
                  _contactIcons(),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _chipBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      professional.role.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.publicSans(
                        fontSize: 11,
                        color: _text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    professional.fullName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                  if (onRate != null) ...[
                    const SizedBox(height: 6),
                    _contactLabels(),
                  ],
                ],
              ),
              if (onReport != null)
                Positioned(top: 0, right: 0, child: _reportBadge()),
            ],
          ),
        ),
        if (onRate != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: onRate,
              style: FilledButton.styleFrom(
                backgroundColor: _aqua,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Calificar',
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _avatar() {
    return ClipOval(
      child: SizedBox(
        width: 72,
        height: 72,
        child: professional.avatarUrl.isNotEmpty
            ? Image.network(
                professional.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarPlaceholder(),
              )
            : _avatarPlaceholder(),
      ),
    );
  }

  Widget _avatarPlaceholder() => Container(
        color: _chipBg,
        alignment: Alignment.center,
        child: const Icon(Icons.person_rounded, color: _aqua, size: 36),
      );

  /// Contacto rápido: WhatsApp/teléfono y correo. Sin dato del backend el
  /// ícono no se dibuja, en vez de ofrecer un enlace que no lleva a ningún
  /// lado.
  Widget _contactIcons() {
    final icons = <Widget>[
      if (professional.hasPhone)
        _circleIcon(Icons.phone_rounded, onCall, 'Llamar'),
      if (professional.hasEmail)
        _circleIcon(Icons.mail_outline_rounded, onEmail, 'Enviar correo'),
    ];
    if (icons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < icons.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          icons[i],
        ],
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback? onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: _chipBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _aqua, size: 16),
        ),
      ),
    );
  }

  Widget _contactLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Teléfono',
            style: GoogleFonts.publicSans(fontSize: 11, color: _text)),
        Text('Mail', style: GoogleFonts.publicSans(fontSize: 11, color: _text)),
      ],
    );
  }

  Widget _reportBadge() {
    return InkWell(
      onTap: onReport,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: _aqua,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'Reportar\nproblema',
              style: GoogleFonts.publicSans(
                fontSize: 9,
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
