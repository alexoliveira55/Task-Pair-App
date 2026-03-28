import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';
import 'package:task_pair_app/features/execution/presentation/providers/execution_provider.dart';
import 'package:task_pair_app/features/recurrence/presentation/providers/recurrence_provider.dart';
import 'package:task_pair_app/features/tasks/presentation/providers/task_provider.dart';
import 'package:task_pair_app/shared/widgets/loading_widget.dart';
import 'package:task_pair_app/shared/widgets/app_error_widget.dart';

class MyTasksPage extends ConsumerWidget {
  const MyTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final occurrencesAsync = ref.watch(occurrencesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tasks)),
      body: occurrencesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(occurrencesProvider),
        ),
        data: (_) {
          final pending = ref.watch(myPendingOccurrencesProvider);
          final inProgress = ref.watch(myInProgressOccurrencesProvider);
          final executed = ref.watch(myExecutedOccurrencesProvider);
          final validated = ref.watch(myValidatedOccurrencesProvider);

          if (pending.isEmpty &&
              inProgress.isEmpty &&
              executed.isEmpty &&
              validated.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noTasks,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.pendingTasks,
                  count: pending.length,
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                ...pending.map((o) => _OccurrenceCard(
                      occurrence: o,
                      section: AppConstants.pendingStatus,
                    )),
                const SizedBox(height: 16),
              ],
              if (inProgress.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.inProgressTasks,
                  count: inProgress.length,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 8),
                ...inProgress.map((o) => _OccurrenceCard(
                      occurrence: o,
                      section: AppConstants.inProgressStatus,
                    )),
                const SizedBox(height: 16),
              ],
              if (executed.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.executedTasks,
                  count: executed.length,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                ...executed.map((o) => _OccurrenceCard(
                      occurrence: o,
                      section: AppConstants.executedStatus,
                    )),
                const SizedBox(height: 16),
              ],
              if (validated.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.validatedTasks,
                  count: validated.length,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                ...validated.map((o) => _OccurrenceCard(
                      occurrence: o,
                      section: AppConstants.validatedStatus,
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _OccurrenceCard extends ConsumerWidget {
  final TaskOccurrenceEntity occurrence;
  final String section;

  const _OccurrenceCard({
    required this.occurrence,
    required this.section,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final task = ref.watch(taskByIdProvider(occurrence.taskId));
    final dueDateStr = occurrence.dueDate.toString().split(' ').first;
    final isOverdue = section == AppConstants.pendingStatus &&
        occurrence.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _statusIcon(section),
        title: Text(
          task?.title ?? occurrence.taskId,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: isOverdue ? Colors.red : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${l10n.dueDate}: $dueDateStr',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : null,
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            if (task != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${task.points} ${l10n.points}'),
                ],
              ),
            ],
          ],
        ),
        trailing: _trailingWidget(context, l10n),
        onTap: section == AppConstants.pendingStatus ||
                section == AppConstants.inProgressStatus
            ? () => context.push('/execute/${occurrence.id}')
            : null,
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case AppConstants.pendingStatus:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.pending_actions, color: Colors.white),
        );
      case AppConstants.inProgressStatus:
        return const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.timer, color: Colors.white),
        );
      case AppConstants.executedStatus:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.hourglass_top, color: Colors.white),
        );
      case AppConstants.validatedStatus:
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check_circle, color: Colors.white),
        );
      default:
        return const CircleAvatar(child: Icon(Icons.task));
    }
  }

  Widget _trailingWidget(BuildContext context, AppLocalizations l10n) {
    switch (section) {
      case AppConstants.pendingStatus:
        return FilledButton.icon(
          onPressed: () => context.push('/execute/${occurrence.id}'),
          icon: const Icon(Icons.play_arrow, size: 18),
          label: Text(l10n.startExecution),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      case AppConstants.inProgressStatus:
        return FilledButton.icon(
          onPressed: () => context.push('/execute/${occurrence.id}'),
          icon: const Icon(Icons.stop, size: 18),
          label: Text(l10n.finishExecution),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: Colors.deepPurple,
          ),
        );
      case AppConstants.executedStatus:
        return Chip(
          label: Text(l10n.pendingValidation),
          backgroundColor: Colors.blue.shade50,
          labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 12),
        );
      case AppConstants.validatedStatus:
        return Chip(
          label: Text(l10n.statusValidated),
          backgroundColor: Colors.green.shade50,
          labelStyle: TextStyle(color: Colors.green.shade700, fontSize: 12),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
