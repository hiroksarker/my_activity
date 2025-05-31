import 'package:flutter/material.dart';
import '../models/activity.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    
    switch (activity.category.toLowerCase()) {
      case 'work':
      case 'official work':
        icon = Icons.work_outline;
        iconColor = Colors.blue;
        break;
      case 'personal':
      case 'personal work':
        icon = Icons.person_outline;
        iconColor = Colors.purple;
        break;
      case 'health':
        icon = Icons.favorite_border;
        iconColor = Colors.red;
        break;
      case 'finance':
      case 'finance tracking':
        icon = Icons.attach_money;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.category_outlined;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(activity.status),
              ],
            ),
            if (activity.description != null && activity.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                activity.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, y • h:mm a').format(activity.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (activity.amount != null && 
                    (activity.category.toLowerCase().contains('finance') ||
                     activity.category.toLowerCase().contains('shopping') ||
                     activity.category.toLowerCase().contains('bills')))
                  Text(
                    '\$${activity.amount!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 