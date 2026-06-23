// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/repositories/visits_repository.dart';
import '/core/result.dart';

// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ListingHQMatchmakingSelectorWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final String? propertyId;
  final VoidCallback? onClose;
  final Function(Map<String, dynamic> operative, DateTime date, TimeOfDay time)? onOperativeSelected;

  /// Slots propuestos por el propietario. Cada entrada es `{ 'date': 'yyyy-MM-dd',
  /// 'time': 'HH:mm' }`. Las dos primeras son obligatorias y la tercera opcional.
  final List<Map<String, String>>? proposedSlots;

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

  @override
  void initState() {
    super.initState();
    // Pre-cargar con la primera opción propuesta por el propietario (matchmaking);
    // si no hay propuesta, por defecto mañana a las 10:00 AM.
    final firstSlot = _parseSlot(widget.proposedSlots?.isNotEmpty == true
        ? widget.proposedSlots!.first
        : null);
    _selectedDate =
        firstSlot?.$1 ?? DateTime.now().add(const Duration(days: 1));
    _selectedTime = firstSlot?.$2 ?? const TimeOfDay(hour: 10, minute: 0);
    _fetchOperatives();
  }

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
      final result = await repo.getAvailableOperatives(_selectedDate!, _selectedTime!);
      
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
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
    if (_selectedOperative != null && _selectedDate != null && _selectedTime != null) {
      widget.onOperativeSelected?.call(_selectedOperative!, _selectedDate!, _selectedTime!);
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
                  onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
              child: Column(
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
                  _buildPickerButton(
                    icon: Icons.access_time,
                    label: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Seleccionar hora',
                    onTap: _pickTime,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 24),

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
              ),
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
        child: Center(child: CircularProgressIndicator()),
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
    return Column(
      children: List.generate(_availableOperatives.length, (index) {
        final operative = _availableOperatives[index];
        final isSelected = _selectedOperative?['id'] == operative['id'];
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
                  color:
                      isSelected ? colorScheme.primary : colorScheme.alternate,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.05)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: operative['photoUrl'] != null
                        ? NetworkImage(operative['photoUrl'] as String)
                        : null,
                    child: operative['photoUrl'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      operative['name'] as String? ?? '',
                      style: colorScheme.bodyMedium.override(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
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
    );
  }

  /// Construye la lista de slots propuestos por el propietario. Las dos primeras
  /// opciones son obligatorias y la tercera (si existe) es opcional.
  List<Widget> _buildProposedSlots() {
    final slots = widget.proposedSlots ?? const [];
    if (slots.isEmpty) {
      return [_buildProposedRow(Icons.calendar_today, 'Sin fechas propuestas')];
    }
    return List.generate(slots.length, (i) {
      final label = i < 2 ? 'Opción ${i + 1} (Obligatoria)' : 'Opción ${i + 1} (Opcional)';
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
            Icon(Icons.chevron_right, size: 20, color: colorScheme.secondaryText),
          ],
        ),
      ),
    );
  }
}
