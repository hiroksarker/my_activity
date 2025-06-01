import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';

class EditTripDialog extends StatefulWidget {
  final Trip trip;
  const EditTripDialog({required this.trip});

  @override
  State<EditTripDialog> createState() => _EditTripDialogState();
}

class _EditTripDialogState extends State<EditTripDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String currency;
  late double budget;
  late DateTime startDate;
  late DateTime endDate;
  late TextEditingController _destController;

  @override
  void initState() {
    super.initState();
    name = widget.trip.name;
    currency = widget.trip.baseCurrency;
    budget = widget.trip.totalBudget;
    startDate = widget.trip.startDate;
    endDate = widget.trip.endDate;
    _destController = TextEditingController(text: widget.trip.destinations.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Trip'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Trip Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
                onSaved: (v) => name = v!,
              ),
              TextFormField(
                controller: _destController,
                decoration: InputDecoration(labelText: 'Destinations (comma separated)'),
                validator: (v) => v == null || v.isEmpty ? 'Enter at least one destination' : null,
              ),
              TextFormField(
                initialValue: budget.toString(),
                decoration: InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a number' : null,
                onSaved: (v) => budget = double.parse(v!),
              ),
              TextFormField(
                initialValue: currency,
                decoration: InputDecoration(labelText: 'Currency'),
                onSaved: (v) => currency = v ?? 'USD',
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Start: ${startDate.toLocal().toString().split(' ').first}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => startDate = picked);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('End: ${endDate.toLocal().toString().split(' ').first}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => endDate = picked);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final destinations = _destController.text
                  .split(',')
                  .map((d) => d.trim())
                  .where((d) => d.isNotEmpty)
                  .toList();
              final updatedTrip = widget.trip.copyWith(
                name: name,
                baseCurrency: currency,
                totalBudget: budget,
                startDate: startDate,
                endDate: endDate,
                destinations: destinations,
              );
              await context.read<TripProvider>().updateTrip(updatedTrip);
              Navigator.pop(context);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
