import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/api_requests/api_config.dart';
import '/core/result.dart';
import '/repositories/notifications_repository.dart';

/// La prueba de notificaciones sólo se ofrece en dev y staging.
bool get notificationTestEnabled => kApiEnvLabel.isNotEmpty;

/// Ejemplos de ruta para `POST /notifications/test`. Los que dependen de a
/// quién iba dirigida llevan el código como `type`, igual que la real; los
/// IDs (`VISIT_ID`, `OFFER_ID`, `PROPERTY_ID`) se reemplazan por reales.
const _presets = <(String, String)>[
  ('Bandeja', '/notifications'),
  ('Dovia Home (cliente)', '/dovia-home/service-requests/SERVICE_REQUEST_ID'),
  (
    'Oferta aceptada (comprador)',
    '/offers/OFFER_ID?type=OFFER_ACCEPTED_CLIENT'
  ),
  ('Oferta recibida (dueño)', '/offers/OFFER_ID?type=OFFER_RECEIVED_OWNER'),
  (
    'Visita confirmada (cliente)',
    '/visits/VISIT_ID?type=VISIT_CONFIRMED_CLIENT&propertyId=PROPERTY_ID'
  ),
  (
    'Solicitud de visita (dueño)',
    '/visits/VISIT_ID?type=VISIT_REQUESTED_OWNER&propertyId=PROPERTY_ID'
  ),
];

/// Abre el formulario para mandarse una notificación de prueba.
Future<void> showNotificationTestSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NotificationTestSheet(),
    );

class _NotificationTestSheet extends StatefulWidget {
  const _NotificationTestSheet();

  @override
  State<_NotificationTestSheet> createState() => _NotificationTestSheetState();
}

class _NotificationTestSheetState extends State<_NotificationTestSheet> {
  final _title = TextEditingController(text: 'Notificación de prueba');
  final _body =
      TextEditingController(text: 'Esta es una notificación de prueba.');
  final _path = TextEditingController(text: _presets.first.$2);
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _path.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    final path = _path.text.trim();
    if (title.isEmpty || body.isEmpty) {
      setState(() => _error = 'Completá el título y el texto.');
      return;
    }
    if (!path.startsWith('/') || path.startsWith('//')) {
      setState(() => _error = 'La ruta tiene que empezar con una sola /.');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });
    final repo = context.read<NotificationsRepository>();
    final result = await repo.sendTestNotification(
      title: title,
      body: body,
      actionPath: path,
    );
    if (!mounted) return;
    switch (result) {
      case Success():
        await repo.loadInbox();
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(const SnackBar(
          content: Text(
              'Enviada. Ya está en la bandeja; tocala para ver a dónde lleva.'),
        ));
      case Failure(:final message):
        setState(() {
          _sending = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Probar una notificación ($kApiEnvLabel)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'Te llega a vos. Reemplazá los IDs de ejemplo por reales.',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, path) in _presets)
                  ActionChip(
                    label: Text(label),
                    onPressed: () => setState(() => _path.text = path),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _body,
              decoration: const InputDecoration(labelText: 'Texto'),
            ),
            TextField(
              controller: _path,
              decoration: const InputDecoration(labelText: 'Ruta (actionPath)'),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Color(0xFFDC2626))),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _sending ? null : _send,
              child: Text(_sending ? 'Enviando...' : 'Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
