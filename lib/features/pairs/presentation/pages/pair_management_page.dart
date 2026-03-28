import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pair_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/pair_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/admin/presentation/providers/admin_provider.dart';
import '../../../../domain/entities/pair_invite_entity.dart';

class PairManagementPage extends ConsumerWidget {
  const PairManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final myPairsAsync = ref.watch(myPairsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pairs)),
      body: myPairsAsync.when(
        data: (pairs) {
          if (pairs.isEmpty) {
            return const _NoPairView();
          }
          return _PairsWithInvitesView(pairs: pairs);
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}

/// View shown when user HAS pairs — list of pairs + invite tabs below.
class _PairsWithInvitesView extends ConsumerWidget {
  final List<PairEntity> pairs;
  const _PairsWithInvitesView({required this.pairs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pairs.length,
            itemBuilder: (context, index) {
              return _PairDetailsView(pair: pairs[index]);
            },
          ),
        ),
        const Divider(),
        Expanded(
          flex: 1,
          child: const _NoPairView(),
        ),
      ],
    );
  }
}

/// View shown when user has no pair — tabs for sent/received invites + send new invite.
class _NoPairView extends ConsumerWidget {
  const _NoPairView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = ref.watch(isAdminProvider);

    return DefaultTabController(
      length: isAdmin ? 4 : 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.sendInvite),
              Tab(text: l10n.sentInvites),
              Tab(text: l10n.receivedInvites),
              if (isAdmin) Tab(text: l10n.adminInvites),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const _CreatePairView(),
                const _SentInvitesView(),
                const _ReceivedInvitesView(),
                if (isAdmin) const _AdminInvitesView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PairDetailsView extends ConsumerStatefulWidget {
  final PairEntity pair;

  const _PairDetailsView({required this.pair});

  @override
  ConsumerState<_PairDetailsView> createState() => _PairDetailsViewState();
}

class _PairDetailsViewState extends ConsumerState<_PairDetailsView> {
  Future<void> _confirmLeavePair() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leavePair),
        content: Text(l10n.confirmLeavePair),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text(l10n.leavePair, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(pairNotifierProvider.notifier).leavePair(widget.pair);
      if (mounted) {
        context.go('/dashboard');
      }
    }
  }

  String _roleLabel(PairEntity pair, String? userId, AppLocalizations l10n) {
    if (pair.requesterId == userId) return 'Requester';
    if (pair.executorId == userId) return 'Executor';
    return 'Member';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pair = widget.pair;
    final currentUser = ref.watch(currentUserEntityProvider).value;

    ref.listen<AsyncValue<void>>(pairNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pair.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(_roleLabel(pair, currentUser?.id, l10n)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${l10n.scoreTarget}: ${pair.scoreTarget}'),
            Text(
                '${l10n.createdAt}: ${pair.createdAt.toString().split(' ').first}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLeavePair(),
                icon:
                    const Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                label: Text(l10n.leavePair,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sent invites tab — shows all invites the current user has sent.
class _SentInvitesView extends ConsumerWidget {
  const _SentInvitesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sentAsync = ref.watch(sentInvitesProvider);

    return sentAsync.when(
      data: (invites) {
        if (invites.isEmpty) {
          return Center(child: Text(l10n.noSentInvites));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invites.length,
          itemBuilder: (context, index) {
            final invite = invites[index];
            return _InviteCard(
              invite: invite,
              titleText: invite.pairName.isNotEmpty
                  ? invite.pairName
                  : l10n.inviteTo(invite.toEmail),
              subtitleText:
                  '${invite.toEmail} — ${_statusLabel(invite.status, l10n)}',
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }
}

/// Received invites tab — shows all invites sent to the current user.
class _ReceivedInvitesView extends ConsumerWidget {
  const _ReceivedInvitesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final receivedAsync = ref.watch(pendingInvitesProvider);

    ref.listen<AsyncValue<void>>(pairNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        },
      );
    });

    return receivedAsync.when(
      data: (invites) {
        if (invites.isEmpty) {
          return Center(child: Text(l10n.noReceivedInvites));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invites.length,
          itemBuilder: (context, index) {
            final invite = invites[index];
            final isPending = invite.status == AppConstants.inviteStatusPending;
            return _InviteCard(
              invite: invite,
              titleText: invite.pairName.isNotEmpty
                  ? invite.pairName
                  : l10n.invitedBy(invite.fromUserId),
              subtitleText:
                  '${l10n.invitedBy(invite.fromUserId)} — ${_statusLabel(invite.status, l10n)}',
              trailing: isPending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => ref
                              .read(pairNotifierProvider.notifier)
                              .acceptInvite(invite),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => ref
                              .read(pairNotifierProvider.notifier)
                              .declineInvite(invite.id),
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }
}

/// Admin invites tab — shows all invites from non-admin users.
class _AdminInvitesView extends ConsumerWidget {
  const _AdminInvitesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allInvitesAsync = ref.watch(adminAllInvitesProvider);

    ref.listen<AsyncValue<void>>(pairNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        },
      );
    });

    return allInvitesAsync.when(
      data: (invites) {
        if (invites.isEmpty) {
          return Center(child: Text(l10n.noReceivedInvites));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invites.length,
          itemBuilder: (context, index) {
            final invite = invites[index];
            final isPending = invite.status == AppConstants.inviteStatusPending;
            return _InviteCard(
              invite: invite,
              titleText: invite.pairName.isNotEmpty
                  ? invite.pairName
                  : '${invite.fromUserId} → ${invite.toEmail}',
              subtitleText:
                  '${invite.fromUserId} → ${invite.toEmail} — ${_statusLabel(invite.status, l10n)}',
              trailing: isPending
                  ? TextButton.icon(
                      icon: const Icon(Icons.check, color: Colors.green),
                      label: Text(l10n.acceptOnBehalf),
                      onPressed: () => ref
                          .read(pairNotifierProvider.notifier)
                          .acceptInviteAsAdmin(invite),
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }
}

/// Reusable invite card widget.
class _InviteCard extends StatelessWidget {
  final PairInviteEntity invite;
  final String titleText;
  final String subtitleText;
  final Widget? trailing;

  const _InviteCard({
    required this.invite,
    required this.titleText,
    required this.subtitleText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          _statusIcon(invite.status),
          color: _statusColor(invite.status),
        ),
        title: Text(titleText),
        subtitle: Text(subtitleText),
        trailing: trailing,
      ),
    );
  }
}

String _statusLabel(String status, AppLocalizations l10n) {
  switch (status) {
    case AppConstants.inviteStatusPending:
      return l10n.statusPending;
    case AppConstants.inviteStatusAccepted:
      return l10n.statusAccepted;
    case AppConstants.inviteStatusRejected:
      return l10n.statusDeclined;
    default:
      return status;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case AppConstants.inviteStatusPending:
      return Icons.hourglass_empty;
    case AppConstants.inviteStatusAccepted:
      return Icons.check_circle;
    case AppConstants.inviteStatusRejected:
      return Icons.cancel;
    default:
      return Icons.help_outline;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case AppConstants.inviteStatusPending:
      return Colors.orange;
    case AppConstants.inviteStatusAccepted:
      return Colors.green;
    case AppConstants.inviteStatusRejected:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class _CreatePairView extends ConsumerStatefulWidget {
  const _CreatePairView();

  @override
  ConsumerState<_CreatePairView> createState() => _CreatePairViewState();
}

class _CreatePairViewState extends ConsumerState<_CreatePairView> {
  final _formKey = GlobalKey<FormState>();
  final _pairNameController = TextEditingController();
  final _scoreTargetController =
      TextEditingController(text: AppConstants.defaultScoreTarget.toString());
  UserEntity? _selectedUser;
  bool _nameAutoFilled = false;

  @override
  void dispose() {
    _pairNameController.dispose();
    _scoreTargetController.dispose();
    super.dispose();
  }

  void _onUserSelected(UserEntity? user) {
    setState(() {
      _selectedUser = user;
      if (user != null &&
          user.displayName != null &&
          user.displayName!.isNotEmpty) {
        _pairNameController.text = user.displayName!;
        _nameAutoFilled = true;
      } else {
        _pairNameController.clear();
        _nameAutoFilled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(pairNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        },
        data: (_) {
          if (prev?.isLoading == true) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inviteSent)),
            );
            setState(() {
              _selectedUser = null;
              _pairNameController.clear();
              _nameAutoFilled = false;
              _scoreTargetController.text =
                  AppConstants.defaultScoreTarget.toString();
            });
          }
        },
      );
    });
    final l10n = AppLocalizations.of(context);
    final pairState = ref.watch(pairNotifierProvider);
    final availableUsersAsync = ref.watch(availableUsersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sendInvite,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            availableUsersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.noAvailableUsers,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
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
                    final label =
                        user.displayName != null && user.displayName!.isNotEmpty
                            ? '${user.displayName} (${user.email})'
                            : user.email;
                    return DropdownMenuItem<UserEntity>(
                      value: user,
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: _onUserSelected,
                  validator: (v) => v == null ? l10n.requiredField : null,
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text(e.toString()),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.scoreTarget,
              controller: _scoreTargetController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.requiredField;
                if (int.tryParse(v) == null) return l10n.invalidNumber;
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.pairName,
              controller: _pairNameController,
              enabled: !_nameAutoFilled,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.sendInvite,
              isLoading: pairState.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                if (_selectedUser == null) return;
                await ref.read(pairNotifierProvider.notifier).sendPairInvite(
                      pairName: _pairNameController.text.trim(),
                      scoreTarget: int.parse(_scoreTargetController.text),
                      inviteEmail: _selectedUser!.email,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
