import '/backend/api_requests/api_manager.dart';

/// Mensaje para mostrarle al usuario cuando falla una llamada a la API.
///
/// Sin conexión (o timeout) el ApiManager devuelve `statusCode == -1`: en ese
/// caso se dice eso, en vez de un error genérico que hace pensar que el dato
/// cargado está mal. Un 5xx es una falla del servidor: su texto ("Internal
/// server error" de API Gateway, por ejemplo) no le sirve al usuario, así que
/// va [fallback]. Si no, se usa el `message` del backend (o el primero de
/// `errors`) y, sin nada de eso, [fallback].
String apiErrorMessage(ApiCallResponse response, String fallback) {
  if (response.statusCode == -1) {
    return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
  }
  if (response.statusCode >= 500) return fallback;
  return apiBodyMessage(response.jsonBody) ?? fallback;
}

/// `message` del cuerpo de error del backend, o el primero de `errors`.
String? apiBodyMessage(dynamic body) {
  if (body is! Map) return null;
  final message = body['message']?.toString().trim();
  if (message != null && message.isNotEmpty) return message;
  final errors = body['errors'];
  if (errors is List) {
    for (final error in errors) {
      if (error is Map) {
        final m = error['message']?.toString().trim();
        if (m != null && m.isNotEmpty) return m;
      }
    }
  }
  return null;
}
