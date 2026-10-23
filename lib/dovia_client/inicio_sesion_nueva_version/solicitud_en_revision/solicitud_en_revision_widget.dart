import '/auth/custom_auth/auth_util.dart';
import '/auth/registration_progress.dart';
import '/auth/sign_out.dart';
import '/backend/api_requests/api_users.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/shared_components/dovia_spinner.dart';

/// Asociado que ya envió todo su registro y espera la aprobación de DOVIA.
///
/// Antes, al enviar el formulario (o al iniciar sesión sin estar aprobado) se
/// cerraba la sesión y la app volvía al login cada vez que se abría. Ahora la
/// sesión queda abierta y esta pantalla es su inicio hasta que el backend lo
/// marque activo: se consulta al entrar, al volver la app del fondo y con
/// "Actualizar estado". Aprobado, pasa directo a su home.
class SolicitudEnRevisionWidget extends StatefulWidget {
  const SolicitudEnRevisionWidget({super.key});

  static String routeName = 'SolicitudEnRevision';
  static String routePath = '/solicitudEnRevision';

  @override
  State<SolicitudEnRevisionWidget> createState() =>
      _SolicitudEnRevisionWidgetState();
}

class _SolicitudEnRevisionWidgetState extends State<SolicitudEnRevisionWidget>
    with WidgetsBindingObserver {
  bool _checking = true;
  bool _checkFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkStatus();
  }

  /// Consulta si DOVIA ya aprobó la cuenta: `verified` en el perfil (lo pone
  /// en true HQ Admin con `POST /admin/users/{id}/verify`). No es `active`,
  /// que indica cuenta deshabilitada.
  Future<void> _checkStatus() async {
    if (!mounted) return;
    setState(() {
      _checking = true;
      _checkFailed = false;
    });
    final call = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall;
    final response = await call.call(authToken: currentAuthenticationToken);
    if (!mounted) return;

    if (response.succeeded && call.isVerified(response.jsonBody) == true) {
      final role = call.userRole(response.jsonBody);
      if (role != null && role.isNotEmpty) FFAppState().UserRole = role;
      await RegistrationProgress.clear();
      if (!mounted) return;
      context.goNamed(homeRouteNameForRole(FFAppState().UserRole));
      return;
    }

    setState(() {
      _checking = false;
      _checkFailed = !response.succeeded;
    });
  }

  Future<void> _signOut() async {
    await RegistrationProgress.clear();
    if (!mounted) return;
    await signOutAndGoToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
          fontSize: 22.0,
          color: const Color(0xFF00444B),
          letterSpacing: 0.0,
        );
    final bodyStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.publicSans(fontWeight: FontWeight.normal),
          fontSize: 14.0,
          letterSpacing: 0.0,
          lineHeight: 1.4,
        );

    // Es el inicio de la app mientras dure la revisión: no hay pantalla a la
    // que volver.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: Stack(
            children: [
              const CornerGradientBackgroundWidget(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/D-verde.svg',
                          width: 56.0,
                          height: 72.0,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24.0),
                        Text(
                          'Tu solicitud está en revisión',
                          textAlign: TextAlign.center,
                          style: titleStyle,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Ya recibimos tus datos y documentos. El equipo de '
                          'DOVIA se comunicará contigo a la brevedad para '
                          'continuar con el proceso de incorporación. Cuando '
                          'aprueben tu cuenta vas a entrar directo a tu inicio.',
                          textAlign: TextAlign.center,
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 28.0),
                        // Mientras se consulta solo se ve el spinner: los
                        // botones no aparecen un instante para desaparecer si
                        // la cuenta ya estaba aprobada.
                        if (_checking)
                          const SizedBox(
                            height: 42.0,
                            child: Center(
                              child: DoviaSpinner(),
                            ),
                          )
                        else ...[
                          if (_checkFailed)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E8),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                'No pudimos consultar el estado de tu '
                                'solicitud. Revisa tu conexión e inténtalo de '
                                'nuevo.',
                                textAlign: TextAlign.center,
                                style: bodyStyle.copyWith(fontSize: 13.0),
                              ),
                            ),
                          FFButtonWidget(
                            onPressed: _checkStatus,
                            text: 'Actualizar estado',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 42.0,
                              color: const Color(0xFF007376),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.publicSans(),
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextButton(
                            onPressed: _signOut,
                            child: Text(
                              'Cerrar sesión',
                              style: GoogleFonts.publicSans(
                                color: const Color(0xFF007376),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
