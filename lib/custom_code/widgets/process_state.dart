// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import '/backend/schema/structs/index.dart';

class ProcessState extends StatelessWidget {
  /// Current step (1, 2, 3, or 4)
  final int currentStep;

  final double? width;
  final double? height;

  /// Optional: Custom names for the steps.
  final List<String>? stepNames;

  const ProcessState({
    super.key,
    required this.currentStep,
    this.width,
    this.height,
    this.stepNames,
  }) : assert(currentStep >= 1, 'currentStep must be at least 1');

  // ── Colors ────────────────────────────────────────────────────────────────
  static const Color _textDark = Color(0xFF00444B);
  static const Color _gray = Color(0xFFA8AABC);

  static const List<String> _defaultTitles = [
    'Completar\ninformación',
    'Enlistamiento',
    'Preparar\nmaterial',
    'Publicación\nde propiedad',
  ];

  List<String> get _titles =>
      (stepNames != null && stepNames!.isNotEmpty) ? stepNames! : _defaultTitles;

  @override
  Widget build(BuildContext context) {
    final titles = _titles;
    final count = titles.length;

    return Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          const Text(
            'Estado de tu proceso',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textDark,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 14),

          // Circles + connectors row
          Row(
            children: [
              for (int i = 1; i <= count; i++) ...[
                _StepCircle(state: _stateOf(i)),
                if (i < count) _Connector(active: i < currentStep),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // "PASO N" labels row
          Row(
            children: [
              for (int i = 1; i <= count; i++) ...[
                SizedBox(
                  width: 72,
                  child: Text(
                    'PASO $i',
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: _gray,
                    ),
                  ),
                ),
                if (i < count) const Spacer(),
              ],
            ],
          ),
          const SizedBox(height: 2),

          // Step title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 1; i <= count; i++) ...[
                SizedBox(
                  width: 72,
                  child: Text(
                    titles[i - 1],
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      fontWeight: _stateOf(i) == _StepState.pending
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: _stateOf(i) == _StepState.pending
                          ? _gray
                          : _textDark,
                      height: 1.35,
                    ),
                  ),
                ),
                if (i < count) const Spacer(),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Status badges row
          Row(
            children: [
              for (int i = 1; i <= count; i++) ...[
                _StatusBadge(state: _stateOf(i)),
                if (i < count) const Spacer(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _StepState _stateOf(int step) {
    if (step < currentStep) return _StepState.completed;
    if (step == currentStep) return _StepState.inProgress;
    return _StepState.pending;
  }
}

// ── Step states ────────────────────────────────────────────────────────────
enum _StepState { completed, inProgress, pending }

// ── Circle indicator ───────────────────────────────────────────────────────
class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.state});
  final _StepState state;

  static const Color _teal = Color(0xFF007376);
  static const Color _tealLight = Color(0xFF70ACAD);
  static const Color _gray = Color(0xFFCCCCCC);

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _StepState.completed:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: _teal,
            shape: BoxShape.circle,
          ),
        );
      case _StepState.inProgress:
        // Outer ring + inner filled dot
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: _tealLight, width: 2.0),
          ),
          child: Center(
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: _tealLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case _StepState.pending:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _gray, width: 1.5),
          ),
        );
    }
  }
}

// ── Connector line ─────────────────────────────────────────────────────────
class _Connector extends StatelessWidget {
  const _Connector({required this.active});
  final bool active;

  static const Color _teal = Color(0xFF007376);
  static const Color _grayLight = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? _teal : _grayLight,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.state});
  final _StepState state;

  static const Color _teal = Color(0xFF007376);
  static const Color _tealLight = Color(0xFF70ACAD);
  static const Color _tealLightBg = Color(0xFFD2EAEB);
  static const Color _completedBg = Color(0x1A007376);
  static const Color _gray = Color(0xFFA8AABC);

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color bg;
    late Color textColor;
    Border? border;

    switch (state) {
      case _StepState.completed:
        label = 'Completado';
        bg = _completedBg;
        textColor = _teal;
        break;
      case _StepState.inProgress:
        label = 'En Proceso';
        bg = _tealLightBg;
        textColor = _tealLight;
        break;
      case _StepState.pending:
        label = 'Pendiente';
        bg = Colors.white;
        textColor = _gray;
        border = Border.all(color: _gray, width: 0.8);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
