import 'package:flutter/material.dart';
import 'transaction_enums.dart';

class FinancialTransaction {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final TransactionType type;
  final String category;
  final String? subcategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRecurring;
  final String? recurrenceType;
  final DateTime? nextOccurrence;
  final String? recurrenceRule;
  final String? metadata;
  final String? categoryIcon;
  final String? categoryColor;

  FinancialTransaction({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.category,
    this.subcategory,
    required this.createdAt,
    required this.updatedAt,
    this.isRecurring = false,
    this.recurrenceType,
    this.nextOccurrence,
    this.recurrenceRule,
    this.metadata,
    this.categoryIcon,
    this.categoryColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category,
      'subcategory': subcategory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring ? 1 : 0,
      'recurrenceType': recurrenceType,
      'nextOccurrence': nextOccurrence?.toIso8601String(),
      'recurrenceRule': recurrenceRule,
      'metadata': metadata,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      amount: map['amount'] as double,
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      category: map['category'] as String,
      subcategory: map['subcategory'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isRecurring: (map['isRecurring'] as int) == 1,
      recurrenceType: map['recurrenceType'] as String?,
      nextOccurrence: map['nextOccurrence'] != null
          ? DateTime.parse(map['nextOccurrence'] as String)
          : null,
      recurrenceRule: map['recurrenceRule'] as String?,
      metadata: map['metadata'] as String?,
      categoryIcon: map['categoryIcon'] as String?,
      categoryColor: map['categoryColor'] as String?,
    );
  }

  FinancialTransaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    TransactionType? type,
    String? category,
    String? subcategory,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? nextOccurrence,
    String? recurrenceRule,
    String? metadata,
    String? categoryIcon,
    String? categoryColor,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      metadata: metadata ?? this.metadata,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  IconData get categoryIconData {
    if (categoryIcon != null) {
      try {
        return IconData(
          int.parse(categoryIcon!),
          fontFamily: 'MaterialIcons',
        );
      } catch (_) {
        // If parsing fails, return a default icon
      }
    }
    return type == TransactionType.expense
        ? Icons.remove_circle_outline
        : Icons.add_circle_outline;
  }

  Color get categoryColorData {
    if (categoryColor != null) {
      try {
        return Color(int.parse(categoryColor!));
      } catch (_) {
        // If parsing fails, return a default color
      }
    }
    return type == TransactionType.expense
        ? Colors.red
        : Colors.green;
  }
} 