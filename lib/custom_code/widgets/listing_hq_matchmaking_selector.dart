// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/repositories/visits_repository.dart';
import '/core/result.dart';
import '/shared_components/dovia_spinner.dart';

// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ListingHQMatchmakingSelectorWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final String? propertyId;
  final VoidCallback? onClose;
  final Function(Map<String, dynamic> operative, DateTime date, TimeOfDay time)?
      onOperativeSelected;

  /// Slots propuestos por el propietario. Cada entrada es `{ 'date': 'yyyy-MM-dd',
  /// 'time': 'HH:mm' }`. Las dos primeras son obligatorias y la tercera opcional.
  final List<Map<String, String>>? proposedSlots;

  /// Disponibilidad semanal propuesta por el propietario, como
  /// `{ 'dayOfWeek': 'WEDNESDAY', 'startTime': '09:00', 'endTime': '12:00' }`.
  /// Es lo que usan las `OPERATIVE_LISTER_VISIT`. Cuando viene, el selector
  /// solo ofrece fechas y horas dentro de estos rangos: el backend rechaza
  /// cualquier otra con `SLOT_OUTSIDE_CLIENT_PROPOSED_AVAILABILITY`.
  final List<Map<String, String>>? availabilityRanges;

  /// Teléfono del propietario, ya formateado (ej. "+52 5512345678").
  final String? ownerPhone;

  const ListingHQMatchmakingSelectorWidget({
    super.key,
    this.width,
    this.height,
    this.propertyId,
    this.onClose,
    this.onOperativeSelected,
    this.proposedSlots,
    this.availabilityRanges,
    this.ownerPhone,
  });

  @override
  State<ListingHQMatchmakingSelectorWidget> createState() =>
      _ListingHQMatchmakingSelectorWidgetState();
}

