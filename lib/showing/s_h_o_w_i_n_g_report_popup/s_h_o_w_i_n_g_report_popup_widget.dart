import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 's_h_o_w_i_n_g_report_popup_model.dart';
export 's_h_o_w_i_n_g_report_popup_model.dart';

class SHOWINGReportPopupWidget extends StatefulWidget {
  const SHOWINGReportPopupWidget({
    super.key,
    this.title = '¿Qué problema tuviste en la visita?',
    this.subtitle = 'Cuéntanos brevemente qué pasó.',
  });

  final String title;
  final String subtitle;

  @override
  State<SHOWINGReportPopupWidget> createState() =>
      _SHOWINGReportPopupWidgetState();
}

class _SHOWINGReportPopupWidgetState extends State<SHOWINGReportPopupWidget> {
  late SHOWINGReportPopupModel _model;

  static const Color reportRed = Color(0xFFC90A0A);
  static const Color _textDark = Color(0xFF00444B);
  static const Color _grey = Color(0xFF717182);
  static const Color _aqua = Color(0xFF007376);

  // Error mostrado cuando se intenta enviar el reporte sin escribir una nota.
  String? _errorText;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SHOWINGReportPopupModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  /// Botón de pie del modal. Los colores van en el TextStyle: dentro de
  /// `font:` el override sólo toma la tipografía, y así "Enviar reporte"
  /// salía con el texto oscuro sobre el rojo.
  Widget _button({
    required String text,
    required VoidCallback onPressed,
    required bool filled,
  }) {
    final color = filled ? reportRed : _aqua;
    return SizedBox(
      height: 46.0,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: filled ? color : Colors.white,
          foregroundColor: filled ? Colors.white : color,
          side: filled ? null : BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.publicSans(
            color: filled ? Colors.white : color,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Mismo diseño que los demás modales de DOVIA: blanco, título verde
  /// oscuro, texto gris y botones redondeados.
  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(24.0, 28.0, 24.0, 24.0),
            // Sin X: se cierra con "Cancelar".
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.publicSans(
                          color: _textDark,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.publicSans(
                          color: _grey,
                          fontSize: 14.0,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _model.textController,
                        focusNode: _model.textFieldFocusNode,
                        maxLines: 5,
                        minLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (value) {
                          if (_errorText != null && value.trim().isNotEmpty) {
                            safeSetState(() => _errorText = null);
                          }
                        },
                        style: GoogleFonts.publicSans(
                          color: _textDark,
                          fontSize: 14.0,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe por qué no se realizó la visita…',
                          hintStyle: GoogleFonts.publicSans(
                            color: _grey,
                            fontSize: 14.0,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14.0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: hasError
                                  ? reportRed
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: hasError ? reportRed : _aqua,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: _model.textControllerValidator
                            ?.asValidator(context),
                      ),
                      if (hasError)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              4.0, 8.0, 0.0, 0.0),
                          child: Text(
                            _errorText!,
                            style: GoogleFonts.publicSans(
                              color: reportRed,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24.0),
                      Row(
                        children: [
                          Expanded(
                            child: _button(
                              text: 'Cancelar',
                              filled: false,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: _button(
                              text: 'Enviar reporte',
                              filled: true,
                              onPressed: () {
                                final text =
                                    _model.textController?.text.trim() ?? '';
                                if (text.isEmpty) {
                                  safeSetState(() => _errorText =
                                      'Escribe qué pasó para enviar el reporte.');
                                  return;
                                }
                                Navigator.pop(context, text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
