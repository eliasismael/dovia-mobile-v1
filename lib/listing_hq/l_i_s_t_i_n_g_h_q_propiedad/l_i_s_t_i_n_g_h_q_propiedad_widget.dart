import '/backend/api_requests/presigned_upload.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_header/l_i_s_t_i_n_g_h_q_header_widget.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_navbar/l_i_s_t_i_n_g_h_q_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_properties.dart';
import '/backend/api_requests/api_manager.dart';
import '/domain/property_media_zones.dart';
import 'l_i_s_t_i_n_g_h_q_propiedad_model.dart';
import 'package:mime_type/mime_type.dart';
import 'package:image_picker/image_picker.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import '/shared_components/dovia_spinner.dart';
export 'l_i_s_t_i_n_g_h_q_propiedad_model.dart';

class LISTINGHQPropiedadWidget extends StatefulWidget {
  final String? visitId;

  const LISTINGHQPropiedadWidget({super.key, this.visitId});

  static String routeName = 'LISTING_HQ_Propiedad';
  static String routePath = '/lISTINGHQPropiedad';

  @override
  State<LISTINGHQPropiedadWidget> createState() =>
      _LISTINGHQPropiedadWidgetState();
}

class _LISTINGHQPropiedadWidgetState extends State<LISTINGHQPropiedadWidget> {
  late LISTINGHQPropiedadModel _model;
  Future<Map<String, dynamic>?>? _visitDetailsFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LISTINGHQPropiedadModel());

    if (widget.visitId != null && widget.visitId!.isNotEmpty) {
      _visitDetailsFuture = _fetchInitialData();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<Map<String, dynamic>?> _fetchInitialData() async {
    final token = currentAuthenticationToken ?? '';
    final response = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: widget.visitId,
      authToken: token,
    );
    if (!response.succeeded) return null;

    final data =
        getJsonField(response.jsonBody, r'$.data') as Map<String, dynamic>?;
    if (data == null) return null;

    // The property embedded in the visit details is a trimmed summary (no
    // `features`, `infoHQ` or full `images`). Fetch the full backoffice
    // property so the checklist can pre-fill rooms, characteristics, etc.
    final summaryProp =
        data['property'] is Map ? data['property'] as Map : null;
    final String? propertyId = summaryProp?['id']?.toString() ??
        summaryProp?['_id']?.toString() ??
        data['propertyId']?.toString();

    if (propertyId != null && propertyId.isNotEmpty) {
      final propRes =
          await DOVIAAPIPropertyContextGroup.getPropertyBackofficeCall.call(
        propertyId: propertyId,
        authToken: token,
      );
      if (propRes.succeeded) {
        final raw = getJsonField(propRes.jsonBody, r'$.data');
        Map<String, dynamic>? fullProp;
        if (raw is Map && raw['data'] is Map) {
          fullProp = Map<String, dynamic>.from(raw['data'] as Map);
        } else if (raw is Map) {
          fullProp = Map<String, dynamic>.from(raw);
        }
        if (fullProp != null && fullProp.isNotEmpty) {
          // Merge: keep summary fields, overlay the full backoffice data.
          data['property'] = {
            if (summaryProp != null) ...summaryProp,
            ...fullProp,
          };
        }
      }
    }

    return data;
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
                    wrapWithModel(
                      model: _model.lISTINGHQHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const LISTINGHQHeaderWidget(
                        titleText: 'Propiedad',
                      ),
                    ),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _visitDetailsFuture,
                      builder: (context, snapshot) {
                        if (widget.visitId != null &&
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: DoviaSpinner()),
                          );
                        }

                        final initialData = snapshot.data;

                        return Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 100.0),
                          child: custom_widgets.ListingHQPropiedad(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            initialData: initialData,
                            onGuardar: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Borrador guardado exitosamente.'),
                                  backgroundColor: Color(0xFF007376),
                                ),
                              );
                            },
                            onPublicar: () async {
                              if (widget.visitId != null) {
                                final res = await DOVIAAPIVisitContextGroup
                                    .publishPropertyAfterVisitCall
                                    .call(
                                  visitId: widget.visitId,
                                  authToken: currentAuthenticationToken ?? '',
                                );
                                debugPrint(
                                    '[HQ Publicar] POST /visits/${widget.visitId}/publish → ${res.statusCode}: ${res.bodyText}');
                                if (!res.succeeded) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Error al publicar la propiedad.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                              }

                              if (!context.mounted) return;

                              await showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return Dialog(
                                    elevation: 0,
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    alignment: const AlignmentDirectional(
                                            0.0, 0.0)
                                        .resolve(Directionality.of(context)),
                                    child: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(dialogContext).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: const PopupExitoWidget(
                                        title: 'Se publicó con éxito',
                                        text:
                                            'La información de la propiedad se ha publicado con éxito. Se le notificará al propietario.',
                                      ),
                                    ),
                                  );
                                },
                              );
                              // Vuelve a la lista de donde vino (Inicio,
                              // Propiedades o Checklists), que se relee al
                              // volver; sin pila, al inicio.
                              if (context.mounted) {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.goNamed('LISTING_HQ_Home');
                                }
                              }
                            },
                            onSave: (data) async {
                              final token = currentAuthenticationToken ?? '';
                              final property = initialData?['property'] is Map
                                  ? initialData!['property'] as Map
                                  : {};
                              final String? propertyId =
                                  property['id']?.toString() ??
                                      property['_id']?.toString() ??
                                      initialData?['propertyId']?.toString();
                              if (propertyId == null || propertyId.isEmpty) {
                                throw Exception(
                                    'No se pudo encontrar el ID de la propiedad.');
                              }

                              // Process and upload images
                              final rawImages =
                                  data['images'] as Map<dynamic, dynamic>?;

                              // Sección → URLs ya subidas, para que el formulario no las

                              // vuelva a subir.

                              final uploaded = <String, List<String>>{};

                              if (rawImages != null) {
                                for (final entry in rawImages.entries) {
                                  final sectionName = entry.key.toString();
                                  final files =
                                      entry.value as List<dynamic>? ?? [];
                                  final List<String> sectionUrls = [];
                                  uploaded[sectionName] = sectionUrls;

                                  final String zone =
                                      propertyZoneForSection(sectionName);

                                  final List<XFile> localFiles = [];
                                  for (final dynamic fileObj in files) {
                                    if (fileObj is XFile) {
                                      if (fileObj.path.startsWith('http://') ||
                                          fileObj.path.startsWith('https://')) {
                                        sectionUrls.add(fileObj.path);
                                      } else {
                                        localFiles.add(fileObj);
                                      }
                                    }
                                  }

                                  if (localFiles.isNotEmpty) {
                                    // New presign contract: zone, fileName, mimeType, sizeBytes.
                                    final List<Map<String, dynamic>>
                                        uploadsPayload = [];
                                    final List<String> mimeTypes = [];
                                    for (final file in localFiles) {
                                      final int sizeBytes = await file.length();
                                      // El backend no firma imágenes de más
                                      // de 10 MB: se avisa antes en vez de
                                      // mostrar su respuesta cruda.
                                      if (sizeBytes > 10 * 1024 * 1024) {
                                        throw Exception(
                                            'La foto "${file.name}" de "$sectionName" pesa más de 10 MB. Quitala y volvé a elegirla.');
                                      }
                                      String mimeType = mime(file.path) ??
                                          mime(file.name) ??
                                          'image/jpeg';
                                      if (mimeType == 'image/jpg')
                                        mimeType = 'image/jpeg';
                                      mimeTypes.add(mimeType);
                                      uploadsPayload.add({
                                        'zone': zone,
                                        'fileName': file.name,
                                        'mimeType': mimeType,
                                        'sizeBytes': sizeBytes,
                                      });
                                    }

                                    final presignRes =
                                        await DOVIAAPIPropertyContextGroup
                                            .presignPropertyImagesCall
                                            .call(
                                      propertyId: propertyId,
                                      authToken: token,
                                      uploads: uploadsPayload,
                                    );

                                    if (!presignRes.succeeded) {
                                      throw Exception(
                                          'Error al obtener URLs firmadas: ${presignRes.jsonBody}');
                                    }

                                    // Response: { data: { propertyId, items: [...] } } (con o sin envoltura `data`).
                                    final dataField = getJsonField(
                                        presignRes.jsonBody, r'$.data');
                                    final Map respMap = dataField is Map
                                        ? dataField
                                        : (presignRes.jsonBody is Map
                                            ? presignRes.jsonBody as Map
                                            : {});
                                    final presignList = (respMap['items'] ??
                                        respMap['uploads']) as List?;
                                    if (presignList == null ||
                                        presignList.isEmpty) {
                                      throw Exception(
                                          'No se devolvieron URLs firmadas.');
                                    }

                                    final List<Map<String, dynamic>>
                                        confirmPayload = [];
                                    for (int i = 0;
                                        i < localFiles.length;
                                        i++) {
                                      final localFile = localFiles[i];
                                      final presignItem = presignList[i]
                                          as Map<String, dynamic>;
                                      final uploadUrl =
                                          (presignItem['uploadUrl'] ??
                                                  presignItem['url'])
                                              ?.toString();
                                      final storageKey =
                                          (presignItem['storageKey'] ??
                                                  presignItem['key'])
                                              ?.toString();
                                      final publicUrl =
                                          (presignItem['publicUrl'] ??
                                                  presignItem['s3Url'])
                                              ?.toString();
                                      final requiredHeaders =
                                          presignItem['requiredHeaders'];

                                      if (uploadUrl == null ||
                                          storageKey == null) {
                                        throw Exception(
                                            'Falta URL de subida o storageKey.');
                                      }

                                      final bytes =
                                          await localFile.readAsBytes();

                                      // Usar exactamente los headers que pide el presign.
                                      final Map<String, String> putHeaders = {};
                                      if (requiredHeaders is Map) {
                                        requiredHeaders.forEach((k, v) =>
                                            putHeaders[k.toString()] =
                                                v.toString());
                                      }
                                      putHeaders.putIfAbsent(
                                          'Content-Type', () => mimeTypes[i]);

                                      final s3PutRes = await putPresigned(
                                        Uri.parse(uploadUrl),
                                        headers: putHeaders,
                                        body: bytes,
                                      );

                                      if (s3PutRes.statusCode < 200 ||
                                          s3PutRes.statusCode >= 300) {
                                        throw Exception(
                                            'Fallo al subir a S3: ${s3PutRes.statusCode}');
                                      }

                                      confirmPayload.add({
                                        'storageKey': storageKey,
                                        'zone': zone
                                      });

                                      final String imageUrl = publicUrl ??
                                          'https://dovia-media-dev.s3.us-east-2.amazonaws.com/$storageKey';
                                      sectionUrls.add(imageUrl);
                                    }

                                    final confirmRes =
                                        await DOVIAAPIPropertyContextGroup
                                            .confirmPropertyImagesCall
                                            .call(
                                      propertyId: propertyId,
                                      authToken: token,
                                      uploads: confirmPayload,
                                    );

                                    if (!confirmRes.succeeded) {
                                      throw Exception(
                                          'Error al confirmar imágenes: ${confirmRes.jsonBody}');
                                    }
                                  }
                                }
                              }

                              // Formato del backend. Las imágenes ya quedaron registradas con
                              // images/confirm: el PATCH no tiene `images` ni `video360Url`.
                              final Map<String, dynamic> patchPayload =
                                  Map<String, dynamic>.from(
                                      data['patchBody'] as Map);

                              debugPrint(
                                  '[HQ Publicar] PATCH /properties/$propertyId body: ${jsonEncode(patchPayload)}');

                              final patchRes =
                                  await ApiManager.instance.makeApiCall(
                                callName: 'PATCH Property Details',
                                apiUrl:
                                    '${DOVIAAPIPropertyContextGroup.getBaseUrl()}/properties/$propertyId',
                                callType: ApiCallType.PATCH,
                                headers: {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                },
                                params: {},
                                body: jsonEncode(patchPayload),
                                bodyType: BodyType.JSON,
                                returnBody: true,
                                encodeBodyUtf8: false,
                                decodeUtf8: false,
                                cache: false,
                                isStreamingApi: false,
                                alwaysAllowBody: false,
                              );

                              debugPrint(
                                  '[HQ Publicar] PATCH /properties/$propertyId → ${patchRes.statusCode}: ${patchRes.bodyText}');

                              if (!patchRes.succeeded) {
                                throw Exception(
                                    'Error al guardar datos: ${patchRes.jsonBody}');
                              }
                              return uploaded;
                            },
                          ),
                        );
                      },
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
