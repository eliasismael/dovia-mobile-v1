import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_client/app/mis_visitas/d_o_v_i_a_c_l_i_e_n_t_oferta_compra/d_o_v_i_a_c_l_i_e_n_t_oferta_compra_widget.dart';
import 'package:dovia/repositories/index.dart';

const _label = 'Tiempo de promesa (en meses)';
const _rangeError = 'El tiempo debe estar entre 1 y 36 meses';

Future<void> _pumpOferta(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 6000 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FFAppState()),
        ChangeNotifierProvider(create: (_) => OffersRepository()),
        ChangeNotifierProvider(create: (_) => PropertiesRepository()),
        ChangeNotifierProvider(create: (_) => UserRepository()),
      ],
      child: const MaterialApp(
        home: DOVIACLIENTOfertaCompraWidget(propertyId: 'prop-1'),
      ),
    ),
  );
  // La propiedad sale contra el fake HttpClient del binding (400 sin red); el
  // formulario espera esa respuesta antes de pintarse.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// El campo de texto que cuelga de una etiqueta del formulario.
Finder _fieldUnder(String label) => find.descendant(
      of: find
          .ancestor(
              of: find.textContaining(label, findRichText: true),
              matching: find.byType(Column))
          .first,
      matching: find.byType(TextFormField),
    );

Finder _promiseField(WidgetTester tester) => _fieldUnder(_label);

Future<void> _choosePromesa(WidgetTester tester) async {
  await tester.tap(find.text('Contado').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Promesa de compra').last);
  await tester.pumpAndSettle();
}

Future<void> _tapAceptar(WidgetTester tester) async {
  final aceptar = find.text('Aceptar').last;
  await tester.ensureVisible(aceptar);
  await tester.pumpAndSettle();
  await tester.tap(aceptar);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(FFAppState.reset);

  testWidgets('el label aclara que el tiempo de promesa es en meses',
      (tester) async {
    await _pumpOferta(tester);
    await _choosePromesa(tester);

    expect(find.textContaining(_label, findRichText: true), findsOneWidget);
  });

  testWidgets('40 meses marca el campo en rojo y no abre ningún diálogo',
      (tester) async {
    await _pumpOferta(tester);
    await _choosePromesa(tester);

    await tester.enterText(_promiseField(tester), '40');
    await _tapAceptar(tester);

    // El aviso queda debajo del campo, que es donde se corrige.
    expect(find.text(_rangeError), findsOneWidget);
    // Ni el diálogo "error" con el JSON, ni ningún otro.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('error'), findsNothing);
  });

  testWidgets('el aviso desaparece apenas se corrige el valor', (tester) async {
    await _pumpOferta(tester);
    await _choosePromesa(tester);

    await tester.enterText(_promiseField(tester), '40');
    await _tapAceptar(tester);
    expect(find.text(_rangeError), findsOneWidget);

    await tester.enterText(_promiseField(tester), '12');
    await tester.pumpAndSettle();
    expect(find.text(_rangeError), findsNothing);
  });

  testWidgets('36 meses es válido: no muestra el aviso de rango',
      (tester) async {
    await _pumpOferta(tester);
    await _choosePromesa(tester);

    await tester.enterText(_promiseField(tester), '36');
    await _tapAceptar(tester);

    expect(find.text(_rangeError), findsNothing);
  });

  testWidgets(
      'si el servidor rechaza la oferta avisa en una barra, sin el diálogo con el JSON',
      (tester) async {
    await _pumpOferta(tester);
    await _choosePromesa(tester);

    // Formulario completo y válido: la validación deja pasar y el envío llega
    // al servidor, que en el test responde 400.
    await tester.enterText(_fieldUnder('Propuesta económica'), '250000');
    await tester.enterText(_fieldUnder('Reserva inicial'), '60000');
    await tester.enterText(_promiseField(tester), '12');
    await tester.enterText(_fieldUnder('Nombre del comprador'), 'Ana');
    await _tapAceptar(tester);

    // Antes salía un AlertDialog titulado "error" con el cuerpo de la respuesta.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('error'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('No pudimos enviar tu oferta. Inténtalo de nuevo.'),
      findsOneWidget,
    );
  });
}
