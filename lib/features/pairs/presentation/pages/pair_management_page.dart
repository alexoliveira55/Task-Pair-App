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

class PairManagementPage extends ConsumerWidget {
  const PairManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pairAsync = ref.watch(currentPairProvider);
    final invitesAsync = ref.watch(pendingInvitesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pairs)),
      body: pairAsync.when(
        data: (pair) {
          if (pair != null) {
            return _PairDetailsView(pair: pair);
          }
          return invitesAsync.when(
            data: (invites) {
              final pending = invites
                  .where((i) => i.status == AppConstants.inviteStatusPending)
                  .toList();
              if (pending.isNotEmpty) {
                return _InvitesView(invites: pending);
              }
              return const _CreatePairView();
            },
            loading: () => const LoadingWidget(),
            error: (e, _) => AppErrorWidget(message: e.toString()),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}

class _PairDetailsView extends ConsumerWidget {
  final dynamic pair;

  const _PairDetailsView({required this.pair});

  Future<void> _confirmLeavePair(BuildContext context, WidgetRef ref) async {
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
      await ref.read(pairNotifierProvider.notifier).leavePair();
      if (context.mounted) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pair.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('${l10n.scoreTarget}: ${pair.scoreTarget}'),
                  Text(
                      '${l10n.createdAt}: ${pair.createdAt.toString().split(' ').first}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/invite'),
                  icon: const Icon(Icons.person_add),
                  label: Text(l10n.invitePartner),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLeavePair(context, ref),
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  label: Text(l10n.leavePair,
                      style: const TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvitesView extends ConsumerWidget {
  final List<dynamic> invites;

  const _InvitesView({required this.invites});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invites.length,
      itemBuilder: (context, index) {
        final invite = invites[index];
        return Card(
          child: ListTile(
            title: Text(l10n.invitedBy(invite.fromUserId)),
            subtitle: Text(l10n.pendingInvites),
            trailing: Row(
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
            ),
          ),
        );
      },
    );
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
  final _inviteEmailController = TextEditingController();
  final _scoreTargetController =
      TextEditingController(text: AppConstants.defaultScoreTarget.toString());

  @override
  void dispose() {
    _pairNameController.dispose();
    _inviteEmailController.dispose();
    _scoreTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pairState = ref.watch(pairNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.createPair,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.pairName,
              controller: _pairNameController,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
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
              label: l10n.inviteEmail,
              controller: _inviteEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.requiredField;
                if (!v.contains('@')) return l10n.enterValidEmail;
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.createPairAndInvite,
              isLoading: pairState.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                await ref
                    .read(pairNotifierProvider.notifier)
                    .createPairAndInvite(
                      pairName: _pairNameController.text.trim(),
                      scoreTarget: int.parse(_scoreTargetController.text),
                      inviteEmail: _inviteEmailController.text.trim(),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
