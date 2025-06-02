import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Image Upload Features',
            icon: Icons.upload_file,
            content: [
              _buildFeatureCard(
                context,
                title: 'Uploading Images',
                description: 'Learn how to upload and manage images for your tips and receipts.',
                items: [
                  'Tap the "Add Image" button in the tip details screen',
                  'Choose between camera or gallery',
                  'Select or take a photo',
                  'Wait for upload to complete',
                  'View your uploaded image',
                ],
                icon: Icons.add_photo_alternate,
              ),
              _buildFeatureCard(
                context,
                title: 'Supported Formats',
                description: 'Types of images you can upload:',
                items: [
                  'JPEG (.jpg, .jpeg)',
                  'PNG (.png)',
                  'HEIC (.heic)',
                ],
                icon: Icons.image,
              ),
              _buildFeatureCard(
                context,
                title: 'Technical Requirements',
                description: 'Requirements for uploading images:',
                items: [
                  'Maximum file size: 5MB',
                  'Recommended resolution: 1024x1024 pixels',
                  'Images are automatically compressed',
                  'Requires internet connection',
                ],
                icon: Icons.settings,
              ),
              _buildFeatureCard(
                context,
                title: 'Managing Images',
                description: 'How to manage your uploaded images:',
                items: [
                  'View images in tip details',
                  'Delete images using the delete button',
                  'Replace images by uploading new ones',
                  'Images are automatically backed up',
                ],
                icon: Icons.manage_accounts,
              ),
              _buildFeatureCard(
                context,
                title: 'Security & Privacy',
                description: 'How we protect your images:',
                items: [
                  'Images are stored securely in Firebase',
                  'Each image is linked to your tip ID',
                  'Only you can access your images',
                  'Old images are automatically cleaned up',
                ],
                icon: Icons.security,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Best Practices',
            icon: Icons.lightbulb_outline,
            content: [
              _buildFeatureCard(
                context,
                title: 'Taking Good Photos',
                description: 'Tips for capturing clear images:',
                items: [
                  'Ensure good lighting',
                  'Keep receipts flat and well-lit',
                  'Avoid blurry or dark images',
                  'Crop unnecessary background',
                  'Check image clarity before uploading',
                ],
                icon: Icons.camera_alt,
              ),
              _buildFeatureCard(
                context,
                title: 'Managing Storage',
                description: 'Tips for managing your image storage:',
                items: [
                  'Delete unnecessary images',
                  'Replace low-quality images',
                  'Keep only important receipts',
                  'Regularly review your uploads',
                ],
                icon: Icons.storage,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Troubleshooting',
            icon: Icons.help_outline,
            content: [
              _buildFeatureCard(
                context,
                title: 'Common Issues',
                description: 'Solutions for common problems:',
                items: [
                  'Upload fails: Check internet connection',
                  'Image too large: Compress before uploading',
                  'Wrong format: Convert to supported format',
                  'Upload slow: Check network speed',
                  'Image not showing: Try refreshing',
                ],
                icon: Icons.error_outline,
              ),
              _buildFeatureCard(
                context,
                title: 'Need More Help?',
                description: 'Additional support options:',
                items: [
                  'Contact support through the app',
                  'Check our online documentation',
                  'Visit our help center',
                  'Email support team',
                ],
                icon: Icons.support_agent,
                onTap: () => _launchHelpCenter(),
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
    required IconData icon,
    required List<Widget> content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...content,
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<String> items,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchHelpCenter() async {
    // Replace with your actual help center URL
    const url = 'https://your-help-center-url.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
} 