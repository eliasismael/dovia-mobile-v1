import 'package:url_launcher/url_launcher.dart';

/// Abre [uri] con la aplicación que el sistema tenga para ese enlace y dice
/// si pudo.
///
/// El sondeo previo y el `try` no son de más: cuando en el dispositivo no hay
/// nada que atienda el enlace —un teléfono sin marcador, un PDF sin visor,
/// WhatsApp sin instalar— `launchUrl` lanza una excepción en vez de devolver
/// `false`, y adentro de un callback asíncrono eso no lo atrapa nadie: la
/// acción se muere en silencio y el usuario se queda mirando la pantalla.
Future<bool> openExternalUri(
  Uri? uri, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  if (uri == null) return false;
  try {
    if (!await canLaunchUrl(uri)) return false;
    return await launchUrl(uri, mode: mode);
  } catch (_) {
    return false;
  }
}

/// Chat de WhatsApp con [phone], o `null` si el número no sirve.
///
/// `wa.me` espera el número en dígitos, con el código de país y sin el `+`.
Uri? whatsAppUri(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? null : Uri.parse('https://wa.me/$digits');
}

/// Llamada telefónica a [phone], o `null` si no hay número.
///
/// Se arma por partes en vez de parsear un texto: un número con espacios o
/// paréntesis rompe `Uri.parse`.
Uri? telUri(String phone) {
  final trimmed = phone.trim();
  return trimmed.isEmpty ? null : Uri(scheme: 'tel', path: trimmed);
}
