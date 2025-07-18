import 'package:flutter/material.dart';
import 'documentation_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/modern_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSection(
            context,
            title: 'Account',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Manage your profile information',
                onTap: () => _showComingSoon(context, 'Profile'),
              ),
              _buildSettingItem(
                context,
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Control your privacy settings',
                onTap: () => _showComingSoon(context, 'Privacy & Security'),
              ),
            ],
          ),
          
          // App Settings
          _buildSection(
            context,
            title: 'App Settings',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () => _showComingSoon(context, 'Notifications'),
              ),
              _buildSettingItem(
                context,
                icon: Icons.palette,
                title: 'Theme',
                subtitle: 'Choose your preferred theme',
                onTap: () => _showThemeDialog(context),
              ),
              _buildSettingItem(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Select your language',
                onTap: () => _showComingSoon(context, 'Language'),
              ),
            ],
          ),
          
          // Data & Storage
          _buildSection(
            context,
            title: 'Data & Storage',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.backup,
                title: 'Backup & Sync',
                subtitle: 'Manage your data backup',
                onTap: () => _showComingSoon(context, 'Backup & Sync'),
              ),
              _buildSettingItem(
                context,
                icon: Icons.storage,
                title: 'Storage',
                subtitle: 'Manage app storage usage',
                onTap: () => _showComingSoon(context, 'Storage'),
              ),
            ],
          ),
          
          // Support
          _buildSection(
            context,
            title: 'Support',
            children: [
              _buildSettingItem(
                context,
                icon: Icons.help,
                title: 'Help & Documentation',
                subtitle: 'Get help and view documentation',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentationScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () => _showComingSoon(context, 'Send Feedback'),
              ),
              _buildSettingItem(
                context,
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ModernCard(
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppTheme.accent.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              '$feature is coming soon! We\'re working hard to bring you this feature.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System Default'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme set to System Default'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Theme'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme set to Light'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Theme'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme set to Dark'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'My Activity',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.explore,
          color: AppTheme.primaryBlue,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'A comprehensive personal activity and travel companion app with features for task management, financial tracking, travel planning, and daily exploration.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Daily Explorer - Travel companion'),
        const Text('• Task & Activity Management'),
        const Text('• Financial Tracking'),
        const Text('• Budget & Trip Planning'),
        const Text('• Calendar Integration'),
        const Text('• Document Management'),
        const Text('• Analytics & Insights'),
      ],
    );
  }
}