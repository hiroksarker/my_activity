import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'activity_enums.dart';
import 'dart:convert';

class Activity {
  final String id;
  final String title;
  final String description;
  final String category;
  final ActivityType type;
  final ActivityStatus status;
  final ActivityPriority priority;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? recurrenceType;
  final DateTime? nextOccurrence;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.status,
    required this.priority,
    required this.timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.recurrenceType,
    this.nextOccurrence,
  }) : 
    createdAt = createdAt ?? timestamp,
    updatedAt = updatedAt ?? timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'recurrenceType': recurrenceType,
      'nextOccurrence': nextOccurrence?.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(map['createdAt'] as String);
    return Activity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ActivityType.expense,
      ),
      status: ActivityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ActivityStatus.active,
      ),
      priority: ActivityPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => ActivityPriority.regular,
      ),
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp'] as String)
          : createdAt,
      createdAt: createdAt,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      recurrenceType: map['recurrenceType'] as String?,
      nextOccurrence: map['nextOccurrence'] != null
          ? DateTime.parse(map['nextOccurrence'] as String)
          : null,
    );
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    ActivityType? type,
    ActivityStatus? status,
    ActivityPriority? priority,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? recurrenceType,
    DateTime? nextOccurrence,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.type == type &&
        other.status == status &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        type.hashCode ^
        status.hashCode ^
        priority.hashCode;
  }

  // UI helper methods
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transportation':
        return Icons.directions_car;
      case 'housing':
        return Icons.home;
      case 'utilities':
        return Icons.power;
      case 'entertainment':
        return Icons.movie;
      case 'healthcare':
        return Icons.medical_services;
      case 'travel':
        return Icons.flight;
      case 'education':
        return Icons.school;
      case 'personal care':
        return Icons.spa;
      case 'gifts & donations':
        return Icons.card_giftcard;
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.computer;
      case 'investment':
        return Icons.trending_up;
      case 'business':
        return Icons.business;
      case 'rental':
        return Icons.apartment;
      case 'gifts':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  Color get categoryColor {
    if (type != ActivityType.expense) return Colors.grey;
    
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Colors.orange;
      case 'shopping':
        return Colors.pink;
      case 'transportation':
        return Colors.blue;
      case 'housing':
        return Colors.purple;
      case 'utilities':
        return Colors.teal;
      case 'entertainment':
        return Colors.indigo;
      case 'healthcare':
        return Colors.red;
      case 'travel':
        return Colors.cyan;
      case 'education':
        return Colors.amber;
      case 'personal care':
        return Colors.lightGreen;
      case 'gifts & donations':
        return Colors.deepPurple;
      case 'salary':
        return Colors.green;
      case 'freelance':
        return Colors.blue;
      case 'investment':
        return Colors.orange;
      case 'business':
        return Colors.brown;
      case 'rental':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  DateTime getNextOccurrence() {
    if (recurrenceType == null) return createdAt;
    
    final now = DateTime.now();
    DateTime next = createdAt;
    
    while (next.isBefore(now)) {
      switch (recurrenceType) {
        case 'daily':
          next = next.add(const Duration(days: 1));
          break;
        case 'weekly':
          next = next.add(const Duration(days: 7));
          break;
        case 'monthly':
          next = DateTime(next.year, next.month + 1, next.day);
          break;
        case 'yearly':
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        default:
          return createdAt;
      }
    }
    
    return next;
  }

  // Add a method to check if activity is new (created within last 5 seconds)
  bool get isNew {
    final now = DateTime.now();
    return now.difference(createdAt).inSeconds < 5;
  }
} 