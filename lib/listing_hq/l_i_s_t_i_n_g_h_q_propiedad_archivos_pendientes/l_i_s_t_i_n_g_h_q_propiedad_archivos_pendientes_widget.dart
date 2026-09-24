import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/uploaded_file.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import '/shared_components/popup_subir_documento/popup_subir_documento_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_visor_pdf/l_i_s_t_i_n_g_h_q_visor_pdf_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_model.dart';
export 'l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_model.dart';

class LISTINGHQPropiedadArchivosPendientesWidget extends StatefulWidget {
  const LISTINGHQPropiedadArchivosPendientesWidget({
    super.key,
    required this.title,
    this.visitId,
  });

  final String? title;
  final String? visitId;

  static String routeName = 'LISTING_HQ_PropiedadArchivosPendientes';
  static String routePath = '/lISTINGHQPropiedadArchivosPendientes';

  @override
  State<LISTINGHQPropiedadArchivosPendientesWidget> createState() =>
      _LISTINGHQPropiedadArchivosPendientesWidgetState();
}

class _LISTINGHQPropiedadArchivosPendientesWidgetState
    extends State<LISTINGHQPropiedadArchivosPendientesWidget> {
  late LISTINGHQPropiedadArchivosPendientesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<dynamic>>? _docsFuture;

  /// Lo que llenó el propietario al publicar. Llega en el mismo detalle de la
  /// visita que el checklist.
  Map? _property;
  Map? _owner;

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => LISTINGHQPropiedadArchivosPendientesModel());

    _docsFuture = _fetchDocs();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  // Paleta del semáforo del checklist.
  static const Color _kMissingBorder = Color(0xFFBC0000);
  static const Color _kMissingFill = Color(0xFFF8D5D5);
  static const Color _kPendingBorder = Color(0xFFE8A200);
  static const Color _kPendingFill = Color(0xFFFFF1CC);
  static const Color _kApprovedBorder = Color(0xFF249689);
  static const Color _kApprovedFill = Color(0xFFDFF1ED);

  /// Estilo de la tarjeta según el estado del documento en el checklist.
  ///
  /// - `missing` y `rejected`: rojo, hay que subir (o volver a subir) el archivo.
  /// - `submitted`: amarillo, el archivo está pero falta que LISTER_HQ lo apruebe.
  /// - `approved`: verde, listo.
  ({Color border, Color fill, Color text, String label, IconData icon})
      _docStyle(String status, bool hasFile) {
    switch (status) {
      case 'approved':
        return (
          border: _kApprovedBorder,
          fill: _kApprovedFill,
          text: _kApprovedBorder,
          label: 'Aprobado',
          icon: Icons.check_circle,
        );
      case 'rejected':
        return (
          border: _kMissingBorder,
          fill: _kMissingFill,
          text: _kMissingBorder,
          label: 'Rechazado, volver a subir',
          icon: Icons.error,
        );
      case 'submitted':
        return (
          border: _kPendingBorder,
          fill: _kPendingFill,
          text: _kPendingBorder,
          label: 'Falta aprobar',
          icon: Icons.hourglass_top,
        );
      default:
        // Sin estado explícito, la presencia del archivo decide.
        return hasFile
            ? (
                border: _kPendingBorder,
                fill: _kPendingFill,
                text: _kPendingBorder,
                label: 'Falta aprobar',
                icon: Icons.hourglass_top,
              )
            : (
                border: _kMissingBorder,
                fill: _kMissingFill,
                text: _kMissingBorder,
                label: 'Falta subir',
                icon: Icons.upload_file,
              );
    }
  }

  /// Cuenta los documentos **requeridos** por estado, que es lo que decide si
  /// la visita puede avanzar a `READY_TO_ASSIGN_OPERATIVE_LISTING`.
  ({int missing, int pending, int approved}) _requiredTally(
      List<dynamic> docs) {
    var missing = 0;
    var pending = 0;
    var approved = 0;
    for (final doc in docs) {
      if (doc is! Map) continue;
      if (doc['required'] == false) continue;
      final status = doc['status']?.toString().toLowerCase() ?? '';
      final hasFile =
          (doc['url'] ?? doc['fileUrl'])?.toString().isNotEmpty ?? false;
      if (status == 'approved') {
        approved++;
      } else if (status == 'submitted' || (status.isEmpty && hasFile)) {
        pending++;
      } else {
        missing++;
      }
    }
    return (missing: missing, pending: pending, approved: approved);
  }

  /// Banner de cabecera: dice de una si la propiedad ya puede recibir un
  /// operative lister, o qué falta para llegar ahí.
  Widget _buildChecklistSummary(List<dynamic> docs) {
    final tally = _requiredTally(docs);
    final ready = tally.missing == 0 && tally.pending == 0;

    final Color border;
    final Color fill;
    final IconData icon;
    final String title;
    final String detail;

    if (ready) {
      border = _kApprovedBorder;
      fill = _kApprovedFill;
      icon = Icons.check_circle;
      title = 'Documentación aprobada';
      detail = 'Todos los documentos requeridos están aprobados.';
    } else if (tally.missing > 0) {
      border = _kMissingBorder;
      fill = _kMissingFill;
      icon = Icons.upload_file;
      title = tally.missing == 1
          ? 'Falta subir 1 documento requerido'
          : 'Faltan subir ${tally.missing} documentos requeridos';
      detail = tally.pending == 0
          ? 'Subilos para poder aprobarlos.'
          : 'Además hay ${tally.pending} esperando aprobación.';
    } else {
      border = _kPendingBorder;
      fill = _kPendingFill;
      icon = Icons.hourglass_top;
      title = tally.pending == 1
          ? 'Falta aprobar 1 documento'
          : 'Faltan aprobar ${tally.pending} documentos';
      detail = 'Abrí cada uno y aprobalo.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border, size: 22.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: border,
                        fontSize: 14.0,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  detail,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 12.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Datos que cargó el propietario.
  // ---------------------------------------------------------------------------

  String _str(dynamic v) => v == null ? '' : v.toString().trim();

  String _money(dynamic v) {
    final n = v is num ? v : num.tryParse(_str(v));
    if (n == null) return '';
    return 'Q ${NumberFormat('#,##0', 'en_US').format(n)}';
  }

  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Finca, folio y libro destacados: con ellos el Lister HQ saca la
  /// certificación del registro.
  Widget _registryBox(Map? legal) {
    Widget cell(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 4.0),
              SelectableText(
                value.isEmpty ? '—' : value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: _kApprovedFill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _kApprovedBorder),
      ),
      child: Column(
        children: [
          Text(
            'Datos registrales',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  color: _kApprovedBorder,
                  fontSize: 13.0,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              cell('Finca', _str(legal?['finca'])),
              cell('Folio', _str(legal?['folio'])),
              cell('Libro', _str(legal?['libro'])),
            ],
          ),
        ],
      ),
    );
  }

  /// Documento que el propietario subió al publicar. Se abre solo para ver:
  /// no es parte del checklist, así que no se aprueba ni se rechaza.
  Widget _ownerDocTile(String name, String url) {
    final has = url.isNotEmpty;
    return InkWell(
      onTap: !has
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LISTINGHQVisorPdfWidget(
                    documentName: name,
                    documentUrl: url,
                    isPdf: url.toLowerCase().contains('.pdf'),
                  ),
                ),
              ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              has ? Icons.description_outlined : Icons.remove_circle_outline,
              color: has
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).secondaryText,
              size: 22.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                name,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Text(
              has ? 'Ver' : 'No lo subió',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                        fontWeight: has ? FontWeight.w600 : FontWeight.w400),
                    color: has
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Datos de la propiedad y documentos del propietario, arriba del checklist.
  List<Widget> _buildReviewHeader() {
    final p = _property;
    final legal = p?['legalInfo'] is Map ? p!['legalInfo'] as Map : null;
    final ownership = p?['ownership'] is Map ? p!['ownership'] as Map : null;
    final sale = p?['saleInfo'] is Map ? p!['saleInfo'] as Map : null;
    final rent = p?['rentInfo'] is Map ? p!['rentInfo'] as Map : null;
    final location = p?['location'] is Map ? p!['location'] as Map : null;
    final address =
        location?['address'] is Map ? location!['address'] as Map : null;
    final description =
        p?['description'] is Map ? p!['description'] as Map : null;
    final listingType = _str(p?['listingType']).toUpperCase();
    final phone = _owner?['phone'] is Map ? _owner!['phone'] as Map : null;
    final isCompany = ownership?['isCompanyOwned'] == true;

    final String operation;
    switch (listingType) {
      case 'SALE':
        operation = 'Venta';
      case 'RENT':
        operation = 'Renta';
      case '':
        operation = '';
      default:
        operation = 'Venta y renta';
    }

    return [
      _buildSectionTitle('Datos de la propiedad'),
      _card([
        _infoRow('Nombre', _str(p?['name'])),
        _infoRow('Dirección', _str(address?['fullAddress'])),
        _infoRow('Referencia', _str(address?['extra'])),
        _infoRow('Tipo', _str(p?['propertyType'])),
        _infoRow('Operación', operation),
        _infoRow('Precio de venta', _money(sale?['salePrice'])),
        _infoRow('Mantenimiento', _money(sale?['maintenanceFee'])),
        _infoRow('IUSI', _money(sale?['singlePropertyTax'])),
        _infoRow('Renta mensual', _money(rent?['monthlyRent'])),
        _infoRow(
            'Propietario',
            isCompany
                ? '${_str(ownership?['companyName'])} (empresa)'
                : _str(_owner?['fullName'])),
        if (isCompany)
          _infoRow('Representante', _str(ownership?['legalRepresentative'])),
        _infoRow(
            'Teléfono',
            phone == null
                ? ''
                : '${_str(phone['countryCode'])} ${_str(phone['number'])}'
                    .trim()),
        _infoRow('Email', _str(_owner?['email'])),
        _infoRow('Descripción', _str(description?['raw'])),
        _registryBox(legal),
      ]),
      _buildSectionTitle('Documentos que subió el propietario'),
      _card([
        _ownerDocTile(
            'DPI propietario inmueble', _str(legal?['ownerIdDocument'])),
        _ownerDocTile('Certificación de la propiedad',
            _str(legal?['propertyCertification'])),
      ]),
    ];
  }

  /// El motivo que da el backend (documento inexistente, visita de otro
  /// Lister HQ, etapa que ya no admite cambios...) en vez de un error genérico.
  String _uploadError(ApiCallResponse res, String fallback) {
    final body = res.jsonBody;
    String? detail;
    if (body is Map) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        detail = (errors.first as Map)['message']?.toString();
      }
      detail ??= body['message']?.toString();
    }
    debugPrint('[ListerHQ docs] ${res.statusCode}: ${res.bodyText}');
    return detail == null || detail.isEmpty
        ? '$fallback (HTTP ${res.statusCode})'
        : '$fallback: $detail';
  }

  /// Nombre a mostrar. Los dos DPI se nombran por quién es cada uno: el
  /// titular de la cuenta que publicó y el dueño registral del inmueble.
  String _docLabel(Map doc) {
    switch (_str(doc['type']).toLowerCase()) {
      case 'user_id':
        return 'DPI propietario cuenta';
      case 'owner_id':
        return 'DPI propietario inmueble';
    }
    final name = _str(doc['name']);
    if (name.isNotEmpty) return name;
    final label = _str(doc['label']);
    if (label.isNotEmpty) return label;
    final type = _str(doc['type']);
    return type.isNotEmpty ? type : 'Documento';
  }

  Future<List<dynamic>> _fetchDocs() async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: widget.visitId ?? '',
      authToken: token,
    );
    if (!res.succeeded) return [];

    final data = getJsonField(res.jsonBody, r'$.data');
    if (data is Map) {
      _property = data['property'] is Map ? data['property'] as Map : null;
      _owner = data['ownerProfile'] is Map ? data['ownerProfile'] as Map : null;
      // The visit details DTO nests the checklist under `visit`. Fall back to
      // the top level in case the response is unwrapped.
      final visit = data['visit'];
      final checklist = (visit is Map ? visit['documentChecklist'] : null) ??
          data['documentChecklist'];
      final docs =
          (visit is Map ? visit['documents'] : null) ?? data['documents'];

      List combined = [];
      if (checklist is List) combined.addAll(checklist);
      if (docs is List) {
        for (var doc in docs) {
          if (doc is! Map) continue;
          // Avoid duplicates if they share the same ID
          final cId = doc['id']?.toString() ?? doc['documentId']?.toString();
          if (cId != null && cId.isNotEmpty) {
            final exists = combined.any((c) {
              final existingId = c is Map
                  ? (c['id']?.toString() ?? c['documentId']?.toString())
                  : null;
              return existingId == cId;
            });
            if (!exists) {
              combined.add(doc);
            }
          } else {
            combined.add(doc);
          }
        }
      }
      return combined;
    }
    return [];
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 42.0, 20.0, 0.0),
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
                                Container(
                                  width: 35.0,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
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
                                  text: widget.title!,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                )
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
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
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        LISTINGHQBusquedaPropiedadWidget
                                            .routeName);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: SvgPicture.asset(
                                      'assets/images/search.svg',
                                      width: 8.0,
                                      height: 8.0,
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        LISTINGHQDocumentosPendientesWidget
                                            .routeName);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: SvgPicture.asset(
                                      'assets/images/folder-alertW.svg',
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FutureBuilder<List<dynamic>>(
                              future: _docsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                                final docs = snapshot.data ?? [];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ..._buildReviewHeader(),
                                    _buildSectionTitle(
                                        'Checklist de documentos'),
                                    if (docs.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 24.0),
                                        child: Center(
                                            child: Text('No hay documentos')),
                                      )
                                    else ...[
                                      _buildChecklistSummary(docs),
                                      const SizedBox(height: 20.0),
                                      Wrap(
                                        spacing: 16.0,
                                        runSpacing: 16.0,
                                        alignment: WrapAlignment.center,
                                        children: docs.map((doc) {
                                          final docMap = doc as Map;
                                          final docName = _docLabel(docMap);
                                          final String docId =
                                              docMap['id']?.toString() ??
                                                  docMap['documentId']
                                                      ?.toString() ??
                                                  docMap['type']?.toString() ??
                                                  '';
                                          final fileUrl =
                                              docMap['fileUrl']?.toString() ??
                                                  docMap['url']?.toString() ??
                                                  '';
                                          final storageKey =
                                              docMap['storageKey']
                                                      ?.toString() ??
                                                  '';
                                          final hasFile = fileUrl.isNotEmpty;
                                          final docStatus = docMap['status']
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              '';
                                          final style =
                                              _docStyle(docStatus, hasFile);
                                          final isPdfDoc = fileUrl
                                                  .toLowerCase()
                                                  .contains('.pdf') ||
                                              fileUrl
                                                  .toLowerCase()
                                                  .contains('/pdf') ||
                                              storageKey
                                                  .toLowerCase()
                                                  .contains('.pdf');

                                          return InkWell(
                                            onTap: () async {
                                              if (hasFile) {
                                                // El visor devuelve `true` cuando
                                                // aprobó o rechazó: hay que releer
                                                // el checklist para que la tarjeta
                                                // y el resumen cambien de color.
                                                final reviewed =
                                                    await Navigator.push<bool>(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LISTINGHQVisorPdfWidget(
                                                            documentName:
                                                                docName,
                                                            documentUrl:
                                                                fileUrl,
                                                            documentId: docId,
                                                            visitId:
                                                                widget.visitId,
                                                            isPdf: isPdfDoc),
                                                  ),
                                                );
                                                if (reviewed == true &&
                                                    mounted) {
                                                  setState(() {
                                                    _docsFuture = _fetchDocs();
                                                  });
                                                }
                                              } else {
                                                // Sin id el backend no encuentra el
                                                // ítem: el checklist de la visita
                                                // quedó guardado sin ids.
                                                final realId =
                                                    docMap['id']?.toString() ??
                                                        '';
                                                if (realId.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Este documento no se puede subir: el checklist de la visita no tiene identificadores. Hay que regenerarlo desde el backend.')),
                                                  );
                                                  return;
                                                }
                                                final result = await showDialog<
                                                    FFUploadedFile>(
                                                  context: context,
                                                  builder: (dialogContext) =>
                                                      Dialog(
                                                    elevation: 0,
                                                    insetPadding:
                                                        EdgeInsets.zero,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    alignment:
                                                        const AlignmentDirectional(
                                                                0.0, 0.0)
                                                            .resolve(
                                                                Directionality.of(
                                                                    context)),
                                                    child:
                                                        PopupSubirDocumentoWidget(
                                                            documentName:
                                                                docName),
                                                  ),
                                                );
                                                if (result != null &&
                                                    (result.bytes?.isNotEmpty ??
                                                        false)) {
                                                  final token =
                                                      currentAuthenticationToken ??
                                                          '';
                                                  final res =
                                                      await DOVIAAPIVisitContextGroup
                                                          .uploadDocumentCall
                                                          .call(
                                                    visitId:
                                                        widget.visitId ?? '',
                                                    documentId: docId,
                                                    authToken: token,
                                                    file: result,
                                                  );
                                                  if (res.succeeded) {
                                                    setState(() {
                                                      _docsFuture =
                                                          _fetchDocs();
                                                    });
                                                  } else {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                _uploadError(
                                                                    res,
                                                                    'Error al subir el documento'))),
                                                      );
                                                    }
                                                  }
                                                }
                                              }
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 150.0,
                                                  height: 150.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                    border: Border.all(
                                                      color: style.border,
                                                      width: 3.0,
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Text(
                                                          'PDF',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .tertiary,
                                                              ),
                                                        ),
                                                      ),
                                                      // Distintivo de estado, para
                                                      // que el color del borde se
                                                      // entienda sin depender solo
                                                      // del color.
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                1.0, -1.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: style.fill,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Icon(
                                                              style.icon,
                                                              color:
                                                                  style.border,
                                                              size: 18.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 3.0),
                                                    decoration: BoxDecoration(
                                                      color: style.fill,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      border: Border.all(
                                                          color: style.border,
                                                          width: 1.0),
                                                    ),
                                                    child: Text(
                                                      style.label,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            color: style.text,
                                                            fontSize: 11.0,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: SizedBox(
                                                    width: 150.0,
                                                    child: Text(
                                                      docName,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 40.0, 20.0, 100.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          final result = await showDialog<FFUploadedFile>(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: const AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: const PopupSubirDocumentoWidget(
                                    documentName: 'Nuevo Documento'),
                              );
                            },
                          );

                          if (result != null &&
                              (result.bytes?.isNotEmpty ?? false)) {
                            final token = currentAuthenticationToken ?? '';
                            final res = await DOVIAAPIVisitContextGroup
                                .createCustomVisitDocumentCall
                                .call(
                              visitId: widget.visitId ?? '',
                              authToken: token,
                              file: result,
                            );
                            if (res.succeeded) {
                              setState(() {
                                _docsFuture = _fetchDocs();
                              });
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(_uploadError(
                                          res, 'Error al crear el documento'))),
                                );
                              }
                            }
                          }
                        },
                        text: 'Subir documentacion de la propiedad',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 48.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
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
                    wrapWithModel(
                      model: _model.lISTINGHQNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQNavbarWidget(),
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
