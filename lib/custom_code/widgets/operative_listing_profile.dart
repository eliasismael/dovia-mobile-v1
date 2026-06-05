// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '/repositories/user_repository.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import '/core/result.dart';

class OperativeListingProfile extends StatefulWidget {
  final double? width;
  final double? height;

  /// Called after the user confirms the delete-account flow (confirm + reason).
  final Future Function()? onDeleteAccount;

  /// Called when the user taps "Cerrar sesión".
  final Future Function()? onSignOut;

  const OperativeListingProfile({
    super.key,
    this.width,
    this.height,
    this.onDeleteAccount,
    this.onSignOut,
  });

  @override
  State<OperativeListingProfile> createState() =>
      _OperativeListingProfileState();
}

/// Document blocks shown in the "Documentación" accordion.
enum _DocType {
  identification('identification-document', 'Fotografía del ID', true),
  criminal('criminal-record', 'Antecedentes penales', false),
  police('police-record', 'Antecedentes policiacos', false),
  utility('utility-bill', 'Recibo de agua, luz o teléfono de vivienda', false);

  const _DocType(this.slug, this.label, this.required);
  final String slug;
  final String label;
  final bool required;
}

class _OperativeListingProfileState extends State<OperativeListingProfile> {
  int _selectedTab = 0;
  bool _datosPersonalesExpanded = true;
  bool _gananciasExpanded = false;
  bool _documentacionExpanded = false;

  // Password controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  // Delete-account reason
  final _deleteReasonController = TextEditingController();

  // Avatar upload state
  Uint8List? _tempAvatarBytes;
  int _avatarVersion = DateTime.now().millisecondsSinceEpoch;

  // Documents that were uploaded during this session (slug set), used to
  // reflect the uploaded state even when the API doesn't return a URL.
  final Set<String> _uploadedThisSession = {};
  String? _uploadingDocSlug;

