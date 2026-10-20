import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/backend/schema/enums/enums.dart';
import 'package:dovia/core/result.dart';
import 'package:dovia/domain/user_models.dart';
import 'package:dovia/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart';
import 'package:dovia/repositories/properties_repository.dart';
import 'package:dovia/repositories/user_repository.dart';

class _FakeProperties extends PropertiesRepository {
  @override
  Future<Result<List<dynamic>>> getPublishableZones() async => const Success([
        {'id': 'zona-10', 'name': 'Zona 10', 'isActive': true},
        {'id': 'zona-1', 'name': 'Zona 1', 'isActive': false},
      ]);
}

class _FakeUser extends UserRepository {
  _FakeUser(this._fake);
  final UserProfile? _fake;

  @override
  UserProfile? get profile => _fake;

  @override
  Future<Result<UserProfile>> loadProfile({bool forceRefresh = false}) async =>
      _fake == null ? const Failure('sin perfil') : Success(_fake!);
}

const _withId = UserProfile(
  uid: 'u1',
  firstName: 'Rodrigo',
  lastName: 'Barrios',
  isActive: true,
  identificationDocumentUrl: 'https://example.com/dpi.pdf',
);

/// El formulario de publicación en un teléfono: cada titularidad muestra sus
/// bloques y nada desborda.
void main() {
  tearDown(FFAppState.reset);

  Future<List<String>> pumpForm(
    WidgetTester tester, {
    PropertyPublicationType type = PropertyPublicationType.SALE_AND_RENT,
    UserProfile? profile = _withId,
  }) async {
    tester.view.physicalSize = const Size(384 * 3, 832 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) overflows.add(text);
      // El mapa, las fuentes y las llamadas de red no aplican acá.
    };
    addTearDown(() => FlutterError.onError = original);

    SharedPreferences.setMockInitialValues({'ff_UserRole': 'CLIENT'});
    await FFAppState().initializePersistedState();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: FFAppState()),
        ChangeNotifierProvider<PropertiesRepository>(
            create: (_) => _FakeProperties()),
        ChangeNotifierProvider<UserRepository>(
            create: (_) => _FakeUser(profile)),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => DOVIACLIENTMisPropiedadesVenderRentarWidget(
              title: 'Venta y renta',
              transactionType: type,
            ),
          ),
        ]),
      ),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return overflows;
  }

  Future<void> chooseOwnership(WidgetTester tester, String label) async {
    final current = find.text('A mi nombre');
    await tester.ensureVisible(current.first);
    await tester.tap(current.first);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text(label).last);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('venta y renta, a mi nombre con la identificación de la cuenta',
      (tester) async {
    final overflows = await pumpForm(tester);

    expect(find.textContaining('Seleccionaste venta y renta'), findsOneWidget);
    expect(find.text('Precio de venta estimado *'), findsOneWidget);
    expect(find.textContaining('Precio de renta mensual'), findsOneWidget);
    expect(find.text('Tiempo mínimo'), findsOneWidget);
    expect(find.text('Rodrigo Barrios'), findsOneWidget);
    expect(find.text('De tu cuenta'), findsOneWidget);
    expect(find.text('Ya la tenemos: la cargaste al crear tu cuenta.'),
        findsOneWidget);
    expect(find.text('Datos del propietario'), findsNothing);
    expect(overflows.where((o) => o.contains('bottom')), isEmpty);
  });

  testWidgets('sin identificación en la cuenta pide subirla', (tester) async {
    await pumpForm(
      tester,
      type: PropertyPublicationType.SALE,
      profile: const UserProfile(
          uid: 'u1', firstName: 'Ana', lastName: 'Ruiz', isActive: true),
    );

    expect(find.textContaining('Seleccionaste venta y renta'), findsNothing);
    expect(find.textContaining('Precio de renta mensual'), findsNothing);
    expect(find.textContaining('todavía no tiene tu identificación'),
        findsOneWidget);
  });

  testWidgets('a nombre de otra persona agrega sus datos y su identificación',
      (tester) async {
    final overflows = await pumpForm(tester);
    await chooseOwnership(tester, 'A nombre de otra persona');

    expect(find.text('Tus datos'), findsOneWidget);
    expect(find.text('Tu relación con el propietario *'), findsOneWidget);
    expect(find.text('Datos del propietario'), findsOneWidget);
    expect(find.text('Teléfono *'), findsOneWidget);
    expect(find.text('Subir identificación del propietario *'), findsOneWidget);
    expect(overflows.where((o) => o.contains('bottom')), isEmpty);
  });

  testWidgets('a nombre de una sociedad pide sociedad, representante y acta',
      (tester) async {
    final overflows = await pumpForm(tester);
    await chooseOwnership(tester, 'A nombre de una sociedad');

    expect(find.text('Tus datos'), findsNothing);
    expect(find.text('Datos de la sociedad'), findsOneWidget);
    expect(find.text('Representante legal'), findsOneWidget);
    expect(find.text('Nombramiento del representante legal'), findsOneWidget);
    expect(find.text('Subir identificación del representante legal *'),
        findsOneWidget);
    expect(
        find.text('Adjuntar acta notarial de nombramiento *'), findsOneWidget);
    expect(find.text('Plazo en años *'), findsOneWidget);
    expect(overflows.where((o) => o.contains('bottom')), isEmpty);
  });
}
