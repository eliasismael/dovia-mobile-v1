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
  final Future Function(String? reason)? onDeleteAccount;

  /// Called when the user taps "Cerrar sesión".
  final Future Function()? onSignOut;

  final Future Function()? onTermsAndConditions;
  final Future Function()? onSupport;
  final Future Function()? onLogout;
  final Future Function()? onSaveInfo;

  const OperativeListingProfile({
    super.key,
    this.width,
    this.height,
    this.onDeleteAccount,
    this.onSignOut,
    this.onTermsAndConditions,
    this.onSupport,
    this.onLogout,
    this.onSaveInfo,
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

  // Notification toggles
  bool _notifDailyListing = false;
  bool _notifRecomendaciones = false;
  bool _notifTips = false;
  bool _notifNovedades = false;
  bool _notifInformeSemanal = false;

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
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
              _buildNotificacionesTab(),
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
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? tabActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: isSelected ? aqua : inputPlaceholder,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
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
          _readonlyField('Edad', ageStr),
          const SizedBox(height: 14),
          _readonlyField('Correo', email),
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
            _readonlyField('Ya ganaste', earnedStr),
            const SizedBox(height: 14),
            _readonlyFieldWithIcon(
              'Calificaciones (estrellas)',
              starsStr,
              const Icon(Icons.star_rounded,
                  size: 18, color: Color(0xFFFFC107)),
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
          Column(
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
                onTap: () async {
                  if (widget.onTermsAndConditions != null) {
                    await widget.onTermsAndConditions!.call();
                  }
                  _openTermsModal();
                },
              ),
              const SizedBox(height: 20),
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
                onTap: () async {
                  if (widget.onSupport != null) {
                    await widget.onSupport!.call();
                  }
                  _openSupportChat();
                },
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
            onTap: () async {
              if (widget.onLogout != null) {
                await widget.onLogout!.call();
              } else if (widget.onSignOut != null) {
                await widget.onSignOut!.call();
              }
            },
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

  // ─── Notificaciones Tab ───────────────────────────────────────────────────────

  Widget _buildNotificacionesTab() {
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
            'Notificaciones',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: aqua,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Daily listing',
            subtitle:
                'Recibe notificaciones cuando publiquemos nuevas propiedades que pueden interesarte',
            value: _notifDailyListing,
            onChanged: (val) => setState(() => _notifDailyListing = val),
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Recomendaciones',
            subtitle:
                'Recibe notificaciones cuando encontremos propiedades que se ajusten a tus búsquedas recientes.',
            value: _notifRecomendaciones,
            onChanged: (val) => setState(() => _notifRecomendaciones = val),
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Tips',
            subtitle: 'Recibe notificaciones con tips semanales',
            value: _notifTips,
            onChanged: (val) => setState(() => _notifTips = val),
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Novedades',
            subtitle: 'Recibe notificaciones sobre novedades en Dovia',
            value: _notifNovedades,
            onChanged: (val) => setState(() => _notifNovedades = val),
          ),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Informe semanal',
            subtitle:
                'Recibe un informe semanal sobre la interacción que tuvo tu propiedad.',
            value: _notifInformeSemanal,
            onChanged: (val) => setState(() => _notifInformeSemanal = val),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: inputPlaceholder,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: aqua,
        ),
      ],
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
        setState(() => _avatarVersion = DateTime.now().millisecondsSinceEpoch);
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTermsModal() {
    showDialog(
      context: context,
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
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmDialog(
        onConfirm: () {
          Navigator.pop(context);
          _showReasonDialog();
        },
      ),
    );
  }

  void _showReasonDialog() {
    showDialog(
      context: context,
      builder: (context) => _DeleteReasonDialog(
        controller: _deleteReasonController,
        onConfirm: () async {
          Navigator.pop(context);
          if (widget.onDeleteAccount != null) {
            final reason = _deleteReasonController.text.trim();
            await widget.onDeleteAccount!.call(reason.isEmpty ? null : reason);
          }
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const _DeleteSuccessDialog(),
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                if (widget.onLogout != null) {
                  widget.onLogout!.call();
                } else if (widget.onSignOut != null) {
                  widget.onSignOut!.call();
                }
              }
            });
          }
        },
      ),
    );
  }

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
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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

