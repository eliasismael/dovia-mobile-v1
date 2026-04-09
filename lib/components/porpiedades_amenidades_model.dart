import '/flutter_flow/flutter_flow_util.dart';
import 'porpiedades_amenidades_widget.dart' show PorpiedadesAmenidadesWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class PorpiedadesAmenidadesModel
    extends FlutterFlowModel<PorpiedadesAmenidadesWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    expandableExpandableController.dispose();
  }
}
