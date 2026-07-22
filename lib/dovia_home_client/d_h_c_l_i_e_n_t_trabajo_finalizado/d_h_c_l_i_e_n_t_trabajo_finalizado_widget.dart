import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_trabajo_finalizado_model.dart';
export 'd_h_c_l_i_e_n_t_trabajo_finalizado_model.dart';

/// Detalle de un servicio finalizado (registro inmutable / solo lectura). Se
/// abre desde la lista "Visitas Finalizadas" tapeando una tarjeta.
///
/// La solicitud a mostrar se pasa por el campo estático [requestData]. Todos los
/// campos se leen best-effort (el shape del backend es incierto) con fallbacks
/// al diseño para que la pantalla renderice siempre.
///
/// Reglas operativas (AC):
/// - [Calificar] siempre visible y funcional.
/// - [Reportar problema] respeta la regla de caducidad de 7 días: si el trabajo
///   se finalizó hace más de 7 días el botón se oculta.
class DHCLIENTTrabajoFinalizadoWidget extends StatefulWidget {
  const DHCLIENTTrabajoFinalizadoWidget({super.key});

  /// Datos exactos y bloqueados de la solicitud finalizada a renderizar.
  static Map<String, dynamic>? requestData;

  static String routeName = 'DH_CLIENT_TrabajoFinalizado';
  static String routePath = '/dHCLIENTTrabajoFinalizado';

  @override
  State<DHCLIENTTrabajoFinalizadoWidget> createState() =>
      _DHCLIENTTrabajoFinalizadoWidgetState();
}

