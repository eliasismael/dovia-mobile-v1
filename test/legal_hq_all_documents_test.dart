import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/legal_hq/legal_hq_process_data.dart';

LegalHqDocument _doc(Map<String, dynamic> json, {bool fromVisit = false}) =>
    LegalHqDocument.fromJson(json, fromVisit: fromVisit);

LegalHqProcessDetail _detail(
  List<LegalHqDocument> documents, [
  List<LegalHqDocument> visitDocuments = const [],
]) =>
    LegalHqProcessDetail(
      process: const LegalHqProcess(
        id: 'p1',
        category: 'SALE',
        status: 'LEGAL_HQ_REVIEW',
        propertyId: 'prop1',
        isAssignedToMe: true,
      ),
      documents: documents,
      visitDocuments: visitDocuments,
    );

void main() {
  test('lee los ítems del checklist de la visita', () {
    final doc = _doc({
      'documentId': 'v1',
      'label': 'DPI del propietario',
      'status': 'APPROVED',
      'fileUrl': 'https://x/dpi.pdf',
    }, fromVisit: true);

    expect(doc.id, 'v1');
    expect(doc.status, 'approved');
    expect(doc.hasFile, isTrue);
    expect(legalHqDocumentProgress(doc).label, 'Aprobado por Lister HQ');
  });

  test('la grilla muestra todos los documentos, con o sin archivo', () {
    final detail = _detail([
      _doc({'id': 'a', 'label': 'DPI del comprador', 'status': 'missing'}),
      _doc({'id': 'b', 'label': 'Recibo', 'status': 'submitted', 'url': 'u'}),
      _doc({
        'id': 'c',
        'label': 'Contrato borrador',
        'status': 'submitted',
        'url': 'u',
      }),
    ], [
      _doc({'id': 'v1', 'label': 'DPI del propietario', 'status': 'approved'},
          fromVisit: true),
    ]);

    expect(
      detail.reviewableDocuments.map((d) => d.id),
      ['a', 'b', 'v1'],
    );
    expect(detail.contractVersions.map((v) => v.document.id), ['c']);
  });

  test('no repite los documentos de la visita ya copiados al expediente', () {
    final detail = _detail([
      _doc({'id': 'a', 'label': 'DPI del propietario', 'status': 'approved'}),
    ], [
      _doc({'id': 'v1', 'label': 'DPI del Propietario ', 'status': 'approved'},
          fromVisit: true),
      _doc({'id': 'v2', 'label': 'Escritura', 'status': 'rejected'},
          fromVisit: true),
    ]);

    expect(detail.allDocuments.map((d) => d.id), ['a', 'v2']);
  });

  test('la hipoteca muestra todo salvo los slots del convenio', () {
    final detail = _detail([
      _doc({
        'id': 'a',
        'type': 'INTERESTED_CLIENT_ID_DOCUMENT',
        'label': 'DPI del comprador',
        'status': 'missing',
      }),
      _doc({
        'id': 'b',
        'type': 'DOVIA_AGREEMENT_UNSIGNED',
        'label': 'Convenio',
        'status': 'missing',
      }),
    ]);

    expect(detail.mortgageEvidenceDocuments().map((d) => d.id), ['a']);
  });
}
