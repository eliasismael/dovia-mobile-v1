import '/flutter_flow/flutter_flow_util.dart';
import 'propiedades_sobre_el_sector_widget.dart'
    show PropiedadesSobreElSectorWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class PropiedadesSobreElSectorModel
    extends FlutterFlowModel<PropiedadesSobreElSectorWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // State field(s) for RatingBar widget.
  double? ratingBarValue1;
  // State field(s) for RatingBar widget.
  double? ratingBarValue2;
  // State field(s) for RatingBar widget.
  double? ratingBarValue3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    expandableExpandableController.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
