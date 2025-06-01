import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';

class AddTripDialog extends StatefulWidget {
  @override
  State<AddTripDialog> createState() => _AddTripDialogState();
}

class _AddTripDialogState extends State<AddTripDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String currency = 'USD';
  double budget = 0;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController _destController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Trip'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
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
                decoration: InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a number' : null,
                onSaved: (v) => budget = double.parse(v!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Currency'),
                initialValue: 'USD',
                onSaved: (v) => currency = v ?? 'USD',
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(startDate == null
                        ? 'Start Date'
                        : 'Start: ${startDate!.toLocal().toString().split(' ').first}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
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
                    child: Text(endDate == null
                        ? 'End Date'
                        : 'End: ${endDate!.toLocal().toString().split(' ').first}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
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
            if (_formKey.currentState!.validate() && startDate != null && endDate != null) {
              _formKey.currentState!.save();
              final destinations = _destController.text
                  .split(',')
                  .map((d) => d.trim())
                  .where((d) => d.isNotEmpty)
                  .toList();
              final trip = Trip(
                name: name,
                startDate: startDate!,
                endDate: endDate!,
                destinations: destinations,
                totalBudget: budget,
                baseCurrency: currency,
                notes: '',
                members: [],
              );
              await context.read<TripProvider>().addTrip(trip);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
