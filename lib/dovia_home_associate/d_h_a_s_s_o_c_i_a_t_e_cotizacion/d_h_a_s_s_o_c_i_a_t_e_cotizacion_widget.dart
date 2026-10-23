import '/core/network_image_size.dart';
import 'package:url_launcher/url_launcher.dart';
import '/dovia_home_associate/associate_nav.dart';
import 'dart:async';

import '/dovia_home_associate/associate_service_request_fields.dart';
import '/dovia_home_associate/company_quote_fields.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_header/d_h_a_s_s_o_c_i_a_t_e_header_widget.dart';
import '/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import '/dovia_home_client/checkout_launcher.dart';
import '/dovia_home_client/proposal_fields.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_dovia_home.dart';
import '/backend/api_requests/api_manager.dart';

import 'd_h_a_s_s_o_c_i_a_t_e_cotizacion_model.dart';
import '/shared_components/dovia_spinner.dart';
export 'd_h_a_s_s_o_c_i_a_t_e_cotizacion_model.dart';

/// Extensiones que acepta el envío de propuestas: un PDF con el desglose, o una
/// imagen del mismo cuando la empresa no tiene el presupuesto en PDF.
const List<String> _kProposalExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

/// Estados del ciclo de venta que esta pantalla puede mostrar.
enum _QuoteState { active, submitted, approved }

/// Detalle **dinámico** de una solicitud a medida: arma y envía el
/// presupuesto, y también da seguimiento a su estado una vez enviado.
///
/// Es el "Ver trabajo" de "Cotizaciones activas" y "Cotizaciones enviadas" del
/// panel/historial de la empresa. Qué se ve depende de con qué se abrió:
///
///   - **[requestData] solo → Estado 1 (Activa).** Todavía no cotizó: ve lo
///     que el cliente mandó —descripción y fotos— y responde con precio y
///     archivo (`POST /dovia-home/company/service-requests/{id}/quote-proposals`,
///     multipart con el PDF/imagen y el monto total en GTQ).
///   - **[requestData] + [proposalData] `SUBMITTED` → Estado 2 (Enviada).**
///     Precio y archivo pasan a sólo lectura y se muestra el banner de espera:
///     no hay nada que operar hasta que el cliente decida.
///   - **[requestData] + [proposalData] `ACCEPTED` → Estado 3 (Aprobada).**
///     Banner de éxito con la fecha de aceptación y el botón [Información del
///     cliente] se habilita: es la única pantalla donde la empresa ve el
///     contacto de un cliente que **todavía no era suyo** hasta ganar el
///     proyecto.
///
/// Las propuestas **rechazadas** no pasan por acá: vuelven a "Cotizaciones
/// activas" para una versión nueva (el contrato versiona las propuestas), así
/// que su lectura vive en [DHASSOCIATEPropuestaEnviadaWidget].
class DHASSOCIATECotizacionWidget extends StatefulWidget {
  const DHASSOCIATECotizacionWidget({
    super.key,
    this.routeId,
    this.routeProposalId,
  });

  /// Id del trabajo que viene en la ruta (`?id=`). Manda sobre el campo
  /// estático cuando no coinciden: ver [associateRouteParams].
  final String? routeId;

  /// Id de la propuesta que viene en la ruta (`?proposalId=`).
  final String? routeProposalId;

  static String routeName = 'DH_ASSOCIATE_Cotizacion';
  static String routePath = '/dHASSOCIATECotizacion';

  /// Solicitud que la empresa abrió desde su panel. Se inyecta antes de
  /// navegar, porque go_router navega sólo por nombre (misma convención que el
  /// resto de las pantallas del asociado).
  static Map<String, dynamic>? requestData;

  /// Propuesta ya existente para esa solicitud. Null → Estado 1 (Activa);
  /// `SUBMITTED` → Estado 2; `ACCEPTED` → Estado 3.
  static Map<String, dynamic>? proposalData;

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

    _requestData = resolveRouteRequest(
        DHASSOCIATECotizacionWidget.requestData, widget.routeId);
    _model.proposal = DHASSOCIATECotizacionWidget.proposalData;
    DHASSOCIATECotizacionWidget.requestData = null;
    DHASSOCIATECotizacionWidget.proposalData = null;

    _loadRouteProposalThenDetail();

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

