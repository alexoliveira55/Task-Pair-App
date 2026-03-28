import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/thermometer_widget.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/admin/presentation/providers/admin_provider.dart';
import '../../../../features/execution/presentation/providers/execution_provider.dart';
import '../../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../../features/score/presentation/providers/score_provider.dart';
import '../../../../features/tasks/presentation/providers/task_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../domain/entities/pair_entity.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPairsAsync = ref.watch(myPairsProvider);
    final l10n = AppLocalizations.of(context);

    return myPairsAsync.when(
      data: (pairs) {
        if (pairs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.dashboard),
              actions: _buildAppBarActions(context, ref, l10n),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noPairYet),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/pair-management'),
                    child: Text(l10n.createOrJoinPair),
                  ),
                ],
              ),
            ),
          );
        }

        final currentUser = ref.watch(currentUserEntityProvider).value;
        final pairsAsRequester =
            pairs.where((p) => p.requesterId == currentUser?.id).toList();
        final pairsAsExecutor =
            pairs.where((p) => p.executorId == currentUser?.id).toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.dashboard),
              actions: _buildAppBarActions(context, ref, l10n),
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: const Icon(Icons.assignment_ind),
                    text: l10n.tasksIExecute,
                  ),
                  Tab(
                    icon: const Icon(Icons.assignment),
                    text: l10n.tasksIRequest,
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _ExecutorView(pairsAsExecutor: pairsAsExecutor),
                _RequesterView(pairsAsRequester: pairsAsRequester),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.dashboard)),
        body: const LoadingWidget(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.dashboard)),
        body: Center(child: Text(e.toString())),
      ),
    );
  }

  List<Widget> _buildAppBarActions(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return [
      if (ref.watch(isAdminProvider))
        IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          tooltip: l10n.adminUserManagement,
          onPressed: () => context.push('/admin/users'),
        ),
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: l10n.settings,
        onPressed: () => context.push('/settings'),
      ),
      IconButton(
        icon: const Icon(Icons.person_outline),
        tooltip: l10n.profile,
        onPressed: () => context.push('/profile'),
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: l10n.logout,
        onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
      ),
    ];
  }
}

// ─── Tab 1: Tasks I execute (only for pairs where I am executor) ────────────

class _ExecutorView extends ConsumerWidget {
  final List<PairEntity> pairsAsExecutor;

