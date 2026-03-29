import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'datos_widget.dart' show DatosWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DatosModel extends FlutterFlowModel<DatosWidget> {
  ///  Local state fields for this page.

  bool isAceptingTerms = false;

  String password = '';

  String confirmPassword = '';

  bool areBothPasswordsEqual = true;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for NombreInput widget.
  FocusNode? nombreInputFocusNode;
  TextEditingController? nombreInputTextController;
  String? Function(BuildContext, String?)? nombreInputTextControllerValidator;
  String? _nombreInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    if (!RegExp('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]').hasMatch(val)) {
      return 'Solo se aceptan caracteres alfabéticos';
    }
    return null;
  }

  // State field(s) for ApellidosInput widget.
  FocusNode? apellidosInputFocusNode;
  TextEditingController? apellidosInputTextController;
  String? Function(BuildContext, String?)?
      apellidosInputTextControllerValidator;
  String? _apellidosInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    if (!RegExp('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]').hasMatch(val)) {
      return 'Solo se aceptan caracteres alfabéticos';
    }
    return null;
  }

  // State field(s) for DiaInput widget.
  FocusNode? diaInputFocusNode;
  TextEditingController? diaInputTextController;
  String? Function(BuildContext, String?)? diaInputTextControllerValidator;
  String? _diaInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  // State field(s) for MesInput widget.
  FocusNode? mesInputFocusNode;
  TextEditingController? mesInputTextController;
  String? Function(BuildContext, String?)? mesInputTextControllerValidator;
  String? _mesInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  // State field(s) for YearInput widget.
  FocusNode? yearInputFocusNode;
  TextEditingController? yearInputTextController;
  String? Function(BuildContext, String?)? yearInputTextControllerValidator;
  String? _yearInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  // State field(s) for SexoInpot widget.
  String? sexoInpotValue;
  FormFieldController<String>? sexoInpotValueController;
  // State field(s) for AreaCodeInput widget.
  FocusNode? areaCodeInputFocusNode;
  TextEditingController? areaCodeInputTextController;
  String? Function(BuildContext, String?)? areaCodeInputTextControllerValidator;
  String? _areaCodeInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  // State field(s) for TelefonoInput widget.
  FocusNode? telefonoInputFocusNode;
  TextEditingController? telefonoInputTextController;
  String? Function(BuildContext, String?)? telefonoInputTextControllerValidator;
  String? _telefonoInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  // State field(s) for NacionalidadInput widget.
  FocusNode? nacionalidadInputFocusNode;
  TextEditingController? nacionalidadInputTextController;
  String? Function(BuildContext, String?)?
      nacionalidadInputTextControllerValidator;
  String? _nacionalidadInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    if (!RegExp('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for PasswordInput widget.
  FocusNode? passwordInputFocusNode;
  TextEditingController? passwordInputTextController;
  late bool passwordInputVisibility;
  String? Function(BuildContext, String?)? passwordInputTextControllerValidator;
  String? _passwordInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    if (!RegExp(
            '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}\$')
        .hasMatch(val)) {
      return 'La contraseña debe tener al menos 8 caráccteres, una letra minúscula, una mayúscula,  un número, y un signo especial';
    }
    return null;
  }

  // State field(s) for ConfirmPasswordInput widget.
  FocusNode? confirmPasswordInputFocusNode;
  TextEditingController? confirmPasswordInputTextController;
  late bool confirmPasswordInputVisibility;
  String? Function(BuildContext, String?)?
      confirmPasswordInputTextControllerValidator;
  String? _confirmPasswordInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // Stores action output result for [Backend Call - API (Complete Registration Step  NEW)] action in Continuar widget.
  ApiCallResponse? response;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    nombreInputTextControllerValidator = _nombreInputTextControllerValidator;
    apellidosInputTextControllerValidator =
        _apellidosInputTextControllerValidator;
    diaInputTextControllerValidator = _diaInputTextControllerValidator;
    mesInputTextControllerValidator = _mesInputTextControllerValidator;
    yearInputTextControllerValidator = _yearInputTextControllerValidator;
    areaCodeInputTextControllerValidator =
        _areaCodeInputTextControllerValidator;
    telefonoInputTextControllerValidator =
        _telefonoInputTextControllerValidator;
    nacionalidadInputTextControllerValidator =
        _nacionalidadInputTextControllerValidator;
    passwordInputVisibility = false;
    passwordInputTextControllerValidator =
        _passwordInputTextControllerValidator;
    confirmPasswordInputVisibility = false;
    confirmPasswordInputTextControllerValidator =
        _confirmPasswordInputTextControllerValidator;
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    nombreInputFocusNode?.dispose();
    nombreInputTextController?.dispose();

    apellidosInputFocusNode?.dispose();
    apellidosInputTextController?.dispose();

    diaInputFocusNode?.dispose();
    diaInputTextController?.dispose();

    mesInputFocusNode?.dispose();
    mesInputTextController?.dispose();

    yearInputFocusNode?.dispose();
    yearInputTextController?.dispose();

    areaCodeInputFocusNode?.dispose();
    areaCodeInputTextController?.dispose();

    telefonoInputFocusNode?.dispose();
    telefonoInputTextController?.dispose();

    nacionalidadInputFocusNode?.dispose();
    nacionalidadInputTextController?.dispose();

    passwordInputFocusNode?.dispose();
    passwordInputTextController?.dispose();

    confirmPasswordInputFocusNode?.dispose();
    confirmPasswordInputTextController?.dispose();
  }
}
