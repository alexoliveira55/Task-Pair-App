import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/validation_provider.dart';
import '../../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../../features/execution/presentation/providers/execution_provider.dart';
import '../../../../features/tasks/presentation/providers/task_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidationPage extends ConsumerStatefulWidget {
  final String executionId;

  const ValidationPage({super.key, required this.executionId});

  @override
  ConsumerState<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends ConsumerState<ValidationPage> {
  final _feedbackController = TextEditingController();
  int _percentage = 100;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitValidation({
    required String occurrenceId,
    required String executedBy,
    required String pairId,
    required int taskPoints,
  }) async {
    await ref.read(validationNotifierProvider.notifier).validate(
          executionId: widget.executionId,
          occurrenceId: occurrenceId,
          percentage: _percentage,
          feedback: _feedbackController.text.trim().isEmpty
              ? null
              : _feedbackController.text.trim(),
          pairId: pairId,
          taskPoints: taskPoints,
          executedBy: executedBy,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validationState = ref.watch(validationNotifierProvider);
    // Watch the stream of executions to find this execution's data
    final executionAsync = ref.watch(executionByIdProvider(widget.executionId));
    final pair = ref.watch(currentPairProvider);

    ref.listen(validationNotifierProvider, (_, next) {
      if (next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.validationCompleted)),
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
      appBar: AppBar(title: Text(l10n.validate)),
      body: executionAsync.when(
        data: (execution) {
          if (execution == null) {
            return Center(child: Text(l10n.noData));
          }
          if (pair == null) {
            return Center(child: Text(l10n.noPairs));
          }
          return Builder(builder: (context) {
            // Look up the task to get its points value
            final tasksAsync = ref.watch(tasksProvider);
            final task = tasksAsync.value
                ?.where((t) => t.id == execution.taskId)
                .firstOrNull;

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
                          Text(
                            l10n.reviewExecution,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (task != null) ...[
                            Text(l10n.taskLabel(task.title)),
                            Text(l10n.pointsLabel(task.points)),
                          ],
                          Text(l10n.executedAtDate(
                              execution.startedAt.toString().split('.').first)),
                          if (execution.finishedAt != null)
                            Text(l10n.finishedAtDate(execution.finishedAt!
                                .toString()
                                .split('.')
                                .first)),
                          if (execution.notes != null &&
                              execution.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(l10n.notesLabel(execution.notes!)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Percentage selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.percentage,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final pct in [
                                100,
                                90,
                                80,
                                70,
                                60,
                                50,
                                40,
                                30,
                                20,
                                10
                              ])
                                ChoiceChip(
                                  label: Text('$pct%'),
                                  selected: _percentage == pct,
                                  onSelected: (_) =>
                                      setState(() => _percentage = pct),
                                  selectedColor: Colors.green.shade200,
                                ),
                              ChoiceChip(
                                label: Text(l10n.notCompleted),
                                selected: _percentage == 0,
                                onSelected: (_) =>
                                    setState(() => _percentage = 0),
                                selectedColor: Colors.red.shade200,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  AppTextField(
                    label: l10n.feedbackOptional,
                    controller: _feedbackController,
                    maxLines: 4,
                    hint: l10n.feedbackHint,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: l10n.validate,
                    icon: Icons.check_circle,
                    color: _percentage > 0 ? Colors.green : Colors.red,
                    isLoading: validationState.isLoading,
                    onPressed: () => _submitValidation(
                      occurrenceId: execution.occurrenceId,
                      executedBy: execution.executedBy,
                      pairId: pair.id,
                      taskPoints:
                          task?.points ?? AppConstants.defaultTaskPoints,
                    ),
                  ),
                ],
              ),
            );
          });
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