  /// Estado del ciclo de venta que le corresponde mostrar a la pantalla.
  ///
  /// [proposal] manda: si llegó `ACCEPTED` es Estado 3 aunque el envío local
  /// de este mismo formulario también esté marcado. Sin propuesta inyectada,
  /// [DHASSOCIATECotizacionModel.submitted] es lo que mueve a Estado 2 apenas
  /// se termina de enviar, sin esperar releer el listado.
  _QuoteState get _state {
    final proposal = _model.proposal;
    if (proposal != null) {
      return proposalStatus(proposal) == kProposalAccepted
          ? _QuoteState.approved
          : _QuoteState.submitted;
    }
    return _model.submitted ? _QuoteState.submitted : _QuoteState.active;
  }

  /// La propuesta decide el estado (activa, enviada, aprobada), así que si
  /// sólo vino su id en la ruta se pide antes que el requerimiento.
  Future<void> _loadRouteProposalThenDetail() async {
    final id = widget.routeProposalId ?? '';
    final current = _model.proposal;
    if (id.isNotEmpty && (current == null || proposalId(current) != id)) {
      final response = await DOVIAAPIDoviaHomeContextGroup
          .getCompanyQuoteProposalCall
          .call(proposalId: id, authToken: currentAuthenticationToken ?? '');
      if (!mounted) return;
      final data = response.succeeded
          ? getJsonField(response.jsonBody, r'''$.data''')
          : null;
      if (data is Map) {
        safeSetState(() => _model.proposal = Map<String, dynamic>.from(data));
      }
    }
    await _loadDetail();
  }

