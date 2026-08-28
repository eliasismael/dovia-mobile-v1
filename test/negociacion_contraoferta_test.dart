import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dovia/domain/counter_offer_view.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/contraoferta/negociacion_contraoferta_widget.dart';
import 'package:dovia/repositories/offers_repository.dart';

CounterOfferView _view({bool withCounter = true}) =>
    CounterOfferView.fromJson({
      'offerId': 'offer-1',
      'offerType': 'SALE',
      'offerStatus': 'COUNTER_OFFER',
      'originalOfferData': const {
        'paymentMethod': 'mortgage',
        'currency': 'USD',
        'proposedAmount': 250000,
        'bankName': 'Banco Industrial',
        'downPaymentPercentage': 20,
      },
      if (withCounter)
        'counterOfferData': const {
          'paymentMethod': 'mortgage',
          'currency': 'USD',
          'proposedAmount': 270000,
          'bankName': 'Banrural',
          'downPaymentPercentage': 30,
        },
    });

/// La pantalla mide mas de 1000px de alto: con la superficie por defecto de
/// 800x600 el trilema queda fuera de vista y no se puede tapear.
Future<void> _pump(WidgetTester tester, {bool withCounter = true}) async {
  await tester.binding.setSurfaceSize(const Size(900, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  return tester.pumpWidget(
    ChangeNotifierProvider<OffersRepository>(
      create: (_) => OffersRepository(),
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NegociacionContraofertaWidget(
              offerId: 'offer-1',
              view: _view(withCounter: withCounter),
            ),
          ),
        ),
      ),
    ),
  );
}

FilledButton _filled(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, label));

void main() {
  testWidgets('enfrenta las dos propuestas con el trilema', (tester) async {
    await _pump(tester);

    expect(find.text('Tu propuesta'), findsOneWidget);
    expect(find.text('Propuesta del propietario'), findsOneWidget);
    expect(find.text('USD 250,000'), findsOneWidget);
    expect(find.text('USD 270,000'), findsOneWidget);
    expect(find.text('Rechazar'), findsOneWidget);
    expect(find.text('Contraoferta'), findsOneWidget);
    expect(find.text('Aceptar'), findsOneWidget);
  });

  testWidgets('sin respuesta del propietario no hay trilema', (tester) async {
    await _pump(tester, withCounter: false);

    expect(
      find.text('Esperando respuesta del propietario...'),
      findsOneWidget,
    );
    expect(find.text('Aceptar'), findsNothing);
  });

  group('Rechazo', () {
    testWidgets('el motivo se despliega al tapear y el trilema sigue visible',
        (tester) async {
      await _pump(tester);

      expect(find.text('¿Por qué rechazaste la oferta?'), findsNothing);

      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(find.text('¿Por qué rechazaste la oferta?'), findsOneWidget);
      expect(find.text('Aceptar'), findsOneWidget,
          reason: 'se tiene que poder cambiar de idea');
    });

    testWidgets('el motivo es obligatorio para confirmar', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(_filled(tester, 'Confirmar rechazo').onPressed, isNull);

      await tester.enterText(
          find.byType(TextField).last, 'El enganche es muy alto');
      await tester.pumpAndSettle();

      expect(_filled(tester, 'Confirmar rechazo').onPressed, isNotNull);
    });

    testWidgets('cancelar repliega el motivo y lo limpia', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'me arrepiento');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('¿Por qué rechazaste la oferta?'), findsNothing);

      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(find.text('me arrepiento'), findsNothing);
    });
  });

  group('Contraoferta', () {
    testWidgets('abre los campos de abajo con lo último propuesto',
        (tester) async {
      await _pump(tester);

      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('Contraoferta'));
      await tester.pumpAndSettle();

      // Banco, propuesta económica, enganche y solicitud adicional.
      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.widgetWithText(TextField, '270000'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Banrural'), findsOneWidget);
      expect(find.text('Enviar oferta'), findsOneWidget);
    });

    testWidgets('mientras se contraoferta no se acepta ni se rechaza',
        (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Contraoferta'));
      await tester.pumpAndSettle();

      expect(_filled(tester, 'Aceptar').onPressed, isNull);
      expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Rechazar'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('volver a tapear cierra el formulario', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Contraoferta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contraoferta'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Enviar oferta'), findsNothing);
    });
  });
}
