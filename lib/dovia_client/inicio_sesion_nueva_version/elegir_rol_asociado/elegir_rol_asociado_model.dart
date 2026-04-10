import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import '/index.dart';
import 'elegir_rol_asociado_widget.dart' show ElegirRolAsociadoWidget;
import 'package:flutter/material.dart';

class ElegirRolAsociadoModel extends FlutterFlowModel<ElegirRolAsociadoWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
    secondaryButtonModel = createModel(context, () => SecondaryButtonModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
    secondaryButtonModel.dispose();
  }
}
