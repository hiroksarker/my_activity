class TripInfo {
  final int? id;
  final int tripId;
  final String type; // e.g., 'emergency', 'insurance', 'health', 'tip', 'language'
  final String value;

  TripInfo({
    this.id,
    required this.tripId,
    required this.type,
    required this.value,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'type': type,
        'value': value,
      };

  factory TripInfo.fromMap(Map<String, dynamic> map) => TripInfo(
        id: map['id'],
        tripId: map['tripId'],
        type: map['type'],
        value: map['value'],
      );
}
