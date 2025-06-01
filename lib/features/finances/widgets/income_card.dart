import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeCard extends StatelessWidget {
  final double totalIncome;
  final Map<String, double> incomeBySource;
  final String period;

  const IncomeCard({
    required this.totalIncome,
    required this.incomeBySource,
    required this.period,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final sortedSources = incomeBySource.entries.toList()
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
                  'Income Summary',
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
              currencyFormat.format(totalIncome),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (sortedSources.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Income by Source',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...sortedSources.map((source) {
                final percentage = (source.value / totalIncome * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(source.key),
                          Text(
                            currencyFormat.format(source.value),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: source.value / totalIncome,
                        backgroundColor: Colors.green.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$percentage% of total income',
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