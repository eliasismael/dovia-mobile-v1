import 'package:flutter/foundation.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_offers.dart';
import '/backend/api_requests/api_properties.dart';
import '/core/result.dart';
import '/domain/client_offer_models.dart';
import '/domain/owner_proposal_models.dart';

class OffersRepository extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Offers received on the properties the current user owns, already split
  /// into the three lanes the "Propuestas Recientes" screens render.
  ///
  /// `/offers/my-properties` sólo devuelve `propertyId`, así que se resuelven
  /// las propiedades del dueño en una segunda llamada y se cruzan por id: sin
  /// eso las tarjetas quedarían sin nombre ni foto. Si esa llamada falla, las
  /// propuestas se devuelven igual, sólo que sin los datos de la propiedad.
  Future<Result<OwnerProposalsBoard>> loadProposalsOnMyProperties({
    int page = 1,
    int limit = 50,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final response =
        await DOVIAAPIOfferContextGroup.listOffersOnMyPropertiesCall.call(
      authToken: token,
      page: page.toString(),
      limit: limit.toString(),
    );

    if (!response.succeeded) {
      return Failure(
        response.jsonBody?['message']?.toString() ??
            'Error al cargar las propuestas recibidas',
        statusCode: response.statusCode,
      );
    }

    return Success(OwnerProposalsBoard.fromOffers(
      _extractItems(response.jsonBody),
      propertiesById: await _loadMyPropertiesById(token),
    ));
  }

  /// Propiedades del dueño indexadas por id, para completar las ofertas.
  Future<Map<String, Map<String, dynamic>>> _loadMyPropertiesById(
      String token) async {
    final response = await DOVIAAPIPropertyContextGroup.getMyPropertiesCall.call(
      authToken: token,
      page: '1',
      limit: '100',
    );
    if (!response.succeeded) return const {};

    final result = <String, Map<String, dynamic>>{};
    for (final raw in _extractItems(response.jsonBody)) {
      if (raw is! Map) continue;
      final property = Map<String, dynamic>.from(raw);
      final id = property['id']?.toString() ?? property['_id']?.toString();
      if (id != null && id.isNotEmpty) result[id] = property;
    }
    return result;
  }

  /// Ofertas que el usuario envió como cliente sobre propiedades ajenas — lo
  /// que alimenta el panel "Mis Ofertas".
  ///
  /// `/offers/my-offers` sólo devuelve `propertyId`, y aquí las propiedades no
  /// son del usuario, así que no sirve `/properties/my-properties`: se resuelve
  /// cada inmueble distinto con `GET /properties/{id}`, que es el único
  /// endpoint que además trae la foto principal. Si una propiedad no se puede
  /// resolver, la oferta se muestra igual con el placeholder de la tarjeta.
  Future<Result<ClientOffersBoard>> loadMyOffers({
    int page = 1,
    int limit = 50,
  }) async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIOfferContextGroup.listMyOffersCall.call(
      authToken: token,
      page: page.toString(),
      limit: limit.toString(),
    );

    if (!response.succeeded) {
      return Failure(
        response.jsonBody?['message']?.toString() ??
            'Error al cargar tus ofertas',
        statusCode: response.statusCode,
      );
    }

    final offers = _extractItems(response.jsonBody);
    return Success(ClientOffersBoard.fromOffers(
      offers,
      propertiesById: await _loadPropertiesByIds(
        offers
            .map((o) => o is Map ? o['propertyId']?.toString() ?? '' : '')
            .where((id) => id.isNotEmpty)
            .toSet(),
      ),
    ));
  }

  /// Retira una oferta enviada por el cliente.
  ///
  /// El backend no tiene un endpoint propio de cancelación: retirar es
  /// rechazar la negociación desde el lado del cliente, igual que ya lo hace
  /// la pantalla de detalle del comprador.
  Future<Result<bool>> withdrawMyOffer({
    required String offerId,
    required String reason,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await DOVIAAPIOfferContextGroup.rejectOfferCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
      rejectedBy: 'CLIENT',
      reason: reason,
    );

    _isLoading = false;
    notifyListeners();

    if (response.succeeded) return const Success(true);
    return Failure(
      response.jsonBody?['message']?.toString() ??
          'No pudimos retirar tu oferta',
      statusCode: response.statusCode,
    );
  }

  /// Resuelve varias propiedades por id, en paralelo. Las que fallen quedan
  /// simplemente fuera del mapa.
  Future<Map<String, Map<String, dynamic>>> _loadPropertiesByIds(
    Set<String> ids,
  ) async {
    if (ids.isEmpty) return const {};

    final responses = await Future.wait(ids.map((id) async {
      final response =
          await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
        propertyId: id,
      );
      return MapEntry(id, response);
    }));

    final result = <String, Map<String, dynamic>>{};
    for (final entry in responses) {
      if (!entry.value.succeeded) continue;
      final data = entry.value.jsonBody is Map
          ? (entry.value.jsonBody as Map)['data']
          : null;
      if (data is Map) result[entry.key] = Map<String, dynamic>.from(data);
    }
    return result;
  }

  /// The endpoint answers either `{data: [...]}` or `{data: {items: [...]}}`
  /// depending on whether the list is paginated.
  List<dynamic> _extractItems(dynamic jsonBody) {
    if (jsonBody is! Map) return const [];
    final data = jsonBody['data'];
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    if (jsonBody['items'] is List) return jsonBody['items'] as List;
    return const [];
  }

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