  const _ExecutorView({required this.pairsAsExecutor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (pairsAsExecutor.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_ind_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noAssignedTasks),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final pair in pairsAsExecutor) ...[
              _ExecutorPairCard(pair: pair),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExecutorPairCard extends ConsumerWidget {
  final PairEntity pair;

  const _ExecutorPairCard({required this.pair});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Use pair-scoped providers so each card loads its own pair's data
    final pendingOccurrences = ref.watch(myPendingByPairProvider(pair.id));
    final inProgressOccurrences =
        ref.watch(myInProgressByPairProvider(pair.id));
    final executedOccurrences = ref.watch(myExecutedByPairProvider(pair.id));
    final validatedOccurrences = ref.watch(myValidatedByPairProvider(pair.id));
    final myPoints = ref.watch(myPointsByPairProvider(pair.id));
    final thermometerProgress = ref.watch(thermometerProgressByPairProvider(
        (pairId: pair.id, scoreTarget: pair.scoreTarget)));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pair header
            Text(
              pair.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Thermometer (only for executor)
            ThermometerWidget(
              progress: thermometerProgress,
              currentPoints: myPoints,
              targetPoints: pair.scoreTarget,
              height: 140,
            ),
            const SizedBox(height: 16),

            // Pending tasks
            Text(l10n.pendingTasks,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (pendingOccurrences.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 24, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(l10n.noAssignedTasks),
                  ],
                ),
              )
            else
              ...pendingOccurrences.map((occ) {
                final task = ref.watch(taskByIdProvider(occ.taskId));
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task?.title ?? occ.taskId,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.dueDate}: ${DateFormat.yMd().format(occ.dueDate)}'
                              '${task != null ? ' • ${task.points} ${l10n.points}' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.push('/execute/${occ.id}'),
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: Text(l10n.startExecution),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

            // In-progress tasks
            if (inProgressOccurrences.isNotEmpty) ...[
              const Divider(height: 24),
              Text(l10n.inProgressTasks,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...inProgressOccurrences.map((occ) {
                final task = ref.watch(taskByIdProvider(occ.taskId));
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task?.title ?? occ.taskId,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.dueDate}: ${DateFormat.yMd().format(occ.dueDate)}'
                              '${task != null ? ' • ${task.points} ${l10n.points}' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.push('/execute/${occ.id}'),
                              icon: const Icon(Icons.stop, size: 18),
                              label: Text(l10n.finishExecution),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Executed / awaiting validation
            if (executedOccurrences.isNotEmpty) ...[
              const Divider(height: 24),
              Text(l10n.awaitingValidation,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...executedOccurrences.map((occ) {
                final task = ref.watch(taskByIdProvider(occ.taskId));
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_top, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task?.title ?? occ.taskId,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.dueDate}: ${DateFormat.yMd().format(occ.dueDate)} • ${l10n.statusExecuted}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(l10n.awaitingValidation),
                              backgroundColor: Colors.blue.withOpacity(0.15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Validated
            if (validatedOccurrences.isNotEmpty) ...[
              const Divider(height: 24),
              Text(l10n.statusValidated,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...validatedOccurrences.map((occ) {
                final task = ref.watch(taskByIdProvider(occ.taskId));
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task?.title ?? occ.taskId,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.dueDate}: ${DateFormat.yMd().format(occ.dueDate)} • ${l10n.statusValidated}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(l10n.statusValidated),
                              backgroundColor: Colors.green.withOpacity(0.15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tab 2: Tasks I requested (for pairs where I am requester) ──────────────

class _RequesterView extends ConsumerWidget {
  final List<PairEntity> pairsAsRequester;

  const _RequesterView({required this.pairsAsRequester});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ResponsiveLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick actions row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/tasks/new'),
                  icon: const Icon(Icons.add_task),
                  label: Text(l10n.createTask),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/rewards'),
                  icon: const Icon(Icons.star),
                  label: Text(l10n.rewards),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/reports'),
                  icon: const Icon(Icons.bar_chart),
                  label: Text(l10n.reports),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/pair-management'),
                  icon: const Icon(Icons.people),
                  label: Text(l10n.pairs),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (pairsAsRequester.isEmpty) ...[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(l10n.noPairYet),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/pair-management'),
                      child: Text(l10n.createOrJoinPair),
                    ),
                  ],
                ),
              ),
            ] else ...[
              for (final pair in pairsAsRequester) ...[
                _RequesterPairCard(pair: pair),
                const SizedBox(height: 16),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RequesterPairCard extends ConsumerWidget {
  final PairEntity pair;

  const _RequesterPairCard({required this.pair});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pairTasks = ref.watch(myRequestedTasksByPairProvider(pair.id));
    final pairValidation = ref.watch(pendingValidationByPairProvider(pair.id));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pair header — NO THERMOMETER for requester
            Text(
              pair.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Needs validation section
            if (pairValidation.isNotEmpty) ...[
              Text(l10n.needsValidation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.deepOrange,
                      )),
              const SizedBox(height: 8),
              ...pairValidation.map((occ) {
                final task = ref.watch(taskByIdProvider(occ.taskId));
                final executionAsync =
                    ref.watch(executionByOccurrenceIdProvider(occ.id));
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.rate_review, color: Colors.deepOrange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task?.title ?? occ.taskId,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.dueDate}: ${DateFormat.yMd().format(occ.dueDate)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            executionAsync.when(
                              data: (execution) {
                                if (execution == null) {
                                  return const SizedBox.shrink();
                                }
                                return FilledButton.icon(
                                  onPressed: () =>
                                      context.push('/validate/${execution.id}'),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: Text(l10n.validate),
                                );
                              },
                              loading: () => const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
            ],

            // My requested tasks section
            Text(l10n.myRequestedTasks,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (pairTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 24, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(l10n.noTasks),
                  ],
                ),
              )
            else
              ...pairTasks.map((task) {
                return ListTile(
                  leading: Icon(
                    task.isActive ? Icons.task_alt : Icons.unpublished_outlined,
                    color: task.isActive ? Colors.green : Colors.grey,
                  ),
                  title: Text(task.title),
                  subtitle: Text(
                    '${task.points} ${l10n.points}'
                    '${task.isActive ? '' : ' • ${l10n.inactive}'}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/tasks/${task.id}/edit');
                      } else if (value == 'delete') {
                        _confirmDeleteTask(context, ref, task.id, l10n);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(l10n.delete,
                                style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, WidgetRef ref, String taskId,
      AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTask),
        content: Text(l10n.confirmDeleteItem(l10n.tasks)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(taskNotifierProvider.notifier).deleteTask(taskId);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
