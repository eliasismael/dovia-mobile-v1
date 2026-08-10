/// Lectura del pipeline de cotizaciones del asociado tipo **Empresa**.
///
/// El panel de la empresa se arma cruzando tres listados que hablan de la misma
/// unidad de trabajo desde ángulos distintos:
///
///   - `GET /dovia-home/company/service-requests` → las solicitudes `QUOTE` que
///     la empresa puede ver y presupuestar. Es un `ServiceRequest`, así que se
///     lee con los mismos accessors que el resto del asociado
///     ([associate_service_request_fields.dart]).
///   - `GET /dovia-home/associate/proposals` → las propuestas que **esta**
///     empresa envió, en el sobre unificado `DoviaHomeUnifiedProposalDto`
///     (mezcla `QUOTE` y `OUT_OF_SCOPE`). Se lee con
///     [proposal_fields.dart], que ya parsea ese DTO para el cliente.
///   - `GET /dovia-home/associate/service-requests` → las solicitudes ya
///     **asignadas** a la empresa. Cuando el cliente acepta su propuesta el
///     servicio pasa a `TAKEN` con la empresa como asociado, así que los
///     proyectos ganados salen de acá y no del marketplace: es también el
///     listado sobre el que corren tomar / notificar llegada / finalizar.
///
/// De ese cruce salen los tres carriles del diseño:
///
///   1. **Activas** — oportunidades abiertas donde la empresa todavía no
///      presupuestó ([cqIsOpenForQuoting] + descarte por [cqQuotedRequestIds]).
///   2. **Enviadas** — sus propuestas `SUBMITTED`, esperando la decisión del
///      cliente ([cqSubmittedQuoteProposals]).
///   3. **Aprobadas** — los proyectos que ganó ([cqIsWonProject]).
///
/// Un mismo servicio nunca puede estar en dos carriles: en cuanto la empresa
/// manda su propuesta sale de "activas", y en cuanto el cliente la acepta el
/// servicio deja de estar en el marketplace y aparece en su agenda.
library;

import '/dovia_home_client/proposal_fields.dart';

import 'associate_service_request_fields.dart';

/// `subStatus` de una cotización con el marketplace abierto: el cliente ya pidió
/// el presupuesto y las empresas pueden proponer. Es el mismo valor contra el
/// que el cliente decide si todavía puede cerrar la cotización.
const String kQuoteSubStatusQuoting = 'QUOTE_QUOTING';

/// Prefijo de los `subStatus` del flujo de cotización. Se mira el prefijo y no
/// el valor exacto porque el contrato puede sumar etapas intermedias
/// (`QUOTE_*`) y todas siguen siendo "cotización en curso".
const String _kQuoteSubStatusPrefix = 'QUOTE';

/// `subStatus` de la solicitud, en mayúsculas y vacío si no trae ninguno.
String cqSubStatus(Map<String, dynamic> data) =>
    (asrString(data['subStatus']) ?? '').toUpperCase();

/// ¿La solicitud sigue recibiendo presupuestos?
///
/// Es una cotización que nadie ganó todavía: `status = PENDING` con el
/// `subStatus` del flujo de cotización. Con la propuesta aceptada el servicio
/// pasa a `TAKEN` y deja de ser una oportunidad para nadie.
bool cqIsOpenForQuoting(Map<String, dynamic> data) =>
    asrIsQuote(data) &&
    asrStatus(data) == 'PENDING' &&
    cqSubStatus(data).startsWith(_kQuoteSubStatusPrefix);

/// ¿Es un proyecto que **esta** empresa ganó y todavía tiene que ejecutar?
///
/// Se evalúa sobre `GET /dovia-home/associate/service-requests`, que devuelve
/// sólo lo asignado a quien pregunta: que la solicitud esté ahí ya significa que
/// el cliente eligió a esta empresa. Los trabajos cerrados salen del carril —son
/// historial, no pipeline.
bool cqIsWonProject(Map<String, dynamic> data) =>
    asrIsQuote(data) && !asrIsFinished(data);

