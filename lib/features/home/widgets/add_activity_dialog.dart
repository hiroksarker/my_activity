import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';

class AddActivityDialog extends StatefulWidget {
  final ActivityType initialType;

  const AddActivityDialog({
    super.key,
    this.initialType = ActivityType.task,
  });

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
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
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _type = widget.initialType;
    _amount = 0.0;
    _category = widget.initialType == ActivityType.expense ? 'finance' : 'general';
    _status = widget.initialType == ActivityType.expense ? TaskStatus.completed : TaskStatus.pending;
    _transactionType = TransactionType.debit;
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
      return;
    }

    if (_type == ActivityType.expense && _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount for expense activities'),
        ),
      );
      return;
    }

    final activity = Activity(
      title: _titleController.text,
      description: _descriptionController.text,
      type: _type,
      amount: _type == ActivityType.expense ? _amount : 0.0,
      category: _category,
      status: _status,
      transactionType: _type == ActivityType.expense ? _transactionType : null,
    );

    Navigator.of(context).pop(activity);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_type == ActivityType.expense ? 'Add Expense' : 'Add Task'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<ActivityType>(
                segments: const [
                  ButtonSegment(
                    value: ActivityType.task,
                    label: Text('Task'),
                    icon: Icon(Icons.task_alt),
                  ),
                  ButtonSegment(
                    value: ActivityType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.attach_money),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<ActivityType> selected) {
                  setState(() {
                    _type = selected.first;
                    if (_type == ActivityType.expense) {
                      _status = TaskStatus.completed;
                      _category = 'finance';
                      _transactionType = TransactionType.debit;
                    } else {
                      _status = TaskStatus.pending;
                      _category = 'general';
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
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
              ),
              const SizedBox(height: 16),
              if (_type == ActivityType.expense) ...[
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
                        keyboardType: TextInputType.number,
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
                items: _type == ActivityType.expense
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
                      ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              if (_type == ActivityType.task) ...[
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
} 