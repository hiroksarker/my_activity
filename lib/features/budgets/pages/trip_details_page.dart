import 'package:flutter/material.dart';
import '../providers/trip_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/itinerary_provider.dart';
import '../providers/document_provider.dart';
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
  const TripDetailsPage({required this.tripId, super.key});

  @override
  Widget build(BuildContext context) {
    final trip = Provider.of<TripProvider>(context, listen: false).getTripById(tripId);
    if (trip == null) {
      return Scaffold(body: Center(child: Text('Trip not found')));
    }
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trip Details'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Expenses'),
              Tab(text: 'Itinerary'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TripOverviewTab(trip: trip),
            ChangeNotifierProvider(
              create: (_) => ExpenseProvider(),
              child: Builder(builder: (context) => ExpensesTab(tripId: tripId)),
            ),
            ChangeNotifierProvider(
              create: (_) => ItineraryProvider()..initialize(),
              child: Builder(builder: (context) => ItineraryTab(tripId: tripId)),
            ),
            ChangeNotifierProvider(
              create: (_) => DocumentProvider(),
              child: Builder(builder: (context) => DocumentsTab(tripId: tripId)),
            ),
          ],
        ),
      ),
    );
  }
}
