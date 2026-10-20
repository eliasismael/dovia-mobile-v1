// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/uploaded_file.dart';
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
  final VoidCallback? onCancelVisit;

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
    this.onCancelVisit,
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
    (label: 'Primera visita', value: 'FIRST_VISIT'),
    (label: 'Segunda visita', value: 'SECOND_VISIT'),
    (label: 'Visita de seguimiento', value: 'FOLLOW_UP_VISIT'),
  ];

  /// Los mismos cuatro rangos que acepta el backend. Antes "+30 min" se
  /// enviaba como `MORE_THAN_60_MIN`: una visita de 40 minutos quedaba
  /// registrada como de más de una hora.
  static const List<_Opt> _durationOpts = [
    (label: '< 15 min', value: 'LESS_THAN_15_MIN'),
    (label: '15–30 min', value: 'BETWEEN_15_AND_30_MIN'),
    (label: '30–60 min', value: 'BETWEEN_30_AND_60_MIN'),
    (label: '+60 min', value: 'MORE_THAN_60_MIN'),
  ];
  static const List<_Opt> _attendeesOpts = [
    (label: 'Pareja', value: 'PARTNER'),
    (label: 'Familiar', value: 'FAMILY'),
    (label: 'No', value: 'NONE'),
    (label: 'Otro', value: 'OTHER'),
  ];
  static const List<_Opt> _conditionOpts = [
    (label: 'Limpio', value: 'CLEAN'),
    (label: 'Requiere mantenimiento', value: 'NEEDS_MAINTENANCE'),
    (label: 'En obra', value: 'UNDER_CONSTRUCTION'),
  ];
  static const List<_Opt> _matchOpts = [
    (label: 'Sí', value: 'YES'),
    (label: 'No', value: 'NO'),
  ];
  static const List<_Opt> _interestOpts = [
    (label: 'Alto', value: 'HIGH'),
    (label: 'Medio', value: 'MEDIUM'),
    (label: 'Bajo', value: 'LOW'),
  ];
  static const List<_Opt> _reasonOpts = [
    (label: 'Precio', value: 'PRICE'),
    (label: 'Ubicación', value: 'LOCATION'),
    (label: 'Tamaño', value: 'SIZE'),
    (label: 'Estado del inmueble', value: 'CONDITION'),
    (label: 'Otro', value: 'OTHER'),
  ];
  static const List<_Opt> _nextStepOpts = [
    (label: 'Solicitar documentos', value: 'REQUEST_DOCUMENTS'),
    (label: 'Agendar segunda visita', value: 'SCHEDULE_SECOND_VISIT'),
    (label: 'Enviar propuesta', value: 'SEND_PROPOSAL'),
    (label: 'No continúa', value: 'NOT_CONTINUING'),
    (label: 'Interesado, lo pensará', value: 'INTERESTED_THINKING'),
    (label: 'Quiere ver otras opciones', value: 'WANTS_OTHER_OPTIONS'),
  ];

  // ==================== FORM STATE (stores API enum values) ====================
  String? _kind;
  String? _duration;
  String? _attendees;
  int _overallRating = 0;
  String? _propertyCondition;
  String? _matchesPublished;
  String? _interest;
  String? _mainReason;
  String? _nextStep;

  final _commentController = TextEditingController();
  bool _confirmed = false;
  List<FFUploadedFile> _uploadedPhotos = [];
  bool _isUploadingPhotos = false;

  /// Hay un envío en curso: el botón no vuelve a disparar otro (dos toques
  /// subían las fotos dos veces y mandaban dos registros).
  bool _isSending = false;

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
      _matchesPublished != null &&
      _interest != null &&
      _mainReason != null &&
      _nextStep != null &&
      _confirmed;

  Future<void> _handleSubmit() async {
    if (_isSending) return;
    if (!_isValid) {
      final missing = <String>[];
      if (_kind == null) missing.add('Modalidad');
      if (_duration == null) missing.add('Duración');
      if (_attendees == null) missing.add('Asistentes');
      if (_overallRating == 0) missing.add('Estrellas');
      if (_propertyCondition == null) missing.add('Condición');
      if (_matchesPublished == null) missing.add('Coincide publicado');
      if (_interest == null) missing.add('Interés');
      if (_mainReason == null) missing.add('Motivo');
      if (_nextStep == null) missing.add('Próximo paso');
      if (!_confirmed) missing.add('Confirmación');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falta completar: ${missing.join(', ')}'),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final Map<String, String> conditionMap = {
      'CLEAN': 'GOOD',
      'NEEDS_MAINTENANCE': 'FAIR',
      'UNDER_CONSTRUCTION': 'POOR',
    };
    final Map<String, String> interestMap = {
      'HIGH': 'VERY_INTERESTED',
      'MEDIUM': 'INTERESTED',
      'LOW': 'NOT_INTERESTED',
    };
    final Map<String, String> nextStepMap = {
      'REQUEST_DOCUMENTS': 'CONSIDERING',
      'SCHEDULE_SECOND_VISIT': 'SCHEDULE_SECOND_VISIT',
      'SEND_PROPOSAL': 'MAKE_OFFER',
      'NOT_CONTINUING': 'NOT_INTERESTED',
      'INTERESTED_THINKING': 'CONSIDERING',
      'WANTS_OTHER_OPTIONS': 'NOT_INTERESTED',
    };

    final String kindLabel = _kindOpts
        .firstWhere((e) => e.value == _kind,
            orElse: () => (label: _kind ?? '', value: ''))
        .label;
    final String matchLabel = _matchesPublished == 'YES' ? 'Sí' : 'No';
    final String extraComments =
        'Modalidad: $kindLabel\nCoincide con lo publicado: $matchLabel';
    final String finalComments = _commentController.text.trim().isEmpty
        ? extraComments
        : '${_commentController.text.trim()}\n\n$extraComments';

    final data = <String, dynamic>{
      'showingVisitKind': 'IN_PERSON',
      'showingVisitDuration': _duration,
      'additionalAttendees': _attendees,
      'propertyCondition': conditionMap[_propertyCondition] ?? 'GOOD',
      'clientInterestLevel': interestMap[_interest] ?? 'NEUTRAL',
      'overallRating': _overallRating,
      'mainReason': _mainReason,
      'nextStep': nextStepMap[_nextStep] ?? 'CONSIDERING',
      'comments': finalComments,
      'photos': _uploadedPhotos,
      'confirmationAccepted': _confirmed,
    };

    if (widget.onSave != null) {
      final pending = widget.onSave!(data);
      if (pending is Future) {
        setState(() => _isSending = true);
        try {
          await pending;
        } finally {
          if (mounted) setState(() => _isSending = false);
        }
      }
    } else if (widget.onFinalizarRegistro != null) {
      widget.onFinalizarRegistro!();
    }
  }

  Future<void> _handleUploadPhotos() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
      pickerFontFamily: 'Public Sans',
    );
    if (selectedMedia != null &&
        selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      setState(() => _isUploadingPhotos = true);
      try {
        final newFiles = selectedMedia
            .map((m) => FFUploadedFile(
                  name: m.storagePath.split('/').last,
                  bytes: m.bytes,
                  height: m.dimensions?.height,
                  width: m.dimensions?.width,
                  blurHash: m.blurHash,
                  originalFilename: m.originalFilename,
                ))
            .toList();
        setState(() {
          _uploadedPhotos.addAll(newFiles);
        });
      } finally {
        setState(() => _isUploadingPhotos = false);
      }
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
      // Sin alto fijo el formulario crece y scrollea la pantalla; con alto,
      // scrollea por dentro.
      child: widget.height == null
          ? _buildForm()
          : SingleChildScrollView(child: _buildForm()),
    );
  }

  Widget _buildForm() {
    return Padding(
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
    );
  }

  // ==================== SHARED PIECES ====================
  Widget _buildSectionHeading(String title, {Widget? trailing}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor, width: 1)),
      ),
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
          ),
          if (trailing != null) trailing,
        ],
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
        padding: expand ? null : const EdgeInsets.symmetric(horizontal: 16),
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
        _buildSectionHeading(
          'Datos básicos de la visita',
          trailing: widget.onCancelVisit != null
              ? InkWell(
                  onTap: widget.onCancelVisit,
                  borderRadius: BorderRadius.circular(24),
                  // Botón relleno rojo (texto blanco) para que no parezca label.
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC90A0A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'No se realizó',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : null,
        ),
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
        _optionsInline(_kindOpts, _kind, (v) => _kind = v, height: 46),
        const SizedBox(height: 16),
        // Dos filas de dos: cuatro en una fila no entran en pantallas chicas.
        _optionsInline(
            _durationOpts.sublist(0, 2), _duration, (v) => _duration = v,
            height: 46),
        const SizedBox(height: 12),
        _optionsInline(
            _durationOpts.sublist(2), _duration, (v) => _duration = v,
            height: 46),
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
        _optionsInline(_attendeesOpts, _attendees, (v) => _attendees = v,
            height: 38),
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
        _optionsInline(
            _conditionOpts, _propertyCondition, (v) => _propertyCondition = v,
            height: 38),
        const SizedBox(height: 16),
        _buildFieldLabel('¿Coincide con lo publicado?'),
        const SizedBox(height: 8),
        _optionsInline(
            _matchOpts, _matchesPublished, (v) => _matchesPublished = v,
            height: 38),
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
        _optionsInline(_interestOpts, _interest, (v) => _interest = v,
            height: 42),
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
        _buildNextStepGrid(),
      ],
    );
  }

  Widget _buildNextStepGrid() {
    return Column(
      children: [
        for (int i = 0; i < _nextStepOpts.length; i += 2)
          Padding(
            padding:
                EdgeInsets.only(bottom: i < _nextStepOpts.length - 2 ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: _optionBox(
                    label: _nextStepOpts[i].label,
                    isSelected: _nextStep == _nextStepOpts[i].value,
                    onTap: () =>
                        setState(() => _nextStep = _nextStepOpts[i].value),
                    height: 42,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < _nextStepOpts.length
                      ? _optionBox(
                          label: _nextStepOpts[i + 1].label,
                          isSelected: _nextStep == _nextStepOpts[i + 1].value,
                          onTap: () => setState(
                              () => _nextStep = _nextStepOpts[i + 1].value),
                          height: 42,
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
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
            Icon(Icons.camera_alt_outlined, size: 16, color: textColor),
            SizedBox(width: 4),
            Text(
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
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploadingPhotos ? null : _handleUploadPhotos,
          child: Container(
            height: 42,
            width: double.infinity,
            decoration: BoxDecoration(
              color: inputBackground,
              border: Border.all(color: inputBorderColor, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: _isUploadingPhotos
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                : const Text(
                    'Subir fotos',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
          ),
        ),
        if (_uploadedPhotos.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _uploadedPhotos.map((file) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: file.bytes != null
                          ? DecorationImage(
                              image: MemoryImage(file.bytes!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[200],
                    ),
                    child: file.bytes == null
                        ? const Icon(Icons.image, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _uploadedPhotos.remove(file);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel,
                            size: 20, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
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
          onTap: _isSending ? null : _handleSubmit,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: _isValid && !_isSending
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: Text(
              _isSending ? 'Enviando...' : 'Finalizar registro de visita',
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
