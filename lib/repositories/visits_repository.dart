import 'package:flutter/foundation.dart';

import '/app_state.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
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

    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: token,
      filter: 'upcoming',
    );

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
    if (FFAppState().UserRole != 'CLIENT') {
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

    if (!response.succeeded) {
      return Failure(
        'No se pudo solicitar la visita',
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
    final response =
        await DOVIAAPIVisitContextGroup.rescheduleVisitCall.call(
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
      debugPrint('[VisitsRepo] hasActiveVisitForProperty: skipped — role is ${FFAppState().UserRole}');
      return false;
    }
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIVisitContextGroup.getMyVisitsCall.call(
      authToken: token,
    );

    debugPrint('[VisitsRepo] hasActiveVisitForProperty: HTTP ${response.statusCode}, succeeded=${response.succeeded}');
    debugPrint('[VisitsRepo] raw body: ${response.jsonBody}');

    if (!response.succeeded) return false;

    final visits = (response.jsonBody?['data'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    debugPrint('[VisitsRepo] checking ${visits.length} visits for propertyId=$propertyId');
    for (final v in visits) {
      final vPropId = v['propertyId'] as String? ?? v['property']?['id'] as String? ?? '';
      final vStatus = (v['status'] as String? ?? '').toUpperCase();
      debugPrint('[VisitsRepo]   id=${v['id']}  propertyId=$vPropId  status=$vStatus');
    }

    return visits.any((v) {
      final vPropId = v['propertyId'] as String? ?? v['property']?['id'] as String? ?? '';
      final vStatus = (v['status'] as String? ?? '').toUpperCase();
      return vPropId == propertyId &&
          (vStatus == 'PENDING' || vStatus == 'APPROVED' || vStatus == 'SCHEDULED');
    });
  }

  /// Clears cached visits (call on logout).
  void clear() {
    _myVisits = [];
    _error = null;
    notifyListeners();
  }
}
