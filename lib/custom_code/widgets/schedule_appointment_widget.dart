// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/repositories/visits_repository.dart';
import '/core/result.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ScheduleAppointmentWidget extends StatefulWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onClose;
  final VoidCallback? onNavigateToVisits;
  final bool hasPendingVisit;
  final String? propertyId;
  final double? width;
  final double? height;

  const ScheduleAppointmentWidget({
    super.key,
    this.width,
    this.height,
    this.onAccept,
    this.onClose,
    this.onNavigateToVisits,
    this.hasPendingVisit = false,
    this.propertyId,
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

  bool _showPendingModal = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit =>
      selectedDates[0] != null &&
      selectedTimes[0] != null &&
      selectedDates[1] != null &&
      selectedTimes[1] != null;

  @override
  void initState() {
    super.initState();
    _showPendingModal = widget.hasPendingVisit;
  }

  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDates[index] ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            onSurface: darkTextColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedDates[index] = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTimes[index] ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            onSurface: darkTextColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedTimes[index] = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleAccept() async {
    if (widget.propertyId == null || widget.propertyId!.isEmpty) {
      setState(() => _errorMessage = 'Error: No se ha seleccionado una propiedad.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<VisitsRepository>();
      final fmtDate = (DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      final fmtTime = (TimeOfDay t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

      final String slot1 = "${fmtDate(selectedDates[0]!)} ${fmtTime(selectedTimes[0]!)}";
      final String slot2 = "${fmtDate(selectedDates[1]!)} ${fmtTime(selectedTimes[1]!)}";
      final String? slot3 = selectedDates[2] != null && selectedTimes[2] != null
          ? "${fmtDate(selectedDates[2]!)} ${fmtTime(selectedTimes[2]!)}"
          : null;

      if (slot1 == slot2 || (slot3 != null && (slot3 == slot1 || slot3 == slot2))) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Las opciones de fecha y hora deben ser distintas entre sí.';
            _isSubmitting = false;
          });
        }
        return;
      }

      final res = await repo.createVisitRequest(
        propertyId: widget.propertyId!,
        dateOne: fmtDate(selectedDates[0]!),
        hourOne: fmtTime(selectedTimes[0]!),
        dateTwo: fmtDate(selectedDates[1]!),
        hourTwo: fmtTime(selectedTimes[1]!),
        dateThree: selectedDates[2] != null ? fmtDate(selectedDates[2]!) : '0000-00-00',
        hourThree: selectedTimes[2] != null ? fmtTime(selectedTimes[2]!) : '00:00',
      );

      if (!res.isSuccess) {
        if (mounted) {
          setState(() => _errorMessage = res.errorOrNull ?? 'Error al solicitar cita.');
        }
        return;
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop(true);
          }
        });
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(dialogContext).pop(true),
            child: const SizedBox.expand(
              child: Center(
                child: SizedBox(
                  height: 340,
                  child: PopupExitoWidget(
                    title: '¡Solicitud enviada!',
                    text:
                        "Se envió con éxito tu solicitud. Recibirás confirmación de tu próxima visita. Podrás gestionar tu visita en 'Mis visitas'.",
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        widget.onAccept?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        Container(
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
                            onTap: () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                Icons.close,
                                size: 24,
                                color: darkTextColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Screen title
                        const Text(
                          'Agendar cita',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: darkTextColor,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Instructive text
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

                        const SizedBox(height: 12),

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

                        _buildDateTimeSlot(0, isRequired: true),
                        const SizedBox(height: 16),
                        _buildDateTimeSlot(1, isRequired: true),
                        const SizedBox(height: 16),
                        _buildDateTimeSlot(2, isRequired: false),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Inline error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFD32F2F), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 13,
                                color: Color(0xFFD32F2F),
                                height: 1.4,
                              ),
                            ),
                          ),
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
                      onPressed: _canSubmit ? _handleAccept : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor:
                            primaryColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
        ),

        // Pending visit modal
        if (_showPendingModal)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 48,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ya tienes una visita pendiente o aprobada para este inmueble.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: darkTextColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Visualiza y gestiona tu visita en "Mis visitas".',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: mediumGrey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onNavigateToVisits?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Ver mis visitas',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Volver al perfil del inmueble',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: mediumGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
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
          _buildPickerRow(
            label: selectedDates[index] != null
                ? _formatDate(selectedDates[index]!)
                : 'Selecciona la fecha',
            isRequired: isRequired,
            hasValue: selectedDates[index] != null,
            icon: Icons.calendar_today_outlined,
            onTap: () => _pickDate(index),
          ),
          const Divider(height: 1, color: borderColor),
          _buildPickerRow(
            label: selectedTimes[index] != null
                ? _formatTime(selectedTimes[index]!)
                : 'Selecciona la hora',
            isRequired: isRequired,
            hasValue: selectedTimes[index] != null,
            icon: Icons.access_time_outlined,
            onTap: () => _pickTime(index),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerRow({
    required String label,
    required bool isRequired,
    required bool hasValue,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasValue ? darkTextColor : mediumGrey,
                ),
              ),
            ),
            if (isRequired)
              const Text(
                '*',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: mediumGrey,
            ),
          ],
        ),
      ),
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
}
