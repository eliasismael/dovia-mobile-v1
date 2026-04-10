import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'datos3_new_widget.dart' show Datos3NewWidget;
import 'package:flutter/material.dart';

class Datos3NewModel extends FlutterFlowModel<Datos3NewWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for PropiedadTipoDropDown widget.
  String? propiedadTipoDropDownValue;
  FormFieldController<String>? propiedadTipoDropDownValueController;
  // State field(s) for ModalidadDropDown widget.
  String? modalidadDropDownValue;
  FormFieldController<String>? modalidadDropDownValueController;
  // State field(s) for DescriptionInput widget.
  FocusNode? descriptionInputFocusNode;
  TextEditingController? descriptionInputTextController;
  String? Function(BuildContext, String?)?
      descriptionInputTextControllerValidator;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    descriptionInputFocusNode?.dispose();
    descriptionInputTextController?.dispose();
  }
}
