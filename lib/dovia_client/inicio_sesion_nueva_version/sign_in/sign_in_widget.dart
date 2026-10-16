import '/backend/api_requests/api_config.dart';
import '/auth/post_login_navigation.dart';
import '/auth/pending_associate_role.dart';
import '/auth/custom_auth/auth_util.dart';
import '/auth/custom_auth/token_refresher.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import '/auth/google/google_button_label.dart';
import '/auth/google/google_sign_in_flow.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_in_model.dart';
export 'sign_in_model.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  static String routeName = 'SignIn';
  static String routePath = '/signIn';

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  bool _googleBusy = false;

  /// "Continuar con Google": Cognito en el navegador del sistema.
  Widget _googleButton(Widget child) => Tooltip(
        message: 'Continuar con Google',
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: _googleBusy
              ? null
              : () async {
                  setState(() => _googleBusy = true);
                  try {
                    await continueWithGoogle(context,
                        intent: GoogleAuthIntent.signIn);
                  } finally {
                    if (mounted) setState(() => _googleBusy = false);
                  }
                },
          child: child,
        ),
      );
  late SignInModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignInModel());

    _model.correoInputTextController ??= TextEditingController();
    _model.correoInputFocusNode ??= FocusNode();

    _model.passwordInputTextController ??= TextEditingController();
    _model.passwordInputFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: Stack(
          children: [
            wrapWithModel(
              model: _model.cornerGradientBackgroundModel,
              updateCallback: () => safeSetState(() {}),
              child: const CornerGradientBackgroundWidget(),
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: // El contenido ocupa al menos el alto de la pantalla (con el bloque
                    // de registro abajo) y solo scrollea si no entra: antes, con
                    // márgenes fijos, sobraban unos píxeles y había scroll de más.
                    LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      // Sin IntrinsicHeight: con las fuentes reales medía
                      // unos píxeles menos que el contenido y el pie
                      // desbordaba. El bloque de registro va pegado al botón
                      // de Google, no al fondo de la pantalla.
                      child: SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 40.0, 0.0, 0.0),
                                  child: Container(
                                    decoration: const BoxDecoration(),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: SvgPicture.asset(
                                        'assets/images/D-verde.svg',
                                        width: 52.0,
                                        height: 68.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                // Entorno de la API (sólo fuera de producción), para no
                                // confundir una build de dev con una de staging.
                                if (kApiEnvLabel.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 3.0),
                                      decoration: BoxDecoration(
                                        color: kApiEnvLabel == 'DEV'
                                            ? const Color(0xFFFFEAD6)
                                            : const Color(0xFFE0E7FF),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Text(
                                        kApiEnvLabel,
                                        style: GoogleFonts.publicSans(
                                          color: kApiEnvLabel == 'DEV'
                                              ? const Color(0xFFB45309)
                                              : const Color(0xFF4F46E5),
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 24.0, 0.0, 0.0),
                                  child: Text(
                                    'Ingresa a tu cuenta',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: const Color(0xFF00444B),
                                          fontSize: 26.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                                // Deja que el gestor de contraseñas complete y guarde
                                // los datos de acceso.
                                AutofillGroup(
                                  child: Form(
                                    key: _model.formKey,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                            child: Text(
                                              'Correo',
                                              textAlign: TextAlign.start,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.publicSans(
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
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                controller: _model
                                                    .correoInputTextController,
                                                focusNode:
                                                    _model.correoInputFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                obscureText: false,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                autocorrect: false,
                                                textInputAction:
                                                    TextInputAction.next,
                                                autofillHints: const [
                                                  AutofillHints.email,
                                                  AutofillHints.username,
                                                ],
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText:
                                                      'ex: jon.smith@email.com',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .correoInputTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 14.0, 0.0, 0.0),
                                            child: Text(
                                              'Contraseña',
                                              textAlign: TextAlign.start,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font:
                                                        GoogleFonts.publicSans(
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
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -1.0, 0.0),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              child: TextFormField(
                                                controller: _model
                                                    .passwordInputTextController,
                                                focusNode: _model
                                                    .passwordInputFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                autofillHints: const [
                                                  AutofillHints.password,
                                                ],
                                                obscureText: !_model
                                                    .passwordInputVisibility,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: '************',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                  suffixIcon: InkWell(
                                                    onTap: () async {
                                                      safeSetState(() => _model
                                                              .passwordInputVisibility =
                                                          !_model
                                                              .passwordInputVisibility);
                                                    },
                                                    focusNode: FocusNode(
                                                        skipTraversal: true),
                                                    child: Icon(
                                                      _model.passwordInputVisibility
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
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
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .passwordInputTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            context.pushNamed(
                                                RecoverPasswordStep1Widget
                                                    .routeName);
                                          },
                                          child: Text(
                                            '¿Olvidaste tu contraseña?',
                                            textAlign: TextAlign.center,
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
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (_model.invalidMailOrPassword) {
                                      return Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                        child: Text(
                                          _model.signInError ?? '',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.publicSans(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: 0.0,
                                        height: 0.0,
                                        decoration: const BoxDecoration(),
                                      );
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 0.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      _model.invalidMailOrPassword = false;
                                      safeSetState(() {});
                                      _model.resultForm = true;
                                      if (_model.formKey.currentState == null ||
                                          !_model.formKey.currentState!
                                              .validate()) {
                                        _model.resultForm = false;
                                      }
                                      if (_model.resultForm!) {
                                        _model.apiResultbr7 =
                                            await DOVIAAPIAuthContextGroup
                                                .signInNEWCall
                                                .call(
                                          email: _model
                                              .correoInputTextController.text
                                              .trim(),
                                          password: _model
                                              .passwordInputTextController.text,
                                        );

                                        if ((_model.apiResultbr7?.succeeded ??
                                            true)) {
                                          // El inicio de sesión se apila sobre esta
                                          // pantalla, que sigue viva: sin esto, al
                                          // cerrar sesión volvía con el correo y la
                                          // contraseña del usuario anterior escritos.
                                          TextInput.finishAutofillContext();
                                          final signedInEmail = _model
                                              .correoInputTextController.text
                                              .trim();
                                          _model.correoInputTextController
                                              ?.clear();
                                          _model.passwordInputTextController
                                              ?.clear();
                                          final idToken =
                                              DOVIAAPIAuthContextGroup
                                                  .signInNEWCall
                                                  .idToken(
                                            (_model.apiResultbr7?.jsonBody ??
                                                ''),
                                          );
                                          FFAppState().UserEmail =
                                              signedInEmail;
                                          if (!context.mounted) return;
                                          GoRouter.of(context)
                                              .prepareAuthEvent();
                                          // Sin el uid, `currentUserUid` quedaba vacío:
                                          // fallaba la subida de documentos del registro
                                          // de asociado y todo lo que se guarda por
                                          // usuario se mezclaba entre cuentas.
                                          await authManager.signIn(
                                            authenticationToken: idToken,
                                            refreshToken:
                                                DOVIAAPIAuthContextGroup
                                                    .signInNEWCall
                                                    .refreshToken(
                                              (_model.apiResultbr7?.jsonBody ??
                                                  ''),
                                            ),
                                            tokenExpiration:
                                                tokenExpirationFrom(
                                              DOVIAAPIAuthContextGroup
                                                  .signInNEWCall
                                                  .expiresIn(_model
                                                      .apiResultbr7?.jsonBody),
                                            ),
                                            authUid: DOVIAAPIAuthContextGroup
                                                .signInNEWCall
                                                .userId(_model
                                                    .apiResultbr7?.jsonBody),
                                          );

                                          _model.apiResultProfile =
                                              await DOVIAAPIUserContextGroup
                                                  .getAuthenticatedUserProfileCall
                                                  .call(
                                            authToken: idToken,
                                          );

                                          // Respaldo por si el sign-in no trae el id.
                                          final profileUid =
                                              DOVIAAPIUserContextGroup
                                                  .getAuthenticatedUserProfileCall
                                                  .userId(_model
                                                      .apiResultProfile
                                                      ?.jsonBody);
                                          if ((authManager.uid ?? '').isEmpty &&
                                              profileUid != null &&
                                              profileUid.isNotEmpty) {
                                            authManager.updateAuthUserData(
                                              authenticationToken: authManager
                                                  .authenticationToken,
                                              refreshToken:
                                                  authManager.refreshToken,
                                              tokenExpiration:
                                                  authManager.tokenExpiration,
                                              authUid: profileUid,
                                            );
                                          }

                                          if (!context.mounted) return;
                                          final signInBody =
                                              _model.apiResultbr7?.jsonBody ??
                                                  '';
                                          final signInCall =
                                              DOVIAAPIAuthContextGroup
                                                  .signInNEWCall;
                                          await navigateAfterSignIn(
                                            context,
                                            profileBody: _model
                                                .apiResultProfile?.jsonBody,
                                            roleSelected: signInCall
                                                .isRoleSelected(signInBody),
                                            associateProfileComplete: signInCall
                                                .isAssociateProfileComplete(
                                                    signInBody),
                                            verified:
                                                signInCall.verified(signInBody),
                                          );
                                        } else {
                                          // Error en texto rojo bajo el form, sin dialog con el JSON.
                                          final status =
                                              _model.apiResultbr7?.statusCode ??
                                                  0;
                                          // 403 USER_DISABLED: cuenta deshabilitada o
                                          // suspendida. Antes caía en el mensaje de
                                          // "intenta en unos minutos", que no se arregla
                                          // esperando.
                                          _model.signInError = status == 403
                                              ? 'Tu cuenta está deshabilitada o suspendida.\nSi crees que es un error, contacta a soporte.'
                                              : (status == 400 ||
                                                      status == 401 ||
                                                      status == 404)
                                                  ? 'Correo o contraseña incorrectos.\nPor favor, verifica tus datos e Inténtalo nuevamente.'
                                                  : 'No pudimos iniciar sesión. Intenta de nuevo en unos minutos.';
                                          _model.invalidMailOrPassword = true;
                                          safeSetState(() {});
                                        }
                                      }

                                      safeSetState(() {});
                                    },
                                    text: 'Inicia sesión',
                                    options: FFButtonOptions(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 42.0,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 10.0, 20.0, 10.0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: const Color(0xFF007376),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.publicSans(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 16.0, 0.0, 0.0),
                                  child: _googleButton(
                                    Container(
                                      height: 42.0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F4F4),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: const GoogleButtonLabel(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 32.0, 0.0, 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '¿Todavía no tienes cuenta?',
                                    style: GoogleFonts.publicSans(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  _footerLink('Ingresa como visita', () {
                                    FFAppState().UserRole = Roles.VISITOR.name;
                                    context.goNamed(
                                        DOVIACLIENTHomePageWidget.routeName);
                                  }),
                                  _footerDivider(),
                                  _footerLink(
                                    'Regístrate como usuario',
                                    () {
                                      PendingAssociateRole.clear();
                                      context.pushNamed(
                                          CreateAccountWidget.routeName);
                                    },
                                  ),
                                  _footerDivider(),
                                  _footerLink(
                                    'Regístrate como asociado',
                                    () => context.pushNamed(
                                        ElegirRolAsociadoWidget.routeName),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback onTap) => InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            text,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF007376),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  Widget _footerDivider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Row(
          children: [
            Expanded(
                child: Divider(
                    height: 12.0, thickness: 1.0, color: Color(0xFFD9D9D9))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('o', style: TextStyle(color: Color(0xFF8A8A8A))),
            ),
            Expanded(
                child: Divider(
                    height: 12.0, thickness: 1.0, color: Color(0xFFD9D9D9))),
          ],
        ),
      );
}
