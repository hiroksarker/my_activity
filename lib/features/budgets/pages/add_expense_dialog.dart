import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseDialog extends StatefulWidget {
  final int tripId;
  const AddExpenseDialog({required this.tripId});
  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  String category = '';
  double amount = 0;
  String currency = 'USD';
  String notes = '';
  DateTime date = DateTime.now();
  String _paidBy = 'Self';
  final _paidByController = TextEditingController();

  @override
  void dispose() {
    _paidByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a category' : null,
                onSaved: (v) => category = v!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a number' : null,
                onSaved: (v) => amount = double.parse(v!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Currency'),
                initialValue: 'USD',
                onSaved: (v) => currency = v ?? 'USD',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                onSaved: (v) => notes = v ?? '',
              ),
              Row(
                children: [
                  Expanded(child: Text('Date: ${date.toLocal().toString().split(' ').first}')),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => date = picked);
                    },
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _paidBy,
                decoration: InputDecoration(labelText: 'Paid by'),
                items: [
                  DropdownMenuItem(value: 'Self', child: Text('Self')),
                  DropdownMenuItem(value: 'Other', child: Text('Someone else')),
                ],
                onChanged: (value) {
                  setState(() {
                    _paidBy = value!;
                    if (_paidBy == 'Self') _paidByController.clear();
                  });
                },
              ),
              if (_paidBy == 'Other')
                TextFormField(
                  controller: _paidByController,
                  decoration: InputDecoration(labelText: 'Name of person who paid'),
                  validator: (value) {
                    if (_paidBy == 'Other' && (value == null || value.isEmpty)) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final expense = Expense(
                tripId: widget.tripId,
                category: category,
                amount: amount,
                date: date,
                currency: currency,
                notes: notes,
                paidBy: _paidBy == 'Self' ? '' : _paidByController.text,
                sharedWith: [],
                isSettled: false,
                photoPath: null,
                id: null,
              );
              await context.read<ExpenseProvider>().addExpense(expense);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
