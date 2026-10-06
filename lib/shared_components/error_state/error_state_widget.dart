import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_manager.dart';
import '/core/api_error.dart';

/// Si una carga falló por algo que el usuario puede reintentar: sin conexión
/// (o timeout) o error del servidor. Un 401/404 no cuenta: en varias listas
/// significa "no hay nada" (o un visitante sin sesión) y se sigue mostrando
/// el estado vacío.
///
/// Sin sesión (visitante) tampoco: en web los 401 llegan como error de red
/// (API Gateway no les pone CORS) y el visitante veía "Sin conexión".
bool isRetryableLoadError(ApiCallResponse response) =>
    loggedIn && (response.statusCode == -1 || response.statusCode >= 500);

/// Aviso de carga fallida con botón para reintentar. Antes esas pantallas
/// mostraban el estado vacío ("Aún no tienes…") y el usuario creía que no
/// tenía datos.
///
/// Sin ícono ni borde, como el resto de los avisos de la app: fondo suave y
/// texto.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// Arma el aviso a partir de la respuesta fallida.
  factory ErrorStateWidget.fromResponse(
    ApiCallResponse response, {
    Key? key,
    VoidCallback? onRetry,
  }) =>
      ErrorStateWidget(
        key: key,
        message: apiErrorMessage(
            response, 'No pudimos cargar la información. Inténtalo de nuevo.'),
        onRetry: onRetry,
      );

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                color: const Color(0xFF7A2E2E),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF007376),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