class _ListingHQMatchmakingSelectorWidgetState
    extends State<ListingHQMatchmakingSelectorWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;
  List<Map<String, dynamic>> _availableOperatives = [];
  Map<String, dynamic>? _selectedOperative;

  /// Duración fija del slot de visita definida por el backend.
  static const Duration _kSlotDuration = Duration(hours: 1);

  static const Map<String, int> _kWeekdayByName = {
    'MONDAY': DateTime.monday,
    'TUESDAY': DateTime.tuesday,
    'WEDNESDAY': DateTime.wednesday,
    'THURSDAY': DateTime.thursday,
    'FRIDAY': DateTime.friday,
    'SATURDAY': DateTime.saturday,
    'SUNDAY': DateTime.sunday,
  };

  static const Map<int, String> _kWeekdayLabel = {
    DateTime.monday: 'Lunes',
    DateTime.tuesday: 'Martes',
    DateTime.wednesday: 'Miércoles',
    DateTime.thursday: 'Jueves',
    DateTime.friday: 'Viernes',
    DateTime.saturday: 'Sábado',
    DateTime.sunday: 'Domingo',
  };

  List<Map<String, String>> get _ranges =>
      widget.availabilityRanges ?? const [];

  bool get _hasRanges => _ranges.isNotEmpty;

  @override
  void initState() {
    super.initState();

    if (_hasRanges) {
      // La visita trae disponibilidad semanal: arrancar en la primera fecha
      // futura que caiga en un día ofrecido, a su primera hora válida.
      final date = _firstAllowedDate();
      _selectedDate = date;
      final slots = date == null ? const <TimeOfDay>[] : _slotsForDate(date);
      _selectedTime = slots.isNotEmpty ? slots.first : null;
    } else {
      // Sin rangos, se conserva el comportamiento previo: primera opción
      // propuesta, o mañana a las 10:00.
      final firstSlot = _parseSlot(widget.proposedSlots?.isNotEmpty == true
          ? widget.proposedSlots!.first
          : null);
      _selectedDate =
          firstSlot?.$1 ?? DateTime.now().add(const Duration(days: 1));
      _selectedTime = firstSlot?.$2 ?? const TimeOfDay(hour: 10, minute: 0);
    }

    _fetchOperatives();
  }

  /// `HH:mm` a `TimeOfDay`. Null si no se puede interpretar.
  TimeOfDay? _parseHhMm(String? value) {
    final parts = (value ?? '').split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Días de la semana que ofreció el propietario.
  Set<int> get _allowedWeekdays => _ranges
      .map((r) => _kWeekdayByName[r['dayOfWeek']?.toUpperCase() ?? ''])
      .whereType<int>()
      .toSet();

  bool _isAllowedDate(DateTime date) =>
      _allowedWeekdays.contains(date.weekday) && _slotsForDate(date).isNotEmpty;

  /// Horas de inicio válidas para [date]: se recorre cada rango de ese día en
  /// pasos de una hora mientras el slot completo entre antes de `endTime`, y
  /// se descartan las horas ya pasadas si la fecha es hoy.
  List<TimeOfDay> _slotsForDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final slotMinutes = _kSlotDuration.inMinutes;

    final result = <int>{};
    for (final range in _ranges) {
      if (_kWeekdayByName[range['dayOfWeek']?.toUpperCase() ?? ''] !=
          date.weekday) {
        continue;
      }
      final start = _parseHhMm(range['startTime']);
      final end = _parseHhMm(range['endTime']);
      if (start == null || end == null) continue;

      for (var m = _minutes(start);
          m + slotMinutes <= _minutes(end);
          m += slotMinutes) {
        if (isToday && m <= now.hour * 60 + now.minute) continue;
        result.add(m);
      }
    }

    final sorted = result.toList()..sort();
    return sorted.map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60)).toList();
  }

  /// Primera fecha, desde hoy, que caiga en un día ofrecido y todavía tenga
  /// alguna hora disponible. Se busca hasta 90 días adelante.
  DateTime? _firstAllowedDate() {
    final today = DateTime.now();
    for (var i = 0; i < 90; i++) {
      final candidate =
          DateTime(today.year, today.month, today.day).add(Duration(days: i));
      if (_isAllowedDate(candidate)) return candidate;
    }
    return null;
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Convierte un slot `{ date, time }` en `(DateTime, TimeOfDay)`.
  /// Devuelve `null` si no se puede interpretar.
  (DateTime, TimeOfDay)? _parseSlot(Map<String, String>? slot) {
    if (slot == null) return null;
    final dateStr = slot['date'] ?? '';
    final timeStr = slot['time'] ?? '';
    if (dateStr.isEmpty) return null;
    try {
      final date = DateTime.parse(dateStr);
      var hour = 10;
      var minute = 0;
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        hour = int.tryParse(parts[0]) ?? 10;
        minute = int.tryParse(parts[1]) ?? 0;
      }
      return (date, TimeOfDay(hour: hour, minute: minute));
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchOperatives() async {
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() {
      _isLoading = true;
      _selectedOperative = null;
    });

    try {
      final repo = context.read<VisitsRepository>();
      final result =
          await repo.getAvailableOperatives(_selectedDate!, _selectedTime!);

      if (result.isSuccess && mounted) {
        setState(() {
          _availableOperatives = result.dataOrNull ?? [];
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _availableOperatives = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _availableOperatives = [];
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Con rangos, el calendario deshabilita los días que el propietario no
    // ofreció, así no se puede elegir uno que el backend vaya a rechazar.
    final initial = _hasRanges
        ? (_selectedDate != null && _isAllowedDate(_selectedDate!)
            ? _selectedDate!
            : (_firstAllowedDate() ?? today))
        : (_selectedDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(now.year + 1),
      selectableDayPredicate: _hasRanges ? _isAllowedDate : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: FlutterFlowTheme.of(context).primary,
            onPrimary: Colors.white,
            onSurface: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (_hasRanges) {
          // La hora elegida antes puede no existir en el nuevo día.
          final slots = _slotsForDate(picked);
          final keep = _selectedTime != null &&
              slots.any((s) => _minutes(s) == _minutes(_selectedTime!));
          _selectedTime =
              keep ? _selectedTime : (slots.isNotEmpty ? slots.first : null);
        }
      });
      _fetchOperatives();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: FlutterFlowTheme.of(context).primary,
            onPrimary: Colors.white,
            onSurface: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _fetchOperatives();
    }
  }

  void _handleAccept() {
    if (_selectedOperative != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      widget.onOperativeSelected
          ?.call(_selectedOperative!, _selectedDate!, _selectedTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = FlutterFlowTheme.of(context);

    // Cuando se usa como página completa (ancho/alto infinito) no aplicamos
    // esquinas redondeadas para que ocupe toda la pantalla.
    final bool isFullPage =
        widget.width == double.infinity || widget.height == double.infinity;

    return Container(
      width: widget.width ?? 800,
      height: widget.height ?? 600,
      decoration: BoxDecoration(
        color: colorScheme.secondaryBackground,
        borderRadius:
            isFullPage ? BorderRadius.zero : BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.primaryText),
                  onPressed:
                      widget.onClose ?? () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Asignar Operative Listing',
                    style: colorScheme.headlineSmall.override(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Contenido en una sola columna (mobile: una cosa debajo de otra).
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 700;

                final leftPanel = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contexto: fechas propuestas por el propietario + teléfono.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.accent1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.accent1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha ingresada por el propietario',
                            style: colorScheme.bodyMedium.override(
                              fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._buildProposedSlots(),
                          if (widget.ownerPhone != null &&
                              widget.ownerPhone!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _buildProposedRow(
                              Icons.phone,
                              'Propietario: ${widget.ownerPhone}',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selección manual de fecha y hora.
                    Text(
                      'Selecciona la fecha y hora final',
                      style: colorScheme.titleMedium.override(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPickerButton(
                      icon: Icons.calendar_today,
                      label: _selectedDate != null
                          ? DateFormat('dd MMM, yyyy').format(_selectedDate!)
                          : 'Seleccionar día',
                      onTap: _pickDate,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    if (_hasRanges)
                      _buildSlotChips(colorScheme)
                    else
                      _buildPickerButton(
                        icon: Icons.access_time,
                        label: _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Seleccionar hora',
                        onTap: _pickTime,
                        colorScheme: colorScheme,
                      ),
                  ],
                );

                final rightPanel = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Operative Listers disponibles para esa fecha/hora.
                    Text(
                      'Operative Listing disponibles',
                      style: colorScheme.titleMedium.override(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOperativesSection(colorScheme),
                  ],
                );

                if (isDesktop) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(child: leftPanel),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(child: rightPanel),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leftPanel,
                      const SizedBox(height: 24),
                      rightPanel,
                    ],
                  ),
                );
              },
            ),
          ),

          // Botón de acción fijo en la parte inferior.
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedOperative == null ? null : _handleAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor:
                        colorScheme.primary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Aceptar y Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de Operative Listers disponibles. No scrollea por sí misma; el scroll
  /// lo maneja la columna de la página completa.
  Widget _buildOperativesSection(FlutterFlowTheme colorScheme) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: DoviaSpinner()),
      );
    }
    if (_availableOperatives.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          'No hay Operatives disponibles para esta fecha y hora.',
          style: colorScheme.bodyMedium,
        ),
      );
    }

    final visible = _filteredOperatives;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador: casi todos los operativos comparten el mismo nombre, así
        // que sin filtrar por email es imposible dar con uno concreto.
        TextField(
          onChanged: (value) => setState(() => _search = value),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o email',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          style: colorScheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Ningún operative coincide con "$_search".',
              style: colorScheme.bodyMedium,
            ),
          ),
        ...List.generate(visible.length, (index) {
          final operative = visible[index];
          final isSelected = _selectedOperative?['id'] == operative['id'];
          final email = operative['email'] as String? ?? '';
          final matchesSearch =
              _search.trim().isNotEmpty && _matches(operative, _search);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedOperative = operative;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : (matchesSearch
                            ? const Color(0xFFE8A200)
                            : colorScheme.alternate),
                    width: isSelected || matchesSearch ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.05)
                      : (matchesSearch
                          ? const Color(0xFFFFF1CC)
                          : Colors.transparent),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          (operative['photoUrl'] as String?)?.isNotEmpty ??
                                  false
                              ? NetworkImage(operative['photoUrl'] as String)
                              : null,
                      // Sin este callback, una URL de avatar rota tira excepción
                      // en cada repintado.
                      onBackgroundImageError:
                          (operative['photoUrl'] as String?)?.isNotEmpty ??
                                  false
                              ? (_, __) {}
                              : null,
                      child: (operative['photoUrl'] as String?)?.isNotEmpty ??
                              false
                          ? null
                          : const Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            operative['name'] as String? ?? '',
                            style: colorScheme.bodyMedium.override(
                              fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: colorScheme.bodySmall.override(
                                fontFamily: 'Public Sans',
                                color: colorScheme.secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Texto del buscador de operativos.
  String _search = '';

  bool _matches(Map<String, dynamic> operative, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;
    final name = (operative['name'] as String? ?? '').toLowerCase();
    final email = (operative['email'] as String? ?? '').toLowerCase();
    return name.contains(q) || email.contains(q);
  }

  List<Map<String, dynamic>> get _filteredOperatives {
    if (_search.trim().isEmpty) return _availableOperatives;
    return _availableOperatives.where((o) => _matches(o, _search)).toList();
  }

  /// Construye la lista de slots propuestos por el propietario. Las dos primeras
  /// opciones son obligatorias y la tercera (si existe) es opcional.
  /// Horas de inicio válidas del día elegido, como chips. Evita el reloj libre,
  /// que dejaba elegir horas fuera de la disponibilidad del propietario.
  Widget _buildSlotChips(FlutterFlowTheme colorScheme) {
    final date = _selectedDate;
    final slots = date == null ? const <TimeOfDay>[] : _slotsForDate(date);

    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8D5D5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBC0000)),
        ),
        child: Text(
          'Ese día no tiene horarios disponibles. Elegí otra fecha.',
          style: colorScheme.bodyMedium.override(
            fontFamily: 'Public Sans',
            color: const Color(0xFFBC0000),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final selected =
            _selectedTime != null && _minutes(slot) == _minutes(_selectedTime!);
        return ChoiceChip(
          label: Text(_formatTime(slot)),
          selected: selected,
          onSelected: (_) {
            setState(() => _selectedTime = slot);
            _fetchOperatives();
          },
          selectedColor: colorScheme.primary,
          backgroundColor: colorScheme.secondaryBackground,
          labelStyle: colorScheme.bodyMedium.override(
            fontFamily: 'Public Sans',
            color: selected ? Colors.white : colorScheme.primaryText,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.primary),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildProposedSlots() {
    // Para una visita de operative listing, lo que propuso el propietario es
    // disponibilidad semanal, no fechas concretas.
    if (_hasRanges) {
      return _ranges.map((range) {
        final weekday =
            _kWeekdayByName[range['dayOfWeek']?.toUpperCase() ?? ''];
        final label = _kWeekdayLabel[weekday] ?? (range['dayOfWeek'] ?? '');
        final start = range['startTime'] ?? '';
        final end = range['endTime'] ?? '';
        return _buildProposedRow(
          Icons.calendar_today,
          '$label de $start a $end',
        );
      }).toList();
    }

    final slots = widget.proposedSlots ?? const [];
    if (slots.isEmpty) {
      return [_buildProposedRow(Icons.calendar_today, 'Sin fechas propuestas')];
    }
    return List.generate(slots.length, (i) {
      final label = i < 2
          ? 'Opción ${i + 1} (Obligatoria)'
          : 'Opción ${i + 1} (Opcional)';
      return _buildProposedRow(
        Icons.calendar_today,
        '$label: ${_formatSlot(slots[i])}',
      );
    });
  }

  /// Formatea un slot `{ date, time }` como "dd MMM, yyyy - hh:mm a".
  String _formatSlot(Map<String, String> slot) {
    final parsed = _parseSlot(slot);
    if (parsed == null) {
      final date = slot['date'] ?? '';
      final time = slot['time'] ?? '';
      return [date, time].where((s) => s.isNotEmpty).join(' - ');
    }
    final dt = DateTime(parsed.$1.year, parsed.$1.month, parsed.$1.day,
        parsed.$2.hour, parsed.$2.minute);
    return DateFormat('dd MMM, yyyy - hh:mm a').format(dt);
  }

  Widget _buildProposedRow(IconData icon, String text) {
    final colorScheme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colorScheme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: colorScheme.bodySmall.override(
                fontFamily: 'Public Sans',
                color: colorScheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required FlutterFlowTheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.alternate),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: colorScheme.bodyMedium.override(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                size: 20, color: colorScheme.secondaryText),
          ],
        ),
      ),
    );
  }
}
