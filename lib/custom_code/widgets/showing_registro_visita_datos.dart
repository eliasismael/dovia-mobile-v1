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

class ShowingRegistroVisitaDatos extends StatefulWidget {
  final double? width;
  final double? height;

  // Callbacks
  final VoidCallback? onFinalizarRegistro;
  final Function? onSave;

  const ShowingRegistroVisitaDatos({
    super.key,
    this.width,
    this.height,
    this.onFinalizarRegistro,
    this.onSave,
  });

  @override
  State<ShowingRegistroVisitaDatos> createState() =>
      _ShowingRegistroVisitaDatosState();
}

class _ShowingRegistroVisitaDatosState
    extends State<ShowingRegistroVisitaDatos> {
  // ==================== COLORS ====================
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color inputBorderColor = Color(0x1A000000);
  static const Color greyTextColor = Color(0xFF99A1AF);
  static const Color confirmBg = Color(0x3370ACAD);

  // ==================== FORM STATE ====================
  // Datos básicos
  String?
      _selectedVisitType; // Primera visita, Segunda visita, Visita de seguimiento
  String? _selectedDuration; // < 15 min, 15–30 min, +30 min

  // Asistentes
  String? _selectedAttendees; // No, Pareja, Familiar, Otro

  // Estado del inmueble
  int _generalConditionRating = 0;
  String? _selectedCondition; // Limpio, Requiere mantenimiento, En obra
  String? _matchesPublished; // Sí, No

  // Reacción del cliente
  String? _selectedInterest; // Alto, Medio, Bajo
  String?
      _selectedReason; // Precio, Ubicación, Tamaño, Estado del inmueble, Otro

  // Próximo paso
  String? _selectedNextStep;

  // Evidencia
  final _commentController = TextEditingController();

  // Confirmación
  bool _confirmed = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final data = {
      'visitType': _selectedVisitType,
      'duration': _selectedDuration,
      'attendees': _selectedAttendees,
      'generalCondition': _generalConditionRating,
      'condition': _selectedCondition,
      'matchesPublished': _matchesPublished,
      'interest': _selectedInterest,
      'reason': _selectedReason,
      'nextStep': _selectedNextStep,
      'comment': _commentController.text,
      'confirmed': _confirmed,
    };

    if (widget.onSave != null) {
      widget.onSave!(data);
    }
    if (widget.onFinalizarRegistro != null) {
      widget.onFinalizarRegistro!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== SECTION 1: DATOS BÁSICOS DE LA VISITA ==========
              _buildSection1DatosBasicos(),
              const SizedBox(height: 32),

              // ========== SECTION 2: ASISTENTES A LA VISITA ==========
              _buildSection2Asistentes(),
              const SizedBox(height: 32),

              // ========== SECTION 3: ESTADO DEL INMUEBLE ==========
              _buildSection3EstadoInmueble(),
              const SizedBox(height: 32),

              // ========== SECTION 4: REACCIÓN DEL CLIENTE ==========
              _buildSection4ReaccionCliente(),
              const SizedBox(height: 32),

              // ========== SECTION 5: PRÓXIMO PASO ==========
              _buildSection5ProximoPaso(),
              const SizedBox(height: 32),

              // ========== SECTION 6: EVIDENCIA (OPCIONAL) ==========
              _buildSection6Evidencia(),
              const SizedBox(height: 32),

              // ========== SECTION 7: CONFIRMACIÓN ==========
              _buildSection7Confirmacion(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SECTION HEADING ====================
  Widget _buildSectionHeading(String title) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primaryColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 28 / 18,
          letterSpacing: -0.44,
        ),
      ),
    );
  }

  // ==================== FIELD LABEL ====================
  Widget _buildFieldLabel(String label, {String? suffix}) {
    if (suffix != null) {
      return SizedBox(
        height: 20,
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 20 / 14,
                letterSpacing: -0.15,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              suffix,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: greyTextColor,
                height: 20 / 14,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 20,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 20 / 14,
          letterSpacing: -0.15,
        ),
      ),
    );
  }

  // ==================== TEXT INPUT (PREFILLED / READ-ONLY STYLE) ====================
  Widget _buildPrefilledInput(String value) {
    return Container(
      height: 42,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: inputBackground,
        border: Border.all(color: inputBorderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 24 / 16,
          letterSpacing: -0.31,
        ),
      ),
    );
  }

  // ==================== DATE/TIME PICKER FIELD ====================
  Widget _buildDateTimeField(String value) {
    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: inputBorderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 24 / 16,
          letterSpacing: -0.31,
        ),
      ),
    );
  }

  // ==================== SELECTABLE OPTION CHIP (FULL WIDTH) ====================
  Widget _buildSelectableOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double height = 46,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : inputBorderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 20 / 14,
            letterSpacing: -0.15,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ==================== SELECTABLE OPTION CHIP (INLINE/FLEXIBLE) ====================
  Widget _buildInlineSelectableOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double height = 38,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : inputBorderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: textColor,
            height: 20 / 14,
            letterSpacing: -0.15,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ==================== SECTION 1: DATOS BÁSICOS DE LA VISITA ====================
  Widget _buildSection1DatosBasicos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Datos básicos de la visita'),
        const SizedBox(height: 16),

        // Propiedad (prellenada)
        _buildFieldLabel('Propiedad', suffix: '(prellenada)'),
        const SizedBox(height: 8),
        _buildPrefilledInput('Datos de la propiedad'),
        const SizedBox(height: 16),

        // Fecha + Hora row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Fecha'),
                  const SizedBox(height: 8),
                  _buildDateTimeField('22/11/2025'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Hora'),
                  const SizedBox(height: 8),
                  _buildDateTimeField('8:00AM'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Visit type options (vertical, full-width)
        ..._buildVisitTypeOptions(),
        const SizedBox(height: 12),

        // Duration options (horizontal, 3 columns)
        _buildDurationOptions(),
      ],
    );
  }

  List<Widget> _buildVisitTypeOptions() {
    final visitTypes = [
      'Primera visita',
      'Segunda visita',
      'Visita de seguimiento'
    ];
    return visitTypes.map((type) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildSelectableOption(
          label: type,
          isSelected: _selectedVisitType == type,
          onTap: () => setState(() => _selectedVisitType = type),
        ),
      );
    }).toList();
  }

  Widget _buildDurationOptions() {
    final durations = ['< 15 min', '15–30 min', '+30 min'];
    return Row(
      children: durations.asMap().entries.map((entry) {
        final index = entry.key;
        final duration = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
            child: _buildInlineSelectableOption(
              label: duration,
              isSelected: _selectedDuration == duration,
              onTap: () => setState(() => _selectedDuration = duration),
              height: 46,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== SECTION 2: ASISTENTES A LA VISITA ====================
  Widget _buildSection2Asistentes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Asistentes a la visita'),
        const SizedBox(height: 16),

        // Cliente (prellenado)
        _buildFieldLabel('Cliente', suffix: '(prellenado)'),
        const SizedBox(height: 8),
        _buildPrefilledInput('Juan Pérez'),
        const SizedBox(height: 16),

        // ¿Asistieron más personas?
        _buildFieldLabel('¿Asistieron más personas?'),
        const SizedBox(height: 8),
        _buildAttendeeOptions(),
      ],
    );
  }

  Widget _buildAttendeeOptions() {
    final options = ['No', 'Pareja', 'Familiar', 'Otro'];
    return Row(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
            child: _buildInlineSelectableOption(
              label: option,
              isSelected: _selectedAttendees == option,
              onTap: () => setState(() => _selectedAttendees = option),
              height: 38,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== SECTION 3: ESTADO DEL INMUEBLE ====================
  Widget _buildSection3EstadoInmueble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Estado del inmueble'),
        const SizedBox(height: 16),

        // Estado general - star rating
        _buildFieldLabel('Estado general'),
        const SizedBox(height: 8),
        _buildStarRating(),
        const SizedBox(height: 16),

        // Condiciones
        _buildFieldLabel('Condiciones'),
        const SizedBox(height: 8),
        _buildConditionOptions(),
        const SizedBox(height: 16),

        // ¿Coincide con lo publicado?
        _buildFieldLabel('¿Coincide con lo publicado?'),
        const SizedBox(height: 8),
        _buildMatchesPublishedOptions(),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _generalConditionRating = index + 1;
            });
          },
          child: Padding(
            padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
            child: Icon(
              index < _generalConditionRating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: 32,
              color: index < _generalConditionRating
                  ? const Color(0xFFFFC107)
                  : const Color(0xFFD1D5DB),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConditionOptions() {
    final conditions = ['Limpio', 'Requiere mantenimiento', 'En obra'];
    return Column(
      children: conditions.map((condition) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildSelectableOption(
            label: condition,
            isSelected: _selectedCondition == condition,
            onTap: () => setState(() => _selectedCondition = condition),
            height: 38,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMatchesPublishedOptions() {
    final options = ['Sí', 'No'];
    return Row(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 1 ? 12 : 0),
            child: _buildSelectableOption(
              label: option,
              isSelected: _matchesPublished == option,
              onTap: () => setState(() => _matchesPublished = option),
              height: 50,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== SECTION 4: REACCIÓN DEL CLIENTE ====================
  Widget _buildSection4ReaccionCliente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Reacción del cliente'),
        const SizedBox(height: 16),

        // Interés del cliente
        _buildFieldLabel('Interés del cliente'),
        const SizedBox(height: 8),
        _buildInterestOptions(),
        const SizedBox(height: 16),

        // Motivo principal
        _buildFieldLabel('Motivo principal'),
        const SizedBox(height: 8),
        _buildReasonOptions(),
      ],
    );
  }

  Widget _buildInterestOptions() {
    final interests = [
      {'label': 'Alto', 'icon': Icons.trending_up},
      {'label': 'Medio', 'icon': Icons.trending_flat},
      {'label': 'Bajo', 'icon': Icons.trending_down},
    ];
    return Row(
      children: interests.asMap().entries.map((entry) {
        final index = entry.key;
        final interest = entry.value;
        final label = interest['label'] as String;
        final icon = interest['icon'] as IconData;
        final isSelected = _selectedInterest == label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedInterest = label),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.1)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? primaryColor : borderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: isSelected ? primaryColor : textColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                        height: 20 / 14,
                        letterSpacing: -0.15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonOptions() {
    final reasons = [
      'Precio',
      'Ubicación',
      'Tamaño',
      'Estado del inmueble',
      'Otro'
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: reasons.map((reason) {
        final isSelected = _selectedReason == reason;
        return GestureDetector(
          onTap: () => setState(() => _selectedReason = reason),
          child: Container(
            width: double.infinity,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.1)
                  : Colors.white,
              border: Border.all(
                color: isSelected ? primaryColor : inputBorderColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              reason,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 20 / 14,
                letterSpacing: -0.15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== SECTION 5: PRÓXIMO PASO ====================
  Widget _buildSection5ProximoPaso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Próximo paso'),
        const SizedBox(height: 16),
        _buildFieldLabel('¿Qué sigue?'),
        const SizedBox(height: 8),
        _buildNextStepOptions(),
      ],
    );
  }

  Widget _buildNextStepOptions() {
    final steps = [
      'Solicitar documentos',
      'Agendar segunda visita',
      'Enviar propuesta',
      'Interesado, lo pensará',
      'Quiere ver otras opciones',
      'No continúa',
    ];
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isSelected = _selectedNextStep == step;
        return Padding(
          padding: EdgeInsets.only(bottom: index < steps.length - 1 ? 12 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedNextStep = step),
            child: Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.1)
                    : Colors.white,
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                step,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 20 / 14,
                  letterSpacing: -0.15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== SECTION 6: EVIDENCIA (OPCIONAL) ====================
  Widget _buildSection6Evidencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Evidencia (opcional)'),
        const SizedBox(height: 16),

        // Fotos
        Row(
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 4),
            const Text(
              'Fotos',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 20 / 14,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        // File upload placeholder
        const SizedBox(height: 20),
        const SizedBox(height: 16),

        // Comentario
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 4),
            const Text(
              'Comentario',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 20 / 14,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 90,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: inputBorderColor, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 3,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              color: textColor,
              height: 24 / 16,
              letterSpacing: -0.31,
            ),
            decoration: InputDecoration(
              hintText:
                  'Ej: "Cliente interesado, pero solicita revisar parqueos y administración."',
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                color: const Color(0xFF0A0A0A).withValues(alpha: 0.5),
                height: 24 / 16,
                letterSpacing: -0.31,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SECTION 7: CONFIRMACIÓN ====================
  Widget _buildSection7Confirmacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Confirmación'),
        const SizedBox(height: 16),

        // Confirmation checkbox
        GestureDetector(
          onTap: () => setState(() => _confirmed = !_confirmed),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: confirmBg,
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          _confirmed ? primaryColor : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: _confirmed ? primaryColor : Colors.white,
                  ),
                  child: _confirmed
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Confirmo que la información registrada corresponde a la visita realizada',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      height: 20 / 14,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Submit button
        GestureDetector(
          onTap: _handleSubmit,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: primaryColor,
              border: Border.all(color: primaryColor, width: 1),
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Finalizar registro de visita',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 14 / 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
