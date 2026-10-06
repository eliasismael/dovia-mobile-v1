/// Configuración de entorno de la API.
///
/// Se define en tiempo de compilación con:
///   flutter build web --release --dart-define=API_BASE_URL=https://...
///
/// Si no se pasa (o llega vacía), se usa el entorno de desarrollo por defecto.
const String _defaultApiBaseUrl =
    'https://fqjwdfvbi2.execute-api.us-east-2.amazonaws.com/dev';

const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

const String kApiBaseUrl =
    _envApiBaseUrl == '' ? _defaultApiBaseUrl : _envApiBaseUrl;

/// Entorno al que apunta este build, deducido de la URL de la API para que no
/// pueda quedar desfasado: 'DEV', 'STAGING' o '' (producción u otro).
String get kApiEnvLabel {
  final url = kApiBaseUrl.toLowerCase();
  if (url.endsWith('/dev')) return 'DEV';
  if (url.endsWith('/staging')) return 'STAGING';
  return '';
}
