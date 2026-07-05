import 'package:flutter/foundation.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_offers.dart';
import '/core/result.dart';

class OffersRepository extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Result<bool>> createCounterOffer({
    required String offerId,
    required Map<String, dynamic> counterOfferData,
  }) async {
    _isLoading = true;
    notifyListeners();

    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIOfferContextGroup.createCounterOfferCall.call(
      offerId: offerId,
      authToken: token,
      counterOfferData: counterOfferData,
    );

    _isLoading = false;
    notifyListeners();

    if (response.succeeded) {
      return const Success(true);
    } else {
      return Failure(
        response.jsonBody?['message'] ?? 'Error al crear la contraoferta',
        statusCode: response.statusCode,
      );
    }
  }
}
