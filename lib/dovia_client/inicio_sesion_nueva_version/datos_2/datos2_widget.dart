import '/auth/custom_auth/token_refresher.dart';
import '/auth/registration_progress.dart';
import '/backend/api_requests/api_users.dart';
import '/auth/pending_associate_role.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/terminos_y_condiciones_scrolleable_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/terminos_condiciones/terminos_condiciones_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'datos2_model.dart';
export 'datos2_model.dart';

class Datos2Widget extends StatefulWidget {
  const Datos2Widget({super.key});

  static String routeName = 'Datos_2';
  static String routePath = '/datos2';

  @override
  State<Datos2Widget> createState() => _Datos2WidgetState();
}

class _Datos2WidgetState extends State<Datos2Widget> {
  late Datos2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _enviando = false;

  /// Sólo al retomar el registro después de cerrar la app: correo con el que
  /// se estaba registrando y opción de empezar con otro.
  bool _resumed = false;
  String _resumeEmail = '';

  /// Rol de asociado guardado al elegirlo antes de registrarse; null = cliente.
  String? _resumeRole;

  static String _roleLabel(String? role) => switch (role) {
        'SHOWING_AGENT' => 'Showing Associate',
        'HOME_ASSOCIATE' => 'Home Associate',
        'LEGAL_ASSOCIATE' => 'Legal Associate',
        'OPERATIVE_LISTER' => 'Lister Associate',
        null => 'cliente',
        _ => 'asociado',
      };

  Future<void> _loadResumeEmail() async {
    final role = await PendingAssociateRole.get();
    if (mounted) safeSetState(() => _resumeRole = role);
    final res = await DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall
        .call(authToken: currentAuthenticationToken);
    final email = res.succeeded
        ? getJsonField(res.jsonBody, r'$.data.email')?.toString()
        : null;
    if (!mounted) return;
    safeSetState(() => _resumeEmail =
        (email != null && email.isNotEmpty) ? email : FFAppState().UserEmail);
  }

  /// Descarta el registro a medias y vuelve a crear la cuenta con otro correo.
  /// El rol de asociado elegido se conserva: sólo cambia el correo.
  Future<void> _registerWithOtherEmail({bool asClient = false}) async {
    await RegistrationProgress.clear();
    // "Como cliente": descarta el rol de asociado y el registro sigue como
    // cliente.
    if (asClient) await PendingAssociateRole.clear();
    await authManager.signOut();
    if (!mounted) return;
    context.goNamedAuth(CreateAccountWidget.routeName, context.mounted);
  }

  String? _error;

