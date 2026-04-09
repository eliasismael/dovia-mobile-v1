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
  bool _datosPersonalesExpanded = true;
  bool _puntosExpanded = true;
  bool _isEditing = false;

  // TextEditingControllers for personal info fields
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
    super.dispose();
  }

  static const Color textPrimary = Color(0xFF00444B);
  static const Color aqua = Color(0xFF007376);
  static const Color backgroundGray = Color(0xFFFAFAFA);
  static const Color inputPlaceholder = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE9EFF2);
  static const Color badgeTextColor = Color(0xFFCCE3E4);
  static const Color starColor = Color(0xFFFFC107);
  static const Color deleteRed = Color(0xFFF93A3A);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 37),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // === Profile Header Section ===
            _buildProfileHeader(),
            const SizedBox(height: 34),

            // === Datos personales + fields ===
            _buildDatosPersonalesSection(),
            const SizedBox(height: 19),

            // === Puntos Section ===
            _buildPuntosSection(),
            const SizedBox(height: 19),

            // === Soporte y legal Section ===
            _buildSoporteYLegalSection(),
            const SizedBox(height: 19),

            // === Acciones críticas Section ===
            _buildAccionesCriticasSection(),
          ],
        ),
      ),
    );
  }

  // ─── Profile Header ──────────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar + Rating + Badge
        Column(
          children: [
            // Avatar
            ClipOval(
              child: Image.asset(
                'assets/images/55a15263074a443ef0adbc59c5a1d36b4353026c.png',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: backgroundGray,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: inputPlaceholder,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Star Rating
            const SizedBox(
              width: 76,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: starColor, size: 23.5),
                  SizedBox(width: 8),
                  Text(
                    '4.9',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: textPrimary,
                      height: 24 / 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Badge: Dovia Operative Lister
            Container(
              width: 170,
              height: 34,
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
        const SizedBox(width: 6),

        // Edit icon — toggles edit mode
        GestureDetector(
          onTap: () => setState(() => _isEditing = !_isEditing),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              size: 20,
              color: _isEditing ? deleteRed : textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Datos Personales Section ─────────────────────────────────────────────────

  Widget _buildDatosPersonalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown header
        _buildDropdownHeader(
          title: 'Datos personales',
          isExpanded: _datosPersonalesExpanded,
          onTap: () => setState(
            () => _datosPersonalesExpanded = !_datosPersonalesExpanded,
          ),
        ),
        const SizedBox(height: 11),

        if (_datosPersonalesExpanded) ...[
          // Input fields
          _buildInputField(
            label: 'Nombres',
            placeholder: 'Laura',
            controller: _nombresController,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Apellidos',
            placeholder: 'Martinez',
            controller: _apellidosController,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Nacionalidad',
            placeholder: 'Colombiana',
            controller: _nacionalidadController,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Sexo',
            placeholder: 'Femenino',
            controller: _sexoController,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Edad',
            placeholder: '28',
            controller: _edadController,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Correo',
            placeholder: 'lauramartinez@gmail.com',
            controller: _correoController,
          ),
          const SizedBox(height: 14),

          // Teléfono field
          _buildPhoneField(),
          const SizedBox(height: 14),

          // Tu perímetro
          _buildPerimetroField(),

          // Save button (only visible in edit mode)
          if (_isEditing) ...[const SizedBox(height: 20), _buildSaveButton()],
        ],
      ],
    );
  }

  // ─── Puntos Section ───────────────────────────────────────────────────────────

  Widget _buildPuntosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownHeader(
          title: 'Puntos',
          isExpanded: _puntosExpanded,
          onTap: () => setState(() => _puntosExpanded = !_puntosExpanded),
        ),
        if (_puntosExpanded) ...[
          const SizedBox(height: 8),
          _buildInputField(label: 'Ya ganaste', placeholder: 'x'),
          const SizedBox(height: 14),
          _buildInputField(label: 'Puedes ganar', placeholder: 'x'),
          const SizedBox(height: 14),
          _buildInputField(label: 'Categoría', placeholder: 'x'),
          const SizedBox(height: 14),
          _buildInputField(label: 'Puntos', placeholder: 'x'),
          const SizedBox(height: 14),
          _buildInputField(
            label: 'Premio por llegar a siguiente categoría',
            placeholder: 'x',
          ),
        ],
      ],
    );
  }

  // ─── Soporte y legal Section ──────────────────────────────────────────────────

  Widget _buildSoporteYLegalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Soporte y legal',
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

          // Términos y condiciones
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
          const SizedBox(height: 20),

          // Ayuda o soporte
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
          _buildOutlinedButton(label: 'Soporte', onTap: widget.onSupport),
        ],
      ),
    );
  }

  // ─── Acciones críticas Section ────────────────────────────────────────────────

  Widget _buildAccionesCriticasSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Acciones críticas',
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

          // Cerrar sesión
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
          _buildOutlinedButton(label: 'Cerrar sesión', onTap: widget.onLogout),
          const SizedBox(height: 20),

          // Eliminar cuenta
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
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: textPrimary,
                  height: 24 / 14,
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
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.28,
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
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: textPrimary,
                    letterSpacing: 0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: inputPlaceholder,
                      letterSpacing: 0.28,
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
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: inputPlaceholder,
                        letterSpacing: 0.28,
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
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Country code
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
                        fontSize: 14,
                        color: textPrimary,
                        letterSpacing: 0.28,
                      ),
                      decoration: const InputDecoration(
                        hintText: '+51',
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
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
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: phonePlaceholder,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            // Phone number
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
                          fontSize: 14,
                          color: textPrimary,
                          letterSpacing: 0.28,
                        ),
                        decoration: const InputDecoration(
                          hintText: '123456789',
                          hintStyle: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
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
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: phonePlaceholder,
                              letterSpacing: 0.28,
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
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            // Map image
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
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: backgroundGray,
                    child: const Center(
                      child: Icon(Icons.map, size: 48, color: inputPlaceholder),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE57373).withOpacity(0.5),
                border: Border.all(
                  color: const Color(0xFFE57373).withOpacity(0.7),
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
            height: 14 / 16,
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
            height: 14 / 16,
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
        widget.onSaveInfo;
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
            height: 14 / 16,
          ),
        ),
      ),
    );
  }
}
