import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/legal_hq/legal_hq_process_data.dart';
import '/shared_components/dovia_spinner.dart';

/// Firma del acuerdo: dónde y cuándo, tal como la agendó el Legal Associate.
///
/// La comparten el comprador ("Tu propuesta") y el propietario ("Acuerdo"),
/// que ven la misma reunión. La oferta sólo trae el id del proceso legal, así
/// que la reunión se lee del detalle del proceso (el backend deja consultarlo
/// al comprador y al propietario).
class LegalMeetingCardWidget extends StatefulWidget {
  const LegalMeetingCardWidget({super.key, required this.processId});

  /// Id del proceso legal. Null mientras la oferta todavía no cargó.
  final String? processId;

  @override
  State<LegalMeetingCardWidget> createState() => _LegalMeetingCardWidgetState();
}

class _LegalMeetingCardWidgetState extends State<LegalMeetingCardWidget> {
  static const Color _primary = Color(0xFF00444B);
  static const Color _aqua = Color(0xFF007376);

  LegalHqAppointment? _appointment;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LegalMeetingCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.processId != widget.processId) {
      setState(() => _loaded = false);
      _load();
    }
  }

  Future<void> _load() async {
    final id = widget.processId ?? '';
    // Sin id todavía se sigue esperando a la oferta.
    if (id.isEmpty) return;
    final detail = await LegalHqProcessApi.fetchDetail(id);
    if (!mounted || widget.processId != id) return;
    setState(() {
      _appointment = detail?.activeAppointment ??
          (detail != null && detail.appointments.isNotEmpty
              ? detail.appointments.last
              : null);
      _loaded = true;
    });
  }

  static const _weekdays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  String _format(DateTime d) {
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${_weekdays[d.weekday - 1]} ${d.day} de ${_months[d.month - 1]}'
        ' de ${d.year} · $hour:$minute hs';
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0x2670ACAD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: _aqua),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF8A8A8A))),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _primary)),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final a = _appointment;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Firma del acuerdo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          if (!_loaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: DoviaSpinner(small: true),
              ),
            )
          else if (a == null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'El Legal Associate todavía no agendó la firma. Te avisaremos '
                'cuando tenga fecha, hora y lugar.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6A6A6A)),
              ),
            )
          else ...[
            if (a.scheduledAt != null)
              _row(Icons.event_outlined, 'Fecha y hora',
                  _format(a.scheduledAt!)),
            if (a.address.isNotEmpty)
              _row(Icons.location_on_outlined, 'Dirección exacta', a.address),
            if (a.arrivalInstructions.isNotEmpty)
              _row(Icons.directions_outlined, 'Instrucciones para llegar',
                  a.arrivalInstructions),
            if (a.status == 'CANCELLED')
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Esta reunión fue cancelada.',
                    style: TextStyle(fontSize: 13, color: Colors.red)),
              ),
            if (a.address.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () => launchUrl(
                    Uri.https('www.google.com', '/maps/search/',
                        {'api': '1', 'query': a.address}),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.map_outlined, size: 18, color: _aqua),
                  label: const Text('Abrir ubicación',
                      style:
                          TextStyle(color: _aqua, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _aqua),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
