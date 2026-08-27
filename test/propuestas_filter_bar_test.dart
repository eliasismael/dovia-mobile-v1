import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/owner_proposal_models.dart';
import 'package:dovia/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_propuestas_recientes/propuestas_filter_bar_widget.dart';

Future<List<OwnerProposalFilter>> _pumpBar(
  WidgetTester tester,
  OwnerProposalLane lane, {
  OwnerProposalFilter? selected,
}) async {
  final picked = <OwnerProposalFilter>[];
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: PropuestasFilterBarWidget(
        filters: lane.filters,
        selected: selected ?? lane.filters.first,
        onSelected: picked.add,
      ),
    ),
  ));
  await tester.pump();
  return picked;
}

void main() {
  testWidgets('Ofertas filtra entre Activas y Rechazadas', (tester) async {
    final picked = await _pumpBar(tester, OwnerProposalLane.ofertas);

    expect(find.text('Activas'), findsOneWidget);
    expect(find.text('Rechazadas'), findsOneWidget);

    await tester.tap(find.text('Rechazadas'));
    await tester.pump();

    expect(picked, [OwnerProposalFilter.ofertasRechazadas]);
  });

  testWidgets('Contraoferta filtra entre Enviada y Rechazada', (tester) async {
    final picked = await _pumpBar(tester, OwnerProposalLane.contraoferta);

    expect(find.text('Enviada'), findsOneWidget);
    expect(find.text('Rechazada'), findsOneWidget);

    await tester.tap(find.text('Rechazada'));
    await tester.pump();

    expect(picked, [OwnerProposalFilter.contraofertaRechazada]);
  });

  testWidgets('Oferta aceptada filtra entre los tres momentos del proceso',
      (tester) async {
    final picked = await _pumpBar(tester, OwnerProposalLane.aceptada);

    expect(find.text('Proceso Legal'), findsOneWidget);
    expect(find.text('Finalizadas'), findsOneWidget);
    expect(find.text('Calificadas'), findsOneWidget);

    await tester.tap(find.text('Calificadas'));
    await tester.pump();

    expect(picked, [OwnerProposalFilter.aceptadaCalificadas]);
  });

  testWidgets('sólo la pestaña activa va resaltada en blanco', (tester) async {
    await _pumpBar(tester, OwnerProposalLane.aceptada,
        selected: OwnerProposalFilter.aceptadaFinalizadas);

    // El Container más cercano al texto es el de la propia pestaña; los
    // siguientes son la pista gris y la tarjeta blanca que la envuelven.
    Color? segmentColor(String label) {
      final container = tester.widget<Container>(find
          .ancestor(of: find.text(label), matching: find.byType(Container))
          .first);
      return (container.decoration as BoxDecoration).color;
    }

    expect(segmentColor('Finalizadas'), Colors.white);
    expect(segmentColor('Proceso Legal'), Colors.transparent);
    expect(segmentColor('Calificadas'), Colors.transparent);
  });
}
