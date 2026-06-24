// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// A selectable option: visible [label] mapped to the API [value] (enum).
typedef _Opt = ({String label, String value});

class ShowingRegistroVisitaDatos extends StatefulWidget {
  final double? width;
  final double? height;

  // Optional prefilled display data
  final String? propertyName;
  final String? clientName;
  final String? dateText;
  final String? timeText;

  // Callbacks
  final VoidCallback? onFinalizarRegistro;

  /// Called with the API-ready payload when the form passes validation.
  /// Keys match POST /visits/{visitId}/showing/report fields.
  final Function? onSave;

  const ShowingRegistroVisitaDatos({
    super.key,
    this.width,
    this.height,
    this.propertyName,
    this.clientName,
    this.dateText,
    this.timeText,
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
  static const Color inputBorderColor = Color(0x1A000000);
  static const Color greyTextColor = Color(0xFF99A1AF);
  static const Color confirmBg = Color(0x3370ACAD);

  // ==================== OPTION SETS (label → API enum) ====================
  static const List<_Opt> _kindOpts = [
    (label: 'Presencial', value: 'IN_PERSON'),
    (label: 'Virtual', value: 'VIRTUAL'),
  ];
  static const List<_Opt> _durationOpts = [
    (label: '< 15 min', value: 'LESS_THAN_15_MIN'),
    (label: '15–30 min', value: 'BETWEEN_15_AND_30_MIN'),
    (label: '30–60 min', value: 'BETWEEN_30_AND_60_MIN'),
    (label: '+60 min', value: 'MORE_THAN_60_MIN'),
  ];
  static const List<_Opt> _attendeesOpts = [
    (label: 'No', value: 'NONE'),
    (label: 'Pareja', value: 'PARTNER'),
    (label: 'Familiar', value: 'FAMILY'),
    (label: 'Asesor financiero', value: 'FINANCIAL_ADVISOR'),
    (label: 'Otro', value: 'OTHER'),
  ];
  static const List<_Opt> _conditionOpts = [
    (label: 'Excelente', value: 'EXCELLENT'),
    (label: 'Bueno', value: 'GOOD'),
    (label: 'Regular', value: 'FAIR'),
    (label: 'Malo', value: 'POOR'),
  ];
  static const List<_Opt> _interestOpts = [
    (label: 'Muy interesado', value: 'VERY_INTERESTED'),
    (label: 'Interesado', value: 'INTERESTED'),
    (label: 'Neutral', value: 'NEUTRAL'),
    (label: 'No interesado', value: 'NOT_INTERESTED'),
  ];
  static const List<_Opt> _reasonOpts = [
    (label: 'Precio', value: 'PRICE'),
    (label: 'Ubicación', value: 'LOCATION'),
    (label: 'Tamaño', value: 'SIZE'),
    (label: 'Estado del inmueble', value: 'CONDITION'),
    (label: 'Características', value: 'FEATURES'),
    (label: 'Otro', value: 'OTHER'),
  ];
  static const List<_Opt> _nextStepOpts = [
    (label: 'Hacer oferta', value: 'MAKE_OFFER'),
    (label: 'Agendar segunda visita', value: 'SCHEDULE_SECOND_VISIT'),
    (label: 'Lo está pensando', value: 'CONSIDERING'),
    (label: 'No le interesa', value: 'NOT_INTERESTED'),
  ];

  // ==================== FORM STATE (stores API enum values) ====================
  String? _kind;
  String? _duration;
  String? _attendees;
  int _overallRating = 0;
  String? _propertyCondition;
  String? _interest;
  String? _mainReason;
  String? _nextStep;

  final _commentController = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _kind != null &&
      _duration != null &&
      _attendees != null &&
      _overallRating > 0 &&
      _propertyCondition != null &&
      _interest != null &&
      _mainReason != null &&
      _nextStep != null &&
      _confirmed;

  void _handleSubmit() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Completa todos los campos y acepta la confirmación antes de finalizar.'),
        ),
      );
      return;
    }

    final data = <String, dynamic>{
      'showingVisitKind': _kind,
      'showingVisitDuration': _duration,
      'additionalAttendees': _attendees,
      'propertyCondition': _propertyCondition,
      'clientInterestLevel': _interest,
      'overallRating': _overallRating,
      'mainReason': _mainReason,
      'nextStep': _nextStep,
      'comments': _commentController.text,
      'confirmationAccepted': _confirmed,
    };

    if (widget.onSave != null) {
      widget.onSave!(data);
    } else if (widget.onFinalizarRegistro != null) {
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
              _buildSection1DatosBasicos(),
              const SizedBox(height: 32),
              _buildSection2Asistentes(),
              const SizedBox(height: 32),
              _buildSection3EstadoInmueble(),
              const SizedBox(height: 32),
              _buildSection4ReaccionCliente(),
              const SizedBox(height: 32),
              _buildSection5ProximoPaso(),
              const SizedBox(height: 32),
              _buildSection6Evidencia(),
              const SizedBox(height: 32),
              _buildSection7Confirmacion(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SHARED PIECES ====================
  Widget _buildSectionHeading(String title) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor, width: 1)),
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

  Widget _buildFieldLabel(String label, {String? suffix}) {
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
          if (suffix != null) ...[
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
        ],
      ),
    );
  }

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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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

  Widget _optionBox({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double height = 46,
    bool expand = true,
  }) {
    final box = GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        padding:
            expand ? null : const EdgeInsets.symmetric(horizontal: 16),
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: textColor,
            height: 20 / 14,
            letterSpacing: -0.15,
          ),
        ),
      ),
    );
    return box;
  }

  /// Vertical list of full-width options.
  Widget _optionsVertical(
    List<_Opt> opts,
    String? selected,
    ValueChanged<String> onChanged, {
    double height = 46,
  }) {
    return Column(
      children: [
        for (int i = 0; i < opts.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < opts.length - 1 ? 12 : 0),
            child: _optionBox(
              label: opts[i].label,
              isSelected: selected == opts[i].value,
              onTap: () => setState(() => onChanged(opts[i].value)),
              height: height,
            ),
          ),
      ],
    );
  }

  /// Row of equal-width options (2–4 per row).
  Widget _optionsInline(
    List<_Opt> opts,
    String? selected,
    ValueChanged<String> onChanged, {
    double height = 46,
  }) {
    return Row(
      children: [
        for (int i = 0; i < opts.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < opts.length - 1 ? 12 : 0),
              child: _optionBox(
                label: opts[i].label,
                isSelected: selected == opts[i].value,
                onTap: () => setState(() => onChanged(opts[i].value)),
                height: height,
              ),
            ),
          ),
      ],
    );
  }

  // ==================== SECTION 1 ====================
  Widget _buildSection1DatosBasicos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Datos básicos de la visita'),
        const SizedBox(height: 16),
        _buildFieldLabel('Propiedad', suffix: '(prellenada)'),
        const SizedBox(height: 8),
        _buildPrefilledInput(widget.propertyName ?? 'Datos de la propiedad'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Fecha'),
                  const SizedBox(height: 8),
                  _buildDateTimeField(widget.dateText ?? '—'),
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
                  _buildDateTimeField(widget.timeText ?? '—'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Modalidad de la visita'),
        const SizedBox(height: 8),
        _optionsInline(
            _kindOpts, _kind, (v) => _kind = v, height: 46),
        const SizedBox(height: 16),
        _buildFieldLabel('Duración'),
        const SizedBox(height: 8),
        // 4 duration options split into two rows of two.
        _optionsInline(
            _durationOpts.sublist(0, 2), _duration, (v) => _duration = v),
        const SizedBox(height: 12),
        _optionsInline(
            _durationOpts.sublist(2, 4), _duration, (v) => _duration = v),
      ],
    );
  }

  // ==================== SECTION 2 ====================
  Widget _buildSection2Asistentes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Asistentes a la visita'),
        const SizedBox(height: 16),
        _buildFieldLabel('Cliente', suffix: '(prellenado)'),
        const SizedBox(height: 8),
        _buildPrefilledInput(widget.clientName ?? 'Cliente'),
        const SizedBox(height: 16),
        _buildFieldLabel('¿Asistieron más personas?'),
        const SizedBox(height: 8),
        _optionsVertical(
            _attendeesOpts, _attendees, (v) => _attendees = v, height: 42),
      ],
    );
  }

  // ==================== SECTION 3 ====================
  Widget _buildSection3EstadoInmueble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Estado del inmueble'),
        const SizedBox(height: 16),
        _buildFieldLabel('Estado general'),
        const SizedBox(height: 8),
        _buildStarRating(),
        const SizedBox(height: 16),
        _buildFieldLabel('Condiciones'),
        const SizedBox(height: 8),
        _optionsVertical(_conditionOpts, _propertyCondition,
            (v) => _propertyCondition = v,
            height: 42),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _overallRating = index + 1),
          child: Padding(
            padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
            child: Icon(
              index < _overallRating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: 32,
              color: index < _overallRating
                  ? const Color(0xFFFFC107)
                  : const Color(0xFFD1D5DB),
            ),
          ),
        );
      }),
    );
  }

  // ==================== SECTION 4 ====================
  Widget _buildSection4ReaccionCliente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Reacción del cliente'),
        const SizedBox(height: 16),
        _buildFieldLabel('Interés del cliente'),
        const SizedBox(height: 8),
        _optionsVertical(
            _interestOpts, _interest, (v) => _interest = v, height: 42),
        const SizedBox(height: 16),
        _buildFieldLabel('Motivo principal'),
        const SizedBox(height: 8),
        _buildReasonWrap(),
      ],
    );
  }

  Widget _buildReasonWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _reasonOpts.map((opt) {
        final isSelected = _mainReason == opt.value;
        return _optionBox(
          label: opt.label,
          isSelected: isSelected,
          onTap: () => setState(() => _mainReason = opt.value),
          height: 38,
          expand: false,
        );
      }).toList(),
    );
  }

  // ==================== SECTION 5 ====================
  Widget _buildSection5ProximoPaso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Próximo paso'),
        const SizedBox(height: 16),
        _buildFieldLabel('¿Qué sigue?'),
        const SizedBox(height: 8),
        _optionsVertical(
            _nextStepOpts, _nextStep, (v) => _nextStep = v, height: 46),
      ],
    );
  }

  // ==================== SECTION 6 ====================
  Widget _buildSection6Evidencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Evidencia (opcional)'),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.chat_bubble_outline, size: 16, color: textColor),
            SizedBox(width: 4),
            Text(
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SECTION 7 ====================
  Widget _buildSection7Confirmacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading('Confirmación'),
        const SizedBox(height: 16),
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
        GestureDetector(
          onTap: _handleSubmit,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: _isValid ? primaryColor : primaryColor.withValues(alpha: 0.5),
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
