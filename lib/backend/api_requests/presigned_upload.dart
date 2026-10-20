import 'package:http/http.dart' as http;

/// Margen para subir un archivo a S3. Holgado para fotos grandes con mala
/// señal, pero finito.
const kPresignedUploadTimeout = Duration(seconds: 60);

/// Sube un archivo a una URL prefirmada de S3 (el PUT del flujo presign →
/// PUT → confirm).
///
/// Es `http.put` con tiempo máximo: una conexión que queda abierta sin
/// responder no lanza ningún error, y sin límite el flujo que la espera
/// quedaba cargando para siempre. Al vencer lanza `TimeoutException`, que el
/// llamador maneja igual que un error de red.
Future<http.Response> putPresigned(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Duration timeout = kPresignedUploadTimeout,
}) =>
    http.put(url, headers: headers, body: body).timeout(timeout);
