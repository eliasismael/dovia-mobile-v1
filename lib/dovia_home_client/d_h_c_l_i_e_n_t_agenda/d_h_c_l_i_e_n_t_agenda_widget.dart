import '/dovia_home_client/d_h_c_l_i_e_n_t_exito_programar_agenda/d_h_c_l_i_e_n_t_exito_programar_agenda_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_homepage/d_h_c_l_i_e_n_t_homepage_widget.dart';
import '/dovia_home_client/d_h_c_l_i_e_n_t_navbar/d_h_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/d_o_v_i_a_s_h_a_r_e_d_header/d_o_v_i_a_s_h_a_r_e_d_header_widget.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import '/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'd_h_c_l_i_e_n_t_agenda_model.dart';
export 'd_h_c_l_i_e_n_t_agenda_model.dart';

class DHCLIENTAgendaWidget extends StatefulWidget {
  const DHCLIENTAgendaWidget({super.key});

  static String routeName = 'DH_CLIENT_Agenda';
  static String routePath = '/dHCLIENTAgenda';

  /// Anticipación mínima (en horas) para agendar una visita: 36h para pago por
  /// uso sin plan, 24h para clientes con suscripción. Lo fija el paso previo
  /// (valor de la visita) según cómo se pagó el servicio.
  static int minAdvanceHours = 36;

  @override
  State<DHCLIENTAgendaWidget> createState() => _DHCLIENTAgendaWidgetState();
}

class _DHCLIENTAgendaWidgetState extends State<DHCLIENTAgendaWidget> {
  late DHCLIENTAgendaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _timeSlots = [
    '6:00 - 7:00',
    '7:00 - 8:00',
    '8:00 - 9:00',
    '9:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
  ];
  static const List<String> _periods = ['AM', 'PM'];

  static const List<String> _monthsEs = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DHCLIENTAgendaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  bool get _canContinue => _model.selectedDate != null && _model.timeChosen;

  String get _selectedTimeLabel =>
      '${_timeSlots[_model.selectedSlotIndex]} ${_periods[_model.selectedPeriodIndex]}';

  String _formatDate(DateTime d) =>
      '${d.day} ${_monthsEs[d.month - 1]} ${d.year}';

  Future<void> _pickDate() async {
    // Respeta la anticipación mínima (36h sin plan / 24h con suscripción).
    final firstDate =
        DateTime.now().add(Duration(hours: DHCLIENTAgendaWidget.minAdvanceHours));
    final picked = await showDatePicker(
      context: context,
      initialDate: _model.selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: FlutterFlowTheme.of(context).primary,
            onPrimary: Colors.white,
            onSurface: const Color(0xFF00444B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      safeSetState(() => _model.selectedDate = picked);
    }
  }

  Widget _buildSelectorRow({
    required String label,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              blurRadius: 7.0,
              color: Color(0x21000000),
              offset: Offset(0.0, 0.0),
            )
          ],
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(18.0, 0.0, 12.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                      color: const Color(0xFF00444B),
                      fontSize: 16.0,
                    ),
              ),
            ),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.chevron_right_rounded,
              color: const Color(0xFF00444B),
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWheel() {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 13.0, 0.0, 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14.0,
            color: Color(0x21000000),
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: SizedBox(
        height: 142.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: _model.selectedSlotIndex),
                itemExtent: 40.0,
                diameterRatio: 1.3,
                selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                  background: Color(0x00000000),
                ),
                onSelectedItemChanged: (index) => safeSetState(() {
                  _model.selectedSlotIndex = index;
                  _model.timeChosen = true;
                }),
                children: _timeSlots
                    .map((s) => Center(
                          child: Text(
                            s,
                            style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: const Color(0xFF454545),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              width: 70.0,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: _model.selectedPeriodIndex),
                itemExtent: 40.0,
                diameterRatio: 1.3,
                selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                  background: Color(0x00000000),
                ),
                onSelectedItemChanged: (index) => safeSetState(() {
                  _model.selectedPeriodIndex = index;
                  _model.timeChosen = true;
                }),
                children: _periods
                    .map((p) => Center(
                          child: Text(
                            p,
                            style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: const Color(0xFF454545),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
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
        body: Stack(
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
                      title: 'Agenda',
                      showCurrency: false,
                      showMap: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 24.0, 20.0, 100.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Selecciona fecha y hora para tu servicio',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w600),
                                color: const Color(0xFF00444B),
                                fontSize: 17.0,
                                letterSpacing: 0.3,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 6.0, 0.0, 0.0),
                          child: Text(
                            'Agenda disponible con ${DHCLIENTAgendaWidget.minAdvanceHours} hs de anticipación para DOVIA BASIC.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 13.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.4,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSelectorRow(
                                  label: _model.selectedDate == null
                                      ? 'Selecciona la fecha'
                                      : _formatDate(_model.selectedDate!),
                                  expanded: false,
                                  onTap: _pickDate,
                                ),
                                const SizedBox(height: 13.0),
                                _buildSelectorRow(
                                  label: _model.timeChosen
                                      ? _selectedTimeLabel
                                      : 'Selecciona la hora',
                                  expanded: _model.timeExpanded,
                                  onTap: () => safeSetState(() {
                                    _model.timeExpanded = !_model.timeExpanded;
                                    if (_model.timeExpanded) {
                                      _model.timeChosen = true;
                                    }
                                  }),
                                ),
                                if (_model.timeExpanded) _buildTimeWheel(),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 40.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: _canContinue
                                ? () async {
                                    // Registra la solicitud y la agrega a
                                    // "Próximas visitas" del Dashboard con
                                    // estatus Pendiente.
                                    // TODO: POST de la solicitud al backend para
                                    // que busque y asigne un Home Associate.
                                    DHCLIENTHomepageWidget.upcomingVisits.insert(
                                      0,
                                      ScheduledVisit(
                                        service: DHCLIENTInstalacionWidget
                                            .serviceTitle,
                                        date: _formatDate(_model.selectedDate!),
                                        time: _selectedTimeLabel,
                                      ),
                                    );
                                    await showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return const Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child:
                                              DHCLIENTExitoProgramarAgendaWidget(),
                                        );
                                      },
                                    );
                                    // Al cerrarse el modal (auto o al tapear
                                    // fuera) redirige al Dashboard principal.
                                    if (context.mounted) {
                                      context.goNamed(
                                          DHCLIENTHomepageWidget.routeName);
                                    }
                                  }
                                : null,
                            text: 'Enviar',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 50.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              disabledColor: const Color(0xFFDFDFDF),
                              disabledTextColor: const Color(0xFF6A6A6A),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    letterSpacing: 0.34,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(100.0),
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
                  Align(
                    alignment: const AlignmentDirectional(1.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 15.0, 100.0),
                      child: wrapWithModel(
                        model: _model.fixedDoviaIconModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const FixedDoviaIconWidget(),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.dHCLIENTNavbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const DHCLIENTNavbarWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
