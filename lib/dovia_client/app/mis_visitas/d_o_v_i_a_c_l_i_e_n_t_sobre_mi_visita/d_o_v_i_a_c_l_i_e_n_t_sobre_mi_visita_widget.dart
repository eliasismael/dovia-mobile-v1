import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_proveedor_card/d_h_c_l_i_e_n_t_proveedor_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import '/backend/api_requests/api_users.dart';
import '/backend/api_requests/api_properties.dart';
import '../d_o_v_i_a_c_l_i_e_n_t_ofertar/d_o_v_i_a_c_l_i_e_n_t_ofertar_widget.dart';
import '../../principal/agendar_cita/agendar_cita_widget.dart';
import 'reschedule_visit_widget.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_sobre_mi_visita_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_sobre_mi_visita_model.dart';

class DOVIACLIENTSobreMiVisitaWidget extends StatefulWidget {
  const DOVIACLIENTSobreMiVisitaWidget({
    super.key,
    required this.propertyId,
    this.visitId,
    this.showingAgentId,
  });

  final String? propertyId;
  final String? visitId;
  final String? showingAgentId;

  static String routeName = 'DOVIA_CLIENT_SobreMiVisita';
  static String routePath = '/dOVIACLIENTSobreMiVisita';

  @override
  State<DOVIACLIENTSobreMiVisitaWidget> createState() =>
      _DOVIACLIENTSobreMiVisitaWidgetState();
}

