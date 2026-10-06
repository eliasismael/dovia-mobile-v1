import 'dart:async';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_widget.dart';
import '/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propiedad_publicada/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_propiedad_publicada_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita1_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita1_model.dart';

class DOVIACLIENTMisPropiedadesVisita1Widget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesVisita1Widget({
    super.key,
    this.visitId,
  });

  final String? visitId;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_Visita_1';
  static String routePath = '/dOVIACLIENTMisPropiedadesVisita';

  @override
  State<DOVIACLIENTMisPropiedadesVisita1Widget> createState() =>
      _DOVIACLIENTMisPropiedadesVisita1WidgetState();
}

class _DOVIACLIENTMisPropiedadesVisita1WidgetState
    extends State<DOVIACLIENTMisPropiedadesVisita1Widget> {
  late DOVIACLIENTMisPropiedadesVisita1Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _teal = Color(0xFF006B6B);

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => DOVIACLIENTMisPropiedadesVisita1Model());
    _model.instructionsController = TextEditingController();
    _model.instructionsFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchVisitDetails());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// `GET /visits/{visitId}/details` responde
  /// `{ success, message, data: { visit, property, ownerProfile,
  /// operativeListing, listerHq } }`. Estos helpers desenvuelven ese sobre;
  /// el respaldo al nivel plano cubre respuestas sin envolver.
  Map<String, dynamic>? _dataMap(dynamic body) {
    if (body is! Map) return null;
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return Map<String, dynamic>.from(body);
  }

  Map<String, dynamic>? _visitMap(dynamic body) {
    final data = _dataMap(body);
    if (data == null) return null;
    final visit = data['visit'];
    return visit is Map ? Map<String, dynamic>.from(visit) : data;
  }

  Map<String, dynamic>? _sectionMap(dynamic body, String key) {
    final section = _dataMap(body)?[key];
    return section is Map ? Map<String, dynamic>.from(section) : null;
  }

  /// Estado de un ítem del `documentChecklist` de la visita
  /// (`missing` | `submitted` | `approved` | `rejected`). Cadena vacía si el
  /// ítem no está en el checklist.
  String _checklistStatus(Map<String, dynamic>? visit, String type) {
    final checklist = visit?['documentChecklist'];
    if (checklist is! List) return '';
    for (final item in checklist) {
      if (item is Map && item['type']?.toString() == type) {
        return item['status']?.toString().toLowerCase() ?? '';
      }
    }
    return '';
  }

  Future<void> _fetchVisitDetails({bool silent = false}) async {
    if (widget.visitId == null || widget.visitId!.isEmpty) return;
    if (!silent) safeSetState(() => _model.isLoading = true);
    _model.visitDetailsResponse =
        await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: widget.visitId,
      authToken: currentAuthenticationToken,
    );
    if (!mounted) return;
    final body = _model.visitDetailsResponse?.jsonBody;
    final visit = _visitMap(body);
    if (visit != null) {
      _model.instructionsController?.text =
          visit['instructions']?.toString() ?? '';

      // El convenio firmado vive en `signedContractUrl` de la visita; también
      // aparece como ítem `signed_contract` del checklist documental.
      final signedUrl = visit['signedContractUrl']?.toString() ?? '';
      const uploadedStates = {'submitted', 'approved'};
      _model.contractUploaded = signedUrl.isNotEmpty ||
          uploadedStates.contains(_checklistStatus(visit, 'signed_contract'));
    }
    if (!silent) safeSetState(() => _model.isLoading = false);

    final newStep = _currentStep(body);

    // Start polling once we land on step 3.
    if (newStep == 3) _startPolling();

    // When polling detects the property was published, show the modal once.
    if (newStep == 4 && !_model.publishedModalShown) {
      _stopPolling();
      _model.publishedModalShown = true;
      safeSetState(() {});
      await Future.microtask(() {}); // let the frame rebuild first
      if (mounted) _showPublishedModal();
    } else if (!silent) {
      safeSetState(() {});
    }
  }

  void _startPolling() {
    if (_model.pollingTimer != null && _model.pollingTimer!.isActive) return;
    _model.pollingTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _fetchVisitDetails(silent: true),
    );
  }

  void _stopPolling() {
    _model.pollingTimer?.cancel();
    _model.pollingTimer = null;
  }

  void _showPublishedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _PublishedModal(
        onSkip: () {
          Navigator.pop(context);
          context.goNamed(DOVIACLIENTMisPropiedadesWidget.routeName);
        },
        onViewMore: () {
          Navigator.pop(context);
          context.goNamed(
            DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget.routeName,
          );
        },
      ),
    );
  }

  /// Deriva el paso (1–4) del estado real de la `OPERATIVE_LISTER_VISIT`.
  ///
  /// - Paso 2 (Enlistamiento): `PENDING`, mientras se completa el checklist y
  ///   se asigna al operative lister.
  /// - Paso 3 (Preparar material): desde que hay slot confirmado
  ///   (`SCHEDULED`/`IN_PROGRESS`/`NO_SHOW`) y mientras HQ revisa las fotos
  ///   (`COMPLETED` con substatus `READY_TO_PUBLISH` o `CHANGES_REQUESTED`).
  /// - Paso 4 (Publicación): `COMPLETED` sin substatus, que es como el backend
  ///   marca la propiedad ya publicada.
  int _currentStep(dynamic body) {
    final visit = _visitMap(body);
    if (visit == null) return 2;
    final status = visit['status']?.toString() ?? '';
    final substatus = visit['substatus']?.toString() ?? '';
    switch (status) {
      case 'COMPLETED':
        return substatus.isEmpty ? 4 : 3;
      case 'PUBLISHED':
        return 4;
      case 'SCHEDULED':
      case 'IN_PROGRESS':
      case 'NO_SHOW':
        return 3;
      case 'PENDING':
      default:
        return 2;
    }
  }

  /// True cuando ya hay un operative lister asignado. El detalle expone su
  /// perfil en `data.operativeListing` (null mientras no hay asignación).
  bool _listerAssigned(dynamic body) =>
      _sectionMap(body, 'operativeListing') != null;

  Future<void> _saveInstructions() async {
    final visitId = widget.visitId?.trim();
    if (visitId == null || visitId.isEmpty || visitId == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar: esta visita no tiene un identificador válido. Volvé a Mis propiedades y abrila nuevamente.',
          ),
        ),
      );
      return;
    }

    safeSetState(() => _model.isSavingInstructions = true);
    final response =
        await DOVIAAPIVisitContextGroup.updateVisitInstructionsCall.call(
      visitId: visitId,
      authToken: currentAuthenticationToken,
      instructions: _model.instructionsController?.text ?? '',
    );
    if (!mounted) return;
    if (response.succeeded) {
      safeSetState(() {
        _model.isEditingInstructions = false;
        _model.isSavingInstructions = false;
      });
      showDialog(
        context: context,
        builder: (context) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: PopupExitoWidget(
            title: '¡Listo!',
            text: 'Tus instrucciones han sido actualizadas.',
            onContinue: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      safeSetState(() => _model.isSavingInstructions = false);
      final body = response.jsonBody;
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'No se pudieron guardar las instrucciones. Inténtalo nuevamente.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// El botón de descarga queda visible aunque no haya convenio disponible,
  /// para no dejar al propietario adivinando por qué no pasa nada.
  void _reportContractUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'El convenio todavía no está disponible para descargar. Escribinos si necesitás una copia.',
        ),
      ),
    );
  }

  Future<void> _downloadContract(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _uploadContract() async {
    final files = await selectFiles(multiFile: false);
    if (files == null || files.isEmpty) return;
    final uploaded = FFUploadedFile(
      name: files.first.storagePath.split('/').last,
      bytes: files.first.bytes,
      originalFilename: files.first.originalFilename,
    );
    safeSetState(() => _model.isUploadingContract = true);
    final res = await DOVIAAPIVisitContextGroup.uploadSignedContractCall.call(
      visitId: widget.visitId,
      authToken: currentAuthenticationToken,
      file: uploaded,
    );
    if (!mounted) return;
    safeSetState(() {
      _model.isUploadingContract = false;
      _model.contractUploaded = res.succeeded;
    });

    if (!res.succeeded) {
      final body = res.jsonBody;
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : 'No se pudo subir el convenio. Inténtalo nuevamente.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    // Releer el detalle: subir el convenio recalcula el substatus de la visita
    // y el checklist, y de eso dependen el paso del stepper y el tilde de la
    // fila del convenio.
    await _fetchVisitDetails(silent: true);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: PopupExitoWidget(
          title: '¡Subido!',
          text: 'Tu documento ha sido cargado con éxito.',
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _model.visitDetailsResponse?.jsonBody;
    final step = _currentStep(body);
    final headerTitle = step == 3 ? 'Preparar material' : 'Visita';
    final listerAssigned = _listerAssigned(body);
    final visit = _visitMap(body);

    // Convenio sin firmar que el propietario descarga, firma y vuelve a subir.
    // El detalle de la visita lo expone en `visit.unsignedContractUrl`, así que
    // está disponible en cualquier momento y desde cualquier dispositivo. Se
    // conserva la lectura a nivel de `data` como respaldo.
    final unsignedContractUrl = (visit?['unsignedContractUrl'] ??
                _dataMap(body)?['unsignedContractUrl'])
            ?.toString() ??
        '';

    // Operative Lister asignado (`data.operativeListing`) y su slot confirmado.
    final operativeListing = _sectionMap(body, 'operativeListing');
    final confirmedSlot = visit?['confirmedTimeSlot'];
    final listerName = operativeListing?['fullName']?.toString() ?? '';
    final listerPhoto = operativeListing?['avatar']?.toString() ?? '';
    final scheduledDate =
        confirmedSlot is Map ? confirmedSlot['date']?.toString() ?? '' : '';
    final scheduledTime =
        confirmedSlot is Map ? confirmedSlot['time']?.toString() ?? '' : '';
    final listerCredentialUrl =
        operativeListing?['identificationDocumentUrl']?.toString() ?? '';

    // Encargado de HQ (`data.listerHq`).
    final listerHq = _sectionMap(body, 'listerHq');

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
              if (_model.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.dOVIASHAREDHeaderModel,
                        updateCallback: () => safeSetState(() {}),
                        child: DOVIASHAREDHeaderWidget(
                          title: headerTitle,
                          showMap: false,
                          showCurrency: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 100.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Stepper ──────────────────────────────────
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: custom_widgets.ProcessState(
                                width: MediaQuery.sizeOf(context).width,
                                currentStep: step,
                              ),
                            ),

                            // ── Consideraciones (tips) ───────────────────
                            if (step == 2) ...[
                              const SizedBox(height: 16.0),
                              _ConsiderationsBox(),
                            ],

                            // ─────────────────────────────────────────────
                            // STEP 2: Enlistamiento
                            // ─────────────────────────────────────────────
                            if (step == 2) ...[
                              const SizedBox(height: 20.0),

                              // Team cards row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Operative Lister card (progressive)
                                  Expanded(
                                    child: listerAssigned
                                        ? _ListerCard(
                                            name: listerName,
                                            photoUrl: listerPhoto,
                                            date: scheduledDate,
                                            time: scheduledTime,
                                            credentialUrl: listerCredentialUrl,
                                          )
                                        : _AssigningCard(),
                                  ),
                                  const SizedBox(width: 12.0),
                                  // HQ card (always shown)
                                  Expanded(
                                    child: _HQCard(
                                      name: listerHq?['fullName']?.toString() ??
                                          '',
                                      photoUrl:
                                          listerHq?['avatar']?.toString() ?? '',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24.0),

                              // ── Instrucciones de llegada ─────────────
                              _InstructionsSectionHeader(
                                isEditing: _model.isEditingInstructions,
                                isSaving: _model.isSavingInstructions,
                                onEdit: () => safeSetState(
                                    () => _model.isEditingInstructions = true),
                                onSave: _saveInstructions,
                              ),
                              const SizedBox(height: 8.0),
                              _model.isEditingInstructions
                                  ? TextFormField(
                                      controller: _model.instructionsController,
                                      focusNode: _model.instructionsFocusNode,
                                      autofocus: true,
                                      maxLines: 5,
                                      maxLength: 1000,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Ej: Tocar el timbre 2, casa al fondo...',
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              letterSpacing: 0.0,
                                            ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                              color: _teal, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                              color: _teal, width: 1.5),
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(),
                                            letterSpacing: 0.0,
                                          ),
                                      cursorColor: _teal,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate),
                                      ),
                                      child: Text(
                                        _model.instructionsController?.text
                                                    .isEmpty ??
                                                true
                                            ? 'Sin instrucciones aún. Toca Editar para agregar.'
                                            : _model
                                                .instructionsController!.text,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color:
                                                  _model.instructionsController
                                                              ?.text.isEmpty ??
                                                          true
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),

                              const SizedBox(height: 24.0),

                              // ── Convenio Legal ───────────────────────
                              _ContractRow(
                                contractUploaded: _model.contractUploaded,
                                isUploading: _model.isUploadingContract,
                                onDownload: unsignedContractUrl.isNotEmpty
                                    ? () =>
                                        _downloadContract(unsignedContractUrl)
                                    : _reportContractUnavailable,
                                onUpload: _uploadContract,
                              ),
                            ],

                            // ─────────────────────────────────────────────
                            // STEP 3: Preparar Material
                            // ─────────────────────────────────────────────
                            if (step == 3) ...[
                              const SizedBox(height: 20.0),
                              _Step3Content(listerName: listerName),
                            ],

                            // ─────────────────────────────────────────────
                            // STEP 4: Publicación
                            // ─────────────────────────────────────────────
                            if (step >= 4) ...[
                              const SizedBox(height: 20.0),
                              _Step4Content(
                                body: body,
                                authToken: currentAuthenticationToken,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Floating chatbot icon + navbar
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 15.0, 12.0),
                        child: wrapWithModel(
                          model: _model.fixedDoviaIconModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const FixedDoviaIconWidget(),
                        ),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const DOVIACLIENTNavbarWidget(),
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

// ─── Helper widgets ────────────────────────────────────────────────────────

class _ConsiderationsBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const tealLight = Color(0xFFD2EAEB);
    const teal = Color(0xFF006B6B);
    final tips = [
      'Mantén la casa limpia y ordenada para las fotos.',
      'Asegúrate de que todas las habitaciones tengan buena iluminación.',
      'Despeja los espacios para que luzcan más amplios.',
      'Guarda objetos personales o de valor antes de la visita.',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: tealLight,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: teal, size: 18),
              const SizedBox(width: 6),
              Text(
                'Consideraciones',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: teal,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style:
                          TextStyle(color: teal, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      tip,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w400),
                            color: teal,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AssigningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline,
                size: 30, color: FlutterFlowTheme.of(context).secondaryText),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0x3370ACAD),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              'Dovia Lister',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Asignando profesional...',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w400),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}

class _ListerCard extends StatelessWidget {
  const _ListerCard({
    required this.name,
    required this.photoUrl,
    required this.date,
    required this.time,
    required this.credentialUrl,
  });

  final String name;
  final String photoUrl;
  final String date;
  final String time;
  final String credentialUrl;

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF006B6B);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: teal, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: photoUrl.isNotEmpty
                ? Image.network(photoUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/nahid_photo.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover))
                : Image.asset('assets/images/nahid_photo.png',
                    width: 72, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0x3370ACAD),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              'Dovia Lister',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name.isNotEmpty ? name : 'Profesional asignado',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                ),
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: teal),
                const SizedBox(width: 4),
                Text(date,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          letterSpacing: 0.0,
                        )),
              ],
            ),
          ],
          if (time.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 13, color: teal),
                const SizedBox(width: 4),
                Text(time,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          letterSpacing: 0.0,
                        )),
              ],
            ),
          ],
          const SizedBox(height: 10),
          FFButtonWidget(
            onPressed: credentialUrl.isNotEmpty
                ? () async {
                    final uri = Uri.tryParse(credentialUrl);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  }
                : null,
            text: 'Ver credencial',
            options: FFButtonOptions(
              width: double.infinity,
              height: 36.0,
              color: teal,
              textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    color: Colors.white,
                    letterSpacing: 0.0,
                  ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _HQCard extends StatelessWidget {
  const _HQCard({this.name = '', this.photoUrl = ''});

  final String name;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF006B6B);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: teal, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/nahid_photo.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/nahid_photo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0x3370ACAD),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              'Dovia HQ\n(Encargado)',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.isNotEmpty ? name : 'Asignando encargado...',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nuestro equipo de HQ te acompañará durante todo el proceso de publicación.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w400),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  lineHeight: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsSectionHeader extends StatelessWidget {
  const _InstructionsSectionHeader({
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onSave,
  });

  final bool isEditing;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF006B6B);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Instrucciones para la visita',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
              ),
        ),
        isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : GestureDetector(
                onTap: isEditing ? onSave : onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isEditing ? teal : Colors.transparent,
                    border: Border.all(color: teal),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    isEditing ? 'Guardar' : 'Editar',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          color: isEditing ? Colors.white : teal,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _ContractRow extends StatelessWidget {
  const _ContractRow({
    required this.contractUploaded,
    required this.isUploading,
    required this.onDownload,
    required this.onUpload,
  });

  final bool contractUploaded;
  final bool isUploading;
  final VoidCallback? onDownload;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Convenio Dovia VS Propietario',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    letterSpacing: 0.0,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              // Download button
              IconButton(
                onPressed: onDownload,
                icon: SvgPicture.asset(
                  'assets/images/descargar.svg',
                  width: 32.0,
                  height: 32.0,
                ),
                tooltip: 'Descargar convenio',
              ),
              // Upload / success check
              if (isUploading)
                const SizedBox(
                    width: 32,
                    height: 32,
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ))
              else if (contractUploaded)
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF006B6B), size: 24),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onUpload,
                      icon: SvgPicture.asset(
                        'assets/images/subir.svg',
                        width: 32.0,
                        height: 32.0,
                      ),
                      tooltip: 'Reemplazar convenio firmado',
                    ),
                  ],
                )
              else
                IconButton(
                  onPressed: onUpload,
                  icon: SvgPicture.asset(
                    'assets/images/subir.svg',
                    width: 32.0,
                    height: 32.0,
                  ),
                  tooltip: 'Subir convenio firmado',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step3Content extends StatelessWidget {
  const _Step3Content({required this.listerName});
  final String listerName;

  static const Color _teal = Color(0xFF006B6B);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Bloque de texto principal ────────────────────────────────────
        RichText(
          textScaler: MediaQuery.of(context).textScaler,
          text: TextSpan(
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.normal),
                  letterSpacing: 0.0,
                ),
            children: [
              TextSpan(
                text: 'Revisión final antes de publicar tu propiedad:\n\n',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      letterSpacing: 0.0,
                    ),
              ),
              const TextSpan(
                text:
                    'DOVIA HQ está verificando toda la información enviada por tu asociado para asegurarnos de que tu publicación sea precisa, profesional y lista para recibir compradores reales.\n\n',
              ),
              const TextSpan(
                text: 'Durante esta etapa revisamos:\n\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    '•  Datos generales de la propiedad\n•  Documentos cargados (ID, certificación, etc.)\n•  Material comercial (fotos, recorrido virtual, descripción)\n•  Precio y detalles relevantes para la publicación\n\n',
              ),
              const TextSpan(
                text:
                    'Si encontramos algún dato que necesite corregirse, te lo notificaremos aquí para que puedas actualizarlo fácilmente.\n\n',
              ),
              const TextSpan(
                text:
                    'En caso de cambios en tus documentos o autorización, generaremos una nueva versión digital para tu firma.\n\n',
              ),
              const TextSpan(
                text: '¿Tienes dudas o necesitas corregir algo?\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Escríbenos directamente desde este apartado y un miembro de DOVIA HQ te ayudará de inmediato.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 28.0),

        // ── Sección calificación ─────────────────────────────────────────
        Text(
          '¿Como te sentiste con la visita de nuestro equipo? Calificala, porque tu opinion nos importa',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 14.0),
        FFButtonWidget(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => _RatingDialog(listerName: listerName),
          ),
          text: 'Calificar',
          options: FFButtonOptions(
            width: 160.0,
            height: 44.0,
            color: _teal,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      ],
    );
  }
}

