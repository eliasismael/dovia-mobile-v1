/// Apertura del checkout de Recurrente para los cobros de Dovia Home.
///
/// Los dos flujos que cobran de verdad —materiales extra y trabajo fuera de
/// alcance— siguen el mismo contrato: el endpoint de aceptación crea la orden y
/// devuelve un `PaymentOrderResponseDto` con `checkoutUrl`, y el pago sólo se
/// completa si el cliente abre esa URL. Aceptar **no** paga: deja la solicitud
/// en `PAYMENT_PENDING` hasta que el webhook confirme.
///
/// Si el checkout se cae (EXPIRED / FAILED / CANCELED) no se repite la
/// aceptación: se reanuda la orden con `POST /payments/{paymentOrderId}/resume`,
/// que crea una sucesora y reemplaza sólo el `paymentOrderId`. Repetir `accept`
/// sobre una solicitud que ya está en `PAYMENT_PENDING` es un estado inválido.
library;

import 'package:url_launcher/url_launcher.dart';

/// Abre [checkoutUrl] en el navegador externo.
///
/// Devuelve `false` si la URL no es utilizable o el sistema no pudo abrirla, para
/// que la pantalla lo diga en vez de dar el pago por encaminado. Se usa
/// [LaunchMode.externalApplication] porque el checkout es un flujo de pago de
/// terceros: dentro de una webview embebida pierde cookies y métodos de pago
/// guardados.
Future<bool> launchDoviaHomeCheckout(String? checkoutUrl) =>
    _launchExternal(checkoutUrl);

/// Abre un PDF del flujo (cotización de materiales, propuesta de un proveedor)
/// en el visor del sistema. Mismo transporte que el checkout, distinto propósito.
Future<bool> launchDoviaHomeDocument(String? documentUrl) =>
    _launchExternal(documentUrl);

Future<bool> _launchExternal(String? url) async {
  final raw = url?.trim();
  if (raw == null || raw.isEmpty) return false;

  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasScheme) return false;

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