  /// Relee la solicitud. En Estado 3 el servicio ya salió del marketplace de
  /// empresa (el cliente lo tomó), así que el detalle se pide contra el
  /// listado de trabajos asignados; en los otros dos todavía es una
  /// oportunidad del marketplace. Es el mismo endpoint que usa cada listado
  /// para leer el detalle completo (fotos y texto que el resumen recorta).
  Future<void> _loadDetail() async {
    final id = _requestId;
    if (id.isEmpty) return;

    safeSetState(() => _model.isLoadingDetail = true);
    try {
      final response = _state == _QuoteState.approved
          ? await DOVIAAPIDoviaHomeContextGroup.getAssociateServiceRequestCall
              .call(
                  serviceRequestId: id,
                  authToken: currentAuthenticationToken ?? '')
          : await DOVIAAPIDoviaHomeContextGroup
              .getCompanyQuoteServiceRequestCall
              .call(
                  serviceRequestId: id,
                  authToken: currentAuthenticationToken ?? '');
      if (!mounted) return;
      if (!response.succeeded) return;

      final data = getJsonField(response.jsonBody, r'''$.data''');
      if (data is Map) {
        final request = Map<String, dynamic>.from(data);
        safeSetState(() {
          _model.detail = request;
          _model.clientProfile = cqExtractClientProfile(request);
        });
      }
    } catch (_) {
      // Sin detalle fresco la pantalla sigue mostrando lo que trajo el
      // listado; no se bloquea el envío por un fallo de red.
    } finally {
      if (mounted) safeSetState(() => _model.isLoadingDetail = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Envío de la propuesta (Estado 1).
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
      // al descargar el presupuesto, no el `<timestamp>.ext` del picker.
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
      return 'El presupuesto tiene que ser un PDF o una imagen (jpg/png).';
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
    final normalized =
        raw.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '');
    final value = num.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return value;
  }

  bool get _canSubmit =>
      _state == _QuoteState.active &&
      !_model.isSubmitting &&
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
      final response =
          await DOVIAAPIDoviaHomeContextGroup.submitCompanyQuoteProposalCall
              .call(
                serviceRequestId: id,
                file: file,
                totalAmount: amount,
                authToken: currentAuthenticationToken ?? '',
              )
              // Sin tope, una subida trabada dejaba el spinner girando para
              // siempre sin decir nada.
              .timeout(const Duration(seconds: 60));
      if (!mounted) return;

      if (!response.succeeded) {
        _showMessage(_submitError(response));
        return;
      }

      // Se queda en esta misma pantalla: el modal de éxito confirma el envío
      // y, al cerrarse, la vista ya está en Estado 2 con los campos
      // bloqueados — no hay que volver al panel para verlo.
      safeSetState(() => _model.submitted = true);
      await _showSubmittedDialog();
    } on TimeoutException {
      _showMessage('El envío tardó demasiado y no obtuvimos respuesta. Revisa '
          'tu conexión y vuelve a intentarlo.');
    } catch (e) {
      _showMessage('No pudimos enviar la propuesta: $e');
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
    if (message is List && message.isNotEmpty) return message.join(', ');

    switch (response.statusCode) {
      case 403:
        return 'Tu cuenta no está habilitada para enviar cotizaciones. '
            'Contacta al equipo de DOVIA.';
      case 409:
        return 'Esta cotización ya no acepta propuestas.';
      default:
        return 'No pudimos enviar la propuesta (error '
            '${response.statusCode}). Intenta de nuevo.';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Modal de envío exitoso (Estado 1 → 2). Se cierra solo, y el "afuera"
  /// también lo cierra: `showDialog` es descartable por barrera por defecto.
  Future<void> _showSubmittedDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: const AlignmentDirectional(0.0, 0.0)
            .resolve(Directionality.of(context)),
        child: const _AutoCloseDialogContent(
          child: PopupExitoWidget(
            title: 'Se envió con éxito la cotización',
            text: 'Se ha enviado la cotización al cliente. Le informaremos '
                'para que pueda responder.',
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Datos del cliente (Estado 3).
  // ---------------------------------------------------------------------------

  void _showClientInfoDialog() {
    final profile = _model.clientProfile ?? const <String, dynamic>{};
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _ClientInfoDialog(
          name: cqClientName(profile),
          phone: cqClientPhone(profile),
          email: cqClientEmail(profile),
        ),
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    if (await launchDoviaHomeDocument(url)) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No pudimos abrir tu presupuesto.')),
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

  /// "Información del inmueble": servicio, dirección enmascarada y fecha de la
  /// solicitud. Visible en los tres estados — la dirección exacta no se revela
  /// acá ni siquiera aprobada la cotización; eso vive en el flujo operativo,
  /// una vez que el trabajo pasa a la agenda de la empresa.
  Widget _buildPropertyInfo() {
    final data = _request;
    if (data == null) {
      return _infoBox('No encontramos el requerimiento. Vuelve a '
          '"Cotizaciones" y ábrelo de nuevo.');
    }
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del inmueble',
          style: theme.bodyMedium.override(
            font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
            color: theme.primaryText,
            fontSize: 16.0,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Servicio: ${asrServiceName(data)}\n'
          'Dirección: ${asrZone(data)}\n'
          'Fecha de la solicitud: ${cqRequestDateLabel(data)}',
          style: theme.bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: theme.primaryText,
            fontSize: 14.0,
            letterSpacing: 0.0,
            lineHeight: 1.4,
          ),
        ),
      ],
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
            cacheWidth: networkImageCacheWidth(width: 92.0, height: 92.0),
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
          borderSide:
              BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
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

  /// Caja de carga del PDF/imagen: dice qué archivo quedó elegido, para que la
  /// empresa no mande el presupuesto equivocado.
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
                file?.name ?? 'Sube el PDF o la imagen con tu presupuesto',
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

  /// Monto ya enviado, de sólo lectura (Estados 2 y 3). Si la pantalla tiene la
  /// propuesta del backend usa su monto; si el envío es el que acaba de hacer
  /// esta misma pantalla (sin haber releído el listado todavía), usa lo que
  /// tecleó — es exactamente lo que se mandó.
  String get _submittedAmountLabel {
    final proposal = _model.proposal;
    if (proposal != null) {
      return proposalAmountLabel(proposal) ?? 'Monto no disponible';
    }
    final amount = _amount;
    return amount == null
        ? 'Monto no disponible'
        : asrFormatAmount(amount, 'GTQ');
  }

  String get _submittedFileName {
    final proposal = _model.proposal;
    if (proposal != null) {
      return proposalOriginalFileName(proposal) ?? 'Presupuesto adjunto';
    }
    return _model.proposalFile?.name ?? 'Presupuesto adjunto';
  }

  String? get _submittedFileUrl {
    final proposal = _model.proposal;
    return proposal == null ? null : proposalDocumentUrl(proposal);
  }

  /// Caja de archivo de sólo lectura. Se puede abrir cuando la pantalla trae
  /// la propuesta del backend (con su URL); el envío recién hecho en esta
  /// misma sesión no tiene todavía una URL que abrir.
  Widget _buildSubmittedFile() {
    final url = _submittedFileUrl;
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
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
              _submittedFileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          if (url != null)
            Icon(
              Icons.open_in_new_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
        ],
      ),
    );

    if (url == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () => _openDocument(url),
      child: content,
    );
  }

  /// Banner del ciclo de venta: amarillo mientras espera la decisión del
  /// cliente, verde cuando ya ganó. Colores tomados de los tokens `warning` /
  /// `success` del theme, tintados — no son sólidos en el diseño.
  Widget _buildBanner({required Color background, required String text}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 13.0,
                letterSpacing: 0.0,
                lineHeight: 1.4,
              ),
        ),
      );

