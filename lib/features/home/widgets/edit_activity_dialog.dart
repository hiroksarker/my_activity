import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../activities/providers/activity_provider.dart';
import '../models/activity.dart';

class EditActivityDialog extends StatefulWidget {
  final Activity activity;

  const EditActivityDialog({
    super.key,
    required this.activity,
  });

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late ActivityType _type;
  late double _amount;
  late String _category;
  late TaskStatus _status;
  late TransactionType _transactionType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity.title);
    _descriptionController = TextEditingController(text: widget.activity.description);
    _amountController = TextEditingController(
      text: widget.activity.amount > 0 ? widget.activity.amount.toString() : '',
    );
    _type = widget.activity.type;
    _amount = widget.activity.amount;
    _category = _getValidCategory(widget.activity.category, widget.activity.type);
    _status = widget.activity.status;
    _transactionType = widget.activity.transactionType ?? TransactionType.debit;
  }

  String _getValidCategory(String currentCategory, ActivityType type) {
    final validCategories = type == ActivityType.expense
        ? const ['finance', 'shopping', 'food', 'transport', 'bills', 'entertainment', 'income']
        : const ['general', 'work', 'personal', 'finance'];
    
    return validCategories.contains(currentCategory) 
        ? currentCategory 
        : validCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_type == ActivityType.expense && _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount for expense activities'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final updatedActivity = widget.activity.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        amount: _type == ActivityType.expense ? _amount : 0.0,
        category: _category,
        status: _status,
        transactionType: _type == ActivityType.expense ? _transactionType : null,
      );

      print('Submitting updated activity: ${updatedActivity.toString()}');
      context.read<ActivityProvider>().updateActivity(updatedActivity);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating activity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating activity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.activity.type == ActivityType.expense;
    final size = MediaQuery.of(context).size;
    final maxHeight = size.height * 0.8;
    final maxWidth = size.width * 0.9;

    final categoryItems = isExpense
        ? const [
            DropdownMenuItem(value: 'finance', child: Text('Finance')),
            DropdownMenuItem(value: 'shopping', child: Text('Shopping')),
            DropdownMenuItem(value: 'food', child: Text('Food')),
            DropdownMenuItem(value: 'transport', child: Text('Transport')),
            DropdownMenuItem(value: 'bills', child: Text('Bills')),
            DropdownMenuItem(value: 'entertainment', child: Text('Entertainment')),
            DropdownMenuItem(value: 'income', child: Text('Income')),
          ]
        : const [
            DropdownMenuItem(value: 'general', child: Text('General')),
            DropdownMenuItem(value: 'work', child: Text('Work')),
            DropdownMenuItem(value: 'personal', child: Text('Personal')),
            DropdownMenuItem(value: 'finance', child: Text('Finance')),
          ];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: (size.width - maxWidth) / 2,
        vertical: 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isExpense ? 'Edit Expense' : 'Edit Task',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          minLines: 2,
                        ),
                        const SizedBox(height: 16),
                        if (isExpense) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _amountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    border: OutlineInputBorder(),
                                    prefixText: '\$',
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (value) {
                                    setState(() {
                                      _amount = double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 120,
                                child: DropdownButtonFormField<TransactionType>(
                                  value: _transactionType,
                                  decoration: const InputDecoration(
                                    labelText: 'Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: TransactionType.debit,
                                      child: Text('Expense'),
                                    ),
                                    DropdownMenuItem(
                                      value: TransactionType.credit,
                                      child: Text('Income'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _transactionType = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: categoryItems,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _category = value;
                              });
                            }
                          },
                        ),
                        if (!isExpense) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<TaskStatus>(
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: TaskStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.toString().split('.').last.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _status = value;
                                });
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Footer
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 