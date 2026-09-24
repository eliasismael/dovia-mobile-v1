// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class DateSelectorWidget extends StatefulWidget {
  final double? width;
  final double? height;

  /// Legacy entry point: initial concrete date (used when [dayNavigation] is
  /// false).
  final DateTime? initialDate;

  /// Currently selected day (null = no day filter → the parent shows the full
  /// month grouped by date). Only honored when [dayNavigation] is true.
  final DateTime? selectedDate;

  /// Month rendered in the pills. Only honored when [dayNavigation] is true.
  final DateTime? displayMonth;

  /// When true the arrows step a selected day by ±1 (or the month when no day
  /// is selected) and the "Día" pill reflects the selected day number.
  final bool dayNavigation;

  final ValueChanged<DateTime?>? onDateSelected;

  /// Fired when the arrows change the month while no day is selected (only in
  /// [dayNavigation] mode).
  final ValueChanged<DateTime>? onMonthChanged;

  const DateSelectorWidget({
    super.key,
    this.width,
    this.height,
    this.initialDate,
    this.selectedDate,
    this.displayMonth,
    this.dayNavigation = false,
    this.onDateSelected,
    this.onMonthChanged,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  static const Color textColor = Color(0xFF00444B);
  static const Color aqua = Color(0xFF007376);
  static const Color bgColor = Color(0xFFF5F5F5);

  // Currently selected day. Null means "no day filter" → the parent renders the
  // full month grouped by date. Only used when [dayNavigation] is true.
  DateTime? _selectedDay;

  // Month shown in the pills (and stepped by the arrows in month view).
  late DateTime _displayMonth;

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
    if (widget.dayNavigation) {
      _selectedDay = widget.selectedDate;
      _displayMonth = _monthOf(
          widget.displayMonth ?? widget.selectedDate ?? DateTime.now());
    } else {
      // Legacy behaviour: a concrete date is always selected.
      _selectedDay = widget.initialDate ?? DateTime.now();
      _displayMonth = _monthOf(_selectedDay!);
    }
  }

  @override
  void didUpdateWidget(covariant DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.dayNavigation) return;
    // Keep in sync when the parent clears the day filter or changes month.
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDay = widget.selectedDate;
    }
    if (widget.displayMonth != oldWidget.displayMonth &&
        widget.displayMonth != null) {
      _displayMonth = _monthOf(widget.displayMonth!);
    }
  }

  DateTime _monthOf(DateTime d) => DateTime(d.year, d.month, 1);

  String get _monthName => _spanishMonths[_displayMonth.month - 1];
  String get _year => _displayMonth.year.toString();
  String get _dayLabel => widget.dayNavigation
      ? (_selectedDay != null ? '${_selectedDay!.day}' : 'Día')
      : 'Día';

  // Left/right arrows. In day-navigation mode they step the selected day by ±1
  // (or the month when no day is selected); otherwise they step the month.
  void _step(int direction) {
    if (widget.dayNavigation && _selectedDay != null) {
      final nd = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day + direction,
      );
      setState(() {
        _selectedDay = nd;
        _displayMonth = _monthOf(nd);
      });
      widget.onDateSelected?.call(nd);
    } else if (widget.dayNavigation) {
      final nm =
          DateTime(_displayMonth.year, _displayMonth.month + direction, 1);
      setState(() => _displayMonth = nm);
      widget.onMonthChanged?.call(nm);
    } else {
      final nm =
          DateTime(_displayMonth.year, _displayMonth.month + direction, 1);
      setState(() {
        _displayMonth = nm;
        _selectedDay = nm;
      });
      widget.onDateSelected?.call(nm);
    }
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
            child: _CustomCalendarPicker(
                initialDate: _selectedDay ?? _displayMonth),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked;
        _displayMonth = _monthOf(picked);
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
              onTap: () => _step(-1),
            ),

            // Center: Día | Month | Year. Se achica si no entra (meses largos
            // o letra grande del sistema) en vez de desbordar a la derecha.
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPill(_dayLabel, isSelected: false),
                      const SizedBox(width: 4),
                      _buildPill(_monthName, isSelected: true),
                      const SizedBox(width: 4),
                      _buildPill(_year, isSelected: false),
                    ],
                  ),
                ),
              ),
            ),

            // Right arrow button
            _buildNavButton(
              icon: Icons.chevron_right,
              onTap: () => _step(1),
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
    int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1)
        .weekday; // 1 = Monday

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
          children: weekdays
              .map((w) => Expanded(
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
                  ))
              .toList(),
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
              int daysInPrevMonth =
                  DateTime(_currentMonth.year, _currentMonth.month, 0).day;
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
                final selected =
                    DateTime(_currentMonth.year, _currentMonth.month, day);
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
