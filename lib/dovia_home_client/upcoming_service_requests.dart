import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'service_request_fields.dart';

/// Solicitudes del cliente que todavía no terminaron, para "Próximas visitas".
///
/// El listado acepta un solo `status` por pedido y viene paginado, así que se
/// pide sin filtro y se descartan las `FINISHED`. Antes se miraba sólo la
/// primera página de 20: si todas estaban finalizadas, la sección quedaba
/// vacía aunque hubiera visitas pendientes más adelante. Ahora se sigue
/// paginando hasta juntar [wanted] o llegar a [maxPages].
///
/// Devuelve una respuesta con la forma del listado (`data` con sólo las
/// pendientes) para que la pantalla la lea igual que antes. Si falla una
/// página y todavía no se juntó ninguna pendiente, se devuelve ese error: una
/// lista vacía diría "no hay visitas" cuando en realidad no se pudo saber. Si
/// ya había pendientes, se muestran las que se juntaron.
Future<ApiCallResponse> loadUpcomingServiceRequests({
  required String authToken,
  int wanted = 10,
  int pageSize = 50,
  int maxPages = 10,
}) async {
  final call = DOVIAAPIDoviaHomeContextGroup.listServiceRequestsCall;
  final upcoming = <dynamic>[];
  ApiCallResponse? first;

  for (var page = 1; page <= maxPages; page++) {
    final response =
        await call.call(authToken: authToken, page: page, limit: pageSize);
    if (!response.succeeded) {
      if (upcoming.isEmpty) return response;
      break;
    }
    first ??= response;

    final items = call.requestsList(response.jsonBody) ?? const [];
    upcoming.addAll(items.where((item) =>
        item is Map &&
        (srString(item['status']) ?? 'PENDING').toUpperCase() != 'FINISHED'));

    final hasNextPage =
        getJsonField(response.jsonBody, r'''$.meta.pagination.hasNextPage''') ==
            true;
    if (upcoming.length >= wanted || !hasNextPage || items.isEmpty) break;
  }

  return ApiCallResponse(
    {'data': upcoming},
    first!.headers,
    first.statusCode,
  );
}
