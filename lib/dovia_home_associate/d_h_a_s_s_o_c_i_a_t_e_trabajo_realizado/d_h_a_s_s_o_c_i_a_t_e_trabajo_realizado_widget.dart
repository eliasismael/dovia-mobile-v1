import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_trabajo_realizado_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_trabajo_realizado_model.dart';

/// Resumen de un trabajo que el asociado ya finalizó. Se abre desde el "Ojo" de
/// una tarjeta de la sección "Trabajos terminados" de la agenda.
///
/// Es **estrictamente de solo lectura**: no hay campos editables, ni carga de
/// evidencia, ni acciones sobre la solicitud. Por eso es una pantalla propia y
/// no el formulario de cierre en modo pasivo: acá no existe nada que se pueda
/// enviar, y además muestra algo que el cierre no tiene —el feedback del
/// cliente—.
///
/// Dos secciones, las del diseño:
///   - **Información que se envió al cliente**: el informe que documentó el
///     asociado y las fotos de evidencia que subió.
///   - **Feedback del cliente**: las estrellas y el comentario que dejó.
class DHASSOCIATETrabajoRealizadoWidget extends StatefulWidget {
  const DHASSOCIATETrabajoRealizadoWidget({super.key});

  /// Trabajo terminado a mostrar. Se fija antes de navegar.
  static Map<String, dynamic>? requestData;

  static String routeName = 'DH_ASSOCIATE_TrabajoRealizado';
  static String routePath = '/dHASSOCIATETrabajoRealizado';

  @override
  State<DHASSOCIATETrabajoRealizadoWidget> createState() =>
      _DHASSOCIATETrabajoRealizadoWidgetState();
}

