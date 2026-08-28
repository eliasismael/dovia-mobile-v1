import '/domain/legal_closure_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Resultado del modal: las estrellas elegidas y el comentario opcional.
class CalificacionAgente {
  final double stars;
  final String comment;

  const CalificacionAgente({required this.stars, required this.comment});
}

/// Modal "Califica" de un profesional legal.
///
/// Devuelve la calificación por `Navigator.pop`, o `null` si se cierra sin
/// enviar. [Enviar] queda deshabilitado hasta elegir al menos una estrella:
/// el backend rechaza cualquier valor menor a 1.
Future<CalificacionAgente?> showCalificarAgenteModal(
  BuildContext context,
  LegalProfessional professional,
) {
  return showDialog<CalificacionAgente>(
    context: context,
    builder: (_) => CalificarAgenteModalWidget(professional: professional),
  );
}

class CalificarAgenteModalWidget extends StatefulWidget {
  const CalificarAgenteModalWidget({super.key, required this.professional});

  final LegalProfessional professional;

  @override
  State<CalificarAgenteModalWidget> createState() =>
      _CalificarAgenteModalWidgetState();
}

class _CalificarAgenteModalWidgetState
    extends State<CalificarAgenteModalWidget> {
  final TextEditingController _commentCtrl = TextEditingController();
  double _stars = 0;

  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _chipBg = Color(0xFFDDE9E9);
  static const Color _idleStar = Color(0xFFD9D9D9);

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      elevation: 15,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Califica',
                style: GoogleFonts.publicSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _chipBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.professional.role.label,
                style: GoogleFonts.publicSans(fontSize: 12, color: _text),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.professional.fullName,
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
            const SizedBox(height: 16),
            _stars5(),
            const SizedBox(height: 16),
            Text(
              'Si deseas, puedes dejar un comentario',
              style: GoogleFonts.publicSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _text,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 84,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDFDFDF)),
              ),
              child: TextField(
                controller: _commentCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Escribe aquí...',
                  hintStyle: GoogleFonts.publicSans(
                    fontSize: 13,
                    color: const Color(0xFF888888),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: GoogleFonts.publicSans(fontSize: 13, color: _text),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _aqua,
                  disabledBackgroundColor: _aqua.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _stars < 1
                    ? null
                    : () => Navigator.of(context).pop(CalificacionAgente(
                          stars: _stars,
                          comment: _commentCtrl.text.trim(),
                        )),
                child: Text(
                  'Enviar',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stars5() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          onPressed: () => setState(() => _stars = value.toDouble()),
          iconSize: 34,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
          tooltip: '$value',
          icon: Icon(
            value <= _stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: value <= _stars ? _aqua : _idleStar,
          ),
        );
      }),
    );
  }
}
