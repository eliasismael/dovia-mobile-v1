/// Filtros de búsqueda compartidos por los dos listados de trabajos del
/// asociado: la bolsa de oportunidades ("Trabajos disponibles") y la agenda
/// ("Próximos trabajos").
///
/// Las dos pantallas muestran los mismos tres desplegables sobre el mismo shape
/// de payload, así que el chrome del control y el agrupado por mes viven acá y
/// no duplicados en cada una. Lo que **no** vive acá es qué opciones ofrece cada
/// filtro: eso depende de los datos de cada pantalla (las especialidades
/// aprobadas del asociado, los meses que realmente tienen trabajos) y lo arma
/// cada una.
library;

import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'associate_service_request_fields.dart';

/// Valor centinela de la opción "Todo" de cada desplegable. Es un valor y no
/// `null` porque `FlutterFlowDropDown` usa null para "nada elegido" y ahí
/// pintaría el placeholder en vez de decir que no está filtrando.
const String kAssociateFilterAll = '__ALL__';

/// Opciones fijas del filtro "Estado del trabajo".
const String kAssociateFilterUrgent = 'URGENT';
const String kAssociateFilterStandard = 'STANDARD';

/// Un mes con trabajos, para el desplegable de fecha.
typedef AssociateMonthOption = ({String key, String label});

/// Meses que tienen trabajos, ordenados cronológicamente.
///
/// Se calcula sobre el listado **sin filtrar** para que el desplegable no se
/// vacíe a medida que el asociado filtra: elegir "Agosto 2026" no debería hacer
/// desaparecer "Septiembre 2026" de las opciones.
List<AssociateMonthOption> associateMonthOptions(
    Iterable<Map<String, dynamic>> jobs) {
  final labelsByKey = <String, String>{};
  for (final job in jobs) {
    final key = asrMonthKey(job);
    final label = asrMonthLabel(job);
    if (key != null && label != null) labelsByKey[key] = label;
  }
  final keys = labelsByKey.keys.toList()..sort();
  return [for (final key in keys) (key: key, label: labelsByKey[key]!)];
}

/// Desplegable de filtro del diseño: etiqueta arriba, campo blanco redondeado
/// con la flecha a la derecha.
class AssociateJobFilterDropdown extends StatelessWidget {
  const AssociateJobFilterDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.options,
    required this.optionLabels,
    required this.onChanged,
    this.disabled = false,
  });

  /// Etiqueta sobre el campo (Ej: "Tipo de Trabajo").
  final String label;

  /// Texto del campo cuando no hay nada elegido.
  final String hintText;

  final FormFieldController<String> controller;

  final List<String> options;
  final List<String> optionLabels;

  final void Function(String?) onChanged;

  /// Sin opciones que ofrecer el control se deja visible pero inerte:
  /// esconderlo haría parecer que la pantalla está rota.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: theme.primaryText,
            fontSize: 16.0,
            letterSpacing: 0.32,
          ),
        ),
        const SizedBox(height: 8.0),
        FlutterFlowDropDown<String>(
          controller: controller,
          options: options,
          optionLabels: optionLabels,
          onChanged: onChanged,
          width: double.infinity,
          height: 48.0,
          hintText: hintText,
          disabled: disabled,
          textStyle: theme.bodyMedium.override(
            font: GoogleFonts.publicSans(),
            color: disabled ? theme.secondaryText : theme.primaryText,
            fontSize: 15.0,
            letterSpacing: 0.3,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.secondaryText,
            size: 24.0,
          ),
          fillColor: theme.secondaryBackground,
          elevation: 2.0,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          borderRadius: 10.0,
          margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 12.0, 4.0),
          hidesUnderline: true,
          isOverButton: false,
          isSearchable: false,
          isMultiSelect: false,
        ),
      ],
    );
  }
}