  static const Color textPrimary = Color(0xFF00444B);
  static const Color aqua = Color(0xFF007376);
  static const Color backgroundGray = Color(0xFFFAFAFA);
  static const Color inputPlaceholder = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE9EFF2);
  static const Color badgeTextColor = Color(0xFFCCE3E4);
  static const Color tabActiveBg = Color(0xFFCCE3E4);
  static const Color deleteRed = Color(0xFFF93A3A);

  @override
  void initState() {
    super.initState();
    // Load fresh data on first render (cached if already loaded).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<UserRepository>();
      repo.loadProfile();
      repo.loadPerformanceSummary();
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    _deleteReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UserRepository>();
    final profile = repo.profile;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTabBar(),
            const SizedBox(height: 20),
            if (_selectedTab == 0) ...[
              if (repo.isLoading && profile == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: aqua),
                  ),
                )
              else ...[
                _buildPerfilCard(repo),
                const SizedBox(height: 16),
                _buildGananciasCard(repo),
                const SizedBox(height: 16),
                _buildDocumentacionCard(repo),
                const SizedBox(height: 16),
                _buildCambioContrasenaCard(),
                const SizedBox(height: 16),
                _buildSoporteYLegalSection(),
                const SizedBox(height: 16),
                _buildAccionesCriticasSection(),
                const SizedBox(height: 16),
              ],
            ] else ...[
              _buildNotificacionesPlaceholder(),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007376).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Perfil y seguridad'),
          _buildTabItem(1, 'Configuración de notificaciones'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? tabActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: isSelected ? aqua : inputPlaceholder,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // ─── Perfil Card ──────────────────────────────────────────────────────────────

  Widget _buildPerfilCard(UserRepository repo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: aqua,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 20),
          _buildAvatarSection(repo),
          const SizedBox(height: 20),
          _buildDatosPersonalesSection(repo),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(UserRepository repo) {
    final profile = repo.profile;
    final avatarUrl = profile?.profilePictureUrl != null
        ? '${profile!.profilePictureUrl!}?v=$_avatarVersion'
        : null;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipOval(
                child: Container(
                  width: 76,
                  height: 76,
                  color: backgroundGray,
                  child: _tempAvatarBytes != null
                      ? Image.memory(_tempAvatarBytes!,
                          width: 76, height: 76, fit: BoxFit.cover)
                      : (avatarUrl != null
                          ? Image.network(
                              avatarUrl,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 40,
                                color: inputPlaceholder,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: inputPlaceholder,
                            )),
                ),
              ),
              GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: aqua,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: aqua,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Dovia Operative Listing',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Datos Personales (read-only) ─────────────────────────────────────────────

  Widget _buildDatosPersonalesSection(UserRepository repo) {
    final profile = repo.profile;

    final firstName = profile?.firstName ?? '—';
    final lastName = profile?.lastName ?? '—';
    final nationality = profile?.nationality ?? '—';
    final gender = _genderLabel(profile?.gender);
    final ageStr = profile?.age != null ? '${profile!.age}' : '—';
    final email = profile?.email ?? '—';
    final phone = profile != null && profile.phoneNumber != null
        ? '${profile.phoneCountryCode ?? ''} ${profile.phoneNumber}'.trim()
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          title: 'Datos personales',
          isExpanded: _datosPersonalesExpanded,
          onTap: () => setState(
            () => _datosPersonalesExpanded = !_datosPersonalesExpanded,
          ),
        ),
        const SizedBox(height: 14),
        if (_datosPersonalesExpanded) ...[
          Row(
            children: [
              Expanded(child: _readonlyField('Nombres', firstName)),
              const SizedBox(width: 14),
              Expanded(child: _readonlyField('Apellidos', lastName)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _readonlyField('Nacionalidad', nationality)),
              const SizedBox(width: 14),
              Expanded(child: _readonlyField('Sexo', gender)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _readonlyField('Edad', ageStr)),
              const SizedBox(width: 14),
              Expanded(child: _readonlyField('Correo', email)),
            ],
          ),
          const SizedBox(height: 14),
          _readonlyField('Teléfono', phone.isEmpty ? '—' : phone),
          const SizedBox(height: 14),
          _buildPerimetroField(profile),
        ],
      ],
    );
  }

  String _genderLabel(String? gender) {
    switch (gender) {
      case 'MALE':
        return 'Masculino';
      case 'FEMALE':
        return 'Femenino';
      case 'OTHER':
        return 'Otro';
      default:
        return '—';
    }
  }

  Widget _buildPerimetroField(profile) {
    final hasLocation = profile?.latitude != null && profile?.longitude != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu perímetro',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: double.infinity,
            height: 155,
            child: hasLocation
                ? DrawMapComponentWidget(
                    height: 155,
                    initialLatitude: profile.latitude!,
                    initialLongitude: profile.longitude!,
                    singlePointMode: true,
                    interactive: false,
                  )
                : Container(
                    color: backgroundGray,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off_outlined,
                              size: 36, color: inputPlaceholder),
                          SizedBox(height: 6),
                          Text(
                            'Ubicación no disponible',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 13,
                              color: inputPlaceholder,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ─── Ganancias Card (read-only metrics) ───────────────────────────────────────

  Widget _buildGananciasCard(UserRepository repo) {
    final earnedStr = 'GTQ ${(repo.totalEarned ?? 0).toStringAsFixed(2)}';
    final starsStr = (repo.averageStars ?? 0).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownHeader(
            title: 'Ganancias',
            isExpanded: _gananciasExpanded,
            onTap: () =>
                setState(() => _gananciasExpanded = !_gananciasExpanded),
          ),
          if (_gananciasExpanded) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _readonlyField('Ya ganaste', earnedStr),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _readonlyFieldWithIcon(
                    'Calificaciones (estrellas)',
                    starsStr,
                    const Icon(Icons.star_rounded,
                        size: 18, color: Color(0xFFFFC107)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Premio por llegar a siguiente categoría',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                color: inputPlaceholder,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Documentación Card (file uploads) ────────────────────────────────────────

  Widget _buildDocumentacionCard(UserRepository repo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownHeader(
            title: 'Documentación',
            isExpanded: _documentacionExpanded,
            onTap: () => setState(
                () => _documentacionExpanded = !_documentacionExpanded),
          ),
          if (_documentacionExpanded) ...[
            const SizedBox(height: 16),
            for (final doc in _DocType.values) ...[
              _buildDocBlock(repo, doc),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  bool _isDocUploaded(UserRepository repo, _DocType doc) {
    if (_uploadedThisSession.contains(doc.slug)) return true;
    final profile = repo.profile;
    switch (doc) {
      case _DocType.identification:
        return profile?.identificationDocumentUrl != null;
      case _DocType.criminal:
        return profile?.criminalRecordUrl != null;
      case _DocType.police:
        return profile?.policeRecordUrl != null;
      case _DocType.utility:
        return profile?.utilityBillUrl != null;
    }
  }

  Widget _buildDocBlock(UserRepository repo, _DocType doc) {
    final uploaded = _isDocUploaded(repo, doc);
    final uploading = _uploadingDocSlug == doc.slug;
    final label = doc.required ? doc.label : '${doc.label} (Opcional)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doc == _DocType.identification ? 'Fotografía del ID' : label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: uploading ? null : () => _pickDocument(doc),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundGray,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: uploaded ? aqua : borderColor,
                width: 1,
              ),
            ),
            child: Center(
              child: uploading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: aqua),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          uploaded
                              ? Icons.check_circle
                              : Icons.upload_file_outlined,
                          size: 22,
                          color: uploaded ? aqua : inputPlaceholder,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          uploaded ? 'Documento cargado' : 'Cargar documento',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: uploaded ? aqua : inputPlaceholder,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Cambio de Contraseña Card ────────────────────────────────────────────────

  Widget _buildCambioContrasenaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cambio de contraseña',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: aqua,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 20),
          _PasswordField(
            label: 'Contraseña actual',
            controller: _currentPasswordController,
          ),
          const SizedBox(height: 14),
          _PasswordField(
            label: 'Contraseña nueva',
            controller: _newPasswordController,
            helperText: 'Debe tener 8 caracteres',
          ),
          const SizedBox(height: 14),
          _PasswordField(
            label: 'Repetir contraseña nueva',
            controller: _repeatPasswordController,
            helperText: 'Debe ser igual a la nueva contraseña',
          ),
          const SizedBox(height: 24),
          _buildSolidButton(
              label: 'Actualizar contraseña', onTap: _handleUpdatePassword),
        ],
      ),
    );
  }

  // ─── Soporte y Legal Section ──────────────────────────────────────────────────

  Widget _buildSoporteYLegalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soporte y legal',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: aqua,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ver términos y condiciones',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: textPrimary,
                        letterSpacing: 0.32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOutlinedButton(
                      label: 'Términos y condiciones',
                      onTap: _openTermsModal,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ayuda o soporte',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: textPrimary,
                        letterSpacing: 0.32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOutlinedButton(
                      label: 'Soporte',
                      onTap: _openSupportChat,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Acciones Críticas Section ────────────────────────────────────────────────

  Widget _buildAccionesCriticasSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones críticas',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: aqua,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 20),
          const Text(
            'Deseo cerrar sesión',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: textPrimary,
              letterSpacing: 0.32,
            ),
          ),
          const SizedBox(height: 12),
          _buildOutlinedButton(
            label: 'Cerrar sesión',
            onTap: () async => await widget.onSignOut?.call(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Deseo eliminar mi cuenta',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: textPrimary,
              letterSpacing: 0.32,
            ),
          ),
          const SizedBox(height: 12),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  // ─── Notificaciones Placeholder ───────────────────────────────────────────────

  Widget _buildNotificacionesPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Configuración de notificaciones próximamente',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 16,
          color: inputPlaceholder,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _pickAvatar() async {
    final repo = context.read<UserRepository>();
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() => _tempAvatarBytes = bytes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Subiendo imagen de perfil...'),
        duration: Duration(seconds: 2),
      ));
    }

    final ffFile = FFUploadedFile(name: image.name, bytes: bytes);
    final result = await repo.uploadAvatar(ffFile);

    if (!mounted) return;
    setState(() => _tempAvatarBytes = null);
    switch (result) {
      case Success():
        setState(
            () => _avatarVersion = DateTime.now().millisecondsSinceEpoch);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Imagen actualizada correctamente'),
          backgroundColor: aqua,
        ));
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $message'),
          backgroundColor: deleteRed,
        ));
    }
  }

  Future<void> _pickDocument(_DocType doc) async {
    final repo = context.read<UserRepository>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final bytes = picked.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo leer el archivo'),
          backgroundColor: deleteRed,
        ));
      }
      return;
    }

    setState(() => _uploadingDocSlug = doc.slug);

    final ffFile = FFUploadedFile(name: picked.name, bytes: bytes);
    final res = await repo.uploadDocument(doc.slug, ffFile);

    if (!mounted) return;
    setState(() => _uploadingDocSlug = null);
    switch (res) {
      case Success():
        setState(() => _uploadedThisSession.add(doc.slug));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Documento cargado correctamente'),
          backgroundColor: aqua,
        ));
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $message'),
          backgroundColor: deleteRed,
        ));
    }
  }

  void _handleUpdatePassword() {
    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final repeat = _repeatPasswordController.text;

    if (current.isEmpty || next.isEmpty || repeat.isEmpty) {
      _showSnack('Completa todos los campos de contraseña');
      return;
    }
    if (next.length < 8) {
      _showSnack('La nueva contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (next != repeat) {
      _showSnack('Las contraseñas no coinciden');
      return;
    }
    // Credential changes go through the verified recover-password flow.
    context.pushNamed('RecoverPassword_1');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TermsModal(),
    );
  }

  void _openSupportChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const DoviaSupportWidget(),
        ),
      ),
    );
  }

  // ─── Delete account flow (2 pop-ups) ──────────────────────────────────────────

  void _showDeleteAccountFlow() {
    _showConfirmBottomSheet(
      title: '¿Estás seguro de que quieres eliminar tu cuenta?',
      subtitle: 'Esta acción es permanente y perderás todos tus datos.',
      confirmLabel: 'Eliminar permanentemente',
      onConfirm: () {
        _showReasonBottomSheet(
          title: '¿Por qué quieres eliminar tu cuenta?',
          controller: _deleteReasonController,
          onConfirm: () async {
            await widget.onDeleteAccount?.call();
          },
        );
      },
    );
  }

  void _showConfirmBottomSheet({
    required String title,
    required String subtitle,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: inputPlaceholder,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: aqua),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deleteRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(confirmLabel,
                            style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReasonBottomSheet({
    required String title,
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(),
              const SizedBox(height: 24),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu motivo aquí...',
                  hintStyle: const TextStyle(
                      fontSize: 14, color: inputPlaceholder),
                  filled: true,
                  fillColor: backgroundGray,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aqua,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: const Text('Confirmar',
                      style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetHandle() => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
      );

  // ─── Shared Builders ──────────────────────────────────────────────────────────

  Widget _buildDropdownHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: 16,
          right: 12,
          top: 10,
          bottom: 10,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: textPrimary,
                  height: 24 / 16,
                ),
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 24,
              color: textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: backgroundGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value.isEmpty ? '—' : value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 15,
              color: inputPlaceholder,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _readonlyFieldWithIcon(String label, String value, Widget icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: backgroundGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 15,
                  color: inputPlaceholder,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: aqua, width: 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: aqua,
          ),
        ),
      ),
    );
  }

  Widget _buildSolidButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aqua,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _showDeleteAccountFlow,
      child: Container(
        width: double.infinity,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: deleteRed,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Text(
          'Eliminar cuenta',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Password Field (self-contained StatefulWidget to avoid null-bool issues) ──

class _PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? helperText;

  const _PasswordField({
    required this.label,
    required this.controller,
    this.helperText,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  static const Color textPrimary = Color(0xFF00444B);
  static const Color backgroundGray = Color(0xFFFAFAFA);
  static const Color inputPlaceholder = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            color: backgroundGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscure,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    color: textPrimary,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: inputPlaceholder,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: textPrimary,
              letterSpacing: 0.28,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Terms & Conditions Modal ──────────────────────────────────────────────────

class _TermsModal extends StatefulWidget {
  const _TermsModal();

  @override
  State<_TermsModal> createState() => _TermsModalState();
}

class _TermsModalState extends State<_TermsModal> {
  final ScrollController _scroll = ScrollController();
  bool _canAccept = false;

  static const Color _aqua = Color(0xFF007376);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 32) {
      if (!_canAccept) setState(() => _canAccept = true);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, sheetCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const Text('Términos y Condiciones',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00444B))),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: const Text(
                _termsText,
                style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: Color(0xFF444444),
                    height: 1.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!_canAccept)
            const Text(
              'Desplázate hasta el final para aceptar',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: Color(0xFF888888)),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _canAccept ? () => Navigator.of(context).pop() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _aqua,
                disabledBackgroundColor: _aqua.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('Aceptar y cerrar',
                  style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  static const String _termsText = '''
TÉRMINOS Y CONDICIONES DE USO – DOVIA

Última actualización: enero 2025

1. ACEPTACIÓN DE LOS TÉRMINOS
Al acceder y usar la plataforma DOVIA ("la Plataforma"), el usuario acepta estos Términos y Condiciones en su totalidad. Si no está de acuerdo, debe abstenerse de usar la Plataforma.

2. DESCRIPCIÓN DEL SERVICIO
DOVIA es una plataforma digital que facilita la publicación, búsqueda y negociación de bienes inmuebles entre propietarios y compradores/arrendatarios, con asistencia de asesores inmobiliarios certificados ("Showings").

3. REGISTRO Y CUENTA
El usuario debe proporcionar información veraz y actualizada. Es responsable de mantener la confidencialidad de sus credenciales de acceso. DOVIA se reserva el derecho de suspender cuentas con información falsa o actividad fraudulenta.

4. ROL DE ASOCIADO OPERATIVO
El Asociado de Operative Listing se compromete a realizar las visitas y levantamientos asignados con diligencia, cargar la documentación requerida y mantener su perfil operativo actualizado dentro de la Plataforma.

5. USO ACEPTABLE
El usuario se compromete a no publicar información falsa sobre inmuebles, no usar la plataforma para actividades ilegales, y no interferir con el funcionamiento técnico del sistema.

6. PRIVACIDAD Y DATOS
DOVIA recopila y procesa datos personales conforme a su Política de Privacidad. Los datos son utilizados exclusivamente para prestar el servicio y mejorar la experiencia del usuario.

7. PROPIEDAD INTELECTUAL
Todo el contenido de la Plataforma —incluyendo logos, diseños y software— es propiedad exclusiva de DOVIA o sus licenciantes y está protegido por las leyes de propiedad intelectual.

8. LIMITACIÓN DE RESPONSABILIDAD
DOVIA actúa como intermediario y no se hace responsable de las transacciones celebradas entre usuarios, ni de la veracidad de la información publicada por terceros.

9. MODIFICACIONES
DOVIA puede modificar estos Términos en cualquier momento. Los cambios sustanciales serán notificados a los usuarios con al menos 15 días de anticipación.

10. LEGISLACIÓN APLICABLE
Estos Términos se rigen por las leyes aplicables. Cualquier disputa será resuelta ante los tribunales competentes.

Al usar la Plataforma confirmas haber leído, entendido y aceptado la totalidad de estos Términos y Condiciones.
''';
}
