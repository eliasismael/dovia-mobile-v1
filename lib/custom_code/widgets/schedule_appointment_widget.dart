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

class ScheduleAppointmentWidget extends StatefulWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onClose;
  final double? width;
  final double? height;

  const ScheduleAppointmentWidget({
    super.key,
    this.width,
    this.height,
    this.onAccept,
    this.onClose,
  });

  @override
  State<ScheduleAppointmentWidget> createState() =>
      _ScheduleAppointmentWidgetState();
}

class _ScheduleAppointmentWidgetState extends State<ScheduleAppointmentWidget> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color darkTextColor = Color(0xFF00444B);
  static const Color lightGrey = Color(0xFFF7F7F7);
  static const Color mediumGrey = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE0E0E0);

  List<DateTime?> selectedDates = [null, null, null];
  List<TimeOfDay?> selectedTimes = [null, null, null];

  List<bool> dateExpanded = [false, false, false];
  List<bool> timeExpanded = [false, false, false];

  // Currently displayed month for calendar
  DateTime displayedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightGrey,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: darkTextColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    const Text(
                      'Para garantizar la mejor experiencia, selecciona 3 potenciales fechas y horas en orden prioritario:',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                        height: 1.36,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: darkTextColor,
                        ),
                        children: [
                          TextSpan(text: 'Selecciona '),
                          TextSpan(
                            text: '2 fechas obligatorias',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' y una opcional'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // First date/time slot (mandatory)
                    _buildDateTimeSlot(0, isRequired: true),

                    const SizedBox(height: 16),

                    // Second date/time slot (mandatory)
                    _buildDateTimeSlot(1, isRequired: true),

                    const SizedBox(height: 16),

                    // Third date/time slot (optional)
                    _buildDateTimeSlot(2, isRequired: false),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Accept button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSlot(int index, {required bool isRequired}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date selector
          _buildDropdownItem(
            label: selectedDates[index] != null
                ? _formatDate(selectedDates[index]!)
                : 'Selecciona la fecha',
            isExpanded: dateExpanded[index],
            isRequired: isRequired && index < 2,
            onTap: () {
              setState(() {
                dateExpanded[index] = !dateExpanded[index];
                if (dateExpanded[index]) {
                  timeExpanded[index] = false;
                }
              });
            },
          ),

          // Calendar dropdown
          if (dateExpanded[index]) _buildCalendar(index),

          // Time selector
          _buildDropdownItem(
            label: selectedTimes[index] != null
                ? _formatTime(selectedTimes[index]!)
                : 'Selecciona la hora',
            isExpanded: timeExpanded[index],
            isRequired: false,
            onTap: () {
              setState(() {
                timeExpanded[index] = !timeExpanded[index];
                if (timeExpanded[index]) {
                  dateExpanded[index] = false;
                }
              });
            },
          ),

          // Time picker dropdown
          if (timeExpanded[index]) _buildTimePicker(index),
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required String label,
    required bool isExpanded,
    required bool isRequired,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkTextColor,
                ),
              ),
            ),
            if (isRequired)
              const Text(
                '*',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
              size: 24,
              color: darkTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(int slotIndex) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(builder: (context) {
                final now = DateTime.now();
                final isCurrentMonth = displayedMonth.year == now.year &&
                    displayedMonth.month == now.month;
                return GestureDetector(
                  onTap: isCurrentMonth
                      ? null
                      : () {
                          setState(() {
                            displayedMonth = DateTime(
                              displayedMonth.year,
                              displayedMonth.month - 1,
                            );
                          });
                        },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: isCurrentMonth
                          ? mediumGrey.withValues(alpha: 0.3)
                          : darkTextColor,
                    ),
                  ),
                );
              }),
              Text(
                _getMonthYearString(displayedMonth),
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkTextColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    displayedMonth = DateTime(
                      displayedMonth.year,
                      displayedMonth.month + 1,
                    );
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: darkTextColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab']
                .map((day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar days
          _buildCalendarDays(slotIndex),
        ],
      ),
    );
  }

  Widget _buildCalendarDays(int slotIndex) {
    final firstDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Empty cells before first day
    for (int i = 0; i < startWeekday; i++) {
      currentRow.add(const SizedBox(width: 32, height: 32));
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Days of month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayedMonth.year, displayedMonth.month, day);
      final isPast = date.isBefore(todayOnly);
      final isSelected = selectedDates[slotIndex] != null &&
          selectedDates[slotIndex]!.year == date.year &&
          selectedDates[slotIndex]!.month == date.month &&
          selectedDates[slotIndex]!.day == date.day;

      currentRow.add(
        GestureDetector(
          onTap: isPast
              ? null
              : () {
                  setState(() {
                    selectedDates[slotIndex] = date;
                    dateExpanded[slotIndex] = false;
                  });
                },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isPast
                      ? mediumGrey.withValues(alpha: 0.4)
                      : isSelected
                          ? Colors.white
                          : darkTextColor,
                ),
              ),
            ),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: currentRow,
            ),
          ),
        );
        currentRow = [];
      }
    }

    // Add remaining days
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const SizedBox(width: 32, height: 32));
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: currentRow,
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildTimePicker(int slotIndex) {
    final currentTime =
        selectedTimes[slotIndex] ?? const TimeOfDay(hour: 6, minute: 30);
    final hour12 =
        currentTime.hourOfPeriod == 0 ? 12 : currentTime.hourOfPeriod;
    final isAM = currentTime.period == DayPeriod.am;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Time picker wheel-like display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour column
                _buildTimeColumn(
                  values: List.generate(
                      12, (i) => '${(i + 1).toString().padLeft(2, '0')}'),
                  selectedValue: hour12.toString().padLeft(2, '0'),
                  onSelect: (value) {
                    final newHour = int.parse(value);
                    final adjustedHour = isAM
                        ? (newHour == 12 ? 0 : newHour)
                        : (newHour == 12 ? 12 : newHour + 12);
                    setState(() {
                      selectedTimes[slotIndex] = TimeOfDay(
                        hour: adjustedHour,
                        minute: currentTime.minute,
                      );
                    });
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: darkTextColor,
                    ),
                  ),
                ),

                // Minute column
                _buildTimeColumn(
                  values: List.generate(
                      12, (i) => '${(i * 5).toString().padLeft(2, '0')}'),
                  selectedValue: currentTime.minute.toString().padLeft(2, '0'),
                  onSelect: (value) {
                    setState(() {
                      selectedTimes[slotIndex] = TimeOfDay(
                        hour: currentTime.hour,
                        minute: int.parse(value),
                      );
                    });
                  },
                ),

                const SizedBox(width: 24),

                // AM/PM toggle
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!isAM) {
                          setState(() {
                            selectedTimes[slotIndex] = TimeOfDay(
                              hour: currentTime.hour - 12,
                              minute: currentTime.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAM ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'AM',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isAM ? Colors.white : mediumGrey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        if (isAM) {
                          setState(() {
                            selectedTimes[slotIndex] = TimeOfDay(
                              hour: currentTime.hour + 12,
                              minute: currentTime.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: !isAM ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PM',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !isAM ? Colors.white : mediumGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn({
    required List<String> values,
    required String selectedValue,
    required Function(String) onSelect,
  }) {
    int selectedIndex = values.indexOf(selectedValue);
    if (selectedIndex == -1) selectedIndex = 0;

    final prevIndex = (selectedIndex - 1 + values.length) % values.length;
    final nextIndex = (selectedIndex + 1) % values.length;

    return Column(
      children: [
        GestureDetector(
          onTap: () => onSelect(values[prevIndex]),
          child: Text(
            values[prevIndex],
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: mediumGrey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            selectedValue,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => onSelect(values[nextIndex]),
          child: Text(
            values[nextIndex],
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: mediumGrey,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
      'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _getMonthYearString(DateTime date) {
    const months = [
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
      'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
