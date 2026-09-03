// Automatic FlutterFlow imports
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_fonts/google_fonts.dart';

class DoviaClientHouseCard extends StatefulWidget {
  final double? width;
  final double? height;
  final String imageUrl;
  final String? name;
  final dynamic type;
  final String? price;
  final double? landArea;
  final bool? isFavorite;
  final String? propertyId;
  final String? authToken;
  final int? bedrooms;
  final int? bathrooms;
  final int? constructionArea;
  final Future<void> Function()? onAddToFavorites;
  final Future<void> Function()? onRemoveFromFavorites;
  final bool? hasDiscount;
  final String? originalPrice;
  final String? propertyType;

  const DoviaClientHouseCard({
    super.key,
    this.width,
    this.height,
    this.name,
    this.type,
    this.price,
    this.landArea,
    this.imageUrl =
        'https://images.unsplash.com/photo-1600596542815-27b88e57e62f?q=80&w=800&auto=format&fit=crop',
    this.isFavorite = false,
    this.propertyId,
    this.authToken,
    this.onAddToFavorites,
    this.onRemoveFromFavorites,
    this.bedrooms,
    this.bathrooms,
    this.constructionArea,
    this.hasDiscount,
    this.originalPrice,
    this.propertyType,
  });

  @override
  State<DoviaClientHouseCard> createState() => _DoviaClientHouseCardState();
}

