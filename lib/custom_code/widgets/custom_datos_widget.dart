// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import the next page route directly or push Named
// import '/dovia_client/inicio_sesion_nueva_version/datos2/datos2_widget.dart';

/// Country data with dial code and expected phone number length.
class CountryData {
  final String name;
  final String dialCode;
  final int phoneLength;

  const CountryData({
    required this.name,
    required this.dialCode,
    required this.phoneLength,
  });

  @override
  String toString() => '$name ($dialCode)';
}

/// All supported countries for phone and nationality dropdowns.
const List<CountryData> kCountries = [
  CountryData(name: 'Argentina', dialCode: '+54', phoneLength: 10),
  CountryData(name: 'Bolivia', dialCode: '+591', phoneLength: 8),
  CountryData(name: 'Brasil', dialCode: '+55', phoneLength: 11),
  CountryData(name: 'Chile', dialCode: '+56', phoneLength: 9),
  CountryData(name: 'Colombia', dialCode: '+57', phoneLength: 10),
  CountryData(name: 'Costa Rica', dialCode: '+506', phoneLength: 8),
  CountryData(name: 'Cuba', dialCode: '+53', phoneLength: 8),
  CountryData(name: 'Ecuador', dialCode: '+593', phoneLength: 9),
  CountryData(name: 'El Salvador', dialCode: '+503', phoneLength: 8),
  CountryData(name: 'España', dialCode: '+34', phoneLength: 9),
  CountryData(name: 'Estados Unidos', dialCode: '+1', phoneLength: 10),
  CountryData(name: 'Guatemala', dialCode: '+502', phoneLength: 8),
  CountryData(name: 'Honduras', dialCode: '+504', phoneLength: 8),
  CountryData(name: 'México', dialCode: '+52', phoneLength: 10),
  CountryData(name: 'Nicaragua', dialCode: '+505', phoneLength: 8),
  CountryData(name: 'Panamá', dialCode: '+507', phoneLength: 8),
  CountryData(name: 'Paraguay', dialCode: '+595', phoneLength: 9),
  CountryData(name: 'Perú', dialCode: '+51', phoneLength: 9),
  CountryData(name: 'Puerto Rico', dialCode: '+1', phoneLength: 10),
  CountryData(name: 'República Dominicana', dialCode: '+1', phoneLength: 10),
  CountryData(name: 'Uruguay', dialCode: '+598', phoneLength: 8),
  CountryData(name: 'Venezuela', dialCode: '+58', phoneLength: 10),
  CountryData(name: 'Alemania', dialCode: '+49', phoneLength: 11),
  CountryData(name: 'Francia', dialCode: '+33', phoneLength: 9),
  CountryData(name: 'Italia', dialCode: '+39', phoneLength: 10),
  CountryData(name: 'Portugal', dialCode: '+351', phoneLength: 9),
  CountryData(name: 'Reino Unido', dialCode: '+44', phoneLength: 10),
  CountryData(name: 'Canadá', dialCode: '+1', phoneLength: 10),
  CountryData(name: 'Japón', dialCode: '+81', phoneLength: 10),
  CountryData(name: 'China', dialCode: '+86', phoneLength: 11),
  CountryData(name: 'India', dialCode: '+91', phoneLength: 10),
  CountryData(name: 'Australia', dialCode: '+61', phoneLength: 9),
  CountryData(name: 'Corea del Sur', dialCode: '+82', phoneLength: 10),
  CountryData(name: 'Rusia', dialCode: '+7', phoneLength: 10),
  CountryData(name: 'Sudáfrica', dialCode: '+27', phoneLength: 9),
  CountryData(name: 'Egipto', dialCode: '+20', phoneLength: 10),
  CountryData(name: 'Marruecos', dialCode: '+212', phoneLength: 9),
  CountryData(name: 'Nigeria', dialCode: '+234', phoneLength: 10),
  CountryData(name: 'Israel', dialCode: '+972', phoneLength: 9),
  CountryData(name: 'Turquía', dialCode: '+90', phoneLength: 10),
  CountryData(name: 'Filipinas', dialCode: '+63', phoneLength: 10),
  CountryData(name: 'Tailandia', dialCode: '+66', phoneLength: 9),
  CountryData(name: 'Indonesia', dialCode: '+62', phoneLength: 11),
  CountryData(name: 'Malasia', dialCode: '+60', phoneLength: 10),
  CountryData(name: 'Singapur', dialCode: '+65', phoneLength: 8),
  CountryData(name: 'Nueva Zelanda', dialCode: '+64', phoneLength: 9),
  CountryData(name: 'Suiza', dialCode: '+41', phoneLength: 9),
  CountryData(name: 'Austria', dialCode: '+43', phoneLength: 10),
  CountryData(name: 'Bélgica', dialCode: '+32', phoneLength: 9),
  CountryData(name: 'Países Bajos', dialCode: '+31', phoneLength: 9),
  CountryData(name: 'Suecia', dialCode: '+46', phoneLength: 9),
  CountryData(name: 'Noruega', dialCode: '+47', phoneLength: 8),
  CountryData(name: 'Dinamarca', dialCode: '+45', phoneLength: 8),
  CountryData(name: 'Finlandia', dialCode: '+358', phoneLength: 9),
  CountryData(name: 'Polonia', dialCode: '+48', phoneLength: 9),
  CountryData(name: 'Grecia', dialCode: '+30', phoneLength: 10),
  CountryData(name: 'Irlanda', dialCode: '+353', phoneLength: 9),
];

