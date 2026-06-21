import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Recorrido360View extends StatefulWidget {
  final String url;
  const Recorrido360View({super.key, required this.url});

  @override
  State<Recorrido360View> createState() => _Recorrido360ViewWebState();
}

class _Recorrido360ViewWebState extends State<Recorrido360View> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'recorrido-360-${widget.url.hashCode}';
    
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'gyroscope; accelerometer; magnetometer; device-orientation';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
