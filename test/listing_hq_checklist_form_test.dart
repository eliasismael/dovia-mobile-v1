import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/custom_code/widgets/listing_h_q_propiedad.dart';

Future<void> _pump(WidgetTester tester, Map<String, dynamic> data,
    {Future<void> Function()? onPublicar}) async {
  tester.view.physicalSize = const Size(800, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ListingHQPropiedad(
          initialData: data,
          onPublicar: onPublicar,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('precarga el nombre público y muestra los títulos nuevos',
      (tester) async {
    await _pump(tester, {
      'property': {'name': 'Casa en Zona 10', 'propertyType': 'HOUSE'},
    });

    expect(find.text('Nombre público del inmueble'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Casa en Zona 10'), findsOneWidget);
    expect(find.text('Servicios y observaciones'), findsOneWidget);
    expect(find.text('Información para HQ'), findsOneWidget);
    expect(find.text('Adicionales'), findsNothing);
    expect(find.text('Próximamente'), findsOneWidget);

    // El nombre público va al PATCH como `name` (el título de las tarjetas).
    final dynamic state = tester.state(find.byType(ListingHQPropiedad));
    final body = state.buildPatchBody() as Map<String, dynamic>;
    expect(body['name'], 'Casa en Zona 10');
  });

  testWidgets('no publica si faltan datos y lista lo que falta',
      (tester) async {
    var published = false;
    await _pump(
      tester,
      {
        'property': {'propertyType': 'HOUSE'},
      },
      onPublicar: () async => published = true,
    );

    await tester.tap(find.text('Publicar'));
    await tester.pump();

    final snack = tester.widget<Text>(find.descendant(
        of: find.byType(SnackBar), matching: find.byType(Text)));
    expect(snack.data, contains('Nombre público del inmueble'));
    expect(snack.data, contains('Baños'));
    expect(snack.data, contains('Hay daños en la propiedad'));
    expect(published, isFalse);
  });
}
