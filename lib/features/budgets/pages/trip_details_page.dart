import 'package:flutter/material.dart';
import '../providers/trip_provider.dart';
import 'trip_overview_tab.dart';
import 'expenses_tab.dart';
import 'itinerary_tab.dart';
import 'documents_tab.dart';
import '../../../widgets/green_pills_wallpaper.dart';
import 'package:provider/provider.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  const AppGradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class TripDetailsPage extends StatelessWidget {
  final int tripId;
  const TripDetailsPage({required this.tripId});

  @override
  Widget build(BuildContext context) {
    final trip = Provider.of<TripProvider>(context).getTripById(tripId);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Trip Details')),
        body: Center(child: Text('Trip not found')),
      );
    }

    return GreenPillsWallpaper(
      child: DefaultTabController(
        length: 4, // Number of tabs
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Trip Details'),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Expenses'),
                Tab(text: 'Itinerary'),
                Tab(text: 'Docs'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              TripOverviewTab(trip: trip),
              ExpensesTab(tripId: tripId),
              ItineraryTab(tripId: tripId),
              DocumentsTab(tripId: tripId),
            ],
          ),
        ),
      ),
    );
  }
}
