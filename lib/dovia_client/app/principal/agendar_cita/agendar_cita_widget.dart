import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'agendar_cita_model.dart';
export 'agendar_cita_model.dart';

class AgendarCitaWidget extends StatefulWidget {
  final String? propertyId;
  final bool hasPendingVisit;
  final VoidCallback? onNavigateToVisits;

  const AgendarCitaWidget({
    super.key,
    this.propertyId,
    this.hasPendingVisit = false,
    this.onNavigateToVisits,
  });

  @override
  State<AgendarCitaWidget> createState() => _AgendarCitaWidgetState();
}

class _AgendarCitaWidgetState extends State<AgendarCitaWidget> {
  late AgendarCitaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgendarCitaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      child: custom_widgets.ScheduleAppointmentWidget(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 1.0,
        propertyId: widget.propertyId,
        hasPendingVisit: widget.hasPendingVisit,
        onNavigateToVisits: widget.onNavigateToVisits,
        onAccept: () async {
          Navigator.of(context).pop();
        },
        onClose: () async {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
