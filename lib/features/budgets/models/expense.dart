import 'dart:convert';

class Expense {
  final int? id;
  final int tripId;
  final String category;
  final double amount;
  final DateTime date;
  final String currency;
  final String notes;
  final String? photoPath;
  final String paidBy;
  final List<String> sharedWith;
  final bool isSettled;

  Expense({
    this.id,
    required this.tripId,
    required this.category,
    required this.amount,
    required this.date,
    required this.currency,
    required this.notes,
    this.photoPath,
    required this.paidBy,
    required this.sharedWith,
    required this.isSettled,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
        'currency': currency,
        'notes': notes,
        'photoPath': photoPath,
        'paidBy': paidBy,
        'sharedWith': jsonEncode(sharedWith),
        'isSettled': isSettled ? 1 : 0,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        tripId: map['tripId'],
        category: map['category'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        currency: map['currency'],
        notes: map['notes'] ?? '',
        photoPath: map['photoPath'],
        paidBy: map['paidBy'],
        sharedWith: List<String>.from(jsonDecode(map['sharedWith'])),
        isSettled: map['isSettled'] == 1,
      );
}
