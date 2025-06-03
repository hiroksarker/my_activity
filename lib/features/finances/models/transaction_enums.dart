import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense,
}

enum ExpenseCategory {
  food('Food', Icons.restaurant, Colors.orange),
  shopping('Shopping', Icons.shopping_bag, Colors.pink),
  transport('Transport', Icons.directions_car, Colors.blue),
  bills('Bills', Icons.receipt_long, Colors.red),
  entertainment('Entertainment', Icons.movie, Colors.purple),
  travel('Travel', Icons.flight, Colors.teal),
  health('Health', Icons.medical_services, Colors.green),
  education('Education', Icons.school, Colors.indigo),
  housing('Housing', Icons.home, Colors.brown),
  utilities('Utilities', Icons.power, Colors.amber),
  other('Other', Icons.more_horiz, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;

  const ExpenseCategory(this.label, this.icon, this.color);
}

enum IncomeCategory {
  salary('Salary', Icons.work, Colors.green),
  business('Business', Icons.business, Colors.blue),
  investment('Investment', Icons.trending_up, Colors.purple),
  freelance('Freelance', Icons.computer, Colors.orange),
  gift('Gift', Icons.card_giftcard, Colors.pink),
  refund('Refund', Icons.replay, Colors.teal),
  other('Other', Icons.more_horiz, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;

  const IncomeCategory(this.label, this.icon, this.color);
}

extension TransactionCategoryExtension on String {
  ExpenseCategory? toExpenseCategory() {
    return ExpenseCategory.values.firstWhere(
      (category) => category.label.toLowerCase() == toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }

  IncomeCategory? toIncomeCategory() {
    return IncomeCategory.values.firstWhere(
      (category) => category.label.toLowerCase() == toLowerCase(),
      orElse: () => IncomeCategory.other,
    );
  }
} 