import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/itinerary_provider.dart';
import '../models/itinerary_item.dart';
import 'add_activity_dialog.dart';
import 'add_itinerary_item_dialog.dart';
import '../../../widgets/green_pills_wallpaper.dart';
import '../../../widgets/confirmation_dialog.dart';

class ItineraryTab extends StatefulWidget {
  final int tripId;
  const ItineraryTab({required this.tripId});

  @override
  State<ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<ItineraryTab> {
  @override
  void initState() {
    super.initState();
    Provider.of<ItineraryProvider>(context, listen: false).loadItinerary(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return GreenPillsWallpaper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<ItineraryProvider>(
          builder: (context, provider, _) {
            final items = provider.items.where((item) => item.tripId == widget.tripId).toList();
            
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, size: 64, color: Colors.blueGrey),
                    SizedBox(height: 16),
                    Text('No activities yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Tap + to add your first activity!', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            // Group by activity name
            final activities = <String, List<ItineraryItem>>{};
            for (var item in items) {
              activities.putIfAbsent(item.activity, () => []).add(item);
            }

            // Sort activities by date and time
            activities.forEach((_, items) {
              items.sort((a, b) {
                final dateCompare = a.date.compareTo(b.date);
                if (dateCompare != 0) return dateCompare;
                return a.time.compareTo(b.time);
              });
            });

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activityName = activities.keys.elementAt(index);
                final activityItems = activities[activityName]!;
                final hasTimeSlots = activityItems.any((item) => item.time != '00:00 AM');
                
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activity header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activityName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                            _ActionIcon(
                              icon: Icons.edit_rounded,
                              color: Colors.orange,
                              tooltip: 'Edit activity name',
                              onTap: () => _showEditActivityDialog(context, activityName),
                            ),
                            SizedBox(width: 4),
                            _ActionIcon(
                              icon: Icons.delete_rounded,
                              color: Colors.red,
                              tooltip: 'Delete activity',
                              onTap: () => _tryDeleteActivity(context, activityName, activityItems),
                            ),
                            SizedBox(width: 4),
                            _ActionIcon(
                              icon: Icons.add_circle_rounded,
                              color: Colors.blue,
                              tooltip: 'Add time slot',
                              onTap: () => _showAddTimeSlotDialog(context, activityName),
                            ),
                          ],
                        ),
                      ),
                      // Time slots or placeholder
                      if (!hasTimeSlots)
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No time slots yet. Tap + to add.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        ...activityItems.where((item) => item.time != '00:00 AM').map((item) => Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.time,
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(item.notes),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionIcon(
                                  icon: Icons.edit_rounded,
                                  color: Colors.teal,
                                  tooltip: 'Edit time slot',
                                  onTap: () => _showEditTimeSlotDialog(context, item),
                                ),
                                SizedBox(width: 4),
                                _ActionIcon(
                                  icon: Icons.delete_rounded,
                                  color: Colors.red,
                                  tooltip: 'Delete time slot',
                                  onTap: () => _deleteTimeSlot(context, item),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddActivityDialog(context),
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddActivityDialog(tripId: widget.tripId),
    );
  }

  void _showAddTimeSlotDialog(BuildContext context, String activityName) {
    showDialog(
      context: context,
      builder: (context) => AddItineraryItemDialog(
        tripId: widget.tripId,
        activityName: activityName,
      ),
    );
  }

  void _showEditActivityDialog(BuildContext context, String activityName) {
    // TODO: Implement edit activity name dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit activity name coming soon!')),
    );
  }

  void _tryDeleteActivity(BuildContext context, String activityName, List<ItineraryItem> items) {
    final hasTimeSlots = items.any((item) => item.time != '00:00 AM');
    if (hasTimeSlots) {
      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
          title: 'Cannot Delete Activity',
          content: 'Please delete all time slots before deleting this activity.',
          icon: Icons.warning_rounded,
          iconColor: Colors.orange,
          onConfirm: () => _showDeleteActivityConfirmation(context, activityName, items),
        ),
      );
    } else {
      _showDeleteActivityConfirmation(context, activityName, items);
    }
  }

  void _showDeleteActivityConfirmation(BuildContext context, String activityName, List<ItineraryItem> items) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Activity',
        content: 'Are you sure you want to delete this activity?',
        icon: Icons.delete_rounded,
        iconColor: Colors.red,
        onConfirm: () async {
          final provider = context.read<ItineraryProvider>();
          for (final item in items) {
            await provider.deleteItineraryItem(item.id, item.tripId);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditTimeSlotDialog(BuildContext context, ItineraryItem item) {
    // TODO: Implement edit time slot dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit time slot coming soon!')),
    );
  }

  void _deleteTimeSlot(BuildContext context, ItineraryItem item) async {
    final provider = context.read<ItineraryProvider>();
    await provider.deleteItineraryItem(item.id, item.tripId);
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}