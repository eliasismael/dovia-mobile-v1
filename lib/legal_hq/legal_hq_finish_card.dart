import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/legal_hq/legal_hq_process_data.dart';

/// Cierre de un trámite de venta o renta aprobado, del lado de Legal HQ.
///
/// Legal HQ revisa el comprobante de pago a DOVIA y, si está bien, finaliza.
/// El backend no tiene una revisión propia para este documento (no acepta
/// decisiones de HQ con el proceso ya aprobado), así que aprobarlo ES
/// finalizar. Si está mal, se le pide al cliente que lo vuelva a subir: su
/// carga reemplaza la anterior.
class LegalHqFinishCard extends StatefulWidget {
  const LegalHqFinishCard({
    super.key,
    required this.detail,
    required this.processId,
    required this.onFinished,
  });

  final LegalHqProcessDetail detail;
  final String processId;

  /// Recarga el expediente después de finalizar.
  final VoidCallback onFinished;

  @override
  State<LegalHqFinishCard> createState() => _LegalHqFinishCardState();
}

class _LegalHqFinishCardState extends State<LegalHqFinishCard> {
  static const Color _aqua = Color(0xFF007376);
  static const Color _textDark = Color(0xFF00444B);

  bool _finishing = false;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final hasProof = detail.hasPaymentProof;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12.0,
            offset: Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Comprobante de pago a Dovia',
            style: GoogleFonts.publicSans(
              color: _textDark,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            hasProof
                ? 'El cliente cargó el comprobante. Revisalo: al aprobarlo se '
                    'finaliza el proceso y se avisa a las partes.'
                : 'Esperando que el cliente cargue el comprobante de pago. '
                    'Cuando lo haga vas a poder revisarlo y finalizar el '
                    'proceso.',
            style: GoogleFonts.publicSans(
              color: const Color(0xFF6A6A6A),
              fontSize: 13.0,
            ),
          ),
          if (hasProof) ...[
            const SizedBox(height: 14.0),
            SizedBox(
              height: 42.0,
              child: OutlinedButton.icon(
                onPressed: () => launchURL(detail.paymentProofLink),
                icon: const Icon(Icons.visibility_outlined,
                    size: 18.0, color: _aqua),
                label: Text(
                  'Ver comprobante',
                  style: GoogleFonts.publicSans(
                      color: _aqua, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _aqua),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0)),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              height: 44.0,
              child: ElevatedButton(
                onPressed: _finishing ? null : _approveAndFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _aqua,
                  disabledBackgroundColor: _aqua.withValues(alpha: 0.35),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0)),
                ),
                child: _finishing
                    ? const SizedBox(
                        width: 18.0,
                        height: 18.0,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.0, color: Colors.white),
                      )
                    : Text(
                        'Aprobar comprobante y finalizar',
                        style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approveAndFinish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('Finalizar proceso',
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w700, color: _textDark)),
        content: Text(
          'Vas a aprobar el comprobante de pago y cerrar el trámite. La '
          'propiedad quedará como vendida o rentada y se avisará al cliente, '
          'al propietario y al Legal Associate.',
          style: GoogleFonts.publicSans(fontSize: 14.0, color: _textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancelar', style: GoogleFonts.publicSans(color: _aqua)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Finalizar',
                style: GoogleFonts.publicSans(
                    color: _aqua, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _finishing = true);
    final res =
        await DOVIAAPILegalProcessContextGroup.finishLegalProcessCall.call(
      processId: widget.processId,
      authToken: currentAuthenticationToken,
    );
    if (!mounted) return;
    setState(() => _finishing = false);
    final message = getJsonField(res.jsonBody, r'$.message')?.toString();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.succeeded
          ? 'Proceso finalizado. Avisamos a las partes.'
          : (message?.isNotEmpty == true
              ? message!
              : 'No se pudo finalizar el proceso')),
    ));
    if (res.succeeded) widget.onFinished();
  }
}
