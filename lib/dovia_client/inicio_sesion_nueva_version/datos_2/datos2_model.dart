import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'datos2_widget.dart' show Datos2Widget;
import 'package:flutter/material.dart';

class Datos2Model extends FlutterFlowModel<Datos2Widget> {
  ///  Local state fields for this page.

  bool isBotonDisabled = true;

  bool terminosAceptados = false;

  ///  State fields for stateful widgets in this page.

  // Model for CornerGradientBackground component.
  late CornerGradientBackgroundModel cornerGradientBackgroundModel;
  bool isDataUploading_uploadData5so = false;
  FFUploadedFile uploadedLocalFile_uploadData5so =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for Checkbox widget.
  bool? checkboxValue;

  @override
  void initState(BuildContext context) {
    cornerGradientBackgroundModel =
        createModel(context, () => CornerGradientBackgroundModel());
  }

  @override
  void dispose() {
    cornerGradientBackgroundModel.dispose();
  }
}
