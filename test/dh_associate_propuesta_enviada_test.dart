import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/app_state.dart';
import 'package:dovia/dovia_home_associate/d_h_a_s_s_o_c_i_a_t_e_propuesta_enviada/d_h_a_s_s_o_c_i_a_t_e_propuesta_enviada_widget.dart';

Future<void> _signInAsCompany() async {
  SharedPreferences.setMockInitialValues(
      {'ff_UserRole': 'HOME_ASSOCIATE_COMPANY'});
  await FFAppState().initializePersistedState();
}

Map<String, dynamic> _proposal({
  String status = 'SUBMITTED',
  num? totalAmount = 1200,
  String? documentUrl = 'https://dovia.test/presupuesto.pdf',
  int? version = 1,
}) =>
    {
      'id': 'prop-1',
      'serviceRequestId': 'req-1',
      'proposalType': 'QUOTE',
      'status': status,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (documentUrl != null) 'documentUrl': documentUrl,
      if (documentUrl != null) 'originalFileName': 'presupuesto-tv.pdf',
      if (version != null) 'version': version,
    };

Map<String, dynamic> _request() => {
      'id': 'req-1',
      'requestType': 'QUOTE',
      'status': 'PENDING',
      'subStatus': 'QUOTE_QUOTING',
      'serviceDetail': {'label': 'Instalación de TV'},
    };

Future<void> _pumpProposal(
  WidgetTester tester, {
  required Map<String, dynamic> proposal,
  Map<String, dynamic>? request,
}) async {
  DHASSOCIATEPropuestaEnviadaWidget.proposalData = proposal;
  DHASSOCIATEPropuestaEnviadaWidget.requestData = request;

  await tester.pumpWidget(const MaterialApp(
    home: DHASSOCIATEPropuestaEnviadaWidget(),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    DHASSOCIATEPropuestaEnviadaWidget.proposalData = null;
    DHASSOCIATEPropuestaEnviadaWidget.requestData = null;
    FFAppState.reset();
  });

  testWidgets('muestra el presupuesto enviado sin ofrecer ninguna acción',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpProposal(tester, proposal: _proposal(), request: _request());

    expect(find.textContaining('Instalación de TV'), findsWidgets);
    expect(find.textContaining('Enviada.'), findsOneWidget);
    expect(find.text('Q1,200'), findsOneWidget);
    expect(find.text('presupuesto-tv.pdf'), findsOneWidget);
    // Es de sólo lectura: la propuesta ya salió y la decide el cliente.
    expect(find.text('Enviar propuesta'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('una propuesta rechazada dice que puede mandar otra versión',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpProposal(
      tester,
      proposal: _proposal(status: 'REJECTED', version: 2),
      request: _request(),
    );

    expect(find.textContaining('Rechazada.'), findsOneWidget);
    expect(find.textContaining('Versión 2'), findsOneWidget);
  });

  testWidgets('sin la solicitud explica por qué faltan fecha y zona',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpProposal(tester, proposal: _proposal());

    expect(
      find.textContaining('ya no está publicada'),
      findsOneWidget,
    );
  });

  testWidgets('sin monto ni PDF lo dice en vez de dejar las cajas vacías',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _signInAsCompany();
    await _pumpProposal(
      tester,
      proposal: _proposal(totalAmount: null, documentUrl: null),
      request: _request(),
    );

    expect(find.textContaining('no registró un monto'), findsOneWidget);
    expect(find.textContaining('No encontramos el PDF'), findsOneWidget);
  });
}
