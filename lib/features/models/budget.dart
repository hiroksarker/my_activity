import 'package:flutter/material.dart';

class Budget {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final Map<String, double> categoryLimits;
  final List<String> categories;
  final String periodType; // 'weekly', 'monthly', 'custom'
  final bool isActive;

  Budget({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.categoryLimits,
    required this.categories,
    required this.periodType,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalAmount': totalAmount,
    'categoryLimits': categoryLimits,
    'categories': categories,
    'periodType': periodType,
    'isActive': isActive,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    name: json['name'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    totalAmount: json['totalAmount'].toDouble(),
    categoryLimits: Map<String, double>.from(json['categoryLimits']),
    categories: List<String>.from(json['categories']),
    periodType: json['periodType'],
    isActive: json['isActive'],
  );

  Budget copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    Map<String, double>? categoryLimits,
    List<String>? categories,
    String? periodType,
    bool? isActive,
  }) => Budget(
    id: id ?? this.id,
    name: name ?? this.name,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    totalAmount: totalAmount ?? this.totalAmount,
    categoryLimits: categoryLimits ?? this.categoryLimits,
    categories: categories ?? this.categories,
    periodType: periodType ?? this.periodType,
    isActive: isActive ?? this.isActive,
  );
} 