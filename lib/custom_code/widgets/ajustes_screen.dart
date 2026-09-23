// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '/repositories/user_repository.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import '/core/result.dart';

class AjustesScreen extends StatefulWidget {
  final double? width;
  final double? height;
  final Future Function()? onCancelSubscription;
  final Future Function(String? reason)? onDeleteAccount;
  final Future Function()? onSignOut;

  const AjustesScreen({
    super.key,
    this.width,
    this.height,
    this.onCancelSubscription,
    this.onDeleteAccount,
    this.onSignOut,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _datosExpanded = true;

  // Password controllers
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _repeatPasswordCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureRepeat = true;
  bool _subscriptionActive = true;

  final _cancelReasonCtrl = TextEditingController();
  final _deleteReasonCtrl = TextEditingController();

  Uint8List? _tempAvatarBytes;
  int _avatarVersion = DateTime.now().millisecondsSinceEpoch;

  static const Color _aqua = Color(0xFF007376);
  static const Color _textPrimary = Color(0xFF00444B);
  static const Color _textSecondary = Color(0xFF888888);
  static const Color _bgGray = Color(0xFFF5F5F5);
  static const Color _softRed = Color(0xFFE57373);

  @override
  void initState() {
    super.initState();
    // Load fresh profile on first render (cached if already loaded).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserRepository>().loadProfile();
    });
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    _cancelReasonCtrl.dispose();
    _deleteReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UserRepository>();
    final profile = repo.profile;

    final firstName = profile?.firstName ?? '—';
    final lastName = profile?.lastName ?? '—';
    final email = profile?.email ?? '—';
    final gender = profile?.gender ?? '—';
    final nationality = profile?.nationality ?? '—';
    final phone = profile != null && profile.phoneNumber != null
        ? '${profile.phoneCountryCode ?? ''} ${profile.phoneNumber}'.trim()
        : '—';
    final ageStr = profile?.age != null ? '${profile!.age} años' : '—';
    final avatarUrl = profile?.profilePictureUrl != null
        ? '${profile!.profilePictureUrl!}?v=$_avatarVersion'
        : null;

    // Renewal date: today + 30 days as mock
    final renewalDate = DateTime.now().add(const Duration(days: 30));
    final renewalStr =
        '${renewalDate.day.toString().padLeft(2, '0')}/${renewalDate.month.toString().padLeft(2, '0')}/${renewalDate.year}';

    if (repo.isLoading && profile == null) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF007376)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ── PERFIL HEADER ──────────────────────────────────────
          const Text('Perfil',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _aqua)),
          const SizedBox(height: 24),

          // Avatar with pencil
          Center(
            child: Column(children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _aqua, width: 2),
                        color: _bgGray,
                      ),
                      child: ClipOval(
                        child: _tempAvatarBytes != null
                            ? Image.memory(_tempAvatarBytes!, fit: BoxFit.cover)
                            : (avatarUrl != null
                                ? Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: _textSecondary),
                                  )
                                : Container(
                                    width: 84,
                                    height: 84,
                                    color: _bgGray,
                                    child: const Icon(Icons.person,
                                        size: 40, color: _textSecondary),
                                  )),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _aqua,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _aqua,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    (firstName != '—' && firstName.isNotEmpty)
                        ? '$firstName $lastName'
                        : 'Mi Perfil',
                    style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 10, color: _aqua),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // ── DATOS PERSONALES (expandible, solo lectura) ─────────
          _buildSectionHeader(
            title: 'Datos personales',
            isExpanded: _datosExpanded,
            onTap: () => setState(() => _datosExpanded = !_datosExpanded),
          ),
          if (_datosExpanded) ...[
            const SizedBox(height: 14),
            _readonlyField('Nombre', firstName),
            const SizedBox(height: 12),
            _readonlyField('Apellido', lastName),
            const SizedBox(height: 12),
            _readonlyField('Nacionalidad', nationality),
            const SizedBox(height: 12),
            _readonlyField('Sexo', gender),
            const SizedBox(height: 12),
            _readonlyField('Edad', ageStr),
            const SizedBox(height: 12),
            _readonlyField('Correo', email),
            const SizedBox(height: 12),
            _readonlyField('Teléfono', phone.isEmpty ? '—' : phone),
          ],
          const SizedBox(height: 28),

          // ── TU PERÍMETRO ──────────────────────────────────────
          const Text('Tu perímetro',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: (profile?.latitude != null && profile?.longitude != null)
                  ? DrawMapComponentWidget(
                      height: 220,
                      initialLatitude: profile!.latitude!,
                      initialLongitude: profile.longitude!,
                      singlePointMode: true,
                      interactive: false,
                    )
                  : Container(
                      color: _bgGray,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_off_outlined,
                                size: 40, color: Color(0xFF888888)),
                            SizedBox(height: 8),
                            Text(
                              'Ubicación no disponible',
                              style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 13,
                                  color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),
          _divider(),
          const SizedBox(height: 28),

          // ── CAMBIO DE CONTRASEÑA ────────────────────────────────
          const Text('Cambio de contraseña',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
          const SizedBox(height: 16),
          _passwordField(
              'Contraseña actual',
              _currentPasswordCtrl,
              _obscureCurrent,
              () => setState(() => _obscureCurrent = !_obscureCurrent)),
          const SizedBox(height: 12),
          _passwordField('Contraseña nueva', _newPasswordCtrl, _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew)),
          const SizedBox(height: 4),
          const Text('Debe tener 8 caracteres',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: _textSecondary)),
          const SizedBox(height: 12),
          _passwordField(
              'Repetir contraseña nueva',
              _repeatPasswordCtrl,
              _obscureRepeat,
              () => setState(() => _obscureRepeat = !_obscureRepeat)),
          const SizedBox(height: 4),
          const Text('Debe ser igual a la nueva contraseña',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: _textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _handleUpdatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _aqua,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('Actualizar contraseña',
                  style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 36),
          _divider(),
          const SizedBox(height: 28),

          // ── SUSCRIPCIÓN Y PAGOS ─────────────────────────────────
          const Text('Suscripción y pagos',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
          const SizedBox(height: 20),
          _buildSubscriptionCard(renewalStr),
          const SizedBox(height: 36),
          _divider(),
          const SizedBox(height: 28),

          // ── SOPORTE Y LEGAL ─────────────────────────────────────
          const Text('Soporte y legal',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
          const SizedBox(height: 16),
          _outlineBtn('Términos y condiciones', _openTermsModal),
          const SizedBox(height: 12),
          _outlineBtn('Soporte', _openSupportChat),
          const SizedBox(height: 36),
          _divider(),
          const SizedBox(height: 28),

          // ── ACCIONES CRÍTICAS ───────────────────────────────────
          const Text('Acciones críticas',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
          const SizedBox(height: 16),
          const Text('Deseo cerrar sesión',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: _textSecondary)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () async => await widget.onSignOut?.call(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _aqua),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Cerrar sesión',
                  style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Deseo eliminar mi cuenta',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: _textSecondary)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _showDeleteAccountFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _softRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── SUBSCRIPTION CARD ─────────────────────────────────────────────
  Widget _buildSubscriptionCard(String renewalDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _aqua.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: _subscriptionActive ? _aqua : _textSecondary,
                borderRadius: BorderRadius.circular(6)),
            child: Text(
              _subscriptionActive ? 'DOVIA BASIC' : 'PLAN FREE',
              style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        if (_subscriptionActive) ...[
          RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: 'Q30',
                  style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary)),
              TextSpan(
                  text: '/mes',
                  style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: _textSecondary)),
            ]),
          ),
          const SizedBox(height: 4),
          Text(
            'Se renueva el $renewalDate',
            style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 4),
          const Text('Tu propiedad, siempre al día.',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: _textSecondary)),
          const SizedBox(height: 18),
          // Benefits
          _buildBenefit('2 servicios mensuales'),
          const SizedBox(height: 4),
          _buildBenefit('10% de descuento en cotizaciones adicionales'),
          const SizedBox(height: 4),
          _buildBenefit('Atención de emergencias en menos de 24h'),
          const SizedBox(height: 4),
          _buildBenefit('Garantía DOVIA en todos los trabajos'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _showCancelSubscriptionFlow,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _softRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Cancelar suscripción',
                  style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _softRed)),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          const Text('No tienes ningún plan activo.',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: _textSecondary)),
        ]
      ]),
    );
  }

  Widget _buildBenefit(String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.check_circle_outline, size: 15, color: _aqua),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: _textPrimary))),
    ]);
  }

  // ── TERMS MODAL ───────────────────────────────────────────────────
  void _openTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TermsModal(),
    );
  }

  // ── SUPPORT CHAT ──────────────────────────────────────────────────
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

  // ── IMAGE PICKER ──────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final ffFile = FFUploadedFile(
        name: image.name,
        bytes: bytes,
      );

      setState(() {
        _tempAvatarBytes = bytes;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Subiendo imagen de perfil...'),
            duration: Duration(seconds: 2)));
      }

      final result = await context.read<UserRepository>().uploadAvatar(ffFile);

      if (mounted) {
        setState(() {
          _tempAvatarBytes = null;
        });
        switch (result) {
          case Success():
            setState(() {
              _avatarVersion = DateTime.now().millisecondsSinceEpoch;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Imagen actualizada correctamente'),
                backgroundColor: _aqua));
          case Failure(:final message):
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: $message'), backgroundColor: _softRed));
        }
      }
    }
  }

  // ── PASSWORD HANDLER ──────────────────────────────────────────────
  void _handleUpdatePassword() {
    // Redirect to recover-password flow as per business rules
    context.pushNamed('RecoverPassword_1');
  }

  // ── SUBSCRIPTION CANCELLATION FLOW ────────────────────────────────
  void _showCancelSubscriptionFlow() {
    _showConfirmBottomSheet(
      title: '¿Estás seguro que deseas cancelar tu suscripción?',
      subtitle: 'Perderás acceso a los beneficios exclusivos de DOVIA BASIC.',
      confirmLabel: 'Continuar',
      isDestructive: true,
      onConfirm: () {
        // Step 2: Reason
        _showReasonBottomSheet(
          title: '¿Por qué deseas cancelar?',
          controller: _cancelReasonCtrl,
          onConfirm: () async {
            await widget.onCancelSubscription?.call();
            setState(() => _subscriptionActive = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Suscripción cancelada correctamente.')));
            }
          },
        );
      },
    );
  }

  // ── DELETE ACCOUNT FLOW ───────────────────────────────────────────
  void _showDeleteAccountFlow() {
    _showConfirmBottomSheet(
      title: '¿Estás seguro de que quieres eliminar tu cuenta?',
      subtitle: 'Esta acción es permanente y perderás todos tus datos.',
      confirmLabel: 'Eliminar permanentemente',
      isDestructive: true,
      onConfirm: () {
        // Step 2: Reason
        _showReasonBottomSheet(
          title: '¿Por qué abandonas DOVIA?',
          controller: _deleteReasonCtrl,
          onConfirm: () async {
            final reason = _deleteReasonCtrl.text.trim();
            await widget.onDeleteAccount?.call(reason.isEmpty ? null : reason);
          },
        );
      },
    );
  }

  // ── REASON BOTTOM SHEET ──────────────────────────────────────────
  void _showReasonBottomSheet({
    required String title,
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu motivo aquí...',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: _textSecondary),
                  filled: true,
                  fillColor: _bgGray,
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
                    backgroundColor: _aqua,
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

  // ── CONFIRMATION MODAL HELPER ────────────────────────────────────
  void _showConfirmBottomSheet({
    required String title,
    required String subtitle,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: _textSecondary,
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
                          side: const BorderSide(color: _aqua),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary)),
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
                          backgroundColor: isDestructive ? _softRed : _aqua,
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

  // ── HELPERS ───────────────────────────────────────────────────────
  Widget _divider() => Container(height: 1, color: _aqua.withOpacity(0.3));

  Widget _buildSectionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        // El título se queda con el ancho que sobra después de la flecha: a su
        // medida natural desbordaba la fila en los teléfonos angostos.
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
        ),
        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: _textPrimary),
      ]),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontFamily: 'Public Sans', fontSize: 13, color: _textPrimary)),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _bgGray,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(
              fontFamily: 'Public Sans', fontSize: 14, color: _textSecondary),
        ),
      ),
    ]);
  }

  Widget _passwordField(
    String label,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontFamily: 'Public Sans', fontSize: 13, color: _textPrimary)),
      const SizedBox(height: 6),
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _bgGray,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              obscureText: obscure,
              decoration: const InputDecoration(
                  border: InputBorder.none, isDense: true),
              style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: _textSecondary),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: _textSecondary),
          ),
        ]),
      ),
    ]);
  }

  Widget _outlineBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _aqua),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textPrimary)),
      ),
    );
  }
}

// ── TERMS MODAL ────────────────────────────────────────────────────────
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
                disabledBackgroundColor: _aqua.withOpacity(0.3),
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

4. SUSCRIPCIONES Y PAGOS
Los planes de suscripción son renovados automáticamente en la fecha indicada. El usuario puede cancelar su suscripción en cualquier momento desde la sección de Ajustes. No se realizarán reembolsos por períodos parciales, salvo que la ley aplicable lo exija.

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
Estos Términos se rigen por las leyes de la República de Colombia. Cualquier disputa será resuelta ante los tribunales competentes de la ciudad de Bogotá D.C.

Al usar la Plataforma confirmas haber leído, entendido y aceptado la totalidad de estos Términos y Condiciones.
''';
}
