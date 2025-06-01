import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    
    try {
      await userProvider.signOut();
      if (context.mounted) {
        Navigator.pop(context); // Close the dialog
        // Navigate to login page and clear the navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);

    if (!userProvider.isAuthenticated) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign in to access settings',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Account Settings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Account',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsTile(
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            icon: Icons.logout,
            textColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => _handleSignOut(context),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          // App Settings
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'App Settings',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsTile(
            title: 'Backup & Restore',
            subtitle: 'Manage your data backup',
            icon: Icons.backup,
            onTap: () {
              // TODO: Implement backup & restore
            },
          ),
          const Divider(height: 1),
          _SettingsTile(
            title: 'Privacy & Security',
            subtitle: 'Manage your privacy settings',
            icon: Icons.security,
            onTap: () {
              // TODO: Implement privacy settings
            },
          ),
          const Divider(height: 1),
          _SettingsTile(
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            icon: Icons.help_outline,
            onTap: () {
              // TODO: Implement help & support
            },
          ),
          const Divider(height: 1),
          _SettingsTile(
            title: 'About',
            subtitle: 'App version and information',
            icon: Icons.info_outline,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'My Activity',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: const [
                  Text(
                    'My Activity is a personal activity and expense tracking app that helps you manage your daily tasks and finances.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    '© 2024 My Activity. All rights reserved.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 