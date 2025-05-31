import 'package:uuid/uuid.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final double amount;
  final String status;

  Activity({
    String? id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.amount,
    required this.status,
  }) : id = id ?? const Uuid().v4();

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? const Uuid().v4(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'status': status,
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    double? amount,
    String? status,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }
} 