/// Carga paginada de los listados de solicitudes del asociado.
///
/// Las dos pantallas de listado —la bolsa de oportunidades ("Trabajos
/// disponibles") y la agenda ("Próximos trabajos")— filtran del lado del
/// cliente: los tres desplegables, la búsqueda y, en la agenda, la partición en
/// aceptados/terminados corren sobre lo que ya se trajo.
///
/// Eso obliga a traer el listado **completo** antes de pintar. Con una sola
/// página, filtrar por "Agosto 2026" devolvería sólo las coincidencias que
/// entraron en esa página —un resultado que parece completo y no lo es— y el
/// desplegable de meses ofrecería únicamente los meses de esa página. Por eso se
/// pagina acá, al cargar, y no a medida que el usuario scrollea.
///
/// En la agenda hay además un segundo motivo: aceptados y terminados salen del
/// mismo listado, así que con una única página el historial le come el cupo a
/// los trabajos que el asociado todavía tiene que hacer.
library;

import '/backend/api_requests/api_manager.dart';

/// Tamaño de página. Es el `limit` que ya venían pidiendo las dos pantallas.
const int kAssociateRequestsPageSize = 50;

/// Tope de páginas a recorrer.
///
/// Es una red de seguridad, no un límite de negocio: sin él, un backend que
/// ignore `page` y devuelva siempre la misma página completa dejaría el bucle
/// girando para siempre. Cuando se alcanza, el listado se marca como
/// [AssociateRequestsPage.truncated] para que la pantalla lo diga en vez de
/// recortar en silencio.
const int kAssociateRequestsMaxPages = 10;

/// Máximo de solicitudes que se llegan a traer.
const int kAssociateRequestsMaxItems =
    kAssociateRequestsPageSize * kAssociateRequestsMaxPages;

/// Listado ya recorrido de punta a punta, más el estado de la carga.
class AssociateRequestsPage {
  const AssociateRequestsPage({
    required this.requests,
    this.errorStatus,
    this.truncated = false,
  });

  final List<Map<String, dynamic>> requests;

  /// Status HTTP con el que falló la carga, o null si trajo algo. Se guarda el
  /// código y no un booleano porque un 403 y una caída se le explican distinto
  /// al usuario.
  final int? errorStatus;

  /// Se llegó al tope de páginas sin agotar el listado: hay solicitudes que no
  /// se están mostrando.
  final bool truncated;

  bool get failed => errorStatus != null;
}

/// Recorre [fetchPage] hasta agotar el listado y devuelve todo junto.
///
/// [extractList] saca el array del cuerpo de la respuesta y [keep] descarta lo
/// que la pantalla no trabaja (cotizaciones, trabajos ya tomados por otro).
Future<AssociateRequestsPage> loadAllAssociateRequests({
  required Future<ApiCallResponse> Function(int page, int limit) fetchPage,
  required List? Function(dynamic) extractList,
  bool Function(Map<String, dynamic>)? keep,
}) async {
  final all = <Map<String, dynamic>>[];

  // `page` es 1-based (mismo criterio que el resto de listados del API).
  for (var page = 1; page <= kAssociateRequestsMaxPages; page++) {
    final response = await fetchPage(page, kAssociateRequestsPageSize);

    if (!response.succeeded) {
      // Si falló la primera página no hay nada que mostrar y la pantalla
      // explica el error. Si falló una posterior ya hay listado en mano: se
      // devuelve lo que se pudo traer, marcado como incompleto, en vez de tirar
      // abajo una pantalla que ya tenía contenido útil.
      if (all.isEmpty) {
        return AssociateRequestsPage(
          requests: const [],
          errorStatus: response.statusCode,
        );
      }
      return AssociateRequestsPage(requests: all, truncated: true);
    }

    // El parser corre sobre `jsonBody`: pasarle el ApiCallResponse deja a
    // JsonPath sin nada que recorrer y devuelve null en silencio (listado
    // siempre vacío).
    final raw = extractList(response.jsonBody) ?? const [];

    final parsed =
        raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e));
    all.addAll(keep == null ? parsed : parsed.where(keep));

    // Página incompleta = última página. Se mide sobre lo que devolvió el
    // backend y **no** sobre lo que sobrevivió a [keep]: una página entera de
    // solicitudes descartadas cortaría el bucle con listado por delante.
    if (raw.length < kAssociateRequestsPageSize) {
      return AssociateRequestsPage(requests: all);
    }
  }

  return AssociateRequestsPage(requests: all, truncated: true);
}
