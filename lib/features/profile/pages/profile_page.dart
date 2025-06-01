import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../shared/services/firebase_service.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart' as app_auth;
import 'package:your_app/widgets/green_pills_wallpaper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _nameController.text = data['name'] as String? ?? '';
      }
    }
  }

  Future<void> _updateProfile({String? name}) async {
    if (name != null && !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final newName = name ?? _nameController.text.trim();
      await user.updateDisplayName(newName);
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'name': newName});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await context.read<app_auth.AuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      try {
        setState(() => _isLoading = true);
        
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('No user logged in');

        final file = File(pickedFile.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${user.uid}.jpg');

        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();

        await user.updatePhotoURL(downloadUrl);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoUrl': downloadUrl});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile picture: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GreenPillsWallpaper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar
              GestureDetector(
                onTap: () => _pickAndUploadImage(context),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                          ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                          : null,
                      child: FirebaseAuth.instance.currentUser?.photoURL == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Name
              Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'No Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Email
              Text(
                FirebaseAuth.instance.currentUser?.email ?? 'No Email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              // Profile Info Card
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: FirebaseAuth.instance.currentUser?.displayName ?? 'Not set',
                        onTap: () => _showEditDialog(
                          context,
                          title: 'Edit Name',
                          initialValue: FirebaseAuth.instance.currentUser?.displayName ?? '',
                          onSave: (value) => _updateProfile(name: value),
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: FirebaseAuth.instance.currentUser?.email ?? 'Not set',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: FirebaseAuth.instance.currentUser?.metadata.creationTime != null
                            ? DateFormat('MMM d, y').format(FirebaseAuth.instance.currentUser!.metadata.creationTime!)
                            : 'Unknown',
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onTap,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Value',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 