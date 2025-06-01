import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/models/activity.dart';
import '../../home/providers/activity_provider.dart';
import 'package:uuid/uuid.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Other';
  TransactionType _transactionType = TransactionType.debit;
  bool _isRecurring = false;
  String? _recurrenceType;

  final List<String> _expenseCategories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Housing',
    'Utilities',
    'Entertainment',
    'Healthcare',
    'Travel',
    'Education',
    'Personal Care',
    'Gifts & Donations',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Rental',
    'Gifts',
    'Other',
  ];

  final List<String> _recurrenceTypes = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final transaction = Activity(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : '',
      amount: _transactionType == TransactionType.debit ? -amount : amount,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: ActivityType.expense,
      transactionType: _transactionType,
      isRecurring: _isRecurring,
      recurrenceType: _recurrenceType,
    );

    context.read<ActivityProvider>().addActivity(transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add Transaction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.debit,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.credit,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_transactionType},
                onSelectionChanged: (Set<TransactionType> selected) {
                  setState(() {
                    _transactionType = selected.first;
                    _selectedCategory = 'Other';
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter transaction title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter transaction description (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 16),
              
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: (_transactionType == TransactionType.debit
                        ? _expenseCategories
                        : _incomeCategories)
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Recurring Transaction
              SwitchListTile(
                title: const Text('Recurring Transaction'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (!value) _recurrenceType = null;
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
                  items: _recurrenceTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
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
          child: const Text('Add Transaction'),
        ),
      ],
    );
  }
}
