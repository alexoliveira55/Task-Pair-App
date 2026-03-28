import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/errors/auth_error_mapper.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen(authNotifierProvider, (_, next) {
      if (next.hasError) {
        final message = mapAuthErrorToMessage(next.error!, l10n);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l10n.displayName,
                  controller: _nameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.requiredField;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.password,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.requiredField;
                    if (v.length < 6) return l10n.minimumCharacters;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.confirmPassword,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return l10n.passwordsDontMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: l10n.createAccount,
                  onPressed: isLoading ? null : _register,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.hasAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
