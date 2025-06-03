import 'package:flutter/material.dart';

enum FinanceCategoryType {
  income,
  expense,
}

class FinanceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final FinanceCategoryType type;

  const FinanceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  static const List<FinanceCategory> incomeCategories = [
    FinanceCategory(
      id: 'salary',
      name: 'Salary',
      icon: Icons.work,
      color: Colors.green,
      type: FinanceCategoryType.income,
    ),
    FinanceCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.computer,
      color: Colors.blue,
      type: FinanceCategoryType.income,
    ),
    FinanceCategory(
      id: 'investments',
      name: 'Investments',
      icon: Icons.trending_up,
      color: Colors.purple,
      type: FinanceCategoryType.income,
    ),
    FinanceCategory(
      id: 'gifts',
      name: 'Gifts',
      icon: Icons.card_giftcard,
      color: Colors.orange,
      type: FinanceCategoryType.income,
    ),
    FinanceCategory(
      id: 'other_income',
      name: 'Other Income',
      icon: Icons.more_horiz,
      color: Colors.grey,
      type: FinanceCategoryType.income,
    ),
  ];

  static const List<FinanceCategory> expenseCategories = [
    FinanceCategory(
      id: 'housing',
      name: 'Housing',
      icon: Icons.home,
      color: Colors.brown,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Colors.orange,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'transportation',
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.power,
      color: Colors.yellow,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.purple,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'healthcare',
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: Colors.red,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      color: Colors.indigo,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'travel',
      name: 'Travel',
      icon: Icons.flight,
      color: Colors.teal,
      type: FinanceCategoryType.expense,
    ),
    FinanceCategory(
      id: 'other_expense',
      name: 'Other Expense',
      icon: Icons.more_horiz,
      color: Colors.grey,
      type: FinanceCategoryType.expense,
    ),
  ];

  static List<FinanceCategory> getCategoriesForType(FinanceCategoryType type) {
    return type == FinanceCategoryType.income ? incomeCategories : expenseCategories;
  }

  static FinanceCategory? getCategoryById(String id) {
    return [...incomeCategories, ...expenseCategories].firstWhere(
      (category) => category.id == id,
      orElse: () => throw Exception('Category not found: $id'),
    );
  }
} 