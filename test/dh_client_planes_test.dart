import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:dovia/core/result.dart';
import 'package:dovia/domain/payment_models.dart';
import 'package:dovia/dovia_home_client/d_h_c_l_i_e_n_t_planes/d_h_c_l_i_e_n_t_planes_widget.dart';
import 'package:dovia/dovia_home_client/d_h_c_l_i_e_n_t_ubicacion/d_h_c_l_i_e_n_t_ubicacion_widget.dart';
import 'package:dovia/repositories/payments_repository.dart';

/// Catálogo tal como lo devuelve `GET /subscriptions/plans` en dev: los dos
/// planes vendibles más uno de prueba con intervalo diario, que no debe
/// llegarle al cliente.
const _monthly = SubscriptionPlan(
  id: 'plan-mensual',
  code: 'DOVIA_HOME_MONTHLY',
  name: 'Dovia Home Premium Mensual',
  amount: 299.99,
  currency: 'GTQ',
  interval: 'month',
);

const _annual = SubscriptionPlan(
  id: 'plan-anual',
  code: 'DOVIA_HOME_ANNUAL',
  name: 'Dovia Home Premium Anual',
  amount: 2999.99,
  currency: 'GTQ',
  interval: 'year',
);

const _test = SubscriptionPlan(
  id: 'plan-test',
  code: 'DOVIA_HOME_MONTHLY_TEST',
  name: 'Dovia Home Mensual TEST',
  amount: 5,
  currency: 'GTQ',
  interval: 'day',
);

/// Repositorio de mentira: la pantalla sólo consume `plans` y `loadPlans`, así
/// que se sobreescriben esos dos y no hace falta red.
///
/// `plans` arranca vacío y se puebla recién cuando `loadPlans` responde, igual
/// que el repositorio real; si devolviera el catálogo de entrada, el estado de
/// carga sería intesteable.
class _FakePaymentsRepository extends PaymentsRepository {
  _FakePaymentsRepository(
    this._catalog, {
    this.fails = false,
    this.delay = Duration.zero,
  });

  final List<SubscriptionPlan> _catalog;
  final bool fails;
  final Duration delay;

  List<SubscriptionPlan> _loaded = const [];

  @override
  List<SubscriptionPlan> get plans => _loaded;

  @override
  Future<Result<List<SubscriptionPlan>>> loadPlans({
    bool forceRefresh = false,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (fails) return const Failure('sin conexión');
    _loaded = _catalog;
    return Success(_catalog);
  }
}

/// Viewport holgado a propósito.
///
/// El alto evita scrollear —lo que se prueba es qué planes se muestran y en
/// qué orden—, y el ancho compensa que en `flutter test` las Google Fonts no
/// se descargan: el tipo de reemplazo es bastante más ancho que Public Sans y
/// desborda filas que en la app entran sin problema.
const _viewport = Size(3000, 24000);

Future<void> _pumpPlanes(
  WidgetTester tester,
  PaymentsRepository repo, {
  bool settle = true,
  void Function(SubscriptionPlan plan)? onPlanSelected,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          // Mismo encuadre que las pantallas que lo embeben.
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: DHCLIENTPlanesWidget(onPlanSelected: onPlanSelected),
          ),
        ),
      ),
      // Destino del tap en una tarjeta. Se apunta a un widget vacío para no
      // arrastrar la pantalla real de Ubicación al test.
      GoRoute(
        path: '/ubicacion',
        name: DHCLIENTUbicacionWidget.routeName,
        builder: (_, __) => const Scaffold(body: Text('ubicacion')),
      ),
    ],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<PaymentsRepository>.value(
      value: repo,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  if (settle) await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  // El paso de datos entre pantallas es por campos estáticos, así que sin
  // limpiarlos un test arrastra el estado del anterior.
  setUp(() {
    DHCLIENTPlanesWidget.selectedPlan = null;
    DHCLIENTUbicacionWidget.pendingNextRoute = null;
  });

  testWidgets('mientras carga el catálogo no muestra tarjetas', (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(
        const [_monthly],
        delay: const Duration(seconds: 1),
      ),
      settle: false,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Dovia Home Premium'), findsNothing);

    // Deja terminar el future pendiente para no ensuciar el tear-down.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('muestra un plan por cada opción vendible, con su precio',
      (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(const [_annual, _monthly]),
    );

    expect(find.text('Dovia Home Premium Mensual'), findsOneWidget);
    expect(find.text('Dovia Home Premium Anual'), findsOneWidget);
    // Monto y período son dos TextSpan del mismo RichText, así que el texto
    // plano incluye el sufijo.
    expect(find.text('Q299.99 /mes', findRichText: true), findsOneWidget);
    expect(find.text('Q2,999.99 /año', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el mensual se muestra antes que el anual', (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Llegan al revés a propósito: el orden de la pantalla no depende del
    // orden en que responda el backend.
    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(const [_annual, _monthly]),
    );

    final mensual = tester.getTopLeft(find.text('Dovia Home Premium Mensual'));
    final anual = tester.getTopLeft(find.text('Dovia Home Premium Anual'));
    expect(mensual.dy, lessThan(anual.dy));
  });

  testWidgets('esconde los planes de prueba que no son comerciales',
      (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(const [_monthly, _annual, _test]),
    );

    expect(find.text('Dovia Home Mensual TEST'), findsNothing);
    expect(find.textContaining('Dovia Home Premium'), findsNWidgets(2));
  });

  testWidgets('sin catálogo ofrece reintentar en vez de precios inventados',
      (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(const [], fails: true),
    );

    expect(find.textContaining('No pudimos cargar los planes'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    // Lo importante: ningún monto que el cliente pueda tomar por real.
    expect(find.textContaining('Q'), findsNothing);
  });

  testWidgets('tapear una tarjeta deja registrado qué plan se va a cobrar',
      (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(const [_monthly, _annual]),
    );

    await tester.tap(find.text('Dovia Home Premium Anual'));
    await tester.pumpAndSettle();

    expect(DHCLIENTPlanesWidget.selectedPlan?.id, 'plan-anual');
  });

  testWidgets('sin callback, elegir un plan manda a verificar la dirección',
      (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(const [_monthly]),
    );

    await tester.tap(find.text('Dovia Home Premium Mensual'));
    await tester.pumpAndSettle();

    expect(find.text('ubicacion'), findsOneWidget);
  });

  testWidgets(
      'con callback no vuelve a pedir dirección: quien embebe decide el paso',
      (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    SubscriptionPlan? elegido;
    await _pumpPlanes(
      tester,
      _FakePaymentsRepository(const [_monthly]),
      onPlanSelected: (plan) => elegido = plan,
    );

    await tester.tap(find.text('Dovia Home Premium Mensual'));
    await tester.pumpAndSettle();

    expect(elegido?.id, 'plan-mensual');
    // El ciclo del que no se salía: en el paso de pago la dirección ya está
    // verificada y volver a pedirla devuelve a esa misma pantalla.
    expect(find.text('ubicacion'), findsNothing);
    expect(DHCLIENTUbicacionWidget.pendingNextRoute, isNull);
  });
}
