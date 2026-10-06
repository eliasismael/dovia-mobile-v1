// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// CUSTOM RECOVER PASSWORD 2
// Importa este componente para que el modal de éxito funcione, o cámbialo por el tuyo.
import '/dovia_client/recover_password/password_successfully_changed/password_successfully_changed_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/core/api_error.dart';
import '/index.dart' show SignInWidget;
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRecoverPassword2 extends StatefulWidget {
  const CustomRecoverPassword2({
    super.key,
    this.width,
    this.height,
    this.email,
  });

  final double? width;
  final double? height;
  final String? email;

  @override
  State<CustomRecoverPassword2> createState() => _CustomRecoverPassword2State();
}

class _CustomRecoverPassword2State extends State<CustomRecoverPassword2> {
  final formKey = GlobalKey<FormState>();

  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;

  TextEditingController? passwordInputTextController;
  FocusNode? passwordInputFocusNode;

  TextEditingController? confirmPasswordInputTextController;
  FocusNode? confirmPasswordInputFocusNode;

  bool showPinError = false;
  bool checkboxValue = false;

  @override
  void initState() {
    super.initState();
    pinCodeController = TextEditingController();
    pinCodeFocusNode = FocusNode();

    passwordInputTextController = TextEditingController();
    passwordInputFocusNode = FocusNode();

    confirmPasswordInputTextController = TextEditingController();
    confirmPasswordInputFocusNode = FocusNode();

    pinCodeController!.addListener(_onFieldChanged);
    passwordInputTextController!.addListener(_onFieldChanged);
    confirmPasswordInputTextController!.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) safeSetState(() {});
  }

  @override
  void dispose() {
    pinCodeController?.removeListener(_onFieldChanged);
    passwordInputTextController?.removeListener(_onFieldChanged);
    confirmPasswordInputTextController?.removeListener(_onFieldChanged);

    pinCodeController?.dispose();
    passwordInputTextController?.dispose();
    confirmPasswordInputTextController?.dispose();
    super.dispose();
  }

  // Helpers de validación
  bool _isPasswordStrong(String val) {
    if (val.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(val)) return false;
    if (!RegExp(r'[0-9]').hasMatch(val)) return false;
    if (!RegExp(r'[!@#$%^&*()_+=\[\]{}|;:,.<>?\-]').hasMatch(val)) return false;
    return true;
  }

  bool get isFormValid {
    final pin = pinCodeController?.text ?? '';
    final pass = passwordInputTextController?.text ?? '';
    final confirm = confirmPasswordInputTextController?.text ?? '';
    if (pin.length < 6) return false;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(pass);
    final hasDigit = RegExp(r'[0-9]').hasMatch(pass);
    final hasSpecial =
        RegExp(r'[!@#$%^&*()_+=\[\]{}|;:,.<>?\-]').hasMatch(pass);
    if (pass.length < 8 || !hasUppercase || !hasDigit || !hasSpecial) {
      return false;
    }
    if (pass != confirm) return false;
    return true;
  }

  Future<void> _showInvalidOtpModal() async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Código inválido',
                style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
            'El código ingresado es inválido. Por favor revisa tu correo e intenta de nuevo.',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Aceptar',
                style: GoogleFonts.publicSans(
                    color: const Color(0xFF007376),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessModal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x4D000000),
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child:
                const PasswordSuccessfullyChangedWidget(), // Widget nativo referenciado arriba
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      // go y no push: con push, "atrás" desde el login volvía a esta pantalla.
      context.goNamed(SignInWidget.routeName);
    }
  }

  Future<void> _onSubmit() async {
    final pin = pinCodeController?.text ?? '';
    final pass = passwordInputTextController?.text ?? '';
    final confirm = confirmPasswordInputTextController?.text ?? '';

    if (pin.length < 6) return;
    if (!_isPasswordStrong(pass) || pass != confirm) {
      formKey.currentState?.validate();
      return;
    }

    final result =
        await DOVIAAPIAuthContextGroup.confirmForgotPasswordNEWCall.call(
      email: widget.email ?? '',
      code: pin,
      newPassword: pass,
      confirmNewPassword: confirm,
    );

    if (!mounted) return;
    if (result.succeeded) {
      await _showSuccessModal();
      return;
    }

    // Solo un código incorrecto o vencido se muestra como "código inválido" y
    // borra el PIN. Sin conexión, o si el backend rechaza la contraseña, el
    // código sigue sirviendo: se explica el motivo y se deja lo escrito.
    if (!_isCodeError(result)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiErrorMessage(
            result, 'No pudimos cambiar tu contraseña. Inténtalo de nuevo.')),
      ));
      return;
    }
    safeSetState(() => showPinError = true);
    await _showInvalidOtpModal();
    safeSetState(() {
      showPinError = false;
      pinCodeController?.clear();
    });
  }

  bool _isCodeError(ApiCallResponse result) {
    if (result.statusCode == -1 || result.statusCode >= 500) return false;
    final message = apiBodyMessage(result.jsonBody);
    // Sin mensaje, un 4xx se sigue tratando como código inválido (lo más
    // común en este paso).
    if (message == null) return true;
    return RegExp(r'code|c[oó]digo|mismatch|expired|venci', caseSensitive: false)
        .hasMatch(message);
  }

  /// Momento a partir del cual se puede volver a pedir el código.
  DateTime? _resendAvailableAt;

  Future<void> _onResendCode() async {
    if (widget.email == null || widget.email!.isEmpty) return;
    final now = DateTime.now();
    if (_resendAvailableAt != null && now.isBefore(_resendAvailableAt!)) {
      final seconds = _resendAvailableAt!.difference(now).inSeconds + 1;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Espera $seconds s para pedir otro código.'),
      ));
      return;
    }
    _resendAvailableAt = now.add(const Duration(seconds: 30));
    final res = await DOVIAAPIAuthContextGroup.forgotPasswordNEWCall
        .call(email: widget.email!);
    if (!mounted) return;
    // Antes se confirmaba el reenvío aunque la llamada hubiera fallado.
    if (!res.succeeded) {
      _resendAvailableAt = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiErrorMessage(
            res, 'No pudimos reenviar el código. Inténtalo de nuevo.')),
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Se reenvió el código a ${widget.email}',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF007376),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showPassword = checkboxValue;
    final bool buttonEnabled = isFormValid;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        width: widget.width ?? MediaQuery.sizeOf(context).width * 1.0,
        height: widget.height ?? MediaQuery.sizeOf(context).height * 1.0,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        child: Stack(
          children: [
            // BACKGROUND INLINED
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              decoration:
                  BoxDecoration(color: FlutterFlowTheme.of(context).alternate),
              child: Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(-1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset('assets/images/Ellipse_17.png',
                          width: 350.0, height: 350.0, fit: BoxFit.cover),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(1.0, -1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset('assets/images/Ellipse_16.png',
                          width: 350.0, height: 350.0, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            // PAGE FOREGROUND
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 111.0, 0.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: SvgPicture.asset('assets/images/D-verde.svg',
                            width: 68.0, height: 88.0, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 53.0, 0.0, 0.0),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.publicSans(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: const Color(0xFF00444B),
                              fontSize: 26.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    Container(
                      width: 350.0,
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 36.0, 0.0, 0.0),
                            child: Text(
                              widget.email != null && widget.email!.isNotEmpty
                                  ? 'Enviamos un código de 6 dígitos a ${widget.email}. Ingrésalo a continuación.'
                                  : 'Ingresa el código de 6 dígitos que se menciona en el correo electrónico.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                    ),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: PinCodeTextField(
                              autoDisposeControllers: false,
                              appContext: context,
                              length: 6,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    font: GoogleFonts.inter(),
                                    letterSpacing: 0.0,
                                  ),
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              enableActiveFill: false,
                              autoFocus: true,
                              focusNode: pinCodeFocusNode,
                              enablePinAutofill: false,
                              errorTextSpace: 0.0,
                              showCursor: true,
                              cursorColor: FlutterFlowTheme.of(context).primary,
                              obscureText: false,
                              hintCharacter: '●',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              pinTheme: PinTheme(
                                fieldHeight: 44.0,
                                fieldWidth: 44.0,
                                borderWidth: 2.0,
                                borderRadius: BorderRadius.circular(12.0),
                                shape: PinCodeFieldShape.box,
                                activeColor: showPinError
                                    ? FlutterFlowTheme.of(context).error
                                    : FlutterFlowTheme.of(context).primaryText,
                                inactiveColor: showPinError
                                    ? FlutterFlowTheme.of(context).error
                                    : FlutterFlowTheme.of(context).alternate,
                                selectedColor: showPinError
                                    ? FlutterFlowTheme.of(context).error
                                    : FlutterFlowTheme.of(context).primary,
                              ),
                              controller: pinCodeController,
                              onChanged: (_) {},
                              onCompleted: (_) => safeSetState(() {}),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿No recibiste un código de verificación? ',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                GestureDetector(
                                  onTap: _onResendCode,
                                  child: Text(
                                    'volver a enviar',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: const Color(0xFF007376),
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 35.0, 0.0, 0.0),
                        child: Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Crea una nueva contraseña. Asegúrate de que sea diferente a las anteriores por seguridad.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 41.0, 0.0, 0.0),
                                      child: Text(
                                        'Ingresa tu contraseña',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: TextFormField(
                                        controller: passwordInputTextController,
                                        focusNode: passwordInputFocusNode,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        obscureText: !showPassword,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: '**********',
                                          hintStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    letterSpacing: 0.0,
                                                  ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xFF007376),
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              letterSpacing: 0.0,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Ingresa una contraseña';
                                          }
                                          final hasUppercase =
                                              RegExp(r'[A-Z]').hasMatch(val);
                                          final hasDigit =
                                              RegExp(r'[0-9]').hasMatch(val);
                                          final hasSpecial = RegExp(
                                                  r'[!@#$%^&*()_+=\[\]{}|;:,.<>?\-]')
                                              .hasMatch(val);
                                          if (val.length < 8 ||
                                              !hasUppercase ||
                                              !hasDigit ||
                                              !hasSpecial) {
                                            return 'Debe incluir al menos un carácter especial, una mayúscula, un numero y un mínimo de 8 caracteres';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 16.0, 0.0, 0.0),
                                child: Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Confirmar la contraseña',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: TextFormField(
                                          controller:
                                              confirmPasswordInputTextController,
                                          focusNode:
                                              confirmPasswordInputFocusNode,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          obscureText: !showPassword,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: '**********',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(),
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF007376),
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(),
                                                letterSpacing: 0.0,
                                              ),
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          validator: (val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Confirma la contraseña';
                                            }
                                            if (val !=
                                                passwordInputTextController
                                                    ?.text) {
                                              return 'Las contraseñas no coinciden';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 0.0),
                                child: Row(
                                  children: [
                                    Theme(
                                      data: ThemeData(
                                        checkboxTheme: CheckboxThemeData(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0)),
                                        ),
                                        unselectedWidgetColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                      ),
                                      child: Checkbox(
                                        value: checkboxValue,
                                        onChanged: (newValue) => safeSetState(
                                            () => checkboxValue = newValue!),
                                        side: BorderSide(
                                            width: 2,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate),
                                        activeColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        checkColor:
                                            FlutterFlowTheme.of(context).info,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              10.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'Mostrar contraseña',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 41.0, 0.0, 41.0),
                                child: FFButtonWidget(
                                  onPressed: buttonEnabled ? _onSubmit : null,
                                  text: 'Verificar contraseña',
                                  options: FFButtonOptions(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: 42.0,
                                    color: buttonEnabled
                                        ? const Color(0xFF00444B)
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.publicSans(),
                                          color: buttonEnabled
                                              ? Colors.white
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}
