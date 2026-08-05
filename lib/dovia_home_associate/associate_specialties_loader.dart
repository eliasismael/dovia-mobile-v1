/// Categorías con las que filtran los tableros de trabajo del asociado.
///
/// Lo usan **Servicios** (el carrusel del panel), **Trabajos disponibles** y
/// **Próximos trabajos**: los tres ofrecen filtrar por oficio, y los tres deben
/// ofrecer **sólo los que el asociado tiene aprobados**, para que no pueda
/// filtrar por un trabajo que no está habilitado a tomar.
///
/// La fuente es `GET /users/me/specialties` y **no** el catálogo de servicios:
/// `GET /dovia-home/catalog/services` es del perfil cliente y responde 403 con
/// un token de asociado. El listado de especialidades ya viene resuelto en
/// aprobadas / solicitables, así que no hay ningún cruce que hacer acá.
///
/// El id de cada categoría es el **id de la especialidad**, que es con lo que
/// cruzan las solicitudes: cada una trae `serviceDetail.requiredSpecialtyIds`
/// (ver [associateRequestMatchesCategory]).
library;

import 'associate_service_categories.dart';
import 'associate_specialties.dart';

/// Los oficios del asociado, separados en lo que ya opera y lo que todavía no.
class AssociateCategories {
  const AssociateCategories({
    required this.approved,
    required this.available,
    this.errorStatus,
  });

  /// Oficios en los que el asociado ya está aprobado para operar.
  final List<AssociateServiceCategory> approved;

  /// Oficios que todavía puede solicitar.
  final List<AssociateServiceCategory> available;

  /// Status HTTP con el que falló la carga, o null si respondió bien.
  final int? errorStatus;

  bool get failed => errorStatus != null;

  /// Mensaje para el usuario cuando el listado no cargó. El 403 se distingue
  /// porque manda a revisar el perfil, no a reintentar.
  String get errorMessage => errorStatus == 403
      ? 'Tu cuenta todavía no está habilitada para operar servicios. Revisá '
          'que tu perfil esté verificado o contactá al equipo de DOVIA.'
      : 'No pudimos cargar tus servicios habilitados. Intentá de nuevo en un '
          'momento.';
}

AssociateServiceCategory _toCategory(AssociateSpecialty specialty) =>
    AssociateServiceCategory(
      id: specialty.id,
      code: specialty.code,
      label: specialty.label,
      iconPath: specialty.iconPath,
    );

/// Pide las especialidades del asociado y las devuelve como categorías de
/// filtro.
Future<AssociateCategories> loadAssociateCategories({
  required String authToken,
}) async {
  final specialties = await loadAssociateSpecialties(authToken: authToken);

  if (specialties.failed) {
    return AssociateCategories(
      approved: const [],
      available: const [],
      errorStatus: specialties.errorStatus,
    );
  }

  return AssociateCategories(
    approved: specialties.current.map(_toCategory).toList(),
    available: specialties.available.map(_toCategory).toList(),
  );
}
