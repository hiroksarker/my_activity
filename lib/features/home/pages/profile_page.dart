import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person, size: 28),
            SizedBox(width: 8),
            Text('Profile'),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activities = provider.activities;
          final completedActivities = activities
              .where((activity) => activity.status == 'completed')
              .length;
          final pendingActivities = activities
              .where((activity) => activity.status == 'pending')
              .length;
          final totalAmount = activities.fold<double>(
            0,
            (sum, activity) => sum + activity.amount,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'User Name',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'user@example.com',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Activity Statistics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.analytics, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Activity Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Completed Activities',
                        completedActivities.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Pending Activities',
                        pendingActivities.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Total Amount',
                        '\$${totalAmount.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Settings Section
              Card(
                child: Column(
                  children: [
                    _buildSettingTile(
                      'Notifications',
                      Icons.notifications,
                      onTap: () {
                        // Handle notifications settings
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingTile(
                      'Theme',
                      Icons.palette,
                      onTap: () {
                        // Handle theme settings
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingTile(
                      'Language',
                      Icons.language,
                      onTap: () {
                        // Handle language settings
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingTile(
                      'About',
                      Icons.info,
                      onTap: () {
                        // Show about dialog
                        showAboutDialog(
                          context: context,
                          applicationName: 'My Activity',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(
                            Icons.task_alt,
                            size: 48,
                            color: Colors.blue,
                          ),
                          children: const [
                            SizedBox(height: 16),
                            Text(
                              'My Activity is a simple and efficient way to track your daily activities and manage your tasks.',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  // Handle logout
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 