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

class DateSelectorWidget extends StatefulWidget {
  final double? width;
  final double? height;

  final DateTime? initialDate;

  final ValueChanged<DateTime?>? onDateSelected;

  const DateSelectorWidget({
    super.key,
    this.width,
    this.height,
    this.initialDate,
    this.onDateSelected,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  static const Color textColor = Color(0xFF00444B);
  static const Color aqua = Color(0xFF007376);
  static const Color bgColor = Color(0xFFF5F5F5);

  late DateTime _selectedDate;

  static const List<String> _spanishMonths = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  String get _monthName => _spanishMonths[_selectedDate.month - 1];
  String get _year => _selectedDate.year.toString();
  String get _day => 'Día';

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month - 1,
        1,
      );
    });
    widget.onDateSelected?.call(_selectedDate);
  }

  void _goToNextMonth() {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + 1,
        1,
      );
    });
    widget.onDateSelected?.call(_selectedDate);
  }

  Future<void> _openCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: aqua,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: aqua),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openCalendar,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white, width: 0.82),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000E33),
              blurRadius: 1.63,
              offset: Offset(0, 0.82),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left arrow button
            _buildNavButton(
              icon: Icons.chevron_left,
              onTap: _goToPreviousMonth,
            ),

            const Spacer(),

            // Center: Día | Month | Year
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Día pill
                _buildPill(_day, isSelected: false),
                const SizedBox(width: 1.5),
                // Month pill (highlighted with border)
                _buildPill(_monthName, isSelected: true),
                const SizedBox(width: 1.5),
                // Year pill
                _buildPill(_year, isSelected: false),
              ],
            ),

            const Spacer(),

            // Right arrow button
            _buildNavButton(
              icon: Icons.chevron_right,
              onTap: _goToNextMonth,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NAV BUTTON ====================
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000E33).withValues(alpha: 0.05),
              blurRadius: 0.82,
              offset: const Offset(0, 0.82),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: aqua,
        ),
      ),
    );
  }

  // ==================== PILL BUTTON ====================
  Widget _buildPill(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: isSelected ? Border.all(color: aqua, width: 1.52) : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000E33).withValues(alpha: 0.05),
            blurRadius: 0.76,
            offset: const Offset(0, 0.76),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
              letterSpacing: -0.15,
              height: 1,
            ),
          ),
          const SizedBox(width: 1.5),
          Icon(
            isSelected ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 12,
            color: textColor,
          ),
        ],
      ),
    );
  }
}
