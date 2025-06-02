class Document {
  final int? id;
  final int tripId;
  final String type;
  final String filePath;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? uploadedBy;
  final String? mimeType;
  final int? fileSize;

  Document({
    this.id,
    required this.tripId,
    required this.type,
    required this.filePath,
    required this.description,
    DateTime? createdAt,
    this.updatedAt,
    this.uploadedBy,
    this.mimeType,
    this.fileSize,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'type': type,
        'filePath': filePath,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'uploadedBy': uploadedBy,
        'mimeType': mimeType,
        'fileSize': fileSize,
      };

  factory Document.fromMap(Map<String, dynamic> map) => Document(
        id: map['id'],
        tripId: map['tripId'],
        type: map['type'],
        filePath: map['filePath'],
        description: map['description'],
        createdAt: DateTime.parse(map['createdAt']),
        updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
        uploadedBy: map['uploadedBy'],
        mimeType: map['mimeType'],
        fileSize: map['fileSize'],
      );

  Document copyWith({
    int? id,
    int? tripId,
    String? type,
    String? filePath,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? uploadedBy,
    String? mimeType,
    int? fileSize,
  }) =>
      Document(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        type: type ?? this.type,
        filePath: filePath ?? this.filePath,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        uploadedBy: uploadedBy ?? this.uploadedBy,
        mimeType: mimeType ?? this.mimeType,
        fileSize: fileSize ?? this.fileSize,
      );
} 