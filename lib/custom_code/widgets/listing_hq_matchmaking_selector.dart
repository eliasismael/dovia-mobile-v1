// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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

  const ListingHQMatchmakingSelectorWidget({
    super.key,
    this.width,
    this.height,
    this.propertyId,
    this.onClose,
    this.onOperativeSelected,
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
    // Default to tomorrow 10:00 AM
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    _fetchOperatives();
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
    
    return Container(
      width: widget.width ?? 800,
      height: widget.height ?? 600,
      decoration: BoxDecoration(
        color: colorScheme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Asignar Operative Listing',
                  style: colorScheme.headlineSmall.override(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.primaryText),
                  onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Split Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT PANEL: Input (Dates & Time)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: colorScheme.alternate, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Propuestas del dueño
                        Container(
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
                                'Fechas sugeridas por el propietario',
                                style: colorScheme.bodyMedium.override(
                                  fontFamily: 'Public Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildMockProposedSlot('Opción 1 (Obligatoria)', '12 Oct, 2026 - 10:00 AM'),
                              _buildMockProposedSlot('Opción 2 (Obligatoria)', '14 Oct, 2026 - 03:00 PM'),
                              _buildMockProposedSlot('Opción 3 (Opcional)', '15 Oct, 2026 - 11:30 AM'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          'Selecciona la fecha y hora final',
                          style: colorScheme.titleMedium.override(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Date Picker Button
                        _buildPickerButton(
                          icon: Icons.calendar_today,
                          label: _selectedDate != null 
                              ? DateFormat('dd MMM, yyyy').format(_selectedDate!) 
                              : 'Seleccionar día',
                          onTap: _pickDate,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),
                        
                        // Time Picker Button
                        _buildPickerButton(
                          icon: Icons.access_time,
                          label: _selectedTime != null 
                              ? _selectedTime!.format(context) 
                              : 'Seleccionar hora',
                          onTap: _pickTime,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // RIGHT PANEL: Results
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operative Listing disponibles',
                          style: colorScheme.titleMedium.override(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Expanded(
                          child: _isLoading 
                              ? const Center(child: CircularProgressIndicator())
                              : _availableOperatives.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No hay Operatives disponibles para esta fecha y hora.',
                                        style: colorScheme.bodyMedium,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _availableOperatives.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final operative = _availableOperatives[index];
                                        final isSelected = _selectedOperative?['id'] == operative['id'];
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedOperative = operative;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected ? colorScheme.primary : colorScheme.alternate,
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
                                        );
                                      },
                                    ),
                        ),
                        
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(color: colorScheme.secondaryText),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _selectedOperative == null ? null : _handleAccept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Aceptar y Continuar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockProposedSlot(String label, String value) {
    final colorScheme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: colorScheme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
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
