import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../activities/models/activity.dart';
import '../../activities/models/activity_enums.dart';
import '../../activities/providers/activity_provider.dart';
import 'package:uuid/uuid.dart';

class ActivityFormDialog extends StatefulWidget {
  final Activity? activity;
  final Function(Activity)? onActivityCreated;

  const ActivityFormDialog({
    super.key,
    this.activity,
    this.onActivityCreated,
  });

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  late ActivityStatus _selectedStatus;
  late ActivityPriority _priority;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.activity?.status ?? ActivityStatus.active;
    _priority = widget.activity?.priority ?? ActivityPriority.regular;

    if (widget.activity != null) {
      _titleController.text = widget.activity!.title;
      _descriptionController.text = widget.activity!.description;
      _categoryController.text = widget.activity!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveActivity() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.activity == null) {
        context.read<ActivityProvider>().addActivity(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          type: ActivityType.expense,
          status: ActivityStatus.active,
          priority: _priority,
          timestamp: DateTime.now(),
        );
      } else {
        final updatedActivity = widget.activity!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          status: _selectedStatus,
          priority: _priority,
        );
        context.read<ActivityProvider>().updateActivity(updatedActivity);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.activity == null ? 'Add Activity' : 'Edit Activity'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              widget.activity != null
                ? DropdownButtonFormField<ActivityStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ActivityStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  )
                : TextFormField(
                    enabled: false,
                    initialValue: 'Active',
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: Colors.grey,
                    ),
                  ),
              DropdownButtonFormField<ActivityPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ActivityPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
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
          onPressed: _saveActivity,
          child: Text(widget.activity == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
} 