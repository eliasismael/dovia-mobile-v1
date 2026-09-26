import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_offers.dart';
import '/domain/offer_json.dart';

/// Etiqueta "En proceso de venta / renta" para una propiedad publicada.
///
/// El backend deja la propiedad en PUBLISHED durante todo el trámite legal y
/// recién la pasa a SOLD / RENTED al finalizarlo, así que la lista de
/// propiedades no dice que ya hay un trato en curso. Se deduce de sus ofertas:
/// una aceptada cuyo proceso no terminó ni se cayó.
class DealInProgressBadge extends StatefulWidget {
  const DealInProgressBadge({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<DealInProgressBadge> createState() => _DealInProgressBadgeState();
}

class _DealInProgressBadgeState extends State<DealInProgressBadge> {
  /// null: sin trato en curso (o todavía cargando).
  String? _label;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.propertyId.isEmpty) return;
    final res = await DOVIAAPIOfferContextGroup.listOffersByPropertyCall.call(
      propertyId: widget.propertyId,
      offerStatus: 'accepted',
      authToken: currentAuthenticationToken,
    );
    if (!mounted || !res.succeeded) return;
    final body = res.jsonBody;
    final raw = body is Map ? body['data'] : null;
    final items = raw is List
        ? raw
        : (raw is Map && raw['items'] is List ? raw['items'] as List : []);
    for (final item in items) {
      if (item is! Map) continue;
      final offer = Map<String, dynamic>.from(item);
      final status =
          (offerStr(offer['offerStatus']) ?? offerStr(offer['status']) ?? '')
              .toLowerCase();
      if (status != 'accepted') continue;
      final process = offerProcessStatus(offer);
      if (process == 'completed' || process == 'rejected') continue;
      final type = [
        offer['offerType'],
        offer['type'],
        offer['operationType'],
        offer['activeOfferData'] is Map
            ? offer['activeOfferData']['paymentMethod']
            : null,
      ].map((e) => e?.toString().toLowerCase() ?? '').join(' ');
      setState(() => _label = type.contains('rent')
          ? 'En proceso de renta'
          : 'En proceso de venta');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;
    if (label == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF007376),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.publicSans(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
