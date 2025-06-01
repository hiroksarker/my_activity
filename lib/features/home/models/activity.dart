import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

enum ActivityType {
  task,
  income,
  expense,
  transfer,
}

enum ActivityStatus {
  active,
  completed,
  cancelled,
  archived,
}

enum TransactionType {
  debit,  // Money spent (expense)
  credit, // Money received (income)
}

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
  final TransactionType transactionType;
  final bool isRecurring;
  final String? recurrenceType;
  final DateTime? nextOccurrence;
  final String? recurrenceRule;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    this.amount,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.type = ActivityType.expense,
    this.status = ActivityStatus.active,
    this.transactionType = TransactionType.debit,
    this.isRecurring = false,
    this.recurrenceType,
    this.nextOccurrence,
    this.recurrenceRule,
    this.metadata,
  });

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
    Map<String, dynamic>? metadata,
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
      'type': type.toString(),
      'status': status.toString(),
      'transactionType': transactionType.toString(),
      'isRecurring': isRecurring ? 1 : 0,
      'recurrenceType': recurrenceType,
      'nextOccurrence': nextOccurrence?.toIso8601String(),
      'recurrenceRule': recurrenceRule,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  Map<String, dynamic> toJson() => toMap();

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
        (e) => e.toString() == map['type'],
        orElse: () => ActivityType.expense,
      ),
      status: ActivityStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ActivityStatus.active,
      ),
      transactionType: TransactionType.values.firstWhere(
        (e) => e.toString() == map['transactionType'],
        orElse: () => TransactionType.debit,
      ),
      isRecurring: (map['isRecurring'] as int?) == 1,
      recurrenceType: map['recurrenceType'] as String?,
      nextOccurrence: map['nextOccurrence'] != null
          ? DateTime.parse(map['nextOccurrence'] as String)
          : null,
      recurrenceRule: map['recurrenceRule'] as String?,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, description: $description, amount: $amount, category: $category, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.amount == amount &&
        other.category == category &&
        other.type == type &&
        other.status == status &&
        other.transactionType == transactionType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        type.hashCode ^
        status.hashCode ^
        transactionType.hashCode;
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
        return Colors.purple;
      case 'business':
        return Colors.orange;
      case 'rental':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData get categoryIcon {
    if (type != ActivityType.expense) return Icons.task;
    
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_cart;
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
      default:
        return Icons.category;
    }
  }

  DateTime? getNextOccurrence() {
    if (recurrenceRule == null) return null;
    
    final now = DateTime.now();
    final parts = recurrenceRule!.split(' ');
    final frequency = parts[0];
    final interval = int.parse(parts[1]);
    final day = parts[2];
    final month = parts[3];
    final year = parts[4];

    DateTime? nextDate;
    if (frequency == 'daily') {
      nextDate = DateTime(now.year, now.month, now.day + interval);
    } else if (frequency == 'weekly') {
      nextDate = DateTime(now.year, now.month, now.day + interval * 7);
    } else if (frequency == 'monthly') {
      nextDate = DateTime(now.year, now.month + interval, now.day);
    } else if (frequency == 'yearly') {
      nextDate = DateTime(now.year + interval, now.month, now.day);
    }

    if (nextDate != null) {
      if (day != 'every' && day != '*') {
        final dayOfWeek = DateTime.parse(day).weekday;
        final currentDayOfWeek = nextDate.weekday;
        final daysToAdd = (dayOfWeek - currentDayOfWeek + 7) % 7;
        nextDate = nextDate.add(Duration(days: daysToAdd));
      }

      if (month != 'every' && month != '*') {
        final currentMonth = nextDate.month;
        final monthsToAdd = int.parse(month) - currentMonth;
        nextDate = nextDate.add(Duration(days: monthsToAdd * 30));
      }

      if (year != 'every' && year != '*') {
        final currentYear = nextDate.year;
        final yearsToAdd = int.parse(year) - currentYear;
        nextDate = nextDate.add(Duration(days: yearsToAdd * 365));
      }
    }

    return nextDate;
  }

  DateTime get timestamp => createdAt;
} 