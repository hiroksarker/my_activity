import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';

class AddTransactionDialog extends StatefulWidget {
  final FinancialTransaction? transaction;

  const AddTransactionDialog({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  late TransactionType _type;
  late ExpenseCategory _expenseCategory;
  late IncomeCategory _incomeCategory;
  bool _isRecurring = false;
  String? _recurrenceType;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _descriptionController.text = widget.transaction!.description ?? '';
      _amountController.text = widget.transaction!.amount.abs().toString();
      _type = widget.transaction!.type;
      if (_type == TransactionType.expense) {
        _expenseCategory = widget.transaction!.category.toExpenseCategory() ?? ExpenseCategory.other;
      } else {
        _incomeCategory = widget.transaction!.category.toIncomeCategory() ?? IncomeCategory.other;
      }
      _isRecurring = widget.transaction!.isRecurring;
      _recurrenceType = widget.transaction!.recurrenceType;
    } else {
      _type = TransactionType.expense;
      _expenseCategory = ExpenseCategory.other;
      _incomeCategory = IncomeCategory.other;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final amount = double.parse(_amountController.text);
      String categoryLabel;
      String categoryIcon;
      String categoryColor;

      if (_type == TransactionType.expense) {
        categoryLabel = _expenseCategory.label;
        categoryIcon = _expenseCategory.icon.codePoint.toString();
        categoryColor = _expenseCategory.color.value.toString();
      } else {
        categoryLabel = _incomeCategory.label;
        categoryIcon = _incomeCategory.icon.codePoint.toString();
        categoryColor = _incomeCategory.color.value.toString();
      }

      final provider = context.read<TransactionProvider>();

      if (widget.transaction == null) {
        await provider.createTransaction(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: _type == TransactionType.expense ? -amount : amount,
          type: _type,
          category: categoryLabel,
          isRecurring: _isRecurring,
          recurrenceType: _recurrenceType,
          categoryIcon: categoryIcon,
          categoryColor: categoryColor,
        );
      } else {
        final updatedTransaction = widget.transaction!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: _type == TransactionType.expense ? -amount : amount,
          type: _type,
          category: categoryLabel,
          isRecurring: _isRecurring,
          recurrenceType: _recurrenceType,
          categoryIcon: categoryIcon,
          categoryColor: categoryColor,
          updatedAt: DateTime.now(),
        );
        await provider.updateTransaction(updatedTransaction);
      }

      if (mounted) {
        // Pop the dialog with a success result
        Navigator.of(context).pop(true);
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
      title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Transaction Type Segmented Button
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
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> selected) {
                  setState(() {
                    _type = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Category Dropdown
              if (_type == TransactionType.expense)
                DropdownButtonFormField<ExpenseCategory>(
                  value: _expenseCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ExpenseCategory.values.map((category) => DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color),
                        const SizedBox(width: 8),
                        Text(category.label),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _expenseCategory = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                )
              else
                DropdownButtonFormField<IncomeCategory>(
                  value: _incomeCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: IncomeCategory.values.map((category) => DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color),
                        const SizedBox(width: 8),
                        Text(category.label),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _incomeCategory = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Recurring Transaction Switch
              SwitchListTile(
                title: const Text('Recurring Transaction'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (!value) {
                      _recurrenceType = null;
                    }
                  });
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurrenceType,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
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
          onPressed: _submit,
          child: Text(widget.transaction == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