class _TermsModal extends StatelessWidget {
  const _TermsModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 20, right: 20, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Términos y condiciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00444B),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close,
                        color: Color(0xFF00444B), size: 24),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  _termsText,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: Color(0xFF007376),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static const String _termsText = '''
1. ¿QUÉ ES DOVIA?
• DOVIA es una plataforma digital que permite: publicar propiedades, coordinar visitas,
• recibir y gestionar ofertas, facilitar procesos de venta y renta de inmuebles.
• DOVIA no es propietaria de los inmuebles, no es agente inmobiliario tradicional, DOVIA
no representa legalmente a ninguna de las partes, DOVIA actúa únicamente como
plataforma de facilitación tecnológica.

2. RESPONSABILIDAD DEL USUARIO
• Cada usuario es responsable de la información que publica, las decisiones que toma,
los acuerdos que celebra.
• DOVIA no garantiza, cierres de venta o renta, precios, comportamiento de otros
usuarios, resultados de negociaciones.

3. PUBLICACIÓN DE PROPIEDADES
• Al publicar una propiedad en DOVIA, el propietario declara que, es el legítimo
propietario o cuenta con autorización expresa, la información proporcionada es veraz y
actualizada.
• DOVIA no se hace responsable por información falsa, incompleta o engañosa
proporcionada por los usuarios.

4. ACUERDOS FUERA DE DOVIA (CLÁUSULA CRÍTICA)
• Si un propietario, comprador, arrendatario o interesado negocia, agenda visitas,
intercambia datos, realiza pagos, firma contratos, utiliza abogados o notarios, FUERA
DE LA APLICACIÓN DOVIA, acepta expresamente que:
o DOVIA no se hace responsable de ningún problema, estafa, incumplimiento,
daño, pérdida económica o conflicto legal derivado de dichos acuerdos.
o Esto incluye contratos privados, escrituras, pagos en efectivo o transferencias
externas, acuerdos verbales.

5. VISITAS, CITAS Y SEGURIDAD
• DOVIA realiza verificaciones básicas de usuarios, sin garantizar identidad real,
conducta, intenciones.
• Si un usuario decide reunirse, permitir visitas, coordinar citas, fuera de la app, lo hace
bajo su propio riesgo, y acepta que DOVIA no es responsable de robos, estafas, daños
físicos o amenazas.

6. COMISIONES Y OBLIGACIONES DEL PROPIETARIO
• DOVIA obtiene sus ingresos mediante comisiones cobradas al propietario cuando una
operación de venta o renta se origina, gestiona o facilita a través de la app.
• Al publicar una propiedad, el propietario acepta que todo contacto, visita u oferta
generada a partir de DOVIA se considera originada por la Plataforma.
• La comisión de DOVIA es exigible si la operación se concreta, aunque el cierre final se
realice fuera de la app.

Evasión de comisiones
• Si el propietario retira la propiedad, negocia directamente con un interesado, utiliza
abogados. notarios o intermediarios externos. firma contratos fuera de DOVIA. con el
propósito de evitar el pago de la comisión, DOVIA se reserva el derecho de tomar acciones.
''';
}

class _DeleteConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _DeleteConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro que quieres eliminar\ntu cuenta?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00444B),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF007376), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF007376))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Eliminar cuenta',
                          style: TextStyle(
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
    );
  }
}

class _DeleteReasonDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onConfirm;
  const _DeleteReasonDialog(
      {required this.controller, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cuéntanos por qué deseas eliminar\ntu cuenta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00444B),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Color(0xFF00444B),
                ),
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí....',
                  hintStyle: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007376),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text('Enviar',
                    style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteSuccessDialog extends StatelessWidget {
  const _DeleteSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Se eliminó con éxito',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00444B),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tu cuenta se ha eliminado con éxito.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF007376),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
