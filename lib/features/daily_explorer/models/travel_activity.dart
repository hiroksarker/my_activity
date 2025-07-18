// Manual JSON serialization for now

enum ActivityType {
  flight,
  hotel,
  restaurant,
  attraction,
  transport,
  meeting,
  other
}

enum ActivityStatus {
  upcoming,
  active,
  completed,
  cancelled,
  delayed
}

class TravelActivity {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final ActivityType type;
  final ActivityStatus status;
  final String location;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic> details;
  final List<String> attachments;
  final List<String> notes;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TravelActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
    required this.location,
    this.latitude,
    this.longitude,
    required this.details,
    required this.attachments,
    required this.notes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelActivity.fromJson(Map<String, dynamic> json) {
    return TravelActivity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.other,
      ),
      status: ActivityStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ActivityStatus.upcoming,
      ),
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      attachments: List<String>.from(json['attachments'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['created'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'details': details,
      'attachments': attachments,
      'notes': notes,
      'userId': userId,
      'created': createdAt.toIso8601String(),
      'updated': updatedAt.toIso8601String(),
    };
  }

  TravelActivity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    ActivityType? type,
    ActivityStatus? status,
    String? location,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? details,
    List<String>? attachments,
    List<String>? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      details: details ?? this.details,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isActive => status == ActivityStatus.active;
  bool get isUpcoming => status == ActivityStatus.upcoming;
  bool get isCompleted => status == ActivityStatus.completed;
  bool get hasLocation => latitude != null && longitude != null;
  
  Duration get duration => endTime.difference(startTime);
  
  String get statusDisplayName {
    switch (status) {
      case ActivityStatus.upcoming:
        return 'Upcoming';
      case ActivityStatus.active:
        return 'Active';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
      case ActivityStatus.delayed:
        return 'Delayed';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ActivityType.flight:
        return 'Flight';
      case ActivityType.hotel:
        return 'Hotel';
      case ActivityType.restaurant:
        return 'Restaurant';
      case ActivityType.attraction:
        return 'Attraction';
      case ActivityType.transport:
        return 'Transport';
      case ActivityType.meeting:
        return 'Meeting';
      case ActivityType.other:
        return 'Other';
    }
  }
}