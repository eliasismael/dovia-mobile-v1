import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal "Reportar problemas" de un profesional legal.
///
/// Devuelve el texto por `Navigator.pop`, o `null` si se cierra sin enviar. La
/// descripción es obligatoria —el backend la exige y es lo único que lee
/// soporte—, así que [Enviar] espera a que haya algo escrito.
Future<String?> showReportarProblemaModal(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const ReportarProblemaModalWidget(),
  );
}

class ReportarProblemaModalWidget extends StatefulWidget {
  const ReportarProblemaModalWidget({super.key});

  @override
  State<ReportarProblemaModalWidget> createState() =>
      _ReportarProblemaModalWidgetState();
}

class _ReportarProblemaModalWidgetState
    extends State<ReportarProblemaModalWidget> {
  final TextEditingController _messageCtrl = TextEditingController();

  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);

  @override
  void dispose() {
    _messageCtrl.dispose();
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
                'Reportar problemas',
                style: GoogleFonts.publicSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Describe el problema',
              style: GoogleFonts.publicSans(fontSize: 13, color: _text),
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
                controller: _messageCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
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
                onPressed: _messageCtrl.text.trim().isEmpty
                    ? null
                    : () =>
                        Navigator.of(context).pop(_messageCtrl.text.trim()),
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
}
