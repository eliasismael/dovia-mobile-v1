import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';

class RescheduleVisitWidget extends StatefulWidget {
  final String visitId;
  /// Pass the current visit substatus so the widget knows if rescheduling is allowed.
  /// Allowed: 'PENDING', 'RESCHEDULE_REQUIRED'. Otherwise shows info panel.
  final String visitSubstatus;

  const RescheduleVisitWidget({
    super.key,
    required this.visitId,
    this.visitSubstatus = '',
  });

  @override
  State<RescheduleVisitWidget> createState() => _RescheduleVisitWidgetState();
}

class _RescheduleVisitWidgetState extends State<RescheduleVisitWidget> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color darkTextColor = Color(0xFF00444B);
  static const Color lightGrey = Color(0xFFF7F7F7);
  static const Color mediumGrey = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE0E0E0);

  final List<DateTime?> _dates = [null, null, null];
  final List<TimeOfDay?> _times = [null, null, null];

  bool _isSubmitting = false;
  String? _errorMessage;

  /// Only PENDING or RESCHEDULE_REQUIRED allow the reschedule endpoint
  bool get _canReschedule {
    final sub = widget.visitSubstatus.toUpperCase();
    return sub == 'PENDING' || sub == 'RESCHEDULE_REQUIRED';
  }

  bool get _canSubmit =>
      _dates[0] != null &&
      _times[0] != null &&
      _dates[1] != null &&
      _times[1] != null;

  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dates[index] ?? today,
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
    if (picked != null && mounted) {
      setState(() {
        _dates[index] = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index] ?? const TimeOfDay(hour: 9, minute: 0),
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
    if (picked != null && mounted) {
      setState(() {
        _times[index] = picked;
        _errorMessage = null;
      });
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${d.day} de ${months[d.month - 1]}, ${d.year}';
  }

  String _displayTime(TimeOfDay t) {
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final slot1 = '${_fmtDate(_dates[0]!)} ${_fmtTime(_times[0]!)}';
    final slot2 = '${_fmtDate(_dates[1]!)} ${_fmtTime(_times[1]!)}';
    final hasSlot3 = _dates[2] != null && _times[2] != null;
    final slot3 = hasSlot3 ? '${_fmtDate(_dates[2]!)} ${_fmtTime(_times[2]!)}' : null;

    if (slot1 == slot2 || (slot3 != null && (slot3 == slot1 || slot3 == slot2))) {
      setState(() => _errorMessage = 'Las opciones de fecha y hora deben ser distintas entre sí.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final res = await DOVIAAPIVisitContextGroup.rescheduleVisitCall.call(
      visitId: widget.visitId,
      authToken: currentAuthenticationToken,
      dateOne: _fmtDate(_dates[0]!),
      hourOne: _fmtTime(_times[0]!),
      dateTwo: _fmtDate(_dates[1]!),
      hourTwo: _fmtTime(_times[1]!),
      dateThree: hasSlot3 ? _fmtDate(_dates[2]!) : '0000-00-00',
      hourThree: hasSlot3 ? _fmtTime(_times[2]!) : '00:00',
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!res.succeeded) {
      final body = res.jsonBody;
      final msg = body is Map
          ? (body['message'] ?? 'Error al reagendar la visita.')
          : 'Error al reagendar la visita.';
      setState(() => _errorMessage = msg.toString());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
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
                    text: 'Tu solicitud de reagendamiento fue enviada con éxito. Recibirás confirmación de tu nueva visita.',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightGrey,
      child: SafeArea(
        child: _canReschedule ? _buildForm() : _buildBlockedInfo(),
      ),
    );
  }

  // ─── Blocked state: visita ya confirmada/asignada ─────────────────────────
  Widget _buildBlockedInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, size: 24, color: darkTextColor),
            ),
          ),
          const SizedBox(height: 16),

          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy_outlined, size: 40, color: primaryColor),
          ),
          const SizedBox(height: 20),

          const Text(
            'No es posible reagendar en este momento',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkTextColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Tu visita ya está confirmada y tiene un asesor DOVIA asignado. Para solicitar un cambio de fecha, comunícate directamente con nuestro equipo.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: mediumGrey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Recuerda: cancela tu visita actual primero si deseas agendar una nueva fecha.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFFAAAAAA),
              height: 1.5,
            ),
          ),

          const Spacer(),

          // Contact DOVIA button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
              label: const Text(
                'Contactar a DOVIA',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Back button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Volver',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reschedule form ──────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.close, size: 24, color: darkTextColor),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reagendar visita',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Selecciona hasta 3 nuevas fechas y horas de preferencia en orden prioritario:',
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
                    style: TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: darkTextColor),
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
                _buildSlot(0, isRequired: true),
                const SizedBox(height: 16),
                _buildSlot(1, isRequired: true),
                const SizedBox(height: 16),
                _buildSlot(2, isRequired: false),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13, color: Color(0xFFD32F2F), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'Confirmar reagendamiento',
                      style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlot(int index, {required bool isRequired}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildRow(
            label: _dates[index] != null ? _displayDate(_dates[index]!) : 'Selecciona la fecha',
            isRequired: isRequired,
            hasValue: _dates[index] != null,
            icon: Icons.calendar_today_outlined,
            onTap: () => _pickDate(index),
          ),
          const Divider(height: 1, color: borderColor),
          _buildRow(
            label: _times[index] != null ? _displayTime(_times[index]!) : 'Selecciona la hora',
            isRequired: isRequired,
            hasValue: _times[index] != null,
            icon: Icons.access_time_outlined,
            onTap: () => _pickTime(index),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
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
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 14, fontWeight: FontWeight.w600, color: hasValue ? darkTextColor : mediumGrey),
              ),
            ),
            if (isRequired)
              const Text('*', style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 22, color: mediumGrey),
          ],
        ),
      ),
    );
  }
}
