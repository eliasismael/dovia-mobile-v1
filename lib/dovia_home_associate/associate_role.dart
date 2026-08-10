/// Perfiles del Dovia Home Associate y qué habilita cada uno.
///
/// El backend distingue dos roles sobre el mismo contexto:
///   - `HOME_ASSOCIATE`: el **profesional independiente**. Toma servicios
///     estándar y emergencias de la bolsa; no cotiza.
///   - `HOME_ASSOCIATE_COMPANY`: la **empresa**. No toma trabajo de la bolsa:
///     su bolsa es el marketplace de cotizaciones (`/dovia-home/company/...`),
///     donde presupuesta proyectos a medida de clientes Premium.
///
/// El rol llega en `roles[0]` del perfil autenticado y queda guardado en
/// [FFAppState.UserRole] al iniciar sesión, que es de donde lo lee la UI: la
/// app no vuelve a pedir el perfil en cada pantalla para decidir qué mostrar.
///
/// **Esto no es un control de acceso.** Los endpoints de empresa validan el rol
/// del token; acá sólo se decide qué se le ofrece a la vista, para que un
/// independiente no vea accesos a cotizaciones que el backend le va a rechazar.
library;

import '/app_state.dart';

const String kHomeAssociateRole = 'HOME_ASSOCIATE';
const String kHomeAssociateCompanyRole = 'HOME_ASSOCIATE_COMPANY';

/// ¿El usuario en sesión es un asociado tipo Empresa?
bool isHomeAssociateCompany() =>
    FFAppState().UserRole.toUpperCase() == kHomeAssociateCompanyRole;
