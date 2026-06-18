import '/flutter_flow/flutter_flow_util.dart';
import 'popup_rechazar_documento_widget.dart' show PopupRechazarDocumentoWidget;
import 'package:flutter/material.dart';

class PopupRechazarDocumentoModel extends FlutterFlowModel<PopupRechazarDocumentoWidget> {
  FocusNode? commentFocusNode;
  TextEditingController? commentTextController;
  String? Function(BuildContext, String?)? commentTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    commentFocusNode?.dispose();
    commentTextController?.dispose();
  }
}
