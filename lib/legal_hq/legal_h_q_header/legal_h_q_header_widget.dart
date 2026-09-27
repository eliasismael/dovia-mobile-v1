import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_h_q_header_model.dart';
export 'legal_h_q_header_model.dart';

class LegalHQHeaderWidget extends StatefulWidget {
  const LegalHQHeaderWidget({
    super.key,
    required this.text,
    this.showBack = true,
  });

  final String? text;

  /// En el Home no hay pantalla anterior: volver llevaría al login.
  final bool showBack;

  @override
  State<LegalHQHeaderWidget> createState() => _LegalHQHeaderWidgetState();
}

class _LegalHQHeaderWidgetState extends State<LegalHQHeaderWidget> {
  late LegalHQHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalHQHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Espacio que dejan el grupo de volver + logo y los íconos de la
    // derecha. Si el título no entra, baja a una segunda línea centrada.
    final titleStyle = GoogleFonts.publicSans(
        fontSize: 18.0, fontWeight: FontWeight.w600, height: 1.4);
    final available = MediaQuery.sizeOf(context).width - 40.0 - 200.0;
    final painter = TextPainter(
      text: TextSpan(text: widget.text ?? '', style: titleStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.of(context).textScaler,
    )..layout();
    final fits = painter.width <= available;
    final Widget title = RichText(
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        children: [
          TextSpan(
            text: valueOrDefault<String>(
              widget.text,
              '[text]',
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  lineHeight: 1.4,
                ),
          )
        ],
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              fontSize: 18.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              lineHeight: 1.4,
            ),
      ),
      textAlign: TextAlign.center,
      maxLines: fits ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );
    final row = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.showBack)
                Container(
                  width: 35.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.safePop();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SvgPicture.asset(
                        'assets/images/IconoVolverAtras.svg',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                ),
              // La D lleva al home.
              GestureDetector(
                onTap: () => context.goNamed(LEGALHQHomeWidget.routeName),
                child: SvgPicture.asset(
                  'assets/images/D-verde.svg',
                  width: 28.0,
                  height: 36.0,
                  fit: BoxFit.cover,
                ),
              ),
            ].divide(const SizedBox(width: 8.0)),
          ),
        ),
        if (fits) title,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  // El visor necesita un documento concreto, así que el
                  // acceso rápido lleva al listado de expedientes por
                  // revisar, que es de donde se abre cada documento.
                  context.pushNamed(LEGALHQProcesosWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: SvgPicture.asset(
                    'assets/images/multiple-pages.svg',
                    width: 8.0,
                    height: 8.0,
                    fit: BoxFit.none,
                  ),
                ),
              ),
            ),
          ].divide(const SizedBox(width: 8.0)),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 42.0, 20.0, 0.0),
      child: fits
          ? row
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                row,
                const SizedBox(height: 10.0),
                SizedBox(width: double.infinity, child: title),
              ],
            ),
    );
  }
}
