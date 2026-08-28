import '/domain/legal_closure_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bóveda de documentos del trámite.
///
/// Cada fila dice si el archivo ya está cargado (check + descarga) o si Legal
/// HQ todavía lo debe subir (reloj, sin descarga): el cliente ve el expediente
/// completo aunque falten piezas, que es lo que da seguimiento al cierre.
class DocumentosLegalesWidget extends StatelessWidget {
  const DocumentosLegalesWidget({
    super.key,
    required this.documents,
    required this.onOpen,
  });

  final List<LegalDocument> documents;

  /// Abre o descarga el documento. Sólo se llama con documentos listos.
  final ValueChanged<LegalDocument> onOpen;

  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _iconBg = Color(0xFFCCE3E4);
  static const Color _rowBg = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();

    const spacing = 16.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dos columnas como el diseño; una sola cuando la pantalla es angosta.
        final columns = constraints.maxWidth < 520 ? 1 : 2;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: documents
              .map((document) => SizedBox(
                    width: width,
                    child: _row(document),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _row(LegalDocument document) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _rowBg,
        borderRadius: BorderRadius.circular(10.7),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              document.label,
              style: GoogleFonts.publicSans(fontSize: 14, color: _text),
            ),
          ),
          const SizedBox(width: 8),
          if (document.isReady) ...[
            const Icon(Icons.check_circle, color: _aqua, size: 24),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => onOpen(document),
              borderRadius: BorderRadius.circular(99),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: _iconBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download_outlined,
                    color: _aqua, size: 18),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: _iconBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.schedule_rounded, color: _aqua, size: 18),
            ),
        ],
      ),
    );
  }
}
