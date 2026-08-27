import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal de retiro de una oferta enviada.
///
/// Es la misma pieza de diseño que el modal de pausar una propiedad, con los
/// textos del comprador: aquí no se pausa una publicación, se retira una
/// oferta. El motivo es obligatorio — lo lee el dueño —, así que
/// [Retirar Oferta] permanece deshabilitado hasta que se escriba algo.
///
/// Devuelve el motivo por `Navigator.pop`, o `null` si se cierra sin retirar.
Future<String?> showCancelarOfertaModal(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const CancelarOfertaModalWidget(),
  );
}

class CancelarOfertaModalWidget extends StatefulWidget {
  const CancelarOfertaModalWidget({super.key});

  @override
  State<CancelarOfertaModalWidget> createState() =>
      _CancelarOfertaModalWidgetState();
}

class _CancelarOfertaModalWidgetState extends State<CancelarOfertaModalWidget> {
  final TextEditingController _reasonCtrl = TextEditingController();

  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _destructive = Color(0xFFE85D75);

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  bool get _canConfirm => _reasonCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '¿Quieres cancelar la oferta de esta propiedad?',
                    style: GoogleFonts.publicSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _text,
                      height: 1.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Opacity(
                    opacity: 0.7,
                    child: Icon(Icons.close,
                        size: 16, color: Colors.black.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _reasonCtrl,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                style:
                    GoogleFonts.publicSans(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Describe por qué quieres retirar tu oferta...',
                  hintStyle: GoogleFonts.publicSans(
                    fontSize: 14,
                    color: const Color(0xFF717182),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _aqua),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.publicSans(
                            fontSize: 16, color: _aqua),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: FilledButton(
                      onPressed: _canConfirm
                          ? () => Navigator.of(context)
                              .pop(_reasonCtrl.text.trim())
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _destructive,
                        disabledBackgroundColor:
                            _destructive.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        'Retirar Oferta',
                        style: GoogleFonts.publicSans(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
