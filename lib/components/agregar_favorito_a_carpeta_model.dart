import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import '/shared_components/secondary_button/secondary_button_widget.dart';
import 'dart:ui';
import 'agregar_favorito_a_carpeta_widget.dart'
    show AgregarFavoritoACarpetaWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AgregarFavoritoACarpetaModel
    extends FlutterFlowModel<AgregarFavoritoACarpetaWidget> {
  ///  State fields for stateful widgets in this component.

  // Models for PrimaryButton dynamic component.
  late FlutterFlowDynamicModels<PrimaryButtonModel> primaryButtonModels;
  // Stores action output result for [Backend Call - API (Add Property to Favorites)] action in PrimaryButton widget.
  ApiCallResponse? apiResultv19;
  // Model for SecondaryButton component.
  late SecondaryButtonModel secondaryButtonModel;

  @override
  void initState(BuildContext context) {
    primaryButtonModels = FlutterFlowDynamicModels(() => PrimaryButtonModel());
    secondaryButtonModel = createModel(context, () => SecondaryButtonModel());
  }

  @override
  void dispose() {
    primaryButtonModels.dispose();
    secondaryButtonModel.dispose();
  }
}
