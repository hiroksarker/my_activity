import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/travel_activity.dart';
import '../models/travel_alert.dart';
import '../providers/daily_explorer_provider.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../../../widgets/modern_background.dart';
import '../../../widgets/modern_card.dart' as custom_card;
import '../../../widgets/empty_state.dart' as custom_empty;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_header.dart' as custom_header;

class DailyDashboardScreen extends StatefulWidget {
  const DailyDashboardScreen({super.key});

  @override
  State<DailyDashboardScreen> createState() => _DailyDashboardScreenState();
}

class _DailyDashboardScreenState extends State<DailyDashboardScreen> with AutomaticKeepAliveClientMixin {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final provider = context.read<DailyExplorerProvider>();
    await Future.wait([
      provider.loadTodayActivities(),
      provider.loadActiveAlerts(),
      provider.updateLocation(),
      provider.updateWeather(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<DailyExplorerProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            key: _refreshKey,
            onRefresh: _loadDashboardData,
            child: CustomScrollView(
              slivers: [
                // App Bar with Location and Weather
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.white24,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daily Explorer',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          DateFormat.yMMMMEEEEd().format(DateTime.now()),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // TODO: Open settings/profile
                                    },
                                    icon: const Icon(Icons.settings, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildLocationWeatherCard(provider),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Active Alerts
                if (provider.activeAlerts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildAlertsSection(provider.activeAlerts),
                  ),

                // Current Activity
                if (provider.currentActivity != null)
                  SliverToBoxAdapter(
                    child: _buildCurrentActivitySection(provider.currentActivity!),
                  ),

                // Today's Activities
                SliverToBoxAdapter(
                  child: _buildActivitiesSection(provider),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: _buildQuickActionsSection(),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),

    );
  }

  Widget _buildLocationWeatherCard(DailyExplorerProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.currentLocation?.address ?? 'Getting location...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          if (provider.currentWeather != null) ...[
            Icon(
              _getWeatherIcon(provider.currentWeather!.description),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              provider.currentWeather!.temperatureDisplay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertsSection(List<TravelAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const custom_header.SectionHeader(
          title: 'Active Alerts',
          subtitle: 'Important updates',
        ),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(TravelAlert alert) {
    Color alertColor;
    IconData alertIcon;

    switch (alert.priority) {
      case AlertPriority.critical:
        alertColor = AppTheme.error;
        alertIcon = Icons.error;
        break;
      case AlertPriority.high:
        alertColor = AppTheme.warning;
        alertIcon = Icons.warning;
        break;
      default:
        alertColor = AppTheme.primaryBlue;
        alertIcon = Icons.info;
    }

    return custom_card.ModernCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(alertIcon, color: alertColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: alertColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.jm().format(alert.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Dismiss alert
            },
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentActivitySection(TravelActivity activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const custom_header.SectionHeader(
          title: 'Now',
          subtitle: 'Current activity',
        ),
        custom_card.ModernCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getActivityIcon(activity.type),
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat.jm().format(activity.startTime)} - ${DateFormat.jm().format(activity.endTime)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (activity.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to activity
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navigate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Capture memory
                      },
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Capture'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(DailyExplorerProvider provider) {
    final upcomingActivities = provider.todayActivities
        .where((a) => a.status == ActivityStatus.upcoming)
        .toList();
    
    final completedActivities = provider.todayActivities
        .where((a) => a.status == ActivityStatus.completed)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (upcomingActivities.isNotEmpty) ...[
          custom_header.SectionHeader(
            title: 'Upcoming Today',
            subtitle: '${upcomingActivities.length} activities',
          ),
          ...upcomingActivities.map((activity) => _buildActivityCard(activity)),
        ],
        
        if (completedActivities.isNotEmpty) ...[
          custom_header.SectionHeader(
            title: 'Completed',
            subtitle: '${completedActivities.length} done',
          ),
          ...completedActivities.map((activity) => _buildActivityCard(activity)),
        ],

        if (provider.todayActivities.isEmpty) ...[
          const custom_empty.EmptyState(
            icon: Icons.event_available,
            title: 'No Activities Today',
            subtitle: 'Add your first activity to get started with Daily Explorer',
          ),
        ],
      ],
    );
  }

  Widget _buildActivityCard(TravelActivity activity) {
    final isCompleted = activity.status == ActivityStatus.completed;
    
    return custom_card.ModernCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        // TODO: Navigate to activity details
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: isCompleted ? AppTheme.success : AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppTheme.textSecondary : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat.jm().format(activity.startTime),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activity.statusDisplayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCompleted ? AppTheme.success : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const custom_header.SectionHeader(
          title: 'Quick Actions',
          subtitle: 'Capture your journey',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.camera_alt,
                  title: 'Capture',
                  subtitle: 'Photo & Notes',
                  color: AppTheme.accent,
                  onTap: () {
                    // TODO: Open camera
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.receipt,
                  title: 'Expense',
                  subtitle: 'Log spending',
                  color: AppTheme.success,
                  onTap: () {
                    // TODO: Open expense tracker
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.explore,
                  title: 'Discover',
                  subtitle: 'Find nearby',
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    // TODO: Open discovery
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return custom_card.ModernCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.flight:
        return Icons.flight;
      case ActivityType.hotel:
        return Icons.hotel;
      case ActivityType.restaurant:
        return Icons.restaurant;
      case ActivityType.attraction:
        return Icons.place;
      case ActivityType.transport:
        return Icons.directions_bus;
      case ActivityType.meeting:
        return Icons.business;
      case ActivityType.other:
        return Icons.event;
    }
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('rain')) return Icons.water_drop;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('sun') || desc.contains('clear')) return Icons.wb_sunny;
    if (desc.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }
}