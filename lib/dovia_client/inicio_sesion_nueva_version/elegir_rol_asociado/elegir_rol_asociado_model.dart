import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'elegir_rol_asociado_widget.dart' show ElegirRolAsociadoWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
