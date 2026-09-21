import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dovia/flutter_flow/flutter_flow_util.dart';
import 'package:dovia/main.dart';
import 'package:dovia/repositories/index.dart';

void main() {
  testWidgets('la app arranca y monta el router', (tester) async {
    // `MyApp` lee sus repositorios del árbol de providers que arma `main()`;
    // montarla suelta hace estallar un ProviderNotFoundException, así que acá
    // se reproduce el mismo árbol.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FFAppState()),
        ChangeNotifierProvider(create: (_) => FavoritesRepository()),
        ChangeNotifierProvider(create: (_) => PropertiesRepository()),
        ChangeNotifierProvider(create: (_) => UserRepository()),
        ChangeNotifierProvider(create: (_) => VisitsRepository()),
        ChangeNotifierProvider(create: (_) => OffersRepository()),
        ChangeNotifierProvider(create: (_) => PaymentsRepository()),
        ChangeNotifierProvider(create: (_) => NotificationsRepository()),
      ],
      child: const MyApp(),
    ));

    // `initState` apaga el splash con un `Future.delayed` de 500 ms. Hay que
    // dejarlo cumplir: si el test termina antes, el binding falla por un timer
    // todavía vivo después de desmontar el árbol.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
