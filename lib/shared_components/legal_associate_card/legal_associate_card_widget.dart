import '/core/network_image_size.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_associate_card_model.dart';
export 'legal_associate_card_model.dart';

class LegalAssociateCardWidget extends StatefulWidget {
  const LegalAssociateCardWidget({
    super.key,
    this.name,
    this.photoUrl,
    this.phone,
    this.email,
  });

  final String? name;
  final String? photoUrl;
  final String? phone;
  final String? email;

  @override
  State<LegalAssociateCardWidget> createState() =>
      _LegalAssociateCardWidgetState();
}

class _LegalAssociateCardWidgetState extends State<LegalAssociateCardWidget> {
  late LegalAssociateCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalAssociateCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  static const Color _primary = Color(0xFF00444B);
  static const Color _aqua = Color(0xFF007376);

  String get _initials => (widget.name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  /// Foto real del asociado; sin foto, sus iniciales (no una foto genérica
  /// que parezca de otra persona).
  Widget _avatar() {
    final url = widget.photoUrl ?? '';
    final fallback = Container(
      color: _aqua,
      alignment: Alignment.center,
      child: Text(
        _initials.isEmpty ? '?' : _initials,
        style: GoogleFonts.publicSans(
          color: Colors.white,
          fontSize: 26.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Container(
      width: 92.0,
      height: 92.0,
      padding: const EdgeInsets.all(3.0),
      decoration: const BoxDecoration(
        color: Color(0x2670ACAD),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: url.isEmpty
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
                cacheWidth: networkImageCacheWidth(width: 92, height: 92),
              ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: const Color(0x2670ACAD),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, size: 16.0, color: _aqua),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: _primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone ?? '';
    final email = widget.email ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14.0,
            offset: Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _avatar(),
          const SizedBox(height: 14.0),
          Text(
            widget.name ?? 'Nombre y Apellido',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0x2670ACAD),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 15.0, color: _aqua),
                const SizedBox(width: 5.0),
                Text(
                  'Dovia Legal Associate',
                  style: GoogleFonts.publicSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _aqua,
                  ),
                ),
              ],
            ),
          ),
          if (phone.isNotEmpty || email.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            const Divider(height: 1.0, color: Color(0xFFEDEFEF)),
            const SizedBox(height: 4.0),
            if (phone.isNotEmpty) _contactRow(Icons.phone_outlined, phone),
            if (email.isNotEmpty) _contactRow(Icons.mail_outline, email),
          ],
        ],
      ),
    );
  }
}
