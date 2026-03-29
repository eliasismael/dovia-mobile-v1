import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpeta_creada_modal/tus_favoritos_carpeta_creada_modal_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'tus_favoritos_carpetas_modal_widget.dart'
    show TusFavoritosCarpetasModalWidget;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TusFavoritosCarpetasModalModel
    extends FlutterFlowModel<TusFavoritosCarpetasModalWidget> {
  ///  Local state fields for this component.

  bool isCreatingNewFolder = false;

  String? folderName;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (Add Property to Favorites)] action in Container widget.
  ApiCallResponse? apiResultvbr;
  // Stores action output result for [Backend Call - API (Create Favorite Folder)] action in Text widget.
  ApiCallResponse? apiResult3ce;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
