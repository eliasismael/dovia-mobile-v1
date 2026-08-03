/// Carga del catálogo de Dovia Home cruzado contra las especialidades
/// aprobadas del asociado.
///
/// Lo usan los dos tableros de trabajo —**Trabajos disponibles** y **Próximos
/// trabajos**—, donde el filtro "Tipo de Trabajo" se puebla **sólo** con las
/// aprobadas, para que no pueda filtrar por un oficio que no está habilitado a
/// trabajar. El cruce sigue haciéndose contra el catálogo porque es el catálogo
/// el que comparte códigos con las tarjetas de trabajo.
///
/// La pantalla de **Servicios** no pasa por acá: `GET /users/me/specialties` ya
/// le devuelve resueltas las aprobadas, las solicitables y las pendientes
/// (`loadAssociateSpecialties`).
library;

import '/backend/api_requests/api_associate_specialties.dart';
import '/backend/api_requests/api_dovia_home.dart';
import 'associate_service_categories.dart';

/// Catálogo ya separado en lo que el asociado opera y lo que todavía no.
class AssociateCategories {
  const AssociateCategories({
    required this.approved,
    required this.available,
    this.catalogErrorStatus,
    this.specialtiesFailed = false,
  });

  /// Categorías en las que el asociado ya está aprobado para operar.
  final List<AssociateServiceCategory> approved;

  /// Categorías del catálogo que todavía puede solicitar.
  final List<AssociateServiceCategory> available;

  /// Status HTTP con el que falló el catálogo, o null si respondió bien. Se
  /// guarda el código y no un booleano porque un 403 y una caída se le explican
  /// distinto al usuario ([catalogErrorMessage]).
  final int? catalogErrorStatus;

  /// El listado de especialidades no respondió. No es fatal —se sigue con el
  /// catálogo completo— pero sí significa que no se sabe qué tiene aprobado.
  final bool specialtiesFailed;

  bool get catalogFailed => catalogErrorStatus != null;

  /// Mensaje para el usuario cuando el catálogo no cargó.
  ///
  /// El 403 se distingue a propósito: el rol del asociado puede no tener el
  /// permiso `DOVIA_HOME_CATALOG_READ`, y decirle "intentá de nuevo" lo manda a
  /// reintentar algo que nunca va a funcionar solo.
  String get catalogErrorMessage => catalogErrorStatus == 403
      ? 'Tu perfil no tiene permisos para ver el catálogo de servicios. '
          'Contactá al equipo de DOVIA.'
      : 'No pudimos cargar el catálogo de servicios. Intentá de nuevo en un '
          'momento.';
}

/// Pide catálogo y especialidades en paralelo y devuelve el cruce.
///
/// Si fallan las especialidades se sigue adelante con el catálogo completo: la
/// pantalla pierde la distinción de aprobadas, pero no se queda en blanco. Si
/// falla el catálogo no hay nada que mostrar y se devuelve el error para que la
/// pantalla lo explique.
Future<AssociateCategories> loadAssociateCategories({
  required String authToken,
}) async {
  final specialtiesCall =
      DOVIAAPIAssociateSpecialtiesContextGroup.getMySpecialtiesCall;

  final responses = await Future.wait([
    DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall
        .call(authToken: authToken),
    specialtiesCall.call(authToken: authToken),
  ]);

  final catalogRes = responses[0];
  final specialtiesRes = responses[1];

  if (!catalogRes.succeeded) {
    return AssociateCategories(
      approved: const [],
      available: const [],
      catalogErrorStatus: catalogRes.statusCode,
      specialtiesFailed: !specialtiesRes.succeeded,
    );
  }

  final categories = parseAssociateCategories(
    DOVIAAPIDoviaHomeContextGroup.listCatalogServicesCall
            .servicesList(catalogRes.jsonBody) ??
        const [],
  );

  final approvedKeys = specialtiesRes.succeeded
      ? parseApprovedSpecialtyKeys(
          specialtiesCall.currentSpecialties(specialtiesRes.jsonBody) ??
              const [],
        )
      : <String>{};

  final approved = <AssociateServiceCategory>[];
  final available = <AssociateServiceCategory>[];
  for (final category in categories) {
    if (categoryIsApproved(category, approvedKeys)) {
      approved.add(category);
    } else {
      available.add(category);
    }
  }

  return AssociateCategories(
    approved: approved,
    available: available,
    specialtiesFailed: !specialtiesRes.succeeded,
  );
}
