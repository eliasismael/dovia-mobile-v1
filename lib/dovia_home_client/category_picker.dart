/// Selección de la categoría del trabajo, compartida por las dos pantallas que
/// crean solicitudes: Agenda (servicio normal) y Emergencias.
///
/// El backend exige `categoryId` para crear cualquier solicitud, y la lista
/// sale del catálogo ([loadDoviaHomeServiceScope] /
/// [loadDoviaHomeEmergencyScope]). Se reutiliza la fila-selector y la hoja
/// inferior que ya usaba Agenda para el lugar del servicio, para que elegir la
/// categoría se vea igual que elegir la ubicación, la fecha o la hora.
library;

import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'service_catalog.dart';

/// Fila blanca con la selección actual y el chevron. Es el control con el que
/// el cliente abre cualquiera de los selectores de la solicitud.
class DoviaHomeSelectorRow extends StatelessWidget {
  const DoviaHomeSelectorRow({
    super.key,
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;

  /// Selector desplegado en la misma pantalla (Ej: la rueda de horarios): el
  /// chevron pasa a apuntar hacia arriba.
  final bool expanded;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
}

/// Abre la hoja de categorías y devuelve la elegida, o null si el cliente la
/// cerró sin elegir (ahí la selección previa queda intacta).
Future<DoviaHomeServiceCategory?> pickDoviaHomeCategory({
  required BuildContext context,
  required String title,
  required List<DoviaHomeServiceCategory> categories,
  required String? selectedId,
  required String emptyMessage,
}) {
  return showModalBottomSheet<DoviaHomeServiceCategory>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _CategoryPickerSheet(
      title: title,
      categories: categories,
      selectedId: selectedId,
      emptyMessage: emptyMessage,
      onSelect: (category) => Navigator.of(sheetContext).pop(category),
    ),
  );
}

/// Hoja inferior con las categorías del servicio. Cada opción muestra el
/// alcance que el catálogo le adjunta ("de 2 a 3 fugas por visita"), que es lo
/// único que le dice al cliente hasta dónde llega la visita antes de pedirla.
class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.title,
    required this.categories,
    required this.selectedId,
    required this.emptyMessage,
    required this.onSelect,
  });

  final String title;
  final List<DoviaHomeServiceCategory> categories;
  final String? selectedId;
  final String emptyMessage;
  final ValueChanged<DoviaHomeServiceCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFDFDF),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w600,
                fontSize: 17.0,
                color: const Color(0xFF00444B),
              ),
            ),
            const SizedBox(height: 12.0),
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  emptyMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category.id == selectedId;
                    return InkWell(
                      onTap: () => onSelect(category),
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0x3670ACAD)
                              : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: selected
                                ? FlutterFlowTheme.of(context).primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0,
                                      color: const Color(0xFF00444B),
                                    ),
                                  ),
                                  if (category.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        category.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.0,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (selected)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 20.0,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
