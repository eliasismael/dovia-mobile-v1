// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class DoviaAssociateDropdownWidget extends StatefulWidget {
  final double? width;
  final double? height;

  final VoidCallback? onShowingAssociateTap;
  final VoidCallback? onListerAssociateTap;
  final VoidCallback? onHomeAssociateTap;
  final VoidCallback? onLegalAssociateTap;

  const DoviaAssociateDropdownWidget({
    super.key,
    this.width,
    this.height,
    this.onShowingAssociateTap,
    this.onListerAssociateTap,
    this.onHomeAssociateTap,
    this.onLegalAssociateTap,
  });

  @override
  State<DoviaAssociateDropdownWidget> createState() =>
      _DoviaAssociateDropdownWidgetState();
}

class _DoviaAssociateDropdownWidgetState
    extends State<DoviaAssociateDropdownWidget> {
  static const Color aquaColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  static const Color separatorColor = Color(0xFFE9EFF2);
  static const Color arrowColor = Color(0xFF00444B);

  // Todas cerradas al entrar; se abren con la flecha.
  final List<bool> _expandedStates = [false, false, false];

  static const List<String> _titles = [
    'Enseña propiedades',
    'Servicios para el hogar',
    'Servicios legales',
  ];

  static const List<List<String>> _descriptions = [
    [
      'Acompaña a clientes de DOVIA en visitas a propiedades asignadas.',
      'Participa en el proceso comercial y genera ingresos cuando la transacción se concreta.',
      'Forma parte de una red profesional respaldada por DOVIA.',
    ],
    [
      'Brinda servicios a clientes de DOVIA Home según su especialidad.',
      'Elige sus asignaciones y genera ingresos por cada servicio completado.',
      'Forma parte de la red profesional de servicios del hogar de DOVIA.',
    ],
    [
      'Apoya a clientes de DOVIA en procesos legales relacionados a propiedades.',
      'Gestiona contratos, acuerdos y documentación en cada operación.',
      'Genera ingresos por cada caso o servicio completado. Opera como parte de la red legal profesional verificada de DOVIA.',
    ],
  ];

  VoidCallback? _getCallback(int index) {
    switch (index) {
      case 0:
        return widget.onShowingAssociateTap;
      case 1:
        return widget.onHomeAssociateTap;
      case 2:
        return widget.onLegalAssociateTap;
      default:
        return null;
    }
  }

  void _toggleExpanded(int index) {
    setState(() {
      final willExpand = !_expandedStates[index];
      // Close all sections first
      for (int i = 0; i < _expandedStates.length; i++) {
        _expandedStates[i] = false;
      }
      // Open the tapped section (if it wasn't already open)
      if (willExpand) {
        _expandedStates[index] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 23,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: List.generate(_titles.length, (index) {
              return _buildDropdownItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(int index) {
    final isExpanded = _expandedStates[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: button + arrow
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: separatorColor, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                // Aqua pill button
                Expanded(
                  child: GestureDetector(
                    onTap: _getCallback(index),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: aquaColor,
                        border: Border.all(color: aquaColor, width: 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _titles[index],
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow icon — toggles dropdown
                GestureDetector(
                  onTap: () => _toggleExpanded(index),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.0 : -0.25,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: arrowColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Description content — animated collapse/expand
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
            child: _buildDescriptionText(_descriptions[index]),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDescriptionText(List<String> lines) {
    final List<InlineSpan> spans = [];
    for (int i = 0; i < lines.length; i++) {
      if (i > 0) {
        spans.add(const TextSpan(text: '\n\n'));
      }
      spans.add(TextSpan(text: lines[i]));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(
        fontFamily: 'Public Sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.4,
        letterSpacing: 0,
      ),
    );
  }
}
