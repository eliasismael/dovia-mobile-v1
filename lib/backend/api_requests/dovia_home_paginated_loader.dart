/// Carga paginada de los listados de Dovia Home.
///
/// Las pantallas de listado filtran del lado del cliente —desplegables,
/// búsqueda, particiones por estado—, así que necesitan el listado **completo**
/// antes de pintar. Con una sola página, filtrar por "Agosto 2026" devolvería
/// sólo las coincidencias que entraron en esa página —un resultado que parece
/// completo y no lo es— y el desplegable de meses ofrecería únicamente los meses
/// de esa página. Por eso se pagina al cargar y no a medida que el usuario
/// scrollea.
///
/// En los listados que mezclan tramos (la agenda del asociado trae pendientes y
/// terminados juntos, igual que el historial del cliente) hay un segundo motivo:
/// con una única página un tramo le come el cupo al otro.
///
/// El corte lo manda `meta.pagination.hasNextPage`, que es lo que declara el
/// contrato. El tamaño de página queda como respaldo para las respuestas que no
/// traen metadata.
library;

import 'api_dovia_home.dart';
import 'api_manager.dart';

/// Tamaño de página pedido al backend.
const int kDoviaHomePageSize = 50;

/// Tope de páginas a recorrer.
///
/// Es una red de seguridad, no un límite de negocio: sin él, un backend que
/// ignore `page` y devuelva siempre `hasNextPage: true` dejaría el bucle girando
/// para siempre. Cuando se alcanza, el listado se marca como
/// [DoviaHomePagedList.truncated] para que la pantalla lo diga en vez de
/// recortar en silencio.
const int kDoviaHomeMaxPages = 10;

/// Máximo de elementos que se llegan a traer.
const int kDoviaHomeMaxItems = kDoviaHomePageSize * kDoviaHomeMaxPages;

/// Listado ya recorrido de punta a punta, más el estado de la carga.
class DoviaHomePagedList {
  const DoviaHomePagedList({
    required this.items,
    this.errorStatus,
    this.truncated = false,
  });

  final List<Map<String, dynamic>> items;

  /// Status HTTP con el que falló la carga, o null si trajo algo. Se guarda el
  /// código y no un booleano porque un 403 y una caída se le explican distinto
  /// al usuario.
  final int? errorStatus;

  /// Se llegó al tope de páginas sin agotar el listado: hay elementos que no se
  /// están mostrando.
  final bool truncated;

  bool get failed => errorStatus != null;
}

/// Recorre [fetchPage] hasta agotar el listado y devuelve todo junto.
///
/// [extractList] saca el arreglo del cuerpo de la respuesta y [keep] descarta lo
/// que la pantalla no trabaja.
Future<DoviaHomePagedList> loadAllDoviaHomePages({
  required Future<ApiCallResponse> Function(int page, int limit) fetchPage,
  required List? Function(dynamic) extractList,
  bool Function(Map<String, dynamic>)? keep,
}) async {
  final all = <Map<String, dynamic>>[];

  // `page` es 1-based (mismo criterio que el resto de listados del API).
  for (var page = 1; page <= kDoviaHomeMaxPages; page++) {
    final response = await fetchPage(page, kDoviaHomePageSize);

    if (!response.succeeded) {
      // Si falló la primera página no hay nada que mostrar y la pantalla
      // explica el error. Si falló una posterior ya hay listado en mano: se
      // devuelve lo que se pudo traer, marcado como incompleto, en vez de tirar
      // abajo una pantalla que ya tenía contenido útil.
      if (all.isEmpty) {
        return DoviaHomePagedList(
          items: const [],
          errorStatus: response.statusCode,
        );
      }
      return DoviaHomePagedList(items: all, truncated: true);
    }

    // El parser corre sobre `jsonBody`: pasarle el ApiCallResponse deja a
    // JsonPath sin nada que recorrer y devuelve null en silencio (listado
    // siempre vacío).
    final raw = extractList(response.jsonBody) ?? const [];

    final parsed =
        raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e));
    all.addAll(keep == null ? parsed : parsed.where(keep));

    // Fin del listado según el propio backend. Es la señal autoritativa: una
    // página completa puede ser la última, y deducirlo del tamaño obligaba a una
    // petición de más para descubrirlo.
    final hasNext = doviaHomeHasNextPage(response.jsonBody);
    if (hasNext == false) {
      return DoviaHomePagedList(items: all);
    }

    // Sin metadata se cae al tamaño de página: una página incompleta es la
    // última. Se mide sobre lo que devolvió el backend y **no** sobre lo que
    // sobrevivió a [keep], porque una página entera de elementos descartados
    // cortaría el bucle con listado por delante.
    if (hasNext == null && raw.length < kDoviaHomePageSize) {
      return DoviaHomePagedList(items: all);
    }
  }

  return DoviaHomePagedList(items: all, truncated: true);
}
