import 'package:uuid/uuid.dart';

class Activity {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final double progress;
  final String? notes;

  Activity({
    String? id,
    required this.title,
    required this.category,
    required this.date,
    required this.progress,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
      'progress': progress,
      'notes': notes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      progress: map['progress'] as double,
      notes: map['notes'] as String?,
    );
  }

  Activity copyWith({
    String? title,
    String? category,
    DateTime? date,
    double? progress,
    String? notes,
  }) {
    return Activity(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      progress: progress ?? this.progress,
      notes: notes ?? this.notes,
    );
  }
} 