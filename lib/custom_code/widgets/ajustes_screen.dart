// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import '/core/network_image_size.dart';
import '/shared_components/delete_account_confirm_dialog.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '/repositories/user_repository.dart';
import '/repositories/payments_repository.dart';
import '/domain/payment_models.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart' show pickSafely;
import '/shared_components/draw_map_component/draw_map_component_widget.dart';
import '/shared_components/dovia_support/dovia_support_widget.dart';
import '/core/result.dart';
import '/shared_components/dovia_spinner.dart';

class AjustesScreen extends StatefulWidget {
  final double? width;
  final double? height;
  final Future Function()? onCancelSubscription;

  /// Devuelve si el backend dio de baja la cuenta. Solo entonces se cierra la
  /// sesión con [onSignOut].
  final Future<bool> Function(String? reason)? onDeleteAccount;
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

  bool _cancellingSubscription = false;
  bool _deletingAccount = false;

  /// Cerrar sesión avisa al backend antes de volver al login y tarda: el
  /// botón muestra el spinner y no acepta otro toque mientras tanto.
  bool _signingOut = false;

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
      // Suscripción real de Dovia Home y catálogo (para el nombre del plan).
      final payments = context.read<PaymentsRepository>();
      payments.loadCurrentSubscription(forceRefresh: true);
      payments.loadPlans();
    });
  }

  @override
  void dispose() {
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

    if (repo.isLoading && profile == null) {
      return const Center(child: DoviaSpinner());
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
                                    cacheWidth: networkImageCacheWidth(
                                        width: 84, height: 84),
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
          const Text(
              'Te enviaremos un código a tu correo para que crees una '
              'contraseña nueva.',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: _textSecondary)),
          const SizedBox(height: 12),
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
          _buildSubscriptionCard(),
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

          // ── CERRAR SESIÓN ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () async {
                if (_signingOut) return;
                setState(() => _signingOut = true);
                try {
                  await widget.onSignOut?.call();
                } finally {
                  if (mounted) setState(() => _signingOut = false);
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: _aqua),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: _signingOut
                  ? const DoviaSpinner(small: true, color: _aqua)
                  : const Text('Cerrar sesión',
                      style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary)),
            ),
          ),
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
          const Text('Deseo eliminar mi cuenta',
              style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: _textSecondary)),
          const SizedBox(height: 12),
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
          // Sin espacio extra: la pantalla ya deja lugar para la navbar.
        ],
      ),
    );
  }

  // ── SUBSCRIPTION CARD ─────────────────────────────────────────────
  String _formatDate(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Widget _buildSubscriptionCard() {
    final payments = context.watch<PaymentsRepository>();
    final sub = payments.currentSubscription;
    final loading = !payments.subscriptionLoaded;
    final hasSub = sub != null && sub.keepsBenefits;

    SubscriptionPlan? plan;
    if (sub != null) {
      for (final p in payments.plans) {
        if (p.id == sub.planId) plan = p;
      }
    }
    final planName = (plan?.name ?? 'DOVIA HOME').toUpperCase();
    final amount = sub?.amount ?? plan?.amount;
    final currency = sub?.currency ?? plan?.currency;
    final amountStr = amount == null
        ? null
        : '${currency == PaymentCurrency.usd ? 'USD ' : 'Q'}'
            '${amount % 1 == 0 ? amount.toInt() : amount}';

    Widget content;
    if (loading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: DoviaSpinner()),
      );
    } else if (!hasSub) {
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _planBadge('SIN SUSCRIPCIÓN', _textSecondary),
        const SizedBox(height: 12),
        const Text(
            'Suscribite a Dovia Home y tené servicios de mantenimiento, '
            'descuentos y atención de emergencias para tu propiedad.',
            style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                color: _textSecondary)),
        const SizedBox(height: 16),
        ..._benefits(),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => context.pushNamed('DH_CLIENT_PlanesPage'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _aqua,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Suscribirme',
                style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
      ]);
    } else {
      final cancelScheduled = sub.isCancelScheduled;
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _planBadge(planName, _aqua),
        const SizedBox(height: 10),
        if (amountStr != null)
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: amountStr,
                  style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary)),
              TextSpan(
                  text: plan?.periodLabel ?? ' /mes',
                  style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: _textSecondary)),
            ]),
          ),
        const SizedBox(height: 4),
        Text(
          cancelScheduled
              ? 'Cancelada. Tenés los beneficios hasta el '
                  '${_formatDate(sub.currentPeriodEnd)}'
              : sub.isPastDue
                  ? 'Pago pendiente. Revisá tu método de pago.'
                  : 'Se renueva el ${_formatDate(sub.currentPeriodEnd)}',
          style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 12,
              color: sub.isPastDue ? _softRed : _textSecondary),
        ),
        ..._benefitsSection(),
        if (!cancelScheduled) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed:
                  _cancellingSubscription ? null : _showCancelSubscriptionFlow,
              style: OutlinedButton.styleFrom(
                backgroundColor: _softRed,
                side: const BorderSide(color: _softRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: _cancellingSubscription
                  ? const DoviaSpinner(small: true, color: Colors.white)
                  : const Text('Cancelar suscripción',
                      style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
            ),
          ),
        ],
      ]);
    }

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
      child: content,
    );
  }

  static const _benefitTexts = [
    '2 servicios mensuales',
    '10% de descuento en cotizaciones adicionales',
    'Atención de emergencias en menos de 24h',
    'Garantía DOVIA en todos los trabajos',
  ];

  List<Widget> _benefits() => [
        for (final b in _benefitTexts) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle_outline, size: 15, color: _aqua),
            const SizedBox(width: 8),
            Expanded(
                child: Text(b,
                    style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: _textPrimary))),
          ]),
          const SizedBox(height: 4),
        ],
      ];

  List<Widget> _benefitsSection() => [
        const SizedBox(height: 16),
        ..._benefits(),
      ];

  Widget _planBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1),
      ),
    );
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
    showDoviaSupport(context);
  }

  // ── IMAGE PICKER ──────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Es un avatar: alcanza con 1024 px, como en el perfil del operative
    // lister, y a tamaño completo la foto podía pasar el límite de subida.
    final XFile? image = await pickSafely(
      () => picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      ),
      context: context,
    );
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

      if (!mounted) return;
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
  /// El cambio de contraseña va por el flujo verificado de recuperación:
  /// se abre con el correo del usuario ya cargado para mandarle el código.
  /// Cambiarla directo desde acá pide el access token de Cognito, que la app
  /// no guarda.
  void _handleUpdatePassword() {
    final email = context.read<UserRepository>().profile?.email ?? '';
    context.pushNamed(
      'RecoverPassword_1',
      queryParameters: {if (email.isNotEmpty) 'email': email},
    );
  }

  // ── SUBSCRIPTION CANCELLATION FLOW ────────────────────────────────
  void _showCancelSubscriptionFlow() {
    _showConfirmBottomSheet(
      title: '¿Estás seguro de que deseas cancelar tu suscripción?',
      subtitle: 'Conservás los beneficios hasta el fin del período ya pagado.',
      confirmLabel: 'Continuar',
      isDestructive: true,
      onConfirm: () {
        // Step 2: Reason
        _showReasonBottomSheet(
          title: '¿Por qué deseas cancelar?',
          controller: _cancelReasonCtrl,
          onConfirm: () async {
            setState(() => _cancellingSubscription = true);
            final result = await context
                .read<PaymentsRepository>()
                .cancelCurrentSubscription();
            if (!mounted) return;
            setState(() => _cancellingSubscription = false);
            switch (result) {
              case Success():
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Suscripción cancelada correctamente.'),
                    backgroundColor: _aqua));
              case Failure(:final message):
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(message), backgroundColor: _softRed));
            }
          },
        );
      },
    );
  }

  // ── DELETE ACCOUNT FLOW ───────────────────────────────────────────
  void _showDeleteAccountFlow() {
    // El mismo diálogo que los ajustes de los demás roles.
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteAccountConfirmDialog(
        onConfirm: () {
          Navigator.pop(dialogContext);
          // Paso 2: el motivo, también en el diálogo de los demás roles.
          showDialog(
            context: context,
            builder: (reasonContext) => DeleteAccountReasonDialog(
              controller: _deleteReasonCtrl,
              onConfirm: () async {
                Navigator.pop(reasonContext);
                if (_deletingAccount) return;
                setState(() => _deletingAccount = true);
                final reason = _deleteReasonCtrl.text.trim();
                final deleted = await widget.onDeleteAccount
                        ?.call(reason.isEmpty ? null : reason) ??
                    false;
                if (!mounted) return;
                setState(() => _deletingAccount = false);
                // Antes se cerraba la sesión aunque el backend hubiera fallado, y
                // el usuario creía haber borrado una cuenta que seguía activa.
                if (!deleted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'No pudimos eliminar tu cuenta. Inténtalo de nuevo.'),
                      backgroundColor: _softRed));
                  return;
                }
                await widget.onSignOut?.call();
              },
            ),
          );
        },
      ),
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
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, 32 + MediaQuery.viewPaddingOf(context).bottom),
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
          padding: EdgeInsets.fromLTRB(
              24, 12, 24, 32 + MediaQuery.viewPaddingOf(context).bottom),
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
                          backgroundColor: Colors.white,
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

  Widget _outlineBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
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
