import 'package:flutter/material.dart';
import '../../../core/design_system/forms/modern_form_scaffold.dart';
import '../../../core/design_system/forms/modern_text_field.dart';
import '../../../core/design_system/forms/form_spacing.dart';

/// Demo screen showing the improved form UI with proper spacing
/// This demonstrates the fixes for overlapping elements and poor alignment
class ModernFormDemoScreen extends StatefulWidget {
  const ModernFormDemoScreen({super.key});

  @override
  State<ModernFormDemoScreen> createState() => _ModernFormDemoScreenState();
}

class _ModernFormDemoScreenState extends State<ModernFormDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _cancelForm() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ModernFormScaffold(
      title: 'Modern Form Demo',
      isLoading: _isLoading,
      onSave: _saveForm,
      onCancel: _cancelForm,
      saveButtonText: 'Save Changes',
      cancelButtonText: 'Cancel',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Basic Information Section
            ModernFormSection(
              title: 'Basic Information',
              subtitle: 'Enter your basic details below',
              icon: Icons.person,
              children: [
                ModernTextField(
                  controller: _titleController,
                  label: 'Title',
                  hintText: 'Enter a title',
                  prefixIcon: Icons.title,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                ModernTextArea(
                  controller: _descriptionController,
                  label: 'Description',
                  hintText: 'Enter a detailed description',
                  helperText: 'Provide as much detail as possible',
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                ),
              ],
            ),

            // Contact Information Section
            ModernFormSection(
              title: 'Contact Information',
              subtitle: 'How can we reach you?',
              icon: Icons.contact_mail,
              children: [
                ModernTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'your.email@example.com',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                ModernTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: '+1 (555) 123-4567',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  helperText: 'Include country code if international',
                ),
              ],
            ),

            // Search Demo Section
            ModernFormSection(
              title: 'Search Example',
              subtitle: 'Demonstrating search field with proper spacing',
              icon: Icons.search,
              children: [
                ModernSearchField(
                  hintText: 'Search for anything...',
                  onChanged: (value) {
                    print('Search: $value');
                  },
                  onSubmitted: (value) {
                    print('Search submitted: $value');
                  },
                ),
              ],
            ),

            // Spacing demonstration
            FormSpacing.gapXl,
            
            // Info card showing improvements
            Container(
              padding: FormSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: FormSpacing.borderRadiusLg,
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: FormSpacing.iconSize,
                      ),
                      FormSpacing.gapHorizontalSm,
                      Text(
                        'UI Improvements',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  FormSpacing.gapSm,
                  Text(
                    '✓ Fixed overlapping elements with proper spacing\n'
                    '✓ Consistent gaps between form fields\n'
                    '✓ Proper icon alignment and sizing\n'
                    '✓ Better visual hierarchy with sections\n'
                    '✓ Responsive layout for all screen sizes\n'
                    '✓ Accessible color combinations\n'
                    '✓ Touch-friendly button sizes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}