// Manual JSON serialization for now

enum MemoryType {
  photo,
  note,
  voice,
  video
}

class TravelMemory {
  final String id;
  final String activityId;
  final MemoryType type;
  final String title;
  final String content;
  final String? filePath;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<String> tags;
  final DateTime timestamp;
  final String userId;
  final Map<String, dynamic> metadata;

  const TravelMemory({
    required this.id,
    required this.activityId,
    required this.type,
    required this.title,
    required this.content,
    this.filePath,
    required this.location,
    this.latitude,
    this.longitude,
    required this.tags,
    required this.timestamp,
    required this.userId,
    required this.metadata,
  });

  factory TravelMemory.fromJson(Map<String, dynamic> json) {
    return TravelMemory(
      id: json['id'] ?? '',
      activityId: json['activityId'] ?? '',
      type: MemoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MemoryType.note,
      ),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      filePath: json['filePath'],
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'type': type.name,
      'title': title,
      'content': content,
      'filePath': filePath,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
    };
  }

  TravelMemory copyWith({
    String? id,
    String? activityId,
    MemoryType? type,
    String? title,
    String? content,
    String? filePath,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? tags,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return TravelMemory(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get hasFile => filePath != null && filePath!.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;
  bool get isPhoto => type == MemoryType.photo;
  bool get isNote => type == MemoryType.note;
  bool get isVoice => type == MemoryType.voice;
  bool get isVideo => type == MemoryType.video;

  String get typeDisplayName {
    switch (type) {
      case MemoryType.photo:
        return 'Photo';
      case MemoryType.note:
        return 'Note';
      case MemoryType.voice:
        return 'Voice Recording';
      case MemoryType.video:
        return 'Video';
    }
  }

  String get displayContent {
    if (content.isNotEmpty) return content;
    if (hasFile) return 'Tap to view ${typeDisplayName.toLowerCase()}';
    return 'No content';
  }
}