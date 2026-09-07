import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'draw_map_component_model.dart';
export 'draw_map_component_model.dart';

class DrawMapComponentWidget extends StatefulWidget {
  const DrawMapComponentWidget({
    super.key,
    this.height,
    bool? singlePointMode,
    this.onPointSelected,
    this.onPointCleared,
    this.initialLatitude,
    this.initialLongitude,
    this.interactive = true,
  }) : singlePointMode = singlePointMode ?? false;

  final double? height;
  final bool singlePointMode;
  final Future Function(double latitude, double longitude)? onPointSelected;

  /// Se invoca al tocar "Limpiar", para que el formulario descarte las
  /// coordenadas que había guardado.
  final VoidCallback? onPointCleared;
  final double? initialLatitude;
  final double? initialLongitude;
  final bool interactive;

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
      height: widget.height,
      decoration: const BoxDecoration(),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 1.0,
        child: custom_widgets.MapDrawingWidget(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          mapboxToken: FFAppConstants.MapboxAccessToken,
          initialLatitude: widget.initialLatitude ?? 14.6407,
          initialLongitude: widget.initialLongitude ?? -90.5133,
          singlePointMode: widget.singlePointMode,
          // El 14.6407 / -90.5133 de arriba solo centra el mapa. El pin arranca
          // marcado únicamente cuando quien usa el componente pasó una
          // ubicación real; en un alta el mapa abre vacío.
          preselectInitialPoint:
              widget.initialLatitude != null && widget.initialLongitude != null,
          interactive: widget.interactive,
          onPointSelected: (latitude, longitude) async {
            await widget.onPointSelected?.call(
              latitude,
              longitude,
            );
          },
          onPointCleared: widget.onPointCleared,
        ),
      ),
    );
  }
}