class _RatingDialog extends StatefulWidget {
  const _RatingDialog({required this.listerName});
  final String listerName;

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _sending = false;

  static const Color _teal = Color(0xFF006B6B);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Título + cierre ──────────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Califica',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        letterSpacing: 0.0,
                      ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // ── Chip "Dovia Lister" ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Text(
                'Dovia  Lister',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            const SizedBox(height: 14.0),

            // ── Nombre del lister ────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nombre Apellido: ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                          ),
                    ),
                    TextSpan(
                      text: widget.listerName.isNotEmpty
                          ? widget.listerName
                          : '—',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Vista y horario:',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            const SizedBox(height: 12.0),

            // ── Estrellas ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _rating;
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      filled ? Icons.star : Icons.star_border,
                      color: filled ? _teal : Colors.grey.shade400,
                      size: 40.0,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16.0),

            // ── Comentario opcional ──────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Si deseas, puedes dejar un comentario',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe aquí...',
                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                    ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: _teal, width: 1.5),
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    letterSpacing: 0.0,
                  ),
              cursorColor: _teal,
            ),
            const SizedBox(height: 20.0),

            // ── Botón Enviar ─────────────────────────────────────────────
            FFButtonWidget(
              onPressed: _rating == 0 || _sending
                  ? null
                  : () async {
                      setState(() => _sending = true);
                      // TODO: llamar API de rating cuando esté disponible
                      await Future.delayed(const Duration(milliseconds: 600));
                      if (context.mounted) Navigator.pop(context);
                    },
              text: _sending ? 'Enviando...' : 'Enviar',
              options: FFButtonOptions(
                width: double.infinity,
                height: 48.0,
                color: _rating == 0 ? Colors.grey.shade300 : _teal,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: _rating == 0 ? Colors.grey : Colors.white,
                      letterSpacing: 0.0,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step4Content extends StatelessWidget {
  const _Step4Content({this.body, this.authToken});
  final dynamic body;
  final String? authToken;

  @override
  Widget build(BuildContext context) {
    // Property data — el detalle la anida en `data.property`; se conserva la
    // lectura plana como respaldo para respuestas sin envolver.
    final envelope = body is Map ? body['data'] : null;
    final root = envelope is Map ? envelope : (body is Map ? body : null);
    final prop = root?['property'] is Map
        ? Map<String, dynamic>.from(root!['property'] as Map)
        : null;
    // El detalle expone la foto como `image` y el tipo como `propertyType`.
    final imageUrl =
        (prop?['image'] ?? prop?['mainImageUrl'] ?? prop?['imageUrl'] ?? '')
            .toString()
            .trim();
    final propertyName = (prop?['name'] ?? '').toString().trim();
    final propertyType = prop?['propertyType'] ?? prop?['type'];
    final saleInfo = prop?['saleInfo'];
    final rentInfo = prop?['rentInfo'];
    final price = (prop?['price'] ??
            (saleInfo is Map ? saleInfo['salePrice'] : null) ??
            (rentInfo is Map ? rentInfo['rentPrice'] : null) ??
            '')
        .toString();
    final landAreaRaw = prop?['landArea'];
    final landArea =
        landAreaRaw != null ? double.tryParse(landAreaRaw.toString()) : null;
    final propertyId = (prop?['id'] ?? '').toString().trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Published banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryText,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            'Tu propiedad ya está publicada',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).tertiary,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Información pública',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                fontSize: 16.0,
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: 250.0,
          child: custom_widgets.DoviaClientHouseCard(
            width: MediaQuery.sizeOf(context).width,
            height: 250.0,
            imageUrl: imageUrl.isNotEmpty
                ? imageUrl
                : 'https://images.unsplash.com/photo-1600596542815-27b88e57e62f?q=80&w=800&auto=format&fit=crop',
            name: propertyName.isNotEmpty ? propertyName : null,
            type: propertyType,
            price: price.isNotEmpty ? price : null,
            landArea: landArea,
            propertyId: propertyId.isNotEmpty ? propertyId : null,
            authToken: authToken,
            onAddToFavorites: () async {},
            onRemoveFromFavorites: () async {},
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Información interna Dovia',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                fontSize: 16.0,
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 12),
        const _InfoRow(label: 'Certificación registral'),
        const SizedBox(height: 12),
        const _InfoRow(label: 'Contrato firmado'),
        const SizedBox(height: 12),
        const _InfoRow(label: 'Instrucciones para asociados'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        FFButtonWidget(
          onPressed: () {},
          text: 'Ver más',
          options: FFButtonOptions(
            height: 32.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: FlutterFlowTheme.of(context).accent1,
            textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.normal),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      ],
    );
  }
}

// ── Modal: propiedad publicada ─────────────────────────────────────────────
class _PublishedModal extends StatelessWidget {
  const _PublishedModal({
    required this.onSkip,
    required this.onViewMore,
  });

  final VoidCallback onSkip;
  final VoidCallback onViewMore;

  static const Color _teal = Color(0xFF006B6B);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ícono de éxito ───────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFD2EAEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: _teal, size: 36),
            ),
            const SizedBox(height: 20),

            // ── Título ───────────────────────────────────────────────────
            Text(
              'Tu propiedad ya se publicó',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12),

            // ── Subtítulo ────────────────────────────────────────────────
            Text(
              'DOVIA HQ ya verificó la información enviada y ha publicado tu propiedad. Ya puedes ver cómo quedó.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w400),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    lineHeight: 1.5,
                  ),
            ),
            const SizedBox(height: 28),

            // ── Botones ──────────────────────────────────────────────────
            Row(
              children: [
                // Omitir (contorno)
                Expanded(
                  child: FFButtonWidget(
                    onPressed: onSkip,
                    text: 'Omitir',
                    options: FFButtonOptions(
                      height: 46.0,
                      color: Colors.transparent,
                      textStyle: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                            color: _teal,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderSide: const BorderSide(color: _teal, width: 1.5),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Ver más (sólido)
                Expanded(
                  child: FFButtonWidget(
                    onPressed: onViewMore,
                    text: 'Ver más',
                    options: FFButtonOptions(
                      height: 46.0,
                      color: _teal,
                      textStyle: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                            color: Colors.white,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
