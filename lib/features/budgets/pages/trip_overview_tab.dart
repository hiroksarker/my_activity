import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../../../widgets/confirmation_dialog.dart';

class TripOverviewTab extends StatelessWidget {
  final Trip trip;
  const TripOverviewTab({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0ECFF), Color(0xFFF8E8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              // Floating header card
              Padding(
                padding: const EdgeInsets.only(top: 32, left: 20, right: 20),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F8CFF), Color(0xFFB721FF), Color(0xFFFF3A44)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${trip.startDate.toLocal().toString().split(' ').first} - ${trip.endDate.toLocal().toString().split(' ').first}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: trip.destinations.isEmpty
                              ? [
                                  Chip(
                                    label: Text('No destinations', style: TextStyle(color: Colors.blueGrey)),
                                    backgroundColor: Colors.white,
                                  )
                                ]
                              : trip.destinations.map((d) => Chip(
                                  avatar: const Icon(Icons.place, color: Color(0xFF4F8CFF), size: 18),
                                  label: Text(
                                    d,
                                    style: const TextStyle(
                                      color: Color(0xFF4F8CFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Color(0xFF4F8CFF), width: 1),
                                  ),
                                )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green[700]),
                            const SizedBox(width: 10),
                            const Text('Budget:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              trip.budget != null ? '\$${trip.budget!.toStringAsFixed(2)}' : 'Not set',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.people, color: Colors.blue[700]),
                            const SizedBox(width: 10),
                            const Text('Travelers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (trip.travelers != null && trip.travelers!.isNotEmpty)
                                    ? trip.travelers!.join(', ')
                                    : 'Just you!',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Edit', style: TextStyle(color: Colors.white)),
                        onPressed: () => _showEditTripDialog(context, trip),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text('Delete', style: TextStyle(color: Colors.white)),
                        onPressed: () => _showDeleteTripDialog(context, trip),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditTripDialog(BuildContext context, Trip trip) {
    final nameController = TextEditingController(text: trip.name);
    final notesController = TextEditingController(text: trip.notes);
    final budgetController = TextEditingController(text: trip.budget?.toString() ?? '');
    final travelersController = TextEditingController(text: trip.travelers?.join(', ') ?? '');
    final destinationsController = TextEditingController(text: trip.destinations.join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Trip'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Trip Name'),
              ),
              TextFormField(
                controller: destinationsController,
                decoration: const InputDecoration(labelText: 'Destinations (comma separated)'),
              ),
              TextFormField(
                controller: budgetController,
                decoration: const InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: travelersController,
                decoration: const InputDecoration(labelText: 'Travelers (comma separated)'),
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
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
            onPressed: () async {
              final updatedTrip = trip.copyWith(
                name: nameController.text,
                destinations: destinationsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                budget: budgetController.text.isNotEmpty ? double.tryParse(budgetController.text) : null,
                travelers: travelersController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                notes: notesController.text,
              );
              await Provider.of<TripProvider>(context, listen: false).updateTrip(updatedTrip);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip updated!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTripDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Trip',
        content: 'Are you sure you want to delete this trip? This action cannot be undone.',
        icon: Icons.delete_rounded,
        iconColor: Colors.red,
        onConfirm: () async {
          await Provider.of<TripProvider>(context, listen: false).deleteTrip(trip.id!);
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip deleted.')));
        },
      ),
    );
  }
}