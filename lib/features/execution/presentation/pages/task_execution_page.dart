import 'package:flutter/material.dart';
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
    final occurrencesAsync = ref.watch(occurrencesProvider);
    final executionState = ref.watch(executionNotifierProvider);

    ref.listen(executionNotifierProvider, (_, next) {
      if (next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task executed successfully!')),
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
      appBar: AppBar(title: const Text('Execute Task')),
      body: occurrencesAsync.when(
        data: (occurrences) {
          final occurrence = occurrences
              .where((o) => o.id == widget.occurrenceId)
              .firstOrNull;
          if (occurrence == null) {
            return const Center(child: Text('Occurrence not found'));
          }
          if (occurrence.status != AppConstants.pendingStatus) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  Text('This task is already ${occurrence.status}'),
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
                        Text('Due: ${occurrence.dueDate.toString().split(' ').first}'),
                        Text('Status: ${occurrence.status}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Notes (optional)',
                  controller: _notesController,
                  maxLines: 4,
                  hint: 'Add any notes about the execution...',
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Mark as Done',
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
