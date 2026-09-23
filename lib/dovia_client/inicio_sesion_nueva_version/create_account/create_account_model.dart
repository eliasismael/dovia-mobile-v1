import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'create_account_widget.dart' show CreateAccountWidget;
import 'package:flutter/material.dart';

class CreateAccountModel extends FlutterFlowModel<CreateAccountWidget> {
  ///  Local state fields for this page.

  bool mailAlredyRegistered = false;

  String? signUpError;

  bool mailInvalid = false;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for CorreoElectronico widget.
  FocusNode? correoElectronicoFocusNode;
  TextEditingController? correoElectronicoTextController;
  String? Function(BuildContext, String?)?
      correoElectronicoTextControllerValidator;
  String? _correoElectronicoTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Introduce un correo electrónico';
    }

    if (val.length < 4) {
      return 'Requires at least 4 characters.';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'El correo electrónico no es válido';
    }
    return null;
  }

  // Stores action output result for [Backend Call - API (Sign Up Step  NEW)] action in Continuar widget.
  ApiCallResponse? response;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    correoElectronicoTextControllerValidator =
        _correoElectronicoTextControllerValidator;
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    correoElectronicoFocusNode?.dispose();
    correoElectronicoTextController?.dispose();
  }
}