class CustomDatosWidget extends StatefulWidget {
  const CustomDatosWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<CustomDatosWidget> createState() => _CustomDatosWidgetState();
}

class _CustomDatosWidgetState extends State<CustomDatosWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  late CornerGradientBackgroundModel cornerGradientBackgroundModel;

  // Form Fields State
  String password = '';
  String confirmPassword = '';

  // Error state fields for real-time validation
  String? nombreError;
  String? apellidosError;
  String? fechaNacimientoError;
  String? telefonoError;
  String? passwordError;
  String? confirmPasswordError;

  // Selected dropdown states
  CountryData? selectedPhoneCountry;
  String? selectedNacionalidad;
  String? selectedPhoneCountryValue;
  String? sexoInpotValue;

  // Controllers & FocusNodes
  late TextEditingController nombreInputTextController;
  late FocusNode nombreInputFocusNode;

  late TextEditingController apellidosInputTextController;
  late FocusNode apellidosInputFocusNode;

  late TextEditingController diaInputTextController;
  late FocusNode diaInputFocusNode;

  late TextEditingController mesInputTextController;
  late FocusNode mesInputFocusNode;

  late TextEditingController yearInputTextController;
  late FocusNode yearInputFocusNode;

  late TextEditingController areaCodeInputTextController;
  late FocusNode areaCodeInputFocusNode;

  late TextEditingController telefonoInputTextController;
  late FocusNode telefonoInputFocusNode;

  late TextEditingController passwordInputTextController;
  late FocusNode passwordInputFocusNode;
  bool passwordInputVisibility = false;

  late TextEditingController confirmPasswordInputTextController;
  late FocusNode confirmPasswordInputFocusNode;
  bool confirmPasswordInputVisibility = false;

  late FormFieldController<String> sexoInpotValueController;
  late FormFieldController<String> phoneCountryDropdownController;
  late FormFieldController<String> nacionalidadDropdownController;

  ApiCallResponse? response;

  bool get isFormValid {
    final hasNombre = nombreInputTextController.text.trim().isNotEmpty;
    final hasApellidos = apellidosInputTextController.text.trim().isNotEmpty;
    final hasDia = diaInputTextController.text.trim().isNotEmpty;
    final hasMes = mesInputTextController.text.trim().isNotEmpty;
    final hasYear = yearInputTextController.text.trim().isNotEmpty;
    final hasSexo = sexoInpotValue != null && sexoInpotValue!.isNotEmpty;
    final hasTelefono = telefonoInputTextController.text.trim().isNotEmpty;
    final hasNacionalidad =
        selectedNacionalidad != null && selectedNacionalidad!.isNotEmpty;
    final hasPhoneCountry = selectedPhoneCountry != null;
    final hasPassword = passwordInputTextController.text.trim().isNotEmpty;
    final hasConfirmPassword =
        confirmPasswordInputTextController.text.trim().isNotEmpty;

    final noErrors = nombreError == null &&
        apellidosError == null &&
        fechaNacimientoError == null &&
        telefonoError == null &&
        passwordError == null &&
        confirmPasswordError == null;

    return hasNombre &&
        hasApellidos &&
        hasDia &&
        hasMes &&
        hasYear &&
        hasSexo &&
        hasTelefono &&
        hasNacionalidad &&
        hasPhoneCountry &&
        hasPassword &&
        hasConfirmPassword &&
        noErrors;
  }

  @override
  void initState() {
    super.initState();
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());

    nombreInputTextController = TextEditingController();
    nombreInputFocusNode = FocusNode();

    apellidosInputTextController = TextEditingController();
    apellidosInputFocusNode = FocusNode();

    diaInputTextController = TextEditingController();
    diaInputFocusNode = FocusNode();

    mesInputTextController = TextEditingController();
    mesInputFocusNode = FocusNode();

    yearInputTextController = TextEditingController();
    yearInputFocusNode = FocusNode();

    areaCodeInputTextController = TextEditingController();
    areaCodeInputFocusNode = FocusNode();

    telefonoInputTextController = TextEditingController();
    telefonoInputFocusNode = FocusNode();

    passwordInputTextController = TextEditingController();
    passwordInputFocusNode = FocusNode();

    confirmPasswordInputTextController = TextEditingController();
    confirmPasswordInputFocusNode = FocusNode();

    sexoInpotValueController = FormFieldController<String>(null);
    phoneCountryDropdownController = FormFieldController<String>(null);
    nacionalidadDropdownController = FormFieldController<String>(null);

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    nombreInputFocusNode.dispose();
    nombreInputTextController.dispose();
    apellidosInputFocusNode.dispose();
    apellidosInputTextController.dispose();
    diaInputFocusNode.dispose();
    diaInputTextController.dispose();
    mesInputFocusNode.dispose();
    mesInputTextController.dispose();
    yearInputFocusNode.dispose();
    yearInputTextController.dispose();
    areaCodeInputFocusNode.dispose();
    areaCodeInputTextController.dispose();
    telefonoInputFocusNode.dispose();
    telefonoInputTextController.dispose();
    passwordInputFocusNode.dispose();
    passwordInputTextController.dispose();
    confirmPasswordInputFocusNode.dispose();
    confirmPasswordInputTextController.dispose();
    super.dispose();
  }

  void validateNombre(String val) {
    if (val.isEmpty) {
      nombreError = 'Campo requerido';
    } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$').hasMatch(val)) {
      nombreError = 'Solo se aceptan caracteres alfabéticos';
    } else {
      nombreError = null;
    }
  }

  void validateApellidos(String val) {
    if (val.isEmpty) {
      apellidosError = 'Campo requerido';
    } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$').hasMatch(val)) {
      apellidosError = 'Solo se aceptan caracteres alfabéticos';
    } else {
      apellidosError = null;
    }
  }

  void validateFechaNacimiento() {
    final diaText = diaInputTextController.text.trim();
    final mesText = mesInputTextController.text.trim();
    final yearText = yearInputTextController.text.trim();

    if (diaText.isEmpty || mesText.isEmpty || yearText.isEmpty) {
      fechaNacimientoError = null;
      return;
    }

    final dia = int.tryParse(diaText);
    final mes = int.tryParse(mesText);
    final year = int.tryParse(yearText);

    if (dia == null || mes == null || year == null) {
      fechaNacimientoError = 'Fecha inválida';
      return;
    }

    if (mes < 1 || mes > 12 || dia < 1 || dia > 31 || yearText.length != 4) {
      fechaNacimientoError = 'Fecha inválida';
      return;
    }

    try {
      final birthDate = DateTime(year, mes, dia);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      if (age < 13) {
        fechaNacimientoError = 'Debes ser mayor a 13 años';
      } else {
        fechaNacimientoError = null;
      }
    } catch (_) {
      fechaNacimientoError = 'Fecha inválida';
    }
  }

  void validateTelefono(String val) {
    if (val.isEmpty) {
      telefonoError = 'Campo requerido';
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(val)) {
      telefonoError = 'El número no es válido';
      return;
    }
    if (selectedPhoneCountry != null &&
        val.length != selectedPhoneCountry!.phoneLength) {
      telefonoError = 'El número no es válido';
      return;
    }
    telefonoError = null;
  }

  void validatePassword(String val) {
    if (val.isEmpty) {
      passwordError = 'Campo requerido';
    } else if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:"|,.<>?/\\`~])[A-Za-z\d!@#$%^&*()_+\-=\[\]{};:"|,.<>?/\\`~]{8,}$')
        .hasMatch(val)) {
      passwordError =
          'Debe incluir al menos un carácter especial, una mayúscula, un numero y un mínimo de 8 caracteres';
    } else {
      passwordError = null;
    }
  }

  void validateConfirmPassword(String val) {
    if (val.isEmpty) {
      confirmPasswordError = 'Campo requerido';
    } else if (val != passwordInputTextController.text) {
      confirmPasswordError = 'Las contraseñas no coinciden';
    } else {
      confirmPasswordError = null;
    }
  }

  Widget _buildLabel(String text) {
    return RichText(
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$text ',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  fontSize: 16.0,
                ),
          ),
          TextSpan(
            text: '*',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).error,
                  fontSize: 14.0,
                ),
          ),
        ],
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              fontSize: 16.0,
            ),
      ),
    );
  }

  Widget _buildErrorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
      child: Text(
        error,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).error,
              fontSize: 12.0,
            ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    bool hasError = false,
    Widget? suffixIcon,
  }) {
    final errorColor = FlutterFlowTheme.of(context).error;
    final borderColor = hasError ? errorColor : const Color(0x00000000);
    return InputDecoration(
      isDense: true,
      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.inter(),
          ),
      hintText: hintText,
      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.inter(),
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: FlutterFlowTheme.of(context).alternate,
      suffixIcon: suffixIcon,
    );
  }

  TextStyle get _bodyStyle => FlutterFlowTheme.of(context).bodyMedium.override(
        font: GoogleFonts.inter(),
      );

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        child: Stack(
          children: [
            wrapWithModel<CornerGradientBackgroundModel>(
              model: cornerGradientBackgroundModel,
              updateCallback: () => setState(() {}),
              child: const CornerGradientBackgroundWidget(),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 54.0, 0.0, 0.0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.99,
                          alignment: const AlignmentDirectional(0.0, -1.0),
                          child: Form(
                            key: formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20.0, 0.0, 20.0, 0.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Completa los datos',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(),
                                            fontSize: 26.7,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    _buildFieldSection(
                                      label: 'Nombres',
                                      error: nombreError,
                                      child: TextFormField(
                                        controller: nombreInputTextController,
                                        focusNode: nombreInputFocusNode,
                                        onChanged: (val) {
                                          validateNombre(val);
                                          setState(() {});
                                        },
                                        decoration: _inputDecoration(
                                          hintText:
                                              'Nombres que aparecen en tu ID',
                                          hasError: nombreError != null,
                                        ),
                                        style: _bodyStyle,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                      ),
                                    ),
                                    _buildFieldSection(
                                      label: 'Apellidos',
                                      error: apellidosError,
                                      child: TextFormField(
                                        controller:
                                            apellidosInputTextController,
                                        focusNode: apellidosInputFocusNode,
                                        onChanged: (val) {
                                          validateApellidos(val);
                                          setState(() {});
                                        },
                                        decoration: _inputDecoration(
                                          hintText:
                                              'Apellidos que aparecen en tu ID',
                                          hasError: apellidosError != null,
                                        ),
                                        style: _bodyStyle,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                      ),
                                    ),
                                    // Fecha de nacimiento
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Fecha de nacimiento'),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 12.0, 0.0, 0.0),
                                                  child: TextFormField(
                                                    controller:
                                                        diaInputTextController,
                                                    focusNode:
                                                        diaInputFocusNode,
                                                    onChanged: (_) {
                                                      validateFechaNacimiento();
                                                      setState(() {});
                                                    },
                                                    decoration:
                                                        _inputDecoration(
                                                      hintText: 'DD',
                                                      hasError:
                                                          fechaNacimientoError !=
                                                              null,
                                                    ),
                                                    style: _bodyStyle,
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 17),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 12.0, 0.0, 0.0),
                                                  child: TextFormField(
                                                    controller:
                                                        mesInputTextController,
                                                    focusNode:
                                                        mesInputFocusNode,
                                                    onChanged: (_) {
                                                      validateFechaNacimiento();
                                                      setState(() {});
                                                    },
                                                    decoration:
                                                        _inputDecoration(
                                                      hintText: 'MM',
                                                      hasError:
                                                          fechaNacimientoError !=
                                                              null,
                                                    ),
                                                    style: _bodyStyle,
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 17),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 12.0, 0.0, 0.0),
                                                  child: TextFormField(
                                                    controller:
                                                        yearInputTextController,
                                                    focusNode:
                                                        yearInputFocusNode,
                                                    onChanged: (_) {
                                                      validateFechaNacimiento();
                                                      setState(() {});
                                                    },
                                                    decoration:
                                                        _inputDecoration(
                                                      hintText: 'AAAA',
                                                      hasError:
                                                          fechaNacimientoError !=
                                                              null,
                                                    ),
                                                    style: _bodyStyle,
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          _buildErrorText(fechaNacimientoError),
                                        ],
                                      ),
                                    ),
                                    // Sexo
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Sexo'),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: FlutterFlowDropDown<String>(
                                              controller:
                                                  sexoInpotValueController,
                                              options: const [
                                                'Masculino',
                                                'Femenino',
                                                'Otro',
                                                'Prefiero no decirlo'
                                              ],
                                              onChanged: (val) => setState(
                                                  () => sexoInpotValue = val),
                                              width: double.infinity,
                                              height: 40.0,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                              hintText: 'Selecciona el sexo',
                                              icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 24.0),
                                              elevation: 2.0,
                                              borderColor: Colors.transparent,
                                              borderWidth: 0.0,
                                              borderRadius: 8.0,
                                              margin:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      12.0, 4.0, 12.0, 4.0),
                                              hidesUnderline: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Teléfono
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Teléfono'),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: FlutterFlowDropDown<String>(
                                              controller:
                                                  phoneCountryDropdownController,
                                              options: kCountries
                                                  .map((c) =>
                                                      '${c.name} (${c.dialCode})')
                                                  .toList(),
                                              onChanged: (val) {
                                                selectedPhoneCountryValue = val;
                                                final country =
                                                    kCountries.firstWhere(
                                                        (c) =>
                                                            '${c.name} (${c.dialCode})' ==
                                                            val,
                                                        orElse: () =>
                                                            kCountries.first);
                                                selectedPhoneCountry = country;
                                                areaCodeInputTextController
                                                    .text = country.dialCode;
                                                if (telefonoInputTextController
                                                    .text.isNotEmpty) {
                                                  validateTelefono(
                                                      telefonoInputTextController
                                                          .text);
                                                }
                                                setState(() {});
                                              },
                                              width: double.infinity,
                                              height: 40.0,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                              hintText: 'Selecciona el país',
                                              icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 24.0),
                                              elevation: 2.0,
                                              borderColor: Colors.transparent,
                                              borderWidth: 0.0,
                                              borderRadius: 8.0,
                                              margin:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      12.0, 4.0, 12.0, 4.0),
                                              hidesUnderline: true,
                                              isSearchable: true,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 12.0, 0.0, 0.0),
                                                child: SizedBox(
                                                  width: 56.0,
                                                  child: TextFormField(
                                                    controller:
                                                        areaCodeInputTextController,
                                                    focusNode:
                                                        areaCodeInputFocusNode,
                                                    readOnly: true,
                                                    decoration:
                                                        _inputDecoration(
                                                            hintText: '+51'),
                                                    style: _bodyStyle,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8.0, 12.0, 0.0, 0.0),
                                                  child: TextFormField(
                                                    controller:
                                                        telefonoInputTextController,
                                                    focusNode:
                                                        telefonoInputFocusNode,
                                                    onChanged: (val) {
                                                      validateTelefono(val);
                                                      setState(() {});
                                                    },
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        _inputDecoration(
                                                      hintText: '123456789',
                                                      hasError:
                                                          telefonoError != null,
                                                    ),
                                                    style: _bodyStyle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          _buildErrorText(telefonoError),
                                        ],
                                      ),
                                    ),
                                    // Nacionalidad
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Nacionalidad'),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: FlutterFlowDropDown<String>(
                                              controller:
                                                  nacionalidadDropdownController,
                                              options: kCountries
                                                  .map((c) => c.name)
                                                  .toList(),
                                              onChanged: (val) {
                                                selectedNacionalidad = val;
                                                setState(() {});
                                              },
                                              width: double.infinity,
                                              height: 40.0,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                              hintText:
                                                  'Selecciona la nacionalidad',
                                              icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 24.0),
                                              elevation: 2.0,
                                              borderColor: Colors.transparent,
                                              borderWidth: 0.0,
                                              borderRadius: 8.0,
                                              margin:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      12.0, 4.0, 12.0, 4.0),
                                              hidesUnderline: true,
                                              isSearchable: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Contraseña
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Contraseña'),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: TextFormField(
                                              controller:
                                                  passwordInputTextController,
                                              focusNode: passwordInputFocusNode,
                                              onChanged: (val) {
                                                password = val;
                                                validatePassword(val);
                                                if (confirmPasswordInputTextController
                                                    .text.isNotEmpty) {
                                                  validateConfirmPassword(
                                                      confirmPasswordInputTextController
                                                          .text);
                                                }
                                                setState(() {});
                                              },
                                              obscureText:
                                                  !passwordInputVisibility,
                                              decoration: _inputDecoration(
                                                hintText: '*********',
                                                hasError: passwordError != null,
                                                suffixIcon: InkWell(
                                                  onTap: () => setState(() =>
                                                      passwordInputVisibility =
                                                          !passwordInputVisibility),
                                                  focusNode: FocusNode(
                                                      skipTraversal: true),
                                                  child: Icon(
                                                      passwordInputVisibility
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      size: 22),
                                                ),
                                              ),
                                              style: _bodyStyle,
                                            ),
                                          ),
                                          _buildErrorText(passwordError),
                                        ],
                                      ),
                                    ),
                                    // Confirmar Contraseña
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 12.0, 0.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Confirma la contraseña'),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: TextFormField(
                                              controller:
                                                  confirmPasswordInputTextController,
                                              focusNode:
                                                  confirmPasswordInputFocusNode,
                                              onChanged: (val) {
                                                confirmPassword = val;
                                                validateConfirmPassword(val);
                                                setState(() {});
                                              },
                                              obscureText:
                                                  !confirmPasswordInputVisibility,
                                              decoration: _inputDecoration(
                                                hintText: '*********',
                                                hasError:
                                                    confirmPasswordError !=
                                                        null,
                                                suffixIcon: InkWell(
                                                  onTap: () => setState(() =>
                                                      confirmPasswordInputVisibility =
                                                          !confirmPasswordInputVisibility),
                                                  focusNode: FocusNode(
                                                      skipTraversal: true),
                                                  child: Icon(
                                                      confirmPasswordInputVisibility
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined,
                                                      size: 22),
                                                ),
                                              ),
                                              style: _bodyStyle,
                                            ),
                                          ),
                                          _buildErrorText(confirmPasswordError),
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
                    ],
                  ),
                  // Continuar button
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 18.0, 20.0, 25.0),
                    child: FFButtonWidget(
                      onPressed: !isFormValid
                          ? null
                          : () async {
                              response = await DOVIAAPIAuthContextGroup
                                  .completeRegistrationStepNEWCall
                                  .call(
                                name: nombreInputTextController.text,
                                lastname: apellidosInputTextController.text,
                                day:
                                    diaInputTextController.text.padLeft(2, '0'),
                                month:
                                    mesInputTextController.text.padLeft(2, '0'),
                                year: yearInputTextController.text,
                                gender: sexoInpotValue == 'Masculino'
                                    ? 'MALE'
                                    : 'FEMALE',
                                phoneCountryCode:
                                    areaCodeInputTextController.text,
                                phoneNumber: telefonoInputTextController.text,
                                password: passwordInputTextController.text,
                                confirmPassword:
                                    confirmPasswordInputTextController.text,
                                nationality: selectedNacionalidad ?? '',
                                email: FFAppState().UserEmail,
                              );

                              if ((response?.succeeded ?? true)) {
                                // Setear los campos del App State UserData
                                FFAppState().updateUserDataStruct(
                                  (u) => u
                                    ..name = nombreInputTextController.text
                                    ..lastname =
                                        apellidosInputTextController.text
                                    ..birthdayDay = int.tryParse(
                                        diaInputTextController.text.trim())
                                    ..birthdayMonth = int.tryParse(
                                        mesInputTextController.text.trim())
                                    ..birthdayYear = int.tryParse(
                                        yearInputTextController.text.trim())
                                    ..gender = sexoInpotValue == 'Masculino'
                                        ? 'MALE'
                                        : sexoInpotValue == 'Femenino'
                                            ? 'FEMALE'
                                            : sexoInpotValue ?? ''
                                    ..nationality = selectedNacionalidad ?? ''
                                    ..phoneCode =
                                        areaCodeInputTextController.text
                                    ..phoneNumber =
                                        telefonoInputTextController.text,
                                );

                                GoRouter.of(context).prepareAuthEvent();
                                await authManager.signIn(
                                  authenticationToken: DOVIAAPIAuthContextGroup
                                      .completeRegistrationStepNEWCall
                                      .idToken((response?.jsonBody ?? ''))
                                      .toString(),
                                  refreshToken: DOVIAAPIAuthContextGroup
                                      .completeRegistrationStepNEWCall
                                      .refreshToken((response?.jsonBody ?? '')),
                                  authUid: DOVIAAPIAuthContextGroup
                                      .completeRegistrationStepNEWCall
                                      .userId((response?.jsonBody ?? '')),
                                );

                                // NOTE: In a True Custom Widget you might want to replace this with an action callback parameter
                                // instead of hardcoding the pushNamedAuth to a specific screen, but maintaining original logic for now:
                                context.pushNamed('Datos_2');
                              } else {
                                await showDialog(
                                  context: context,
                                  builder: (alertDialogContext) {
                                    return AlertDialog(
                                      title: Text((response?.statusCode ?? 200)
                                          .toString()),
                                      content: Text((response?.bodyText ?? '')),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(
                                                alertDialogContext),
                                            child: const Text('Ok')),
                                      ],
                                    );
                                  },
                                );
                              }
                              setState(() {});
                            },
                      text: 'Continuar',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 40.0,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.publicSans(),
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                        borderRadius: BorderRadius.circular(25.0),
                        disabledColor: const Color(0xAD007376),
                        disabledTextColor: const Color(0x9FFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSection({
    required String label,
    required Widget child,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: child,
          ),
          _buildErrorText(error),
        ],
      ),
    );
  }
}
