import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_properties.dart';
import '/domain/listing_hq_documents.dart';
import '/domain/property_ownership_view.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/listing_hq/listing_hq_property_details.dart';
import '/listing_hq/listing_hq_ui.dart';
import '/domain/property_types.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import 'package:flutter/material.dart';
import '/shared_components/popup_subir_documento/popup_subir_documento_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_visor_pdf/l_i_s_t_i_n_g_h_q_visor_pdf_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_archivos_pendientes_model.dart';
import '/shared_components/dovia_spinner.dart';
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

  /// Dueño de la propiedad: el del detalle o, en el formato nuevo, el
  /// completo del backoffice (ver [ownershipView]).
  dynamic _ownership;

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
  static const Color _kPendingBorder = ListingHqUi.pending;
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
    final String title;
    final String detail;

    if (ready) {
      border = _kApprovedBorder;
      title = 'Documentación aprobada';
      detail = 'Todos los documentos requeridos están aprobados.';
    } else if (tally.missing > 0) {
      border = _kMissingBorder;
      title = tally.missing == 1
          ? 'Falta subir 1 documento requerido'
          : 'Faltan subir ${tally.missing} documentos requeridos';
      detail = tally.pending == 0
          ? 'Súbelos para poder aprobarlos.'
          : 'Además hay ${tally.pending} esperando aprobación.';
    } else {
      border = _kPendingBorder;
      title = tally.pending == 1
          ? 'Falta aprobar 1 documento'
          : 'Faltan aprobar ${tally.pending} documentos';
      detail = 'Abre cada uno y apruébalo.';
    }

    // Solo texto, sin fondo: el título en el color del estado.
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font:
                            GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                        color: border,
                        fontSize: 14.0,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  detail,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 13.0,
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

  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            text,
            style: ListingHqUi.sectionTitle(context),
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: ListingHqUi.cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );

  /// Orden de la pantalla: documentos del propietario, checklist y, al final,
  /// los datos de la propiedad como referencia.
  List<Widget> _buildOwnerDocs() {
    final p = _property;
    final legal = p?['legalInfo'] is Map ? p!['legalInfo'] as Map : null;
    return [
      _buildSectionTitle('Documentos que subió el propietario'),
      _card([
        ListingHqDocTile(
            name: 'DPI propietario inmueble',
            url: _str(legal?['ownerIdDocument'])),
        ListingHqDocTile(
            name: 'Certificación de la propiedad',
            url: _str(legal?['propertyCertification'])),
        // Registro de inmueble nuevo: DPI del dueño o del representante.
        for (final doc in ownershipView(_ownership).documents)
          ListingHqDocTile(name: doc.name, url: doc.url),
      ]),
    ];
  }

  List<Widget> _buildPropertyData() => [
        ListingHqPropertyDetails(
          property: _property,
          ownerProfile: _owner,
          ownership: _ownership,
        ),
      ];

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
      _ownership = _property?['ownership'];
      if (isClassifiedOwnership(_ownership)) {
        await _loadFullOwnership(data, token);
      }
      // El título (tipo y zona) está fuera del FutureBuilder.
      if (mounted) safeSetState(() {});
      return listerHqVisitDocs(data);
    }
    return [];
  }

  /// El detalle de la visita solo trae el tipo del dueño del formato nuevo:
  /// nombres y documentos vienen en el backoffice de la propiedad.
  Future<void> _loadFullOwnership(Map data, String token) async {
    final visit = data['visit'];
    final propertyId = _str(_property?['id']).isNotEmpty
        ? _str(_property?['id'])
        : _str(visit is Map ? visit['propertyId'] : null);
    if (propertyId.isEmpty) return;
    final res = await DOVIAAPIPropertyContextGroup.getPropertyBackofficeCall
        .call(propertyId: propertyId, authToken: token);
    if (!res.succeeded) {
      debugPrint(
          '[ListerHQ docs] backoffice ${res.statusCode}: ${res.bodyText}');
      return;
    }
    final full = getJsonField(res.jsonBody, r'$.data.ownership');
    if (full is Map) _ownership = full;
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
          // Sin SafeArea abajo: el contenido pasa por debajo de la barra
          // flotante hasta el borde de la pantalla.
          bottom: false,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                // Lo que ocupa el indicador de inicio (iPhone), que ya no
                // descuenta el SafeArea: el final queda sobre la barra.
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const LISTINGHQHeaderWidget(
                      titleText: 'Revisar documentación',
                    ),
                    // Tipo y zona, como en la miniatura: el nombre que
                    // escribe el propietario puede ser una descripción larga.
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 0.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          propertyShortTitle(
                            _property,
                            fallback: (widget.title ?? '').isNotEmpty
                                ? widget.title!
                                : 'Propiedad',
                          ),
                          style: GoogleFonts.publicSans(
                            color: ListingHqUi.textDark,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
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
                                    child: Center(child: DoviaSpinner()),
                                  );
                                }
                                final docs = snapshot.data ?? [];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ..._buildOwnerDocs(),
                                    _buildSectionTitle(
                                        'Checklist de documentos'),
                                    if (docs.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24.0),
                                        child: Center(
                                            child: ListingHqUi.emptyText(
                                                context,
                                                'Todavía no hay documentos en el checklist.')),
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
                                                  decoration: ListingHqUi
                                                      .cardDecoration(context),
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
                                                                font: GoogleFonts
                                                                    .publicSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                color: ListingHqUi
                                                                    .textDark,
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
                                                  child: SizedBox(
                                                    width: 150.0,
                                                    child:
                                                        ListingHqUi.statusPill(
                                                            style.label,
                                                            style.border),
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
                                                                font: GoogleFonts
                                                                    .publicSans(
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
                                    ..._buildPropertyData(),
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
                          20.0, 40.0, 20.0, 120.0),
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
                        text: 'Subir documentación de la propiedad',
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
                                    font: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                    fontSize: 16.0,
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
