import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/responsive_layout.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isUploadingPhoto = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() => _isUploadingPhoto = true);

      final bytes = await image.readAsBytes();
      await ref.read(authNotifierProvider.notifier).updateProfilePhoto(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _updateDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await ref.read(authNotifierProvider.notifier).updateDisplayName(newName);

    if (mounted) {
      setState(() => _isEditingName = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name updated!')),
      );
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserEntityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ResponsiveLayout(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Not signed in'));
            }

            if (!_isEditingName) {
              _nameController.text = user.displayName ?? '';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? const Icon(Icons.person, size: 56)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _isUploadingPhoto
                            ? const SizedBox(
                                width: 36,
                                height: 36,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt,
                                      size: 18, color: Colors.white),
                                  onPressed: _pickAndUploadPhoto,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Email (read-only)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Display name
                  Card(
                    child: _isEditingName
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Display Name',
                                    controller: _nameController,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: _updateDisplayName,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () =>
                                      setState(() => _isEditingName = false),
                                ),
                              ],
                            ),
                          )
                        : ListTile(
                            leading: const Icon(Icons.person_outlined),
                            title: const Text('Display Name'),
                            subtitle: Text(user.displayName ?? 'Not set'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  setState(() => _isEditingName = true),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Pair info
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.people_outlined),
                      title: const Text('Pair'),
                      subtitle:
                          Text(user.pairId != null ? 'Paired' : 'No pair yet'),
                      trailing: user.pairId != null
                          ? IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () => context.push('/pair-management'),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Member since
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Member Since'),
                      subtitle:
                          Text(user.createdAt.toString().split(' ').first),
                    ),
                  ),

                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Sign Out',
                    icon: Icons.logout,
                    color: Colors.red,
                    onPressed: _confirmSignOut,
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
