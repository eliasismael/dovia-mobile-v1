import '/domain/owner_proposal_models.dart';
import '/shared_components/segmented_filter_bar/segmented_filter_bar_widget.dart';
import 'package:flutter/material.dart';

/// Barra de pestañas que filtra dentro de un carril de propuestas recibidas.
///
/// Es el control segmentado compartido con el listado de ofertas enviadas,
/// hablando el vocabulario del propietario.
class PropuestasFilterBarWidget extends StatelessWidget {
  const PropuestasFilterBarWidget({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<OwnerProposalFilter> filters;
  final OwnerProposalFilter selected;
  final ValueChanged<OwnerProposalFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedFilterBarWidget(
      labels: filters.map((f) => f.label).toList(),
      selectedIndex: filters.indexOf(selected),
      onSelected: (index) => onSelected(filters[index]),
    );
  }
}
