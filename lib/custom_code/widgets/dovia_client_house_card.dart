// Automatic FlutterFlow imports
import '/core/network_image_size.dart';
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

  /// En las propiedades del propio usuario no va el corazón.
  final bool showFavorite;

  /// Versión chica para grillas de dos columnas: foto más baja y las
  /// medidas acomodadas en varias líneas si no entran en una.
  final bool compact;

  /// Precio ya armado, que se muestra tal cual en vez de [price] (Ej: los
  /// proyectos nuevos van en USD y "Desde ...", y [price] siempre sale en Q).
  final String? priceLabel;

  /// Los datos que no vienen (o vienen en 0) se muestran como "—" en vez de
  /// "0". Para los proyectos nuevos, cuyo sitio manda 0 en lo que el
  /// desarrollo todavía no definió.
  final bool dashEmptySpecs;

  /// Zona que se muestra sobre la foto, debajo del nombre (Ej: "Zona 15,
  /// Guatemala"). Ver `propertyLocationLabel`.
  final String? location;

  /// Parqueos (`features.general.parkingSpots`).
  final int? parkingSpots;

  /// Rótulo chico sobre el precio (Ej: "Precio desde").
  final String? priceCaption;

  /// Tarjeta de la sección Proyectos Nuevos: arriba a la derecha va una
  /// flecha (abre la página del proyecto) en vez del corazón, el tipo va en
  /// plural y las habitaciones como "Desde N".
  final bool isNewProject;

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
    this.showFavorite = true,
    this.compact = false,
    this.onRemoveFromFavorites,
    this.bedrooms,
    this.bathrooms,
    this.constructionArea,
    this.hasDiscount,
    this.originalPrice,
    this.propertyType,
    this.priceLabel,
    this.dashEmptySpecs = false,
    this.location,
    this.parkingSpots,
    this.priceCaption,
    this.isNewProject = false,
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

  bool _heartBusy = false;

  Future<void> _handleHeartTap() async {
    // Un invitado no puede guardar nada: la acción sólo abre el modal de
    // registro, así que el corazón no debe encenderse.
    if (FFAppState().UserRole == 'VISITOR') {
      await widget.onAddToFavorites?.call();
      return;
    }
    // Un segundo toque mientras se guarda mandaba el alta dos veces.
    if (_heartBusy) return;
    _heartBusy = true;
    try {
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
    } finally {
      _heartBusy = false;
    }
    // El corazón se prende antes de guardar; si el alta falló (o en el modal
    // se quitó de todas las carpetas) quedaba mintiendo. Se confirma con el
    // backend.
    if (mounted && FFAppState().UserRole == 'CLIENT') {
      await _syncFavoriteStatusFromApi();
    }
  }

  /// Foto de la propiedad. Cuando el backend no manda ninguna, o la que
  /// manda no carga, la tarjeta cae en la imagen de casa que trae la app.
  Widget _photo() {
    Widget fallback() => Image.asset(
          'assets/images/casa_card_sobreMiVisita.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFFEFEFEF)),
        );

    final url = widget.imageUrl.trim();
    if (url.isEmpty) {
      return fallback();
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
        cacheWidth: networkImageCacheWidth(width: widget.width ?? 320),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  static const _ink = Color(0xFF00444B);
  static const _teal = Color(0xFF007376);
  static const _muted = Color(0xFF7A8A8C);

  /// Nombre en español del tipo (`APARTMENT` → "Apartamento"). Un proyecto
  /// nuevo agrupa varias unidades, así que va en plural, como en la web.
  String _typeChipLabel(String raw) {
    const labels = <String, List<String>>{
      'APARTMENT': ['Apartamento', 'Apartamentos'],
      'HOUSE': ['Casa', 'Casas'],
      'PENTHOUSE': ['Penthouse', 'Penthouses'],
      'STUDIO': ['Estudio', 'Estudios'],
      'LOT': ['Terreno', 'Terrenos'],
      'LAND': ['Terreno', 'Terrenos'],
      'FARM': ['Finca', 'Fincas'],
      'CONDO': ['Condominio', 'Condominios'],
      'CONDOMINIUM': ['Condominio', 'Condominios'],
      'OFFICE': ['Oficina', 'Oficinas'],
      'COMMERCIAL': ['Local', 'Locales'],
      'LOCAL': ['Local', 'Locales'],
      'STORE': ['Local', 'Locales'],
      'WAREHOUSE': ['Bodega', 'Bodegas'],
    };
    final key = raw.trim().toUpperCase();
    final pair = labels[key];
    if (pair != null) return pair[widget.isNewProject ? 1 : 0];
    return raw.trim().replaceAll('_', ' ');
  }

  Widget _chip(String text, Color background) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 8 : 10,
        vertical: widget.compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.publicSans(
          fontSize: widget.compact ? 8.5 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Botón redondo de arriba a la derecha: el corazón de favoritos o, en un
  /// proyecto nuevo, la flecha que indica que abre su página en el sitio.
  Widget _cornerButton() {
    final size = widget.compact ? 30.0 : 34.0;
    final icon = Icon(
      widget.isNewProject
          ? Icons.north_east
          : (_isFavorite ? Icons.favorite : Icons.favorite_border),
      color: _ink,
      // El corazón llena más el círculo: a 18 se perdía. La flecha queda como
      // estaba.
      size: widget.isNewProject
          ? (widget.compact ? 16 : 18)
          : (widget.compact ? 20 : 22),
    );
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        shape: BoxShape.circle,
      ),
      child: icon,
    );
    // La flecha es sólo una señal: el toque lo maneja la tarjeta entera.
    if (widget.isNewProject) return circle;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleHeartTap,
        child: circle,
      ),
    );
  }

  Widget _photoHeader() {
    final pad = widget.compact ? 10.0 : 14.0;
    final type = (widget.propertyType ?? '').trim();
    final listing = _getDisplayType(widget.type).trim();
    final location = (widget.location ?? '').trim();
    final chips = <Widget>[
      if (type.isNotEmpty && type != 'null')
        _chip(_typeChipLabel(type), const Color(0xFF3E5F6B).withOpacity(0.85)),
      if (listing.isNotEmpty) _chip(listing, _teal),
    ];
    final showCorner = widget.isNewProject || widget.showFavorite;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: _photo(),
          ),
          // Degradado para que el nombre se lea sobre cualquier foto.
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  Colors.black.withOpacity(0.10),
                  Colors.transparent,
                  _ink.withOpacity(0.88),
                ],
              ),
            ),
          ),
          Positioned(
            top: pad,
            left: pad,
            right: pad + (showCorner ? (widget.compact ? 34 : 40) : 0),
            child: Wrap(spacing: 6, runSpacing: 6, children: chips),
          ),
          if (showCorner)
            Positioned(top: pad, right: pad, child: _cornerButton()),
          Positioned(
            left: pad,
            right: pad,
            bottom: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (widget.name == null ||
                          widget.name!.trim().isEmpty ||
                          widget.name == 'null')
                      ? 'Propiedad sin nombre'
                      : widget.name!.trim().toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.publicSans(
                    fontSize: widget.compact ? 13 : 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    height: 1.15,
                    color: Colors.white,
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: widget.compact ? 12 : 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.publicSans(
                            fontSize: widget.compact ? 10.5 : 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBlock() {
    final caption = (widget.priceCaption ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (caption.isNotEmpty) ...[
          Text(
            caption.toUpperCase(),
            style: GoogleFonts.publicSans(
              fontSize: widget.compact ? 9 : 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: _muted,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Un precio largo ("Precio por confirmar") se achica en vez de
            // desbordar la tarjeta.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  widget.priceLabel ?? _formatPrice(widget.price),
                  maxLines: 1,
                  style: GoogleFonts.publicSans(
                    fontSize: widget.compact ? 16 : 21,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
            ),
            if (widget.hasDiscount == true && widget.originalPrice != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _formatPrice(widget.originalPrice),
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Un dato de la grilla: ícono en círculo, rótulo y valor.
  Widget _specTile(IconData icon, String label, String value) {
    final circle = widget.compact ? 24.0 : 32.0;
    return Row(
      children: [
        Container(
          width: circle,
          height: circle,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F4F4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _teal, size: widget.compact ? 13 : 16),
        ),
        SizedBox(width: widget.compact ? 5 : 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  style: GoogleFonts.publicSans(
                    fontSize: widget.compact ? 7.5 : 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: _muted,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: GoogleFonts.publicSans(
                    fontSize: widget.compact ? 11.5 : 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _specsGrid() {
    // En las tarjetas angostas (carruseles, grilla) "Habitaciones" no entra
    // sin achicarse de más.
    final short = widget.compact || (widget.width ?? 320) < 260;
    // Una sola área, como en la web: la construida y, si no hay, la del
    // terreno (los lotes sólo tienen esa).
    final built = widget.constructionArea;
    final area =
        (built != null && built > 0) ? built : widget.landArea?.toInt();
    final bedrooms = _spec(widget.bedrooms, '');
    final gap = SizedBox(height: widget.compact ? 8 : 12);
    Widget row(Widget a, Widget b) => Row(
          children: [
            Expanded(child: a),
            SizedBox(width: widget.compact ? 6 : 10),
            Expanded(child: b),
          ],
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(
          _specTile(Icons.open_in_full, 'Área', _spec(area, ' m²')),
          _specTile(
            Icons.bed_outlined,
            short ? 'Hab.' : 'Habitaciones',
            widget.isNewProject && bedrooms != '—'
                ? 'Desde $bedrooms'
                : bedrooms,
          ),
        ),
        gap,
        row(
          _specTile(
              Icons.bathtub_outlined, 'Baños', _spec(widget.bathrooms, '')),
          _specTile(
            Icons.directions_car_outlined,
            widget.compact ? 'Parq.' : 'Parqueos',
            _spec(widget.parkingSpots, ''),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = widget.compact ? 10.0 : 16.0;
    // La altura la dan la foto y los datos; un alto fijo cortaba la grilla.
    return Container(
      width: widget.width ?? 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _photoHeader(),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _priceBlock(),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: widget.compact ? 8 : 12),
                  child: const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE6EBEB),
                  ),
                ),
                _specsGrid(),
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

    return 'Q ${value.startsWith('-') ? '-' : ''}$grouped';
  }

  /// Un dato de la ficha con su unidad. "—" si no vino, o si vino en 0 y
  /// [DoviaClientHouseCard.dashEmptySpecs].
  String _spec(int? value, String unit) {
    if (value == null || (widget.dashEmptySpecs && value <= 0)) return '—';
    return '$value$unit';
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