  Widget _buildSubmittedBanner() => _buildBanner(
        background:
            FlutterFlowTheme.of(context).warning.withValues(alpha: 0.18),
        text: 'Tu cotización fue enviada correctamente, se te enviará una '
            'notificación en caso que sea aprobada la cotización y puedas '
            'realizar el trabajo.',
      );

  Widget _buildApprovedBanner() {
    final proposal = _model.proposal;
    final dateLabel =
        proposal == null ? null : proposalDecidedDateLabel(proposal);
    final text = dateLabel == null
        ? 'Tu cotización fue aceptada. Comunícate con el cliente para '
            'realizar el trabajo.'
        : 'Tu cotización fue aceptada el día $dateLabel. Comunícate con el '
            'cliente para realizar el trabajo.';
    return _buildBanner(
      background: FlutterFlowTheme.of(context).success.withValues(alpha: 0.14),
      text: text,
    );
  }

  /// [Información del cliente]: outline aqua, deshabilitado hasta que el
  /// proyecto sea de la empresa.
  Widget _infoButton({required bool enabled}) {
    final theme = FlutterFlowTheme.of(context);
    final tint = enabled ? theme.primary : theme.alternate;
    return FFButtonWidget(
      onPressed: enabled ? _showClientInfoDialog : null,
      text: 'Información del cliente',
      options: FFButtonOptions(
        width: double.infinity,
        height: 42.0,
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: Colors.transparent,
        textStyle: theme.titleSmall.override(
          font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
          color: enabled ? theme.primary : theme.secondaryText,
          fontSize: 16.0,
          letterSpacing: 0.0,
        ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: tint, width: 1.5),
        disabledColor: Colors.transparent,
        disabledTextColor: theme.secondaryText,
      ),
    );
  }

