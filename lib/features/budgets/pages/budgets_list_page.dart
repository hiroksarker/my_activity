import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../models/trip.dart';
import 'add_trip_dialog.dart';
import 'edit_trip_dialog.dart';
import '../../../widgets/green_pills_wallpaper.dart';

class BudgetsListPage extends StatefulWidget {
  @override
  State<BudgetsListPage> createState() => _BudgetsListPageState();
}

class _BudgetsListPageState extends State<BudgetsListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<TripProvider>(context, listen: false).loadTrips()
    );
  }

  @override
  Widget build(BuildContext context) {
    return GreenPillsWallpaper(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('My Trips'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4F8CFF), // Blue
                  Color(0xFFB721FF), // Purple
                  Color(0xFFFF3A44), // Red
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
        ),
        body: Consumer<TripProvider>(
          builder: (context, tripProvider, _) {
            final trips = tripProvider.trips;
            return trips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_travel, size: 80, color: Colors.blueAccent),
                        SizedBox(height: 16),
                        Text('No trips yet!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Tap + to add your first trip.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: trips.length,
                    itemBuilder: (context, i) {
                      final trip = trips[i];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.flight_takeoff, color: Colors.blue),
                          ),
                          title: Text(trip.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${trip.startDate.toLocal().toString().split(' ').first} - ${trip.endDate.toLocal().toString().split(' ').first}\n'
                            'Destinations: ${trip.destinations.isEmpty ? "None" : trip.destinations.join(", ")}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditTripDialog(trip: trip),
                                  );
                                },
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/trip-details',
                              arguments: trip.id,
                            );
                          },
                        ),
                      );
                    },
                  );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddTripDialog(),
            );
          },
          icon: Icon(Icons.add),
          label: Text('Add Trip'),
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
  }
}
