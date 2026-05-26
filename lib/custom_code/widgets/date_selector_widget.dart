// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
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
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _CustomCalendarPicker(initialDate: _selectedDate),
          ),
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

class _CustomCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  const _CustomCalendarPicker({required this.initialDate});

  @override
  State<_CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<_CustomCalendarPicker> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  static const Color aqua = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);

  static const List<String> _spanishMonths = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Monday
    
    final weekdays = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: textColor),
              onPressed: _previousMonth,
            ),
            Text(
              '${_spanishMonths[_currentMonth.month - 1]} ${_currentMonth.year}',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: textColor),
              onPressed: _nextMonth,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekdays
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((w) => Expanded(
            child: Text(
              w,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5A5A5A),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 42, // 6 rows * 7 days
          itemBuilder: (context, index) {
            int day;
            bool isCurrentMonth = true;
            bool isSelected = false;
            bool isToday = false;

            if (index < firstWeekday - 1) {
              isCurrentMonth = false;
              int daysInPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
              day = daysInPrevMonth - (firstWeekday - 1 - index) + 1;
            } else if (index >= firstWeekday - 1 + daysInMonth) {
              isCurrentMonth = false;
              day = index - (firstWeekday - 1 + daysInMonth) + 1;
            } else {
              day = index - (firstWeekday - 1) + 1;
              isSelected = _selectedDate.year == _currentMonth.year &&
                           _selectedDate.month == _currentMonth.month &&
                           _selectedDate.day == day;
              isToday = DateTime.now().year == _currentMonth.year &&
                        DateTime.now().month == _currentMonth.month &&
                        DateTime.now().day == day;
            }

            return GestureDetector(
              onTap: () {
                if (!isCurrentMonth) return;
                final selected = DateTime(_currentMonth.year, _currentMonth.month, day);
                Navigator.of(context).pop(selected);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentMonth
                      ? (isSelected ? aqua : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentMonth
                        ? (isSelected ? Colors.white : textColor)
                        : const Color(0xFFC4C4C4),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
