import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/showing/s_h_o_w_i_n_g_navbar/s_h_o_w_i_n_g_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/showing/s_h_o_w_i_n_g_header/s_h_o_w_i_n_g_header_widget.dart';
import '/showing/s_h_o_w_i_n_g_to_navegation_app/s_h_o_w_i_n_g_to_navegation_app_widget.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_visits.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 's_h_o_w_i_n_g_propiedades_a_mostrar_model.dart';
export 's_h_o_w_i_n_g_propiedades_a_mostrar_model.dart';

class _ShowingVisit {
  final String visitId;
  final String title;
  final String address;
  final String ownerName;
  final String date;
  final String time;
  final String imageUrl;
  final String status;
  final String substatus;
  final double? lat;
  final double? lng;

  const _ShowingVisit({
    required this.visitId,
    this.title = '',
    this.address = '',
    this.ownerName = '',
    this.date = '',
    this.time = '',
    this.imageUrl = '',
    this.status = '',
    this.substatus = '',
    this.lat,
    this.lng,
  });
}

class SHOWINGPropiedadesAMostrarWidget extends StatefulWidget {
  const SHOWINGPropiedadesAMostrarWidget({super.key});

  static String routeName = 'SHOWING_PropiedadesAMostrar';
  static String routePath = '/sHOWINGPropiedadesAMostrar';

  @override
  State<SHOWINGPropiedadesAMostrarWidget> createState() =>
      _SHOWINGPropiedadesAMostrarWidgetState();
}

