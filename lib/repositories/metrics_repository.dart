import 'package:flutter/foundation.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_metrics.dart';
import '/core/result.dart';

class MetricsRepository extends ChangeNotifier {
  /// Tracks a property view.
  Future<Result<bool>> trackPropertyView(String propertyId) async {
    final token = currentAuthenticationToken ?? '';
    if (token.isEmpty) return const Failure('No autenticado');

    final response =
        await DOVIAAPIMetricsContextGroup.trackPropertyViewCall.call(
      propertyId: propertyId,
      bearerAuth: token,
    );

    if (!response.succeeded) {
      return Failure('Error al registrar vista',
          statusCode: response.statusCode);
    }
    return const Success(true);
  }

  /// Tracks a property interaction.
  Future<Result<bool>> trackPropertyInteraction(String propertyId) async {
    final token = currentAuthenticationToken ?? '';
    if (token.isEmpty) return const Failure('No autenticado');

    final response =
        await DOVIAAPIMetricsContextGroup.trackPropertyInteractionCall.call(
      propertyId: propertyId,
      bearerAuth: token,
    );

    if (!response.succeeded) {
      return Failure('Error al registrar interacción',
          statusCode: response.statusCode);
    }
    return const Success(true);
  }

  /// Gets the statistics for a property.
  Future<Result<Map<String, dynamic>>> getPropertyStatistics(
      String propertyId) async {
    final token = currentAuthenticationToken ?? '';
    if (token.isEmpty) return const Failure('No autenticado');

    final response =
        await DOVIAAPIMetricsContextGroup.getPropertyStatisticsCall.call(
      propertyId: propertyId,
      bearerAuth: token,
    );

    if (!response.succeeded) {
      return Failure('Error al obtener estadísticas',
          statusCode: response.statusCode);
    }

    final data = response.jsonBody?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const Failure('Respuesta inesperada del servidor');
    }

    return Success(data);
  }
}
