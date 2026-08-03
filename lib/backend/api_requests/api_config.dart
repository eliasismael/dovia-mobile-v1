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
