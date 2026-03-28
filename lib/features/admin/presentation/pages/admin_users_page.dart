import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final usersAsync = ref.watch(allUsersProvider);

    ref.listen<AsyncValue<void>>(adminNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminUserManagement),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text(l10n.noData));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allUsersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user.displayName ?? user.email),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.isAdmin)
                          Chip(
                            label: Text(l10n.admin),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'toggle_admin') {
                              _confirmToggleAdmin(context, ref, user);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle_admin',
                              child: Text(user.isAdmin
                                  ? l10n.removeAdmin
                                  : l10n.makeAdmin),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }

  void _confirmToggleAdmin(
      BuildContext context, WidgetRef ref, dynamic user) async {
    final l10n = AppLocalizations.of(context);
    final newStatus = !user.isAdmin;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? l10n.makeAdmin : l10n.removeAdmin),
        content: Text(
          newStatus
              ? l10n.confirmMakeAdmin(user.displayName ?? user.email)
              : l10n.confirmRemoveAdmin(user.displayName ?? user.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(adminNotifierProvider.notifier)
          .toggleAdmin(user.id, newStatus);
    }
  }

  void _showCreateUserDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _CreateUserDialog(),
    );
  }
}

class _CreateUserDialog extends ConsumerStatefulWidget {
  const _CreateUserDialog();

  @override
  ConsumerState<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final adminUser = ref.read(currentUserEntityProvider).value;
    if (adminUser == null) return;

    await ref.read(adminNotifierProvider.notifier).createUserForThirdParty(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          adminEmail: adminUser.email,
          adminPassword: _adminPasswordController.text,
        );

    if (!mounted) return;
    final error = ref.read(adminNotifierProvider).error;
    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).userCreated)),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.createUser),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: l10n.displayName,
                controller: _nameController,
                prefixIcon: Icons.person_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.requiredField;
                  if (!v.contains('@')) return l10n.enterValidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.password,
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.requiredField;
                  if (v.length < 6) return l10n.minimumCharacters;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(l10n.adminPasswordRequired,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              AppTextField(
                label: l10n.adminPassword,
                controller: _adminPasswordController,
                obscureText: true,
                prefixIcon: Icons.admin_panel_settings,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.requiredField : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        AppButton(
          label: l10n.createUser,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }
}