class _DoviaClientHouseCardState extends State<DoviaClientHouseCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite ?? false;
    // Only sync from API for CLIENT users — agents/HQ don't have favorites.
    // If isFavorite is already true, trust the parent to avoid overwriting.
    if (!_isFavorite && FFAppState().UserRole == 'CLIENT') {
      _syncFavoriteStatusFromApi();
    }
  }

  @override
  void didUpdateWidget(DoviaClientHouseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite ?? false;
      });
    }

    if (widget.propertyId != oldWidget.propertyId ||
        widget.authToken != oldWidget.authToken) {
      // Same logic: only sync from API if CLIENT and parent says not a favorite.
      if (!(widget.isFavorite ?? false) && FFAppState().UserRole == 'CLIENT') {
        _syncFavoriteStatusFromApi();
      }
    }
  }

  Future<void> _syncFavoriteStatusFromApi() async {
    final propertyId = widget.propertyId;
    final authToken = widget.authToken;
    if (propertyId == null ||
        propertyId.isEmpty ||
        authToken == null ||
        authToken.isEmpty) {
      return;
    }

    final response =
        await DOVIAAPIFavoriteContextGroup.checkIfPropertyIsFavoritedCall.call(
      propertyId: propertyId,
      authToken: authToken,
    );
    if (!mounted || !response.succeeded) {
      return;
    }

    final isFavoriteFromApi =
        getJsonField(response.jsonBody, r'''$.data.isFavorite''') == true ||
            getJsonField(response.jsonBody, r'''$.data.isFavorite''')
                    .toString()
                    .toLowerCase() ==
                'true' ||
            getJsonField(response.jsonBody, r'''$.data.isFavorite''')
                    .toString() ==
                '1' ||
            (DOVIAAPIFavoriteContextGroup.checkIfPropertyIsFavoritedCall
                    .foledersStoredIn(response.jsonBody)
                    ?.isNotEmpty ??
                false);

    if (_isFavorite != isFavoriteFromApi) {
      setState(() {
        _isFavorite = isFavoriteFromApi;
      });
    }
  }

  Future<void> _handleHeartTap() async {
    // Un invitado no puede guardar nada: la acción sólo abre el modal de
    // registro, así que el corazón no debe encenderse.
    if (FFAppState().UserRole == 'VISITOR') {
      await widget.onAddToFavorites?.call();
      return;
    }

    if (!_isFavorite) {
      setState(() {
        _isFavorite = true;
      });
      if (widget.onAddToFavorites != null) {
        await widget.onAddToFavorites!();
      }
    } else {
      // If already favorite, we trigger onRemoveFromFavorites to show the folder modal without adding again
      if (widget.onRemoveFromFavorites != null) {
        await widget.onRemoveFromFavorites!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (widget.imageUrl.startsWith('http') ||
        widget.imageUrl.startsWith('https')) {
      imageProvider = NetworkImage(widget.imageUrl);
    } else {
      imageProvider = AssetImage(widget.imageUrl);
    }

    return Container(
      width: widget.width ?? 320,
      height:
          (widget.height != null && widget.height! > 0) ? widget.height : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Typology Icon
                if (widget.propertyType != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (widget.propertyType!
                                    .toLowerCase()
                                    .contains('departamento') ||
                                widget.propertyType!
                                    .toLowerCase()
                                    .contains('edificio'))
                            ? Icons.apartment
                            : Icons.house,
                        color: const Color(0xFF00444B),
                        size: 20,
                      ),
                    ),
                  ),

                // Heart Button Logic
                Positioned(
                  top: 12,
                  right: 12, // Moved to right since typology icon is on left
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: _handleHeartTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isFavorite
                              ? const Color(0xFFFFEAEA).withOpacity(0.9)
                              : const Color(0xFFD0E6E8).withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? Colors.red
                              : const Color(0xFF00444B),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatPrice(widget.price),
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF007376),
                      ),
                    ),
                    if (widget.hasDiscount == true &&
                        widget.originalPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _formatPrice(widget.originalPrice),
                          style: GoogleFonts.raleway(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  (widget.name == null || widget.name!.isEmpty)
                      ? "Propiedad sin nombre"
                      : widget.name!,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF00444B),
                  ),
                ),
                Text(
                  _getDisplayType(widget.type),
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSpecItem("${widget.constructionArea ?? 0} M2"),
                    _buildSpecItem("${widget.landArea?.toInt() ?? 0} M2"),
                    _buildSpecItem("${widget.bedrooms ?? 0} Hab."),
                    _buildSpecItem("${widget.bathrooms ?? 0} Baños"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a raw price into the format used across the designs, e.g.
  /// `$ 1.000.000`. Returns the original string when it cannot be parsed.
  String _formatPrice(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return '';
    }

    var body = value.replaceAll(RegExp(r'[^0-9.,]'), '');
    final lastSeparator = body.lastIndexOf(RegExp(r'[.,]'));
    final decimals = lastSeparator == -1 ? 0 : body.length - lastSeparator - 1;
    // A trailing group of one or two digits is a decimal part, not a
    // thousands group, so drop it. Three digits means it is a group.
    if (lastSeparator != -1 && decimals > 0 && decimals <= 2) {
      body = body.substring(0, lastSeparator);
    }

    final digits = body.replaceAll(RegExp(r'[.,]'), '');
    if (digits.isEmpty) {
      return value;
    }

    final whole = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final grouped = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        grouped.write('.');
      }
      grouped.write(whole[i]);
    }

    return '\$ ${value.startsWith('-') ? '-' : ''}$grouped';
  }

  Widget _buildSpecItem(String text) {
    return Text(
      text,
      style: GoogleFonts.raleway(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF858585),
      ),
    );
  }

  String _getDisplayType(dynamic type) {
    if (type == null) return '';
    try {
      List<String> items = [];
      if (type is String) {
        if (type.startsWith('[') && type.endsWith(']')) {
          // It looks like a JSON-style string: ["SALE", "RENT"]
          items = type
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .replaceAll("'", '')
              .split(',')
              .map((e) => e.trim().toUpperCase())
              .toList();
        } else {
          // Simple string: "SALE" or "SALE, RENT"
          items = type.split(',').map((e) => e.trim().toUpperCase()).toList();
        }
      } else if (type is Iterable) {
        items = type.map((e) => e.toString().trim().toUpperCase()).toList();
      } else {
        items = [type.toString().trim().toUpperCase()];
      }

      final hasSale = items.contains('SALE');
      final hasRent = items.contains('RENT');

      if (hasSale && hasRent) return 'Venta y Renta';
      if (hasSale) return 'Venta';
      if (hasRent) return 'Renta';

      // Fallback for other types or untranslated strings
      return items.join(', ');
    } catch (_) {
      return type.toString();
    }
  }
}
