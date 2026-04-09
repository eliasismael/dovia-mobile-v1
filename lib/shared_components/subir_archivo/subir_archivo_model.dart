import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/primary_button/primary_button_widget.dart';
import 'subir_archivo_widget.dart' show SubirArchivoWidget;
import 'package:flutter/material.dart';

class SubirArchivoModel extends FlutterFlowModel<SubirArchivoWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_documentoFirmado = false;
  FFUploadedFile uploadedLocalFile_documentoFirmado =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Model for PrimaryButton component.
  late PrimaryButtonModel primaryButtonModel;

  @override
  void initState(BuildContext context) {
    primaryButtonModel = createModel(context, () => PrimaryButtonModel());
  }

  @override
  void dispose() {
    primaryButtonModel.dispose();
  }
}
