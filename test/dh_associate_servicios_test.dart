import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_home_associate/associate_specialties.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_navbar/d_h_a_s_s_o_c_i_a_t_e_navbar_widget.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_servicios/d_h_a_s_s_o_c_i_a_t_e_servicios_widget.dart';
import 'package:dovia/flutter_flow/flutter_flow_widgets.dart';

AssociateSpecialty _specialty(String id, String label) => AssociateSpecialty(
      id: id,
      code: label.toUpperCase(),
      label: label,
      iconPath: 'assets/images/IconoCaja.svg',
    );

/// Lo que devolvería `GET /users/me/specialties` para una empresa ya verificada
/// en tres rubros: el backend descuenta las aprobadas de las solicitables, así
/// que Plomería no vuelve a aparecer abajo.
AssociateSpecialties _empresaVerificada() => AssociateSpecialties(
      current: [
        _specialty('1', 'Plomería'),
        _specialty('2', 'Albañilería'),
        _specialty('3', 'Instalación'),
      ],
      available: [
        _specialty('4', 'Eléctrico'),
        _specialty('5', 'Pintura'),
      ],
      pending: const [],
    );

/// Deja el rol en sesión como lo dejaría el login. `initializePersistedState`
/// además engancha las prefs mock, sin las cuales el setter de rol explota.
Future<void> _signInAs(String role) async {
  SharedPreferences.setMockInitialValues({'ff_UserRole': role});
  await FFAppState().initializePersistedState();
}

Future<void> _pump(
  WidgetTester tester, {
  required String role,
  AssociateSpecialties? specialties,
}) async {
  await _signInAs(role);
  DHASSOCIATEServiciosWidget.specialtiesLoader =
      () async => specialties ?? _empresaVerificada();

  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATEServiciosWidget(),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Finder _navItems() => find.descendant(
      of: find.byType(DHASSOCIATENavbarWidget),
      matching: find.byType(InkWell),
    );

/// La tarjeta de una categoría del selector, por su etiqueta.
Finder _categoryCard(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(InkWell),
    );

FFButtonWidget _solicitar(WidgetTester tester) =>
    tester.widget<FFButtonWidget>(find.byType(FFButtonWidget));

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    DHASSOCIATEServiciosWidget.specialtiesLoader = null;
    FFAppState.reset();
  });

  /// Pantalla de escritorio adaptada a mobile: con el alto de un teléfono el
  /// formulario queda fuera del viewport y los `find` no lo alcanzan.
  Future<void> withTallScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('la empresa ve la cabecera y el menú con Cotizaciones',
      (tester) async {
    await withTallScreen(tester);
    await _pump(tester, role: 'HOME_ASSOCIATE_COMPANY');

    // El título del header y la pestaña de la barra.
    expect(find.text('Servicios', findRichText: true), findsNWidgets(2));
    // Inicio + Cotizaciones + Servicios: avisos y ajustes están en el header.
    expect(_navItems(), findsNWidgets(3));
    expect(find.text('Cotizaciones'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el independiente no ve el ítem de Cotizaciones en el menú',
      (tester) async {
    await withTallScreen(tester);
    await _pump(tester, role: 'HOME_ASSOCIATE');

    // Inicio + Trabajos + Servicios.
    expect(_navItems(), findsNWidgets(3));
    expect(find.text('Trabajos'), findsOneWidget);
  });

  testWidgets('los servicios verificados se pintan y no son accionables',
      (tester) async {
    await withTallScreen(tester);
    await _pump(tester, role: 'HOME_ASSOCIATE_COMPANY');

    expect(find.text('Servicios actuales'), findsOneWidget);
    expect(find.text('Albañilería'), findsOneWidget);
    expect(find.text('Instalación'), findsOneWidget);

    // Plomería está aprobada: aparece arriba, y como el backend la descuenta de
    // las solicitables no vuelve a aparecer en el selector.
    expect(find.text('Plomería'), findsOneWidget);
    expect(_categoryCard('Plomería'), findsNothing);
    expect(_categoryCard('Albañilería'), findsNothing);
  });

  testWidgets('el selector de nueva especialidad es de selección única',
      (tester) async {
    await withTallScreen(tester);
    await _pump(tester, role: 'HOME_ASSOCIATE_COMPANY');

    expect(find.text('Solicita agregar un nuevo servicio en tu perfil'),
        findsOneWidget);

    // El estado de selección vive en el `Semantics` que rotula la tarjeta, que
    // es lo que también lee el lector de pantalla. Se busca por etiqueta y no
    // por descendencia del InkWell, que trae los suyos propios.
    Semantics semanticsOf(String label) => tester.widget<Semantics>(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == label,
          ),
        );

    await tester.tap(_categoryCard('Eléctrico'));
    await tester.pump();
    expect(semanticsOf('Eléctrico').properties.selected, isTrue);
    expect(semanticsOf('Pintura').properties.selected, isFalse);

    // Radio button: elegir otra desmarca la anterior.
    await tester.tap(_categoryCard('Pintura'));
    await tester.pump();
    expect(semanticsOf('Eléctrico').properties.selected, isFalse);
    expect(semanticsOf('Pintura').properties.selected, isTrue);
  });

  testWidgets('el formulario de evidencia usa el lenguaje de la empresa',
      (tester) async {
    await withTallScreen(tester);
    await _pump(tester, role: 'HOME_ASSOCIATE_COMPANY');

    expect(find.text('Escribe la experiencia en este nuevo servicio'),
        findsOneWidget);
    expect(find.text('Carga el certificado o titulo'), findsOneWidget);
    expect(
      find.text('Adjuntá el permiso, la patente o la certificación comercial '
          'que habilita a tu empresa en el rubro.'),
      findsOneWidget,
    );
  });

  testWidgets('al independiente se le sigue pidiendo su título', (tester) async {
    await withTallScreen(tester);
    await _pump(tester, role: 'HOME_ASSOCIATE');

    expect(
      find.text('Adjuntá el título, certificado o matrícula que respalde tu '
          'experiencia en el rubro.'),
      findsOneWidget,
    );
  });

  testWidgets('[Solicitar] queda bloqueado sin las tres evidencias',
      (tester) async {
    await withTallScreen(tester);
    await _pump(tester, role: 'HOME_ASSOCIATE_COMPANY');

    // Sin nada cargado.
    expect(_solicitar(tester).onPressed, isNull);

    // Sólo categoría.
    await tester.tap(_categoryCard('Eléctrico'));
    await tester.pump();
    expect(_solicitar(tester).onPressed, isNull);

    // Categoría + experiencia, todavía sin certificado: el certificado es lo
    // que audita el Backoffice, así que sigue bloqueado.
    await tester.enterText(
      find.byType(TextFormField),
      'La empresa lleva 8 años en instalaciones eléctricas.',
    );
    await tester.pump();
    expect(_solicitar(tester).onPressed, isNull);
  });

  testWidgets('sin especialidades aprobadas se lo dice en voz de empresa',
      (tester) async {
    await withTallScreen(tester);
    await _pump(
      tester,
      role: 'HOME_ASSOCIATE_COMPANY',
      specialties: AssociateSpecialties(
        current: const [],
        available: [_specialty('4', 'Eléctrico')],
        pending: const [],
      ),
    );

    expect(
      find.text('Tu empresa todavía no tiene especialidades aprobadas. '
          'Solicitá la primera acá abajo y el equipo de DOVIA revisará la '
          'documentación.'),
      findsOneWidget,
    );
  });
}
