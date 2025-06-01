import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_dialog.dart';
import '../widgets/gradient_background.dart';
import 'expense_details_dialog.dart';

class ExpensesTab extends StatefulWidget {
  final int tripId;
  const ExpensesTab({required this.tripId});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseProvider>(context, listen: false).loadExpenses(widget.tripId);
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'lodging':
        return Icons.hotel;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      opacity: 0.85,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, _) {
            final expenses = expenseProvider.expenses;
            return expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.deepPurple),
                        SizedBox(height: 16),
                        Text('No expenses yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Tap + to add your first expense!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: expenses.length,
                    itemBuilder: (context, i) {
                      final e = expenses[i];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade50,
                            child: Icon(getCategoryIcon(e.category), color: Colors.deepPurple),
                          ),
                          title: Text('${e.category}: ${e.amount} ${e.currency}', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${e.date.toLocal().toString().split(' ').first} - ${e.paidBy}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => expenseProvider.deleteExpense(e.id!, e.tripId),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => ExpenseDetailsDialog(expense: e),
                            );
                          },
                        ),
                      );
                    },
                  );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddExpenseDialog(tripId: widget.tripId),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.deepPurple,
        ),
      ),
    );
  }
}
