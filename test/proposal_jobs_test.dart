import 'package:flutter_test/flutter_test.dart';

import 'package:dovia/dovia_home_client/proposal_fields.dart';
import 'package:dovia/dovia_home_client/quote_proposals_nav.dart';

Map<String, dynamic> _p(
  String id,
  String requestId, {
  String status = 'SUBMITTED',
  String? description,
  String createdAt = '2026-10-20T15:00:00.000Z',
  bool? active,
  String type = 'QUOTE',
}) =>
    {
      'id': id,
      'serviceRequestId': requestId,
      'proposalType': type,
      'status': status,
      'createdAt': createdAt,
      if (description != null) 'description': description,
      if (active != null) 'active': active,
    };

void main() {
  test('agrupa las propuestas por trabajo, en el orden en que llegaron', () {
    final jobs = groupProposalsByJob([
      _p('a', 'r1', description: 'Pintar la sala'),
      _p('b', 'r2', description: 'Cambiar el calentador'),
      _p('c', 'r1', description: 'Pintar la sala'),
    ]);
    expect(jobs.map((j) => j.key), ['r1', 'r2']);
    expect(jobs.first.proposals.map(proposalId), ['a', 'c']);
    expect(jobs.first.description, 'Pintar la sala');
  });

  test('aceptada una, las demás del trabajo quedan rechazadas', () {
    final job = groupProposalsByJob([
      _p('a', 'r1', status: 'ACCEPTED'),
      _p('b', 'r1'),
    ]).single;
    expect(job.hasAccepted, isTrue);
    expect(job.statusLabel(job.proposals[0]), 'Aceptada');
    expect(job.statusLabel(job.proposals[1]), 'Rechazada');
    expect(job.canDecide(job.proposals[1]), isFalse);
    expect(job.jobStatusLabel, 'Aceptada');
  });

  test('una propuesta desactivada por el backend no se puede elegir', () {
    final job = groupProposalsByJob([
      _p('a', 'r1', active: false),
      _p('b', 'r1'),
    ]).single;
    expect(job.canDecide(job.proposals[0]), isFalse);
    expect(job.canDecide(job.proposals[1]), isTrue);
    expect(job.jobStatusLabel, 'Pendiente');
  });

  test('la tarjeta muestra el envío más reciente', () {
    final job = groupProposalsByJob([
      _p('a', 'r1', createdAt: '2026-10-20T15:00:00.000Z'),
      _p('b', 'r1', createdAt: '2026-10-22T15:00:00.000Z'),
    ]).single;
    expect(job.lastSentAt, DateTime.utc(2026, 10, 22, 15).toLocal());
    expect(proposalSentDateLabel(job.proposals.first), isNotNull);
  });

  test('reconoce los trabajos fuera de alcance', () {
    final job =
        groupProposalsByJob([_p('a', 'child', type: 'OUT_OF_SCOPE')]).single;
    expect(job.isOutOfScope, isTrue);
  });

  test('sólo una cotización sin decidir puede tener propuestas abiertas', () {
    expect(
        srMayHaveOpenProposals({'requestType': 'QUOTE', 'status': 'PENDING'}),
        isTrue);
    expect(srMayHaveOpenProposals({'requestType': 'QUOTE', 'status': 'TAKEN'}),
        isFalse);
    expect(
        srMayHaveOpenProposals({'requestType': 'SERVICE', 'status': 'PENDING'}),
        isFalse);
  });
}
