import 'package:flutter/material.dart';

class Income {
  final String id;
  final String title;
  final String source; // e.g., 'salary', 'freelance', 'investment', 'other'
  final double amount;
  final DateTime date;
  final String? description;
  final String currency;
  final bool isRecurring;
  final String? recurrenceType; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime? nextOccurrence;
  final Map<String, dynamic>? metadata; // Additional data like tax, deductions, etc.

  Income({
    required this.id,
    required this.title,
    required this.source,
    required this.amount,
    required this.date,
    this.description,
    this.currency = 'USD',
    this.isRecurring = false,
    this.recurrenceType,
    this.nextOccurrence,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'source': source,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
    'currency': currency,
    'isRecurring': isRecurring,
    'recurrenceType': recurrenceType,
    'nextOccurrence': nextOccurrence?.toIso8601String(),
    'metadata': metadata,
  };

  factory Income.fromJson(Map<String, dynamic> json) => Income(
    id: json['id'],
    title: json['title'],
    source: json['source'],
    amount: json['amount'].toDouble(),
    date: DateTime.parse(json['date']),
    description: json['description'],
    currency: json['currency'],
    isRecurring: json['isRecurring'],
    recurrenceType: json['recurrenceType'],
    nextOccurrence: json['nextOccurrence'] != null 
        ? DateTime.parse(json['nextOccurrence'])
        : null,
    metadata: json['metadata'],
  );

  Income copyWith({
    String? id,
    String? title,
    String? source,
    double? amount,
    DateTime? date,
    String? description,
    String? currency,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? nextOccurrence,
    Map<String, dynamic>? metadata,
  }) => Income(
    id: id ?? this.id,
    title: title ?? this.title,
    source: source ?? this.source,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    description: description ?? this.description,
    currency: currency ?? this.currency,
    isRecurring: isRecurring ?? this.isRecurring,
    recurrenceType: recurrenceType ?? this.recurrenceType,
    nextOccurrence: nextOccurrence ?? this.nextOccurrence,
    metadata: metadata ?? this.metadata,
  );

  String get formattedAmount {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color get sourceColor {
    switch (source.toLowerCase()) {
      case 'salary':
        return Colors.green;
      case 'freelance':
        return Colors.blue;
      case 'investment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get sourceIcon {
    switch (source.toLowerCase()) {
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.computer;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.attach_money;
    }
  }
} 