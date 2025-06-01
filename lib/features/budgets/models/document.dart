class Document {
  final int? id;
  final int tripId;
  final String type; // e.g., 'passport', 'ticket'
  final String filePath;
  final String description;

  Document({
    this.id,
    required this.tripId,
    required this.type,
    required this.filePath,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'type': type,
        'filePath': filePath,
        'description': description,
      };

  factory Document.fromMap(Map<String, dynamic> map) => Document(
        id: map['id'],
        tripId: map['tripId'],
        type: map['type'],
        filePath: map['filePath'],
        description: map['description'],
      );
}
