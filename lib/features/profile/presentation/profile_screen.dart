import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../core/utils/app_snack_bar.dart';
import '../../../core/theme/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
      if (image == null) return;

      setState(() => _isUploading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');

      final bytes = await image.readAsBytes();
      await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
      });

      // Refetch user data
      ref.invalidate(authControllerProvider);
      
      if (mounted) {
        AppSnackBar.showSuccess(context, 'Profile picture updated!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Upload failed',
            detail: e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;
                
                Navigator.pop(context);
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                try {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'name': newName,
                  });
                  ref.invalidate(authControllerProvider);
                  if (mounted) AppSnackBar.showSuccess(context, 'Name updated!');
                } catch (e) {
                  if (mounted) AppSnackBar.showError(context, 'Update failed', detail: e.toString());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authControllerProvider);
    final user = userAsync.value;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: user.photoUrl != null 
                          ? NetworkImage(user.photoUrl!) 
                          : null,
                      child: user.photoUrl == null 
                          ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                          : null,
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(color: Colors.white),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name ?? 'No Name',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditNameDialog(user.name ?? ''),
                    tooltip: 'Edit Name',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  user.role,
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 48),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme Mode'),
                trailing: DropdownButton<ThemeMode>(
                  value: ref.watch(themeProvider),
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeProvider.notifier).setTheme(mode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
