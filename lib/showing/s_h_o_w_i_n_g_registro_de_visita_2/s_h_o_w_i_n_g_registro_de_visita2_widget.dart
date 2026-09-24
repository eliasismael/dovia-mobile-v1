import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_properties.dart';
import '/domain/offer_json.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/showing/s_h_o_w_i_n_g_visit_registered_popup/s_h_o_w_i_n_g_visit_registered_popup_widget.dart';
import '/showing/s_h_o_w_i_n_g_report_popup/s_h_o_w_i_n_g_report_popup_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 's_h_o_w_i_n_g_registro_de_visita2_model.dart';
export 's_h_o_w_i_n_g_registro_de_visita2_model.dart';

class SHOWINGRegistroDeVisita2Widget extends StatefulWidget {
  const SHOWINGRegistroDeVisita2Widget({super.key, this.visitId});

  final String? visitId;

  static String routeName = 'SHOWING_RegistroDeVisita_2';
  static String routePath = '/sHOWINGRegistroDeVisita2';

  @override
  State<SHOWINGRegistroDeVisita2Widget> createState() =>
      _SHOWINGRegistroDeVisita2WidgetState();
}

class _SHOWINGRegistroDeVisita2WidgetState
    extends State<SHOWINGRegistroDeVisita2Widget> {
  late SHOWINGRegistroDeVisita2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<ApiCallResponse>? _overviewFuture;

  /// Propiedad completa: el overview no trae nombre, foto ni precio.
  Map? _propData;

  Future<void> _loadProperty() async {
    final ov = await _overviewFuture;
    final pid = ov != null && ov.succeeded
        ? getJsonField(ov.jsonBody, r'$.data.property.id')?.toString()
        : null;
    if (pid == null || pid.isEmpty) return;
    final res = await DOVIAAPIPropertyContextGroup.getPropertyByIDCall
        .call(propertyId: pid);
    if (!res.succeeded || !mounted) return;
    final d = getJsonField(res.jsonBody, r'$.data.data') ??
        getJsonField(res.jsonBody, r'$.data');
    if (d is Map) safeSetState(() => _propData = d);
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGRegistroDeVisita2Model());
    if (widget.visitId != null && widget.visitId!.isNotEmpty) {
      _overviewFuture =
          DOVIAAPIVisitContextGroup.getShowingVisitOverviewCall.call(
        authToken: currentAuthenticationToken,
        visitId: widget.visitId,
      );
      _loadProperty();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _onCancelVisit() async {
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const SHOWINGReportPopupWidget(
            title: 'Visita no realizada',
            subtitle: 'Por favor, describe por qué no se realizó la visita',
          ),
        );
      },
    );
    if (message == null || message.trim().isEmpty) return;

    final visitId = widget.visitId ?? '';
    final res = await DOVIAAPIVisitContextGroup.showingReportProblemCall.call(
      authToken: currentAuthenticationToken,
      visitId: visitId,
      message: message.trim(),
    );
    if (!mounted) return;

    if (res.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Visita cancelada.',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      context.safePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo reportar el problema.')),
      );
    }
  }

  // Submit the showing visit report (POST /visits/{visitId}/showing/report).
  Future<void> _submitReport(Map<String, dynamic> data) async {
    final visitId = widget.visitId ?? '';
    if (visitId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró la visita a registrar.')),
      );
      return;
    }

    final photos = data['photos'] as List?;
    if (photos != null && photos.isNotEmpty) {
      // 1. Presign
      final uploadsReq = photos.asMap().entries.map((e) {
        final i = e.key;
        final p = e.value;
        return {
          'fileName': p.name ?? 'foto_$i.jpg',
          'mimeType': 'image/jpeg',
          'sizeBytes': p.bytes?.length ?? 0,
          'clientUploadId': 'upload_$i',
        };
      }).toList();

      final presignRes =
          await DOVIAAPIVisitContextGroup.presignShowingReportEvidenceCall.call(
        visitId: visitId,
        authToken: currentAuthenticationToken,
        uploads: uploadsReq,
      );

      if (!presignRes.succeeded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al preparar subida de fotos.')),
          );
        }
        return;
      }

      final items = getJsonField(presignRes.jsonBody, r'$.data.items');
      if (items is List) {
        // 2. Upload to S3
        for (final item in items) {
          final clientId = item['clientUploadId'];
          final uploadUrl = item['uploadUrl'];

          // find matching photo
          final pIndex =
              int.tryParse(clientId.toString().replaceAll('upload_', '')) ?? 0;
          final pBytes = photos[pIndex].bytes;

          if (pBytes != null && uploadUrl != null) {
            await http.put(
              Uri.parse(uploadUrl.toString()),
              headers: {'Content-Type': 'image/jpeg'},
              body: pBytes,
            );
          }
        }

        // 3. Confirm
        final confirmReq = items
            .map((item) => {
                  'storageKey': item['storageKey'],
                  'clientUploadId': item['clientUploadId'],
                })
            .toList();

        final confirmRes = await DOVIAAPIVisitContextGroup
            .confirmShowingReportEvidenceCall
            .call(
          visitId: visitId,
          authToken: currentAuthenticationToken,
          uploads: confirmReq,
        );

        if (!confirmRes.succeeded) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Error al confirmar fotos subidas.')),
            );
          }
          return;
        }
      }
    }

    // 4. Submit Report
    final res = await DOVIAAPIVisitContextGroup.submitShowingReportCall.call(
      authToken: currentAuthenticationToken,
      visitId: visitId,
      showingVisitKind: data['showingVisitKind'] as String?,
      showingVisitDuration: data['showingVisitDuration'] as String?,
      additionalAttendees: data['additionalAttendees'] as String?,
      propertyCondition: data['propertyCondition'] as String?,
      clientInterestLevel: data['clientInterestLevel'] as String?,
      overallRating: data['overallRating'] as int?,
      mainReason: data['mainReason'] as String?,
      nextStep: data['nextStep'] as String?,
      comments: data['comments'] as String? ?? '',
      confirmationAccepted: data['confirmationAccepted'] as bool? ?? false,
    );
    if (!mounted) return;

    if (res.succeeded) {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: const AlignmentDirectional(0.0, 0.0)
                .resolve(Directionality.of(context)),
            child: const SHOWINGVisitRegisteredPopupWidget(),
          );
        },
      );
      if (mounted) context.safePop();
    } else {
      final msg = res.statusCode == 409
          ? 'El reporte de esta visita ya fue enviado.'
          : 'No se pudo registrar la visita. Inténtalo de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
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
                      model: _model.sHOWINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: SHOWINGHeaderWidget(
                        title: 'Registro de visita',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 40.0, 20.0, 100.0),
                      child: FutureBuilder<ApiCallResponse>(
                        future: _overviewFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final res = snapshot.data!;
                          if (!res.succeeded) {
                            return const Center(
                                child: Text(
                                    'Error al cargar la información de la visita.'));
                          }

                          final data = getJsonField(res.jsonBody, r'$.data');
                          String title = 'Propiedad';
                          String propertyType = 'Tipo';
                          String price = '';
                          String specs = '';
                          String imageUrl = '';
                          String ownerName = 'Cliente';
                          String dateText = '';
                          String timeText = '';

                          if (data is Map) {
                            // Overview + propiedad completa (nombre, foto).
                            final prop = {
                              if (data['property'] is Map)
                                ...data['property'] as Map,
                              if (_propData != null) ..._propData!,
                            };
                            if (prop.isNotEmpty) {
                              title = prop['name']?.toString() ??
                                  prop['title']?.toString() ??
                                  'Propiedad';

                              final lt = prop['listingType'];
                              propertyType = (lt is List && lt.isNotEmpty)
                                  ? lt[0].toString()
                                  : prop['propertyType']?.toString() ?? 'Tipo';

                              final priceVal = prop['price'] ??
                                  prop['saleInfo']?['salePrice'];
                              price = priceVal?.toString() ?? '';

                              imageUrl = firstPropertyPhotoUrl(
                                      Map<String, dynamic>.from(prop)) ??
                                  prop['image']?.toString() ??
                                  '';

                              String buildSize = '-';
                              String bedrooms = '-';
                              String bathrooms = '-';

                              final general =
                                  prop['features']?['general'] as Map?;
                              if (general != null) {
                                bedrooms =
                                    general['bedrooms']?.toString() ?? '-';
                                bathrooms =
                                    general['bathrooms']?.toString() ?? '-';
                                buildSize =
                                    general['constructionArea']?.toString() ??
                                        general['landArea']?.toString() ??
                                        '-';
                              }

                              // Sin "-" sueltos cuando faltan datos.
                              specs = [
                                if (buildSize != '-') '$buildSize M2',
                                if (bedrooms != '-') '$bedrooms Habitaciones',
                                if (bathrooms != '-') '$bathrooms Baños',
                              ].join(' - ');
                            }
                            // El cliente es quien pidió la visita
                            // (`requester`), no el propietario.
                            final client = data['requester'];
                            if (client is Map) {
                              ownerName =
                                  client['fullName']?.toString() ?? 'Cliente';
                            }
                            final visitMap = data['visit'] is Map
                                ? data['visit'] as Map
                                : {};
                            final slot = data['confirmedTimeSlot'] ??
                                data['confirmedSlot'] ??
                                visitMap['confirmedTimeSlot'] ??
                                visitMap['confirmedSlot'];
                            if (slot is Map) {
                              dateText = slot['date']?.toString() ?? '';
                              timeText = slot['time']?.toString() ?? '';
                            }
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            10.0, 10.0, 10.0, 10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: imageUrl.isNotEmpty
                                                ? Image.network(
                                                    imageUrl,
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/images/casa_card_sobreMiVisita.png',
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 20.0, 0.0, 0.0),
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                1.0,
                                            decoration: const BoxDecoration(),
                                            child: IntrinsicWidth(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child: RichText(
                                                      textScaler:
                                                          MediaQuery.of(context)
                                                              .textScaler,
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: '$title\n',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                '$propertyType\n',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                          ),
                                                          TextSpan(
                                                            text: 'Q$price\n',
                                                          ),
                                                          TextSpan(
                                                            text: specs,
                                                          )
                                                        ],
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .publicSans(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                              ),
                                                              lineHeight: 1.5,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Sin alto fijo: un solo scroll, el de la pantalla.
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                child:
                                    custom_widgets.ShowingRegistroVisitaDatos(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  propertyName: title,
                                  clientName: ownerName,
                                  dateText: dateText,
                                  timeText: timeText,
                                  onCancelVisit: () => _onCancelVisit(),
                                  onSave: (data) => _submitReport(
                                      data as Map<String, dynamic>),
                                  onFinalizarRegistro: () async {},
                                ),
                              ),
                            ],
                          );
                        },
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
                      model: _model.sHOWINGNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGNavbarWidget(),
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
