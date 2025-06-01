import 'package:flutter/material.dart';
import '../../home/models/activity.dart';

class StatsSection extends StatelessWidget {
  final List<Activity> activities;

  const StatsSection({
    required this.activities,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate stats
    final totalTasks = activities.where((a) => a.type == ActivityType.task).length;
    final completedTasks = activities
        .where((a) => a.type == ActivityType.task && a.status == TaskStatus.completed)
        .length;
    final totalExpenses = activities
        .where((a) => a.type == ActivityType.expense)
        .fold<double>(0, (sum, a) => sum + a.amount);
    final travelExpenses = activities
        .where((a) =>
            a.type == ActivityType.expense &&
            a.category == 'travel' &&
            a.transactionType == TransactionType.debit)
        .fold<double>(0, (sum, a) => sum + a.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Tasks',
                  value: '$completedTasks/$totalTasks',
                  subtitle: 'Completed',
                  icon: Icons.task_alt,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Expenses',
                  value: '\$${totalExpenses.toStringAsFixed(2)}',
                  subtitle: 'Total',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Travel',
                  value: '\$${travelExpenses.toStringAsFixed(2)}',
                  subtitle: 'Spent',
                  icon: Icons.flight,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Activities',
                  value: activities.length.toString(),
                  subtitle: 'Total',
                  icon: Icons.analytics,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 