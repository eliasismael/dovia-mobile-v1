import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/domain/listing_hq_documents.dart';
import 'package:dovia/domain/property_media_zones.dart';
import 'package:dovia/domain/property_ownership_view.dart';
import 'package:dovia/domain/property_types.dart';
import 'package:dovia/operative_listing/operative_next_visit.dart';

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
      expect(v.documents.map((d) => d.name), ['DPI del propietario']);
    });

    test('nuevo a nombre de otra persona', () {
      final v = ownershipView({
        'type': {'value': 'THIRD_PARTY', 'label': 'A nombre de otra persona'},
        'relationshipToOwner': {'value': 'PARENT', 'label': 'Padre o madre'},
        'owner': {
          'fullName': 'Rosa Pérez',
          'identification': {
            'type': {'value': 'PASSPORT', 'label': 'Pasaporte'},
          },
          'identificationDocumentUrl': 'https://s3/dpi.pdf',
        },
        'submitter': {'identificationDocumentUrl': 'https://s3/mio.pdf'},
      });
      expect(v.ownerName, 'Rosa Pérez');
      expect(v.relationship, 'Padre o madre');
      expect(v.documents.map((d) => (d.name, d.url)), [
        ('Pasaporte del propietario', 'https://s3/dpi.pdf'),
        ('DPI de quien registra', 'https://s3/mio.pdf'),
      ]);
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

  group('ownershipSections', () {
    Map<String, dynamic> person(String name) => {
          'fullName': name,
          'sex': {'value': 'FEMALE', 'label': 'Femenino'},
          'age': 40,
          'nationality': 'Guatemalteca',
          'maritalStatus': {'value': 'MARRIED', 'label': 'Casado(a)'},
          'identification': {
            'type': {'value': 'DPI', 'label': 'DPI'},
            'number': '1234 56789 0101',
          },
          'occupation': 'Abogada',
          'nit': '1234567-8',
        };

    String row(OwnershipSection s, String label) =>
        s.rows.firstWhere((r) => r.$1 == label).$2;

    test('a mi nombre: los datos del titular con el nombre de la cuenta', () {
      final sections = ownershipSections({
        'type': {'value': 'SELF', 'label': 'A mi nombre'},
        'owner': {...person(''), 'fullName': ''},
      }, accountName: 'Juan Pérez');
      expect(sections.map((s) => s.title), ['Datos del titular']);
      expect(row(sections.single, 'Nombre'), 'Juan Pérez');
      expect(row(sections.single, 'Estado civil'), 'Casado(a)');
      expect(row(sections.single, 'Número de documento'), '1234 56789 0101');
    });

    test('a nombre de otra persona: propietario y quien registra', () {
      final sections = ownershipSections({
        'type': {'value': 'THIRD_PARTY', 'label': 'A nombre de otra persona'},
        'relationshipToOwner': {'value': 'CHILD', 'label': 'Hijo(a)'},
        'owner': {...person('Rosa Pérez'), 'phone': '+502 5555 1234'},
        'submitter': person(''),
      }, accountName: 'Juan Pérez');
      expect(sections.map((s) => s.title),
          ['Datos del propietario', 'Datos de quien registra']);
      expect(row(sections[0], 'Teléfono'), '+502 5555 1234');
      expect(row(sections[0], 'Sexo'), 'Femenino');
      expect(row(sections[1], 'Relación con el propietario'), 'Hijo(a)');
      expect(row(sections[1], 'Nombre'), 'Juan Pérez');
    });

    test('sociedad: sociedad, registro, representante, acta y nombramiento',
        () {
      final sections = ownershipSections({
        'type': {'value': 'COMPANY', 'label': 'A nombre de una sociedad'},
        'company': {
          'name': 'Casas SA',
          'nit': '999',
          'commercialRegistry': {
            'number': '10',
            'folio': '20',
            'book': '30',
            'isElectronicBook': true,
          },
        },
        'legalRepresentative': person('Luis Gómez'),
        'legalRepresentativeAppointment': {
          'notarialAct': {
            'city': 'Guatemala',
            'date': '2026-01-15',
            'notaryName': 'Ana Ruiz',
          },
          'commercialRegistry': {
            'number': '1',
            'folio': '2',
            'book': '3',
            'registrationDate': '2026-02-01',
          },
          'termYears': 5,
        },
      });
      expect(sections.map((s) => s.title), [
        'Datos de la sociedad',
        'Inscripción en el Registro Mercantil',
        'Representante legal',
        'Acta notarial',
        'Inscripción del nombramiento',
      ]);
      expect(row(sections[1], 'Libro electrónico'), 'Sí');
      expect(row(sections[3], 'Nombre del notario'), 'Ana Ruiz');
      expect(row(sections[4], 'Plazo en años'), '5');
    });

    test('formato viejo: sin secciones', () {
      expect(ownershipSections({'isCompanyOwned': false}), isEmpty);
    });
  });

  test('título corto: tipo y zona', () {
    expect(
      propertyShortTitle({
        'propertyType': 'APARTMENT',
        'location': {
          'address': {
            'fullAddress': '4 Avenida 9-1, Zona 15, Ciudad de Guatemala',
          },
        },
      }),
      'Apartamento en Zona 15',
    );
    expect(
      propertyShortTitle({
        'propertyType': 'HOUSE',
        'location': {
          'address': {'zone': '10'},
        },
      }),
      'Casa en Zona 10',
    );
    expect(propertyShortTitle({'name': 'Algo'}, fallback: 'Algo'), 'Algo');
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

  group('próxima visita del Operative', () {
    final now = DateTime(2026, 10, 26, 12);
    Map visit(String id, String date, String time) => {
          'id': id,
          'confirmedSlot': {'date': date, 'time': time},
        };

    test('elige la más cercana que sigue en plazo', () {
      expect(
        OperativeNextVisit.nextVisitIdFrom([
          visit('lejana', '2026-10-30', '10:00'),
          visit('cercana', '2026-10-27', '11:00'),
          visit('vencida', '2026-10-24', '09:00'),
        ], now),
        'cercana',
      );
    });

    test('sin visitas en plazo no hay botón', () {
      expect(
        OperativeNextVisit.nextVisitIdFrom(
            [visit('vencida', '2026-10-24', '09:00'), {'id': 'sin-horario'}], now),
        isNull,
      );
    });
  });
}
