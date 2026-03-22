import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final pairAsync = ref.watch(currentPairProvider);
    final invitesAsync = ref.watch(pendingInvitesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pair Management')),
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

class _PairDetailsView extends StatelessWidget {
  final dynamic pair;

  const _PairDetailsView({required this.pair});

  @override
  Widget build(BuildContext context) {
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
                  Text('Score Target: ${pair.scoreTarget} points'),
                  Text('Created: ${pair.createdAt.toString().split(' ').first}'),
                ],
              ),
            ),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invites.length,
      itemBuilder: (context, index) {
        final invite = invites[index];
        return Card(
          child: ListTile(
            title: Text('Invite from ${invite.fromUserId}'),
            subtitle: Text('Pair invite pending'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () =>
                      ref.read(pairNotifierProvider.notifier).acceptInvite(invite),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () =>
                      ref.read(pairNotifierProvider.notifier).declineInvite(invite.id),
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
    final pairState = ref.watch(pairNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create a Pair',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Pair Name',
              controller: _pairNameController,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Score Target',
              controller: _scoreTargetController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Score target is required';
                if (int.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Invite Partner Email',
              controller: _inviteEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Create Pair & Send Invite',
              isLoading: pairState.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                await ref.read(pairNotifierProvider.notifier).createPairAndInvite(
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
