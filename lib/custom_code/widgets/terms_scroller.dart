// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class TermsScroller extends StatefulWidget {
  const TermsScroller({
    super.key,
    this.width,
    this.height,
    required this.terminos,
    required this.onBottomReached,
  });

  final double? width;
  final double? height;
  final Future Function() onBottomReached;
  final String terminos;

  @override
  State<TermsScroller> createState() => _TermsScrollerState();
}

class _TermsScrollerState extends State<TermsScroller> {
  late ScrollController _scrollController;
  bool _hasReachedBottom = false;

  // Reemplazá este texto con tus términos reales
//   final String terminos = """
// 1. ¿QUÉ ES DOVIA?
// • DOVIA es una plataforma digital que permite: publicar propiedades, coordinar visitas...
//   """;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_hasReachedBottom &&
          _scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          _hasReachedBottom = true;
        });
        // Dispara la acción hacia FlutterFlow
        widget.onBottomReached();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Text(
          widget.terminos,
          style: const TextStyle(
            color: Color(0xFF004D40), // Tu color verde oscuro
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
