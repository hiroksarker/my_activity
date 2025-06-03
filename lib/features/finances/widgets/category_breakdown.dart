import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CategoryBreakdown extends StatefulWidget {
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
  State<CategoryBreakdown> createState() => _CategoryBreakdownState();
}

class _CategoryBreakdownState extends State<CategoryBreakdown> with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final sortedData = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isExpense ? 'Expenses by Category' : 'Income by Source',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = null;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sections: sortedData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isTouched = index == _touchedIndex;
                            final color = widget.isExpense
                                ? Colors.red.withOpacity(0.7 - (index * 0.1))
                                : Colors.green.withOpacity(0.7 - (index * 0.1));
                            
                            return PieChartSectionData(
                              value: item.value * _animation.value,
                              title: isTouched ? '${(item.value / widget.total * 100).toStringAsFixed(1)}%' : '',
                              color: color,
                              radius: isTouched ? 110 : 100,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              borderSide: isTouched
                                  ? const BorderSide(color: Colors.white, width: 2)
                                  : BorderSide.none,
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          centerSpaceColor: theme.colorScheme.surface,
                          startDegreeOffset: -90,
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isExpense ? 'Total Expenses' : 'Total Income',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(widget.total),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: sortedData.asMap().entries.map((entry) {
                final index = entry.key;
                final isTouched = index == _touchedIndex;
                final color = widget.isExpense
                    ? Colors.red.withOpacity(0.7 - (index * 0.1))
                    : Colors.green.withOpacity(0.7 - (index * 0.1));
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTouched ? color.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isTouched
                        ? Border.all(color: color, width: 1)
                        : null,
                  ),
                  child: Row(
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
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${(entry.value / widget.total * 100).toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currencyFormat.format(entry.value),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 