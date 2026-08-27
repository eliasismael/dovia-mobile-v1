import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_client/app/mis_ofertas/cancelar_oferta_modal_widget.dart';

/// Abre el modal desde un botón y guarda lo que devuelve.
Future<List<String?>> _openModal(WidgetTester tester) async {
  final results = <String?>[];
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async =>
              results.add(await showCancelarOfertaModal(context)),
          child: const Text('abrir'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return results;
}

FilledButton _retirarButton(WidgetTester tester) => tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Retirar Oferta'),
        matching: find.byType(FilledButton),
      ),
    );

void main() {
  testWidgets('muestra los textos del comprador, no los de la propiedad',
      (tester) async {
    await _openModal(tester);

    expect(find.text('¿Quieres cancelar la oferta de esta propiedad?'),
        findsOneWidget);
    expect(find.text('Describe por qué quieres retirar tu oferta...'),
        findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Retirar Oferta'), findsOneWidget);
  });

  testWidgets('el motivo es obligatorio para poder retirar', (tester) async {
    await _openModal(tester);

    expect(_retirarButton(tester).onPressed, isNull,
        reason: 'sin motivo no se puede retirar');

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(_retirarButton(tester).onPressed, isNull,
        reason: 'espacios en blanco no son un motivo');

    await tester.enterText(find.byType(TextField), 'Encontré otra casa');
    await tester.pump();
    expect(_retirarButton(tester).onPressed, isNotNull);
  });

  testWidgets('confirmar devuelve el motivo escrito', (tester) async {
    final results = await _openModal(tester);

    await tester.enterText(find.byType(TextField), '  Encontré otra casa  ');
    await tester.pump();
    await tester.tap(find.text('Retirar Oferta'));
    await tester.pumpAndSettle();

    expect(results, ['Encontré otra casa']);
  });

  testWidgets('cancelar cierra sin retirar nada', (tester) async {
    final results = await _openModal(tester);

    await tester.enterText(find.byType(TextField), 'me arrepentí');
    await tester.pump();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(results, [null]);
  });

  testWidgets('la X tambien cierra sin retirar nada', (tester) async {
    final results = await _openModal(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(results, [null]);
  });
}
