import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/backend/api_requests/api_config.dart';
import '/app_state.dart';
import '/core/result.dart';
import '/repositories/notifications_repository.dart';
import 'notification_catalog.dart';
import 'notification_catalog_entry.dart';

/// La prueba de notificaciones sólo se ofrece en dev y staging.
bool get notificationTestEnabled => kApiEnvLabel.isNotEmpty;

/// Tipos de usuario del catálogo, en el orden en que se ofrecen.
const kNotificationTestRoles = <String, String>{
  'CLIENT': 'Cliente (interesado / comprador)',
  'OWNER': 'Dueño',
  'SHOWING_AGENT': 'Showing agent',
  'OPERATIVE_LISTER': 'Operative lister',
  'LISTER_HQ': 'Lister HQ',
  'LEGAL_ASSOCIATE': 'Legal associate',
  'LEGAL_OFFICER': 'Legal officer',
  'HOME_ASSOCIATE': 'Home associate',
  'HOME_ASSOCIATE_COMPANY': 'Home associate (empresa)',
  'DOVIA_HOME_PROVIDER': 'Proveedor Dovia Home',
};

/// Notificaciones del catálogo que le llegan a [role].
List<NotificationCatalogEntry> catalogFor(String role) =>
    kNotificationCatalog.where((e) => e.role == role).toList();

String _deliveryLabel(String delivery) => switch (delivery) {
      'PUSH_ONLY' => ' · sólo push',
      'INBOX_ONLY' => ' · sólo bandeja',
      _ => '',
    };

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
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _path = TextEditingController();
  late String _role;
  NotificationCatalogEntry? _entry;

  @override
  void initState() {
    super.initState();
    // Arranca en el tipo de usuario de la sesión, si está en el catálogo.
    final current = FFAppState().UserRole;
    _selectRole(
        kNotificationTestRoles.containsKey(current) ? current : 'CLIENT');
  }

  void _selectRole(String role) {
    _role = role;
    _selectEntry(catalogFor(role).firstOrNull);
  }

  void _selectEntry(NotificationCatalogEntry? entry) {
    _entry = entry;
    if (entry == null) return;
    _title.text = entry.title;
    _body.text = entry.sampleBody;
    _path.text = entry.sampleActionPath;
    _error = null;
  }

  bool _sending = false;
  String? _error;

  /// En Android la app se cierra sola; iOS no permite cerrarla desde código.
  bool get _canCloseApp =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _path.dispose();
    super.dispose();
  }

  /// Con [closeApp] la app se cierra apenas el backend acepta el envío: el
  /// push pasa por la cola y el worker, que tardan unos segundos, así que
  /// llega con la app cerrada y aparece en la barra del sistema. Tocarlo abre
  /// la app desde cero (el camino de `getInitialMessage`).
  Future<void> _send({required bool closeApp}) async {
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
        if (closeApp && _canCloseApp) {
          await SystemNavigator.pop();
          return;
        }
        await repo.loadInbox();
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(
          content: Text(closeApp
              ? 'Enviada. Salí de la app ya para que llegue como push.'
              : 'Enviada. Ya está en la bandeja; tocala para ver a dónde lleva.'),
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
      // Teclado o, si no está abierto, la barra de navegación del sistema.
      padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 +
              MediaQuery.viewInsetsOf(context).bottom +
              MediaQuery.paddingOf(context).bottom),
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
            DropdownButtonFormField<String>(
              initialValue: _role,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Tipo de usuario'),
              items: [
                for (final MapEntry(:key, :value)
                    in kNotificationTestRoles.entries)
                  DropdownMenuItem(
                    value: key,
                    child: Text('$value (${catalogFor(key).length})'),
                  ),
              ],
              onChanged: (role) {
                if (role != null) setState(() => _selectRole(role));
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<NotificationCatalogEntry>(
              // La key fuerza a rearmarlo al cambiar de tipo de usuario.
              key: ValueKey(_role),
              initialValue: _entry,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Notificación'),
              items: [
                for (final entry in catalogFor(_role))
                  DropdownMenuItem(
                    value: entry,
                    child: Text(
                      '${entry.title}${_deliveryLabel(entry.delivery)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (entry) => setState(() => _selectEntry(entry)),
            ),
            if (_entry != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_entry!.code} · ${_entry!.recipient}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
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
              onPressed: _sending ? null : () => _send(closeApp: false),
              child: Text(_sending ? 'Enviando...' : 'Enviar (app abierta)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _sending ? null : () => _send(closeApp: true),
              child: Text(_canCloseApp
                  ? 'Enviar como push (cierra la app)'
                  : 'Enviar como push (salí de la app)'),
            ),
          ],
        ),
      ),
    );
  }
}
