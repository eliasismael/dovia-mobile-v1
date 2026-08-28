import 'package:flutter/foundation.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_offers.dart';
import '/backend/api_requests/api_associate_feedback.dart';
import '/backend/api_requests/api_legal_process.dart';
import '/backend/api_requests/api_properties.dart';
import '/core/result.dart';
import '/domain/client_counter_offer_detail.dart';
import '/domain/client_offer_detail.dart';
import '/domain/client_offer_models.dart';
import '/domain/legal_closure_models.dart';
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
    final propertyIds = offers
        .map((o) => o is Map ? o['propertyId']?.toString() ?? '' : '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final crossed = await Future.wait([
      _loadPropertiesByIds(propertyIds),
      _loadRatingStatusByOffer(token),
    ]);

    return Success(ClientOffersBoard.fromOffers(
      offers,
      propertiesById: crossed[0],
      ratingStatusByOffer: crossed[1],
    ));
  }

  /// Estado de calificación de los tratos cerrados, indexado por oferta.
  ///
  /// `/offers/my-offers` no dice qué se calificó ya, así que sin este cruce la
  /// pestaña "Calificadas" quedaría siempre vacía y la pantalla de cierre
  /// siempre pediría calificar. `GET /offers/accepted` sí lo expone, pero sólo
  /// en sus dos filtros de calificación: se piden los dos y se unen.
  ///
  /// Es información de adorno: si falla, las ofertas se muestran igual y el
  /// cierre se comporta como si no hubiera calificado nada.
  Future<Map<String, Map<String, dynamic>>> _loadRatingStatusByOffer(
    String token,
  ) async {
    final responses = await Future.wait(
      const ['rated', 'pending-rating'].map(
        (filter) => DOVIAAPIOfferContextGroup.listAcceptedOffersCall.call(
          authToken: token,
          filter: filter,
          page: '1',
          limit: '100',
        ),
      ),
    );

    final result = <String, Map<String, dynamic>>{};
    for (final response in responses) {
      if (!response.succeeded) continue;
      for (final raw in _extractItems(response.jsonBody)) {
        if (raw is! Map) continue;
        final id = raw['offerId']?.toString() ?? raw['id']?.toString() ?? '';
        final status = raw['ratingStatus'];
        if (id.isEmpty || status is! Map) continue;
        result[id] = Map<String, dynamic>.from(status);
      }
    }
    return result;
  }

  /// Carga una oferta enviada y la traduce al modelo de detalle de sólo
  /// lectura. La vista recibe datos de dominio y no conoce la forma cruda de
  /// las respuestas HTTP.
  Future<Result<ClientOfferDetail>> loadMyOfferDetail(String offerId) async {
    if (offerId.isEmpty) {
      return const Failure('No se especificó el ID de la oferta.');
    }

    final response = await DOVIAAPIOfferContextGroup.getOfferByIDCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!response.succeeded) {
      return Failure(
        response.jsonBody is Map
            ? (response.jsonBody['message']?.toString() ??
                'No pudimos cargar tu oferta (${response.statusCode}).')
            : 'No pudimos cargar tu oferta (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    final offerJson = _extractObject(response.jsonBody);
    if (offerJson == null) {
      return const Failure('La oferta recibida no tiene un formato válido.');
    }

    Map<String, dynamic>? propertyJson;
    final propertyId = offerJson['propertyId']?.toString() ?? '';
    if (propertyId.isNotEmpty) {
      final propertyResponse =
          await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
        propertyId: propertyId,
      );
      if (propertyResponse.succeeded && propertyResponse.jsonBody is Map) {
        propertyJson = Map<String, dynamic>.from(propertyResponse.jsonBody);
      }
    }

    return Success(ClientOfferDetail.fromJson(
      offerJson,
      propertyJson: propertyJson,
    ));
  }

  /// Profesionales y documentos del proceso legal de un trato cerrado.
  ///
  /// `GET /legal-processes/{processId}` es el único endpoint que el rol CLIENT
  /// puede leer y que trae a la vez los dos perfiles y el expediente; la oferta
  /// sola expone el asociado pero no a Legal HQ ni los archivos.
  Future<Result<LegalProcessClosure>> loadLegalClosure(String processId) async {
    if (processId.isEmpty) {
      return const Failure('El trato todavía no tiene proceso legal.');
    }

    final response =
        await DOVIAAPILegalProcessContextGroup.getLegalProcessByIDCall.call(
      processId: processId,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!response.succeeded) {
      return Failure(
        response.jsonBody is Map
            ? (response.jsonBody['message']?.toString() ??
                'No pudimos cargar tu proceso legal (${response.statusCode}).')
            : 'No pudimos cargar tu proceso legal (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.jsonBody is! Map) {
      return const Failure('El proceso legal no tiene un formato válido.');
    }

    return Success(LegalProcessClosure.fromJson(
      Map<String, dynamic>.from(response.jsonBody),
    ));
  }

  /// Califica a uno de los profesionales legales del trato.
  ///
  /// El backend sólo acepta `stars`: el comentario del diseño se recoge pero
  /// todavía no tiene dónde guardarse, la misma limitación que ya arrastra la
  /// pantalla de calificación de Dovia Home.
  Future<Result<bool>> rateLegalProfessional({
    required String offerId,
    required String targetRole,
    required double stars,
  }) async {
    final response =
        await DOVIAAPIAssociateFeedbackContextGroup.createOfferAssociateRatingCall
            .call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
      targetRole: targetRole,
      stars: stars,
    );

    if (response.succeeded) return const Success(true);
    return Failure(
      response.jsonBody is Map
          ? (response.jsonBody['message']?.toString() ??
              'No pudimos enviar tu calificación.')
          : 'No pudimos enviar tu calificación.',
      statusCode: response.statusCode,
    );
  }

  /// Reporta un problema con uno de los profesionales legales.
  Future<Result<bool>> reportLegalProfessional({
    required String offerId,
    required String targetRole,
    required String message,
  }) async {
    final response =
        await DOVIAAPIAssociateFeedbackContextGroup.createOfferAssociateReportCall
            .call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
      targetRole: targetRole,
      message: message,
    );

    if (response.succeeded) return const Success(true);
    return Failure(
      response.jsonBody is Map
          ? (response.jsonBody['message']?.toString() ??
              'No pudimos enviar tu reporte.')
          : 'No pudimos enviar tu reporte.',
      statusCode: response.statusCode,
    );
  }

  /// Acepta la propuesta vigente del propietario y cierra la negociación.
  ///
  /// El trato pasa al carril de ofertas aceptadas y arranca el proceso con
  /// Legal HQ.
  Future<Result<bool>> acceptOfferAsClient(String offerId) async {
    final response = await DOVIAAPIOfferContextGroup.acceptOfferCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
      acceptedBy: 'CLIENT',
    );

    if (response.succeeded) return const Success(true);
    return Failure(
      response.jsonBody is Map
          ? (response.jsonBody['message']?.toString() ??
              'No pudimos aceptar la oferta.')
          : 'No pudimos aceptar la oferta.',
      statusCode: response.statusCode,
    );
  }

  Future<Result<ClientCounterOfferDetail>> loadClientCounterOfferDetail(
    String offerId,
  ) async {
    if (offerId.isEmpty) {
      return const Failure('No se especificó el ID de la contraoferta.');
    }

    final response = await DOVIAAPIOfferContextGroup.getOfferByIDCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
    );
    if (!response.succeeded) {
      return Failure(
        response.jsonBody is Map
            ? (response.jsonBody['message']?.toString() ??
                'No pudimos cargar la contraoferta (${response.statusCode}).')
            : 'No pudimos cargar la contraoferta (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    final offerJson = _extractObject(response.jsonBody);
    if (offerJson == null) {
      return const Failure('La contraoferta recibida no tiene un formato válido.');
    }
    return Success(ClientCounterOfferDetail.fromJson(offerJson));
  }

  Future<Result<bool>> acceptClientCounterOffer(String offerId) async {
    _isLoading = true;
    notifyListeners();
    final response = await DOVIAAPIOfferContextGroup.acceptOfferCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
      acceptedBy: 'CLIENT',
    );
    _isLoading = false;
    notifyListeners();

    if (response.succeeded) return const Success(true);
    return Failure(
      response.jsonBody?['message']?.toString() ??
          'No pudimos aceptar la contraoferta',
      statusCode: response.statusCode,
    );
  }

  Future<Result<bool>> rejectClientCounterOffer({
    required String offerId,
    required String reason,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      return const Failure('Debes indicar por qué rechazas la oferta.');
    }

    _isLoading = true;
    notifyListeners();
    final response = await DOVIAAPIOfferContextGroup.rejectOfferCall.call(
      offerId: offerId,
      authToken: currentAuthenticationToken ?? '',
      rejectedBy: 'CLIENT',
      reason: trimmedReason,
    );
    _isLoading = false;
    notifyListeners();

    if (response.succeeded) return const Success(true);
    return Failure(
      response.jsonBody?['message']?.toString() ??
          'No pudimos rechazar la contraoferta',
      statusCode: response.statusCode,
    );
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

  Map<String, dynamic>? _extractObject(dynamic jsonBody) {
    if (jsonBody is! Map) return null;
    final body = Map<String, dynamic>.from(jsonBody);
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    final offer = body['offer'];
    if (offer is Map) return Map<String, dynamic>.from(offer);
    return body;
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
