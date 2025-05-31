import 'package:flutter/material.dart';

class Receipt {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final DateTime date;
  final String category;
  final String? merchantName;
  final String? location;
  final String? imageUrl; // URL to stored receipt image
  final String currency;
  final Map<String, dynamic>? metadata; // Additional data like tax, items, etc.
  final bool isVerified; // Whether the receipt has been verified
  final String status; // 'pending', 'verified', 'rejected'

  Receipt({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.merchantName,
    this.location,
    this.imageUrl,
    this.currency = 'USD',
    this.metadata,
    this.isVerified = false,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'merchantName': merchantName,
    'location': location,
    'imageUrl': imageUrl,
    'currency': currency,
    'metadata': metadata,
    'isVerified': isVerified,
    'status': status,
  };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    amount: json['amount'].toDouble(),
    date: DateTime.parse(json['date']),
    category: json['category'],
    merchantName: json['merchantName'],
    location: json['location'],
    imageUrl: json['imageUrl'],
    currency: json['currency'],
    metadata: json['metadata'],
    isVerified: json['isVerified'],
    status: json['status'],
  );

  Receipt copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    String? category,
    String? merchantName,
    String? location,
    String? imageUrl,
    String? currency,
    Map<String, dynamic>? metadata,
    bool? isVerified,
    String? status,
  }) => Receipt(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    category: category ?? this.category,
    merchantName: merchantName ?? this.merchantName,
    location: location ?? this.location,
    imageUrl: imageUrl ?? this.imageUrl,
    currency: currency ?? this.currency,
    metadata: metadata ?? this.metadata,
    isVerified: isVerified ?? this.isVerified,
    status: status ?? this.status,
  );

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'verified':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String get formattedAmount {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
} 