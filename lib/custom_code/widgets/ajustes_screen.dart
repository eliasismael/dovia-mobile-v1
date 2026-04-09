// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


class AjustesScreen extends StatefulWidget {
  final double? width;
  final double? height;
  final Future Function()? onCancelSubscription;
  final Future Function()? onDeleteAccount;

  const AjustesScreen({
    super.key,
    this.width,
    this.height,
    this.onCancelSubscription,
    this.onDeleteAccount,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _datosPersonalesExpanded = true;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureRepeatPassword = true;

  static const Color textPrimary = Color(0xFF00444B);
  static const Color aqua = Color(0xFF007376);
  static const Color aquaDark = Color(0xFF007376);
  static const Color backgroundGray = Color(0xFFFAFAFA);
  static const Color borderGray = Color(0xFF007376);
  static const Color textSecondary = Color(0xFF888888);
  static const Color errorRed = Color(0xFFF93A3A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: aqua,
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Avatar Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: aqua, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/55a15263074a443ef0adbc59c5a1d36b4353026c.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  child: const Icon(Icons.person,
                                      size: 40, color: textSecondary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Badge: Dovia Home Associate
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: aqua,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Dovia Home Associate',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  size: 10, color: aqua),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Edit icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: backgroundGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 16, color: textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Datos personales Section
                _buildExpandableSection(
                  title: 'Datos personales',
                  isExpanded: _datosPersonalesExpanded,
                  onTap: () => setState(() =>
                      _datosPersonalesExpanded = !_datosPersonalesExpanded),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildInputField(label: 'Nombres', value: 'Laura'),
                      const SizedBox(height: 16),
                      _buildInputField(label: 'Apellidos', value: 'Martínez'),
                      const SizedBox(height: 16),
                      _buildInputFieldWithIcon(
                        label: 'Nacionalidad',
                        value: 'Colombiana',
                        trailing: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderGray),
                          ),
                          child: const Center(
                            child: Text(
                              'D',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: aqua,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(label: 'Sexo', value: 'Femenino'),
                      const SizedBox(height: 16),
                      _buildInputField(label: 'Edad', value: '29'),
                      const SizedBox(height: 16),
                      _buildInputField(
                          label: 'Correo', value: 'lauramartínez@gmail.com'),
                      const SizedBox(height: 16),
                      _buildInputField(label: 'Teléfono', value: '3124567890'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tu perímetro Section
                const Text(
                  'Tu perímetro',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Map placeholder
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: backgroundGray,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/0ba5c4f76c4d6354a3244e0d158279a9c7009893.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: backgroundGray,
                        child: const Center(
                          child:
                              Icon(Icons.map, size: 48, color: textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Cambio de contraseña Section
                const Text(
                  'Cambio de contraseña',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  label: 'Contraseña actual',
                  value: '**********',
                  obscure: _obscureCurrentPassword,
                  onToggle: () => setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  label: 'Contraseña nueva',
                  value: '**********',
                  obscure: _obscureNewPassword,
                  onToggle: () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Debe tener 8 caracteres',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  label: 'Repetir contraseña nueva',
                  value: '**********',
                  obscure: _obscureRepeatPassword,
                  onToggle: () => setState(
                      () => _obscureRepeatPassword = !_obscureRepeatPassword),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Debe ser igual a la nueva contraseña',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Actualizar contraseña button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aqua,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Actualizar contraseña',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Container(height: 1, color: borderGray),
                const SizedBox(height: 32),

                // Suscripción y pagos Section
                const Text(
                  'Suscripción y pagos',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Subscription Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderGray),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with DOVIA BASIC
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: aqua,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'DOVIA BASIC',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Price
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '\$30',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '/mes',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Tu propiedad, siempre al día.',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Incluye section
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: aqua,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Incluye:',
                                    style: TextStyle(
                                      fontFamily: 'Public Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildIncludeItem(
                                      text: '2 servicios mensuales'),
                                  const SizedBox(height: 4),
                                  _buildIncludeItem(
                                      text:
                                          '10% de descuento en cualquier cotización adicional'),
                                  const SizedBox(height: 4),
                                  _buildIncludeItem(
                                      icon: Icons.support_agent,
                                      text:
                                          'Atención de emergencias en menos de 24 horas'),
                                  const SizedBox(height: 4),
                                  _buildIncludeItem(
                                      icon: Icons.check_circle,
                                      text:
                                          'Garantía DOVIA en todos los trabajos'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Cancelar suscripción button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () async {
                            await widget.onCancelSubscription?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: aqua),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Cancelar suscripción',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: aqua,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Divider line
                Container(height: 1, color: borderGray),
                const SizedBox(height: 32),

                // Soporte y legal Section
                const Text(
                  'Soporte y legal',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Ver términos y condiciones link
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Ver términos y condiciones',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: aqua,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Términos y condiciones button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: borderGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Términos y condiciones',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Ayuda o soporte
                const Text(
                  'Ayuda o soporte',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: borderGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Soporte',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Container(height: 1, color: borderGray),
                const SizedBox(height: 32),

                const Text(
                  'Acciones críticas',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deseo cerrar sesión',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: borderGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Deseo eliminar mi cuenta',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      await widget.onDeleteAccount?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Eliminar cuenta',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: textPrimary,
              ),
            ],
          ),
        ),
        if (isExpanded) child,
      ],
    );
  }

  Widget _buildInputField({required String label, required String value}) {
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundGray,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldWithIcon({
    required String label,
    required String value,
    required Widget trailing,
  }) {
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundGray,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String value,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundGray,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  obscure ? '**********' : value,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncludeItem({required String text, IconData? icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon ?? Icons.check,
          size: 16,
          color: aqua,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
