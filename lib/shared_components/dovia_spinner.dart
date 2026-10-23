import 'package:flutter/material.dart';

/// Spinner de carga de toda la app: mismo verde, grosor y punta redondeada en
/// todas las pantallas. Antes cada una tenía el suyo (de 14 a 120 px, con
/// trazos de 2 a 4 y algunos azules, el color por defecto de Material).
///
/// - Normal (32 px): el de una sección o pantalla que carga.
/// - [small] (18 px): dentro de botones o junto a un texto. Ahí puede ir
///   [color] (Ej: blanco sobre un botón verde).
class DoviaSpinner extends StatelessWidget {
  const DoviaSpinner({super.key, this.small = false, this.color});

  final bool small;
  final Color? color;

  static const Color green = Color(0xFF007376);
  static const double size = 32.0;
  static const double smallSize = 18.0;

  /// Separación entre un spinner [small] y el texto que lo acompaña.
  static const double textGap = 10.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: small ? smallSize : size,
      child: CircularProgressIndicator(
        strokeWidth: small ? 2.5 : 3.0,
        strokeCap: StrokeCap.round,
        color: color ?? green,
      ),
    );
  }
}
