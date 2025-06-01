import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> data;
  final double total;
  final bool isExpense;

  const CategoryBreakdown({
    required this.data,
    required this.total,
    required this.isExpense,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sortedData.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = isExpense
                    ? Colors.red.withOpacity(0.7 - (index * 0.1))
                    : Colors.green.withOpacity(0.7 - (index * 0.1));
                
                return PieChartSectionData(
                  value: item.value,
                  title: '${(item.value / total * 100).toStringAsFixed(1)}%',
                  color: color,
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              centerSpaceColor: theme.colorScheme.surface,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: sortedData.map((entry) {
            final index = sortedData.indexOf(entry);
            final color = isExpense
                ? Colors.red.withOpacity(0.7 - (index * 0.1))
                : Colors.green.withOpacity(0.7 - (index * 0.1));
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key}: ${currencyFormat.format(entry.value)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
} 