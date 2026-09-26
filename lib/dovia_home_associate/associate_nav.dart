import 'package:flutter/widgets.dart';

import '/dovia_home_associate/associate_role.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_client/proposal_fields.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Nombre de la ruta del panel que le corresponde al asociado en sesión:
/// empresa o profesional independiente.
String associateHomeRouteName() => isHomeAssociateCompany()
    ? DHASSOCIATEEmpresaHomePageWidget.routeName
    : DHASSOCIATEHomePageWidget.routeName;

/// Vuelve al panel del asociado limpiando la pila (la "D" del header).
void goAssociateHome(BuildContext context) =>
    context.goNamed(associateHomeRouteName());

/// Parámetros de ruta de las pantallas de detalle del asociado.
///
/// Las pantallas reciben el trabajo ya cargado en un campo estático para
/// pintarse al instante, pero además llevan su id en la ruta: así también
/// abren bien desde una notificación, un deep link o después de un hot
/// restart, cuando ese campo está vacío.
Map<String, String> associateRouteParams({
  Map<String, dynamic>? request,
  Map<String, dynamic>? proposal,
  String? id,
}) {
  final requestId = id ?? (request == null ? '' : asrId(request));
  final propId = proposal == null ? '' : proposalId(proposal);
  return {
    if (requestId.isNotEmpty) 'id': requestId,
    if (propId.isNotEmpty) 'proposalId': propId,
  };
}

/// El trabajo que tiene que mostrar la pantalla: el inyectado si corresponde
/// al id de la ruta y, si no, un resumen mínimo con el id para que la
/// pantalla lo pida al backend.
Map<String, dynamic>? resolveRouteRequest(
    Map<String, dynamic>? injected, String? routeId) {
  if (routeId == null || routeId.isEmpty) return injected;
  if (injected != null && asrId(injected) == routeId) return injected;
  return {'id': routeId};
}

/// `true` cuando sólo se tiene el id (se abrió desde la ruta) y falta pedir
/// el detalle para poder mostrar algo.
bool isRouteStub(Map<String, dynamic>? data) =>
    data != null && data.length == 1 && data.containsKey('id');
