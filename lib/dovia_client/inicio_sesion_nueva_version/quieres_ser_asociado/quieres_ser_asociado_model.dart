import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'quieres_ser_asociado_widget.dart' show QuieresSerAsociadoWidget;
import 'package:flutter/material.dart';

class QuieresSerAsociadoModel
    extends FlutterFlowModel<QuieresSerAsociadoWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel1;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel2;

  @override
  void initState(BuildContext context) {
    secondaryButtonModel1 = createModel(context, () => SecondaryButtonModel());
    secondaryButtonModel2 = createModel(context, () => SecondaryButtonModel());
  }

  @override
  void dispose() {
    secondaryButtonModel1.dispose();
    secondaryButtonModel2.dispose();
  }
}
