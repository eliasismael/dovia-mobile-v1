import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/app_state.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/core/api_error.dart';
import '/core/result.dart';
import '/domain/visit_models.dart';

/// Single Source of Truth for the current user's visits.
class VisitsRepository extends ChangeNotifier {
  List<Visit> _myVisits = [];
  bool _isLoading = false;
  String? _error;

  List<Visit> get myVisits => List.unmodifiable(_myVisits);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads the list of visits for the current authenticated user.
  /// No-ops silently if the current user is not a CLIENT.
  Future<Result<List<Visit>>> loadMyVisits({bool forceRefresh = false}) async {
    if (FFAppState().UserRole != 'CLIENT') {
      return const Success([]);
    }

    if (_myVisits.isNotEmpty && !forceRefresh) {
      return Success(List.unmodifiable(_myVisits));
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final generation = authManager.sessionGeneration;
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: token,
      filter: 'upcoming',
    );
    // Se cerró sesión o entró otra cuenta mientras tanto: las visitas son de
    // la sesión anterior y no se guardan.
    if (authManager.sessionGeneration != generation) {
      return const Failure('La sesión cambió mientras se cargaba');
    }

    _isLoading = false;

    if (!response.succeeded) {
      _error = 'Error al cargar visitas';
      notifyListeners();
      return Failure(_error!, statusCode: response.statusCode);
    }

    final rawData = (response.jsonBody?['data'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    _myVisits = rawData.map(Visit.fromJson).toList();
    notifyListeners();
    return Success(List.unmodifiable(_myVisits));
  }

  /// Requests a new visit with up to 3 proposed time slots.
  /// Returns a failure immediately if the user is not a CLIENT.
  Future<Result<void>> createVisitRequest({
    required String propertyId,
    required String dateOne,
    required String hourOne,
    String dateTwo = '',
    String hourTwo = '',
    String dateThree = '0000-00-00',
    String hourThree = '00:00',
  }) async {
    debugPrint(
        '[VisitsRepo] Creating visit request. Current FFAppState.UserRole: ${FFAppState().UserRole}');
    if (FFAppState().UserRole != 'CLIENT') {
      debugPrint('[VisitsRepo] REJECTED: Not a CLIENT');
      return const Failure('Solo usuarios CLIENT pueden solicitar visitas.');
    }
    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIVisitContextGroup.createVisitRequestCall.call(
      propertyId: propertyId,
      authToken: token,
      dateOne: dateOne,
      hourOne: hourOne,
      dateTwo: dateTwo,
      hourTwo: hourTwo,
      dateThree: dateThree,
      hourThree: hourThree,
    );

    // El 401 por token vencido lo renueva y reintenta el ApiManager, atado a
    // la sesión que hizo el pedido. Acá había un refresh propio que podía
    // guardar el token de una cuenta con el id de otra.
    // El motivo del backend le dice al cliente qué cambiar (Ej: ya tiene una
    // visita activa en esta propiedad, o la propiedad no está disponible).
    if (!response.succeeded) {
      return Failure(
        apiErrorMessage(
            response, 'No se pudo solicitar la visita. Inténtalo de nuevo.'),
        statusCode: response.statusCode,
      );
    }

    // Invalidate cache so the list is reloaded next time
    _myVisits = [];
    notifyListeners();
    return const Success(null);
  }

  /// Cancels a visit by ID and removes it from the local cache.
  Future<Result<void>> cancelVisit(String visitId) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIVisitContextGroup.cancelVisitCall
        .call(visitId: visitId, authToken: token);

    if (!response.succeeded) {
      return Failure(
        'No se pudo cancelar la visita',
        statusCode: response.statusCode,
      );
    }

    _myVisits.removeWhere((v) => v.id == visitId);
    notifyListeners();
    return const Success(null);
  }

  /// Reschedules a visit with a new set of proposed slots.
  Future<Result<void>> rescheduleVisit({
    required String visitId,
    required String dateOne,
    required String hourOne,
    String dateTwo = '',
    String hourTwo = '',
    String dateThree = '0000-00-00',
    String hourThree = '00:00',
  }) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIVisitContextGroup.rescheduleVisitCall.call(
      visitId: visitId,
      authToken: token,
      dateOne: dateOne,
      hourOne: hourOne,
      dateTwo: dateTwo,
      hourTwo: hourTwo,
      dateThree: dateThree,
      hourThree: hourThree,
    );

    if (!response.succeeded) {
      return Failure(
        'No se pudo reagendar la visita',
        statusCode: response.statusCode,
      );
    }

    // Invalidate cache
    _myVisits = [];
    notifyListeners();
    return const Success(null);
  }

