/// Apertura del checkout de Recurrente para los cobros de Dovia Home.
///
/// El flujo que cobra por acá es el de **materiales extra**: el endpoint de
/// aceptación crea la orden y devuelve un `PaymentOrderResponseDto` con
/// `checkoutUrl`, y el pago sólo se completa si el cliente abre esa URL.
/// Aceptar **no** paga: deja la solicitud en `PAYMENT_PENDING` hasta que el
/// webhook confirme.
///
/// El trabajo **fuera de alcance no cobra por la plataforma**: aceptar una
/// propuesta es la autorización de negocio, reserva el trabajo en el acto y
/// deja su `payment` en `NOT_REQUIRED`. Su respuesta no trae `checkoutUrl`, así
/// que no hay checkout que abrir ahí.
///
/// Si el checkout se cae (EXPIRED / FAILED / CANCELED) no se repite la
/// aceptación: se reanuda la orden con `POST /payments/{paymentOrderId}/resume`,
/// que crea una sucesora y reemplaza sólo el `paymentOrderId`. Repetir `accept`
/// sobre una solicitud que ya está en `PAYMENT_PENDING` es un estado inválido.
library;

import 'package:url_launcher/url_launcher.dart';

/// Abre [checkoutUrl] en el navegador del sistema **dentro de la app**
/// (Custom Tabs en Android, SFSafariViewController en iOS), así el cliente no
/// sale de DOVIA para pagar.
///
/// Devuelve `false` si la URL no es utilizable o el sistema no pudo abrirla, para
/// que la pantalla lo diga en vez de dar el pago por encaminado. No se usa una
/// webview embebida porque el checkout es un flujo de pago de terceros: ahí
/// pierde cookies, métodos de pago guardados y Apple Pay/Google Pay.
Future<bool> launchDoviaHomeCheckout(String? checkoutUrl) =>
    _launch(checkoutUrl, LaunchMode.inAppBrowserView);

/// Cierra el checkout cuando el pago ya se resolvió. Sólo iOS lo permite; en
/// Android el cliente lo cierra con la X y debajo encuentra la app al día.
Future<void> closeDoviaHomeCheckout() async {
  try {
    if (await supportsCloseForLaunchMode(LaunchMode.inAppBrowserView)) {
      await closeInAppWebView();
    }
  } catch (_) {
    // Nada abierto o plataforma sin soporte: no hay nada que cerrar.
  }
}

/// Abre un PDF del flujo (cotización de materiales, propuesta de un proveedor)
/// en el visor del sistema. Mismo transporte que el checkout, distinto propósito.
Future<bool> launchDoviaHomeDocument(String? documentUrl) =>
    _launch(documentUrl, LaunchMode.externalApplication);

Future<bool> _launch(String? url, LaunchMode mode) async {
  final raw = url?.trim();
  if (raw == null || raw.isEmpty) return false;

  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasScheme) return false;

  try {
    return await launchUrl(uri, mode: mode);
  } catch (_) {
    return false;
  }
}