/// Etiqueta de ganancia de la tarjeta de oportunidad.
///
/// El diseño pide "un estimado de ganancia **si aplica**", y en una cotización
/// abierta normalmente no aplica: el precio lo pone la empresa en su propuesta,
/// no DOVIA. Cuando el payload sí trae un neto se muestra con el mismo formato
/// que el resto del asociado; si no, se dice que lo define su presupuesto en vez
/// de inventar un número.
String cqEarningsLabel(Map<String, dynamic> data) {
  final amount = asrPayoutAmount(data);
  if (amount == null) return 'Ganancia: la defines en tu propuesta';
  return 'Podrás ganar: ${asrFormatAmount(amount, asrCurrency(data))}';
}

/// Propuestas de tipo `QUOTE` dentro del listado unificado del proveedor.
///
/// El endpoint mezcla las de cotización con las de trabajo fuera de alcance, y
/// el panel de cotizaciones sólo habla de las primeras.
List<Map<String, dynamic>> cqQuoteProposals(List<Map<String, dynamic>> raw) =>
    raw.where((p) => !proposalIsOutOfScope(p)).toList();

/// Propuestas enviadas y todavía sin decisión del cliente: el carril 2.
///
/// Se filtra por `SUBMITTED` y no por descarte: una propuesta rechazada no está
/// "en espera de decisión" —ya la hubo— y una aceptada pertenece al carril de
/// aprobadas.
List<Map<String, dynamic>> cqSubmittedQuoteProposals(
        List<Map<String, dynamic>> raw) =>
    cqQuoteProposals(raw).where(proposalIsActionable).toList();

/// Servicios sobre los que la empresa **ya se pronunció**: mandó una propuesta
/// que sigue viva o que el cliente aceptó.
///
/// Con esto se sacan de "Cotizaciones activas" las oportunidades que ya
/// presupuestó: el marketplace las sigue devolviendo mientras el cliente decide,
/// y dejarlas ahí la invitaría a cotizar dos veces lo mismo.
///
/// Las **rechazadas no** entran: tras un rechazo la empresa puede mandar una
/// versión nueva —el contrato versiona las propuestas—, así que la oportunidad
/// vuelve a ser suya para tomar.
Set<String> cqQuotedRequestIds(List<Map<String, dynamic>> proposals) {
  final ids = <String>{};
  for (final proposal in cqQuoteProposals(proposals)) {
    if (proposalStatus(proposal) == kProposalRejected) continue;
    final id = proposalServiceRequestId(proposal);
    if (id != null) ids.add(id);
  }
  return ids;
}

/// Título de una propuesta enviada.
///
/// El sobre unificado no trae el servicio cotizado —sólo `description`—, así que
/// el nombre sale de cruzar `serviceRequestId` contra el marketplace, que es de
/// donde la empresa abrió la oportunidad. Si el servicio ya no está en el
/// listado (el cliente cerró la cotización, por ejemplo) se cae a la descripción
/// de la propia propuesta y, en última instancia, a una etiqueta genérica: la
/// tarjeta tiene que decir algo, y una vacía no le sirve a nadie.
String cqProposalTitle(
  Map<String, dynamic> proposal,
  Map<String, Map<String, dynamic>> requestsById,
) {
  final request = requestsById[proposalServiceRequestId(proposal) ?? ''];
  if (request != null) return asrServiceName(request);
  return proposalDescription(proposal) ?? 'Cotización enviada';
}

/// Indexa un listado de solicitudes por id, para cruzarlo con las propuestas.
Map<String, Map<String, dynamic>> cqRequestsById(
    List<Map<String, dynamic>> requests) {
  final byId = <String, Map<String, dynamic>>{};
  for (final request in requests) {
    final id = asrId(request);
    if (id.isNotEmpty) byId[id] = request;
  }
  return byId;
}
