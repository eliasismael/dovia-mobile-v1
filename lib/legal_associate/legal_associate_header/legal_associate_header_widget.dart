import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_associate_header_model.dart';
export 'legal_associate_header_model.dart';

class LegalAssociateHeaderWidget extends StatefulWidget {
  const LegalAssociateHeaderWidget({
    super.key,
    required this.titleText,
  });

  final String? titleText;

  @override
  State<LegalAssociateHeaderWidget> createState() =>
      _LegalAssociateHeaderWidgetState();
}

class _LegalAssociateHeaderWidgetState
    extends State<LegalAssociateHeaderWidget> {
  late LegalAssociateHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalAssociateHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El ícono de documentos queda marcado cuando la bandeja está abierta.
    String? route;
    try {
      route = GoRouterState.of(context).name;
    } catch (_) {}
    final onDocuments = route == LEGALASSOCIATEDocumentosWidget.routeName;
    // En el inicio no hay a dónde volver.
    final onHome = route == LegalAssociateHomeWidget.routeName;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 42.0, 20.0, 0.0),
      child: Row(
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
                if (!onHome)
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
                // La D lleva al inicio del Legal Associate (limpia el stack).
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      context.goNamed(LegalAssociateHomeWidget.routeName),
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
          RichText(
            textScaler: MediaQuery.of(context).textScaler,
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.titleText!,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.4,
                      ),
                )
              ],
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    lineHeight: 1.4,
                  ),
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: onDocuments
                      ? const Color(0xFF00444B)
                      : FlutterFlowTheme.of(context).secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (onDocuments) return;
                    context.pushNamed(LEGALASSOCIATEDocumentosWidget.routeName);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: SvgPicture.asset(
                      'assets/images/multiple-pages.svg',
                      width: 8.0,
                      height: 8.0,
                      fit: BoxFit.none,
                      colorFilter: onDocuments
                          ? const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn)
                          : null,
                    ),
                  ),
                ),
              ),
            ].divide(const SizedBox(width: 8.0)),
          ),
        ],
      ),
    );
  }
}
