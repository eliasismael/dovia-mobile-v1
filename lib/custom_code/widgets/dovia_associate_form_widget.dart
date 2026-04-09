// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class DoviaAssociateFormWidget extends StatefulWidget {
  final double? width;
  final double? height;

  final Widget? profileImage;
  final String roleBadgeText;
  final Widget Function()? mapWidget;

  // Callbacks to the parent page (optional — for routing/API calls)
  final VoidCallback? onEnviar;
  final void Function(double latitude, double longitude)? onMapPointSelected;

  const DoviaAssociateFormWidget({
    super.key,
    this.width,
    this.height,
    this.profileImage,
    this.roleBadgeText = 'Dovia Showing Associate',
    this.mapWidget,
    this.onEnviar,
    this.onMapPointSelected,
  });

  @override
  State<DoviaAssociateFormWidget> createState() =>
      _DoviaAssociateFormWidgetState();
}

class _DoviaAssociateFormWidgetState extends State<DoviaAssociateFormWidget> {
  // ── Design tokens ────────────────────────────────────────────────────────────
  static const Color aquaColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color placeholderColor = Color(0xFF888888);
  static const Color inputBg = Color(0xFFFAFAFA);
  static const Color sectionBg = Color(0xFFF7F7F7);
  static const Color badgeTextColor = Color(0xFFCCE3E4);
  static const Color errorColor = Color(0xFFD32F2F);

  // ── Text controllers ─────────────────────────────────────────────────────────
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _sexoController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  final _edadController = TextEditingController();
  final _telefonoCodeController = TextEditingController(text: '+51');
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();

  // ── Validation errors ────────────────────────────────────────────────────────
  String? _nombreError;
  String? _apellidosError;
  String? _edadError;
  String? _telefonoError;
  String? _direccionError;

  // ── Date / time (internal state) ─────────────────────────────────────────────
  DateTime? _fechaEntrevista;
  TimeOfDay? _horaEntrevista;

  // ── Document uploads (internal state) ────────────────────────────────────────
  // Each stores the picked file name for display; bytes for actual upload.
  PlatformFile? _fileAntecedentesPenales;
  PlatformFile? _fileAntecedentesPoliciacos;
  PlatformFile? _fileRecibo;
  PlatformFile? _fileFotografiaId;

  // ── Profile photo (internal state) ───────────────────────────────────────────
  Uint8List? _profileImageBytes;

  // ── Map coordinates ──────────────────────────────────────────────────────────
  double? _mapLatitude;
  double? _mapLongitude;

  // ── Form completeness ────────────────────────────────────────────────────────
  bool get _isFormComplete {
    return _nombresController.text.trim().isNotEmpty &&
        _nombreError == null &&
        _apellidosController.text.trim().isNotEmpty &&
        _apellidosError == null &&
        _sexoController.text.trim().isNotEmpty &&
        _nacionalidadController.text.trim().isNotEmpty &&
        _edadController.text.trim().isNotEmpty &&
        _edadError == null &&
        _telefonoController.text.trim().isNotEmpty &&
        _telefonoError == null &&
        _correoController.text.trim().isNotEmpty &&
        _direccionController.text.trim().isNotEmpty &&
        _direccionError == null &&
        _fechaEntrevista != null &&
        _horaEntrevista != null;
  }

  // ── Validation ───────────────────────────────────────────────────────────────
  void _validateNombres(String v) => setState(() {
        _nombreError = v.trim().isEmpty
            ? 'Campo requerido'
            : !RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$').hasMatch(v.trim())
                ? 'Solo letras'
                : null;
      });

  void _validateApellidos(String v) => setState(() {
        _apellidosError = v.trim().isEmpty
            ? 'Campo requerido'
            : !RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$').hasMatch(v.trim())
                ? 'Solo letras'
                : null;
      });

  void _validateEdad(String v) => setState(() {
        final n = int.tryParse(v.trim());
        _edadError = v.trim().isEmpty
            ? 'Campo requerido'
            : (n == null || n < 13 || n > 120)
                ? 'Edad inválida'
                : null;
      });

  void _validateTelefono(String v) => setState(() {
        _telefonoError = v.trim().isEmpty
            ? 'Campo requerido'
            : !RegExp(r'^\d+$').hasMatch(v.trim())
                ? 'Solo números'
                : null;
      });

  void _validateDireccion(String v) => setState(
      () => _direccionError = v.trim().isEmpty ? 'Campo requerido' : null);

