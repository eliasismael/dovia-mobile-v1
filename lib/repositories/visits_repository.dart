import 'package:flutter/foundation.dart';

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
  Future<Result<List<Visit>>> loadMyVisits({bool forceRefresh = false}) async {
    if (_myVisits.isNotEmpty && !forceRefresh) {
      return Success(List.unmodifiable(_myVisits));
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIVisitContextGroup.getMyVisitsCall.call(authToken: token);

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
  Future<Result<void>> createVisitRequest({
    required String propertyId,
    required String dateOne,
    required String hourOne,
    String dateTwo = '',
    String hourTwo = '',
    String dateThree = '0000-00-00',
    String hourThree = '00:00',
  }) async {
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

  /// Clears cached visits (call on logout).
  void clear() {
    _myVisits = [];
    _error = null;
    notifyListeners();
  }
}
