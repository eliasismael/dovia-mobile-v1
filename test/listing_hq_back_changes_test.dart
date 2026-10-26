import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/listing_hq_documents.dart';
import 'package:dovia/domain/property_media_zones.dart';
import 'package:dovia/domain/property_ownership_view.dart';

void main() {
  group('listerHqDocIdsToApprove', () {
    final docs = [
      {'id': 'contrato', 'status': 'SUBMITTED', 'url': 'https://s3/c.pdf'},
      {'id': 'dpi', 'status': 'approved', 'url': 'https://s3/d.pdf'},
      {'id': 'cert', 'status': 'missing', 'url': null},
      {'id': 'rechazado', 'status': 'rejected', 'url': 'https://s3/r.pdf'},
      {'documentId': 'custom', 'status': 'submitted', 'fileUrl': 'https://s3/x.pdf'},
    ];

    test('aprueba el abierto y los que tienen archivo y faltan aprobar', () {
      expect(listerHqDocIdsToApprove(docs, 'contrato'), ['contrato', 'custom']);
    });

    test('deja afuera aprobados, sin archivo y rechazados', () {
      final ids = listerHqDocIdsToApprove(docs, 'contrato');
      expect(ids, isNot(contains('dpi')));
      expect(ids, isNot(contains('cert')));
      expect(ids, isNot(contains('rechazado')));
    });

    test('el abierto entra aunque esté rechazado', () {
      expect(listerHqDocIdsToApprove(docs, 'rechazado').first, 'rechazado');
    });

    test('visita nueva: solo el contrato', () {
      expect(
        listerHqDocIdsToApprove(
            [{'id': 'contrato', 'status': 'submitted', 'url': 'u'}], 'contrato'),
        ['contrato'],
      );
    });
  });

  test('listerHqVisitDocs junta checklist y documentos sin repetir', () {
    final docs = listerHqVisitDocs({
      'visit': {
        'documentChecklist': [
          {'id': 'a'},
          {'id': 'b'},
        ],
        'documents': [
          {'documentId': 'b'},
          {'documentId': 'c'},
        ],
      },
    });
    expect(docs.map((d) => (d['id'] ?? d['documentId'])), ['a', 'b', 'c']);
  });

  group('ownershipView', () {
    test('formato viejo de empresa', () {
      final v = ownershipView({
        'isCompanyOwned': true,
        'companyName': 'Inmobiliaria SA',
        'legalRepresentative': 'Ana López',
      }, accountName: 'Juan');
      expect(v.ownerName, 'Inmobiliaria SA (empresa)');
      expect(v.representative, 'Ana López');
      expect(v.typeLabel, isEmpty);
    });

    test('formato viejo a nombre propio usa la cuenta', () {
      expect(ownershipView({'isCompanyOwned': false}, accountName: 'Juan').ownerName,
          'Juan');
    });

    test('nuevo a mi nombre', () {
      final v = ownershipView({
        'type': {'value': 'SELF', 'label': 'A mi nombre'},
        'owner': {'fullName': 'Juan Pérez'},
      }, accountName: 'Juan');
      expect(v.typeLabel, 'A mi nombre');
      expect(v.ownerName, 'Juan Pérez');
      expect(v.documents, isEmpty);
    });

    test('nuevo a nombre de otra persona', () {
      final v = ownershipView({
        'type': {'value': 'THIRD_PARTY', 'label': 'A nombre de otra persona'},
        'relationshipToOwner': {'value': 'PARENT', 'label': 'Padre o madre'},
        'owner': {'fullName': 'Rosa Pérez', 'identificationDocumentUrl': 'https://s3/dpi.pdf'},
      });
      expect(v.ownerName, 'Rosa Pérez');
      expect(v.relationship, 'Padre o madre');
      expect(v.documents.single.url, 'https://s3/dpi.pdf');
    });

    test('nuevo de sociedad', () {
      final v = ownershipView({
        'type': {'value': 'COMPANY', 'label': 'A nombre de una sociedad'},
        'company': {'name': 'Casas SA'},
        'legalRepresentative': {
          'fullName': 'Luis Gómez',
          'identificationDocumentUrl': 'https://s3/rep.pdf',
        },
      });
      expect(v.ownerName, 'Casas SA (empresa)');
      expect(v.representative, 'Luis Gómez');
      expect(v.documents.map((d) => d.url), ['https://s3/rep.pdf', '']);
    });

    test('solo el tipo (detalle de visita sin backoffice) usa la cuenta', () {
      final v = ownershipView({
        'type': {'value': 'COMPANY', 'label': 'A nombre de una sociedad'},
      }, accountName: 'Juan');
      expect(v.ownerName, 'Juan');
      expect(v.typeLabel, 'A nombre de una sociedad');
    });
  });

  group('zonas de fotos', () {
    test('sube con las claves de la web', () {
      expect(propertyZoneForSection('Habitaciones'), 'habitaciones');
      expect(propertyZoneForSection('Otras zonas'), 'otras-zonas');
      expect(propertyZoneForSection('Recorrido 360'), 'recorrido-360');
      expect(propertyZoneForSection('Baño de visitas'), 'bano-de-visitas');
    });

    test('lee claves viejas y nuevas en la misma sección', () {
      expect(propertySectionForZone('habitacion'), 'Habitaciones');
      expect(propertySectionForZone('habitaciones'), 'Habitaciones');
      expect(propertySectionForZone('otras'), 'Otras zonas');
      expect(propertySectionForZone('otras-zonas'), 'Otras zonas');
      expect(propertySectionForZone('recorrido-360'), 'Recorrido 360');
      expect(propertySectionForZone('frenteEdificio'), 'Fachada');
    });

    test('las zonas agregadas por el usuario se leen sin guiones', () {
      expect(propertySectionForZone('bano-de-visitas'), 'Bano de visitas');
    });

    test('ida y vuelta de las secciones fijas', () {
      for (final s in ['Foto principal', 'Habitaciones', 'Sala', 'Comedor', 'Cocina',
        'Otras zonas', 'Plano', 'Recorrido 360']) {
        expect(propertySectionForZone(propertyZoneForSection(s)), s);
      }
    });
  });
}