  // ── Date / time pickers ──────────────────────────────────────────────────────
  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _fechaEntrevista ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: aquaColor,
            onPrimary: Colors.white,
            onSurface: textColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fechaEntrevista = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaEntrevista ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: aquaColor,
            onPrimary: Colors.white,
            onSurface: textColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _horaEntrevista = picked);
  }

  // ── Profile image picker ──────────────────────────────────────────────────────
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _profileImageBytes = bytes);
    }
  }

  // ── File picker ──────────────────────────────────────────────────────────────
  Future<void> _pickFile(void Function(PlatformFile file) onPicked) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => onPicked(result.files.first));
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = Provider.of<FFAppState>(context, listen: false);
      final userData = appState.UserData;

      _nombresController.text = userData.name;
      _apellidosController.text = userData.lastname;

      _sexoController.text = userData.gender == 'MALE'
          ? 'Masculino'
          : userData.gender == 'FEMALE'
              ? 'Femenino'
              : userData.gender;

      _nacionalidadController.text = userData.nationality;

      if (userData.birthdayYear > 0 &&
          userData.birthdayMonth > 0 &&
          userData.birthdayDay > 0) {
        final birth = DateTime(userData.birthdayYear, userData.birthdayMonth,
            userData.birthdayDay);
        final now = DateTime.now();
        int age = now.year - birth.year;
        if (now.month < birth.month ||
            (now.month == birth.month && now.day < birth.day)) {
          age--;
        }
        _edadController.text = age.toString();
      }

      if (userData.phoneCode.isNotEmpty) {
        _telefonoCodeController.text = userData.phoneCode;
      }
      _telefonoController.text = userData.phoneNumber;
      _correoController.text = appState.UserEmail;

      setState(() {}); // refresh
    });
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _sexoController.dispose();
    _nacionalidadController.dispose();
    _edadController.dispose();
    _telefonoCodeController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 23, offset: Offset(0, 7)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: 56, bottom: 40, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 30),
              _buildFormFields(),
              const SizedBox(height: 14),
              _buildMapSection(),
              const SizedBox(height: 30),
              // Date / time BEFORE documents (as in Figma)
              _buildDateTimeSection(),
              const SizedBox(height: 19),
              _buildDocumentUpload(
                'Fotografía del ID (Opcional)',
                _fileFotografiaId,
                () => _pickFile((f) => _fileFotografiaId = f),
              ),
              const SizedBox(height: 19),
              _buildDocumentUpload(
                'Debes cargar tus antecedentes penales (Opcional)',
                _fileAntecedentesPenales,
                () => _pickFile((f) => _fileAntecedentesPenales = f),
              ),
              const SizedBox(height: 19),
              _buildDocumentUpload(
                'Debes cargar tus antecedentes policiacos (Opcional)',
                _fileAntecedentesPoliciacos,
                () => _pickFile((f) => _fileAntecedentesPoliciacos = f),
              ),
              const SizedBox(height: 19),
              _buildDocumentUpload(
                'Debes cargar el recibo de agua, luz o teléfono de vivienda (Opcional)',
                _fileRecibo,
                () => _pickFile((f) => _fileRecibo = f),
              ),
              const SizedBox(height: 19),
              _buildDisclaimer(),
              const SizedBox(height: 19),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile ──────────────────────────────────────────────────────────────────
  Widget _buildProfileSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: ClipOval(
                  child: _profileImageBytes != null
                      ? Image.memory(
                          _profileImageBytes!,
                          fit: BoxFit.cover,
                          width: 76,
                          height: 76,
                        )
                      : widget.profileImage ??
                          Container(
                            color: const Color(0xFFE0E0E0),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: aquaColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          decoration: BoxDecoration(
            color: aquaColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              widget.roleBadgeText,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: badgeTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Form fields ──────────────────────────────────────────────────────────────
  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTwoColumnRow(
          _buildInputField('Nombres', _nombresController, 'Laura',
              errorText: _nombreError, onChanged: _validateNombres),
          _buildInputField('Apellidos', _apellidosController, 'Martinez',
              errorText: _apellidosError, onChanged: _validateApellidos),
        ),
        const SizedBox(height: 14),
        _buildTwoColumnRow(
          _buildInputField('Sexo', _sexoController, 'Femenino',
              onChanged: (_) => setState(() {})),
          _buildInputField(
              'Nacionalidad', _nacionalidadController, 'Colombiana',
              onChanged: (_) => setState(() {})),
        ),
        const SizedBox(height: 14),
        _buildTwoColumnRow(
          _buildInputField('Edad', _edadController, '28',
              keyboardType: TextInputType.number,
              errorText: _edadError,
              onChanged: _validateEdad),
          _buildPhoneField(),
        ),
        const SizedBox(height: 14),
        _buildTwoColumnRow(
          _buildInputField(
            'Correo',
            _correoController,
            'correo@ejemplo.com',
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
          ),
          _buildInputField(
            'Dirección de vivienda',
            _direccionController,
            'Calle 123',
            errorText: _direccionError,
            onChanged: _validateDireccion,
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String placeholder, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.28,
            )),
        const SizedBox(height: 12),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFFF0F0F0) : inputBg,
            borderRadius: BorderRadius.circular(10),
            border: hasError
                ? Border.all(color: errorColor, width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: readOnly ? textColor.withAlpha(140) : textColor,
              letterSpacing: 0.28,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: placeholderColor.withAlpha(128),
                letterSpacing: 0.28,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(errorText,
              style: const TextStyle(
                  fontFamily: 'Public Sans', fontSize: 11, color: errorColor)),
        ],
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Teléfono',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.28,
            )),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 42,
              decoration: BoxDecoration(
                  color: inputBg, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _telefonoCodeController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: textColor,
                    letterSpacing: 0.28),
                decoration: const InputDecoration(
                  hintText: '+51',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(10),
                      border: _telefonoError != null
                          ? Border.all(color: errorColor, width: 1.5)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: TextField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      onChanged: _validateTelefono,
                      style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          color: textColor,
                          letterSpacing: 0.28),
                      decoration: InputDecoration(
                        hintText: '123456789',
                        hintStyle: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            color: const Color(0xFFBDBDBD).withAlpha(128)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                      ),
                    ),
                  ),
                  if (_telefonoError != null) ...[
                    const SizedBox(height: 4),
                    Text(_telefonoError!,
                        style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 11,
                            color: errorColor)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Map ──────────────────────────────────────────────────────────────────────
  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marca el rango de trabajo que te es accesible o tienes actualmente disponible:',
          style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.28),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: inputBg, borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.antiAlias,
            child: widget.mapWidget?.call() ??
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('Mapa',
                          style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 16,
                              color: Colors.grey[500])),
                    ],
                  ),
                ),
          ),
        ),
        if (_mapLatitude != null && _mapLongitude != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Punto: ${_mapLatitude!.toStringAsFixed(5)}, ${_mapLongitude!.toStringAsFixed(5)}',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 11,
                  color: textColor.withAlpha(178)),
            ),
          ),
      ],
    );
  }

  // ── Date / time ──────────────────────────────────────────────────────────────
  Widget _buildDateTimeSection() {
    final fechaLabel = _fechaEntrevista != null
        ? DateFormat('dd/MM/yyyy').format(_fechaEntrevista!)
        : 'Selecciona la fecha';
    final horaLabel = _horaEntrevista != null
        ? _horaEntrevista!.format(context)
        : 'Selecciona la hora';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona la fecha para que DOVIA se comunique con vos y coordinar una entrevista',
          style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.32),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: sectionBg, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 423),
              child: Column(
                children: [
                  _buildDateTimeRow(
                    fechaLabel,
                    Icons.chevron_right_rounded,
                    _pickFecha,
                    selected: _fechaEntrevista != null,
                  ),
                  const SizedBox(height: 13),
                  _buildDateTimeRow(
                    horaLabel,
                    Icons.chevron_right_rounded,
                    _pickHora,
                    selected: _horaEntrevista != null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color(0x21000000), blurRadius: 14, offset: Offset(0, 0))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? aquaColor : textColor,
              ),
            ),
            Icon(icon, size: 24, color: selected ? aquaColor : textColor),
          ],
        ),
      ),
    );
  }

  // ── Document upload ──────────────────────────────────────────────────────────
  Widget _buildDocumentUpload(
    String label,
    PlatformFile? file,
    VoidCallback onTap,
  ) {
    final uploaded = file != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    letterSpacing: 0.32),
              ),
            ),
            if (uploaded)
              const Icon(Icons.check_circle, color: aquaColor, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 104,
            width: double.infinity,
            decoration: BoxDecoration(
              color: uploaded ? const Color(0xFFE8F5E9) : inputBg,
              borderRadius: BorderRadius.circular(10),
              border:
                  uploaded ? Border.all(color: aquaColor.withAlpha(100)) : null,
            ),
            child: uploaded
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_drive_file,
                          size: 28, color: aquaColor.withAlpha(200)),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          file.name,
                          style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 12,
                              color: textColor.withAlpha(180)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(Icons.note_add_outlined,
                        size: 24, color: textColor.withAlpha(128)),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Disclaimer ───────────────────────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return const Text(
      'Una vez enviado los datos, no se podran modificar porfavor verifica que sean cargados correctamente',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Public Sans',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.3,
        decoration: TextDecoration.underline,
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    final enabled = _isFormComplete;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 607),
        child: SizedBox(
          width: double.infinity,
          height: 42,
          child: GestureDetector(
            onTap: enabled ? widget.onEnviar : null,
            child: Container(
              decoration: BoxDecoration(
                color: enabled ? aquaColor : aquaColor.withAlpha(100),
                border: Border.all(
                    color: enabled ? aquaColor : aquaColor.withAlpha(100)),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Enviar',
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
        ),
      ),
    );
  }
}