  /// Mientras envía sigue verde, con el spinner en blanco.
  Widget _sendButton() {
    final theme = FlutterFlowTheme.of(context);
    final ready = _canSubmit || _model.isSubmitting;
    return SizedBox(
      width: double.infinity,
      height: 42.0,
      child: ElevatedButton(
        onPressed: _canSubmit ? _submit : (_model.isSubmitting ? () {} : null),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          disabledBackgroundColor: theme.primary.withValues(alpha: 0.35),
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
        child: _model.isSubmitting
            ? const DoviaSpinner(small: true, color: Colors.white)
            : Text(
                'Enviar cotización',
                style: GoogleFonts.publicSans(
                  color: ready ? Colors.white : Colors.white70,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Acciones del estado. Activa: Enviar. Enviada: un aviso de que el
  /// contacto se habilita al aceptar (un botón gris sin explicación
  /// confundía). Aprobada: Información del cliente.
  Widget _buildActions() {
    switch (_state) {
      case _QuoteState.active:
        return _sendButton();
      case _QuoteState.submitted:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0x2670ACAD),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            'Cuando el cliente acepte tu presupuesto vas a poder ver sus '
            'datos de contacto.',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              color: const Color(0xFF00444B),
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case _QuoteState.approved:
        return _infoButton(enabled: true);
    }
  }

  List<Widget> _buildBody() {
    final state = _state;
    return [
      _buildPropertyInfo(),
      const SizedBox(height: 21.0),
      _label('Lo que necesita el cliente'),
      const SizedBox(height: 12.0),
      _buildClientDescription(),
      const SizedBox(height: 21.0),
      _label('Fotos'),
      const SizedBox(height: 12.0),
      _buildClientImages(),
      const SizedBox(height: 21.0),
      _label('Indica el precio total de la cotización'),
      const SizedBox(height: 12.0),
      state == _QuoteState.active
          ? _buildAmountField()
          : _infoBox(_submittedAmountLabel),
      const SizedBox(height: 21.0),
      _label('Carga las Cotización'),
      const SizedBox(height: 12.0),
      state == _QuoteState.active ? _buildFilePicker() : _buildSubmittedFile(),
      const SizedBox(height: 21.0),
      if (state == _QuoteState.submitted) ...[
        _buildSubmittedBanner(),
        const SizedBox(height: 21.0),
      ],
      if (state == _QuoteState.approved) ...[
        _buildApprovedBanner(),
        const SizedBox(height: 21.0),
      ],
      _buildActions(),
    ];
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
                        tittleText: 'Cotizaciones',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 35.0, 20.0, 140.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildBody(),
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

/// Envoltorio que cierra el diálogo solo, pasado un tiempo de lectura. El
/// afuera también lo cierra porque `showDialog` es descartable por barrera por
/// defecto.
class _AutoCloseDialogContent extends StatefulWidget {
  const _AutoCloseDialogContent({required this.child});

  static const Duration duration = Duration(seconds: 3);

  final Widget child;

  @override
  State<_AutoCloseDialogContent> createState() =>
      _AutoCloseDialogContentState();
}

class _AutoCloseDialogContentState extends State<_AutoCloseDialogContent> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_AutoCloseDialogContent.duration, () {
      // `canPop` cubre que el usuario ya lo haya cerrado tocando afuera.
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Modal "Datos del cliente": nombre, teléfono y correo, con [Cerrar] como
/// única salida. Sólo se abre desde Estado 3 — el proyecto ya es de la
/// empresa.
class _ClientInfoDialog extends StatelessWidget {
  const _ClientInfoDialog({
    required this.name,
    required this.phone,
    required this.email,
  });

  final String name;
  final String? phone;
  final String? email;

  static const String _kUnavailable = 'No disponible';

  /// Teléfono listo para marcar: sólo dígitos y el `+` del código de país.
  String get _dialable => (phone ?? '').replaceAll(RegExp(r'[^0-9+]'), '');

  Future<void> _launch(BuildContext context, Uri uri,
      {required String error}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  Widget _contactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final primary = FlutterFlowTheme.of(context).primary;
    return SizedBox(
      height: 44.0,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18.0, color: filled ? Colors.white : primary),
        label: Text(
          label,
          style: GoogleFonts.publicSans(
            color: filled ? Colors.white : primary,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? primary : Colors.transparent,
          side: BorderSide(color: primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    Widget line(String text) => Text(
          text,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: theme.primaryText,
            fontSize: 16.0,
            letterSpacing: 0.32,
          ),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Datos del cliente',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: theme.primaryText,
              fontSize: 22.0,
              letterSpacing: 0.44,
            ),
          ),
          const SizedBox(height: 18.0),
          line(name),
          const SizedBox(height: 12.0),
          line('Número: ${phone ?? _kUnavailable}'),
          const SizedBox(height: 12.0),
          line('Correo: ${email ?? _kUnavailable}'),
          // Contacto directo con el cliente, sin copiar el número a mano.
          if (_dialable.isNotEmpty) ...[
            const SizedBox(height: 18.0),
            Row(
              children: [
                Expanded(
                  child: _contactButton(
                    context,
                    icon: Icons.call_outlined,
                    label: 'Llamar',
                    filled: false,
                    onTap: () => _launch(
                        context, Uri(scheme: 'tel', path: _dialable),
                        error: 'No se pudo abrir el teléfono'),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: _contactButton(
                    context,
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    filled: true,
                    onTap: () => _launch(
                        context,
                        Uri.parse(
                            'https://wa.me/${_dialable.replaceAll('+', '')}'),
                        error: 'No se pudo abrir WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 21.0),
          FFButtonWidget(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Cerrar',
            options: FFButtonOptions(
              width: double.infinity,
              height: 53.0,
              color: Colors.transparent,
              textStyle: theme.titleSmall.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                color: theme.primary,
                fontSize: 18.0,
                letterSpacing: 0.0,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(color: theme.primary, width: 2.0),
            ),
          ),
        ],
      ),
    );
  }
}
