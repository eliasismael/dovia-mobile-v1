import '/flutter_flow/flutter_flow_theme.dart';
import '/shared_components/horizontal_fade_edges.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Piezas de las pantallas de Lister HQ con el mismo estilo que las del
/// cliente: títulos de sección, tarjetas, estados, botones y carruseles.
class ListingHqUi {
  ListingHqUi._();

  static const Color aqua = Color(0xFF007376);
  static const Color textDark = Color(0xFF00444B);

  /// Colores de los estados. El texto va en blanco encima, como en Mis
  /// visitas del cliente.
  static const Color pending = Color(0xFFF57E00);
  static const Color urgent = Color(0xFFF52100);
  static const Color alert = Color(0xFFBC0000);

  /// Margen de la página a los costados.
  static const double gutter = 20.0;

  /// Título de sección, igual que los de los carruseles del cliente.
  static TextStyle sectionTitle(BuildContext context) =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
            fontSize: 17.0,
            letterSpacing: 0.33,
            fontWeight: FontWeight.w600,
            lineHeight: 1.3,
          );

  /// "Ver todo" y similares: texto verde sin fondo.
  static TextStyle link(BuildContext context) => GoogleFonts.publicSans(
        color: FlutterFlowTheme.of(context).primary,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      );

  /// Aviso de sección vacía, en gris.
  static Widget emptyText(BuildContext context, String text) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
      );

  /// Fondo de las tarjetas: blanco, bien redondeado y con sombra suave.
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      );

  /// Estado a todo el ancho: texto blanco sobre el color del estado.
  static Widget statusPill(String text, Color color) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(99.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.publicSans(
            color: Colors.white,
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  /// Etiqueta suave (qué hay que hacer con la propiedad).
  static Widget tag(BuildContext context, String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).accent1,
          borderRadius: BorderRadius.circular(99.0),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.publicSans(
            color: FlutterFlowTheme.of(context).primary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  /// Botón principal de las tarjetas, como "Ver tu oferta" del cliente.
  static Widget cardButton(String text, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99.0),
        child: Container(
          width: double.infinity,
          height: 30.0,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: aqua,
            borderRadius: BorderRadius.circular(99.0),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
}

/// Encabezado de sección: título a la izquierda y un link a la derecha.
class ListingHqSectionHeader extends StatelessWidget {
  const ListingHqSectionHeader({
    super.key,
    required this.title,
    this.linkText,
    this.onLinkTap,
  });

  final String title;
  final String? linkText;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 32.0, bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: ListingHqUi.sectionTitle(context)),
          ),
          if (linkText != null) ...[
            const SizedBox(width: 12.0),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: onLinkTap,
              child: Text(linkText!, style: ListingHqUi.link(context)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de propiedad de los carruseles.
class ListingHqPropertyCard extends StatelessWidget {
  const ListingHqPropertyCard({
    super.key,
    required this.address,
    required this.tagText,
    required this.statusText,
    required this.statusColor,
    required this.buttonText,
    this.onPressed,
    this.trailing,
  });

  final String address;
  final String tagText;
  final String statusText;
  final Color statusColor;
  final String buttonText;
  final VoidCallback? onPressed;

  /// Acción extra al lado del botón (p. ej. el menú de Propiedades).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.0,
      padding: const EdgeInsets.all(12.0),
      decoration: ListingHqUi.cardDecoration(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.isNotEmpty ? address : 'Sin dirección registrada',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.publicSans(
              color: ListingHqUi.textDark,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          ListingHqUi.tag(context, tagText),
          ListingHqUi.statusPill(statusText, statusColor),
          Row(
            children: [
              Expanded(
                child: ListingHqUi.cardButton(buttonText, onPressed),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8.0),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Carrusel horizontal como los del inicio del cliente: va de borde a borde
/// de la pantalla (sale del margen de la página), se desvanece del lado
/// opuesto al que se scrollea y tiene flechas a los costados.
///
/// Se usa dentro de una columna con [ListingHqUi.gutter] de margen a cada
/// lado: el carrusel ocupa ese margen y la primera tarjeta queda alineada
/// con el resto de la página.
class ListingHqCarousel extends StatefulWidget {
  const ListingHqCarousel({
    super.key,
    required this.children,
    this.height = 180.0,
    this.spacing = 15.0,
  });

  final List<Widget> children;
  final double height;
  final double spacing;

  @override
  State<ListingHqCarousel> createState() => _ListingHqCarouselState();
}

class _ListingHqCarouselState extends State<ListingHqCarousel> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Con el carrusel ya medido se sabe si hace falta la flecha derecha.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int step) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final target = (position.pixels + step * position.viewportDimension * 0.8)
        .clamp(0.0, position.maxScrollExtent);
    _controller.animateTo(target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic);
  }

  Widget _arrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 6.0,
              color: Color(0x26000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        child: Icon(
          icon,
          color: FlutterFlowTheme.of(context).primaryText,
          size: 20.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth + 2 * ListingHqUi.gutter;
        return SizedBox(
          height: widget.height,
          child: OverflowBox(
            minWidth: fullWidth,
            maxWidth: fullWidth,
            child: Stack(
              children: [
                HorizontalFadeEdges(
                  child: ListView.separated(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(
                        horizontal: ListingHqUi.gutter, vertical: 6.0),
                    itemCount: widget.children.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: widget.spacing),
                    itemBuilder: (_, i) => widget.children[i],
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final measured = _controller.hasClients &&
                        _controller.position.hasContentDimensions;
                    final pixels = measured ? _controller.position.pixels : 0.0;
                    final max = measured
                        ? _controller.position.maxScrollExtent
                        : (widget.children.length > 1 ? double.infinity : 0.0);
                    return Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Stack(
                          children: [
                            if (pixels > 1)
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, 0.0),
                                child:
                                    _arrow(Icons.chevron_left, () => _move(-1)),
                              ),
                            if (pixels < max - 1)
                              Align(
                                alignment: const AlignmentDirectional(1.0, 0.0),
                                child:
                                    _arrow(Icons.chevron_right, () => _move(1)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Buscador con el mismo diseño que "Búsqueda con IA" del inicio del
/// cliente. Sin [controller] es sólo una barra que se toca ([onTap]).
class ListingHqSearchField extends StatelessWidget {
  const ListingHqSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.autofocus = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool autofocus;

  static const _radius = BorderRadius.all(Radius.circular(25.0));

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;
    return Container(
      height: 42.0,
      decoration: const BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 4.0),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: controller == null,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.publicSans(fontSize: 14.0),
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 12.0, 10.0),
          hintText: hintText,
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 13.0,
                letterSpacing: 0.2,
              ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: _radius,
          ),
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          prefixIcon: const Icon(Icons.search_rounded, size: 20.0),
          suffixIcon: hasText && onClear != null
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18.0),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}
