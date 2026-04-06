// Domain models for property visits.

class VisitTimeSlot {
  final String date;
  final String hour;

  const VisitTimeSlot({required this.date, required this.hour});

  Map<String, dynamic> toJson() => {'date': date, 'hour': hour};
}

class Visit {
  final String id;
  final String propertyId;
  final String? propertyName;
  final String? propertyAddress;
  final String status;
  final List<VisitTimeSlot> proposedSlots;
  final VisitTimeSlot? confirmedSlot;
  final String? instructions;
  final String? createdAt;

  const Visit({
    required this.id,
    required this.propertyId,
    this.propertyName,
    this.propertyAddress,
    required this.status,
    required this.proposedSlots,
    this.confirmedSlot,
    this.instructions,
    this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    final slots = (json['proposedTimeSlots'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((s) => VisitTimeSlot(
              date: s['date'] as String? ?? '',
              hour: s['hour'] as String? ?? '',
            ))
        .toList();

    final confirmed = json['confirmedSlot'] as Map<String, dynamic>?;

    return Visit(
      id: json['id'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      propertyName: json['property']?['name'] as String?,
      propertyAddress:
          json['property']?['location']?['address']?['fullAddress'] as String?,
      status: json['status'] as String? ?? '',
      proposedSlots: slots,
      confirmedSlot: confirmed != null
          ? VisitTimeSlot(
              date: confirmed['date'] as String? ?? '',
              hour: confirmed['hour'] as String? ?? '',
            )
          : null,
      instructions: json['instructions'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
