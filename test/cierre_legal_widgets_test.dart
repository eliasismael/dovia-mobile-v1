import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/legal_closure_models.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/cierre_legal/calificar_agente_modal_widget.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/cierre_legal/documentos_legales_widget.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/cierre_legal/legal_professional_card_widget.dart';
import 'package:dovia/dovia_client/app/mis_ofertas/cierre_legal/reportar_problema_modal_widget.dart';

const _professional = LegalProfessional(
  role: LegalProfessionalRole.legalAssociate,
  fullName: 'Ana Lopez',
  avatarUrl: '',
  phone: '+50255555555',
  email: 'ana@dovia.com',
);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
    );

void main() {
  group('Tarjeta del profesional', () {
    testWidgets('en Finalizadas ofrece calificar y reportar', (tester) async {
      var rated = 0;
      var reported = 0;

      await _pump(
        tester,
        LegalProfessionalCardWidget(
          professional: _professional,
          onRate: () => rated++,
          onReport: () => reported++,
        ),
      );

      expect(find.text('Ana Lopez'), findsOneWidget);
      expect(find.text('Dovia Legal Associate'), findsOneWidget);

      await tester.tap(find.text('Calificar'));
      await tester.tap(find.textContaining('Reportar'));
      expect(rated, 1);
      expect(reported, 1);
    });

    testWidgets('en Calificadas las acciones desaparecen por completo',
        (tester) async {
      await _pump(
        tester,
        const LegalProfessionalCardWidget(professional: _professional),
      );

      expect(find.text('Ana Lopez'), findsOneWidget);
      expect(find.text('Calificar'), findsNothing);
      expect(find.textContaining('Reportar'), findsNothing);
    });

    testWidgets('con un envío en vuelo los controles quedan apagados',
        (tester) async {
      await _pump(
        tester,
        LegalProfessionalCardWidget(
          professional: _professional,
          onRate: () {},
          onReport: () {},
          enabled: false,
        ),
      );

      // Sacarlos de la pantalla haría saltar el alto de la tarjeta y se
      // leería como si el trámite ya estuviera calificado.
      final calificar = find.widgetWithText(FilledButton, 'Calificar');
      expect(calificar, findsOneWidget);
      expect(tester.widget<FilledButton>(calificar).onPressed, isNull);
      expect(find.textContaining('Reportar'), findsOneWidget);
    });

    testWidgets('sin teléfono ni correo no dibuja contacto rápido',
        (tester) async {
      await _pump(
        tester,
        const LegalProfessionalCardWidget(
          professional: LegalProfessional(
            role: LegalProfessionalRole.legalOfficer,
            fullName: 'Luis Ruiz',
            avatarUrl: '',
            phone: '',
            email: '',
          ),
        ),
      );

      expect(find.byIcon(Icons.phone_rounded), findsNothing);
      expect(find.byIcon(Icons.mail_outline_rounded), findsNothing);
    });
  });

  group('Modal Califica', () {
    testWidgets('Enviar espera a que haya estrellas', (tester) async {
      await _pump(
        tester,
        const CalificarAgenteModalWidget(professional: _professional),
      );

      final enviar = find.widgetWithText(FilledButton, 'Enviar');
      expect(tester.widget<FilledButton>(enviar).onPressed, isNull);

      await tester.tap(find.byTooltip('4'));
      await tester.pump();

      expect(tester.widget<FilledButton>(enviar).onPressed, isNotNull);
    });

    testWidgets('devuelve las estrellas y el comentario', (tester) async {
      CalificacionAgente? result;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showCalificarAgenteModal(context, _professional);
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('5'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Muy atenta');
      await tester.tap(find.widgetWithText(FilledButton, 'Enviar'));
      await tester.pumpAndSettle();

      expect(result?.stars, 5);
      expect(result?.comment, 'Muy atenta');
    });
  });

  group('Modal Reportar problemas', () {
    testWidgets('la descripción es obligatoria', (tester) async {
      await _pump(tester, const ReportarProblemaModalWidget());

      final enviar = find.widgetWithText(FilledButton, 'Enviar');
      expect(tester.widget<FilledButton>(enviar).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Nunca contestó');
      await tester.pump();

      expect(tester.widget<FilledButton>(enviar).onPressed, isNotNull);
    });
  });

  group('Bóveda de documentos', () {
    testWidgets('el listo se descarga y el pendiente muestra el reloj',
        (tester) async {
      final opened = <String>[];

      await _pump(
        tester,
        DocumentosLegalesWidget(
          documents: const [
            LegalDocument(
              label: 'Copia de Contratos',
              url: 'https://cdn/contrato.pdf',
              status: 'approved',
            ),
            LegalDocument(
              label: 'Copia de aviso a municipalidad',
              url: '',
              status: 'missing',
            ),
          ],
          onOpen: (document) => opened.add(document.label),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.download_outlined));
      expect(opened, ['Copia de Contratos']);
    });
  });
}
