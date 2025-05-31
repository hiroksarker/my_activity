import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../widgets/activity_card.dart';
import '../widgets/add_activity_dialog.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch activities when the page loads
    Future.microtask(
      () => context.read<ActivityProvider>().fetchActivities(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activities'),
        centerTitle: true,
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.activities.isEmpty) {
            // If error is due to no data, show info message instead of error
            if (provider.error!.contains('No activities') || provider.error!.contains('not found') || provider.error!.contains('empty') || provider.error!.contains('404')) {
              return const Center(
                child: Text(
                  'List currently empty, no record found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }
            _logger.e('HomePage error: ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchActivities(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final upcomingActivities = provider.getUpcomingActivities();
          final recentActivities = provider.getRecentActivities();

          return RefreshIndicator(
            onRefresh: () => provider.fetchActivities(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcomingActivities.isNotEmpty) ...[
                  const Text(
                    'Upcoming Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...upcomingActivities.map((activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ActivityCard(
                          activity: activity,
                          onDelete: () => provider.deleteActivity(activity.id),
                          onUpdate: (updatedActivity) =>
                              provider.updateActivity(updatedActivity),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
                if (recentActivities.isNotEmpty) ...[
                  const Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recentActivities.map((activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ActivityCard(
                          activity: activity,
                          onDelete: () => provider.deleteActivity(activity.id),
                          onUpdate: (updatedActivity) =>
                              provider.updateActivity(updatedActivity),
                        ),
                      )),
                ],
                if (upcomingActivities.isEmpty && recentActivities.isEmpty)
                  const Center(
                    child: Text(
                      'No activities yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddActivityDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
} 