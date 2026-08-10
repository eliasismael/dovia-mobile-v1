import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_associate/associate_service_request_fields.dart';
import 'package:dovia/dovia_home_associate/company_quote_fields.dart';

Map<String, dynamic> _quote({
  String id = 'req-1',
  String status = 'PENDING',
  String subStatus = 'QUOTE_QUOTING',
  String label = 'Instalación de TV',
}) =>
    {
      'id': id,
      'requestType': 'QUOTE',
      'status': status,
      'subStatus': subStatus,
      'serviceDetail': {'label': label},
    };

Map<String, dynamic> _proposal({
  String id = 'prop-1',
  String serviceRequestId = 'req-1',
  String status = 'SUBMITTED',
  String? proposalType = 'QUOTE',
  String? description,
}) =>
    {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'status': status,
      if (proposalType != null) 'proposalType': proposalType,
      if (description != null) 'description': description,
    };

void main() {
  group('cqIsOpenForQuoting', () {
    test('una cotización PENDING con el marketplace abierto es oportunidad',
        () {
      expect(cqIsOpenForQuoting(_quote()), isTrue);
    });

    test('deja de serlo cuando el cliente ya eligió (TAKEN)', () {
      expect(cqIsOpenForQuoting(_quote(status: 'TAKEN')), isFalse);
    });

    test('un servicio estándar nunca es una oportunidad de cotización', () {
      final service = {
        'id': 'req-2',
        'requestType': 'SERVICE',
        'status': 'PENDING',
        'subStatus': 'QUOTE_QUOTING',
      };

      expect(cqIsOpenForQuoting(service), isFalse);
    });

    test('sin subStatus del flujo de cotización no está circulando', () {
      expect(cqIsOpenForQuoting(_quote(subStatus: '')), isFalse);
    });
  });

  group('cqIsWonProject', () {
    test('una cotización asignada y sin cerrar es un proyecto por ejecutar', () {
      expect(cqIsWonProject(_quote(status: 'TAKEN')), isTrue);
      expect(cqIsWonProject(_quote(status: 'IN_PROGRESS')), isTrue);
    });

    test('un trabajo terminado es historial, no pipeline', () {
      expect(cqIsWonProject(_quote(status: 'FINISHED')), isFalse);
    });
  });

  group('cqQuotedRequestIds', () {
    test('marca los servicios con propuesta viva o aceptada', () {
      final ids = cqQuotedRequestIds([
        _proposal(serviceRequestId: 'req-1'),
        _proposal(
            id: 'prop-2', serviceRequestId: 'req-2', status: 'ACCEPTED'),
      ]);

      expect(ids, {'req-1', 'req-2'});
    });

    test('una propuesta rechazada devuelve la oportunidad al carril activo', () {
      // Tras el rechazo la empresa puede mandar una versión nueva, así que el
      // servicio tiene que volver a aparecer entre las oportunidades.
      final ids = cqQuotedRequestIds([
        _proposal(status: 'REJECTED'),
      ]);

      expect(ids, isEmpty);
    });

    test('ignora las propuestas de trabajo fuera de alcance', () {
      // El listado del proveedor mezcla las dos familias; el panel de
      // cotizaciones sólo habla de QUOTE.
      final ids = cqQuotedRequestIds([
        {
          'id': 'prop-3',
          'serviceRequestId': 'req-9',
          'status': 'SUBMITTED',
          'proposalType': 'OUT_OF_SCOPE',
        },
      ]);

      expect(ids, isEmpty);
    });
  });

  group('cqSubmittedQuoteProposals', () {
    test('sólo las que esperan decisión del cliente', () {
      final submitted = cqSubmittedQuoteProposals([
        _proposal(id: 'p1'),
        _proposal(id: 'p2', status: 'ACCEPTED'),
        _proposal(id: 'p3', status: 'REJECTED'),
      ]);

      expect(submitted.map((p) => p['id']), ['p1']);
    });

    test('descarta las de fuera de alcance por outOfScopeRequestId', () {
      // El listado por servicio no manda `proposalType`: se deduce del campo
      // que sólo existe en el DTO de fuera de alcance.
      final submitted = cqSubmittedQuoteProposals([
        {
          'id': 'p1',
          'serviceRequestId': 'req-1',
          'status': 'SUBMITTED',
          'outOfScopeRequestId': 'oos-1',
        },
      ]);

      expect(submitted, isEmpty);
    });
  });

  group('cqProposalTitle', () {
    test('toma el nombre del servicio cruzando contra el marketplace', () {
      final byId = cqRequestsById([_quote(label: 'Instalación de muebles')]);

      expect(cqProposalTitle(_proposal(), byId), 'Instalación de muebles');
    });

    test('cae en la descripción cuando el servicio ya no está en el listado',
        () {
      expect(
        cqProposalTitle(
          _proposal(serviceRequestId: 'req-borrado', description: 'Remodelación'),
          const {},
        ),
        'Remodelación',
      );
    });

    test('etiqueta genérica antes que una tarjeta sin título', () {
      expect(cqProposalTitle(_proposal(), const {}), 'Cotización enviada');
    });
  });

  group('cqEarningsLabel', () {
    test('sin monto dice que lo define la propuesta, no inventa un número', () {
      expect(cqEarningsLabel(_quote()), 'Ganancia: la defines en tu propuesta');
    });

    test('con neto del backend usa el formato del resto del asociado', () {
      final data = _quote()..['associatePayout'] = 1200;

      expect(cqEarningsLabel(data), 'Podrás ganar: Q1,200');
    });
  });

  group('asrIsWorkableByCompany', () {
    test('la empresa sólo trabaja cotizaciones', () {
      expect(asrIsWorkableByCompany(_quote()), isTrue);
      expect(
        asrIsWorkableByCompany({'requestType': 'SERVICE'}),
        isFalse,
      );
      expect(
        asrIsWorkableByCompany({'requestType': 'EMERGENCY'}),
        isFalse,
      );
    });
  });

  group('asrRequestImages', () {
    test('lee las fotos que mandó el cliente en requestImageUrls', () {
      final data = _quote()
        ..['requestImageUrls'] = ['https://x/1.jpg', 'https://x/2.jpg'];

      expect(asrRequestImages(data), ['https://x/1.jpg', 'https://x/2.jpg']);
    });

    test('acepta la forma anidada del marketplace', () {
      final data = _quote()
        ..['imageUrls'] = [
          {'url': 'https://x/3.jpg'}
        ];

      expect(asrRequestImages(data), ['https://x/3.jpg']);
    });

    test('sin fotos devuelve vacío en vez de una lista con nulos', () {
      expect(asrRequestImages(_quote()), isEmpty);
    });
  });
}
