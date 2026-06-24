import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'porpiedades_amenidades_model.dart';
export 'porpiedades_amenidades_model.dart';

class PorpiedadesAmenidadesWidget extends StatefulWidget {
  const PorpiedadesAmenidadesWidget({
    super.key,
    this.amenities,
  });

  final Map<String, dynamic>? amenities;

  @override
  State<PorpiedadesAmenidadesWidget> createState() =>
      _PorpiedadesAmenidadesWidgetState();
}

class _PorpiedadesAmenidadesWidgetState
    extends State<PorpiedadesAmenidadesWidget> {
  late PorpiedadesAmenidadesModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PorpiedadesAmenidadesModel());

    _model.expandableExpandableController =
        ExpandableController(initialExpanded: false)
          ..addListener(() => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  List<String> getPropertyAmenities() {
    if (widget.amenities == null) return [];
    final prop = widget.amenities!['property'] as Map?;
    if (prop == null) return [];
    final list = <String>[];
    if (prop['airConditioning'] == true) list.add('A/C');
    if (prop['garden'] == true) list.add('Jardín');
    if (prop['bbqArea'] == true) list.add('Área de churrasquera');
    if (prop['islandKitchen'] == true) list.add('Cocina con isla');
    if (prop['outdoorLivingRoom'] == true) list.add('Sala de exterior');
    if (prop['bathtub'] == true) list.add('Tina');

    final extra = prop['additionalProperties'];
    if (extra is Map) {
      extra.forEach((k, v) {
        if (v == true && k != null) {
          list.add(k.toString());
        }
      });
    }
    return list;
  }

  List<String> getCommonAmenities() {
    if (widget.amenities == null) return [];
    final common = widget.amenities!['commonAreas'] as Map?;
    if (common == null) return [];
    final list = <String>[];
    if (common['pool'] == true) list.add('Piscina');
    if (common['playground'] == true) list.add('Parque de juegos');
    if (common['gym'] == true) list.add('Gimnasio');
    if (common['coworking'] == true) list.add('Coworking');
    if (common['eventHall'] == true) list.add('Salón de eventos');
    if (common['yogaDeck'] == true) list.add('Yoga Deck');
    if (common['eventKitchen'] == true) list.add('Cocina para eventos');

    final extra = common['additionalProperties'];
    if (extra is Map) {
      extra.forEach((k, v) {
        if (v == true && k != null) {
          list.add(k.toString());
        }
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final propList = getPropertyAmenities();
    final propLeft = <String>[];
    final propRight = <String>[];
    if (propList.isEmpty) {
      propLeft.add('Sin amenidades registradas');
    } else {
      for (int i = 0; i < propList.length; i++) {
        if (i % 2 == 0) {
          propLeft.add(propList[i]);
        } else {
          propRight.add(propList[i]);
        }
      }
    }

    final commonList = getCommonAmenities();
    final commonLeft = <String>[];
    final commonRight = <String>[];
    if (commonList.isEmpty) {
      commonLeft.add('Sin áreas comunes registradas');
    } else {
      for (int i = 0; i < commonList.length; i++) {
        if (i % 2 == 0) {
          commonLeft.add(commonList[i]);
        } else {
          commonRight.add(commonList[i]);
        }
      }
    }

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: const BoxDecoration(),
      child: Container(
        width: double.infinity,
        color: FlutterFlowTheme.of(context).tertiary,
        child: ExpandableNotifier(
          controller: _model.expandableExpandableController,
          child: ExpandablePanel(
            header: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: Align(
                alignment: const AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Amenidades',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ),
            ),
            collapsed: Container(
              width: 0.0,
              height: 0.0,
              decoration: const BoxDecoration(),
            ),
            expanded: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).tertiary,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Text(
                        'Propiedad',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: propLeft
                                  .map(
                                    (item) => Text(
                                      '- $item',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  )
                                  .toList()
                                  .divide(const SizedBox(height: 12.0))
                                  .addToStart(const SizedBox(height: 12.0)),
                            ),
                          ),
                          if (propRight.isNotEmpty)
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: propRight
                                    .map(
                                      (item) => Text(
                                        '- $item',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    )
                                    .toList()
                                    .divide(const SizedBox(height: 12.0))
                                    .addToStart(const SizedBox(height: 12.0)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 1.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent1,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: Text(
                          'Áreas comúnes',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: commonLeft
                                    .map(
                                      (item) => Text(
                                        '- $item',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    )
                                    .toList()
                                    .divide(const SizedBox(height: 12.0)),
                              ),
                            ),
                          ),
                        ),
                        if (commonRight.isNotEmpty)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: commonRight
                                    .map(
                                      (item) => Text(
                                        '- $item',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    )
                                    .toList()
                                    .divide(const SizedBox(height: 12.0)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            theme: const ExpandableThemeData(
              tapHeaderToExpand: true,
              tapBodyToExpand: false,
              tapBodyToCollapse: false,
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              hasIcon: true,
            ),
          ),
        ),
      ),
    );
  }
}
