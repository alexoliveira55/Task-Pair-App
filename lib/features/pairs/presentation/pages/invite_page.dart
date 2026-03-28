import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pair_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../domain/entities/user_entity.dart';

class InvitePage extends ConsumerStatefulWidget {
  const InvitePage({super.key});

  @override
  ConsumerState<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends ConsumerState<InvitePage> {
  final _formKey = GlobalKey<FormState>();
  UserEntity? _selectedUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pair = ref.watch(currentPairProvider);
    final pairState = ref.watch(pairNotifierProvider);
    final availableUsersAsync = ref.watch(availableUsersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invitePartner)),
      body: pair == null
          ? Center(child: Text(l10n.noPairs))
          : SingleChildScrollView(
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
                    availableUsersAsync.when(
                      data: (users) {
                        if (users.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              l10n.noAvailableUsers,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          );
                        }
                        return DropdownButtonFormField<UserEntity>(
                          value: _selectedUser,
                          decoration: InputDecoration(
                            labelText: l10n.selectUser,
                            prefixIcon: const Icon(Icons.person_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          items: users.map((user) {
                            final label = user.displayName != null &&
                                    user.displayName!.isNotEmpty
                                ? '${user.displayName} (${user.email})'
                                : user.email;
                            return DropdownMenuItem<UserEntity>(
                              value: user,
                              child:
                                  Text(label, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (user) =>
                              setState(() => _selectedUser = user),
                          validator: (v) =>
                              v == null ? l10n.requiredField : null,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, _) => Text(e.toString()),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: l10n.sendInvite,
                      isLoading: pairState.isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_selectedUser == null) return;
                        await ref
                            .read(pairNotifierProvider.notifier)
                            .sendInvite(
                              pairId: pair.id,
                              inviteUserId: _selectedUser!.id,
                              inviteEmail: _selectedUser!.email,
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
                          setState(() => _selectedUser = null);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
