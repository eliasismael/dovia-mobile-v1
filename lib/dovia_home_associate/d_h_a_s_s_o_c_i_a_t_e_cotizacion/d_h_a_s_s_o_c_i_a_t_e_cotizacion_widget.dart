import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_cotizacion_model.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_cotizacion_model.dart';

/// Extensión que acepta el envío de propuestas. El endpoint recibe **un PDF**:
/// se valida acá para que la empresa no espere un upload que el backend va a
/// rechazar.
const List<String> _kProposalExtensions = ['pdf'];

/// Detalle del requerimiento del cliente y envío de la propuesta económica.
///
/// Es el "Ojo" de **Cotizaciones activas** del panel de la empresa: acá ve lo
/// que el cliente mandó —descripción y fotos— y responde con su presupuesto
/// (`POST /dovia-home/company/service-requests/{id}/quote-proposals`, multipart
/// con el PDF y el monto total en GTQ).
///
/// La **dirección sigue enmascarada**: la empresa todavía no ganó el proyecto y
/// la dirección exacta de un cliente que no la contrató no se revela. Se
/// desoculta recién cuando la propuesta se acepta y el trabajo pasa a su agenda,
/// en la pantalla de trabajo estándar.
///
/// Enviada la propuesta, la oportunidad deja de ser accionable desde acá: pasa
/// al carril "Cotizaciones enviadas" y la decisión es del cliente. Puede mandar
/// una versión nueva —el contrato versiona las propuestas— pero recién si el
/// cliente rechaza la anterior, así que la pantalla no ofrece reenviar.
class DHASSOCIATECotizacionWidget extends StatefulWidget {
  const DHASSOCIATECotizacionWidget({super.key});

  static String routeName = 'DH_ASSOCIATE_Cotizacion';
  static String routePath = '/dHASSOCIATECotizacion';

  /// Oportunidad que la empresa abrió desde su panel. Se inyecta antes de
  /// navegar, porque go_router navega sólo por nombre (misma convención que el
  /// resto de las pantallas del asociado).
  static Map<String, dynamic>? requestData;

  @override
  State<DHASSOCIATECotizacionWidget> createState() =>
      _DHASSOCIATECotizacionWidgetState();
}

