import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Recorrido360View extends StatefulWidget {
  final String url;
  const Recorrido360View({super.key, required this.url});

  @override
  State<Recorrido360View> createState() => _Recorrido360ViewMobileState();
}

class _Recorrido360ViewMobileState extends State<Recorrido360View> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
