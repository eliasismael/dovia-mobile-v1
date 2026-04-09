// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import 'index.dart'; // Imports other custom widgets

import 'package:flutter_svg/flutter_svg.dart';

class DoviaClientMisPropiedadesAgendarVisita extends StatefulWidget {
  final double? width;
  final double? height;

  // Callbacks for page variables
  final Future Function(String dateOne)? onDateOne;
  final Future Function(String hourOne)? onHourOne;
  final Future Function(String dateTwo)? onDateTwo;
  final Future Function(String hourTwo)? onHourTwo;
  final Future Function(String dateThree)? onDateThree;
  final Future Function(String hourThree)? onHourThree;
  final VoidCallback? onContinue;

  const DoviaClientMisPropiedadesAgendarVisita({
    super.key,
    this.width,
    this.height,
    this.onDateOne,
    this.onHourOne,
    this.onDateTwo,
    this.onHourTwo,
    this.onDateThree,
    this.onHourThree,
    this.onContinue,
  });

  @override
  State<DoviaClientMisPropiedadesAgendarVisita> createState() =>
      _DoviaClientMisPropiedadesAgendarVisitaState();
}

class _DoviaClientMisPropiedadesAgendarVisitaState
    extends State<DoviaClientMisPropiedadesAgendarVisita> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color cardBackground = Colors.white;
  static const Color infoCardColor = Color(0xFF00444B);
  static const Color errorColor = Color(0xFFD32F2F);

  // 3 slots for date/time pairs
  DateTime? _date1;
  TimeOfDay? _time1;
  DateTime? _date2;
  TimeOfDay? _time2;
  DateTime? _date3;
  TimeOfDay? _time3;

  bool _showThirdOption = false;

  /// Whether at least 2 complete pairs are filled
  bool get _canContinue {
    final pair1Complete = _date1 != null && _time1 != null;
    final pair2Complete = _date2 != null && _time2 != null;
    final pair3Complete = _date3 != null && _time3 != null;

    int completePairs = 0;
    if (pair1Complete) completePairs++;
    if (pair2Complete) completePairs++;
    if (pair3Complete) completePairs++;

    return completePairs >= 2;
  }

  /// Format DateTime to "2026-02-15"
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format TimeOfDay to "10:00"
  String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      color: backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildMaterialIncludesList(),
              const SizedBox(height: 16),
              _buildContentDescription(),
              const SizedBox(height: 32),

              // ── Option 1 ──
              _buildOptionLabel('Opción 1', required: true),
              const SizedBox(height: 8),
              _buildDateSelector(
                selectedDate: _date1,
                onPicked: (picked) {
                  setState(() => _date1 = picked);
                  widget.onDateOne?.call(_dateToString(picked));
                },
              ),
              const SizedBox(height: 8),
              _buildTimeSelector(
                selectedTime: _time1,
                onPicked: (picked) {
                  setState(() => _time1 = picked);
                  widget.onHourOne?.call(_timeToString(picked));
                },
              ),

              const SizedBox(height: 24),

              // ── Option 2 ──
              _buildOptionLabel('Opción 2', required: true),
              const SizedBox(height: 8),
              _buildDateSelector(
                selectedDate: _date2,
                onPicked: (picked) {
                  setState(() => _date2 = picked);
                  widget.onDateTwo?.call(_dateToString(picked));
                },
              ),
              const SizedBox(height: 8),
              _buildTimeSelector(
                selectedTime: _time2,
                onPicked: (picked) {
                  setState(() => _time2 = picked);
                  widget.onHourTwo?.call(_timeToString(picked));
                },
              ),

              const SizedBox(height: 24),

              // ── Option 3 (optional, toggleable) ──
              if (!_showThirdOption)
                _buildAddThirdOptionButton()
              else ...[
                _buildOptionLabel('Opción 3', required: false),
                const SizedBox(height: 8),
                _buildDateSelector(
                  selectedDate: _date3,
                  onPicked: (picked) {
                    setState(() => _date3 = picked);
                    widget.onDateThree?.call(_dateToString(picked));
                  },
                ),
                const SizedBox(height: 8),
                _buildTimeSelector(
                  selectedTime: _time3,
                  onPicked: (picked) {
                    setState(() => _time3 = picked);
                    widget.onHourThree?.call(_timeToString(picked));
                  },
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showThirdOption = false;
                        _date3 = null;
                        _time3 = null;
                      });
                      // Clear the page variables
                      widget.onDateThree?.call('');
                      widget.onHourThree?.call('');
                    },
                    child: const Text(
                      'Eliminar opción 3',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: errorColor,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Info card
              _buildInfoCard(),

              const SizedBox(height: 24),

              // Continue button
              _buildContinueButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Option label ───────────────────────────────────────────────────
  Widget _buildOptionLabel(String label, {required bool required}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 6),
        if (required)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Requerida',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(40),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Opcional',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withAlpha(150),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Add third option button ────────────────────────────────────────
  Widget _buildAddThirdOptionButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _showThirdOption = true);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primaryColor.withAlpha(80),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: primaryColor, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Agregar tercera opción (opcional)',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona al menos dos opciones de fecha y hora para la visita',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            letterSpacing: 0.28,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nuestro asociado llegará en la fecha y hora que elijas para crear el material profesional con el que tu propiedad será publicada.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor.withAlpha(179),
            letterSpacing: 0.28,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ─── Material includes ──────────────────────────────────────────────
  Widget _buildMaterialIncludesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Este material incluye:',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        _buildListItem(Icons.camera_alt_outlined, 'Fotos profesionales'),
        const SizedBox(height: 8),
        _buildListItem(Icons.view_in_ar_outlined, 'Recorrido virtual'),
        const SizedBox(height: 8),
        _buildListItem(Icons.architecture_outlined, 'Plano'),
        const SizedBox(height: 8),
        _buildListItem(
          Icons.edit_outlined,
          'Descripción de tu propiedad y del entorno',
        ),
        const SizedBox(height: 8),
        _buildListItem(
          Icons.lightbulb_outline,
          'Elaboración de gancho de venta',
        ),
      ],
    );
  }

  Widget _buildListItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentDescription() {
    return Text(
      'Este contenido nos permite presentar tu propiedad con la mejor calidad posible y atraer compradores reales.',
      style: TextStyle(
        fontFamily: 'Public Sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor.withAlpha(179),
        letterSpacing: 0.28,
        height: 1.4,
      ),
    );
  }

  // ─── Generic date selector ─────────────────────────────────────────
  Widget _buildDateSelector({
    required DateTime? selectedDate,
    required void Function(DateTime) onPicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: textColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(33),
              blurRadius: 14,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: selectedDate != null
                      ? primaryColor
                      : textColor.withAlpha(128),
                ),
                const SizedBox(width: 10),
                Text(
                  selectedDate != null
                      ? _formatDateDisplay(selectedDate)
                      : 'Selecciona la fecha',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedDate != null
                        ? textColor
                        : textColor.withAlpha(128),
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: textColor, size: 24),
          ],
        ),
      ),
    );
  }

  // ─── Generic time selector ─────────────────────────────────────────
  Widget _buildTimeSelector({
    required TimeOfDay? selectedTime,
    required void Function(TimeOfDay) onPicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: textColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(33),
              blurRadius: 14,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 18,
                  color: selectedTime != null
                      ? primaryColor
                      : textColor.withAlpha(128),
                ),
                const SizedBox(width: 10),
                Text(
                  selectedTime != null
                      ? _formatTimeDisplay(selectedTime)
                      : 'Selecciona la hora',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedTime != null
                        ? textColor
                        : textColor.withAlpha(128),
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: textColor, size: 24),
          ],
        ),
      ),
    );
  }

  // ─── Info card ──────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: infoCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Te enviaremos los datos del asociado',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.28,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Antes de la visita recibirás su nombre, fotografía y número de contacto para que sientas totalmente seguro y tranquilo.',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 0.28,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Además, junto con esta información te compartiremos el acuerdo de autorización de comercialización, un documento sencillo que nos permite preparar y publicar tu propiedad de manera formal y transparente.',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 0.28,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.string(
                '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 4C12 4 6 4 6 10V14C6 20 12 20 12 20C12 20 18 20 18 14V10C18 4 12 4 12 4Z" fill="white"/>
                </svg>''',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Continue button ────────────────────────────────────────────────
  Widget _buildContinueButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_canContinue)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Debes completar al menos 2 opciones de fecha y hora',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor.withAlpha(150),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _canContinue ? widget.onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              disabledBackgroundColor: primaryColor.withAlpha(100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Display formatters (human-readable) ────────────────────────────
  String _formatDateDisplay(DateTime date) {
    final months = [
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
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTimeDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
