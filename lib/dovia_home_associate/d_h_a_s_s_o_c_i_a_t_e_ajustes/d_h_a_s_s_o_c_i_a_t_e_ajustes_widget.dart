import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_auth.dart';
import '/backend/api_requests/api_users.dart';
import '/dovia_home_associate/associate_role.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/repositories/user_repository.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_ajustes_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_ajustes_model.dart';

/// Ajustes del Dovia Home Associate.
///
/// El cuerpo es [custom_widgets.OperativeListingProfile], el mismo componente
/// que ya usan los ajustes del resto de los perfiles de asociado (Legal
/// Associate, Legal HQ, Listing HQ, Operative Listing y Showing). Trae las dos
/// pestañas del diseño y todo lo que cuelga de ellas:
///
///   - **Perfil y seguridad**: foto y rol, "Datos personales" (nombre,
///     nacionalidad, sexo, edad, correo, teléfono y perímetro de trabajo),
///     "Ganancias" (lo ganado y las estrellas, de
///     `GET /users/me/performance-summary`), "Documentación" (ID y antecedentes,
///     contra `POST /users/{id}/documents/{tipo}`), cambio de contraseña,
///     soporte y legal, y las acciones críticas.
///   - **Configuración de notificaciones**: los cinco avisos con su switch.
///
/// Se reutiliza en vez de reimplementarlo porque el perfil del asociado es el
/// mismo en todos los verticales —los datos salen de `GET /users/me`, no del
/// contexto de Dovia Home— y tener dos pantallas de ajustes que editan el mismo
/// perfil era la forma segura de que un día dejaran de coincidir.
///
/// Lo que sí es propio de Dovia Home es el chrome: cabecera, fondo y barra
/// inferior de este vertical.
class DHASSOCIATEAjustesWidget extends StatefulWidget {
  const DHASSOCIATEAjustesWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_Ajustes';
  static String routePath = '/dHASSOCIATEAjustes';

  @override
  State<DHASSOCIATEAjustesWidget> createState() =>
      _DHASSOCIATEAjustesWidgetState();
}

class _DHASSOCIATEAjustesWidgetState extends State<DHASSOCIATEAjustesWidget> {
  late DHASSOCIATEAjustesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATEAjustesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Cierra la sesión en el backend y vuelve al inicio de la app.
  ///
  /// El perfil cacheado se limpia **antes** de navegar: es el mismo
  /// [UserRepository] para toda la app y dejarlo con los datos del asociado
  /// anterior se los mostraría a quien inicie sesión después.
  Future<void> _signOut() async {
    final router = GoRouter.of(context);
    context.read<UserRepository>().clear();
    await DOVIAAPIAuthContextGroup.logoutAllCall
        .call(idToken: authManager.authenticationToken);
    router.prepareAuthEvent();
    await authManager.signOut();
    router.clearRedirectLocation();
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    context.goNamedAuth(QueEsDoviaWidget.routeName, mounted);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    wrapWithModel(
                      model: _model.dHASSOCIATEHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATEHeaderWidget(
                        tittleText: 'Ajustes',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 24.0, 20.0, 120.0),
                      child: custom_widgets.OperativeListingProfile(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        // Sin alto fijo: el componente se mide por su
                        // contenido y las secciones desplegables lo cambian
                        // al abrirse.
                        height: null,
                        // El componente es compartido con otros verticales y
                        // por defecto trae la píldora de "Operative Listing";
                        // acá va la del rol real en sesión.
                        roleLabel: isHomeAssociateCompany()
                            ? 'Empresa Asociada Dovia Home'
                            : 'Asociado Dovia Home',
                        onTermsAndConditions: () async {},
                        onSupport: () async {},
                        onLogout: _signOut,
                        onDeleteAccount: (reason) async {
                          await DOVIAAPIUserContextGroup.deactivateMyAccountCall
                              .call(
                            authToken: authManager.authenticationToken,
                            reason: reason,
                          );
                        },
                        onSaveInfo: () async {},
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 5.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dHASSOCIATENavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DHASSOCIATENavbarWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
