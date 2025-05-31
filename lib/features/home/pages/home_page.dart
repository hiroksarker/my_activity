import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_list.dart';
import '../widgets/add_activity_dialog.dart';
import '../models/activity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize activities when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeActivities();
    });
  }

  Future<void> _initializeActivities() async {
    if (!mounted) return;
    
    try {
      print('Initializing activities...');
      await context.read<ActivityProvider>().fetchActivities();
      print('Activities initialized successfully');
    } catch (e) {
      print('Error initializing activities: $e');
      if (!mounted) return;
      
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading activities: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _initializeActivities,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeActivities,
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading activities...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
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
                  ElevatedButton.icon(
                    onPressed: _initializeActivities,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.activities.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No activities yet.\nTap + to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return const ActivityList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final activity = await showDialog<Activity>(
              context: context,
              builder: (context) => const AddActivityDialog(),
            );

            if (activity != null && mounted) {
              print('Adding new activity: ${activity.toString()}');
              await context.read<ActivityProvider>().addActivity(activity);
              print('Activity added successfully');
            }
          } catch (e) {
            print('Error adding activity: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding activity: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}