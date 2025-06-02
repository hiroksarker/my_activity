import 'package:uuid/uuid.dart';
import 'activity_enums.dart';
import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final double? amount;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ActivityType type;
  final ActivityStatus status;
  final TransactionType? transactionType;
  final bool isRecurring;
  final String? recurrenceType;
  final DateTime? nextOccurrence;
  final String? recurrenceRule;
  final String? metadata;
  final String? imageUrl;

  Activity({
    String? id,
    required this.title,
    required this.description,
    this.amount,
    required this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.type,
    required this.status,
    this.transactionType,
    this.isRecurring = false,
    this.recurrenceType,
    this.nextOccurrence,
    this.recurrenceRule,
    this.metadata,
    this.imageUrl,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double?,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ActivityType.task,
      ),
      status: ActivityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ActivityStatus.active,
      ),
      transactionType: map['transactionType'] != null
          ? TransactionType.values.firstWhere(
              (e) => e.toString().split('.').last == map['transactionType'],
              orElse: () => TransactionType.debit,
            )
          : null,
      isRecurring: (map['isRecurring'] as int?) == 1,
      recurrenceType: map['recurrenceType'] as String?,
      nextOccurrence: map['nextOccurrence'] != null 
          ? DateTime.parse(map['nextOccurrence'] as String)
          : null,
      recurrenceRule: map['recurrenceRule'] as String?,
      metadata: map['metadata'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'transactionType': transactionType?.toString().split('.').last,
      'isRecurring': isRecurring ? 1 : 0,
      'recurrenceType': recurrenceType,
      'nextOccurrence': nextOccurrence?.toIso8601String(),
      'recurrenceRule': recurrenceRule,
      'metadata': metadata,
      'imageUrl': imageUrl,
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    ActivityType? type,
    ActivityStatus? status,
    TransactionType? transactionType,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? nextOccurrence,
    String? recurrenceRule,
    String? metadata,
    String? imageUrl,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      status: status ?? this.status,
      transactionType: transactionType ?? this.transactionType,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  DateTime getNextOccurrence() {
    if (!isRecurring || recurrenceType == null) return createdAt;
    
    final now = DateTime.now();
    DateTime next = createdAt;
    
    while (next.isBefore(now)) {
      switch (recurrenceType) {
        case 'Daily':
          next = next.add(const Duration(days: 1));
          break;
        case 'Weekly':
          next = next.add(const Duration(days: 7));
          break;
        case 'Monthly':
          next = DateTime(next.year, next.month + 1, next.day);
          break;
        case 'Yearly':
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        default:
          return createdAt;
      }
    }
    
    return next;
  }

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, type: $type, status: $status)';
  }

  // Add getters for UI properties
  DateTime get timestamp => createdAt;
  
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
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Colors.orange;
      case 'shopping':
        return Colors.pink;
      case 'transportation':
        return Colors.blue;
      case 'housing':
        return Colors.brown;
      case 'utilities':
        return Colors.amber;
      case 'entertainment':
        return Colors.purple;
      case 'healthcare':
        return Colors.red;
      case 'travel':
        return Colors.cyan;
      case 'education':
        return Colors.indigo;
      case 'personal care':
        return Colors.teal;
      case 'gifts & donations':
        return Colors.deepPurple;
      case 'salary':
        return Colors.green;
      case 'freelance':
        return Colors.lightBlue;
      case 'investment':
        return Colors.lightGreen;
      case 'business':
        return Colors.blueGrey;
      case 'rental':
        return Colors.deepOrange;
      case 'gifts':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
} 