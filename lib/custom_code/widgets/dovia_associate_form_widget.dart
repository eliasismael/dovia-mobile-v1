// Automatic FlutterFlow imports
import '/core/network_image_size.dart';
import '/core/api_error.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:provider/provider.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/form_field_controller.dart';
import '/auth/custom_auth/auth_util.dart';
import '/auth/pending_associate_role.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_recruitment.dart';
import '/backend/api_requests/api_users.dart';
import 'package:image_picker/image_picker.dart';
import '/shared_components/dovia_spinner.dart';

class DoviaAssociateFormWidget extends StatefulWidget {
  final double? width;
  final double? height;

  final Widget? profileImage;
  final String roleBadgeText;

  // Callbacks to the parent page (optional — for routing/API calls)
  final VoidCallback? onEnviar;

  const DoviaAssociateFormWidget({
    super.key,
    this.width,
    this.height,
    this.profileImage,
    this.roleBadgeText = 'Dovia Showing Associate',
    this.onEnviar,
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

  // ── Date / time (internal state) ─────────────────────────────────────────────
  DateTime? _fechaEntrevista;
  TimeOfDay? _horaEntrevista;

  // ── Document uploads (internal state) ────────────────────────────────────────
  // Each stores the picked file name for display; bytes for actual upload.
  FFUploadedFile? _fileAntecedentesPenales;
  FFUploadedFile? _fileAntecedentesPoliciacos;
  FFUploadedFile? _fileRecibo;
  FFUploadedFile? _fileFotografiaId;

  final _scrollController = ScrollController();

  /// Documentos que ya están en el perfil (GET /users/me), por tipo. Se
  /// muestran como cargados aunque la app se haya cerrado después de subirlos.
  Map<String, String> _remoteDocs = const {};

  Future<void> _loadRemoteDocs() async {
    final res = await DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall
        .call(authToken: currentAuthenticationToken);
    if (!mounted || !res.succeeded) return;
    String? url(String field) {
      final v = getJsonField(res.jsonBody, '\$.data.$field')?.toString();
      return (v == null || v.isEmpty || v == 'null') ? null : v;
    }

    final docs = <String, String>{
      for (final e in const {
        'identification-document': 'identificationDocumentUrl',
        'criminal-record': 'criminalRecordUrl',
        'police-record': 'policeRecordUrl',
        'utility-bill': 'utilityBillUrl',
      }.entries)
        if (url(e.value) != null) e.key: url(e.value)!,
    };
    setState(() {
      _remoteDocs = docs;
      _profileZoneId = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall
          .workZoneId(res.jsonBody);
      _applyProfileZone();
    });
  }

  // ── Zona de trabajo ──────────────────────────────────────────────────────────
  /// Zonas activas de `GET /users/work-zones`; null mientras se cargan.
  List<UserWorkZone>? _zones;
  bool _zonesFailed = false;
  String? _workZoneId;

  /// La zona que ya tenía guardada (si volvió al formulario).
  String? _profileZoneId;
  final _zoneController = FormFieldController<String>(null);

  Future<void> _loadZones() async {
    setState(() {
      _zones = null;
      _zonesFailed = false;
    });
    final res = await DOVIAAPIUserContextGroup.getUserWorkZonesCall.call();
    if (!mounted) return;
    setState(() {
      if (res.succeeded) {
        _zones = UserWorkZone.listFrom(res.jsonBody);
        _applyProfileZone();
      } else {
        _zones = const [];
        _zonesFailed = true;
      }
    });
  }

  /// Preselecciona la zona guardada, solo si sigue en el catálogo activo.
  void _applyProfileZone() {
    final id = _profileZoneId;
    if (_workZoneId != null || id == null) return;
    if (_zones?.any((z) => z.id == id) ?? false) {
      _workZoneId = id;
      _zoneController.value = id;
    }
  }

  /// Se pide elegir una zona cuando hay catálogo. Si no se pudo cargar o
  /// viene vacío no se bloquea el envío: el backend la toma como opcional.
  bool get _zoneRequired => _zones == null || _zones!.isNotEmpty;

  // ── Profile photo (internal state) ───────────────────────────────────────────
  Uint8List? _profileImageBytes;

  // ── Form completeness ────────────────────────────────────────────────────────
  /// Lo obligatorio es la cita de primer contacto (`scheduledAt`) y la zona de
  /// trabajo. Datos personales vienen del registro; dirección, foto y
  /// documentos son opcionales.
  bool get _isFormComplete => _missingFields.isEmpty;

  /// Qué falta para poder enviar, en el orden del formulario.
  List<String> get _missingFields => [
        if (_zoneRequired && _workZoneId == null) 'zona de trabajo',
        if (_fechaEntrevista == null) 'fecha de la entrevista',
        if (_horaEntrevista == null) 'hora de la entrevista',
      ];

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

  // ── Foto por campo ───────────────────────────────────────────────────────────
  /// Mismo selector que el resto de la app (cámara o galería). Una sola foto
  /// por campo: elegir otra reemplaza la anterior.
  Future<void> _pickFile(void Function(FFUploadedFile file) onPicked) async {
    final selected = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
      pickerFontFamily: 'Public Sans',
    );
    if (selected == null || selected.isEmpty) return;
    final m = selected.first;
    if (!mounted || !validateFileFormat(m.storagePath, context)) return;
    setState(() => onPicked(FFUploadedFile(
          name: m.storagePath.split('/').last,
          bytes: m.bytes,
          height: m.dimensions?.height,
          width: m.dimensions?.width,
          blurHash: m.blurHash,
          originalFilename: m.originalFilename,
        )));
  }

  // ── Envío ────────────────────────────────────────────────────────────────────
  bool _sending = false;

  /// Arma la solicitud en el orden que pide el backend: la cita de primer
  /// contacto toma los documentos "del perfil del usuario" al crearse, así que
  /// foto, documentos y datos van antes; la cita, al final.
  Future<void> _submit() async {
    if (_sending) return;
    setState(() => _sending = true);
    final token = currentAuthenticationToken ?? '';
    var userId = currentUserUid;
    String? error;

    String failMsg(ApiCallResponse res, String what) {
      if (res.statusCode == -1) return apiErrorMessage(res, '');
      final m = apiBodyMessage(res.jsonBody);
      return m != null ? 'No se pudo $what: $m' : 'No se pudo $what.';
    }

    try {
      // Los documentos van a /users/{id}/...: sin id el pedido sale a
      // /users//... y falla. Se busca en el perfil antes de intentar.
      if (userId.isEmpty) {
        final profile = await DOVIAAPIUserContextGroup
            .getAuthenticatedUserProfileCall
            .call(authToken: token);
        userId = DOVIAAPIUserContextGroup.getAuthenticatedUserProfileCall
                .userId(profile.jsonBody) ??
            '';
        if (userId.isEmpty) {
          error = 'No pudimos identificar tu cuenta. Cierra sesión y vuelve '
              'a entrar.';
        }
      }

      final photo = _profileImageBytes;
      if (photo != null && error == null) {
        final res =
            await DOVIAAPIUserContextGroup.uploadProfilePictureCall.call(
          authToken: token,
          file: FFUploadedFile(name: 'perfil.jpg', bytes: photo),
        );
        if (!res.succeeded) error = failMsg(res, 'subir la foto de perfil');
      }

      final docs = <String, FFUploadedFile?>{
        'identification-document': _fileFotografiaId,
        'criminal-record': _fileAntecedentesPenales,
        'police-record': _fileAntecedentesPoliciacos,
        'utility-bill': _fileRecibo,
      };
      for (final e in docs.entries) {
        if (error != null) break;
        final file = e.value;
        if (file == null) continue;
        if (identical(file, RegistrationIdDocument.uploaded)) continue;
        final res = await DOVIAAPIUserContextGroup.uploadUserDocumentCall.call(
          userId: userId,
          documentType: e.key,
          authToken: token,
          file: file,
        );
        if (!res.succeeded) error = failMsg(res, 'subir un documento');
      }

      if (error == null) {
        final address = _direccionController.text.trim();
        final zoneId = _workZoneId;
        if (address.isNotEmpty || zoneId != null) {
          final res = await DOVIAAPIUserContextGroup.updateUserProfileCall.call(
            userId: userId,
            authToken: token,
            address: address.isNotEmpty ? address : null,
            workZoneId: zoneId,
          );
          if (!res.succeeded) {
            error = failMsg(res, 'guardar tu dirección y zona de trabajo');
          }
        }
      }

      if (error == null) {
        final f = _fechaEntrevista!;
        final h = _horaEntrevista!;
        final scheduledAt =
            DateTime(f.year, f.month, f.day, h.hour, h.minute).toUtc();
        final res = await DoviaAPIRecruitmentGroup.createFirstContactCall.call(
          bearerAuth: token,
          scheduledAt: scheduledAt.toIso8601String(),
        );
        // 409: la solicitud ya existía (p. ej. un reintento); se sigue igual.
        if (!res.succeeded && res.statusCode != 409) {
          error = failMsg(res, 'agendar la entrevista');
        }
      }
    } catch (_) {
      error = 'No se pudo enviar la solicitud. Revisa tu conexión.';
    }

    if (!mounted) return;
    setState(() => _sending = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    widget.onEnviar?.call();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadZones();
      _loadRemoteDocs();
      final idDoc = RegistrationIdDocument.uploaded;
      if (idDoc != null) setState(() => _fileFotografiaId = idDoc);
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
    _zoneController.dispose();
    _scrollController.dispose();
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
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding:
                const EdgeInsets.only(top: 56, bottom: 40, left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileSection(),
                const SizedBox(height: 30),
                _buildFormFields(),
                const SizedBox(height: 14),
                _buildZoneSection(),
                const SizedBox(height: 30),
                // Date / time BEFORE documents (as in Figma)
                _buildDateTimeSection(),
                const SizedBox(height: 19),
                _buildDocumentUpload(
                  'Fotografía del ID (opcional)',
                  _fileFotografiaId,
                  () => _pickFile((f) => _fileFotografiaId = f),
                  () => setState(() => _fileFotografiaId = null),
                  remoteUrl: _remoteDocs['identification-document'],
                ),
                const SizedBox(height: 19),
                _buildDocumentUpload(
                  'Antecedentes penales (opcional)',
                  _fileAntecedentesPenales,
                  () => _pickFile((f) => _fileAntecedentesPenales = f),
                  () => setState(() => _fileAntecedentesPenales = null),
                  remoteUrl: _remoteDocs['criminal-record'],
                ),
                const SizedBox(height: 19),
                _buildDocumentUpload(
                  'Antecedentes policiales (opcional)',
                  _fileAntecedentesPoliciacos,
                  () => _pickFile((f) => _fileAntecedentesPoliciacos = f),
                  () => setState(() => _fileAntecedentesPoliciacos = null),
                  remoteUrl: _remoteDocs['police-record'],
                ),
                const SizedBox(height: 19),
                _buildDocumentUpload(
                  'Recibo de agua, luz o teléfono de la vivienda (opcional)',
                  _fileRecibo,
                  () => _pickFile((f) => _fileRecibo = f),
                  () => setState(() => _fileRecibo = null),
                  remoteUrl: _remoteDocs['utility-bill'],
                ),
                const SizedBox(height: 19),
                _buildDisclaimer(),
                const SizedBox(height: 19),
                _buildSubmitButton(),
              ],
            ),
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
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickProfileImage,
          child: Text(
            _profileImageBytes == null
                ? 'Agrega una foto de perfil'
                : 'Cambiar foto de perfil',
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: aquaColor,
            ),
          ),
        ),
        if (_profileImageBytes == null) ...[
          const SizedBox(height: 2),
          const Text(
            'Ayuda a que los clientes te reconozcan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: Color(0xFF6A6A6A),
            ),
          ),
        ],
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
  /// Los datos personales vienen del registro: se muestran sólo para
  /// revisar. Lo único que se completa acá es la dirección.
  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTwoColumnRow(
          _buildInputField('Nombres', _nombresController, '', readOnly: true),
          _buildInputField('Apellidos', _apellidosController, '',
              readOnly: true),
        ),
        const SizedBox(height: 14),
        _buildTwoColumnRow(
          _buildInputField('Sexo', _sexoController, '', readOnly: true),
          _buildInputField('Nacionalidad', _nacionalidadController, '',
              readOnly: true),
        ),
        const SizedBox(height: 14),
        _buildTwoColumnRow(
          _buildInputField('Edad', _edadController, '', readOnly: true),
          _buildPhoneField(),
        ),
        const SizedBox(height: 14),
        _buildTwoColumnRow(
          _buildInputField('Correo', _correoController, '', readOnly: true),
          _buildInputField(
            'Dirección de vivienda',
            _direccionController,
            'Calle 123',
          ),
        ),
      ],
    );
  }

  /// En el celular los campos van uno debajo del otro.
  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        left,
        const SizedBox(height: 14),
        right,
      ],
    );
  }

  /// Etiqueta de campo obligatorio: texto + asterisco rojo.
  Widget _requiredLabel(String label,
          {double fontSize = 14, bool required = true}) =>
      Text.rich(
        TextSpan(children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: errorColor)),
        ]),
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: textColor,
          letterSpacing: 0.28,
        ),
      );

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String placeholder, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool required = false,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel(label, required: required),
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
        _requiredLabel('Teléfono', required: false),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _telefonoCodeController,
                readOnly: true,
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
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: TextField(
                      controller: _telefonoController,
                      readOnly: true,
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
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Zona de trabajo ──────────────────────────────────────────────────────────
  Widget _buildZoneSection() {
    final zones = _zones;
    // Sin zonas configuradas en el backend no hay nada que elegir.
    if (zones != null && zones.isEmpty && !_zonesFailed) {
      return const SizedBox.shrink();
    }
    const infoStyle = TextStyle(
        fontFamily: 'Public Sans', fontSize: 13, color: Color(0xFF6A6A6A));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _requiredLabel('Zona de trabajo', required: _zoneRequired),
        const SizedBox(height: 12),
        if (zones == null)
          const Text('Cargando zonas…', style: infoStyle)
        else if (_zonesFailed)
          Row(
            children: [
              const Expanded(
                child: Text('No pudimos cargar las zonas.', style: infoStyle),
              ),
              TextButton(
                onPressed: _loadZones,
                child: const Text('Reintentar',
                    style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                        color: aquaColor)),
              ),
            ],
          )
        else
          FlutterFlowDropDown<String>(
            controller: _zoneController,
            options: [for (final z in zones) z.id],
            optionLabels: [for (final z in zones) z.name],
            onChanged: (val) => setState(() => _workZoneId = val),
            width: double.infinity,
            height: 42,
            textStyle: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: textColor,
                letterSpacing: 0.28),
            hintText: 'Selecciona la zona donde trabajarás',
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: placeholderColor, size: 24),
            fillColor: inputBg,
            elevation: 2,
            borderColor: Colors.transparent,
            borderWidth: 0,
            borderRadius: 10,
            margin: const EdgeInsetsDirectional.fromSTEB(15, 0, 12, 0),
            hidesUnderline: true,
            isSearchable: false,
            isMultiSelect: false,
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
        _requiredLabel(
          'Selecciona la fecha y la hora para que DOVIA se comunique contigo y coordine una entrevista',
          fontSize: 16,
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
    FFUploadedFile? file,
    VoidCallback onPick,
    VoidCallback onRemove, {
    String? remoteUrl,
  }) {
    final bytes = file?.bytes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: 0.32),
        ),
        const SizedBox(height: 12),
        if (bytes == null && remoteUrl != null)
          // Ya subido antes: se ve lo guardado y tocando se reemplaza.
          GestureDetector(
            onTap: onPick,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    remoteUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 104,
                      width: double.infinity,
                      color: inputBg,
                      alignment: Alignment.center,
                      child: const Icon(Icons.insert_drive_file_outlined,
                          size: 28, color: aquaColor),
                    ),
                    cacheWidth: networkImageCacheWidth(
                        width: double.infinity, height: 160),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Ya cargado · Toca para reemplazar',
                      style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (bytes == null)
          GestureDetector(
            onTap: onPick,
            child: Container(
              height: 104,
              width: double.infinity,
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0x2670ACAD),
                    child: Icon(Icons.add_a_photo_outlined,
                        size: 20, color: aquaColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toca para agregar una foto',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: aquaColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: onPick,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(bytes, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xCC000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
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
    final missing = _missingFields;
    return Column(children: [
      _submitButton(enabled),
      if (!enabled && missing.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          'Falta completar: ${missing.join(', ')}.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 13,
            color: Color(0xFF6A6A6A),
          ),
        ),
      ],
    ]);
  }

  Widget _submitButton(bool enabled) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 607),
        child: SizedBox(
          width: double.infinity,
          height: 42,
          child: GestureDetector(
            onTap: enabled && !_sending ? _submit : null,
            child: Container(
              decoration: BoxDecoration(
                color: enabled ? aquaColor : aquaColor.withAlpha(100),
                border: Border.all(
                    color: enabled ? aquaColor : aquaColor.withAlpha(100)),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: _sending
                  ? const DoviaSpinner(small: true, color: Colors.white)
                  : const Text(
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