class _DHASSOCIATECotizacionWidgetState
    extends State<DHASSOCIATECotizacionWidget> {
  late DHASSOCIATECotizacionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Oportunidad fijada al abrir la pantalla, para que el envío no dependa de
  /// un estático que otra navegación pueda cambiar por debajo.
  Map<String, dynamic>? _requestData;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHASSOCIATECotizacionModel());

    _model.amountController ??= TextEditingController();
    _model.amountFocusNode ??= FocusNode();

    _requestData = DHASSOCIATECotizacionWidget.requestData;
    DHASSOCIATECotizacionWidget.requestData = null;

    _loadDetail();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Requerimiento vigente: el detalle del backend si ya respondió, y mientras
  /// tanto lo que trajo el listado para no dejar la pantalla vacía.
  Map<String, dynamic>? get _request => _model.detail ?? _requestData;

  String get _requestId {
    final data = _request;
    return data == null ? '' : asrId(data);
  }

  /// Relee el requerimiento del marketplace de empresa. El listado es un
  /// resumen; esta llamada trae la descripción completa y las fotos, que son lo
  /// único con lo que se puede armar un presupuesto sin visitar.
  Future<void> _loadDetail() async {
    final id = _requestId;
    if (id.isEmpty) return;

    safeSetState(() => _model.isLoadingDetail = true);
    try {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .getCompanyQuoteServiceRequestCall
          .call(
        serviceRequestId: id,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;
      if (!response.succeeded) return;

      final data = getJsonField(response.jsonBody, r'''$.data''');
      if (data is Map) {
        safeSetState(() => _model.detail = Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Sin detalle fresco la pantalla sigue mostrando lo que trajo el
      // listado; no se bloquea el envío por un fallo de red.
    } finally {
      if (mounted) safeSetState(() => _model.isLoadingDetail = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Envío de la propuesta.
  // ---------------------------------------------------------------------------

  Future<void> _pickProposalFile() async {
    if (_model.isPickingFile) return;
    safeSetState(() => _model.isPickingFile = true);
    try {
      final selected = await selectFiles(
        multiFile: false,
        allowedExtensions: _kProposalExtensions,
      );
      if (selected == null || selected.isEmpty) return;

      final media = selected.first;
      // Se conserva el nombre real del archivo: es lo que va a ver el cliente
      // al descargar el presupuesto, no el `<timestamp>.pdf` del picker.
      final timestampedName = media.storagePath.split('/').last;
      final originalName = media.originalFilename;
      final name = originalName.contains('.') ? originalName : timestampedName;

      final rejection = _fileRejection(name, media.bytes);
      if (rejection != null) {
        _showMessage(rejection);
        return;
      }

      safeSetState(() {
        _model.proposalFile = FFUploadedFile(
          name: name,
          bytes: media.bytes,
          originalFilename: originalName,
        );
      });
    } finally {
      if (mounted) safeSetState(() => _model.isPickingFile = false);
    }
  }

  String? _fileRejection(String name, Uint8List? bytes) {
    if (!_kProposalExtensions.contains(name.split('.').last.toLowerCase())) {
      return 'El presupuesto tiene que ser un PDF.';
    }
    if (bytes == null || bytes.isEmpty) {
      return 'No pudimos leer el archivo. Prueba de nuevo o elige otro.';
    }
    return null;
  }

  /// Monto tecleado, o null si no es un número válido y mayor que cero.
  ///
  /// Se aceptan las dos formas en las que se escribe plata acá ("1200",
  /// "1,200.50") normalizando separadores antes de parsear: rechazar un monto
  /// bien escrito por un formato sería incomprensible.
  num? get _amount {
    final raw = _model.amountController?.text.trim() ?? '';
    if (raw.isEmpty) return null;
    final normalized = raw.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '');
    final value = num.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return value;
  }

  bool get _canSubmit =>
      !_model.isSubmitting &&
      !_model.submitted &&
      _requestId.isNotEmpty &&
      _amount != null &&
      _model.proposalFile != null;

  Future<void> _submit() async {
    final id = _requestId;
    final amount = _amount;
    final file = _model.proposalFile;
    if (id.isEmpty || amount == null || file == null) return;

    safeSetState(() => _model.isSubmitting = true);
    try {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .submitCompanyQuoteProposalCall
          .call(
        serviceRequestId: id,
        file: file,
        totalAmount: amount,
        authToken: currentAuthenticationToken ?? '',
      );
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage(_submitError(response));
        return;
      }

      safeSetState(() => _model.submitted = true);
      _showMessage('Propuesta enviada. El cliente la compara y decide.');
      Navigator.pop(context);
    } catch (_) {
      _showMessage('No pudimos enviar la propuesta. Intenta de nuevo.');
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  /// Qué decirle a la empresa cuando el envío falla.
  ///
  /// Se prefiere el `message` que manda la API —viene en castellano y apto para
  /// mostrar— y se cae a un texto por status: un 403 es la habilitación de la
  /// cuenta y un 409 es que la cotización ya se cerró, y ninguno de los dos se
  /// resuelve reintentando.
  String _submitError(ApiCallResponse response) {
    final message = getJsonField(response.jsonBody, r'''$.message''');
    if (message is String && message.trim().isNotEmpty) return message.trim();

    switch (response.statusCode) {
      case 403:
        return 'Tu cuenta no está habilitada para enviar cotizaciones. '
            'Contacta al equipo de DOVIA.';
      case 409:
        return 'Esta cotización ya no acepta propuestas.';
      default:
        return 'No pudimos enviar la propuesta. Intenta de nuevo.';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------------------------------------------------------------------------
  // Bloques de UI.
  // ---------------------------------------------------------------------------

  Widget _label(String text, {double fontSize = 16.0}) => Align(
        alignment: const AlignmentDirectional(-1.0, 0.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: fontSize,
                letterSpacing: fontSize * 0.02,
              ),
        ),
      );

  /// Caja de sólo lectura con un dato del requerimiento.
  Widget _infoBox(String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                fontSize: 12.0,
                letterSpacing: 0.0,
                lineHeight: 1.4,
              ),
        ),
      );

  /// Resumen de la oportunidad, con la dirección todavía enmascarada.
  Widget _buildSummary() {
    final data = _request;
    if (data == null) {
      return _infoBox('No encontramos el requerimiento. Vuelve al panel y '
          'ábrelo de nuevo.');
    }
    return _infoBox(
      '${asrServiceName(data)}\n'
      '${asrLongDate(data)} · ${asrTimeLabel(data)}\n'
      '${asrZoneLabel(data)}',
    );
  }

  /// Texto que escribió el cliente. Sin descripción se dice que no la hay: es
  /// información que cambia cómo se cotiza, y una caja vacía se lee como un
  /// error de la app.
  Widget _buildClientDescription() {
    final data = _request;
    final description = data == null ? null : asrDescription(data);
    return _infoBox(description ??
        'El cliente no dejó una descripción escrita de lo que necesita.');
  }

  /// Fotos que mandó el cliente. Es la evidencia con la que se presupuesta sin
  /// haber visitado.
  Widget _buildClientImages() {
    final data = _request;
    final urls = data == null ? const <String>[] : asrRequestImages(data);

    if (urls.isEmpty) {
      return _infoBox(_model.isLoadingDetail
          ? 'Cargando las fotos del cliente…'
          : 'El cliente no adjuntó fotos de lo que necesita.');
    }

    return SizedBox(
      height: 92.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15.0),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            urls[index],
            width: 92.0,
            height: 92.0,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 92.0,
              height: 92.0,
              color: FlutterFlowTheme.of(context).alternate,
              child: Icon(
                Icons.broken_image_outlined,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _model.amountController,
      focusNode: _model.amountFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => safeSetState(() {}),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Ej: 4,500.00',
        prefixText: 'Q ',
        prefixStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context)
                  .secondaryText
                  .withValues(alpha: 0.5),
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: FlutterFlowTheme.of(context).alternate,
        contentPadding:
            const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(),
            fontSize: 14.0,
            letterSpacing: 0.0,
          ),
      cursorColor: FlutterFlowTheme.of(context).primaryText,
      validator: _model.amountControllerValidator.asValidator(context),
    );
  }

  /// Caja de carga del PDF: dice qué archivo quedó elegido, para que la empresa
  /// no mande el presupuesto equivocado.
  Widget _buildFilePicker() {
    final file = _model.proposalFile;

    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: _model.isPickingFile ? null : _pickProposalFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/page-edit.svg',
              width: 24.0,
              height: 24.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                file?.name ?? 'Sube el PDF con tu presupuesto',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(),
                      color: file == null
                          ? FlutterFlowTheme.of(context).secondaryText
                          : FlutterFlowTheme.of(context).primaryText,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            if (file != null)
              Icon(
                Icons.check_circle_outline,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }

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
        body: SafeArea(
          top: true,
          child: Stack(
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
                        tittleText: 'Cotización',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 35.0, 20.0, 140.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Requerimiento', fontSize: 14.0),
                          const SizedBox(height: 12.0),
                          _buildSummary(),
                          const SizedBox(height: 21.0),
                          _label('Lo que pide el cliente'),
                          const SizedBox(height: 12.0),
                          _buildClientDescription(),
                          const SizedBox(height: 21.0),
                          _label('Fotos del cliente'),
                          const SizedBox(height: 12.0),
                          _buildClientImages(),
                          const SizedBox(height: 21.0),
                          _label('Monto total de tu propuesta'),
                          const SizedBox(height: 12.0),
                          _buildAmountField(),
                          const SizedBox(height: 21.0),
                          _label('Presupuesto en PDF'),
                          const SizedBox(height: 12.0),
                          _buildFilePicker(),
                          const SizedBox(height: 21.0),
                          FFButtonWidget(
                            onPressed: _canSubmit ? _submit : null,
                            text: _model.isSubmitting
                                ? 'Enviando…'
                                : 'Enviar propuesta',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 42.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(25.0),
                              disabledColor:
                                  FlutterFlowTheme.of(context).alternate,
                              disabledTextColor:
                                  FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
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
      ),
    );
  }
}
