// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
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
  /// If not provided or empty, defaults will be used.
  final List<String>? stepNames;

  const ProcessState({
    super.key,
    required this.currentStep,
    this.width,
    this.height,
    this.stepNames,
  }) : assert(currentStep >= 1, 'currentStep must be at least 1');

  static const Color primaryColor = Color(0xFF007376);
  static const Color primaryLightBg = Color(
    0xFFD2EAEB,
  );
  static const Color primaryLightCircle = Color(
    0xFF70ACAD,
  );
  static const Color completedBadgeBg = Color(
    0x1A007376,
  );
  static const Color textColor = Color(0xFF00444B);
  static const Color grayColor = Color(0xFFA8AABC);

  // Default Step Titles (Fallback)
  static const List<String> _defaultStepTitles = [
    'Completar\ninformación',
    'Enlistamiento',
    'Preparar\nmaterial',
    'Publicación\nde propiedad',
  ];

  // Helper to get the actual list to use
  List<String> get _effectiveStepTitles {
    if (stepNames != null && stepNames!.isNotEmpty) {
      return stepNames!;
    }
    return _defaultStepTitles;
  }

  @override
  Widget build(BuildContext context) {
    // We determine the number of steps based on the list being used
    final stepsCount = _effectiveStepTitles.length;

    return Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color(0xFFE9EFFF),
            Colors.white,
          ],
          stops: [1.0, 0.25],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 19,
            offset: const Offset(4.5, 5.2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Estado de tu proceso',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.26,
            ),
          ),
          const SizedBox(height: 12),
          _buildCirclesRow(stepsCount),
          const SizedBox(height: 8),
          _buildStepLabelsRow(stepsCount),
          const SizedBox(height: 4),
          _buildStepTitlesRow(_effectiveStepTitles),
          const SizedBox(height: 8),
          _buildStatusBadgesRow(stepsCount),
        ],
      ),
    );
  }

  Widget _buildCirclesRow(int stepsCount) {
    return Row(
      children: [
        for (int i = 1; i <= stepsCount; i++) ...[
          _buildCircle(_getStepState(i)),
          if (i < stepsCount) _buildConnector(i),
        ],
      ],
    );
  }

  Widget _buildStepLabelsRow(int stepsCount) {
    return Row(
      children: [
        for (int i = 1; i <= stepsCount; i++) ...[
          SizedBox(
            width: 75,
            child: Text(
              'PASO $i',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: grayColor,
              ),
            ),
          ),
          if (i < stepsCount) const Spacer(),
        ],
      ],
    );
  }

  Widget _buildStepTitlesRow(List<String> titles) {
    final stepsCount = titles.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 1; i <= stepsCount; i++) ...[
          SizedBox(
            width: 78,
            child: Text(
              titles[i - 1],
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
          if (i < stepsCount) const Spacer(),
        ],
      ],
    );
  }

  Widget _buildStatusBadgesRow(int stepsCount) {
    return Row(
      children: [
        for (int i = 1; i <= stepsCount; i++) ...[
          _buildStatusBadge(_getStepState(i)),
          if (i < stepsCount) const Spacer(),
        ],
      ],
    );
  }

  Widget _buildCircle(StepState state) {
    switch (state) {
      case StepState.completed:
        return Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
        );
      case StepState.inProgress:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: primaryLightCircle, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: primaryLightCircle,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case StepState.pending:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
          ),
        );
    }
  }

  Widget _buildConnector(int afterStep) {
    final bool isCompleted = afterStep < currentStep;

    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isCompleted ? primaryColor : grayColor.withAlpha(77),
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StepState state) {
    String label;
    Color backgroundColor;
    Color badgeTextColor;
    Border? border;

    switch (state) {
      case StepState.completed:
        label = 'Completado';
        backgroundColor = completedBadgeBg;
        badgeTextColor = primaryColor;
        border = null;
        break;
      case StepState.inProgress:
        label = 'En Proceso';
        backgroundColor = primaryLightBg;
        badgeTextColor = primaryLightCircle;
        border = null;
        break;
      case StepState.pending:
        label = 'Pendiente';
        backgroundColor = Colors.white;
        badgeTextColor = grayColor;
        border = Border.all(color: grayColor, width: 0.77);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: badgeTextColor,
        ),
      ),
    );
  }

  StepState _getStepState(int stepNumber) {
    if (stepNumber < currentStep) {
      return StepState.completed;
    } else if (stepNumber == currentStep) {
      return StepState.inProgress;
    } else {
      return StepState.pending;
    }
  }
}

enum StepState { completed, inProgress, pending }