class _SHOWINGPropiedadesAMostrarWidgetState
    extends State<SHOWINGPropiedadesAMostrarWidget> {
  late SHOWINGPropiedadesAMostrarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<_ShowingVisit>>? _visitsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGPropiedadesAMostrarModel());
    _visitsFuture = _fetchVisits();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<List<_ShowingVisit>> _fetchVisits() async {
    final token = currentAuthenticationToken ?? '';
    final res = await DOVIAAPIVisitContextGroup.getShowingAgentVisitsCall.call(
      authToken: token,
      filter: 'upcoming',
      page: '1',
      limit: '100',
    );
    if (!res.succeeded) return [];

    final raw = getJsonField(res.jsonBody, r'$.data');
    final visits = raw is List ? raw : <dynamic>[];

    final ovFutures = visits.map((v) {
      final id = v is Map ? v['visitId']?.toString() ?? '' : '';
      return DOVIAAPIVisitContextGroup.getShowingVisitOverviewCall
          .call(authToken: token, visitId: id);
    }).toList();
    final overviews = await Future.wait(ovFutures);

    final out = <_ShowingVisit>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      String image = '';
      if (v is Map && v['property'] is Map) {
        image = (v['property'] as Map)['image']?.toString() ?? '';
      }

      String title = '';
      String address = '';
      String ownerName = '';
      double? lat;
      double? lng;
      final ov = overviews[i];
      if (ov.succeeded) {
        final data = getJsonField(ov.jsonBody, r'$.data');
        if (data is Map) {
          final prop = data['property'];
          if (prop is Map) {
            title = prop['name']?.toString() ?? prop['title']?.toString() ?? '';
            final addr = _deepMap(prop, ['location', 'address']);
            address = addr?['fullAddress']?.toString() ?? '';
            final coords = _deepValue(prop, ['location', 'geo', 'coordinates']);
            if (coords is List && coords.length >= 2) {
              lng = (coords[0] as num?)?.toDouble();
              lat = (coords[1] as num?)?.toDouble();
            }
          }
          final owner = data['ownerProfile'];
          if (owner is Map) {
            ownerName = owner['fullName']?.toString() ?? '';
          }
        }
      }

      out.add(_ShowingVisit(
        visitId: v is Map ? v['visitId']?.toString() ?? '' : '',
        title: title,
        address: address,
        ownerName: ownerName,
        imageUrl: image,
        date: _slot(v, 'date'),
        time: _slot(v, 'time'),
        status: v is Map ? v['status']?.toString() ?? '' : '',
        substatus: v is Map ? v['substatus']?.toString() ?? '' : '',
        lat: lat,
        lng: lng,
      ));
    }
    return out;
  }

  String _slot(dynamic visit, String field) {
    if (visit is! Map) return '';
    final slot = visit['confirmedTimeSlot'];
    if (slot is! Map) return '';
    return slot[field]?.toString() ?? '';
  }

  Map? _deepMap(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur is Map ? cur : null;
  }

  dynamic _deepValue(dynamic obj, List<String> keys) {
    dynamic cur = obj;
    for (final k in keys) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur;
  }

  Map<String, List<_ShowingVisit>> _groupVisits(List<_ShowingVisit> visits) {
    final grouped = <String, List<_ShowingVisit>>{};
    for (final v in visits) {
      final date = v.date.isNotEmpty ? v.date : 'Sin fecha';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(v);
    }
    
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      if (a == 'Sin fecha') return 1;
      if (b == 'Sin fecha') return -1;
      return a.compareTo(b);
    });
    
    final sortedGrouped = <String, List<_ShowingVisit>>{};
    for (final k in sortedKeys) {
      final list = grouped[k]!..sort((a, b) => a.time.compareTo(b.time));
      sortedGrouped[k] = list;
    }
    
    return sortedGrouped;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == 'Sin fecha') return 'Sin fecha';
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = parts[0];
      final monthNum = int.parse(parts[1]);
      final dayNum = int.parse(parts[2]);
      
      const months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      if (monthNum < 1 || monthNum > 12) return dateStr;
      final month = months[monthNum - 1];
      
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      if (dateStr == todayStr) {
        return 'Hoy $dayNum de $month de $year';
      } else {
        return '$dayNum de $month de $year';
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateOnly(String dateStr) {
    if (dateStr.isEmpty) return 'Sin fecha';
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = parts[0];
      final monthNum = int.parse(parts[1]);
      final dayNum = int.parse(parts[2]);
      
      const months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      if (monthNum < 1 || monthNum > 12) return dateStr;
      final month = months[monthNum - 1];
      return '$dayNum de $month de $year';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _cardImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: url.isNotEmpty
          ? Image.network(
              url,
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/casa_card_sobreMiVisita.png',
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/images/casa_card_sobreMiVisita.png',
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
    );
  }

  Future<void> _launchMap(_ShowingVisit v) async {
    if (v.lat == null || v.lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay coordenadas disponibles para esta propiedad.')),
      );
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0.0, 0.0)
              .resolve(Directionality.of(context)),
          child: const SHOWINGToNavegationAppWidget(),
        );
      },
    );
    
    if (confirm != true) return;
    
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${v.lat},${v.lng}");
    final appleMapsUrl = Uri.parse("https://maps.apple.com/?q=${v.lat},${v.lng}");
    
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        final webUrl = Uri.parse("https://www.google.com/maps/place/${v.lat},${v.lng}");
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la app de mapas: $e')),
      );
    }
  }

  Widget _buildVisitCard(_ShowingVisit visit) {
    const _primary = Color(0xFF007376);
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: _cardImage(visit.imageUrl),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.6,
              decoration: const BoxDecoration(),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${visit.title.isNotEmpty ? visit.title : "Propiedad"}\n',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                            TextSpan(
                              text: 'Dirección: ${visit.address.isNotEmpty ? visit.address : "—"}\n',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                            TextSpan(
                              text: 'Fecha: ${_formatDateOnly(visit.date)}\n',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                            TextSpan(
                              text: 'Hora: ${visit.time.isNotEmpty ? visit.time : "—"}\n',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                            TextSpan(
                              text: '${visit.ownerName.isNotEmpty ? visit.ownerName : "Sin propietario asignado"}\n',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                            ),
                          ],
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.publicSans(
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                lineHeight: 1.5,
                              ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FFButtonWidget(
                          onPressed: () => _launchMap(visit),
                          text: 'Iniciar ruta',
                          options: FFButtonOptions(
                            height: 30.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: const Color(0x00007376),
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () {
                            context.pushNamed(
                              'SHOWING_PropiedadAMostrar',
                              queryParameters: {
                                'visitId': serializeParam(visit.visitId, ParamType.String),
                              }.withoutNulls,
                            );
                          },
                          text: 'Detalles',
                          options: FFButtonOptions(
                            height: 30.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                  ),
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ].divide(const SizedBox(width: 10.0)),
        ),
      ),
    );
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
                      model: _model.sHOWINGHeaderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SHOWINGHeaderWidget(
                        title: 'Propiedades a \nmostrar',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 100.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Propiedades asignadas',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: 'Ver todo',
                                  options: FFButtonOptions(
                                    height: 30.0,
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                    iconPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).accent1,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder<List<_ShowingVisit>>(
                            future: _visitsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                                  child: Center(
                                    child: Text(
                                      'Error al cargar las visitas.',
                                      style: FlutterFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                );
                              }
                              final visits = snapshot.data!;
                              if (visits.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                                  child: Center(
                                    child: Text(
                                      'No tienes visitas programadas.',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(),
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                    ),
                                  ),
                                );
                              }

                              final grouped = _groupVisits(visits);
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: grouped.length,
                                itemBuilder: (context, index) {
                                  final dateStr = grouped.keys.elementAt(index);
                                  final dayVisits = grouped[dateStr]!;

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: const AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 20.0, 0.0, 10.0),
                                          child: Text(
                                            _formatDate(dateStr),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                      ...dayVisits.map((v) => Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                0.0, 10.0, 0.0, 10.0),
                                            child: _buildVisitCard(v),
                                          )),
                                    ],
                                  );
                                },
                              );
                            },
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