  /// Returns true if the user already has a PENDING, APPROVED, or SCHEDULED
  /// visit for [propertyId]. Makes a fresh API call without the 'upcoming'
  /// filter so that unconfirmed (PENDING) visits are always included.
  Future<bool> hasActiveVisitForProperty(String propertyId) async {
    if (FFAppState().UserRole != 'CLIENT') {
      debugPrint(
          '[VisitsRepo] hasActiveVisitForProperty: skipped — role is ${FFAppState().UserRole}');
      return false;
    }
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: token,
    );

    debugPrint(
        '[VisitsRepo] hasActiveVisitForProperty: HTTP ${response.statusCode}, succeeded=${response.succeeded}');
    debugPrint('[VisitsRepo] raw body: ${response.jsonBody}');

    if (!response.succeeded) return false;

    final visits = (response.jsonBody?['data'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    debugPrint(
        '[VisitsRepo] checking ${visits.length} visits for propertyId=$propertyId');
    for (final v in visits) {
      final vPropId =
          v['propertyId'] as String? ?? v['property']?['id'] as String? ?? '';
      final vStatus = (v['status'] as String? ?? '').toUpperCase();
      debugPrint(
          '[VisitsRepo]   id=${v['id']}  propertyId=$vPropId  status=$vStatus');
    }

    return visits.any((v) {
      final vPropId =
          v['propertyId'] as String? ?? v['property']?['id'] as String? ?? '';
      final vStatus = (v['status'] as String? ?? '').toUpperCase();
      return vPropId == propertyId &&
          (vStatus == 'PENDING' ||
              vStatus == 'APPROVED' ||
              vStatus == 'SCHEDULED');
    });
  }

  /// Clears cached visits (call on logout).
  void clear() {
    _myVisits = [];
    _error = null;
    // Una carga de la sesión anterior se descarta al volver: no queda "cargando".
    _isLoading = false;
    notifyListeners();
  }

  // =========================================================================
  // LISTING HQ MATCHMAKING (Operative Lister assignment)
  // =========================================================================

  /// Fetches available Operative Listers for a specific date and time slot.
  Future<Result<List<Map<String, dynamic>>>> getAvailableOperatives(
      DateTime date, TimeOfDay time) async {
    final token = currentAuthenticationToken ?? '';
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final response =
        await DOVIAAPIVisitContextGroup.getAvailableOperativeListersCall.call(
      authToken: token,
      date: dateStr,
      time: timeStr,
    );

    if (!response.succeeded) {
      return Failure('No se pudieron cargar los operative listers',
          statusCode: response.statusCode);
    }

    // El backend envuelve la respuesta en `data`
    // (`{ data: { date, time, operativeListers } }`). Se deja el acceso plano
    // como respaldo por si algún entorno devuelve el cuerpo sin envolver.
    final body = response.jsonBody;
    final envelope = body is Map ? body['data'] : null;
    final rawList = (envelope is Map ? envelope['operativeListers'] : null) ??
        (body is Map ? body['operativeListers'] : null);

    final operatives = <Map<String, dynamic>>[];
    if (rawList is List) {
      for (final o in rawList) {
        if (o is! Map) continue;
        // Muchos operativos de prueba comparten el mismo `fullName`; el email
        // es lo único que los distingue en pantalla.
        final phone = o['phone'];
        operatives.add({
          'id': o['id']?.toString() ?? '',
          'name': o['fullName']?.toString() ?? '',
          'photoUrl': o['avatar']?.toString(),
          'email': o['email']?.toString() ?? '',
          'phone': phone is Map
              ? '${phone['countryCode'] ?? ''} ${phone['number'] ?? ''}'.trim()
              : '',
        });
      }
    }

    return Success(operatives);
  }

  /// Assigns an operative lister to a visit.
  ///
  /// El backend exige que la visita esté en substatus
  /// `READY_TO_ASSIGN_OPERATIVE_LISTING` y que el usuario sea el `listerHqId`
  /// asignado; en cualquier otro caso responde 400.
  Future<Result<void>> assignVisit({
    required String visitId,
    required String operativeId,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final response =
        await DOVIAAPIVisitContextGroup.assignOperativeListerCall.call(
      visitId: visitId,
      authToken: token,
      operativeListerId: operativeId,
      date: dateStr,
      startTime: timeStr,
    );

    if (!response.succeeded) {
      // El backend explica el motivo real (substatus inválido, conflicto de
      // horario, etc.); mostrarlo evita diagnosticar a ciegas.
      final body = response.jsonBody;
      final detail = body is Map ? body['message']?.toString() : null;
      return Failure(
        detail == null || detail.isEmpty
            ? 'No se pudo asignar el operative lister'
            : 'No se pudo asignar el operative lister: $detail',
        statusCode: response.statusCode,
      );
    }

    // Invalidate cache
    _myVisits = [];
    notifyListeners();
    return const Success(null);
  }
}