  Future<void> _continuarComoCliente() async {
    setState(() {
      _enviando = true;
      _error = null;
    });

    // Si eligió un rol de asociado antes de registrarse, la solicitud va acá.
    final pendingRole = await PendingAssociateRole.get();
    final role = pendingRole ?? 'CLIENT';
    final res = await DOVIAAPIAuthContextGroup.selectRoleCall.call(
      role: role,
      authToken: currentAuthenticationToken,
    );

    // 409: el rol ya estaba elegido (retomó el registro después de cerrar la
    // app en este paso); se sigue con la identificación.
    if (!res.succeeded && res.statusCode != 409) {
      safeSetState(() {
        _enviando = false;
        _error = 'No pudimos continuar. Intenta de nuevo.';
      });
      return;
    }

    String? newToken =
        DOVIAAPIAuthContextGroup.selectRoleCall.idToken(res.jsonBody);
    String? newRefreshToken =
        DOVIAAPIAuthContextGroup.selectRoleCall.refreshToken(res.jsonBody);

    if (newToken != null && newToken.isNotEmpty) {
      authManager.updateAuthUserData(
        authenticationToken: newToken,
        refreshToken: newRefreshToken ?? currentAuthRefreshToken,
        tokenExpiration: currentAuthTokenExpiration,
        authUid: currentUserUid,
      );
    } else {
      // Sin tokens en la respuesta (siempre con Google): se renuevan según la
      // sesión, con la API o directo en Cognito, para que traigan el rol.
      newToken = await refreshSession();
    }

    if (newToken != null && newToken.isNotEmpty) {
      FFAppState().UserRole = role;
      FFAppState().update(() {});
    }

    // La identificación se sube a su documento del perfil
    // (POST /users/{id}/documents/identification-document).
    final idPhoto = _model.uploadedLocalFile_uploadData5so;
    if (idPhoto.bytes != null && idPhoto.bytes!.isNotEmpty) {
      final up = await DOVIAAPIUserContextGroup.uploadUserDocumentCall.call(
        userId: currentUserUid,
        documentType: 'identification-document',
        authToken: currentAuthenticationToken,
        file: idPhoto,
      );
      if (!up.succeeded) {
        final m = getJsonField(up.jsonBody, r'$.message')?.toString();
        safeSetState(() {
          _enviando = false;
          _error = (m != null && m.isNotEmpty)
              ? 'No pudimos subir tu identificación: $m'
              : 'No pudimos subir tu identificación. Intenta de nuevo.';
        });
        return;
      }
      RegistrationIdDocument.uploaded = idPhoto;
    }

    if (!mounted) return;
    safeSetState(() => _enviando = false);
    // goNamed: el paso ya hecho sale de la pila y no se puede volver.
    if (pendingRole != null) {
      await RegistrationProgress.set(RegistrationProgress.associateForm);
      await PendingAssociateRole.clear();
      if (!mounted) return;
      // Sigue el flujo normal del asociado: formulario y "solicitud en
      // revisión".
      context.goNamed(FormAssociateWidget.routeName);
      return;
    }
    await RegistrationProgress.clear();
    if (!mounted) return;
    context.goNamed(Datos3NewWidget.routeName);
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Datos2Model());
    if (RegistrationProgress.resumedAfterRestart) {
      RegistrationProgress.resumedAfterRestart = false;
      _resumed = true;
      _loadResumeEmail();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: const BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          decoration: const BoxDecoration(),
                          // Logo alineado a la izquierda, con el mismo margen
                          // que el título.
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                28.0, 48.0, 0.0, 0.0),
                            child: SvgPicture.asset(
                              'assets/images/D-verde.svg',
                              width: 48.0,
                              height: 61.4,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 54.0, 0.0, 0.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              decoration: const BoxDecoration(),
                              alignment: const AlignmentDirectional(0.0, -1.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Completa los datos',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            fontSize: 26.7,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(),
                                      child: Align(
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 19.0, 0.0, 0.0),
                                              child: Text(
                                                'Sube tu identificación o pasaporte',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 12.0, 0.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final selectedMedia =
                                                      await selectMediaWithSourceBottomSheet(
                                                    context: context,
                                                    allowPhoto: true,
                                                    pickerFontFamily:
                                                        'Public Sans',
                                                  );
                                                  if (selectedMedia != null &&
                                                      selectedMedia.every((m) =>
                                                          validateFileFormat(
                                                              m.storagePath,
                                                              context))) {
                                                    safeSetState(() => _model
                                                            .isDataUploading_uploadData5so =
                                                        true);
                                                    var selectedUploadedFiles =
                                                        <FFUploadedFile>[];

                                                    try {
                                                      selectedUploadedFiles =
                                                          selectedMedia
                                                              .map((m) =>
                                                                  FFUploadedFile(
                                                                    name: m
                                                                        .storagePath
                                                                        .split(
                                                                            '/')
                                                                        .last,
                                                                    bytes:
                                                                        m.bytes,
                                                                    height: m
                                                                        .dimensions
                                                                        ?.height,
                                                                    width: m
                                                                        .dimensions
                                                                        ?.width,
                                                                    blurHash: m
                                                                        .blurHash,
                                                                    originalFilename:
                                                                        m.originalFilename,
                                                                  ))
                                                              .toList();
                                                    } finally {
                                                      _model.isDataUploading_uploadData5so =
                                                          false;
                                                    }
                                                    if (selectedUploadedFiles
                                                            .length ==
                                                        selectedMedia.length) {
                                                      safeSetState(() {
                                                        _model.uploadedLocalFile_uploadData5so =
                                                            selectedUploadedFiles
                                                                .first;
                                                      });
                                                    } else {
                                                      safeSetState(() {});
                                                      return;
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          1.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Builder(
                                                    builder: (context) {
                                                      if ((_model
                                                              .uploadedLocalFile_uploadData5so
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child: Image.memory(
                                                            _model.uploadedLocalFile_uploadData5so
                                                                    .bytes ??
                                                                Uint8List
                                                                    .fromList(
                                                                        []),
                                                            width: 200.0,
                                                            height: 200.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      } else {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/images/AddMediaImage.svg',
                                                            width: 200.0,
                                                            height: 200.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) => Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 19.0, 20.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                if (_model.terminosAceptados == false) {
                                  await showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            const AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(dialogContext)
                                                .unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.9,
                                            child:
                                                TerminosYCondicionesScrolleableWidget(
                                              onAccept: () async {
                                                _model.terminosAceptados = true;
                                                safeSetState(() {});
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  // Solo queda marcado si se leyó hasta el final y se tocó Aceptar;
// cerrar el modal con volver no lo marca.
                                  safeSetState(() {
                                    _model.checkboxValue =
                                        _model.terminosAceptados;
                                  });
                                } else {
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            const AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(dialogContext)
                                                .unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: SizedBox(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.5,
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.9,
                                            child:
                                                const TerminosCondicionesWidget(),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Theme(
                                    data: ThemeData(
                                      checkboxTheme: CheckboxThemeData(
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                        ),
                                      ),
                                      unselectedWidgetColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                    ),
                                    // El toque lo recibe la fila, que abre el modal de términos:
// la casilla no se puede marcar a mano.
                                    child: IgnorePointer(
                                      child: Checkbox(
                                        value: _model.terminosAceptados,
                                        onChanged: (_) {},
                                        side: const BorderSide(
                                          width: 2,
                                          color: Color(0xFF8A8A8A),
                                        ),
                                        fillColor:
                                            WidgetStateProperty.resolveWith(
                                          (states) => states.contains(
                                                  WidgetState.selected)
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : Colors.white,
                                        ),
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: RichText(
                                      textScaler:
                                          MediaQuery.of(context).textScaler,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Al aceptar, aceptas los ',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          const TextSpan(
                                            text: 'términos y condiciones',
                                            style: TextStyle(),
                                          )
                                        ],
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 18.0, 20.0, 25.0),
                          child: FFButtonWidget(
                            onPressed: (((_model.uploadedLocalFile_uploadData5so
                                            .bytes?.isEmpty ??
                                        true)) ||
                                    (_model.terminosAceptados == false) ||
                                    _enviando)
                                ? null
                                : _continuarComoCliente,
                            text: _enviando ? 'Enviando...' : 'Aceptar',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 40.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(25.0),
                              disabledColor:
                                  FlutterFlowTheme.of(context).accent1,
                            ),
                          ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 0.0, 20.0, 0.0),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: FlutterFlowTheme.of(context).error,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        if (_resumed) ...[
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 12.0, 20.0, 0.0),
                            child: Text(
                              _resumeEmail.isEmpty
                                  ? 'Estás continuando tu registro como ${_roleLabel(_resumeRole)}.'
                                  : 'Estás continuando tu registro como ${_roleLabel(_resumeRole)} con $_resumeEmail',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.publicSans(
                                color: const Color(0xFF6A6A6A),
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _enviando ? null : _registerWithOtherEmail,
                            child: Text(
                              'Registrarme con otro correo',
                              style: GoogleFonts.publicSans(
                                color: const Color(0xFF007376),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_resumeRole != null)
                            TextButton(
                              onPressed: _enviando
                                  ? null
                                  : () =>
                                      _registerWithOtherEmail(asClient: true),
                              child: Text(
                                'Registrarme como cliente con otro correo',
                                style: GoogleFonts.publicSans(
                                  color: const Color(0xFF007376),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
