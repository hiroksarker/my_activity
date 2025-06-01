import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseDetailsDialog extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailsDialog({required this.expense, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Expense Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow(Icons.category, 'Category', expense.category),
          _detailRow(Icons.attach_money, 'Amount', '${expense.amount} ${expense.currency}'),
          _detailRow(Icons.calendar_today, 'Date', expense.date.toLocal().toString().split(' ').first),
          if (expense.notes.isNotEmpty)
            _detailRow(Icons.notes, 'Notes', expense.notes),
          _detailRow(
            Icons.person,
            'Paid by',
            expense.paidBy ?? 'Self',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 14),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
