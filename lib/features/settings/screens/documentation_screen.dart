import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/modern_card.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Documentation'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Getting Started',
            icon: Icons.play_arrow,
            color: AppTheme.primaryBlue,
            items: [
              'Welcome to My Activity',
              'Setting up your profile',
              'First time setup guide',
              'Basic navigation',
            ],
          ),
          _buildSection(
            context,
            title: 'Daily Explorer',
            icon: Icons.explore,
            color: AppTheme.accent,
            items: [
              'Travel companion features',
              'Managing activities',
              'Location and weather',
              'Memory capture',
            ],
          ),
          _buildSection(
            context,
            title: 'Financial Management',
            icon: Icons.account_balance_wallet,
            color: AppTheme.success,
            items: [
              'Tracking expenses',
              'Budget planning',
              'Financial reports',
              'Trip budgets',
            ],
          ),
          _buildSection(
            context,
            title: 'Task Management',
            icon: Icons.task_alt,
            color: Colors.purple,
            items: [
              'Creating tasks',
              'Task organization',
              'Progress tracking',
              'Productivity tips',
            ],
          ),
          _buildSection(
            context,
            title: 'Support',
            icon: Icons.help,
            color: Colors.orange,
            items: [
              'Frequently asked questions',
              'Contact support',
              'Report a bug',
              'Feature requests',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildDocItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildDocItem(BuildContext context, String title) {
    return InkWell(
      onTap: () => _showDocumentationDetail(context, title),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
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

  void _showDocumentationDetail(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article,
              size: 64,
              color: AppTheme.primaryBlue.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Documentation content would be displayed here in the full version of the app.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}