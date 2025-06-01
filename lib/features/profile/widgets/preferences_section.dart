import 'package:flutter/material.dart';

class PreferencesSection extends StatefulWidget {
  const PreferencesSection({super.key});

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  bool _darkMode = false;
  bool _notifications = true;
  String _currency = 'USD';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _PreferenceTile(
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            icon: Icons.dark_mode,
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                // TODO: Implement theme change
              },
            ),
          ),
          const Divider(height: 1),
          _PreferenceTile(
            title: 'Notifications',
            subtitle: 'Enable push notifications',
            icon: Icons.notifications,
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
                // TODO: Implement notification settings
              },
            ),
          ),
          const Divider(height: 1),
          _PreferenceTile(
            title: 'Currency',
            subtitle: 'Select your preferred currency',
            icon: Icons.attach_money,
            trailing: DropdownButton<String>(
              value: _currency,
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                DropdownMenuItem(value: 'JPY', child: Text('JPY')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currency = value;
                  });
                  // TODO: Implement currency change
                }
              },
            ),
          ),
          const Divider(height: 1),
          _PreferenceTile(
            title: 'Language',
            subtitle: 'Select your preferred language',
            icon: Icons.language,
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                DropdownMenuItem(value: 'French', child: Text('French')),
                DropdownMenuItem(value: 'German', child: Text('German')),
                DropdownMenuItem(value: 'Japanese', child: Text('Japanese')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                  // TODO: Implement language change
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget trailing;

  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
      trailing: trailing,
    );
  }
} 