import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/custom_code/widgets/all_photos_widget.dart' show PhotoCategory;
import 'package:flutter/material.dart';
import 'todas_las_fotos_model.dart';
export 'todas_las_fotos_model.dart';

class TodasLasFotosWidget extends StatefulWidget {
  const TodasLasFotosWidget({
    super.key,
    this.habitacionImages,
    this.cocinaImages,
    this.terrazaImages,
    this.extraCategories,
  });

  final List<String>? habitacionImages;
  final List<String>? cocinaImages;
  final List<String>? terrazaImages;

  /// Additional categories beyond the standard three (e.g., Sala, Balcón)
  final Map<String, List<String>>? extraCategories;

  @override
  State<TodasLasFotosWidget> createState() => _TodasLasFotosWidgetState();
}

class _TodasLasFotosWidgetState extends State<TodasLasFotosWidget> {
  late TodasLasFotosModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TodasLasFotosModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  List<PhotoCategory>? _buildCategories() {
    final List<PhotoCategory> categories = [];

    if (widget.habitacionImages != null && widget.habitacionImages!.isNotEmpty) {
      categories.add(PhotoCategory(
        name: 'Habitación',
        imagePaths: widget.habitacionImages!,
      ));
    }
    if (widget.cocinaImages != null && widget.cocinaImages!.isNotEmpty) {
      categories.add(PhotoCategory(
        name: 'Cocina',
        imagePaths: widget.cocinaImages!,
      ));
    }
    if (widget.terrazaImages != null && widget.terrazaImages!.isNotEmpty) {
      categories.add(PhotoCategory(
        name: 'Terraza',
        imagePaths: widget.terrazaImages!,
      ));
    }
    if (widget.extraCategories != null) {
      widget.extraCategories!.forEach((name, images) {
        if (images.isNotEmpty) {
          categories.add(PhotoCategory(name: name, imagePaths: images));
        }
      });
    }

    return categories.isEmpty ? null : categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          child: custom_widgets.AllPhotosWidget(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            categories: _buildCategories(),
            onClose: () async {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
