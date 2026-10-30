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
    this.titulo,
  });

  final String? titulo;
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.titulo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  widget.titulo!,
                  style: const TextStyle(
                    color: Color(0xFF004D40),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(
              widget.terminos,
              style: const TextStyle(
                color: Color(0xFF004D40),
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
