import '/auth/sign_out.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Datos personales de quien entró con Google y todavía no tiene cuenta en
/// Dovia: el mismo formulario del registro, sin correo ni contraseña (los da
/// Google). Al enviarlo se hace el alta federada y sigue el registro normal
/// (identificación, términos y rol).
class GoogleDatosWidget extends StatefulWidget {
  const GoogleDatosWidget({super.key});

  static String routeName = 'GoogleDatos';
  static String routePath = '/googleDatos';

  @override
  State<GoogleDatosWidget> createState() => _GoogleDatosWidgetState();
}

class _GoogleDatosWidgetState extends State<GoogleDatosWidget> {
  /// La sesión de Google ya está abierta: salir la cierra, y la cuenta no se
  /// crea hasta que vuelva a entrar con Google.
  Future<void> _confirmExit() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('¿Salir del registro?',
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w600, color: const Color(0xFF00444B))),
        content: Text(
          'Tu cuenta no se creará. Puedes volver a registrarte con Google '
          'cuando quieras.',
          style: GoogleFonts.publicSans(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Seguir completando',
                style: GoogleFonts.publicSans(color: const Color(0xFF007376))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Salir',
                style: GoogleFonts.publicSans(
                    color: const Color(0xFF007376),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (exit != true || !mounted) return;
    // Todavía no tiene usuario en Dovia: no hay sesiones del backend que
    // revocar.
    await signOutAndGoToLogin(context, revokeSessions: false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                const custom_widgets.CustomDatosWidget(googleAccount: true),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: IconButton(
                    tooltip: 'Salir del registro',
                    onPressed: _confirmExit,
                    icon: SvgPicture.asset(
                      'assets/images/IconoVolverAtras.svg',
                      fit: BoxFit.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