class _DHASSOCIATETrabajoRealizadoWidgetState
    extends State<DHASSOCIATETrabajoRealizadoWidget> {
  late DHASSOCIATETrabajoRealizadoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Alto de la caja de evidencia del diseño.
  static const double _mediaBoxHeight = 168.0;

  /// Alto mínimo de las cajas de texto de solo lectura.
  static const double _textBoxMinHeight = 104.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATETrabajoRealizadoModel());

    // Lo que inyectó la tarjeta se pinta sin esperar al backend; el detalle
    // sólo completa lo que el resumen del listado no trae.
    _model.requestData = DHASSOCIATETrabajoRealizadoWidget.requestData;

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Datos.
  // ---------------------------------------------------------------------------

  Map<String, dynamic> get _data => _model.requestData ?? const {};

  /// Trae el detalle del trabajo y lo mergea sobre el resumen del listado.
  ///
  /// El item del listado no trae la evidencia de completado ni el feedback del
  /// cliente, así que sin esta lectura la pantalla sólo podría mostrar el
  /// informe. El merge no reemplaza: conserva los campos que sí venían.
  Future<void> _loadDetail() async {
    final id = _data.isEmpty ? '' : asrId(_data);
    if (id.isEmpty) {
      // Sin id no hay detalle que pedir: se muestra lo inyectado.
      if (mounted) safeSetState(() {});
      return;
    }

    safeSetState(() {
      _model.isLoading = true;
      _model.loadFailed = false;
    });

    try {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .getAssociateServiceRequestCall
          .call(
        serviceRequestId: id,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        safeSetState(() => _model.loadFailed = true);
        _notifyLoadFailure();
        return;
      }

      final body = getJsonField(response.jsonBody, r'''$.data''');
      final detail = body is Map
          ? Map<String, dynamic>.from(body)
          : (response.jsonBody is Map
              ? Map<String, dynamic>.from(response.jsonBody as Map)
              : null);

      safeSetState(() {
        _model.detailLoaded = true;
        if (detail != null && detail.isNotEmpty) {
          _model.requestData = {..._data, ...detail};
        }
      });
    } catch (_) {
      if (!mounted) return;
      safeSetState(() => _model.loadFailed = true);
      _notifyLoadFailure();
    } finally {
      if (mounted) safeSetState(() => _model.isLoading = false);
    }
  }

  /// Avisa que el detalle no se pudo leer y ofrece reintentar. Sin esto el fallo
  /// sería mudo: un trabajo con evidencia y calificación se vería igual que uno
  /// sin nada de eso.
  void _notifyLoadFailure() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('No se pudo cargar el detalle del trabajo.'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: _loadDetail,
          ),
        ),
      );
  }

  /// Qué decir cuando una sección viene vacía. Mientras el detalle está en vuelo
  /// —o si falló— no se afirma que el dato no existe.
  String _emptyMessage(String whenEmpty) {
    if (_model.isLoading) return 'Cargando…';
    if (_model.loadFailed) return 'No se pudo cargar esta información.';
    return whenEmpty;
  }

  /// El informe que el asociado le mandó al cliente, en líneas: la descripción
  /// del trabajo y, si las cargó, las recomendaciones.
  List<String> get _reportLines {
    final lines = <String>[];
    final description = asrCompletionDescription(_data);
    if (description != null) lines.add(description);
    final recommendations = asrCompletionRecommendations(_data);
    if (recommendations != null) {
      lines.add('Recomendaciones: $recommendations');
    }
    return lines;
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  /// Título de sección ("Información que se envio al cliente").
  Widget _sectionTitle(String title) => Text(
        title,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 17.0,
              letterSpacing: 0.34,
              fontWeight: FontWeight.w600,
            ),
      );

  /// Etiqueta de un campo ("Imagenes que se mandaron").
  Widget _fieldLabel(
    String label, {
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      Text(
        label,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: fontWeight),
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: fontSize,
              letterSpacing: fontSize * 0.02,
              fontWeight: fontWeight,
            ),
      );

  /// Caja gris de solo lectura del diseño. No es un TextFormField deshabilitado
  /// a propósito: acá no hay nada que pueda recibir foco ni parecer editable.
  Widget _readOnlyBox({required Widget child}) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: _textBoxMinHeight),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16.0),
        child: child,
      );

  Widget _boxText(String text, {required bool muted}) => Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(),
              color: muted
                  ? FlutterFlowTheme.of(context).secondaryText
                  : FlutterFlowTheme.of(context).primaryText,
              fontSize: 14.0,
              letterSpacing: 0.28,
              lineHeight: 1.6,
            ),
      );

  /// Informe enviado con anterioridad, en formato de lista.
  Widget _buildReport() {
    final lines = _reportLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Informe enviado con anterioridad:', fontSize: 14.0),
        const SizedBox(height: 12.0),
        _readOnlyBox(
          child: lines.isEmpty
              ? _boxText(
                  _emptyMessage('No registraste un informe para este trabajo.'),
                  muted: true,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _boxText('•  ', muted: false),
                            Expanded(child: _boxText(line, muted: false)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Una foto de la evidencia. Un error de red no rompe la tira: esa foto cae al
  /// recuadro vacío y las demás siguen cargando.
  Widget _photo(String url) => ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          url,
          width: 136.0,
          height: 136.0,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : Container(
                  width: 136.0,
                  height: 136.0,
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  child: const Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
                ),
          errorBuilder: (context, _, __) => Container(
            width: 136.0,
            height: 136.0,
            color: FlutterFlowTheme.of(context).primaryBackground,
            child: Icon(
              Icons.broken_image_outlined,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 28.0,
            ),
          ),
        ),
      );

  /// Evidencia fotográfica: carrusel horizontal dentro de la caja del diseño.
  /// En escritorio es una cuadrícula; en mobile no entran tres fotos legibles
  /// por fila, así que se deslizan.
  Widget _buildEvidence() {
    final images = asrCompletionImages(_data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Imagenes que se mandaron'),
        const SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          height: _mediaBoxHeight,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: images.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/AddMediaImage.svg',
                      width: 24.0,
                      height: 24.0,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        _emptyMessage('No enviaste imágenes de este trabajo.'),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.publicSans(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 13.0,
                              letterSpacing: 0.26,
                            ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12.0),
                  itemBuilder: (_, index) => _photo(images[index]),
                ),
        ),
      ],
    );
  }

  /// Calificación del cliente: las 5 estrellas con las que otorgó rellenas.
  ///
  /// `ignoreGestures` es lo que sostiene la inmutabilidad: la barra se ve igual
  /// que en "Calificar" pero no se puede tocar.
  Widget _buildRating() {
    final stars = asrClientRatingStars(_data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Calificacion que se te asigno'),
        const SizedBox(height: 20.0),
        Align(
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: RatingBar.builder(
            onRatingUpdate: (_) {},
            ignoreGestures: true,
            itemBuilder: (context, index) => Icon(
              Icons.star_rounded,
              color: FlutterFlowTheme.of(context).primary,
            ),
            direction: Axis.horizontal,
            initialRating: stars ?? 0.0,
            unratedColor: FlutterFlowTheme.of(context).alternate,
            itemCount: 5,
            itemSize: 44.0,
            glowColor: FlutterFlowTheme.of(context).primary,
          ),
        ),
        if (stars == null) ...[
          const SizedBox(height: 14.0),
          Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Text(
              _emptyMessage('El cliente aún no ha dejado una calificación.'),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 14.0,
                    letterSpacing: 0.28,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  /// Reseña escrita del cliente.
  Widget _buildComment() {
    final comment = asrClientRatingComment(_data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Comentario que se te asigno', fontWeight: FontWeight.w500),
        const SizedBox(height: 12.0),
        _readOnlyBox(
          child: _boxText(
            comment ?? _emptyMessage('El cliente no dejó ningún comentario.'),
            muted: comment == null,
          ),
        ),
      ],
    );
  }

  /// Cierra el detalle y vuelve a la agenda.
  Widget _buildAceptarButton() => FFButtonWidget(
        onPressed: () => context.safePop(),
        text: 'Aceptar',
        options: FFButtonOptions(
          width: double.infinity,
          height: 42.0,
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          color: FlutterFlowTheme.of(context).primary,
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: Colors.white,
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
          elevation: 0.0,
          borderRadius: BorderRadius.circular(25.0),
        ),
      );

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
                    model: _model.dHASSOCIATEHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHASSOCIATEHeaderWidget(
                      tittleText: 'Tu trabajo realizado',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 28.0, 20.0, 120.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Información que se envio al cliente'),
                        const SizedBox(height: 21.0),
                        _buildReport(),
                        const SizedBox(height: 21.0),
                        _buildEvidence(),
                        const SizedBox(height: 28.0),
                        _sectionTitle('Feedback del cliente'),
                        const SizedBox(height: 21.0),
                        _buildRating(),
                        const SizedBox(height: 24.0),
                        _buildComment(),
                        const SizedBox(height: 32.0),
                        _buildAceptarButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 5.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.dHASSOCIATENavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHASSOCIATENavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
