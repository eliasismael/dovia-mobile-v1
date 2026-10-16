/// Una notificación del catálogo del backend (ver
/// `notification_catalog.dart`), para mandarse una de prueba igual a la real.
class NotificationCatalogEntry {
  const NotificationCatalogEntry({
    required this.id,
    required this.code,
    required this.title,
    required this.body,
    required this.recipient,
    required this.role,
    required this.delivery,
    required this.actionPath,
    required this.data,
  });

  final String id;

  /// Código del catálogo (`type`), Ej: `VISIT_CONFIRMED_CLIENT`.
  final String code;
  final String title;

  /// Texto con variables, Ej: `{{associateName}} está en camino`.
  final String body;

  /// A quién le llega, Ej: `INTERESTED_CLIENT`, `PROPERTY_OWNER`.
  final String recipient;

  /// Tipo de usuario al que le llega, Ej: `CLIENT`, `OWNER`, `SHOWING_AGENT`.
  final String role;

  /// `INBOX_AND_PUSH`, `PUSH_ONLY` o `INBOX_ONLY`.
  final String delivery;

  /// Ruta con variables, Ej: `/visits/{{visitId}}`.
  final String actionPath;

  /// Datos que viajan con la notificación, Ej: `visitId`, `propertyId`.
  final List<String> data;

  static final _variable = RegExp(r'\{\{(\w+)\}\}');

  /// Valor de ejemplo de cada variable: los IDs quedan como `VISIT_ID` para
  /// reemplazarlos por uno real; los textos, con un valor de muestra.
  static String sampleValue(String name) => switch (name) {
        'associateName' => 'Juan Pérez',
        _ => name
            .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}')
            .toUpperCase(),
      };

  static String fill(String template) =>
      template.replaceAllMapped(_variable, (m) => sampleValue(m[1]!));

  String get sampleBody => fill(body);

  /// `actionPath` de prueba: la ruta con IDs de ejemplo, más el código y los
  /// datos que no están en la ruta como parámetros, que es como el router
  /// resuelve una notificación de prueba igual que la real.
  String get sampleActionPath {
    final path = fill(actionPath);
    final inPath = _variable.allMatches(actionPath).map((m) => m[1]!).toSet();
    final query = {
      'type': code,
      for (final key in data)
        if (!inPath.contains(key)) key: sampleValue(key),
    };
    return '$path?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }
}