class _DHCLIENTTrabajoFinalizadoWidgetState
    extends State<DHCLIENTTrabajoFinalizadoWidget> {
  late DHCLIENTTrabajoFinalizadoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTTrabajoFinalizadoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Extracción best-effort de los datos del trabajo finalizado.
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? get _data => DHCLIENTTrabajoFinalizadoWidget.requestData;

  String? _firstString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  /// URLs de imágenes a partir de una lista cuyo item puede ser un String o un
  /// Map con alguna de las claves conocidas.
  List<String> _urlsFrom(dynamic list) {
    if (list is! List) return [];
    final urls = <String>[];
    for (final it in list) {
      if (it is String && it.trim().isNotEmpty) {
        urls.add(it.trim());
      } else if (it is Map) {
        final u = _firstString(
            [it['url'], it['signedUrl'], it['downloadUrl'], it['storageKey']]);
        if (u != null) urls.add(u);
      }
    }
    return urls;
  }

  /// Fotografías de evidencia del trabajo terminado (subidas por el asociado al
  /// finalizar).
  List<String> get _evidenceImages => _urlsFrom(
        _data?['completionImages'] ??
            _data?['completedImages'] ??
            _data?['evidenceImages'] ??
            _data?['finishImages'],
      );

  /// Fotografías del material sobrante (si aplica).
  List<String> get _leftoverImages => _urlsFrom(
        _data?['leftoverImages'] ??
            _data?['remainingMaterialsImages'] ??
            _data?['materialImages'],
      );

  /// Texto del campo "Trabajo realizado" (descripción de completado).
  String get _workDone =>
      _firstString([
        _data?['completionDescription'],
        _data?['workDoneDescription'],
        _data?['completionNotes'],
      ]) ??
      '';

  /// Ubicación / detalle del material sobrante. Sólo aplica a algunos servicios.
  String get _leftoverLocation =>
      _firstString([
        _data?['leftoverMaterialsLocation'],
        _data?['remainingMaterialsLocation'],
        _data?['materialsLocation'],
        _data?['clientRecommendations'],
      ]) ??
      '';

  /// La sección "Material sobrante" sólo se renderiza si el servicio la reporta.
  bool get _hasLeftover =>
      _leftoverLocation.isNotEmpty || _leftoverImages.isNotEmpty;

  /// Texto de garantía inyectado desde backend, con fallback al copy del diseño.
  String get _warrantyText =>
      _firstString([
        _data?['warrantyInfo'],
        _data?['warranty'],
        _data?['warrantyDescription'],
      ]) ??
      'Recuerda que los trabajos tienen garantía Dovia.';

  /// Fecha de finalización, para evaluar la regla de caducidad de 7 días.
  DateTime? get _finishedAt {
    final apt = _data?['appointment'];
    final raw = _firstString([
      _data?['finishedAt'],
      _data?['completedAt'],
      apt is Map ? apt['finishedAt'] : null,
    ]);
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  /// Regla de 7 días: el botón "Reportar problema" sólo se muestra dentro de los
  /// 7 días posteriores a la finalización. Si no hay fecha (modo demo) se muestra.
  bool get _canReport {
    final finished = _finishedAt;
    if (finished == null) return true;
    return DateTime.now().difference(finished).inDays <= 7;
  }

  // ---------------------------------------------------------------------------
  // UI.
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            wrapWithModel(
              model: _model.cornerGradientBackgroundModel,
              updateCallback: () => safeSetState(() {}),
              child: const CornerGradientBackgroundWidget(),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.dOVIASHAREDHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DOVIASHAREDHeaderWidget(
                      title: 'Trabajo\nFinalizado',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 100.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Regla de 7 días: se oculta si el trabajo se finalizó
                        // hace más de una semana.
                        if (_canReport)
                          Align(
                            alignment: const AlignmentDirectional(1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: _buildReportButton(),
                            ),
                          ),
                        const SizedBox(height: 12.0),
                        _sectionCard(child: _evidencePhotos()),
                        const SizedBox(height: 12.0),
                        _sectionLabel('Trabajo realizado'),
                        const SizedBox(height: 8.0),
                        _readOnlyText(_workDone.isNotEmpty
                            ? _workDone
                            : 'Sin descripción registrada.'),
                        if (_hasLeftover) ...[
                          const SizedBox(height: 12.0),
                          _sectionLabel(_leftoverLocation.isNotEmpty
                              ? 'Material sobrante ubicado en: $_leftoverLocation'
                              : 'Material sobrante'),
                          if (_leftoverImages.isNotEmpty) ...[
                            const SizedBox(height: 8.0),
                            _sectionCard(
                                child: _photosRow(_leftoverImages)),
                          ],
                        ],
                        const SizedBox(height: 12.0),
                        _warrantyBanner(),
                        const SizedBox(height: 30.0),
                        _buildCalificarButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 100.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.dHCLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHCLIENTNavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        context.pushNamed(DHCLIENTReportarProblemaWidget.routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: const Color(0x9F11A7AB),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SvgPicture.asset(
                    'assets/images/warning-triangle.svg',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.none,
                  ),
                ),
              ),
              Text(
                'Reportar\nProblema',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                    ),
              ),
            ].divide(const SizedBox(width: 8.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildCalificarButton() {
    return FFButtonWidget(
      onPressed: () async {
        context.pushNamed(DHCLIENTCalificarWidget.routeName);
      },
      text: 'Calificar',
      options: FFButtonOptions(
        width: double.infinity,
        height: 42.0,
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.publicSans(),
              color: Colors.white,
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(24.0),
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
        alignment: const AlignmentDirectional(-1.0, 0.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                letterSpacing: 0.0,
              ),
        ),
      );

  Widget _sectionCard({required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(20.0),
        child: child,
      );

  /// Texto de solo lectura (registro inmutable). Reemplaza al TextFormField
  /// editable del diseño: el cliente sólo consulta lo que hizo el asociado.
  Widget _readOnlyText(String text) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                letterSpacing: 0.0,
              ),
        ),
      );

  /// Fila de fotos de evidencia. Sin URLs reales cae a los placeholders del
  /// diseño para no dejar la sección vacía.
  Widget _evidencePhotos() {
    final urls = _evidenceImages;
    if (urls.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (_) => _photoPlaceholder()),
      );
    }
    return _photosRow(urls);
  }

  Widget _photosRow(List<String> urls) => SizedBox(
        height: 60.0,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: urls.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10.0),
          itemBuilder: (context, i) => ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              urls[i],
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _photoPlaceholder(),
            ),
          ),
        ),
      );

  Widget _photoPlaceholder() => ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: SvgPicture.asset(
          'assets/images/AddMediaImage.svg',
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
      );

  Widget _warrantyBanner() => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0x3570ACAD),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
        child: Text(
          _warrantyText,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                letterSpacing: 0.0,
              ),
        ),
      );
}
