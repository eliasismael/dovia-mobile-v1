import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita_1/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_visita1_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/popup_exito/popup_exito_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_agendar_visita_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_mis_propiedades_agendar_visita_model.dart';

class DOVIACLIENTMisPropiedadesAgendarVisitaWidget extends StatefulWidget {
  const DOVIACLIENTMisPropiedadesAgendarVisitaWidget({
    super.key,
    this.propertyId,
  });

  final String? propertyId;

  static String routeName = 'DOVIA_CLIENT_MisPropiedades_AgendarVisita';
  static String routePath = '/dOVIACLIENTMisPropiedadesAgendarVisita';

  @override
  State<DOVIACLIENTMisPropiedadesAgendarVisitaWidget> createState() =>
      _DOVIACLIENTMisPropiedadesAgendarVisitaWidgetState();
}

class _DOVIACLIENTMisPropiedadesAgendarVisitaWidgetState
    extends State<DOVIACLIENTMisPropiedadesAgendarVisitaWidget> {
  late DOVIACLIENTMisPropiedadesAgendarVisitaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _dayLabels = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  // Colors matching DOVIA Teal primary
  static const Color _teal = Color(0xFF006B6B);

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => DOVIACLIENTMisPropiedadesAgendarVisitaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    final h12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '${h12.toString().padLeft(2, '0')}:$m $period';
  }

  String _timeToApi(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime({required bool isFrom}) async {
    final initial = isFrom
        ? (_model.timeFrom ?? const TimeOfDay(hour: 9, minute: 0))
        : (_model.timeTo ?? const TimeOfDay(hour: 12, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );

    if (picked == null) return;

    if (isFrom) {
      _model.timeFrom = picked;
    } else {
      // Validate: "Hasta" must be after "Desde"
      if (_model.timeFrom != null) {
        final fromMinutes =
            _model.timeFrom!.hour * 60 + _model.timeFrom!.minute;
        final toMinutes = picked.hour * 60 + picked.minute;
        if (toMinutes <= fromMinutes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'La hora de finalización debe ser posterior a la de inicio'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      _model.timeTo = picked;
    }
    safeSetState(() {});
  }

  Future<void> _onContinuar() async {
    if (!_model.canContinue) return;

    final List<String> dayNames = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];

    final sortedDays = _model.selectedDays.toList()..sort();
    final startTimeStr = _timeToApi(_model.timeFrom!);
    final endTimeStr = _timeToApi(_model.timeTo!);

    final ranges = sortedDays
        .map((dayIndex) => {
              'dayOfWeek': dayNames[dayIndex],
              'startTime': startTimeStr,
              'endTime': endTimeStr,
            })
        .toList();

    _model.apiResCreateVisitRequest =
        await DOVIAAPIVisitContextGroup.createOperativeListingVisitCall.call(
      propertyId: widget.propertyId,
      authToken: currentAuthenticationToken,
      ranges: ranges,
    );

    if (!mounted) return;

    if (_model.apiResCreateVisitRequest?.succeeded ?? false) {
      final visitId = DOVIAAPIVisitContextGroup.createOperativeListingVisitCall
          .visitId(_model.apiResCreateVisitRequest!.jsonBody);
      if (visitId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'La visita fue creada, pero no se recibió su identificador. Volvé a Mis propiedades e inténtalo nuevamente.',
            ),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
        safeSetState(() {});
        return;
      }
      showDialog(
        context: context,
        builder: (context) => Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: PopupExitoWidget(
            title: '¡Listo!',
            text: 'Tu visita ha sido agendada con éxito.',
            continueText: 'Ir a seguimiento',
            onContinue: () {
              Navigator.pop(context);
              context.pushNamed(
                DOVIACLIENTMisPropiedadesVisita1Widget.routeName,
                queryParameters: {
                  'visitId': visitId,
                },
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al agendar la visita. Intenta de nuevo.',
            style: FlutterFlowTheme.of(context)
                .bodyMedium
                .override(font: GoogleFonts.inter()),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
    safeSetState(() {});
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
                      child: const DOVIASHAREDHeaderWidget(
                        title: 'Agenda tu visita',
                        showMap: false,
                        showCurrency: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 20.0, 20.0, 120.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Explanatory text
                          Text(
                            'Selecciona días y rangos horarios en los que te encuentres disponible a partir de la próxima semana para realizar la visita y preparar los materiales.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w400,
                                  ),
                                  letterSpacing: 0.0,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  lineHeight: 1.5,
                                ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Este contenido nos permite presentar tu propiedad con la mejor calidad posible y atraer compradores reales.',
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      lineHeight: 1.5,
                                    ),
                          ),

                          const SizedBox(height: 20.0),

                          // 5 bullet points
                          const _BulletPoint(
                              icon: Icons.camera_alt_outlined,
                              text: 'Fotos profesionales'),
                          const SizedBox(height: 10.0),
                          const _BulletPoint(
                              icon: Icons.vrpano_outlined,
                              text: 'Recorrido virtual'),
                          const SizedBox(height: 10.0),
                          const _BulletPoint(
                              icon: Icons.architecture_outlined, text: 'Plano'),
                          const SizedBox(height: 10.0),
                          const _BulletPoint(
                              icon: Icons.location_on_outlined,
                              text:
                                  'Descripción de tu propiedad y del entorno'),
                          const SizedBox(height: 10.0),
                          const _BulletPoint(
                              icon: Icons.star_outline,
                              text: 'Elaboración de gancho de venta'),

                          const SizedBox(height: 28.0),

                          // Day selector label
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Seleccione los días que tiene disponibilidad ',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                const TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Day chips row
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: List.generate(7, (index) {
                              final isSelected =
                                  _model.selectedDays.contains(index);
                              final isSunday = index == 6;
                              return GestureDetector(
                                onTap: isSunday
                                    ? null
                                    : () {
                                        safeSetState(() {
                                          if (isSelected) {
                                            _model.selectedDays.remove(index);
                                          } else {
                                            _model.selectedDays.add(index);
                                          }
                                        });
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _teal.withOpacity(0.1)
                                        : isSunday
                                            ? FlutterFlowTheme.of(context)
                                                .alternate
                                            : FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                    border: Border.all(
                                      color: isSelected
                                          ? _teal
                                          : isSunday
                                              ? FlutterFlowTheme.of(context)
                                                  .secondaryText
                                                  .withOpacity(0.3)
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText
                                                  .withAlpha(128),
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    _dayLabels[index],
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                          color: isSelected
                                              ? _teal
                                              : isSunday
                                                  ? FlutterFlowTheme.of(context)
                                                      .secondaryText
                                                      .withOpacity(0.4)
                                                  : FlutterFlowTheme.of(context)
                                                      .primaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 24.0),

                          // Time range label
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Seleccione el rango horario que tiene disponibilidad ',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                const TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Time pickers row
                          Row(
                            children: [
                              Expanded(
                                child: _TimePickerField(
                                  label: 'Desde',
                                  value: _formatTime(_model.timeFrom),
                                  hasValue: _model.timeFrom != null,
                                  onTap: () => _pickTime(isFrom: true),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: _TimePickerField(
                                  label: 'Hasta',
                                  value: _formatTime(_model.timeTo),
                                  hasValue: _model.timeTo != null,
                                  onTap: () => _pickTime(isFrom: false),
                                ),
                              ),
                            ],
                          ),

                          // Time validation error (only when times are set but range is invalid)
                          if (_model.timeFrom != null &&
                              _model.timeTo != null &&
                              (_model.timeTo!.hour * 60 +
                                      _model.timeTo!.minute) <=
                                  (_model.timeFrom!.hour * 60 +
                                      _model.timeFrom!.minute))
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                'La hora de finalización debe ser posterior a la de inicio',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context).error,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),

                          const SizedBox(height: 28.0),

                          // Trust info box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dovia se pondrá en contacto para confirmar la fecha y la hora exacta de la visita, te enviaremos los datos del asociado',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                const SizedBox(height: 6.0),
                                Text(
                                  'Antes de la visita recibirás su nombre, fotografía y número de contacto. Además, junto con esta información te compartiremos el acuerdo de autorización de comercialización.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w400),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32.0),

                          // Continue button
                          FFButtonWidget(
                            onPressed: _model.canContinue ? _onContinuar : null,
                            text: 'Continuar',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              color: _model.canContinue
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context).alternate,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    color: _model.canContinue
                                        ? Colors.white
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(10.0),
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
                child: wrapWithModel(
                  model: _model.dOVIACLIENTNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const DOVIACLIENTNavbarWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bullet point helper widget
class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.0, color: FlutterFlowTheme.of(context).primary),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w400),
                  letterSpacing: 0.0,
                ),
          ),
        ),
      ],
    );
  }
}

// Time picker field helper widget
class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          border: Border.all(
            color: hasValue
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            width: hasValue ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 18.0,
              color: hasValue
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w400),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 11.0,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                            fontWeight:
                                hasValue ? FontWeight.w600 : FontWeight.w400),
                        color: hasValue
                            ? FlutterFlowTheme.of(context).primaryText
                            : FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
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
