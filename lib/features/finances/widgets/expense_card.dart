import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final double totalExpenses;
  final Map<String, double> expensesByCategory;
  final String period;

  const ExpenseCard({
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.period,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense Summary',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  period,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currencyFormat.format(totalExpenses),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (sortedCategories.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Expenses by Category',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...sortedCategories.map((category) {
                final percentage = (category.value / totalExpenses * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category.key),
                          Text(
                            currencyFormat.format(category.value),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: category.value / totalExpenses,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$percentage% of total expenses',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
} 