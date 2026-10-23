import '/core/external_links.dart';
import '/core/result.dart';
import '/domain/legal_closure_models.dart';
import '/repositories/offers_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'calificar_agente_modal_widget.dart';
import 'documentos_legales_widget.dart';
import 'reportar_problema_modal_widget.dart';
import 'legal_professional_card_widget.dart';
import '/shared_components/dovia_spinner.dart';

/// Pie del proceso legal cerrado: quiénes acompañaron el trato y el expediente
/// que dejó.
///
/// Se monta debajo del stepper "Estado de tu proceso" cuando el trámite llegó
/// a `completed`. Las acciones dependen de si el cliente ya calificó: mientras
/// falte, cada tarjeta lleva [Calificar] y [Reportar problema]; calificado el
/// rol, esa tarjeta queda limpia y la pantalla es sólo archivo — la bóveda de
/// documentos, en cambio, está siempre.
class CierreLegalSectionWidget extends StatefulWidget {
  const CierreLegalSectionWidget({
    super.key,
    required this.offerId,
    required this.legalProcessId,
    this.ratedRoles = const [],
  });

  final String offerId;
  final String legalProcessId;

  /// Roles que el cliente ya calificó, en el vocabulario de `targetRole`.
  /// Sus tarjetas nacen sin acciones: es lo que distingue a "Calificadas".
  final List<String> ratedRoles;

  @override
  State<CierreLegalSectionWidget> createState() =>
      _CierreLegalSectionWidgetState();
}

class _CierreLegalSectionWidgetState extends State<CierreLegalSectionWidget> {
  static const Color _aqua = Color(0xFF007376);
  static const Color _text = Color(0xFF00444B);
  static const Color _errorRed = Color(0xFFE44444);

  LegalProcessClosure _closure = const LegalProcessClosure.empty();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  /// Roles ya calificados: los que entran calificados desde el listado y los
  /// que el cliente califica sin salir de la pantalla.
  final Set<LegalProfessionalRole> _ratedRoles = {};

  @override
  void initState() {
    super.initState();
    _ratedRoles.addAll(LegalProfessionalRole.values
        .where((role) => widget.ratedRoles.contains(role.apiValue)));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final result = await context
        .read<OffersRepository>()
        .loadLegalClosure(widget.legalProcessId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      switch (result) {
        case Success(:final data):
          _closure = data;
          _errorMessage = null;
          break;
        case Failure(:final message):
          _errorMessage = message;
          break;
      }
    });
  }

  Future<void> _rate(LegalProfessional professional) async {
    final rating = await showCalificarAgenteModal(context, professional);
    if (rating == null || !mounted) return;

    setState(() => _isSubmitting = true);
    final result = await context.read<OffersRepository>().rateLegalProfessional(
          offerId: widget.offerId,
          targetRole: professional.role.apiValue,
          stars: rating.stars,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        setState(() => _ratedRoles.add(professional.role));
        _toast('¡Gracias por tu calificación!');
        break;
      case Failure(:final message):
        _toast(message, isError: true);
        break;
    }
  }

  Future<void> _report(LegalProfessional professional) async {
    final message = await showReportarProblemaModal(context);
    if (message == null || !mounted) return;

    setState(() => _isSubmitting = true);
    final result =
        await context.read<OffersRepository>().reportLegalProfessional(
              offerId: widget.offerId,
              targetRole: professional.role.apiValue,
              message: message,
            );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        _toast('Enviamos tu reporte al equipo de Dovia.');
        break;
      case Failure(:final message):
        _toast(message, isError: true);
        break;
    }
  }

  Future<void> _openDocument(LegalDocument document) async {
    final uri = Uri.tryParse(document.url);
    if (uri == null || !await openExternalUri(uri)) {
      if (mounted) _toast('No pudimos abrir el documento.', isError: true);
    }
  }

  Future<void> _launch(String scheme, String value) async {
    if (!await openExternalUri(Uri(scheme: scheme, path: value)) && mounted) {
      _toast('No pudimos abrir la aplicación.', isError: true);
    }
  }

  void _toast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? _errorRed : const Color(0xFF555555),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: DoviaSpinner()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.publicSans(fontSize: 14, color: _text),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _load();
              },
              child: Text(
                'Reintentar',
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w600, color: _aqua),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_closure.professionals.isNotEmpty) ...[
          _professionals(),
          const SizedBox(height: 24),
        ],
        DocumentosLegalesWidget(
          documents: _closure.documents,
          onOpen: _openDocument,
        ),
      ],
    );
  }

  Widget _professionals() {
    const spacing = 16.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 520 || _closure.professionals.length == 1
                ? 1
                : 2;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _closure.professionals.map((professional) {
            final isRated = _ratedRoles.contains(professional.role);
            return SizedBox(
              width: width,
              child: LegalProfessionalCardWidget(
                professional: professional,
                // Calificado el rol, las acciones se van de la pantalla —eso
                // es "Calificadas"—; mientras hay un envío en vuelo siguen en
                // su lugar, apagadas.
                onRate: isRated ? null : () => _rate(professional),
                onReport: isRated ? null : () => _report(professional),
                enabled: !_isSubmitting,
                onCall: professional.hasPhone
                    ? () => _launch('tel', professional.phone)
                    : null,
                onEmail: professional.hasEmail
                    ? () => _launch('mailto', professional.email)
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
