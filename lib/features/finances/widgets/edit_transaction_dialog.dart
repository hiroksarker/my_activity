import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';

class EditTransactionDialog extends StatefulWidget {
  final FinancialTransaction transaction;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();

  late TransactionType _transactionType;
  late bool _isRecurring;
  late String? _recurrenceType;

  @override
  void initState() {
    super.initState();
    _transactionType = widget.transaction.type;
    _isRecurring = widget.transaction.isRecurring;
    _recurrenceType = widget.transaction.recurrenceType;

    _titleController.text = widget.transaction.title;
    _descriptionController.text = widget.transaction.description ?? '';
    _amountController.text = widget.transaction.amount.abs().toString();
    _categoryController.text = widget.transaction.category;
    if (widget.transaction.subcategory != null) {
      _subcategoryController.text = widget.transaction.subcategory!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    try {
      final updatedTransaction = widget.transaction.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        amount: amount,
        type: _transactionType,
        category: _categoryController.text,
        subcategory: _subcategoryController.text.isNotEmpty
            ? _subcategoryController.text
            : null,
        isRecurring: _isRecurring,
        recurrenceType: _recurrenceType,
        updatedAt: DateTime.now(),
      );

      await context.read<TransactionProvider>().updateTransaction(updatedTransaction);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Transaction'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _subcategoryController,
                decoration: const InputDecoration(labelText: 'Subcategory (optional)'),
              ),
              const SizedBox(height: 16),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_transactionType},
                onSelectionChanged: (Set<TransactionType> selected) {
                  setState(() {
                    _transactionType = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Recurring Transaction'),
                value: _isRecurring,
                onChanged: (bool value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurrenceType,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence Type',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'daily',
                      child: Text('Daily'),
                    ),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text('Weekly'),
                    ),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text('Monthly'),
                    ),
                    DropdownMenuItem(
                      value: 'yearly',
                      child: Text('Yearly'),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _recurrenceType = value;
                    });
                  },
                  validator: (value) {
                    if (_isRecurring && (value == null || value.isEmpty)) {
                      return 'Please select a recurrence type';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 