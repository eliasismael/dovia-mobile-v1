// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class OperativeListingProfile extends StatefulWidget {
  final double? width;
  final double? height;

  final VoidCallback? onTermsAndConditions;
  final VoidCallback? onSupport;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;
  final Function? onSaveInfo;

  const OperativeListingProfile({
    super.key,
    this.width,
    this.height,
    this.onTermsAndConditions,
    this.onSupport,
    this.onLogout,
    this.onDeleteAccount,
    this.onSaveInfo,
  });

  @override
  State<OperativeListingProfile> createState() =>
      _OperativeListingProfileState();
}

class _OperativeListingProfileState extends State<OperativeListingProfile> {
  int _selectedTab = 0;
  bool _datosPersonalesExpanded = true;
  bool _isEditing = false;

  final _nombresController = TextEditingController(text: 'Laura');
  final _apellidosController = TextEditingController(text: 'Martinez');
  final _nacionalidadController = TextEditingController(text: 'Colombiana');
  final _sexoController = TextEditingController(text: 'Femenino');
  final _edadController = TextEditingController(text: '28');
  final _correoController = TextEditingController(
    text: 'lauramartinez@gmail.com',
  );
  final _countryCodeController = TextEditingController(text: '+51');
  final _phoneController = TextEditingController(text: '123456789');
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _nacionalidadController.dispose();
    _sexoController.dispose();
    _edadController.dispose();
    _correoController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  static const Color textPrimary = Color(0xFF00444B);
  static const Color aqua = Color(0xFF007376);
  static const Color backgroundGray = Color(0xFFFAFAFA);
  static const Color inputPlaceholder = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE9EFF2);
  static const Color badgeTextColor = Color(0xFFCCE3E4);
  static const Color tabActiveBg = Color(0xFFCCE3E4);
  static const Color deleteRed = Color(0xFFF93A3A);

  @override
  Widget build(BuildContext context) {
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
              _buildPerfilCard(),
              const SizedBox(height: 16),
              _buildCambioContrasenaCard(),
              const SizedBox(height: 16),
              _buildSoporteYLegalSection(),
              const SizedBox(height: 16),
              _buildAccionesCriticasSection(),
              const SizedBox(height: 16),
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

  Widget _buildPerfilCard() {
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
          _buildAvatarSection(),
          const SizedBox(height: 20),
          _buildDatosPersonalesSection(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
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
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: inputPlaceholder,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isEditing = !_isEditing),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _isEditing ? deleteRed : aqua,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isEditing ? Icons.close : Icons.edit,
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
              'Dovia Operative Lister',
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

  // ─── Datos Personales ─────────────────────────────────────────────────────────

  Widget _buildDatosPersonalesSection() {
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
              Expanded(
                child: _buildInputField(
                  label: 'Nombres',
                  placeholder: 'Laura',
                  controller: _nombresController,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Apellidos',
                  placeholder: 'Martinez',
                  controller: _apellidosController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Nacionalidad',
                  placeholder: 'Colombiana',
                  controller: _nacionalidadController,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Sexo',
                  placeholder: 'Femenino',
                  controller: _sexoController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Edad',
                  placeholder: '28',
                  controller: _edadController,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Correo',
                  placeholder: 'lauramartinez@gmail.com',
                  controller: _correoController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildPhoneField()),
              const SizedBox(width: 14),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 14),
          _buildPerimetroField(),
          if (_isEditing) ...[const SizedBox(height: 20), _buildSaveButton()],
        ],
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
          _buildSolidButton(label: 'Actualizar contraseña', onTap: () {}),
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
                      onTap: widget.onTermsAndConditions,
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
                      onTap: widget.onSupport,
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
            onTap: widget.onLogout,
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

  Widget _buildInputField({
    required String label,
    required String placeholder,
    TextEditingController? controller,
  }) {
    final bool editable = _isEditing && controller != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            border: editable ? Border.all(color: aqua, width: 1) : null,
          ),
          child: editable
              ? TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: textPrimary,
                    letterSpacing: 0.32,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: inputPlaceholder,
                      letterSpacing: 0.32,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller?.text ?? placeholder,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: inputPlaceholder,
                        letterSpacing: 0.32,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    const Color phonePlaceholder = Color(0xFFBDBDBD);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Teléfono',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 56,
              height: 42,
              decoration: BoxDecoration(
                color: backgroundGray,
                borderRadius: BorderRadius.circular(10),
                border: _isEditing ? Border.all(color: aqua, width: 1) : null,
              ),
              child: _isEditing
                  ? TextField(
                      controller: _countryCodeController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        color: textPrimary,
                        letterSpacing: 0.32,
                      ),
                      decoration: const InputDecoration(
                        hintText: '+51',
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 16,
                          color: phonePlaceholder,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    )
                  : Center(
                      child: Text(
                        _countryCodeController.text,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 16,
                          color: phonePlaceholder,
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: backgroundGray,
                  borderRadius: BorderRadius.circular(10),
                  border: _isEditing ? Border.all(color: aqua, width: 1) : null,
                ),
                child: _isEditing
                    ? TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 16,
                          color: textPrimary,
                          letterSpacing: 0.32,
                        ),
                        decoration: const InputDecoration(
                          hintText: '123456789',
                          hintStyle: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 16,
                            color: phonePlaceholder,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _phoneController.text,
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 16,
                              color: phonePlaceholder,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerimetroField() {
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
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 155,
              decoration: BoxDecoration(
                color: backgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/0ba5c4f76c4d6354a3244e0d158279a9c7009893.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.map, size: 48, color: inputPlaceholder),
                  ),
                ),
              ),
            ),
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE57373).withValues(alpha: 0.5),
                border: Border.all(
                  color: const Color(0xFFE57373).withValues(alpha: 0.7),
                  width: 2,
                ),
              ),
            ),
          ],
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
      onTap: widget.onDeleteAccount,
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

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        final data = {
          'nombres': _nombresController.text,
          'apellidos': _apellidosController.text,
          'nacionalidad': _nacionalidadController.text,
          'sexo': _sexoController.text,
          'edad': _edadController.text,
          'correo': _correoController.text,
          'countryCode': _countryCodeController.text,
          'telefono': _phoneController.text,
        };
        widget.onSaveInfo?.call(data);
        setState(() => _isEditing = false);
      },
      child: Container(
        width: double.infinity,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aqua,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Text(
          'Guardar información',
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
