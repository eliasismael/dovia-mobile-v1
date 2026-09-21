import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_client/app/mis_visitas/d_o_v_i_a_c_l_i_e_n_t_oferta_compra/d_o_v_i_a_c_l_i_e_n_t_oferta_compra_widget.dart';
import 'package:dovia/dovia_client/app/principal/d_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_new/d_o_v_i_a_c_l_i_e_n_t_propiedad_seleccionada_new_widget.dart';
import 'package:dovia/repositories/index.dart';

const _propertyId = '01a082b9-c6ff-713c-8157-d71becabdfb0';
const _popupTitle = 'Ya tienes una oferta en curso';

/// Lo que aparece cuando la pantalla deja avanzar: el formulario de ofertas.
const _formMarker = 'FORMULARIO_DE_OFERTA';

/// Backend de mentira que reproduce el comportamiento real de la API:
///
///  * `GET /properties/{id}` devuelve una propiedad sólo de venta.
///  * `GET /offers/my-offers` responde **500 si `page` o `limit` vienen
///    vacíos** (`?page=&limit=&...`), tal como se vio en la red.
///
/// [offers] son las ofertas del usuario; [requests] registra lo que se pidió.
MockClient _fakeBackend({
  required List<Map<String, dynamic>> offers,
  List<Uri>? requests,
}) {
  return MockClient((request) async {
    requests?.add(request.url);

    if (request.url.path.endsWith('/offers/my-offers')) {
      final page = request.url.queryParameters['page'] ?? '';
      final limit = request.url.queryParameters['limit'] ?? '';
      if (page.isEmpty || limit.isEmpty) {
        return http.Response(
          jsonEncode({
            'success': false,
            'status_code': 500,
            'message': 'Ocurrió un error inesperado',
          }),
          500,
        );
      }
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'items': offers},
        }),
        200,
      );
    }

    if (request.url.path.endsWith('/properties/$_propertyId')) {
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'listingType': ['SALE'],
            'name': 'Casa de prueba',
            'saleInfo': {'salePrice': 250000},
          },
        }),
        200,
      );
    }

    // Visitas, calificaciones, etc.: la pantalla las pide pero no importan.
    return http.Response(jsonEncode({'success': true, 'data': []}), 200);
  });
}

Map<String, dynamic> _offer({
  String propertyId = _propertyId,
  String offerStatus = 'PENDING',
}) => {
  'offerId': 'offer-1',
  'propertyId': propertyId,
  'offerType': 'PURCHASE',
  'offerStatus': offerStatus,
  'processStatus': 'PENDING',
};

Future<void> _pumpPropiedad(WidgetTester tester) async {
  // Las tarjetas de datos de esta pantalla desbordan 3 px (`..._new_widget
  // .dart` :1739, :1823, :1907). Es anterior a `fix/formularios-cliente`,
  // ajeno a lo que este archivo mide, y el framework de tests lo cuenta como
  // falla. Se silencia sólo ese mensaje —cualquier otro error de layout sigue
  // haciendo fallar el test— y se restaura el handler al terminar.
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('overflowed by 3.0 pixels')) {
      return;
    }
    originalOnError?.call(details);
  };

  addTearDown(() => FlutterError.onError = originalOnError);

  tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const DOVIACLIENTPropiedadSeleccionadaNewWidget(
          propertyId: _propertyId,
        ),
      ),
      // Stand-in del formulario: lo que importa es si se llega o no a él.
      GoRoute(
        name: DOVIACLIENTOfertaCompraWidget.routeName,
        path: '/oferta',
        builder: (_, __) => const Scaffold(body: Text(_formMarker)),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FFAppState()),
        ChangeNotifierProvider(create: (_) => VisitsRepository()),
        ChangeNotifierProvider(create: (_) => FavoritesRepository()),
        ChangeNotifierProvider(create: (_) => PropertiesRepository()),
        ChangeNotifierProvider(create: (_) => OffersRepository()),
        ChangeNotifierProvider(create: (_) => UserRepository()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _tapOfertar(WidgetTester tester) async {
  final ofertar = find.text('Ofertar').last;
  await tester.ensureVisible(ofertar);
  await tester.pumpAndSettle();
  await tester.tap(ofertar);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(FFAppState.reset);

  testWidgets('con una oferta en curso, Ofertar muestra el aviso al instante', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await _pumpPropiedad(tester);
      await _tapOfertar(tester);

      expect(find.text(_popupTitle), findsOneWidget);
    }, () => _fakeBackend(offers: [_offer()]));
  });

  testWidgets('el aviso no deja avanzar al formulario de ofertas', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await _pumpPropiedad(tester);
      await _tapOfertar(tester);

      expect(find.text(_popupTitle), findsOneWidget);
      // El formulario no se abrió: el aviso frena antes de navegar.
      expect(find.text(_formMarker), findsNothing);
    }, () => _fakeBackend(offers: [_offer()]));
  });

  testWidgets(
    'pide las ofertas con page y limit, que es lo que el backend exige',
    (tester) async {
      final requests = <Uri>[];

      await http.runWithClient(() async {
        await _pumpPropiedad(tester);
        await _tapOfertar(tester);

        final myOffers = requests
            .where((u) => u.path.endsWith('/offers/my-offers'))
            .toList();
        expect(myOffers, isNotEmpty);
        for (final url in myOffers) {
          expect(url.queryParameters['page'], isNotEmpty);
          expect(url.queryParameters['limit'], isNotEmpty);
        }
      }, () => _fakeBackend(offers: [_offer()], requests: requests));
    },
  );

  testWidgets('una oferta ya rechazada no bloquea una nueva', (tester) async {
    await http.runWithClient(() async {
      await _pumpPropiedad(tester);
      await _tapOfertar(tester);

      expect(find.text(_popupTitle), findsNothing);
      expect(find.text(_formMarker), findsOneWidget);
    }, () => _fakeBackend(offers: [_offer(offerStatus: 'REJECTED')]));
  });

  testWidgets('una oferta sobre otra propiedad no bloquea', (tester) async {
    await http.runWithClient(() async {
      await _pumpPropiedad(tester);
      await _tapOfertar(tester);

      expect(find.text(_popupTitle), findsNothing);
      expect(find.text(_formMarker), findsOneWidget);
    }, () => _fakeBackend(offers: [_offer(propertyId: 'otra-propiedad')]));
  });
}
