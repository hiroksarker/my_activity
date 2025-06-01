import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/itinerary_provider.dart';
import '../models/itinerary_item.dart';

class AddItineraryItemDialog extends StatefulWidget {
  final int tripId;
  final String activityName; // Required: the activity to add time slots to

  const AddItineraryItemDialog({
    Key? key,
    required this.tripId,
    required this.activityName,
  }) : super(key: key);

  @override
  State<AddItineraryItemDialog> createState() => _AddItineraryItemDialogState();
}

class _AddItineraryItemDialogState extends State<AddItineraryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _time;
  late String _notes;
  late String _selectedAmPm = 'AM';
  late int _selectedHour = 9;
  late int _selectedMinute = 0;

  @override
  void initState() {
    super.initState();
    _time = '09:00 AM';
    _notes = '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Time Slot to ${widget.activityName}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time selection
              Row(
                children: [
                  // Hour dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedHour,
                      decoration: const InputDecoration(
                        labelText: 'Hour',
                      ),
                      items: List.generate(12, (index) {
                        final hour = index + 1;
                        return DropdownMenuItem(
                          value: hour,
                          child: Text(hour.toString().padLeft(2, '0')),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedHour = value;
                            _updateTimeString();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Minute dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMinute,
                      decoration: const InputDecoration(
                        labelText: 'Minute',
                      ),
                      items: [0, 15, 30, 45].map((minute) {
                        return DropdownMenuItem(
                          value: minute,
                          child: Text(minute.toString().padLeft(2, '0')),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMinute = value;
                            _updateTimeString();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // AM/PM dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedAmPm,
                      decoration: const InputDecoration(
                        labelText: 'AM/PM',
                      ),
                      items: ['AM', 'PM'].map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedAmPm = value;
                            _updateTimeString();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  hintText: 'Enter details for this time slot',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some details';
                  }
                  return null;
                },
                onSaved: (value) => _notes = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTimeSlot,
          child: const Text('Add Time Slot'),
        ),
      ],
    );
  }

  void _updateTimeString() {
    setState(() {
      _time = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $_selectedAmPm';
    });
  }

  void _saveTimeSlot() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        final provider = context.read<ItineraryProvider>();
        final item = ItineraryItem(
          id: DateTime.now().millisecondsSinceEpoch,
          tripId: widget.tripId,
          activity: widget.activityName,
          date: '', // No date needed
          time: _time,
          notes: _notes,
        );

        await provider.addItineraryItem(item);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Time slot added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding time slot: $e')),
          );
        }
      }
    }
  }
}