class _DOVIACLIENTSobreMiVisitaWidgetState
    extends State<DOVIACLIENTSobreMiVisitaWidget> {
  late DOVIACLIENTSobreMiVisitaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _isCancelling = false;

  String _propertyName = '';
  String _propertyImageUrl = '';
  String _address = '';
  String _visitDate = '';
  String _arrivalInstructions = '';
  String _entryInstructions = '';
  double? _lat;
  double? _lng;

  String _advisorName = '';
  String _advisorAge = '';
  String _advisorAvatarUrl = '';
  String _advisorPhone = '';
  String _advisorId = '';
  String _advisorVehicle = '';
  String _advisorLicensePlate = '';
  String _visitTime = '';
  String _visitSubstatus = '';
  bool _advisorAssigned = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTSobreMiVisitaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadData() async {
    final visitId = widget.visitId;
    if (visitId == null || visitId.isEmpty) {
      safeSetState(() => _isLoading = false);
      return;
    }

    final response = await DOVIAAPIVisitContextGroup.getVisitDetailsCall.call(
      visitId: visitId,
      authToken: currentAuthenticationToken,
    );

    if (!mounted) return;

    if (response.succeeded) {
      final body = response.jsonBody;
      final property = getJsonField(body, r'$.data.property');
      final visit = getJsonField(body, r'$.data.visit');
      // Priority: use showingAgentId passed from the list (most reliable)
      // Fallback: extract from details endpoint
      dynamic showingIdOrObj = widget.showingAgentId?.isNotEmpty == true
          ? widget.showingAgentId
          : getJsonField(body, r'$.data.showing');

      if ((showingIdOrObj == null ||
              (showingIdOrObj is String && showingIdOrObj.isEmpty)) &&
          visit is Map) {
        showingIdOrObj = visit['showing'] ??
            visit['showingAgentId'] ??
            visit['operativeListerId'] ??
            visit['listerHqId'];
      }

      Map<String, dynamic>? showingData;
      if (showingIdOrObj is Map) {
        showingData = showingIdOrObj as Map<String, dynamic>;
      } else if (showingIdOrObj is String && showingIdOrObj.isNotEmpty) {
        final showingRes =
            await DOVIAAPIUserContextGroup.getUserByIDNEWCall.call(
          userId: showingIdOrObj,
          authToken: currentAuthenticationToken,
        );
        if (showingRes.succeeded) {
          final showingBody = showingRes.jsonBody;
          final userData = getJsonField(showingBody, r'$.data');
          if (userData is Map) showingData = userData as Map<String, dynamic>;
        }
      }

      // If coordinates not populated by visit details, fetch from property API
      if (_lat == null &&
          _lng == null &&
          widget.propertyId != null &&
          widget.propertyId!.isNotEmpty) {
        final propRes =
            await DOVIAAPIPropertyContextGroup.getPropertyByIDCall.call(
          propertyId: widget.propertyId,
        );
        if (propRes.succeeded) {
          final propData = getJsonField(propRes.jsonBody, r'$.data.data') ??
              getJsonField(propRes.jsonBody, r'$.data');
          if (propData is Map) {
            final geo =
                _deepValue(propData, ['location', 'geo', 'coordinates']);
            if (geo is List && geo.length >= 2) {
              _lat = (geo[1] as num?)?.toDouble();
              _lng = (geo[0] as num?)?.toDouble();
            }
            if (_address.isEmpty) {
              _address =
                  _deepStr(propData, ['location', 'address', 'fullAddress']) ??
                      _deepStr(propData, ['location', 'address', 'street']) ??
                      '';
            }
          }
        }
      }

      safeSetState(() {
        _propertyName = _str(property, 'name') ?? _str(property, 'title') ?? '';

        final images = property is Map ? property['images'] : null;
        if (images is List && images.isNotEmpty) {
          _propertyImageUrl = images[0]['url']?.toString() ?? '';
        }

        _address = _deepStr(property, ['location', 'address', 'fullAddress']) ??
            _deepStr(property, ['location', 'address', 'street']) ??
            '';

        final slot = visit is Map ? visit['confirmedTimeSlot'] : null;
        if (slot is Map) {
          final date = slot['date']?.toString() ?? '';
          final time = slot['time']?.toString() ?? '';
          _visitDate = _formatVisitDate(date, time);
          _visitTime = time;
        }

        // Substatus for reschedule gating
        _visitSubstatus = _str(visit, 'substatus') ?? '';

        _arrivalInstructions = _str(visit, 'instructions') ?? '';
        _entryInstructions =
            _deepStr(property, ['infoHQ', 'visitorInstructions']) ?? '';

        final geo = _deepValue(property, ['location', 'geo', 'coordinates']);
        if (geo is List && geo.length >= 2) {
          _lng = (geo[0] as num?)?.toDouble();
          _lat = (geo[1] as num?)?.toDouble();
        }

        if (showingData != null && showingData.isNotEmpty) {
          _advisorAssigned = true;
          _advisorId = _str(showingData, 'id') ?? widget.showingAgentId ?? '';

          final fullNameObj = showingData['fullName'];
          if (fullNameObj is Map) {
            _advisorName =
                '${fullNameObj['name'] ?? ''} ${fullNameObj['lastname'] ?? ''}'
                    .trim();
          } else {
            _advisorName = _str(showingData, 'fullName') ??
                _str(showingData, 'name') ??
                '';
          }

          final birthDate = _str(showingData, 'birthDate') ?? '';
          if (birthDate.isNotEmpty) {
            try {
              final dob = DateTime.parse(birthDate);
              final age = DateTime.now().difference(dob).inDays ~/ 365;
              _advisorAge = age.toString();
            } catch (_) {
              _advisorAge = _str(showingData, 'age') ?? '';
            }
          } else {
            _advisorAge = _str(showingData, 'age') ?? '';
          }

          _advisorAvatarUrl = _str(showingData, 'avatar') ?? '';

          final phoneObj = showingData['phone'];
          if (phoneObj is Map) {
            _advisorPhone =
                '${phoneObj['countryCode'] ?? ''}${phoneObj['number'] ?? ''}'
                    .trim();
          } else {
            _advisorPhone = _str(showingData, 'phone') ?? '';
          }

          // Vehicle info
          final vehicleObj = showingData['vehicle'] ?? showingData['car'];
          if (vehicleObj is Map) {
            _advisorVehicle =
                '${vehicleObj['brand'] ?? ''} ${vehicleObj['model'] ?? ''}'
                    .trim();
            _advisorLicensePlate = _str(vehicleObj, 'plate') ??
                _str(vehicleObj, 'licensePlate') ??
                '';
          } else {
            _advisorVehicle = _str(showingData, 'vehicle') ?? '';
            _advisorLicensePlate = _str(showingData, 'licensePlate') ?? '';
          }
        }

        _isLoading = false;
      });
    } else {
      safeSetState(() => _isLoading = false);
    }
  }

  String? _str(dynamic obj, String key) {
    if (obj is Map) return obj[key]?.toString();
    return null;
  }

  String? _deepStr(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is Map) {
        cur = cur[k];
      } else {
        return null;
      }
    }
    return cur?.toString();
  }

  dynamic _deepValue(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is Map) {
        cur = cur[k];
      } else {
        return null;
      }
    }
    return cur;
  }

  String _formatVisitDate(String date, String time) {
    if (date.isEmpty) return '';
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final formatted = '${parts[2]}/${parts[1]}/${parts[0]}';
        return time.isNotEmpty ? '$formatted a las $time' : formatted;
      }
    } catch (_) {}
    return time.isNotEmpty ? '$date $time' : date;
  }

  Future<void> _openLocation() async {
    if (_lat != null && _lng != null) {
      // Universal geo URI — opens in any maps app the user has
      final geoUri = Uri.parse('geo:$_lat,$_lng?q=$_lat,$_lng');
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }
      // Fallback: Google Maps deep link
      final googleUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        return;
      }
    } else if (_address.isNotEmpty) {
      final encoded = Uri.encodeComponent(_address);
      final googleUri =
          Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el mapa')),
      );
    }
  }

  Future<void> _cancelVisit() async {
    final visitId = widget.visitId;
    if (visitId == null || visitId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar visita'),
        content:
            const Text('¿Estás seguro de que deseas cancelar esta visita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No, volver'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Sí, cancelar',
              style: TextStyle(color: FlutterFlowTheme.of(context).error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    safeSetState(() => _isCancelling = true);
    final response = await DOVIAAPIVisitContextGroup.cancelVisitCall.call(
      visitId: visitId,
      authToken: currentAuthenticationToken,
    );

    if (!mounted) return;
    safeSetState(() => _isCancelling = false);

    if (response.succeeded) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo cancelar la visita. Intenta de nuevo.')),
      );
    }
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
                      model: _model.dOVIASHAREDHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIASHAREDHeaderWidget(
                        title: _propertyName.isNotEmpty
                            ? 'Mi visita en $_propertyName'
                            : 'Mi visita',
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 80.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 100.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Header row: property type + Contactar button
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 53.0, 0.0, 0.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Compra',
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
                                          fontSize: 17.0,
                                          letterSpacing: 0.33,
                                          fontWeight: FontWeight.w600,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                  FFButtonWidget(
                                    onPressed: () async {
                                      final uri = Uri.parse('https://wa.me/');
                                      if (!await launchUrl(uri,
                                          mode:
                                              LaunchMode.externalApplication)) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'No se pudo abrir WhatsApp')),
                                          );
                                        }
                                      }
                                    },
                                    text: 'Contactar a DOVIA',
                                    options: FFButtonOptions(
                                      height: 40.0,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 6.0, 20.0, 6.0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: const Color(0x2E007376),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.publicSans(
                                              fontWeight: FontWeight.normal,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Property image card
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: SizedBox(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 240.0,
                                child: custom_widgets.DoviaClientHouseCard(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 240.0,
                                  imageUrl: _propertyImageUrl.isNotEmpty
                                      ? _propertyImageUrl
                                      : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dovia-td03cg/assets/kbm95ashhb4z/casa_card_sobreMiVisita.png',
                                  onAddToFavorites: () async {},
                                  onRemoveFromFavorites: () async {},
                                ),
                              ),
                            ),

                            // Address section
                            _infoSection(
                              label: 'Dirección exacta',
                              child: _address.isNotEmpty
                                  ? _infoText(_address)
                                  : _emptyText('Sin información'),
                            ),

                            // Date section
                            _infoSection(
                              label: 'Fecha de visita',
                              child: _visitDate.isNotEmpty
                                  ? _infoText(_visitDate)
                                  : _emptyText('Sin fecha confirmada'),
                            ),

                            // Arrival instructions
                            _infoSectionWithButton(
                              label: 'Instrucción para llegar',
                              content: _arrivalInstructions,
                              buttonLabel: 'Abrir ubicación',
                              onButtonPressed: _openLocation,
                            ),

                            // Entry instructions
                            _infoSection(
                              label: 'Instrucción para ingresar',
                              child: _entryInstructions.isNotEmpty
                                  ? _infoText(_entryInstructions)
                                  : _emptyText('Sin instrucciones'),
                            ),

                            // Advisor card
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 32.0, 0.0, 16.0),
                              child: wrapWithModel(
                                model: _model.dHCLIENTProveedorCardModel,
                                updateCallback: () => safeSetState(() {}),
                                child: DHCLIENTProveedorCardWidget(
                                  fullName: _advisorName,
                                  age: _advisorAge,
                                  avatarUrl: _advisorAvatarUrl,
                                  phoneNumber: _advisorPhone,
                                  isAssigned: _advisorAssigned,
                                  advisorId: _advisorId,
                                  visitDate: _visitDate,
                                  visitTime: _visitTime,
                                  vehicle: _advisorVehicle,
                                  licensePlate: _advisorLicensePlate,
                                ),
                              ),
                            ),

                            // Ofertar button
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 36.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () {
                                  context.pushNamed(
                                    DOVIACLIENTOfertarWidget.routeName,
                                    queryParameters: {
                                      'propertyId': serializeParam(
                                          widget.propertyId, ParamType.String),
                                    }.withoutNulls,
                                  );
                                },
                                text: 'Ofertar',
                                options: FFButtonOptions(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 48.0,
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
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 2.0,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),

                            // Cancel visit button
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 36.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: _isCancelling ? null : _cancelVisit,
                                text: _isCancelling
                                    ? 'Cancelando...'
                                    : 'Cancelar visita',
                                options: FFButtonOptions(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 42.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.normal,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),

                            // Reagendar button
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 18.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: Wrap(
                                          children: [
                                            RescheduleVisitWidget(
                                              visitId: widget.visitId ?? '',
                                              visitSubstatus: _visitSubstatus,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                text: 'Reagendar visita',
                                options: FFButtonOptions(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 42.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.normal,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),
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

  Widget _infoSection({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.3,
                  ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSectionWithButton({
    required String label,
    required String content,
    required String buttonLabel,
    required VoidCallback onButtonPressed,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 21.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.publicSans(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.3,
                  ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                padding: const EdgeInsetsDirectional.fromSTEB(
                    10.0, 16.0, 10.0, 16.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  content.isNotEmpty ? content : 'Sin instrucciones',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: content.isNotEmpty
                            ? FlutterFlowTheme.of(context).secondaryText
                            : FlutterFlowTheme.of(context)
                                .secondaryText
                                .withOpacity(0.5),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
              child: Align(
                alignment: const AlignmentDirectional(-1.0, 0.0),
                child: FFButtonWidget(
                  onPressed: onButtonPressed,
                  text: buttonLabel,
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 0.0),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 0.0),
                    color: const Color(0x37007376),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.publicSans(
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String text) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      padding: const EdgeInsetsDirectional.fromSTEB(10.0, 12.0, 10.0, 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color:
                  FlutterFlowTheme.of(context).secondaryText.withOpacity(0.6),
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}
