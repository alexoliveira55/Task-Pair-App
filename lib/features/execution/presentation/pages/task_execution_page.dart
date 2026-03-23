import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/execution_provider.dart';
import '../../../../features/recurrence/presentation/providers/recurrence_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/constants/app_constants.dart';

class TaskExecutionPage extends ConsumerStatefulWidget {
  final String occurrenceId;

  const TaskExecutionPage({super.key, required this.occurrenceId});

  @override
  ConsumerState<TaskExecutionPage> createState() => _TaskExecutionPageState();
}

class _TaskExecutionPageState extends ConsumerState<TaskExecutionPage> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final occurrencesAsync = ref.watch(occurrencesProvider);
    final executionState = ref.watch(executionNotifierProvider);

    ref.listen(executionNotifierProvider, (_, next) {
      if (next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.executionCompleted)),
        );
        context.pop();
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.execute)),
      body: occurrencesAsync.when(
        data: (occurrences) {
          final occurrence =
              occurrences.where((o) => o.id == widget.occurrenceId).firstOrNull;
          if (occurrence == null) {
            return Center(child: Text(l10n.noData));
          }
          if (occurrence.status != AppConstants.pendingStatus) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  Text(l10n.taskAlreadyStatus(occurrence.status)),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Task ID: ${occurrence.taskId}'),
                        Text(
                            '${l10n.dueDate}: ${occurrence.dueDate.toString().split(' ').first}'),
                        Text('Status: ${occurrence.status}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.executionNotes,
                  controller: _notesController,
                  maxLines: 4,
                  hint: l10n.executionNotesHint,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: l10n.finishExecution,
                  icon: Icons.check,
                  isLoading: executionState.isLoading,
                  onPressed: () async {
                    await ref
                        .read(executionNotifierProvider.notifier)
                        .executeTask(
                          occurrenceId: widget.occurrenceId,
                          taskId: occurrence.taskId,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
