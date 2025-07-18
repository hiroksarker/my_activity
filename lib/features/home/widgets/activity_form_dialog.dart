import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../activities/models/activity.dart';
import '../../activities/models/activity_enums.dart';
import '../../activities/providers/activity_provider.dart';
import '../../../core/design_system/forms/modern_form_scaffold.dart';
import '../../../core/design_system/forms/modern_text_field.dart';
import '../../../core/design_system/forms/modern_dropdown.dart';
import '../../../core/design_system/forms/form_spacing.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ModernFormScaffold(
          title: widget.activity == null ? 'Add Activity' : 'Edit Activity',
          onSave: _saveActivity,
          onCancel: () => Navigator.of(context).pop(),
          saveButtonText: widget.activity == null ? 'Add' : 'Update',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Basic Information Section
                ModernFormSection(
                  title: 'Activity Details',
                  icon: Icons.task_alt,
                  children: [
                    ModernTextField(
                      controller: _titleController,
                      label: 'Title',
                      hintText: 'Enter activity title',
                      prefixIcon: Icons.title,
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    ModernTextArea(
                      controller: _descriptionController,
                      label: 'Description',
                      hintText: 'Enter activity description',
                      minLines: 2,
                      maxLines: 4,
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    ModernTextField(
                      controller: _categoryController,
                      label: 'Category',
                      hintText: 'Enter category',
                      prefixIcon: Icons.category,
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                // Status and Priority Section
                ModernFormSection(
                  title: 'Status & Priority',
                  icon: Icons.settings,
                  children: [
                    ModernDropdown<ActivityStatus>(
                      value: _selectedStatus,
                      label: 'Status',
                      prefixIcon: Icons.flag,
                      enabled: widget.activity != null,
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
                    ),
                    
                    ModernDropdown<ActivityPriority>(
                      value: _priority,
                      label: 'Priority',
                      prefixIcon: Icons.priority_high,
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