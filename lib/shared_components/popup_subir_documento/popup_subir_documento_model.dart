import '/flutter_flow/flutter_flow_util.dart';
import 'popup_subir_documento_widget.dart' show PopupSubirDocumentoWidget;
import 'package:flutter/material.dart';

class PopupSubirDocumentoModel
    extends FlutterFlowModel<PopupSubirDocumentoWidget> {
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
