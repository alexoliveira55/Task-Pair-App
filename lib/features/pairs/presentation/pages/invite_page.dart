import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pair_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_widget.dart';

class InvitePage extends ConsumerStatefulWidget {
  const InvitePage({super.key});

  @override
  ConsumerState<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends ConsumerState<InvitePage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pairAsync = ref.watch(currentPairProvider);
    final pairState = ref.watch(pairNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invitePartner)),
      body: pairAsync.when(
        data: (pair) {
          if (pair == null) {
            return Center(child: Text(l10n.noPairs));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.pairs}: ${pair.name}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(l10n.targetPoints(pair.scoreTarget)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: l10n.inviteEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.requiredField;
                      if (!v.contains('@')) return l10n.enterValidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: l10n.sendInvite,
                    isLoading: pairState.isLoading,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await ref.read(pairNotifierProvider.notifier).sendInvite(
                            pairId: pair.id,
                            inviteEmail: _emailController.text.trim(),
                          );
                      if (!mounted) return;
                      final error = ref.read(pairNotifierProvider).error;
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${l10n.error}: $error')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.inviteSent)),
                        );
                        _emailController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
