class TripInfo {
  final int? id;
  final int tripId;
  final String type; // e.g., 'emergency', 'insurance', 'health', 'tip', 'language'
  final String value;
  final DateTime? endDate;  // New field for trip end date

  TripInfo({
    this.id,
    required this.tripId,
    required this.type,
    required this.value,
    this.endDate,  // New parameter
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'type': type,
        'value': value,
        'endDate': endDate?.toIso8601String(),  // New field
      };

  factory TripInfo.fromMap(Map<String, dynamic> map) => TripInfo(
        id: map['id'],
        tripId: map['tripId'],
        type: map['type'],
        value: map['value'],
        endDate: map['endDate'] != null 
            ? DateTime.parse(map['endDate'] as String)
            : null,  // Parse end date
      );

  // Helper method to check if trip can be deleted
  bool get canBeDeleted {
    if (endDate == null) return true;  // If no end date, can be deleted
    return DateTime.now().isBefore(endDate!);  // Can only delete if end date is in the future
  }

  // Helper method to get trip status
  String get status {
    if (endDate == null) return 'Active';
    if (DateTime.now().isAfter(endDate!)) return 'Completed';
    return 'Active';
  }
}
