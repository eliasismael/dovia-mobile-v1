import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'datos3_widget.dart' show Datos3Widget;
import 'package:flutter/material.dart';

class Datos3Model extends FlutterFlowModel<Datos3Widget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // State field(s) for PropiedadTipoDropDown widget.
  String? propiedadTipoDropDownValue;
  FormFieldController<String>? propiedadTipoDropDownValueController;
  // State field(s) for ModalidadDropDown widget.
  String? modalidadDropDownValue1;
  FormFieldController<String>? modalidadDropDownValueController1;
  // State field(s) for DescriptionInput widget.
  FocusNode? descriptionInputFocusNode;
  TextEditingController? descriptionInputTextController;
  String? Function(BuildContext, String?)?
      descriptionInputTextControllerValidator;
  // State field(s) for ModalidadDropDown widget.
  String? modalidadDropDownValue2;
  FormFieldController<String>? modalidadDropDownValueController2;
  // State field(s) for ModalidadDropDown widget.
  String? modalidadDropDownValue3;
  FormFieldController<String>? modalidadDropDownValueController3;
  // State field(s) for ModalidadDropDown widget.
  String? modalidadDropDownValue4;
  FormFieldController<String>? modalidadDropDownValueController4;
  // State field(s) for ModalidadDropDown widget.
  String? modalidadDropDownValue5;
  FormFieldController<String>? modalidadDropDownValueController5;
  // State field(s) for ModalidadDropDown widget.
  String? modalidadDropDownValue6;
  FormFieldController<String>? modalidadDropDownValueController6;
  // State field(s) for Slider widget.
  double? sliderValue;

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
