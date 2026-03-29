import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'draw_map_component_model.dart';
export 'draw_map_component_model.dart';

class DrawMapComponentWidget extends StatefulWidget {
  const DrawMapComponentWidget({
    super.key,
    this.height,
    bool? singlePointMode,
    this.onPointSelected,
  }) : this.singlePointMode = singlePointMode ?? false;

  final double? height;
  final bool singlePointMode;
  final Future Function(double latitude, double longitude)? onPointSelected;

  @override
  State<DrawMapComponentWidget> createState() => _DrawMapComponentWidgetState();
}

class _DrawMapComponentWidgetState extends State<DrawMapComponentWidget> {
  late DrawMapComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrawMapComponentModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget!.height,
      decoration: BoxDecoration(),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 1.0,
        child: custom_widgets.MapDrawingWidget(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          mapboxToken: FFAppConstants.MapboxAccessToken,
          initialLatitude: 14.6407,
          initialLongitude: -90.5133,
          singlePointMode: widget!.singlePointMode,
          onPointSelected: (latitude, longitude) async {
            await widget.onPointSelected?.call(
              1.0,
              1.0,
            );
          },
        ),
      ),
    );
  }
}
