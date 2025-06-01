import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class ActivityFormDialog extends StatefulWidget {
  final Activity? activity; // If null, we're creating a new activity
  final ActivityType initialType;

  const ActivityFormDialog({
    super.key,
    this.activity,
    this.initialType = ActivityType.task,
  });

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late ActivityType _type;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _category;
  late TaskStatus _status;
  late TransactionType _transactionType;

  final List<String> _taskCategories = [
    'general',
    'work',
    'personal',
    'health',
    'finance',
  ];

  final List<String> _expenseCategories = [
    'food',
    'shopping',
    'bills',
    'entertainment',
    'transport',
    'travel',
    'income',
  ];

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _titleController = TextEditingController(text: activity?.title ?? '');
    _descriptionController = TextEditingController(text: activity?.description ?? '');
    _amountController = TextEditingController(
      text: activity?.amount.toString() ?? '',
    );
    _type = activity?.type ?? widget.initialType;
    _selectedDate = activity?.timestamp ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(activity?.timestamp ?? DateTime.now());
    _category = activity?.category ?? (_type == ActivityType.expense ? 'food' : 'general');
    _status = activity?.status ?? TaskStatus.pending;
    _transactionType = activity?.transactionType ?? TransactionType.debit;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _submit() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
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

    final activity = Activity(
      id: widget.activity?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      timestamp: _selectedDate,
      type: _type,
      amount: _type == ActivityType.expense ? double.parse(_amountController.text) : 0.0,
      category: _category,
      status: _status,
      transactionType: _type == ActivityType.expense ? _transactionType : null,
    );

    Navigator.of(context).pop(activity);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Activity' : 'New Activity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Selection
            if (!isEditing)
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
                    _category = _type == ActivityType.expense ? 'food' : 'general';
                  });
                },
              ),
            const SizedBox(height: 16),
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            // Date and Time Selection
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat('MMM d, y').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: (_type == ActivityType.expense ? _expenseCategories : _taskCategories)
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.capitalize()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Amount and Transaction Type (for expenses)
            if (_type == ActivityType.expense) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
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
            ] else ...[
              // Status (for tasks)
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last.capitalize()),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
} 