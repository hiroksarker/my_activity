import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/itinerary_provider.dart';
import '../models/itinerary_item.dart';

class AddActivityDialog extends StatefulWidget {
  final int tripId;

  const AddActivityDialog({
    Key? key,
    required this.tripId,
  }) : super(key: key);

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _activityController = TextEditingController();

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Activity'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _activityController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                hintText: 'e.g., Sightseeing, Shopping, Dining',
                prefixIcon: Icon(Icons.event),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an activity name';
                }
                return null;
              },
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveActivity,
          child: const Text('Add Activity'),
        ),
      ],
    );
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      final activityName = _activityController.text.trim();
      
      // Create a placeholder item with just the activity name
      final item = ItineraryItem(
        id: DateTime.now().millisecondsSinceEpoch,
        tripId: widget.tripId,
        activity: activityName,
        date: DateTime.now().toString().split(' ')[0],
        time: '00:00 AM', // Placeholder time
        notes: 'Click + to add time slots', // Placeholder note
      );

      context.read<ItineraryProvider>().addItineraryItem(item);
      Navigator.pop(context);
    }
  }
} 