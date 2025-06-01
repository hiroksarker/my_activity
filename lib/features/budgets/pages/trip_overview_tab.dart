import 'package:flutter/material.dart';
import '../models/trip.dart';

class TripOverviewTab extends StatelessWidget {
  final Trip trip;
  const TripOverviewTab({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F8CFF), Color(0xFFB721FF), Color(0xFFFF3A44)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  trip.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${trip.startDate.toLocal().toString().split(' ').first} - ${trip.endDate.toLocal().toString().split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: trip.destinations.isEmpty
                      ? [Chip(label: Text('No destinations', style: TextStyle(color: Colors.white70)), backgroundColor: Colors.white24)]
                      : trip.destinations.map((d) => Chip(
                          label: Text(d, style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.white24,
                        )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Trip Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green[700]),
                        const SizedBox(width: 10),
                        Text(
                          'Budget: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          trip.budget != null ? '\$${trip.budget!.toStringAsFixed(2)}' : 'Not set',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.blue[700]),
                        const SizedBox(width: 10),
                        Text(
                          'Travelers: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          trip.travelers?.join(', ') ?? 'Just you',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // Show edit dialog
                  },
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Delete', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // Show delete confirmation
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}